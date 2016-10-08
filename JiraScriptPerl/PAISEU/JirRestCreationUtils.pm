package PAISEU::JiraRestCreationUtils;
# JiraRestCreationUtils.pm
#
# Author: extern.prevignano
#
# Date: 2014-11-21
#
# Description:
# Utility library to interact with Jira through REST API
# Utilities for Issue CREATION 
# List of function:
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
#use Switch;

use Exporter;
use base 'Exporter';

our @EXPORT = qw (
   addLabel
   getCreateMeta
   getCreateMeta_ProjectsAndIssueTypes
   getCreationRequiredFieldsFromIssuType
   getCreationFieldsFromIssuType
   getFieldObjectFromName
   getFieldObjectFromKey
   checkAllowedValue
   checkUser
   validateValueFromField   
   checkAndCreateFieldHash
   createKeyStringFieldObject
   getKeyFromName_CreateMeta
   createFieldHash
   createIssue
   createIssueLink
   executeIssueTransition
   getIssueData
);




#######################################################################
#     Creation's functions
#######################################################################
#
# Return the create meta JSON decoded object for a specific project
#
sub getCreateMeta{
   my $JIRA_SERVER = shift;
   my $JIRA_USER   = shift;
   my $JIRA_PASSWD = shift;
   my $projectKeys = shift;
   my $issuetypeNames = shift;
   
   my $issuetypesStr = "";
   
   if ($projectKeys eq "") {
      print "[ERROR] No prject specified\n";
      exit(1);
   }
   if ($issuetypeNames ne "") {
     $issuetypesStr = "&issuetypeNames=".$issuetypeNames;
   }
   my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/createmeta?projectKeys=".$projectKeys.$issuetypesStr."&"."expand=projects.issuetypes.fields.assignee";
   print "[INFO] REST URL:" . $jiraServerRest."\n";
   my $ua = LWP::UserAgent->new; 
   $ua->cookie_jar( {} );
	
   my $req = HTTP::Request->new( GET => "$jiraServerRest");
   $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );

   my $jsonreq		= $ua->request($req);
   if (!$jsonreq->is_success) {		
       print  "[ERROR] Could not get data via http: " . $jsonreq->content . "\n";
       close ;
       exit(0);
   }
   print  "[INFO] Create Meta DATA downloaded\n";
   my $jsonstr			= $jsonreq->content;
   my $decoded_json = decode_json($jsonstr);
   
   #print Dumper($decoded_json), length($decoded_json), "\n";
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      print "[INFO] PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
	      print "[INFO] ISSUETYPE: ".$issuet->{"name"} . "\n";
	  }
   }
   print "\n";
   return $decoded_json;    
}

################################################################################
#
# Return the create meta JSON decoded object for projects and their issue types, 
# without issue field expansion (only list of projects and issue types
#
sub getCreateMeta_ProjectsAndIssueTypes{
   my $JIRA_SERVER = shift;
   my $JIRA_USER   = shift;
   my $JIRA_PASSWD = shift;
      
   my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/createmeta";
   print "[INFO] REST URL:" . $jiraServerRest."\n";
   my $ua = LWP::UserAgent->new; 
   $ua->cookie_jar( {} );
	
   my $req = HTTP::Request->new( GET => "$jiraServerRest");
   $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );

   my $jsonreq		= $ua->request($req);
   if (!$jsonreq->is_success) {		
       print  "[ERROR] Could not get data via http: " . $jsonreq->content . "\n";
       close ;
       exit(0);
   }
   print  "[INFO] Create Meta DATA downloaded\n";
   my $jsonstr			= $jsonreq->content;
   my $decoded_json = decode_json($jsonstr);
   
   #print Dumper($decoded_json), length($decoded_json), "\n";
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      print "[INFO] getCreateMetaProjectsAndIssueTypes-> PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
	      print "[INFO] getCreateMetaProjectsAndIssueTypes-> ISSUETYPE: ".$issuet->{"name"} . "\n";
	  }
   }
   print "\n";
   return $decoded_json;
     
}


