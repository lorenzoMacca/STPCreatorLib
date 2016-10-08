package PAISEU::JiraRestUpdateIssueUtils;
# JiraRestUtils.pm
#
# Author: extern.prevignano
#
# Date: 2014-10-22
#
# Description:
# Utility library to interact with Jira through REST API
# List of function:
#
#   getFieldsListMeta
#   getFieldNameFromKey_FieldMeta
#   getFieldKeyFromName_FieldMeta
#   getFieldValueFromJira
#   addLabel
#   addComment
#   checkAndCreateFieldHash
#   getFieldObjectFromName_FieldMeta
#   createIssueLink
#   executeIssueTransition
#   updateIssue



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
use lib "..";
use PAISEU::LogMessage;
use Encode qw(encode_utf8);
use Date::Calc;
#use Switch;

use Exporter;
use base 'Exporter';

our @EXPORT = qw (
    getEditMeta
    getFieldsListMeta
    getFieldNameFromKey_FieldMeta
    getFieldKeyFromName_FieldMeta
    getFieldValueFromJira
    addLabel
    addComment   
    checkAndCreateFieldHash
    getFieldObjectFromName_FieldMeta
    createIssueLink
    executeIssueTransition
    updateIssue
    addAttachmentFile
    validateValueFromField
    executeJQLQuery
);


#############################################################
#  Get the Fields List Meta (JSON) from the Jira Server
#  REST API: "/rest/api/2/field"
#  Return the JSon of all available fields in the JIRA server
sub executeJQLQuery {
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $jql         = shift;
    
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/search?jql=";
    my $restGet = "";
    my $restPost = "";
    $jiraServerRest .= $jql;
    
    print "REST URL:" . $jiraServerRest;
    my $ua = LWP::UserAgent->new;
    $ua->cookie_jar( {} );
    
    my $req = HTTP::Request->new( GET => "$jiraServerRest");
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    
    my $jsonreq             = $ua->request($req);
    if (!$jsonreq->is_success) {
        my $error_message = '[ERROR] Could not get data via http:';
        #process_error($jsonreq, $error_message);
        return -1;
    }
    #print  "[INFO] Get Field List Meta DATA\n";
    my $jsonstr                     = $jsonreq->content;
    
    my $decoded_json = decode_json($jsonstr);
     #print Dumper($decoded_json), length($decoded_json), "\n";
     my $issuenumber = scalar(@{$decoded_json->{'issues'}});
     #print "ISSUE NUMBER:". $issuenumber."\n";
    return $issuenumber;
    
}

#############################################################
#  Get the Fields List Meta (JSON) from the Jira Server
#  REST API: "/rest/api/2/field"
#  Return the JSon of all available fields in the JIRA server
sub getEditMeta {
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $issuekey    = shift;
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/$issuekey/editmeta";
    my $restGet = "";
    my $restPost = "";
    
    #print "REST URL:" . $jiraServerRest."\n";
    my $ua = LWP::UserAgent->new;
    $ua->cookie_jar( {} );
    
    my $req = HTTP::Request->new( GET => "$jiraServerRest");
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    
    my $jsonreq             = $ua->request($req);
    if (!$jsonreq->is_success) {
        my $error_message = '[ERROR] Could not get data via http:';
        process_error($jsonreq, $error_message);
    }
    #print  "[INFO] Get Field List Meta DATA\n";
    my $jsonstr                     = $jsonreq->content;
    
    my $decoded_json = decode_json($jsonstr);
    # print Dumper($decoded_json), length($decoded_json), "\n";
    return $decoded_json;
}




#############################################################
#  Get the Fields List Meta (JSON) from the Jira Server
#  REST API: "/rest/api/2/field"
#  Return the JSon of all available fields in the JIRA server
sub getFieldsListMeta {
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/field";
    my $restGet = "";
    my $restPost = "";
    
    #print "REST URL:" . $jiraServerRest."\n";
    my $ua = LWP::UserAgent->new; 
    $ua->cookie_jar( {} );
    
    my $req = HTTP::Request->new( GET => "$jiraServerRest");
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    
    my $jsonreq     = $ua->request($req);
    if (!$jsonreq->is_success) {        
        my $error_message = '[ERROR] Could not get data via http:';
        process_error($jsonreq, $error_message);
    }
    #print  "[INFO] Get Field List Meta DATA\n";
    my $jsonstr         = $jsonreq->content;
    
    my $decoded_json = decode_json($jsonstr);
    #    print Dumper($decoded_json), length($decoded_json), "\n";  
    return $decoded_json;
}

