#!/usr/bin/perl
use strict;
use Riemann::Client;
use Getopt::Long;
use Data::Dumper;
use Filesys::DiskSpace;
use Net::Domain qw(hostname hostfqdn);
use POSIX;
my $max_retries = 3;
my $timeout = 10;
# option setting (default) and parsing
my $riemann = 'localhost';
my $hostname = hostfqdn();
my $interval = 10;
my $ttl = 60; # minimum guarantee ttl
my $user_input_ttl = 40; # some random ttl value (just to inititialize)
# get and set options from cmdline
GetOptions ('hostname=s' => \$hostname,
        'riemann=s' => \$riemann,
        'lasting=i' => \$user_input_ttl
        ) or die("Error in command line arguments\n");
# MAIN FUNC 
retry( sub {  
		local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
		alarm $timeout;
		# initialize riemann client
		my $r = Riemann::Client->new(
                	host => "$riemann",
                	port => '5555',
        	) ;
		# execute the check
		my $uptime = ceil(uptime());
		my $days = floor($uptime/86400);
		my $hours = floor(($uptime%86400)/3600);
		my $state = (($days*24 + $hours)>6) ? 'ok':'warning'; #warn if less than 6 hours
		my $description = "$days d $hours h";
		$ttl = ($ttl > $user_input_ttl) ? $ttl : $user_input_ttl; #select the bigger ttl
		$r->send({service => 'uptime',
		                metric => $days,
		                state => "$state",
		                description => "$description",
		                ttl => "$ttl",
		                tags => ['system-check'],
		                host => "$hostname",
		                }
		);
		
} ); 

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

# uptime check
sub uptime {
        # Read the uptime in seconds from /proc/uptime, skip the idle time...
        open FILE, "< /proc/uptime" or die return ("Cannot open /proc/uptime: $!");
                my ($uptime, undef) = split / /, <FILE>;
        close FILE;
        return ($uptime);
}