#########################################################################################
# This function return all Mandatory/Required fields (from CreateMeta) on creation phase 
# from an issue type.
# Return an HASH {'key', 'value'} with the following format { 'Field Name' , 'FieldId'}
# for ex {'Due Date','duedate'}, {'Sub Project','customfield_13680'}, 
# TODO For only 1 project!!!!!!!!!!!!!!!!!!!!!!
sub getCreationRequiredFieldsFromIssuType {
   my $decoded_json = shift;
   my $issueType = shift;
   my %requiredField = ();
   print "[INFO] Creation Requred Fields for IssueType $issueType\n";
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      #print "[INFO] PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
	      #print "[INFO] ISSUETYPE: ".$issuet->{"name"} . "\n";
		  if($issuet->{"name"} eq $issueType ){		     
			 my %fields = %{$issuet->{'fields'}};
			 
             for my $field (keys %fields)
             {
                #print "[INFO] Field: \t".$key." \t- ".$fields{$field}->{'name'}." \t - ". $fields{$field}->{'required'}  ."\n";
				if( $fields{$field}->{'required'} eq '1' ){
				  $requiredField {$fields{$field}->{'name'}} = $field;
				}
             }
		  }
	  }
   }
   return %requiredField;
}

###############################################################################################
# This function return all fields available on creation (from CreateMeta data) of an issue type
# Return an HASH {'key', 'value'} with the following format { 'Field Name' , 'FieldId'}
# for ex {'Due Date','duedate'}, {'Sub Project','customfield_13680'}, 
#
sub getCreationFieldsFromIssuType {
   my $decoded_json = shift;
   my $issueType = shift;
   my %creationFields = ();
   print "[INFO] Creation Fields for Issue Type $issueType\n";
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      #print "[INFO] PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
	      #print "[INFO] ISSUETYPE: ".$issuet->{"name"} . "\n";
		  if($issuet->{"name"} eq $issueType ){		     
			 my %fields = %{$issuet->{'fields'}};
			 
             for my $key (keys %fields)
             {
                #print "[INFO] Field: \t".$key." \t- ".$fields{$key}->{'name'}." \t - ". $fields{$key}->{'required'}  ."\n";
				$creationFields {$fields{$key}->{'name'}} = $key;
             }
		  }
	  }
   }
   return %creationFields;
}
#########################################################################
# This function look for the field object of the specified issue type and 
# field NAME (customfield_xxxx) in the global JSON CreateMeta data
# Return the field Object from decoded JSON data
sub getFieldObjectFromName{
   my $decoded_json = shift;
   my $issueType = shift;
   my $fieldName = shift;
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      #print "[INFO] getFieldObjectFromName->PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
	      
		  if($issuet->{"name"} eq $issueType ){		     
			 my %fields = %{$issuet->{'fields'}};
			 #print "[INFO] getFieldObjectFromName->ISSUETYPE: ".$issuet->{"name"} . "\n"; 
             for my $field (keys %fields)
             {
			    if(lc  $fields{$field}->{'name'} eq lc $fieldName){
				    #print "[INFO] getFieldObjectFromName->FIELD NAME: ".$fields{$field} . "\n"; 
				    return $fields{$field};
                }				
             }
		  }
	  }
   }
   return 0;
}

#############################################################
# Look for the field object of the specified issue type and 
# field KEY (customfield_xxxx) in the global JSON CreateMeta data
sub getFieldObjectFromKey{
   my $decoded_json = shift;
   my $issueType = shift;
   my $keyName = shift;
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      print "[INFO] getFieldObjectFromKey->PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
		  if($issuet->{"name"} eq $issueType ){		     
			 my %fields = %{$issuet->{'fields'}};
			 print "[INFO] getFieldObjectFromKey->ISSUETYPE: ".$issuet->{"name"} . "\n";
             for my $field (keys %fields)
             {
			    if(lc $field eq lc $keyName){
				    print "[INFO] getFieldObjectFromKey->FIELD KEY: ".$fields{$field} . "\n"; 
				    return $fields{$field};
                }				
             }
		  }
	  }
   }
   print "[INFO] getFieldObjectFromKey->Cannot find field \"$keyName\" for $issueType issuetype \n";
   return 0;
}

