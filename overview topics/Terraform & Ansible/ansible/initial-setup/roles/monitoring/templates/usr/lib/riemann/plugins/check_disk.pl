#!/usr/bin/perl
use strict;
use Riemann::Client;
use Getopt::Long;
use Data::Dumper;
use Filesys::DiskSpace;
use Net::Domain qw(hostname hostfqdn);

my $max_retries = 3;
my $timeout = 10;
# option setting (default) and parsing
my $riemann = 'localhost';
my $hostname = hostfqdn();
my $interval = 10;
my $ttl = 60; # minimum guarantee ttl
my $user_input_ttl = 40; # some random ttl value (just to inititialize)
my $disk_threshold = 0.9;
my $inode_threshold = 0.85;

GetOptions ('hostname=s' => \$hostname,
        'riemann=s' => \$riemann,
	'disk=f' => \$disk_threshold,
	'file=f' => \$inode_threshold,
	'lasting=i' => \$user_input_ttl
        ) or die("Error in command line arguments\n");

retry (sub{
	local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
	alarm $timeout;
	#initialize riemann client
	my $r = Riemann::Client->new(
			host => "$riemann",
			port => '5555',
		) ;

	my $disk_use_description = "mountpoint		Disk Use (ratio)\n";
	my $inode_use_description = "mountpoint 	Inode Use (ratio)\n";
	my ($disk_metric,$disk_state) = 0;
	my ($inode_metric,$inode_state) = 0;

	my $mountpoints = `df -x vfat | tail -n +2 | awk '{print \$1,\$6}' | grep -v '/dev/loop'`;
	foreach my $line (split("\n",$mountpoints)){
		chomp($line);
		my ($filesystem,$mount) = split(/\s+/,$line);
		next unless($filesystem =~ /\//);
		my ($disk_usage,$inode_usage) = get_disk_usage($mount);
		#description
		$disk_use_description = $disk_use_description."$mount		$disk_usage\n";
		$inode_use_description = $inode_use_description."$mount 	$inode_usage\n";
		#metric
		$disk_metric = ($disk_metric > $disk_usage) ? $disk_metric : $disk_usage;
		$inode_metric = ($inode_metric > $inode_usage) ? $inode_metric : $inode_usage;
		#state
		my $mount_disk_state = ($disk_usage > $disk_threshold) ? 2 : 0;
		my $mount_inode_state = ($inode_usage > $inode_threshold) ? 2 : 0;
		$disk_state = ($disk_state > $mount_disk_state) ? $disk_state : $mount_disk_state;
		$inode_state = ($inode_state > $mount_inode_state) ? $inode_state : $mount_inode_state;
		
	}

	$ttl = ($ttl > $user_input_ttl) ? $ttl : $user_input_ttl;
	# disk metric push to riemann
	my $disk_state_riemann = ($disk_state == 2) ? 'critical':'ok';
	$r->send({service => 'disk',
			metric => $disk_metric,
			state => "$disk_state_riemann",
			description => "$disk_use_description",
			ttl => "$ttl",
			tags => ['system-check'],
			host => "$hostname",
			}
	);
	# inode metric push to riemann
	my $inode_state_riemann = ($inode_state == 2) ? 'critical':'ok';
	$r->send({service => 'inode',
			metric => $inode_metric,
			state => "$inode_state_riemann",
			description => "$inode_use_description",
			ttl => "$ttl",
			tags => ['system-check'],
			host => "$hostname",
			}
	);

	if ($inode_state_riemann eq 'critical' or $disk_state_riemann eq 'critical'){
		# debug info in log (in case of critical)
		print "Disk:\n$disk_use_description\nInode:\n$inode_use_description\n";
	}
});

# retry logic - expects sub ref and tries it upto max_retries times if it encounters exceptions 
sub retry {
    my $sub_ref = shift;
    my $try     = 0;
  ATTEMPT: {
        eval { $sub_ref->(); };
        if ( $@ and $try++ < $max_retries ) {
            warn "Failed try $try, retrying.  Error: $@\n";
            redo ATTEMPT;
        }
    }
    if ($@) { die "failed after $max_retries tries: $@\n" }
}

# other functions
sub get_disk_usage(){
        my $dir = shift;
        my ($fs_type, $fs_desc, $used, $avail, $fused, $favail);
        eval { ($fs_type, $fs_desc, $used, $avail, $fused, $favail) = df $dir};
        if($@){($used, $avail, $fused, $favail) = manual_df($dir);}
        my $disk_usage = (($used) / ($avail+$used));
        my $inode_usage = (($fused) / ($fused+$favail));
        return($disk_usage,$inode_usage);
}

sub manual_df(){
        my $dir = shift;
        my @return_array;
        # df
        my $out = `df $dir | tail -1 | awk '{print \$3,\$4}'`;
#       chomp($out);
        push(@return_array,split(" ",$out));
        # df -i
        $out = `df -i $dir | tail -1 | awk '{print \$3,\$4}'`;
#       chomp($out);
        push(@return_array,split(" ",$out));
        return @return_array;
}
