set CW=38_39
set CONF_FILE=configFile/20150908_CW38_39_IntegrationTemplate.csv

perl CreateShortTermPlanPlusIntegrationTickets.pl -i %CONF_FILE% -cw %CW% -st 1

perl CreateShortTermPlanPlusIntegrationTickets.pl -i CW%CW%_QA_tickets.csv -cw %CW% -st 3

perl LinkTickets.pl CW%CW%_QA_Linkt_to_integration_tickets.csv -st 5