#########################################################################
# This function look for the field object of the specified issue type and 
# field NAME (customfield_xxxx) in the global JSON CreateMeta data
# Return the field Object from decoded JSON data
sub getKeyFromName_CreateMeta{
   my $decoded_json = shift;
   my $issueType = shift;
   my $fieldName = shift;
   
   my @prjs = @{ $decoded_json->{'projects'} };
   foreach my $project ( @prjs ) {
      #print "[INFO] getKeyFromName_CreateMeta->PROJECT: ".$project->{"name"} . "\n";
	  my @issuetypes = @{ $project->{'issuetypes'} };
	  foreach my $issuet ( @issuetypes ) {
	      
		  if($issuet->{"name"} eq $issueType ){		     
			 my %fields = %{$issuet->{'fields'}};
			 #print "[INFO] getKeyFromName_CreateMeta->ISSUETYPE: ".$issuet->{"name"} . "\n"; 
             for my $field (keys %fields)
             {
			    if(lc  $fields{$field}->{'name'} eq lc $fieldName){
				    #print "[INFO] getKeyFromName_CreateMeta->FIELD NAME: ".$fields{$field} . "\n"; 
				    return $field;
                }				
             }
		  }
	  }
   }
   return 0;
}


##########################################################
# Check if the "value" is in the allowed Values array
# Return JSon representation of the field, 0 otherwise
#
sub checkAllowedValue{
   my $allowedValueArrayObjs = shift;
   my $value      = shift;
   
   my @allowedValuesObj = @{$allowedValueArrayObjs};
   
   #print "Allowed Values: ".Dumper(@allowedValuesObj), length(scalar(@allowedValuesObj)), "\n";
   foreach my $allowedfield ( @allowedValuesObj ) {
        
		#print "ALLOWED FIELD Name:".$allowedfield->{'name'}." - VALUE:".$value."\n";
	    if( $allowedfield->{'name'} and ($allowedfield->{'name'} eq  $value) ){
		    #print "[INFO]\t\tcheckAllowedValue-> ALLOWED FIELD NAME: ".$allowedfield->{'name'}."\n";
		    return 'name';
	    }
	    if( $allowedfield->{'value'} and  $allowedfield->{'value'} eq  $value){
		    #print "[INFO]\t\tcheckAllowedValue-> ALLOWED FIELD value: ".$allowedfield->{'value'}."\n";
			return 'value';
	    }
	    if( $allowedfield->{'id'} and $allowedfield->{'id'} eq  $value){
		    #print "[INFO]\t\tcheckAllowedValue-> ALLOWED FIELD ID: ".$allowedfield->{'id'}."\n";
			return 'id';
	    }
	    if( $allowedfield->{'key'} and $allowedfield->{'key'} eq $value){
	      #print "[INFO]\t\tcheckAllowedValue-> ALLOWED FIELD KEY: ".$allowedfield->{'key'}."\n";
		  return 'key';
	   }
   }   
   return 0;
}

##########################################################################
# Check if the user exist or not in Jira and/or check if is Active or not
#
sub checkUser{
   my $JIRA_SERVER = shift;
   my $JIRA_USER   = shift;
   my $JIRA_PASSWD = shift;
   my $username = shift;
   my $checkRestUrl="/rest/api/latest/user/search?username=";
   
   my $jiraServerRest = $JIRA_SERVER.$checkRestUrl.$username;
   my $restGet = "";
   my $restPost = "";
   
   print "[DEBUG] REST URL:" . $jiraServerRest."\n";
   my $ua = LWP::UserAgent->new; 
	$ua->cookie_jar( {} );
	
    my $req = HTTP::Request->new( GET => "$jiraServerRest");

	$req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );

	my $jsonreq		= $ua->request($req);
	if (!$jsonreq->is_success) {		
	    print  "[ERROR] checkUser-> Could not get data via http: " . $jsonreq->content . "\n";
		close ;
		exit(0);
	}
	#print  "[DEBUG] checkUser-> Get Issue DATA\n";
	my $jsonstr			= $jsonreq->content;
	 
	#print $jsonstr;
	if($username eq ""){
	   print "[WARN] checkUser-> EMPTY USERNAME\n";
	   return 0;
	}
	my $decoded_json = decode_json($jsonstr);
	my @usersArray = @{$decoded_json};
	#print Dumper(@usersArray), length(scalar(@usersArray)), "\n";
	
	foreach my $user ( @usersArray ) {
      #print "[INFO] checkUser->USER: ".$user->{'name'} . "\n";
	  if (index(lc $user->{'name'}, lc $username, ) != -1) {
	     if($user->{'active'} eq 0){
		     print "[WARN] checkUser-> The user ".$user->{'name'}. " is NOT ACTIVE!\n" ;
		 }
	     return $user->{'name'};
	  }
	  else{ 
	     if(index(lc $user->{'displayName'}, lc $username, ) != -1){
	        return $user->{'name'};
	     }
	  }
	}
   return 0;
}

