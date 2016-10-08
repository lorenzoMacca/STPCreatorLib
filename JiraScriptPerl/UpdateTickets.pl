#! perl

# 
# JIRA - Script for tickets update from a CSV files
#  
# This script read, validate and create tickets from a CSV file (with separtor ";" for excel compatibility); 
# the CSV file is in the format:
#
#
# Project;GL005
# IssueType;REV
# TODO
# IssueKey;field names  to update;...;...;...
# row1values;..;..;..;..;..;..;..;..;..;..
# row2values;..;..;..;..;..;..;..;..;..;..
#
#
# Author: Prevignano Massimo
# Creation Date: 05-12-2014
#

use strict;
use warnings;
use File::Basename;
use Data::Dumper;
use Getopt::Long; 
use JSON;
use LWP::UserAgent;
use strict;
use HTTP::Request::Common qw(POST);
use Scalar::Util qw(looks_like_number);
use PAISEU::JiraRestUpdateIssueUtils;
use PAISEU::LogMessage;
use Text::CSV_XS;
use Term::ReadKey;
use Cwd 'abs_path';


my $JIRA_SERVER  = "http://bugs.lng.pce.cz.pan.eu:8081";
#my $JIRA_SERVER  = "http://gew12kjiraneo.lng.pce.cz.pan.eu:8085";
my $JIRA_USER    = "";  # If this variable is empty, you will be prompted for it when you start the script
my $JIRA_PASSWD  = "";  # If this variable is empty, you will be prompted for it when you start the script
my $LABEL_STR        = "";

my $JSON_PROJECT_EDIT_META = 0;

#Input csv files name
my $CsvInputFileName;

#Global values for all tickets
my $project = "";
my $securityLevel = "gl005_onsite";
my $priority = "Major";
my $dueDate = "2015-04-01";
my $headersRow = ();
my $issueType = "";
my $issueKeyColumnIndex = -1;
my $reporter = 0;
my $OnlyVerify = 0;
my $cwd = "";

#====================================================================================
#Usage function
# ...
#====================================================================================
sub usage {
    print $#ARGV."\n";
    if ($#ARGV < 0 or $#ARGV > 1) {
        print "usage: UpdateTickets [-t] cvsUpdateTicketsFile\n";
        close ;
        exit;
    }
    
    my $argvrevidx = 0;
    
    if($ARGV[0] eq "\-t"){
        $argvrevidx = 1;
        $OnlyVerify = 1;
    }
    
    if (-e $ARGV[$argvrevidx]) {
        $CsvInputFileName = $ARGV[$argvrevidx];
        log_msg($LOG_TYPE_INF, "Input file: $ARGV[$argvrevidx]");
        
    } 
    else
    {
        print "ERROR: usage: file $ARGV[0] doesn't exist\n";
        #close ;
        exit(0);
    }
}


