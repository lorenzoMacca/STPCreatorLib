#ifndef JIRA_SCRIPT_EXECUTOR_H
#define JIRA_SCRIPT_EXECUTOR_H

#include <QObject>
#include <QString>
#include <QProcess>

class JiraScriptExecutor : public QObject{

    Q_OBJECT

public:
    virtual bool createSPTicket()=0;
    virtual QProcess* getProcessSTP()=0;

};

#endif
