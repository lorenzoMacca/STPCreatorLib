cd JiraScriptPerl

set CW=%1

echo CreateShortTermPlanPlusIntegrationTickets.pl -i CW%CW%_QA_tickets.csv -cw %CW% -st 4 > createTaskTicket.log

perl CreateShortTermPlanPlusIntegrationTickets.pl -i CW%CW%_QA_tickets.csv -cw %CW% -st 4

echo LinkTickets.pl CW%CW%_QA_Linkt_to_integration_tickets.csv -st 5 > linkTaskToSTP.log

perl LinkTickets.pl CW%CW%_QA_Linkt_to_integration_tickets.csv -st 5
