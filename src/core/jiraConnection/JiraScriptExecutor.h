#ifndef JIRA_SCRIPT_EXECUTOR_H
#define JIRA_SCRIPT_EXECUTOR_H

#include <QObject>
#include <QString>

class JiraScriptExecutor : public QObject{

    Q_OBJECT

public:
    virtual bool createSPTicket()=0;

};

#endif
