#! perl

#
# JIRA - Script for tickets creation from a CSV file
#
# This script read, validate and create tickets from a CSV file (with separtor ";" for excel compatibility);
# the CSV file is in the format:
#
#
#Project;GL005
#IssueType;Component Release
#Summary;Security Level;Assignee;Component/s;Due Date;PIC;Component Tag Name;Subproject relations
#Radio_AMFM_CW;gl005_onsite;Schetler;AMFM;17.08.2015;Schetler, Denis;AMFM_044.001.000;SVT01,HON03,PAE04,CRY01,FOD01
#GRA_AMFMHD_CW;gl005_Toyota;K.Sriram;GRA_AMFMHD;17.08.2015;K.Sriram;GRA_AMFMHD_020.001.000;TOY01
#
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
use PAISEU::JiraRestCreationUtils;
use PAISEU::LogMessage;
use PAISEU::StateTransitions;
use Text::CSV_XS;
use Pod::Usage;

#my $JIRA_SERVER  = "http://bugs.lng.pce.cz.pan.eu:8081";
my $JIRA_SERVER = "http://gelijiratestneo.lng.pce.cz.pan.eu:8085";
my $JIRA_USER   = ""  ; # If this variable is empty, you will be prompted for it when you start the script
my $JIRA_PASSWD = ""  ; # If this variable is empty, you will be prompted for it when you start the script
$JIRA_USER   = "extern.lorenzo";
$JIRA_PASSWD = "Qwertzuiop789m";
my $LABEL_STR = "";

my $JSON_PROJECT_CREATE_META = 0;

#Input xls file name
my $CsvInputFileName;

#Global values for all tickets
my $project               = "";
my $headersRow            = ();
my $issueType             = "";
my $statusHeaderColIndex  = -1;
my $CommentHeaderColIndex = -1;
my $help;
my $CW = "";
my $release = 0;

#QA_TASK_TICKET
my $matchingIntegrationQATicket = ();

################################################################################
################################################################################
#                                 Const
################################################################################
################################################################################
use constant {

	#traceLog constant
	_NO_STATE              => 0,
	_INTEGRATION           => 1,
	_SHORT_TERM            => 2,
	_QA_TICKET_INTEGRATION => 3,
	_QA_TICKET_SHORT_TERM  => 4,
	_LINKING               => 5,
};
my $state = _NO_STATE;
my $state_IO = "";

# Get command line options
sub get_options {
	# Define the format for each argument and save it to a variable (or array)
	my $result = Getopt::Long::GetOptions(
		'help|h'              => \$help,
		'calendarWeek|cw=s' => \$CW,
		'state|st=s' => \$state_IO,
		'release|r'  => \$release,
		'inputFile|i=s'      => \$CsvInputFileName,
	  )
	  or Pod::Usage::pod2usage(
		-sections => 'USAGE',
		-exitval  => 1,
		-verbose  => 99
	  );

	if ($help) {
		Pod::Usage::pod2usage( -exitval => 0, -verbose => 2, -noperldoc => 1 );
	}
	
	#check the status
	if( $state_IO == _INTEGRATION ||
		$state_IO == _SHORT_TERM  ||
		$state_IO == _QA_TICKET_INTEGRATION  ||
		$state_IO == _QA_TICKET_SHORT_TERM  ||
		$state_IO == _LINKING
	){
		log_msg( $LOG_TYPE_INF, "status has been checked " . $state_IO);
		$state = $state_IO;
	}else{
		log_msg( $LOG_TYPE_INF, "status wrong " . $state_IO);
		exit(0);
	}
	
	if ( -e $CsvInputFileName ) {
		print "[INFO] Input file: $CsvInputFileName\n";
	}else {
		print "ERROR: usage: file $CsvInputFileName doesn't exist\n";
		#close ;
		exit(0);
	}

	return;
}


