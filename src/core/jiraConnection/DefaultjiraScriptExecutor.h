#ifndef DEFAULT_SCRIPT_EXECUTOR_H
#define DEFAULT_SCRIPT_EXECUTOR_H

#include <QObject>
#include "JiraScriptExecutor.h"
#include "../data/data.h"
#include "../entities/integration_plan.h"
#include "../jiraConnection/CreateJiraSPTInputFileCsv.h"
#include "../jiraConnection/JiraSPInputFileCsv.h"

class DefaultJiraScriptExecutor : public JiraScriptExecutor{

    Q_OBJECT

public:
    DefaultJiraScriptExecutor(Data* data, QObject *parent=0);
    bool createSPTicket();

public slots:

private:
    Data * m_data;

    void createSTP(JiraSPInputFileCsv *inputFileCsv, int release);
    void createMorningFollowupTicket();
    void linkMfTicketToStp();

signals:
    void integrationPlanNotVerified();

};


#endif