#######################################################
# Return the field name from field key using Field Meta
#
sub getFieldNameFromKey_FieldMeta {
    my $fieldKey = shift;
    my $decoded_json = shift;
    
    my @fieldObjs = @{ $decoded_json };
    foreach my $fieldObj ( @fieldObjs ) {
        if( lc $fieldObj->{'id'} eq lc $fieldKey){
            return $fieldObj->{'name'};
        }
    }
    return 0;
}

#####################################################################
# This function look for the field object (customfield_xxxx) from  
# field NAME in the JSON field Meta data
#
sub getFieldObjectFromName_FieldMeta{
    my $field_json = shift;
    my $fieldName = shift;
    
    my @fields = @{ $field_json };
    foreach my $field ( @fields ) {
        #print "[INFO] getFieldObjectFromName_FieldMeta->: ".$field->{"name"} . "\n";
        if(lc  $field->{'name'} eq lc $fieldName){
            print "[INFO] getFieldObjectFromName_FieldMeta->FIELD NAME: ".$field->{"name"} . "\n"; 
            return $field;
        }
    }
    return 0;
}

#####################################################################
# This function look for the field object (customfield_xxxx) from
# field NAME in the JSON field Meta data
#
sub getFieldObjectFromName_EditMeta{
    my $edit_json = shift;
    my $fieldName = shift;
    
#    print Dumper($edit_json->{'fields'}), length($edit_json->{'fields'}), "\n";    
    my %fields = %{ $edit_json->{'fields'}  };
    for my $field (keys %fields)
    {
#           print "[INFO] getFieldObjectFromName->FIELD KEY: ".$field . "\n";
        if(lc  $fields{$field}->{'name'} eq lc $fieldName){
            print "[INFO] getFieldObjectFromName->FIELD NAME: ".$fields{$field}->{'name'} . "\n";
            return ($field, $fields{$field});
        }
    }
    
    return (0,0);
}

########################################
# Return the field key from field name 
# using the JSON field meta data
#
sub getFieldKeyFromName_FieldMeta {
    my $fieldName = shift;
    my $decoded_json = shift;
    
    #print "[INFO] Get Field key from Field name \n";
    
    my @fieldObjs = @{ $decoded_json };
    foreach my $fieldObj ( @fieldObjs ) {
        if( lc $fieldObj->{'name'} eq lc $fieldName){
            return $fieldObj->{'id'};
        }
    }
    return 0;
}
#--------------- END Field Meta Utilities ---------------------------