#######################################################################
# Check if the "value" is valid for the field object "fieldObject"
#
sub validateValueFromField{
   my $json        = shift;
   my $myissueType = shift;
   my $fieldName   = shift;
   my $value       = shift;
    
   my $fieldObject = getFieldObjectFromName($json, $myissueType, $fieldName);
   #print Dumper($fieldObject), length($fieldObject), "\n";
   if(!$fieldObject){
      print "[WARN] field is empty(null) for $fieldName \n";
	  return 0;
   }
   #print "[INFO] validateValueFromField-> FieldObj Schema Type: " . $fieldObject->{'schema'}->{'type'}."\n";
   if( $fieldObject->{'schema'}->{'type'} eq 'string' ) {
      if ($fieldObject->{'allowedValues'}){
	    return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	  }
	  return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'array' ){
	  if ($fieldObject->{'allowedValues'}){
         if( ref($value) eq "ARRAY"){
             foreach (@{$value})
	         {
			     my $ftype = checkAllowedValue($fieldObject->{'allowedValues'}, $_);
				 #print "--------------- IS AN ARRAY!!!! VALUE. ".$ftype. ":" .$_."\n";
			     if(!$ftype){ 
				     print "[WARN] ------------- VALUE NOT FOUND - ". $_ ." -----------\n";
				     return $ftype;
				 }
		     }
	     }
	     else{
		     return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	     }	    
	  }
	  return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'date' ){
		#TODO Check date
		return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'issuetype' ){
	  if ($fieldObject->{'allowedValues'}){
	    return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	  }
	  return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'issuelink' ){
       return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'number' ){
      if (looks_like_number($value) ){
	    return 1;
	  }
	  print "[ERROR] validateValueFromField: Field ".$fieldObject->{'name'}." is not a number:".$value."\n";
	  return 0;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'priority' ){
     if ($fieldObject->{'allowedValues'}){
	    return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	 }
	 return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'project' ){
      if ($fieldObject->{'allowedValues'}){
	    return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	  }
	  return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'securitylevel' ){
      if ($fieldObject->{'allowedValues'}){
	    return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	  }
	  return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'timetracking' ){
      return 1;
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'user' ){
      print "[WARN] -----------  Please use checkUser function to check the user name [$fieldName, $value] --------\n";
      return 0;#checkUser($value);
   }
   if( $fieldObject->{'schema'}->{'type'} eq 'version' ){
      if ($fieldObject->{'allowedValues'}){
	    return checkAllowedValue($fieldObject->{'allowedValues'}, $value);
	  }
	  return 1;
   }
   print "[WARN] validateValueFromField-> FieldObj Schema Type Not Managed: " . $fieldObject->{'schema'}->{'type'}."\n";
   return 0;
}

###################################################
# Create a new Issue (NO SUBTASK see createSubTask)
# Return the JSON answer from the server with the ticket id, 
# number and url link ( {"id":"139130","key":"GL005-3851","self":"http://gew12kjiraneo.lng.pce.cz.pan.eu:8085/rest/api/2/issue/139130"})
sub createIssue{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
	my $json_encoded_text = shift;
	
   
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/";
    #my $json = $jsonfields;
    #print "[INFO] JSON:".$json_encoded_text."\n";
    print "[INFO] JIRA REST:".$jiraServerRest."\n";
   
    my $ua = LWP::UserAgent->new; 
    my $req = POST ($jiraServerRest,
  	   Content_Type => 'application/json',
	   Content      => $json_encoded_text, );
	
    #$req->method('PUT');	
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
   
    my $resp = $ua->request($req);   
    if ( !$resp->is_success ) {
 	    print  "[ERROR] Could not create issue " . $resp->content . "\n";
		exit(0);
    }

	my $string = $resp->content . "\n\n";	
    print "JIRA SERVER ANSWER: ".$string."\n";
	my $answerdecoded_json = decode_json($string);
	
	return $answerdecoded_json->{'key'};
}


