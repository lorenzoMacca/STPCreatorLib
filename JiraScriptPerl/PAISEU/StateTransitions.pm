package PAISEU::StateTransitions;
#=============================================================================
#  $HeadURL: $
#  $Revision: $
#  $Author:  $
#  $Date: $
#=============================================================================

use strict;
use warnings;

use PAISEU::LogMessage;
use PAISEU::JiraRestUpdateIssueUtils;

use Exporter;
use base 'Exporter';

our @EXPORT = qw (
    get_initial_status_for_wf
    get_steps
    executeTransitions
    go_to_step
);

my $JIRA_SERVER;
my $JIRA_USER;
my $JIRA_PASSWD;

my $initial_status = {};
my $steps = {};



################################################################################
#                         Steps for the OV001 project
################################################################################

###############################
# Issue type CCR Implementation
###############################

$initial_status->{'OV001'}->{'CCR Implementation'} = 'New';

$steps->{'OV001'}->{'CCR Implementation'}->{'Estimation'}->{'previous'}   = 'New';
$steps->{'OV001'}->{'CCR Implementation'}->{'Estimation'}->{'transition'} = 'Estimate';

$steps->{'OV001'}->{'CCR Implementation'}->{'Supplier offer ready'}->{'previous'}   = 'Estimation';
$steps->{'OV001'}->{'CCR Implementation'}->{'Supplier offer ready'}->{'transition'} = 'Supplier offer ready';

$steps->{'OV001'}->{'CCR Implementation'}->{'Offer rejected'}->{'previous'}   = 'Supplier offer ready';
$steps->{'OV001'}->{'CCR Implementation'}->{'Offer rejected'}->{'transition'} = 'Reject offer';

$steps->{'OV001'}->{'CCR Implementation'}->{'Ordered'}->{'previous'}   = 'Supplier offer ready';
$steps->{'OV001'}->{'CCR Implementation'}->{'Ordered'}->{'transition'} = 'Ordered';

$steps->{'OV001'}->{'CCR Implementation'}->{'In process'}->{'previous'}   = 'Ordered';
$steps->{'OV001'}->{'CCR Implementation'}->{'In process'}->{'transition'} = 'In process';

$steps->{'OV001'}->{'CCR Implementation'}->{'Supplier Testing/QS'}->{'previous'}   = 'In process';
$steps->{'OV001'}->{'CCR Implementation'}->{'Supplier Testing/QS'}->{'transition'} = 'Supplier Testing/QS';

$steps->{'OV001'}->{'CCR Implementation'}->{'To be tested on test system'}->{'previous'}   = 'Supplier Testing/QS';
$steps->{'OV001'}->{'CCR Implementation'}->{'To be tested on test system'}->{'transition'} = 'To be tested on test system';

$steps->{'OV001'}->{'CCR Implementation'}->{'Bug found on test system'}->{'previous'}   = 'To be tested on test system';
$steps->{'OV001'}->{'CCR Implementation'}->{'Bug found on test system'}->{'transition'} = 'Bug found';

$steps->{'OV001'}->{'CCR Implementation'}->{'Tested'}->{'previous'}   = 'To be tested on test system';
$steps->{'OV001'}->{'CCR Implementation'}->{'Tested'}->{'transition'} = 'Successfully tested on test system';

$steps->{'OV001'}->{'CCR Implementation'}->{'Cancelled'}->{'previous'}   = 'Tested';
$steps->{'OV001'}->{'CCR Implementation'}->{'Cancelled'}->{'transition'} = 'Cancel';

$steps->{'OV001'}->{'CCR Implementation'}->{'Ready to release'}->{'previous'}   = 'Tested';
$steps->{'OV001'}->{'CCR Implementation'}->{'Ready to release'}->{'transition'} = 'Ready to release';

$steps->{'OV001'}->{'CCR Implementation'}->{'To be tested on live system'}->{'previous'}   = 'Ready to release';
$steps->{'OV001'}->{'CCR Implementation'}->{'To be tested on live system'}->{'transition'} = 'Test on live system';

$steps->{'OV001'}->{'CCR Implementation'}->{'Bug found on live system'}->{'previous'}   = 'To be tested on live system';
$steps->{'OV001'}->{'CCR Implementation'}->{'Bug found on live system'}->{'transition'} = 'Bug found';

