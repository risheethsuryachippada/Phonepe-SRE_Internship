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
my $riemann_host = 'localhost';
my $riemann_port = 5555;
my $hostname = hostfqdn();
my $ttl = 60; # minimum guarantee ttl
my $disk_threshold = 0.9;
my $inode_threshold = 0.85;
my %disk_breach_per_mount;
my %inode_breach_per_mount;
my @mount_arr = ();

GetOptions ('hostname=s' => \$hostname,
        'riemann_host=s' => \$riemann_host,
        'riemann_port=i' => \$riemann_port,
	'disk=f' => \$disk_threshold,
	'inode=f' => \$inode_threshold,
	'ttl=i' => \$ttl
        ) or die("Error in command line arguments\n");

## Send alert to riemann
sub send_alert {
	my $conn = Riemann::Client->new(
                host => "$riemann_host",
                port => $riemann_port
        ) ;
        my ($riemann_service, $metric, $state, $desc) = @_;
#	print $conn . "    " . $riemann_service . "    " . $metric . "   " . $state . " ". $desc . " " . $ttl . "\n";
	        $conn->send({service => "$riemann_service",
			tags => ['system-check'],
	                metric => $metric,
	                state => "$state",
	                description => "$desc",
	                ttl => "$ttl",
	                host => "$hostname",
	                });
}

=begin comment
Sanitize mount points
The service name for riemann alert will be disk_<mountpoint> or inode_<mountpoint>
For example:
for mountpoint / the service would be disk_root or inode_root
For mountpoint /hdp/data01 the service would be disk_hdp_data and so on
This subroutine replaces '/' in mountpoint with '_'
For root partition '/', the sanitized string would be root
For /hdp/data01 -> hdp_data
For /hdp/data02 -> hdp_data
=cut
sub sanitize_mount_point {
	my $mount = shift;
	if ($mount =~ /^\/$/) {
		$mount = "root";
	}
	else {
		$mount =~ s/^\///;
		$mount =~ s/\//_/g;
		$mount =~ s/[0-9]+//g;
	}
	return $mount;
}

retry (sub{
	local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
	alarm $timeout;

	my $mountpoints = `df -x vfat | tail -n +2 | awk '{print \$1,\$6}' | grep -vE '(/dev/loop|var/cache/mylvmbackup/mnt)'`;
        foreach my $line (split("\n",$mountpoints)){
                chomp($line);
                my ($filesystem,$mount) = split(/\s+/,$line);
		## Only process the mountpoints containing '/';
                next unless($filesystem =~ /\//);
		## To keep track of disk alerts of same prefixed mountpoint
		## In case if disk for /hdp/data01 ad /hdp/data02 are critical
		## This is to make sure only one alert is generated for /hdp/data
		$disk_breach_per_mount{sanitize_mount_point($mount)} = 0;
		## To keep track of inode alerts of same prefixed mountpoint
		$inode_breach_per_mount{sanitize_mount_point($mount)} = 0;
		## List of mountpoints to check
		push(@mount_arr, $mount);
	}

	foreach my $mountpoint (@mount_arr){

		my $disk_use_description = "mountpoint          Disk Use (ratio)\n";
	        my $inode_use_description = "mountpoint         Inode Use (ratio)\n";
		my $alert_state = "ok";
		my ($disk_usage,$inode_usage) = get_disk_usage($mountpoint);

		#description
		$disk_use_description = $disk_use_description . "$mountpoint $disk_usage\n";
		$inode_use_description = $inode_use_description . "$mountpoint $inode_usage\n";
		my $sanitised_str = sanitize_mount_point($mountpoint);
		## Check if disk alert for same prefixed moutpoint is generated
		if ($disk_breach_per_mount{$sanitised_str} == 0) {

			if($disk_usage > $disk_threshold) {
				$disk_breach_per_mount{$sanitised_str} = 1;
				$alert_state = "critical";
			}
			send_alert("disk_".$sanitised_str, $disk_usage, $alert_state,
				$disk_use_description);
		}
		## Check if inode alert for same prefixed moutpoint is generated
		print "Sending disk $alert_state to riemann for $mountpoint\n" .
			$disk_use_description;
		$alert_state = "ok";
		if ($inode_breach_per_mount{$sanitised_str} == 0) {
			if($inode_usage > $inode_threshold) {
				$inode_breach_per_mount{$sanitised_str} = 1;
				$alert_state = "critical";
                	}
			send_alert("inode_".$sanitised_str, $inode_usage, $alert_state,
				$inode_use_description);
		}
		print "Sending inode $alert_state to riemann for $mountpoint\n" .
			$inode_use_description;
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

sub get_disk_usage(){
        my $dir = shift;
        my ($fs_type, $fs_desc, $used, $avail, $fused, $favail);
        eval { ($fs_type, $fs_desc, $used, $avail, $fused, $favail) = df $dir};
        if($@){($used, $avail, $fused, $favail) = manual_df($dir);}
        my $disk_usage = sprintf("%.2f", ($used / ($used+$avail)));
	my $inode_usage = sprintf("%.2f", ($fused / ($fused+$favail)));
        return($disk_usage,$inode_usage);
}

## If df fails
sub manual_df(){
        my $dir = shift;
        my @return_array;
        my $out = `df $dir | tail -1 | awk '{print \$3,\$4}'`;
        push(@return_array,split(" ",$out));
        $out = `df -i $dir | tail -1 | awk '{print \$3,\$4}'`;
        push(@return_array,split(" ",$out));
        return @return_array;
}