#################################################################################
# Create a simple hash object,compatible with JSon format, from a Field JSon Object 
# with CF key value.
# Example:  { "key": "JRADEV" }
#
sub createStringFieldObject{
    my $fieldName = shift;
	my $value     = shift;
	my $create_json = shift;
	my $issuetype  = shift;
	
	my $fieldKey = getKeyFromName_CreateMeta( $create_json, $issuetype, $fieldName);
	my $jsontag = { $fieldKey => $value};
	return $jsontag;
}

#################################################################################
# Create an hash object,compatible with JSon format, from a Field JSon Object 
# with CF key value and 'name' or 'key' or 'value' key
# Example: "customfield_10011": { "key": "JRADEV" }
#
sub createKeyStringFieldObject{
    my $fieldName = shift;
	my $key       = shift;
	my $value     = shift;
	my $create_json = shift;
	my $issuetype  = shift;
	
	my $fieldKey = getKeyFromName_CreateMeta( $create_json, $issuetype, $fieldName);
	my $jsontag = { $fieldKey => {$key => $value}};
	return $jsontag;
}

#################################################################################
# Create an hash object of an array,compatible with JSon format, from a Field JSon Object 
# Example: "customfield_10011": [{ "key": "JRADEV" },...]
#
sub createKeyStringArrayFieldObject{
   my $fieldObject = shift;
   my $create_json = shift;   
   my $issuetype   = shift;
   my $value       = shift;

   my @arraytag = ();
   if( ref($value) eq "ARRAY"){
       #print "IS AN ARRAY!!!!\n";
       foreach (@{$value})
	   {
			if ($fieldObject->{'allowedValues'}){
			    my $ftype = checkAllowedValue($fieldObject->{'allowedValues'}, $_);
				#print "IS AN ARRAY!!!! VALUE. ".$ftype. ":" .$_."\n";
			    my $element  = { $ftype => $_ };
			    push(@arraytag, $element);
			}
			else{
			    push(@arraytag, $_);
			}
		}
	}
	else{
		push(@arraytag, $value);
	}
	my $fieldKey = getKeyFromName_CreateMeta( $create_json, $issuetype, $fieldObject->{'name'});
	return { $fieldKey => \@arraytag };
}

############################################################
# This function return a Hash object that represent the 
# JSON format (must be encoded_json, from createJsonMeta)
#
sub createFieldHash{

    my $fieldName  = shift;
	my $value      = shift;
	my $create_json = shift;
	my $issuetype  = shift;
	
	my $fieldObject = getFieldObjectFromName($create_json, $issuetype, $fieldName);
	if($fieldName eq 'project'){
	   return { 'project' => {'key' => $value}};
	}
	if($fieldObject eq 0){
	   print "[ERROR] createFieldHash->Object Field NOT FOUND for field name\"". $fieldName ."\" (or perhaps not a field)\n";
	   return 0;
	}
   #print "createFieldHash -> Field Name:".$fieldName." - Value:".$value."\n";
   if( $fieldObject->{'schema'}->{'type'} eq 'string' or
       $fieldObject->{'schema'}->{'type'} eq 'issuetype' or
       $fieldObject->{'schema'}->{'type'} eq 'priority'	 or
       $fieldObject->{'schema'}->{'type'} eq 'project' 	or
       $fieldObject->{'schema'}->{'type'} eq 'securitylevel' or
       $fieldObject->{'schema'}->{'type'} eq 'version'   ) 
	{
	   
        if ($fieldObject->{'allowedValues'}){		    
	        my $ftype = checkAllowedValue($fieldObject->{'allowedValues'}, $value);
		    return createKeyStringFieldObject( $fieldName, $ftype, $value, $create_json, $issuetype);
	    }
	    return createStringFieldObject( $fieldName, $value, $create_json, $issuetype);
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'array' ){
        return createKeyStringArrayFieldObject($fieldObject , $create_json, $issuetype, $value);
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'date' ){
		#TODO Check date
		return createStringFieldObject( $fieldName, $value, $create_json, $issuetype);
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'number' ){
       if (looks_like_number($value) ){
 	       return createStringFieldObject( $fieldName, $value, $create_json, $issuetype);
	   }
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'timetracking' ){
      return {'timetracking' => {'originalEstimate' => @{$value}[0],'remainingEstimate' => @{$value}[1]}};
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'user' ){
	    if( $value ne ""){
	         return createKeyStringFieldObject( $fieldName, 'name', $value, $create_json, $issuetype);;
	    }
    }
   
    print "[WARN] createFieldHash-> FieldObj Schema Type Not Managed: " . $fieldObject->{'schema'}->{'type'}."\n";
    return 0;
}

