package PAISEU::LogMessage;

# little helper module, to create standard logfiles.
# log4perl would be better, but it need an extra installed external module.
# until that is done. This thing will help - hopefully.
# All logmessage are written to STDOUT, instead of a dedicated logfile. So
# to have a logfile the STDOUT and STDErr should be written to a file.
#
# author: extern.schroeder
# date:   2010-10-28

use strict;
use warnings;
use Exporter;
use strict;
use warnings;
use Term::ReadKey;
use base 'Exporter';
use POSIX qw/strftime/;
use IO::Handle; # For autoflush

our @EXPORT = qw(
    $LOG_TYPE_INF
    $LOG_TYPE_WARN
    $LOG_TYPE_ERR
    $LOG_TYPE_FATAL
    $LOG_TYPE_TRACE

    set_log_die_message
    log_msg
    passwordPrompt
    userPrompt
);


##############################################################################
# PUBLIC VARIABLES
##############################################################################
our $LOG_TYPE_INF   = 0;
our $LOG_TYPE_WARN  = 1;
our $LOG_TYPE_ERR   = 2;
our $LOG_TYPE_FATAL = 3;
our $LOG_TYPE_TRACE = 4;

my %log_typestring = (
    $LOG_TYPE_INF   => "INFO ",
    $LOG_TYPE_WARN  => "WARN ",
    $LOG_TYPE_ERR   => "ERR  ", 
    $LOG_TYPE_FATAL => "FATAL",
    $LOG_TYPE_TRACE => "TRACE"
);

our $DIE_MESSAGE = -1;


# if the log_message is used to end the programm, this function sets the
# level when to die.
sub set_log_die_message {
    my $log_fatal = shift;
    $DIE_MESSAGE = $log_fatal;              
}


# Helper function until a better Log is installed.
# Should log all messages and traces on STDOUT or a given file.
sub log_msg {
    my $type = shift;
    my $msg  = shift;

    print strftime("%Y-%m-%d %H:%M:%S", localtime) . " - $log_typestring{$type}: $msg\n";
    
    if ($DIE_MESSAGE >= $type) {
        die $!; 
    }
}


## The input is not secret, therefore it is shown normally
sub userPrompt(){
    
    STDOUT->autoflush(1); # Flush output every time (otherwise, if STDOUT is redirected to a file/pipe, you won't see
                          # that you are prompted for username and password, you will read the request only after you
                          # have typed the answer in)
    print "\nPlease input username: ";
    my $username = "";
    
    $username = ReadLine(0);
    chomp($username);
    print "\n";
    
    #print "Your username is: $username\n";
    
    STDOUT->autoflush(0); # Restore normal buffering
    
    return $username;
}


## The input is secret, therefore nothing is shown, not even a '*' for each key.
#  The reason behind this is that to show a '*' for every key we have to use the ReadKey
#  function, as explained at http://stackoverflow.com/questions/701078/how-can-i-enter-a-password-using-perl-and-replace-the-characters-with,
# but it doesn't work well under Windows, where lines are terminated by CRLF.
sub passwordPrompt(){
    
    STDOUT->autoflush(1); # Flush output every time (otherwise, if STDOUT is redirected to a file/pipe, you won't see
                          # that you are prompted for username and password, you will read the request only after you
                          # have typed the answer in)
    print "\nPlease input your password: ";
    my $password = "";
    
    # Taken from http://docstore.mik.ua/orelly/perl/cookbook/ch15_11.htm
    ReadMode('noecho');      # Explained at http://search.cpan.org/dist/TermReadKey/ReadKey.pm
    $password = ReadLine(0);
    chomp($password);
    print "\n";
    
    #print "Your password is: $password\n";
    
    ReadMode(0); #Reset the terminal once we are done
    
    STDOUT->autoflush(0); # Restore normal buffering
    
    return $password;
}

1;

__END__
