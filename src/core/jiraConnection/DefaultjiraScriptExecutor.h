#ifndef DEFAULT_SCRIPT_EXECUTOR_H
#define DEFAULT_SCRIPT_EXECUTOR_H

#include <QObject>
#include <QProcess>
#include <QDebug>
#include <QProcessEnvironment>
#include <QDir>
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
    const static int ERROR_FOLDER_NOT_FOUND = 1;
    const static int ERROR_SCRIPT_NOT_FOUND = 2;
    const static int ERROR_INPUT_FILE = 3;

public slots:

private:
    Data * m_data;
	QProcess *processSTP;
    void createSTP(QString cw, int release);
	void createSTPDevDrop(QString cw, int release);


signals:
    void integrationPlanNotVerified();
    void started();
    void finished();
    void jiraScriptFolderNotFound();
    void STPCreated();

};


#endif