#################################################
#  Get the value "object" of the specified field from Jira
#  REST API: "/rest/api/2/issue/$ISSUEKEY"
#
sub getFieldValueFromJira{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $issueKey = shift;
    my $fieldKey = shift;
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/".$issueKey;
    my $restGet = "";
    my $restPost = "";
    
    #print "REST URL:" . $jiraServerRest."\n";
    my $ua = LWP::UserAgent->new; 
    $ua->cookie_jar( {} );
    
    my $req = HTTP::Request->new( GET => "$jiraServerRest");
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    
    my $jsonreq     = $ua->request($req);
    if (!$jsonreq->is_success) {
        my $error_message = '[ERROR] Could not get data via http:';
        process_error($jsonreq, $error_message);
    }
    #print  "[INFO] Get Issue DATA\n";
    my $jsonstr         = $jsonreq->content;
    
    #print $jsonstr;
    if($fieldKey eq ""){
    print "[WARN] getFieldValueFromJira: EMPTY FIELDNAME\n";
    return 0;
    }
    my $decoded_json = decode_json($jsonstr);
    my $field_json = getFieldsListMeta($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD);
    #print Dumper($decoded_json), length($decoded_json), "\n";  
    
    if(defined $decoded_json){  
        my %fieldHash = %{$decoded_json->{'fields'}};
        if(%fieldHash){
            for my $fkey (keys %fieldHash)
            {
                if($fieldKey eq $fkey){
                   print "[INFO] Field Name:   ".getFieldNameFromKey_FieldMeta($fkey,$field_json). " - Field KEY:  ". $fkey ."      \t- Field Value:  " .$fieldHash{$fkey}."\n";
                   #TODO!!!!!
                   #this return a string value or an simple/complex HASH of values like linkedissue
                   #print Dumper($fieldHash{$fkey}), length($fieldHash{$fkey}), "\n";
                   return $fieldHash{$fkey};
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
        if( $allowedfield->{'id'} and $allowedfield->{'id'} eq  $value){
            #print "[INFO]\t\tcheckAllowedValue-> ALLOWED FIELD ID: ".$allowedfield->{'id'}."\n";
            return 'id';
        }
        if( $allowedfield->{'value'} and  $allowedfield->{'value'} eq  $value){
            #print "[INFO]\t\tcheckAllowedValue-> ALLOWED FIELD value: ".$allowedfield->{'value'}."\n";
            return 'value';
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
    
    #print "[DEBUG] REST URL:" . $jiraServerRest."\n";
    my $ua = LWP::UserAgent->new; 
    $ua->cookie_jar( {} );
    
    my $req = HTTP::Request->new( GET => "$jiraServerRest");
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    
    my $jsonreq     = $ua->request($req);
    if (!$jsonreq->is_success) {
        my $error_message = '[ERROR] checkUser-> Could not get data via http:';
        process_error($jsonreq, $error_message);
    }
    #print  "[DEBUG] checkUser-> Get Issue DATA\n";
    my $jsonstr         = $jsonreq->content;
     
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

#####################################################################################
# Check if the "value" is valid for the field object "fieldObject" (with create meta)
#
sub validateValueFromField{
    my $json        = shift;
    my $myissueType = shift;
    my $fieldName   = shift;
    my $value       = shift;
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    
    my $fieldObject = getFieldObjectFromName_EditMeta($json, $fieldName);
    #print Dumper($fieldObject), length($fieldObject), "\n";
    if(!$fieldObject){
        print "[ERROR] field $fieldName not available on creation\n";
        return 0;
    }
    #print "[INFO] validateValueFromField-> FieldObj Schema Type: " . $fieldObject->{'schema'}->{'type'}."\n";
    if( $fieldObject->{'schema'}->{'type'} eq 'string' ) {
        if ($fieldObject->{'allowedValues'}){
            my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value);
            if($checkVal){
                return $value;
            }
            else{
                return $checkVal;
            }
        }
        return $value;
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
                my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value); 
                if($checkVal){
                    return $value;
                }
                else{
                    return $checkVal;
                }
            }    
        }
        return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'date' ){
        my $dateValue = "";
        my ( $day,$month,$year );
        
        if( $value =~ m/(\d\d)\.(\d\d)\.(\d\d\d\d)/){ # dd.mm.yyyy
            ( $day,$month,$year ) = ($1, $2, $3);
            $dateValue = "$year-$month-$day";
        }
        elsif( $value =~ m/(\d\d)-(\d\d)-(\d\d\d\d)/){ # dd-mm-yyyy
            ( $day,$month,$year ) = ($1, $2, $3);
            $dateValue = "$year-$month-$day";
        }
        elsif( $value =~ m/(\d\d\d\d)-(\d\d)-(\d\d)/){ # yyyy-mm-dd
            ( $year,$month,$day ) = ($1, $2, $3);
            $dateValue = "$value";
        }
        elsif( $value =~ m/(\d\d)\/(\d\d)\/(\d\d\d\d)/) { # dd/mm/yyyy
            ( $day,$month,$year ) = ($1, $2, $3);
            $dateValue = "$year-$month-$day";
        }
        else{
            print "[ERROR] validateValueFromField: Field ".$fieldObject->{'name'}." is a date of unrecognized format: ".$value."\n";
            print "[ERROR] validateValueFromField: Accepted date formats are: dd.mm.yyyy or dd-mm-yyyy or yyyy-mm-dd or dd/mm/yyyy\n";
            return 0;
        }
        
        # Validate the date, to prevent errors like 31st of February
        if (Date::Calc::check_date($year, $month, $day)) {
            #print "Date $day/$month/$year is valid\n";
        } else {
            print "[ERROR] validateValueFromField: Date $day/$month/$year does not exist\n";
            return 0;
        }
        
        return $dateValue;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'issuetype' ){
        if ($fieldObject->{'allowedValues'}){
            my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value); 
            if($checkVal){
                return $value;
            }
            else{
                return $checkVal;
            }
        }
        return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'issuelink' ){
        return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'number' ){
        if (looks_like_number($value) ){
            return $value;
        }
        print "[ERROR] validateValueFromField: Field ".$fieldObject->{'name'}." is not a number:".$value."\n";
        return 0;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'priority' ){
        if ($fieldObject->{'allowedValues'}){
            if ($fieldObject->{'allowedValues'}){
                my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value);
                if($checkVal){
                    return $value;
                }
                else{
                    return $checkVal;
                }
            }
        }
        return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'project' ){
        if ($fieldObject->{'allowedValues'}){
            if ($fieldObject->{'allowedValues'}){
                my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value); 
                if($checkVal){
                    return $value;
                }
                else{
                    return $checkVal;
                }
            }
        }
        return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'securitylevel' ){
        if ($fieldObject->{'allowedValues'}){
        if ($fieldObject->{'allowedValues'}){
            my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value); 
            if($checkVal){
                return $value;
            }
            else{
                return $checkVal;
            }
        }
    }
    return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'timetracking' ){
        return $value;
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'user' ){
        #print "[WARN] -----------  Please use checkUser function to check the user name [$fieldName, $value] --------\n";
        return checkUser($JIRA_SERVER, $JIRA_USER, $JIRA_PASSWD,$value);
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'version' ){
        if ($fieldObject->{'allowedValues'}){
            if ($fieldObject->{'allowedValues'}){
                my $checkVal = checkAllowedValue($fieldObject->{'allowedValues'}, $value);
                if($checkVal){
                    return $value;
                }
                else{
                    return $checkVal;
                }
            }
        }
        return $value;
    }
    print "[WARN] validateValueFromField-> FieldObj Schema Type Not Managed: " . $fieldObject->{'schema'}->{'type'}."\n";
    return 0;
}