$steps->{'OV001'}->{'CCR Implementation'}->{'Closed'}->{'previous'}   = 'To be tested on live system';
$steps->{'OV001'}->{'CCR Implementation'}->{'Closed'}->{'transition'} = 'Successfully tested on live system';


################
# Issue type ERR
################


$initial_status->{'OV001'}->{'ERR'} = 'New';

$steps->{'OV001'}->{'ERR'}->{'Pre-Analysed'}->{'previous'}   = 'New';
$steps->{'OV001'}->{'ERR'}->{'Pre-Analysed'}->{'transition'} = 'Pre-Analyse';

$steps->{'OV001'}->{'ERR'}->{'Analysed'}->{'previous'}   = 'Pre-Analysed';
$steps->{'OV001'}->{'ERR'}->{'Analysed'}->{'transition'} = 'Analyse';

$steps->{'OV001'}->{'ERR'}->{'Postponed'}->{'previous'}   = 'Analysed';
$steps->{'OV001'}->{'ERR'}->{'Postponed'}->{'transition'} = 'Postpone';

$steps->{'OV001'}->{'ERR'}->{'Rejected'}->{'previous'}   = 'Analysed';
$steps->{'OV001'}->{'ERR'}->{'Rejected'}->{'transition'} = 'Reject';

$steps->{'OV001'}->{'ERR'}->{'Closed-Rej'}->{'previous'}   = 'Rejected';
$steps->{'OV001'}->{'ERR'}->{'Closed-Rej'}->{'transition'} = 'Close rejected';

$steps->{'OV001'}->{'ERR'}->{'Accepted'}->{'previous'}   = 'Analysed';
$steps->{'OV001'}->{'ERR'}->{'Accepted'}->{'transition'} = 'Accept';

$steps->{'OV001'}->{'ERR'}->{'In process'}->{'previous'}   = 'Accepted';
$steps->{'OV001'}->{'ERR'}->{'In process'}->{'transition'} = 'In process';

$steps->{'OV001'}->{'ERR'}->{'Developed'}->{'previous'}   = 'In process';
$steps->{'OV001'}->{'ERR'}->{'Developed'}->{'transition'} = 'Develop';

$steps->{'OV001'}->{'ERR'}->{'Supplier Testing/QS'}->{'previous'}   = 'Developed';
$steps->{'OV001'}->{'ERR'}->{'Supplier Testing/QS'}->{'transition'} = 'Supplier Testing/QS';

$steps->{'OV001'}->{'ERR'}->{'To be tested on live system'}->{'previous'}   = 'Supplier Testing/QS';
$steps->{'OV001'}->{'ERR'}->{'To be tested on live system'}->{'transition'} = 'Test on live system';

$steps->{'OV001'}->{'ERR'}->{'Tested'}->{'previous'}   = 'To be tested on live system';
$steps->{'OV001'}->{'ERR'}->{'Tested'}->{'transition'} = 'Test successful';

$steps->{'OV001'}->{'ERR'}->{'Closed-OK'}->{'previous'}   = 'Tested';
$steps->{'OV001'}->{'ERR'}->{'Closed-OK'}->{'transition'} = 'Close';


#################
# Issue type Task
#################

$initial_status->{'OV001'}->{'Task'} = 'Open';

$steps->{'OV001'}->{'Task'}->{'In Progress'}->{'previous'}   = 'Open';
$steps->{'OV001'}->{'Task'}->{'In Progress'}->{'transition'} = 'Start Progress';

$steps->{'OV001'}->{'Task'}->{'Resolved'}->{'previous'}   = 'Open';
$steps->{'OV001'}->{'Task'}->{'Resolved'}->{'transition'} = 'Resolve Issue';

$steps->{'OV001'}->{'Task'}->{'Reopened'}->{'previous'}   = 'Resolved';
$steps->{'OV001'}->{'Task'}->{'Reopened'}->{'transition'} = 'Reopen Issue';

$steps->{'OV001'}->{'Task'}->{'Closed'}->{'previous'}   = 'Open';
$steps->{'OV001'}->{'Task'}->{'Closed'}->{'transition'} = 'Close Issue';


################################################################################
#                        Steps for the DA016 project
################################################################################

