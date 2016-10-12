cd JiraScriptPerl

rm -f *.csv *.log

set CONF_FILE=configFile/%1
set CW=%2

echo CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3 >> jira_stp_log.log

perl CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3 >> jira_stp_log.log