#################################################################################
# Create a simple hash object,compatible with JSon format, from a Field JSon Object 
# with CF key value.
# Example:  { "key": "JRADEV" }
#
sub createStringFieldObject{
    my $fieldKey = shift;
    my $value     = shift;
    my $operation = shift;
    
    my $jsontag = '{ "'. $fieldKey .'": [ {"'.$operation.'":"'.$value.'" } ] }';
#   my $jsontag = "{ $fieldKey => $value}";
    return $jsontag;
}


#################################################################################
# Create a simple hash object,compatible with JSon format, from a Field JSon Object
# with CF key value.
# Example:  { "key": "JRADEV" }
#
sub createNumberFieldObject{
    my $fieldKey = shift;
    my $value     = shift;
    my $operation = shift;
    
    my $jsontag = '{ "'. $fieldKey .'": [ {"'.$operation.'":"'.int($value).'" } ] }'; # { $fieldKey => int($value)};
    return $jsontag;
}

#################################################################################
# Create an hash object,compatible with JSon format, from a Field JSon Object 
# with CF key value and 'name' or 'key' or 'value' key
# Example: "customfield_10011": { "key": "JRADEV" }
#
sub createKeyStringFieldObject{
    my $fieldkey   = shift;
    my $key       = shift;
    my $value     = shift;
    my $operation = shift;
    my $jsontag = '{ "'. $fieldkey .'": [ {"'.$operation.'":{"'.$key.'":"'.$value.'"} } ] }';
    return $jsontag;
}