###################################
# Add a label to an issue
###################################
sub addLabel{
   my $JIRA_SERVER = shift;
   my $JIRA_USER   = shift;
   my $JIRA_PASSWD = shift;
   my $issueKey = shift;
   my $label = shift;
   
   my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/".$issueKey;
   my $json = '{"update":{ "labels": [ { "add":"'.$label.'" } ] } }';
   #print "[INFO] JSON:".$json."\n";
  # print "[INFO] JIRA REST:".$jiraServerRest."\n";
   
   my $ua = LWP::UserAgent->new; 
   my $req = POST ($jiraServerRest,
	  Content_Type => 'application/json',
	  Content      => $json,
	  );
	
   $req->method('PUT');	
   $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
   #
   my $resp = $ua->request($req);   
   if ( !$resp->is_success ) {
		print  "[ERROR] Could not update label " . $resp->content . "\n";
		exit(0);
	}

	#print Dumper($resp);
	my $string = $resp->content . "\n\n";
	return $resp->content;
}


#################################################
#  Link issues
#################################################

sub createIssueLink{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
	my $linkTypeName  = shift;
    my $ticketFrom = shift;
	my $ticketTO   = shift;
	my $comment    = shift;
	my $commentVisibilityType = shift;
	my $commentVisibilityValue = shift;
	
	
	my $typeTag         = { 'type' => {'name' => $linkTypeName} };
	my $inwardIssueTag  = { 'inwardIssue' => {'key' => $ticketFrom} };
	my $outwardIssueTag = { 'outwardIssue' => {'key' => $ticketTO} };
	my $commentTag = "";
	my $jsonIssueLink = 0;
	if(  $comment and $comment ne "" and $commentVisibilityType and $commentVisibilityValue){
    	$commentTag  = {  'comment' => 
		                 {'body' => $comment, 
		                  'visibility' => {'type' => $commentVisibilityType,'value' => $commentVisibilityValue} }
					   };
		$jsonIssueLink = {%{$typeTag},%{$inwardIssueTag},%{$outwardIssueTag},%{$commentTag}};
	}
	else{
	   $jsonIssueLink = {%{$typeTag},%{$inwardIssueTag},%{$outwardIssueTag}};
	}
    my $encoded_json = encode_json($jsonIssueLink);
    print "[INFO] createIssueLink->  $ticketFrom $linkTypeName $ticketTO\n";
	print Dumper($encoded_json), length($encoded_json), "\n";
	
	
	my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issueLink";
      
    my $ua = LWP::UserAgent->new; 
    my $req = POST ($jiraServerRest,
	  Content_Type => 'application/json',
	  Content      => $encoded_json,
	  );
	
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    my $resp = $ua->request($req);   
    if ( !$resp->is_success ) {
		print  "[ERROR] Could not create issue link " . $resp->content . "\n";
		exit(0);
	}

	#print Dumper($resp->content);	
	return 1;
}

#######################################################
#  Issues Transition Utils
######################################################
# getIssueTransionMeta
# Get Issue transition JSON meta related to the issue.
# It contains the available transition for the issue 
# type and user permissions
#
sub getIssueTransionMeta{
   my $JIRA_SERVER = shift;
   my $JIRA_USER   = shift;
   my $JIRA_PASSWD = shift;
   my $issueKey = shift;
   
   if ($issueKey eq "") {
      print "[ERROR] No IssueKey specified\n";
      exit(1);
   }
 
   my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/". $issueKey ."/transitions?expand=transitions.fields";
   print "[INFO] REST TRANSITION URL:" . $jiraServerRest."\n";
   my $ua = LWP::UserAgent->new; 
   $ua->cookie_jar( {} );
	
   my $req = HTTP::Request->new( GET => "$jiraServerRest");
   $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );

   my $jsonreq		= $ua->request($req);
   if (!$jsonreq->is_success) {		
       print  "[ERROR] Could not get data via http: " . $jsonreq->content . "\n";
       close ;
       exit(0);
   }
   print  "[INFO] Issue transition Meta DATA downloaded\n";
   my $jsonstr			= $jsonreq->content;
   my $decoded_json = decode_json($jsonstr);
   
   # to comment
   #print Dumper($decoded_json), length($decoded_json), "\n";
   
   # my @transitions = @{ $decoded_json->{'transitions'} };
   # foreach my $transition ( @transitions ) {
      # print "[INFO] Transition: ".$transition->{"name"} . "- TransitionID" . $transition->{"id"} . "\n";
   # }
   print "\n";
   return $decoded_json;
     
}

