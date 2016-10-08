#! perl

# 
#  
# This script read, validate and create tickets from a CSV file (with separtor ";" for excel compatibility); 
# the CSV file is in the format:
#
# These are the link types that are available as of 05/05/2015:
# blocks                <-->  is blocked by
# was cloned as         <-->  is a clone of
# is delta review from  <-->  is basis review of
# duplicates            <-->  is duplicated by
# is a follow-up of     <-->  is followed-up by
# integrates            <-->  is integrated by
# is relating to        <-->  is related to
# is sub issue of       <-->  is master issue of
# is a test of          <-->  is tested by
#
#T1;T2
#

use strict;
use warnings;
use File::Basename;
use Data::Dumper;
use Getopt::Long; 
use JSON;
use LWP::UserAgent;
use LWP::Debug qw(+);
use strict;
use HTTP::Request::Common qw(POST);
use LWP::Protocol::https;
use Scalar::Util qw(looks_like_number);
use PAISEU::JiraRestCreationUtils;
use PAISEU::JiraRestUpdateIssueUtils;
use PAISEU::LogMessage;
use Text::CSV_XS;
use Term::ReadKey;
use Cwd 'abs_path';
use POSIX qw/strftime/;


#my $JIRA_SERVER  = "http://bugs.lng.pce.cz.pan.eu:8081";
my $JIRA_SERVER  = "http://gelijiratestneo.lng.pce.cz.pan.eu:8085";
my $JIRA_USER    = "";
my $JIRA_PASSWD  = "";
$JIRA_USER   = "extern.lorenzo";
$JIRA_PASSWD = "Qwertzuiop789m";
my $LABEL_STR        = "";
my $cwd = "";


###########################################################################################
# MAIN
###########################################################################################

print "Please enter Jira user name and password\n";


my $file_to_read = $ARGV[0];
my $lines = [];
read_lines_from_file($file_to_read, $lines);

my $linked_tickets = 0;
foreach my $line (@$lines) {
	chomp($line);
	my ($task, $rev) = split(';', $line);
	createIssueLink($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD, "Related", $rev, $task, 0,0,0);
	$linked_tickets++;
}


log_msg($LOG_TYPE_INF, "EXIT, linked $linked_tickets tickets");

exit(0);



sub read_lines_from_file {
	my ($file_to_read, $lines) = @_;
	open (my $fh, '<', $file_to_read) or die "Can't open $file_to_read\n";
	@{$lines} = <$fh>;
	close ($fh) or die "Can't close $file_to_read\n";
}

__END__