#################################################################################
# Create an hash object of an array,compatible with JSon format, from a Field JSon Object 
# Example: "customfield_10011": [{ "key": "JRADEV" },...]
#
sub createKeyStringArrayFieldObject{
    my $fieldObject = shift;
    my $value       = shift;
    my $fieldKey    = shift;
    my $operation = shift;
    
    my $jsontag = '{ "'.$fieldKey.'":[';
    
    if( ref($value) eq "ARRAY"){
        #print "IS AN ARRAY!!!!\n";
        foreach (@{$value})
        {
        if ($fieldObject->{'allowedValues'}){
            my $ftype = checkAllowedValue($fieldObject->{'allowedValues'}, $_);
            #print "IS AN ARRAY!!!! VALUE. ".$ftype. ":" .$_."\n";
            $jsontag = $jsontag.'{"'.$operation.'":[{"'.$ftype.'":"'.$_.'"}]}';
        }
            else{
                $jsontag = $jsontag.'{"'.$operation.'":"'.$_.'"}';
            }
        }
    }
    else{
        #print Dumper($fieldObject), length($fieldObject), "\n";
        if ($fieldObject->{'allowedValues'}){
            my $ftype = checkAllowedValue($fieldObject->{'allowedValues'}, $value);
            $jsontag = $jsontag.'{"'.$operation.'":[{"'.$ftype.'":"'.$value.'"}]}';
        }
        else{
            $jsontag = $jsontag.'{"'.$operation.'":"'.$value.'"}';
        }
    }
    $jsontag = $jsontag.']}';
    return $jsontag;
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
        my $error_message = '[ERROR] Could not update label';
        process_error($resp, $error_message);
    }
    
    #print Dumper($resp);
    my $string = $resp->content . "\n\n";
    return $resp->content;
}

###################################
# Add a comment to an issue
###################################
sub addAttachmentFile{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $issueKey = shift;
    my $attachFileURL = shift;
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/".$issueKey."/attachments";
    #$comment =~ s/\n/\\n/g;
#   my $json = '{"update":{ "comment": [ { "add": { "body":"'.encode_utf8($comment).'"} } ] } }';
    
    #print "jiraserverRest: ". $jiraServerRest."\n";
    $attachFileURL =~  s/\\/\//g;
    print "[INFO] -- addAttachmentFile: file to attach  ". $attachFileURL."\n";
    if ( -e $attachFileURL) {
        
        my $ua = LWP::UserAgent->new;
        my $req = POST ($jiraServerRest,
            Content_Type => 'form-data',
            'X-Atlassian-Token' => 'nocheck',
            #Content      => [file => [$attachFileURL,"ZTest.csv"],],
            Content      => [file => [ $attachFileURL],],
        );
        
        $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
        
        my $resp = $ua->request($req);
        if ( !$resp->is_success ) {
            my $error_message = '[ERROR] Could not add attachment';
            process_error($resp, $error_message);
        }
        
        #print Dumper($resp);
        my $string = $resp->content . "\n\n";
        return $resp->content;
    }
    else{
        print "[ERROR] file ".  $attachFileURL ." not found in the path specified\n";
    }
    return 0;
}