#################
# Issue type Task
#################

$initial_status->{'DA016'}->{'RQ'} = 'New';







################################################################################
################################################################################
#                                 Functions
################################################################################
################################################################################


sub get_initial_status_for_wf {
    my ($project, $issue_type) = @_;
    
    if (defined $initial_status->{$project}->{$issue_type}) {
        return  $initial_status->{$project}->{$issue_type};
    } else {
        return undef;
    }
}


sub get_steps {
    my ($project, $issue_type) = @_;
    
    if (defined $steps->{$project}->{$issue_type}) {
        return  $steps->{$project}->{$issue_type};
    } else {
        return undef;
    }
}


sub executeTransitions {
    $JIRA_SERVER = shift;
    $JIRA_USER   = shift;
    $JIRA_PASSWD = shift;
    my $newstatus = shift;
    my $issueKey  = shift;
    my $project   = shift;
    my $issueType = shift;
    
    # This is how to reach each step of the OV001 CCR_Implementation wf.
    my $steps = get_steps($project, $issueType);
    my $initial_status_for_wf = get_initial_status_for_wf($project, $issueType);
    
    if (! defined $initial_status_for_wf) {
        die "ERROR: initial_status_for_wf should be defined\n";
    }
    
    if (! defined $steps) {
        log_msg($LOG_TYPE_WARN, "Error: transitions are not defined for project = $project and issue type = $issueType");
    }
    
    #Array of @["Requirement Summay", "Requirement Description", "SYR Ticket Summary" ]
    if ($newstatus ne $initial_status_for_wf){
        
        my $current_step = $initial_status_for_wf;
        if (go_to_step($current_step, $newstatus, $steps, $issueKey) eq $newstatus) {
            log_msg($LOG_TYPE_INF, "Transition to \"$newstatus\" completed for ticket ".$issueKey);
        } else {
            log_msg($LOG_TYPE_WARN, "Error: step $newstatus couldn't be reached for ".$issueKey);
        }
    }
    else{
        log_msg($LOG_TYPE_INF, "Ticket ". $issueKey ." already in status $initial_status_for_wf");
        #print "STATUS already $initial_status_for_wf\n";
    }
}


# Go all the way from current_step to step_to_reach, recursively. For example, if you are at step 3
# and you have to reach step 6 (the order is 3->4->5->6), the algorithm will try to go from 3 to 6,
# but 6 can only be reached through 5, so it will try 3->5; 5 can be reached by 4, so it will try
# 3->4, which can be done. This ends the recursion, and the function returns that the new current
# status is 4, then the stack is unwound and it goes from 4 to 5, stack is unwound, 5 to 6, over.
sub go_to_step {
    my ($current_step, $step_to_reach, $steps, $issueKey) = @_;
    
    #print "Debug, current step = $current_step, step to reach = $step_to_reach, issue key = $issueKey\n";
    
    # Check that the "routing" information (the name of the previous step) is available
    if (! defined $steps->{$step_to_reach}) {
        log_msg($LOG_TYPE_WARN, "Error: transitions to step $step_to_reach are unknown");
        return $current_step;
    }
    
    # If step_to_reach is more than one "hop" away from current_step, go there recursively
    if ($current_step ne $step_to_reach && $current_step ne $steps->{$step_to_reach}->{'previous'}) {
        print "Debug: recursion, step to reach = $steps->{$step_to_reach}->{'previous'}\n";
        $current_step = go_to_step($current_step, $steps->{$step_to_reach}->{'previous'}, $steps, $issueKey);
    }
    
    # At this point, thanks to the previous if, we are sure we have reached the step before
    # step_to_reach, so now we can perform the transition and return the step that has been rached
    if ($current_step eq $steps->{$step_to_reach}->{'previous'}) {
        if (executeIssueTransition($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,$issueKey,0,"$steps->{$step_to_reach}->{'transition'}","")){
            log_msg($LOG_TYPE_INF, "Reached step $step_to_reach");
            return $step_to_reach;
        } else {
            log_msg($LOG_TYPE_WARN, "Error on transition \"$steps->{$step_to_reach}->{'transition'}\"" );
            return $current_step;
        }
    } elsif ($current_step eq $step_to_reach) {
        return $current_step;
    }
}


1;

__END__