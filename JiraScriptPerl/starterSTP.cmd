set CW=38_39
set CONF_FILE=configFile/20150908_CW38_39_ShortTermTemplate.csv

perl CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 2

perl CreateShortTermPlanPlusIntegrationTickets.pl -i CW%CW%_QA_tickets.csv -cw %CW% -st 4

perl LinkTickets.pl CW%CW%_QA_Linkt_to_integration_tickets.csv -st 5