###################################
# Add a comment to an issue
###################################
sub addComment{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $issueKey = shift;
    my $comment = shift;
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/".$issueKey;
    $comment =~ s/\n/\\n/g;  # Escape newlines
    $comment =~ s/"/\\"/g;   # Escape quotes
    my $json = '{"update":{ "comment": [ { "add": { "body":"'.encode_utf8($comment).'"} } ] } }';
    
    #print Dumper($json), length($json), "\n";
    
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
        my $error_message = '[ERROR] Could not add comment';
        process_error($resp, $error_message);
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
    #print Dumper($encoded_json), length($encoded_json), "\n";
    
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issueLink";
    
    my $ua = LWP::UserAgent->new;
    my $req = POST ($jiraServerRest,
        Content_Type => 'application/json',
        Content      => $encoded_json,
    );
    
    
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    my $resp = $ua->request($req);
    if ( !$resp->is_success ) {
        my $error_message = '[ERROR] Could not create issue link';
        process_error($resp, $error_message);
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
    
    my $jsonreq      = $ua->request($req);
    if (!$jsonreq->is_success) {
        my $error_message = '[ERROR] Could not get data via http:';
        process_error($jsonreq, $error_message);
    }
    print  "[INFO] Issue transition Meta DATA downloaded\n";
    my $jsonstr          = $jsonreq->content;
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
        #print "[ERROR] TransitionName and TransitionId empty \n";
        log_msg($LOG_TYPE_ERR, "TransitionName and TransitionId are empty");
        return 0;
    }
    my @transitions = @{ $transitionMeta->{'transitions'} };
    foreach my $transition ( @transitions ) {
        log_msg($LOG_TYPE_INF, "Transition: ".$transition->{"name"} . " (TransitionID: " . $transition->{"id"} . ")");
        #print "[INFO] Transition: ".$transition->{"name"} . " (TransitionID: " . $transition->{"id"} . ")\n";
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
        log_msg($LOG_TYPE_WARN, "Cannot execute Transition. Transition ". ($issueTransitionName?$issueTransitionName:"").
              "/" .($issueTransitionId?$issueTransitionId:"-"). " not found");
        #print "[WARN] Cannot execute Transition. Transition ". ($issueTransitionName?$issueTransitionName:""). 
        #      "/" .($issueTransitionId?$issueTransitionId:""). " not found\n"; 
        return 0;
    }
    #TODO 
    # check required field
    # add update fields
    # if there is a mandatory field in the workflow REST answer OK instead of error!!!!!!
    if($transFields){
        for my $fkey (keys %{$transFields})
        {
            #log_msg($LOG_TYPE_INF, " Field:  ".$fkey . " - " . $transFields->{$fkey}->{'name'}." - ".$transFields->{$fkey}->{'required'});
            #print " Field:  ".$fkey . " - " . $transFields->{$fkey}->{'name'}." - ".$transFields->{$fkey}->{'required'};
            if($transFields->{$fkey}->{'required'} eq "1"){
                log_msg($LOG_TYPE_INF, " Field:  ".$fkey . " ------------> " . $transFields->{$fkey}->{'name'}." - ".$transFields->{$fkey}->{'required'} . "-> REQUIRED");
                #print " --> REQUIRED\n";
                if( $fieldToUpdate and ($fieldToUpdate->{$transFields->{$fkey}->{'name'}} or $fieldToUpdate->{$fkey})){
                    log_msg($LOG_TYPE_INF,"------  Mandatory field found in update Fields");
                    #print "Mandatory field found in update Fields\n";
                }
                else{
                    #print "Mandatory field NOT found in update Fields\n";
                }
            }
            else {
                log_msg($LOG_TYPE_INF, " Field:  ".$fkey . " - " . $transFields->{$fkey}->{'name'}." - ".$transFields->{$fkey}->{'required'} . "-> NOT REQUIRED");
                #print " -> NOT REQUIRED\n";
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
        my $error_message = '[ERROR] Could not do issue transition';
        process_error($resp, $error_message);
    }
    
    #print Dumper($resp->content);
    return 1;
}



#################################################################
#  Update Issue with new fields value
#  Fields parameter is an array of: ["customfield_11111, "value"]
#  Operation can be: "set","add","remove"
#################################################################
sub updateIssue{
    my $JIRA_SERVER = shift;
    my $JIRA_USER   = shift;
    my $JIRA_PASSWD = shift;
    my $issueKey = shift;
    my $fields = shift;
    my $operation = shift;
    my $editmeta = shift;
    
    my $fieldName = $fields->[0];
    my $fieldValueNotUtf8 = $fields->[1];
    my $fieldValue = encode_utf8($fieldValueNotUtf8);
    
    if(!$editmeta){
        $editmeta = getEditMeta($JIRA_SERVER,$JIRA_USER,$JIRA_PASSWD,$issueKey);
    }
    my ($fieldkey, $fieldObject)  = getFieldObjectFromName_EditMeta($editmeta, $fields->[0]);
    my $updateJson = "";
    
    if($fieldObject eq 0){
        print "[ERROR] updateIssue->Object Field NOT FOUND for field name\"". $fieldName ."\" (or perhaps not a field)\n";
        return 0;
    }
    
    print "updateFieldHash -> Field Name:".$fieldName." - Value:".$fieldValue." === ".$fieldObject->{'schema'}->{'type'}."\n";
    if( $fieldObject->{'schema'}->{'type'} eq 'string' or
        $fieldObject->{'schema'}->{'type'} eq 'issuetype' or
        $fieldObject->{'schema'}->{'type'} eq 'priority'  or
        $fieldObject->{'schema'}->{'type'} eq 'project'  or
        $fieldObject->{'schema'}->{'type'} eq 'securitylevel' or
        $fieldObject->{'schema'}->{'type'} eq 'version'   ) 
    {
        my $jsonfield = "";
        if ($fieldObject->{'allowedValues'}){
            my $ftype = checkAllowedValue($fieldObject->{'allowedValues'}, $fieldValue);
            $jsonfield = createKeyStringFieldObject( $fieldkey, $ftype, $fieldValue , $operation);
        }
        else{
            $jsonfield = createStringFieldObject( $fieldkey, $fieldValue, $operation);
        }
        $updateJson =  '{"update":'. $jsonfield .'}';
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'array' ){
        my $jsonfield = createKeyStringArrayFieldObject($fieldObject , $fieldValue, $fieldkey, $operation);
        $updateJson =  '{"update":'. $jsonfield .'}';
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'date' ){
        my $dateValue = "";
        if( $fieldValue =~ m/(\d\d).(\d\d).(\d\d\d\d)/){
            my ( $day,$month,$year ) = $fieldValue =~ m/(\d\d).(\d\d).(\d\d\d\d)/;
            $dateValue = "$year-$month-$day";
        }
        else{
            if( $fieldValue =~ m/(\d\d)-(\d\d)-(\d\d\d\d)/){
                my ( $day,$month,$year ) = $fieldValue =~ m/(\d\d)-(\d\d)-(\d\d\d\d)/;
                $dateValue = "$year-$month-$day";
            }
            else{
                if( $fieldValue =~ m/(\d\d\d\d)-(\d\d)-(\d\d)/){
                    $dateValue = "$fieldValue";
                }
            }
        }
        my $jsonfield = createStringFieldObject( $fieldkey, $dateValue,$operation);
        $updateJson =  '{"update":'. $jsonfield .'}';
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'number' ){
        if (looks_like_number($fieldValue) ){
            my $jsonfield = createNumberFieldObject( $fieldkey, $fieldValue);
            $updateJson =  '{"update":'. $jsonfield .'}';    
        }
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'timetracking' ){
        $updateJson =  '{"update":{ "'.$fieldObject->{id}.'": [ {"'.$operation.'":"'.$fieldValue.'" } ] } }';
    }
    if( $fieldObject->{'schema'}->{'type'} eq 'user' ){
        if( $fieldValue ne ""){
            my $jsonfield = createKeyStringFieldObject( $fieldkey, 'name', $fieldValue , $operation);
            $updateJson =  '{"update":'. $jsonfield .'}';    
        }
    }
    
    
    my $jiraServerRest = $JIRA_SERVER."/rest/api/2/issue/".$issueKey;
    print "[INFO] Update:". $issueKey ." - JSON:".$updateJson."\n";
    
    my $ua = LWP::UserAgent->new; 
    my $req = POST ($jiraServerRest,
        Content_Type => 'application/json',
        Content      => $updateJson,
    );
    
    $req->method('PUT'); 
    $req->authorization_basic( $JIRA_USER, $JIRA_PASSWD );
    #
    my $resp = $ua->request($req);
    if ( !$resp->is_success ) {
        my $error_message = '[ERROR] Could not update $fieldName';
        process_error($resp, $error_message);
    }
    
    my $string = $resp->content . "\n\n";
    #print Dumper($string);
    return $resp->content;
}


sub process_error {
    my $resp = shift;
    my $error_message = shift;
    
    if ($resp->content =~ /<title>Unauthorized \(401\)<\/title>/) {
        # print "\n[ERROR] Jira authentication failed\n";
        # print "Please make sure your username and password are correct, and the password hasn't expired.\n";
        print "\n";
        log_msg($LOG_TYPE_ERR, "Jira authentication failed");
        log_msg($LOG_TYPE_ERR, "Please make sure your username and password are correct, and the password hasn't expired.");
    } else {
        #print  $error_message . "\n" . $resp->content . "\n";
        log_msg($LOG_TYPE_ERR, $error_message . "\n" . $resp->content);
    }
    close;
    exit(0);
}

1;
__END__