###############################################
#  Execute the transition for the issue.
#  Must be specified the transition Name OR ID
###############################################
sub executeIssueTransition{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
	my $issueKey    = shift;
	my $fieldToUpdate = shift; # Hash of {"field_key=>"value"}
	my $issueTransitionName = shift;
	my $issueTransitionId = shift;	
	
	my $transitionMeta = getIssueTransionMeta($JIRA_SERVER,$JIRA_USER,$JIRA_PASSWD,$issueKey);
	my $transID = "";
	my $transFields = 0;
	
	#Check transition availability
	if($issueTransitionName eq "" and $issueTransitionId eq ""){
		print "[ERROR] TransitionName and TransitionId empty \n";
	    return 0;
	}
	my @transitions = @{ $transitionMeta->{'transitions'} };
    foreach my $transition ( @transitions ) {
		print "[INFO] Transition: ".$transition->{"name"} . "- TransitionID: " . $transition->{"id"} . "\n";
		if($issueTransitionName and $issueTransitionName ne "" and $issueTransitionName eq $transition->{"name"}){
			$transID = $transition->{"id"};
			$transFields = $transition->{"fields"};
			last;
		}
		elsif( $issueTransitionId and $issueTransitionId ne "" and $issueTransitionId eq $transition->{"id"}){
			$transID = $transition->{"id"};
			$transFields = $transition->{"fields"};
			last;
		}
    }
	
	if($transID eq ""){
	    print "[WARN] Cannot execute Transition. Transition ". ($issueTransitionName?$issueTransitionName:""). 
		      "/" .($issueTransitionId?$issueTransitionId:""). " not found\n"; 
		return 0;
	}
	#TODO 
	# check required field
	# add update fields
	# if there is a mandatory field in the workflow REST answer OK instead of error!!!!!!
	if($transFields){
		for my $fkey (keys %{$transFields})
		{
			print " Field:  ".$fkey . " - " . $transFields->{$fkey}->{'name'}." - ".$transFields->{$fkey}->{'required'};
			if($transFields->{$fkey}->{'required'} eq "1"){
			    print " -> REQUIRED\n";
				if( $fieldToUpdate and ($fieldToUpdate->{$transFields->{$fkey}->{'name'}} or $fieldToUpdate->{$fkey})){
				    print "Mandatory field found in update Fields\n";
				}
				else{
					#print "Mandatory field NOT found in update Fields\n";
				}
			}
			else {
			    print " -> NOT REQUIRED\n";
			}
		}
	}
	
	my $jsonTransition = 0;
	my $transitionTag =  { 'transition' => { 'id' => $transID } };

	my $updatesTag =0;
	if( $fieldToUpdate){
		$updatesTag = { 'fields' => $fieldToUpdate};
		#print "Field to set=>".$fieldToUpdate."\n";
	}
	
	if($updatesTag){
		$jsonTransition = {%{$transitionTag},%{$updatesTag}};
	}
	else{
		$jsonTransition = {%{$transitionTag}};
	}
	
    my $encoded_json = encode_json($jsonTransition);
    #print "[INFO] Issue Transition ->  $issueKey -> $transID \n";
	#print Dumper($encoded_json), length($encoded_json), "\n";
	
	my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/". $issueKey ."/transitions";
      
    my $ua = LWP::UserAgent->new; 
    my $req = POST ($jiraServerRest,
	  Content_Type => 'application/json',
	  Content      => $encoded_json,
	  );
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    my $resp = $ua->request($req);   
    if ( !$resp->is_success ) {
		print  "[ERROR] Could not do issue transition " . $resp->content . "\n";
		exit(0);
	}

	#print Dumper($resp->content);	
	return 1;
}




##################################
#
sub createSubTask{
#TODO
my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $project = shift;
	my $issueType = shift;
	my $jsonfields = shift;
	
   
   my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/";
   my $json = $jsonfields;
   #Add :  ... "parent":{"key": "TEST-101"} ...
}

1;
__END__

