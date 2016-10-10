cd JiraScriptPerl

set CONF_FILE=configFile/%1
set CW=%2

echo CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3

perl CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3 > script.log