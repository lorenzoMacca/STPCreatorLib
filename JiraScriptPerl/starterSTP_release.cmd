cd JiraScriptPerl

rm -f *.csv *.log

set CONF_FILE=configFile/%1
set CW=%2

echo CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3 >> jira_stp_log.log

perl CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3 >> jira_stp_log.log

echo CreateShortTermPlanPlusIntegrationTickets.pl -i CW%CW%_QA_tickets.csv -cw %CW% -st 4 >> jira_stp_log.log

perl CreateShortTermPlanPlusIntegrationTickets.pl -i CW%CW%_QA_tickets.csv -cw %CW% -st 4 >> jira_stp_log.log

echo LinkTickets.pl CW%CW%_QA_Linkt_to_integration_tickets.csv -st 5 >> jira_stp_log.log

perl LinkTickets.pl CW%CW%_QA_Linkt_to_integration_tickets.csv -st 5 >> jira_stp_log.log