#################################################
# Get the column index from the given header name
#
sub getHeaderIndex{

    my $header = shift;
    my $columnName = shift;
    my @headerRow = @{$header};
    
    for my $i (0 .. $#headerRow)
    {
        if ($headerRow[$i] eq $columnName){
            return $i;
        }
    } 
    return -1;
}

#################################################
# Check if the row contains the Headers 
#
sub checkHeaderRow{
    my $hrow = shift;
    
    my $h_counter = 0;
    #Header Column check
    my $colIndex = 0;
    foreach my $headercol (@{$hrow}) 
    {
        my @columnObjs = ("IssueKey");
        
        foreach my $columnObj ( @columnObjs ) {
            if($headercol eq $columnObj){
                $h_counter++;
            }
        }
        $colIndex++;
    }
    
    #log_msg($LOG_TYPE_INF, "New Status column index: $issueKeyColumnIndex");
    
    if($h_counter >= 1){
        foreach my $hcol (@{$hrow}){
            log_msg($LOG_TYPE_INF, "Header column: " .$hcol );
            #print $hcol.", ";
        }
        return 1;
    }
    return 0;
}



###############################################
# extractDataFromFile from Requirements file
# Return anArray of @["Summary", "Description", "SYR Summary" ]
#
sub extractDataFromFile{
    
    my $inputFileName = shift;
    my $rows = ();
    my $isdatarow = 0;
    
    log_msg($LOG_TYPE_INF, "Read Data from file ".$inputFileName);
    # Open the csv file, with ',' as separator
    my $csv = Text::CSV_XS->new( { binary => 1, sep_char => ';', eol => $/ } )
        or die "Cannot use CSV: " . Text::CSV->error_diag();
    open my $io, "<${inputFileName}" or die "${inputFileName}: $!";
    
    while ( my $row = $csv->getline($io) ) {         
        
        if($isdatarow){
            push @{$rows}, $row;                  
        }
        else{
            if( checkHeaderRow($row)){
                $headersRow  = $row;
                $isdatarow = 1;
                print "HEADER'S SCOLMNS: \n";               
                print Dumper($headersRow), length($headersRow), "\n";
            }
            else{
                    if(defined $row->[0] and $row->[0] eq "Project" and defined $row->[1]){
                        $project=$row->[1];
                    }
                    if(defined $row->[0] and $row->[0] eq "IssueType" and defined $row->[1]){
                        $issueType=$row->[1];
                    }
            }
        }
    }
    print "DATA ROWS\n";
    #print Dumper($rows), length(scalar ($rows)), "\n";
    return $rows;

}

####################################################
# Verify all data and look for possible wrong values
# Return an array with the correct values (i.e. user prevignano -> extern.prevignano or date 01.11.2014->2014-11-01)
#
sub verifyData{
    my $raws_data = shift;
    if(!$JSON_PROJECT_EDIT_META){
        $JSON_PROJECT_EDIT_META = getFieldsListMeta($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,$project,$issueType);
    }
    my $new_rows_data = ();
    
    log_msg($LOG_TYPE_INF, "Required fields Column OK");
    
    my $rowIndex = 0;
    #Verify all rows cells value
    foreach my $raw (@{$raws_data})
    {
        log_msg($LOG_TYPE_INF, "Verifying row ".$rowIndex);
        my $headerIndex = 0;
        my $newrow = ();
        foreach my $cell (@{$raw}){
            #print "CELL: $cell - Index: $headerIndex\n";
            
            if(defined $cell and $cell ne ""){
                #log_msg($LOG_TYPE_INF, " --------  Verififying cell ". $cell);
                
                if( $headersRow->[$headerIndex] eq 'IssueKey'){
                    $headerIndex++;
                    next;
                }
                
                # array values 
                my $validateValue = 0;
                $validateValue = validateValueFromField($JSON_PROJECT_EDIT_META, $issueType, $headersRow->[$headerIndex], $cell,$JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD);
                
                if (!$validateValue){
                    log_msg($LOG_TYPE_FATAL, "Value $cell for column $headersRow->[$headerIndex] is not valid");
                    #print "[ERROR] Value $cell for column $headersRow->[$headerIndex] is not valid "."\n";
                    exit (1);
                }
                if($validateValue ne ""){
                    #print "[DEBUG]         CELL:$cell - Value:$validateValue (Index: $headerIndex)\n";
                    push @{$newrow}, $validateValue;
                }
            }
            else{
                push @{$newrow}, '';
            }
            $headerIndex++;
        }
        push @{$new_rows_data}, $newrow;
        $rowIndex++;
    }
    log_msg($LOG_TYPE_INF, "Fields values OK");
    #print "[INFO] Fields values OK\n";
    return $new_rows_data;
}

###############################################################################
# Update  Tickets
# Return 
#
sub updateTickets{

    my $create_raws_data = shift;
    
    #print "\n[INFO] Start Ticket creation....\n";
    log_msg($LOG_TYPE_INF, "Start Ticket update....");
    my $req_issueNumber = (); # Will Contains [ ['GL005-1234'], ...]     
    #if(!$JSON_PROJECT_EDIT_META){
    #     $JSON_PROJECT_EDIT_META = getEditMeta($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD);
    #} 
        #print Dumper($JSON_PROJECT_EDIT_META), length(scalar($JSON_PROJECT_EDIT_META)), "\n";
    
    my $total_number_of_updated_issues = 0;
    
    foreach my $create_raw (@{$create_raws_data})
    {
    
        my $headerIndex = 0;
        my $statusvalue = 0;
        my $field_update_requests = 0;
        my $issueFields = {};
        my @attachment_array=();
        #my %newHash = ( %{$issueFields}, %{createFieldHash("Issue Type",$issueType,$JSON_PROJECT_CREATE_META,$issueType)});
        #%{$issueFields} = %newHash;
        
        log_msg($LOG_TYPE_INF, "\n\nProcessing IssueKey: " . $create_raw->[0]);
        
        foreach my $cell (@{$create_raw}){
            if(defined $cell ){
            
 #-----------------------------------------------------------------
 # enable to speed up the update of several ticket; works if the have the same state 
 # but in any case is possible to have errors because it depends on every singular ticket 
 #-----------------------------------------------------------------

                #if(!$JSON_PROJECT_EDIT_META){
                #  $JSON_PROJECT_EDIT_META = getEditMeta($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD);
                #} 
                if( $headersRow->[$headerIndex] eq 'IssueKey'){
                    $headerIndex++;
                    next;
                }
                
                if( $headersRow->[$headerIndex] eq "Attachments")
                {
                    my @values = split('\n', $cell);
                    
                    foreach my $val (@values) {
                        log_msg($LOG_TYPE_INF, "-- -- -- File to Attach:$val\n");
                        push @attachment_array, $val;
                    }
                    $headerIndex++;
                    next;
                }
                
                if( $headersRow->[$headerIndex] eq 'Description'){
                    $cell =~ s/\"/\\"/g;  # Escape quotes
                    $cell =~ s/\n/\\n/g;  # Escape newlines
                    $cell =~ s/\t/\\t/g;  # Escape tabs
                    #print "\nKey:". $create_raw->[0] . "\ndescription:" .  $cell . "\n";
                }
                
                log_msg($LOG_TYPE_INF, "\nProcessing IssueKey: " . $create_raw->[0] . ", field: " . $headersRow->[$headerIndex]);
                updateIssue($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,$create_raw->[0],[$headersRow->[$headerIndex], $cell],"set",0);
                $field_update_requests++;
                
            }
            $headerIndex++;
        }
        foreach my $attachval (@attachment_array)
        {
            log_msg($LOG_TYPE_INF, "Add Attachments: ");
            if( $attachval =~ /^https/){
                #log_msg($LOG_TYPE_INF, "  --  --> Add file:".$attachval);
                my $svnattachfile = svnDownloadFiles($attachval, $create_raw->[0]);
                addAttachmentFile($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,$create_raw->[0],$svnattachfile);
            }
            else{
                # log_msg($LOG_TYPE_INF, "  --  --> Add file:".$attachval);
                addAttachmentFile($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,$create_raw->[0],$attachval);
            }
        }
        #execute transition
#        if( $statusHeaderColIndex >= 0 and $statusvalue){
 #               #print "NEW STATUS : $statusvalue \n";
  #              executeTransitions($statusvalue ,$ticketKey);
   #     }
        
        # If at least a field was updated, count the issue as updated. Please note that "field updated" here actually
        # means that the request was sent, but maybe the field already had that value and therefore no real update was
        # made.
        if ($field_update_requests > 0) {
            $total_number_of_updated_issues++;
        }
    }
    #print Dumper($req_issueNumber), length(scalar($req_issueNumber)), "\n";
    log_msg($LOG_TYPE_INF, "\nTotal number of updated issues: " . $total_number_of_updated_issues);
    return $req_issueNumber;
}

sub svnDownloadFiles{
    
    my $fileurldata = shift;
    my $issuekey = shift;
    
    
    if( defined $fileurldata and $fileurldata ne "")
    {
        
        #  log_msg($LOG_TYPE_INF, "Downloading files from SVN ".$fileurldata."\n");
        my @values = split('\n', $fileurldata);
        foreach my $val (@values) {
            if( $val ne ""){
                $val =~ /.*\/(.*)/;
                my $filename =$1;
                
                if ( ! -d "QA_CheckLsistTmp/Rev-$issuekey" ){
                    mkdir "QA_CheckLsistTmp/Rev-$issuekey";
                }

        #       log_msg($LOG_TYPE_INF, "   --> $val");
                svnCheckoutFile($val, "QA_CheckLsistTmp/Rev-$issuekey");
                my ($filedwnlname) = $val =~ /.*\/(.*)$/;
                return $cwd."/QA_CheckLsistTmp/Rev-$issuekey/".$filedwnlname;
            }
        }
    }
}

sub svnCheckoutFile{
        my $fileurl = shift;
        my $copath = shift;
        
        log_msg($LOG_TYPE_INF, "-------  Checkout".$fileurl." to " . $copath);
        system( qq{ svn export $fileurl $copath });
}


###########################################################################################
# MAIN
###########################################################################################

usage();
#print "Please enter Jira user name and password\n";
if ($JIRA_USER eq '') {
    $JIRA_USER = userPrompt();
}

if ($JIRA_PASSWD eq '') {
    $JIRA_PASSWD = passwordPrompt();
}

# print "\nUsername: $JIRA_USER\n";
# print "Password: $JIRA_PASSWD\n";

($cwd) = abs_path($0) =~ /(^.*)\/.*$/;
log_msg($LOG_TYPE_INF, "Running script path: ".$cwd);

if ( -d "QA_CheckLsistTmp" ){
    system(qq{ rm -rf QA_CheckLsistTmp });
    mkdir "QA_CheckLsistTmp";
}

my $raws_data = extractDataFromFile($CsvInputFileName); 
# my $verified_rows_data = verifyData($raws_data);
if ($OnlyVerify == 1)
{
    exit(1);
}
#print "All verified\n";
#exit(0);
updateTickets($raws_data);


log_msg($LOG_TYPE_INF, "EXIT");
#print "[INFO] Exit program";

exit(0);

__END__