#################################################
# Get the column index from the given header name
#
sub getHeaderIndex {

	my $header     = shift;
	my $columnName = shift;
	my @headerRow  = @{$header};

	for my $i ( 0 .. $#headerRow ) {
		if ( $headerRow[$i] eq $columnName ) {

#print "[INFO] getHeaderIndex: Column Index for \"".$columnName. "\":".$i. "\n";
			return $i;
		}
	}
	return -1;
}

#################################################
# Check if the row contains the Headers.
# There must be at least 4 of the fields listed in @columnObjs
#
sub checkHeaderRow {
	my $hrow = shift;

	my $h_counter = 0;

	#Header Column check
	my $colIndex = 0;
	foreach my $headercol ( @{$hrow} ) {
		my @columnObjs = ("Summary");

		foreach my $columnObj (@columnObjs) {
			if ( $headercol eq $columnObj ) {
				$h_counter++;
			}
		}
		if ( $headercol eq "Status" ) {
			$statusHeaderColIndex = $colIndex;
		}
		if ( $headercol eq "Comment" ) {
			$CommentHeaderColIndex = $colIndex;
		}
		$colIndex++;
	}

	#log_msg($LOG_TYPE_INF, "New Status column index: $statusHeaderColIndex");
	#log_msg($LOG_TYPE_INF, "Comment column index: $CommentHeaderColIndex");

	if ( $h_counter >= 1 ) {
		foreach my $hcol ( @{$hrow} ) {
			log_msg( $LOG_TYPE_INF, "Header column: " . $hcol );

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
sub extractDataFromFile {

	my $inputFileName = shift;
	my $rows          = ();
	my $isdatarow     = 0;

# Make sure the input file is valid (e.g. it's a file and not a directory, it's readable, it's non-empty)
	if ( !-f $inputFileName ) {
		die "File $inputFileName not found\n";
	}
	if ( !-r $inputFileName ) {
		die "File $inputFileName isn't readable\n";
	}
	if ( -z $inputFileName ) {
		die "File $inputFileName is empty\n";
	}

	log_msg( $LOG_TYPE_INF, "Read Data from file " . $inputFileName );

	# Open the csv file, with ',' as separator
	my $csv = Text::CSV_XS->new( { binary => 1, sep_char => ';', eol => $/ } )
	  or die "Cannot use CSV: " . Text::CSV->error_diag();
	open my $io, "<${inputFileName}" or die "${inputFileName}: $!";

	while ( my $row = $csv->getline($io) ) {

		#print Dumper($row), length(scalar ($row)), "\n";
		if ($isdatarow) {
			push @{$rows}, $row;
		}
		else {
			if ( checkHeaderRow($row) ) {
				$headersRow = $row;
				$isdatarow  = 1;

				#print "HEADER'S SCOLMNS: \n";
				#print Dumper($headersRow), length($headersRow), "\n";
			}
			else {
				if (    defined $row->[0]
					and $row->[0] eq "Project"
					and defined $row->[1] )
				{
					$project = $row->[1];
				}
				if (    defined $row->[0]
					and $row->[0] eq "IssueType"
					and defined $row->[1] )
				{
					$issueType = $row->[1];
				}
			}
		}
	}

	#print "DATA ROWS\n";
	#print Dumper(${${$rows}[0]}[0]);
	#print Dumper($rows), length(scalar ($rows)), "\n";
	#print $rows;
	return $rows;

}

####################################################
# Verify all data and look for possible wrong values
# Return an array with the correct values (i.e. user prevignano -> extern.prevignano or date 01.11.2014->2014-11-01)
#
sub verifyData {
	my $raws_data = shift;
	if ( !$JSON_PROJECT_CREATE_META ) {
		$JSON_PROJECT_CREATE_META =
		  getCreateMeta( $JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD, $project,
			$issueType );
	}

#print Dumper($JSON_PROJECT_CREATE_META), length(scalar($JSON_PROJECT_CREATE_META)), "\n";
	my $new_rows_data = ();

	#Check mandatory fields
	my %requiredFields =
	  getCreationRequiredFieldsFromIssuType( $JSON_PROJECT_CREATE_META,
		$issueType );

	for my $rfield ( keys %requiredFields ) {

		# Don't check 'Project' and 'Issue Type' because not in the header's column but in the first 2 rows
		# Don'T check "Status" column, it'S only for transitions to the new status
		if (   $rfield eq "Project"
			or $rfield eq "Issue Type"
			or $rfield eq "Status" )
		{
			next;
		}
		my $ffound = 0;
		foreach my $header ( @{$headersRow} ) {
			if ( lc $rfield eq lc $header ) {
				$ffound = 1;
				last;
			}
		}
		if ( !$ffound ) {
			log_msg( $LOG_TYPE_FATAL,
				    "Field " . $rfield
				  . " is required for $issueType but it's not present on creation csv document file"
			);
			exit(1);
		}
	}
	log_msg( $LOG_TYPE_INF, "Required fields Column OK" );

	my $rowIndex = 0;

	#Verify all rows cells value
	foreach my $raw ( @{$raws_data} ) {
		my @labels_array = ();
		log_msg( $LOG_TYPE_INF, "Verifying row " . $rowIndex );
		my $headerIndex = 0;
		my $newrow      = ();
		foreach my $cell ( @{$raw} ) {
			print "CELL: $cell - Index: $headerIndex\n";

			if ( $headerIndex == $statusHeaderColIndex ) {
				push @{$newrow}, $cell;
				$headerIndex++;
				next;
			}

			if ( $headerIndex == $CommentHeaderColIndex ) {
				push @{$newrow}, $cell;
				$headerIndex++;
				next;
			}

			if ( defined $cell and $cell ne "" ) {

				#log_msg($LOG_TYPE_INF, " --------  Verifying cell ". $cell);
				# array values

				if ( $headersRow->[$headerIndex] eq "Subproject relations" ) {
					$cell =~ s/,/\n/g;
				}

				my $validateValue = 0;
				$validateValue =
				  PAISEU::JiraRestCreationUtils::validateValueFromField(
					$JSON_PROJECT_CREATE_META, $issueType,
					$headersRow->[$headerIndex],
					$cell, $JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD );

				if ( !$validateValue ) {
					log_msg( $LOG_TYPE_FATAL,"Value $cell for column $headersRow->[$headerIndex] is not valid"
					);

				#print "[ERROR] Value $cell for column $headersRow->[$headerIndex] is not valid "."\n";
					exit(1);
				}
				if ( $validateValue ne "" ) {

				#print "[DEBUG]         CELL:$cell - Value:$validateValue (Index: $headerIndex)\n";
					push @{$newrow}, $validateValue;
				}
			}
			else {
				push @{$newrow}, '';
			}
			$headerIndex++;
		}
		push @{$new_rows_data}, $newrow;
		$rowIndex++;
	}
	log_msg( $LOG_TYPE_INF, "Fields values OK" );

	#print "[INFO] Fields values OK\n";
	return $new_rows_data;
}

sub removeTicketTag{
	my $str = shift;
	my $mode = shift;
	chomp($str);
	if( $str =~ /\#(GL005\-.+)\#/ ){
		$str =~ s/\#(GL005\-.+)\#//;
		log_msg( $LOG_TYPE_INF, "Integtation Ticket: $1" );
		log_msg( $LOG_TYPE_INF, "QA Ticket: $str" );
		return $1 if ($mode == 2);
		return $str if ($mode == 1);
	}
	return 0;
}

###############################################################################
#
sub createTickets {

	my $create_raws_data = shift;
	my $CoulumsMap = shift;

	print "\n[INFO] Start Ticket creation....\n";
	log_msg( $LOG_TYPE_INF, "Start Ticket creation...." );
	my $req_issueNumber = ();    # Will Contains [ ['GL005-1234'], ...]
	if ( !$JSON_PROJECT_CREATE_META ) {
		$JSON_PROJECT_CREATE_META =
		  getCreateMeta( $JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD, $project,
			$issueType );
	}

	#print Dumper($create_raws_data), length(scalar($create_raws_data)), "\n";
	foreach my $create_raw ( @{$create_raws_data} ) {

		#Ticket creation
		my $integrationTicket=0;
		my $headerIndex  = 0;
		my $statusvalue  = 0;
		my $commentValue = 0;
		my $issueFields  =  createFieldHash( "Project", $project, $JSON_PROJECT_CREATE_META, $issueType );

		my %newHash =  ( %{$issueFields}, %{ { 'issuetype' => { 'name' => $issueType } } } );
		%{$issueFields} = %newHash;

		#nur für das Taskticket
		if($issueType eq "Task"){
			my $newSummary = removeTicketTag(${$create_raw}[0], 1);
			$integrationTicket = removeTicketTag(${$create_raw}[0], 2);
			print "New Summary=" . $newSummary, "\n";
			print "Integration Ticket=" . $integrationTicket, "\n";
			${$create_raw}[0] = $newSummary;
		}
		
		foreach my $cell ( @{$create_raw} ) {
			if ( defined $cell and $cell ne "" ) {
				if ( $headerIndex == $statusHeaderColIndex ) {
					$statusvalue = $cell;
					log_msg( $LOG_TYPE_INF,
						"New Status Transition found: " . $statusvalue );

					#print "NEW STATUS : $cell  $headerIndex\n";
					$headerIndex++;
					next;
				}

				if ( $headerIndex == $CommentHeaderColIndex ) {
					$commentValue = $cell;

				   #log_msg($LOG_TYPE_INF, "New Comment found: ".$commentValue);
				   #print "NEW COMMENT : $cell  $headerIndex\n";
					$headerIndex++;
					next;
				}
				print "Create Field Hash: $headersRow->[$headerIndex]\n";
				%newHash = (
					%{$issueFields},
					%{
						createFieldHash(
							$headersRow->[$headerIndex], $cell,
							$JSON_PROJECT_CREATE_META,   $issueType
						)
					  }
				);
				%{$issueFields} = %newHash;
			}
			$headerIndex++;
		}

		my $issuetag     = { 'fields' => $issueFields };
		my $encoded_json = encode_json($issuetag);

		#log_msg($LOG_TYPE_INF, "ENCODED JSON:" . $encoded_json);
		#print "ENCODED JSON: " . $encoded_json . "\n";
		my $ticketKey = createIssue( $JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD, $encoded_json );
		push(@{$matchingIntegrationQATicket}, "$integrationTicket;$ticketKey");
		
		log_msg( $LOG_TYPE_INF, "Created ticket " . $ticketKey );

		#print "[INFO] Created ticket $ticketKey \n";
		
		#Summary;Security Level;Priority;Assignee;Due Date;Planned Start;PIC;Sub Project;Labels;Description
		my $summaryIndex = ${$CoulumsMap}{'Summary'};
		my $securityLevel = ${$CoulumsMap}{'Security Level'};
		my $priority = ${$CoulumsMap}{'Priority'};
		my $Assignee = ${$CoulumsMap}{'Assignee'};
		my $dueDate = ${$CoulumsMap}{'Due Date'};
		my $PlannedDate = ${$CoulumsMap}{'Planned Start'};
		my $PIC = ${$CoulumsMap}{'PIC'};
		my $subProject = ${$CoulumsMap}{'Sub Project'};
		
		push @{$req_issueNumber}, [
										$ticketKey,
								   		${$create_raw}[$summaryIndex],
								   		${$create_raw}[$securityLevel],
								   		${$create_raw}[$priority],
								   		${$create_raw}[$Assignee],
								   		${$create_raw}[$dueDate],
								   		${$create_raw}[$PlannedDate],
								   		${$create_raw}[$PIC],
								   		${$create_raw}[$subProject]
								  ];
		
		#execute transition
		if ( $statusHeaderColIndex >= 0 and $statusvalue ) {

			#print "NEW STATUS : $statusvalue \n";
			executeTransitions(
				$JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD, $statusvalue,
				$ticketKey,   $project,   $issueType
			);
		}

		#Add comment to the ticket
		if ( $CommentHeaderColIndex >= 0 and $commentValue ) {

			#print "NEW COMMENT : $commentValue \n";
			print "Call addComment with argument:\n$commentValue\n";
			addComment(
				$JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,
				$ticketKey,   $commentValue
			);
		}

	}

	#print Dumper($req_issueNumber), length(scalar($req_issueNumber)), "\n";
	return $req_issueNumber;
}

sub addCWToTheInput {
	my $raws_data = shift;
	foreach my $item ( @{$raws_data} ) {
		${$item}[0] = ${$item}[0] . $CW;
		print "@{$item}\n";
	}
}

sub addDataToIntegrationTicket{
	my $dueDateColPos = -1;
	my $raws_data = shift;
	my $i=0;
	
	foreach my $col (@{$headersRow}){
		$dueDateColPos = $i if($col eq 'Due Date'); 
		$i++;
	}
	
	if($dueDateColPos == -1){
		log_msg( $LOG_TYPE_INF, "No due date available, please check the config file!!!" );
		exit(0);
	}
	
	foreach my $item ( @{$raws_data} ) {
		${$item}[0] = ${$item}[$dueDateColPos] . ' ' . ${$item}[0];
		print "@{$item}\n";
	}
}

sub createCVSReport {
	my $reqIssues = shift;

	my $str = 'ticket;summary' . "\n";
	foreach my $ticket (@{$reqIssues}){
		chomp(${$ticket}[0]);
		chomp(${$ticket}[1]);
		chomp(${$ticket}[2]);
		chomp(${$ticket}[3]);
		chomp(${$ticket}[4]);
		chomp(${$ticket}[5]);
		chomp(${$ticket}[6]);
		chomp(${$ticket}[7]);
		chomp(${$ticket}[8]);
		$str = $str . ${$ticket}[0] . ';' . ${$ticket}[1] . ';' . ${$ticket}[2] . ';' . ${$ticket}[3] .  ';' . ${$ticket}[4] .  ';' . ${$ticket}[5] .  ';' . ${$ticket}[6] .  ';' . ${$ticket}[7] . ';' . ${$ticket}[7] . "\n";
	}
	
	#print $str; 
	
	my $filename = 'report.lol';
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	print $fh $str;
	close $fh;
	log_msg( $LOG_TYPE_INF, "Report has been created!" );
	
}

sub getColumIndexFromHeadersRow{
	my $hr = shift;
	my $fieldHash;
	my $i=0;
	foreach my $field (@{$hr}){
		${$fieldHash}{$field} = $i++;
	}
	return $fieldHash;
}

#
# questa funzione é chiamata all'interno di createQATaskTicket
# Usando la struttura $reqIssues é possibile modificare/rimuovere o 
# aggiungere dati.
#
sub customizeQATaskTicketData{
	my $reqIssues = shift;

}

sub createQATaskTicket{
	my $reqIssues = shift;
	
	customizeQATaskTicketData($reqIssues);
	
	my $str = 'Project;GL005' . "\n" . 'IssueType;Task' . "\n";
	
	#print the header row
	$str = $str . 'Summary;Security Level;Priority;Assignee;Due Date;Planned Start;PIC;Component/s;Sub Project;Description' . "\n";
	
	#print all data
	foreach my $integration (@{$reqIssues}){
		#print @{$integration}[1] . "\n";
		
		#understand if it's a release.
		my @summarySplitted = split(/ /, @{$integration}[1]);
		my $buildName = $summarySplitted[1];
		#print substr($buildName, length($buildName)-3, 1) . "<----------\n";
		if(substr($buildName, length($buildName)-3, 1) eq 'R'){
		
			log_msg( $LOG_TYPE_INF, "Creating QA task ticket for $buildName" );
			log_msg( $LOG_TYPE_INF, '   [' . @{$integration}[8] . '] CW' . $CW . ' Release review meeting minutes' );
			log_msg( $LOG_TYPE_INF, '   QA_' . @{$integration}[8] . '_CW_' . $CW );
			
			my $ticketTag = '#' . @{$integration}[0] . '#';
			
			#per alcuni ticket hon03/toy01/pae04 il titolare del ticket non é vincenzo
			my $assigneeQATicket = "Colubriale";
			my $projectGL005 = @{$integration}[8];
			chomp($projectGL005);
			$assigneeQATicket = 'Vaidhiyanathan, Shyamala' if($projectGL005 eq 'PAE04' || $projectGL005 eq 'TOY01' || $projectGL005 eq 'HON03');
			#fine patch
			
			$str = $str . $ticketTag . 'QA_' . @{$integration}[8] . '_CW_' . $CW . ';' . 
			  		  @{$integration}[2] . ';' . 
			  		  "Major" . ';' . 
			          $assigneeQATicket . ';' . 
			          @{$integration}[5] . ';' .
			          @{$integration}[5] . ';' .
			          "gianfermi" . ';' .
			          '-null-' . ';' .
			          @{$integration}[8] . ';' .
			          "" . "\n";
			  
			$str = $str . $ticketTag . '[' . @{$integration}[8] . '] CW' . $CW . ' Release review meeting minutes' . ';' . 
			          @{$integration}[2] . ';' . 
			          "Major" . ';' . 
			          @{$integration}[7] . ';' . 
			          @{$integration}[5] . ';' .
			          @{$integration}[5] . ';' .
			          @{$integration}[7] . ';' .
			          '-null-' . ';' .
			          @{$integration}[8] . ';' .
			          "\"Agenda:\n1) Product level Q-checks deviations review\n2) Short and Functional test results review\"" . "\n";
		}
	}
	#print $str;
	my $filename = 'CW' . $CW . '_QA_tickets.csv';
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	print $fh $str;
	close $fh;
	log_msg( $LOG_TYPE_INF, 'CW' . $CW . ' QA_tickets.csv created' );
}

sub createQATaskTicketSP{
	my $reqIssues = shift;
	my $str = 'Project;GL005' . "\n" . 'IssueType;Task' . "\n";
	
	#print the header row
	$str = $str . 'Summary;Security Level;Priority;Assignee;Due Date;Planned Start;PIC;Component/s;Sub Project;Labels;Description' . "\n";
	
	#print all data
	foreach my $SP_integration (@{$reqIssues}){
		#print @{$integration}[1] . "\n";
		
		#understand if it's a release.
		my $summarySP = @{$SP_integration}[1];
		if($release == 1){
		
			log_msg( $LOG_TYPE_INF, "Creating QA task ticket for $summarySP" );
			log_msg( $LOG_TYPE_INF, '   [' . @{$SP_integration}[8] . '] CW' . $CW . ' Integration Opening/Follow up Meeting' );
			
			my $ticketTag = '#' . @{$SP_integration}[0] . '#';
			
			$str = $str . $ticketTag . '   [' . @{$SP_integration}[8] . '] CW' . $CW . ' Integration Opening/Follow up Meeting' . ';' . 
			  		  @{$SP_integration}[2] . ';' . 
			  		  "Major" . ';' . 
			          "Laghigna" . ';' . 
			          @{$SP_integration}[6] . ';' .
			          @{$SP_integration}[6] . ';' .
			          "Laghigna" . ';' .
			          '-null-' . ';' .
			          @{$SP_integration}[8] . ';' .
					  'Integration_Meeting_' . @{$SP_integration}[8] . ';' .
			          '"Agenda:'."\n".'- Pre-integration and Integration activities review'."\n".
			          				 'The activities are related to the following build:' . "\n\n".
			          				 '- Opening:'."\n".
			          				 'Participants'."\n".
			          				 'Date: tt/mm/jjjj; Time: hh:mm - hh:mm'."\n\n".
			          				 'The following Components reported deviations:' ."\n\n".
			          				 '- Follow up:'."\n".
			          				 'Participants'."\n".
			          				 'Date: tt/mm/jjjj; Time: hh:mm - hh:mm'."\n".
			          				 '- Deviations at product level are reported within the integration ticket above mentioned.'."\n".
			          				 '- Deviations reported by test team will be added to the deviation list.'."\n\n".
			          				 '- Reference documents:"'."\n";			 
		}
	}
	#print $str;
	my $filename = 'CW' . $CW . '_QA_tickets.csv';
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	print $fh $str;
	close $fh;
	log_msg( $LOG_TYPE_INF, 'CW' . $CW . ' QA_tickets.csv created' );
}

sub createCSVLinkinQAIntegration{
	my $arr = shift;
	my $str = "";
	foreach my $item (@{$arr}){
		my @tmp = split (/;/, $item);
		$str = $str . $tmp[0] . ';'  . $tmp[1] . "\n";
	}
	
	my $filename = 'CW' . $CW . '_QA_Linkt_to_integration_tickets.csv';
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	print $fh $str;
	close $fh;
	log_msg( $LOG_TYPE_INF, 'CW' . $CW . ' QA_tickets.csv created' );
}


###########################################################################################
# MAIN
###########################################################################################

get_options();

if ( $JIRA_USER eq '' ) {
	$JIRA_USER = userPrompt();
}

if ( $JIRA_PASSWD eq '' ) {
	$JIRA_PASSWD = passwordPrompt();
}

my $raws_data = extractDataFromFile($CsvInputFileName);
my $CoulumsMap = getColumIndexFromHeadersRow($headersRow);

addCWToTheInput($raws_data)            if ($issueType eq 'SP_Integration');
addDataToIntegrationTicket($raws_data) if ($issueType eq 'Integration');


if ( !$JSON_PROJECT_CREATE_META ) {
	$JSON_PROJECT_CREATE_META = getCreateMeta( $JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD, $project, $issueType );

	#print Dumper($JSON_PROJECT_CREATE_META), length(scalar($JSON_PROJECT_CREATE_META)), "\n";
	my $verified_rows_data = verifyData($raws_data);
	print Dumper($verified_rows_data), length( scalar($verified_rows_data) ),
	  "\n";
	print "All verified\n";
	
	my $i=0;
	foreach my $item (@{$verified_rows_data}){
		$i++;
	}
	print "Trying to create $i $issueType ticket/s\n";
	
	my $reqIssues = createTickets($verified_rows_data, $CoulumsMap);
	#print Dumper($reqIssues), length( scalar($reqIssues) ), "\n";
	
	createCVSReport($reqIssues) if ($issueType eq 'Integration');
	createQATaskTicket($reqIssues) if($issueType eq "Integration");
	createCSVLinkinQAIntegration($matchingIntegrationQATicket) if ($issueType eq "Task");
	createQATaskTicketSP($reqIssues) if ($issueType eq 'SP_Integration');
	#print Dumper(@{$matchingIntegrationQATicket}) if ($issueType eq "Task");
	
}



log_msg( $LOG_TYPE_INF, "EXIT" );



exit(0);

__END__

=head1 DESCRIPTION

This script create the libPasa from the libs released by PASA and
update all header file.

=head1 USAGE

perl CreateTickets.pl  -i cvsticketsfile.csv -cw XY_WZ

 Options:
	
=head1 OUTPUT

=head1 EXIT STATUS

The exit value is always 0.

=head1 AUTHOR

Lorenzo Cozza <Cozza Lorenzo/EXT/EU/Panasonic>
based on the greit work of Prevignano Massimo (Jira admin)

=cut
