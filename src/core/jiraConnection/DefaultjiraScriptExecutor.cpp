#include "DefaultjiraScriptExecutor.h"

DefaultJiraScriptExecutor::DefaultJiraScriptExecutor(Data* data, QObject *parent)
{
    this->setParent(parent);
    this->m_data = data;
}

bool DefaultJiraScriptExecutor::createSPTicket()
{
    emit started();

    //get integration plan from the global data
    IntegrationPlan *integrationPlan = this->m_data->integrationPlan();

    //check the integrationPlan
    if(!integrationPlan->checkIntegrationPlan())
    {
        emit integrationPlanNotVerified();
        return false;
    }

    // create input file for STP
    CreateJiraSPTInputFileCsv *input_file_creator = new CreateJiraSPTInputFileCsv(this->m_data->getHTMLCode(), integrationPlan, this);
    JiraSPInputFileCsv *input_file =input_file_creator->createJiraSPTInputFileCsv();

    //save the input file
    input_file->save(this->m_data->settingData()->sp_input_file_name());

    if(integrationPlan->stp_type() == IntegrationPlan::RELEASE)
    {
        //create the STP
        this->createSTP(integrationPlan->cw(), 1);

        //create morning/follow-up ticket
        this->createMorningFollowupTicket(integrationPlan->cw());

    }else
    {
        this->createSTP(integrationPlan->cw(), 0);
    }

    emit finished();
    return true;
}

void DefaultJiraScriptExecutor::createSTP(QString cw, int release)
{
    QDir jira_script_folder = this->m_data->settingData()->create_stp_jira_path();
    if(!jira_script_folder.exists())
    {
        emit jiraScriptFolderNotFound();
        return;
    }

    QProcess *process = new QProcess(this);
    process->setObjectName("Creating STP ticket");

    QStringList arguments;
    arguments << "STPs.csv" << cw << QString::number(release);
    process->start("JiraScriptPerl/starterSTP_for_Lib.cmd", arguments);
}

void DefaultJiraScriptExecutor::createMorningFollowupTicket(QString cw)
{
    QDir jira_script_folder = this->m_data->settingData()->create_stp_jira_path();
    if(!jira_script_folder.exists())
    {
        emit jiraScriptFolderNotFound();
        return;
    }

    QProcess *process = new QProcess(this);
    process->setObjectName("Creating Task ticket");

    QStringList arguments;
    arguments << cw;
    process->start("JiraScriptPerl/starterTaskTicket_for_Lib.cmd", arguments);
}


