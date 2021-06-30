use strict;
use warnings;
use Net::Domain qw(hostfqdn);
use YAML::XS 'LoadFile';
use Getopt::Long;
use Data::Dumper qw(Dumper);
use Riemann::Client;

use v5.10;

# Get the hostname of the running machine
# my $host_name = 'cor-chrony001.phonepe.nm5';
my $host_name = hostfqdn();
my $riemann = 'riemann-prod';
my $CONF_FILE = '';
my $config = '';

GetOptions(
  "riemann=s" => \$riemann,
  "config=s" => \$CONF_FILE,
);
print("Riemann: $riemann\n");



# 1st param riemann obj
# 2nd param desc
# 3rd param state
# 4th param metric
sub send_riemann_event {
  my $rie = shift;
  my $desc = shift;
  my $state = shift;
  my $metric = shift;
  eval {
    $rie->send({
      service => "Chrony Check",
      metric => $metric,
      state => $state,
      description => $desc,
      ttl => 120.0
    });
    print("$state event sent.\n\n");
  };
  if ($@) {
    print("Error sending '$state' event.\n\n");
  }
  exit();
}


sub check_stratum {
  my $rie = shift;
  my $host_str = shift;
  my $op_str = shift;

  if ($host_str == $op_str) {
    print("Stratum value: $op_str, looks good for $host_name\n");
    send_riemann_event($rie, "Stratum value: $op_str, looks good for $host_name", 'ok', 1.0);
  } else {
    print("Stratum value: $op_str is incorrect for $host_name. Should be $host_str\n");
    send_riemann_event($rie, "Stratum value: $op_str is incorrect for $host_name. Should be $host_str", 'critical', 0.0);
  }
}

sub check_ntp {
  print "Checking if NTP is running\n";
  my $running_status = `timeout 5 systemctl show -p SubState ntp | sed 's/SubState=//g'`;
  chomp $running_status;
  if ($running_status eq "running"){
	print "NTP is running, Executing chrony salt\n";
	my $exit_code = system("timeout 60 salt-call state.sls chrony.client");
        if ($exit_code != 0) {
		print "Salt execution failed\n";
	} else {
		print "Salt execution succeeded\n";
	}
    }
}

my $r = Riemann::Client->new(
    host => "$riemann"
);

check_ntp();

eval {
  $config = LoadFile($CONF_FILE);
};
if ($@) {
  print("Failed to read config file at $CONF_FILE\n");
  send_riemann_event($r, "Failed to read config file at $CONF_FILE", 'critical', 0.0);
}
my $domain = substr($host_name, -3);
if($config->{$domain}) {
  print("Config loaded\n");
} else {
  print("Domain of $host_name didnt matched with any env in config file\n");
  print Dumper($config);
  send_riemann_event($r, "Domain of $host_name didnt matched with any env in config file", 'critical', 0.0);

}

my $resp = `chronyc tracking`;
unless ($resp) {
  print("Failed to execute 'chronyc tracking' command.\n");
  send_riemann_event($r, "Failed to execute 'chronyc tracking' command", 'critical', 0.0);
}

eval {

  my @output_lines = split('\n', $resp);
  my $op_stratum = substr($output_lines[1], -1) + 0;
  my $prefix_length = length $config->{$domain}->{'server_hostname_prefix'};

  # if the hostname is a chrony server
  if (substr($host_name, 0, $prefix_length) eq $config->{$domain}->{'server_hostname_prefix'}) {
    check_stratum($r, $config->{$domain}->{'server_hosts'}, $op_stratum);
  }

  # if the hostname is not a chrony server
  else {
    check_stratum($r, $config->{$domain}->{'other_hosts'}, $op_stratum);
  }
};
if ($@) {
  print("Error parsing output of 'chronyc tracking' command\n");
  send_riemann_event($r, "Error parsing output of 'chronyc tracking' command", 'critical', 0.0);
}