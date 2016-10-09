set CW=%1
set CONF_FILE=configFile/%2

perl CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2 -r %3