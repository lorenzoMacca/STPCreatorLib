#include "DefaultjiraScriptExecutor.h"

DefaultJiraScriptExecutor::DefaultJiraScriptExecutor(Data* data, QObject *parent)
{
    this->setParent(parent);
    this->m_data = data;
	this->processSTP = new QProcess(this);
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


    //create the STP
	if(this->m_data->integrationPlan()->stp_type() == IntegrationPlan::RELEASE)
    {
		this->createSTP(integrationPlan->cw(), 1);
	}else
	{
		this->createSTPDevDrop(integrationPlan->cw(), 0);
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

    this->processSTP->setObjectName("Creating STP ticket");

    QStringList arguments;
    arguments << "STPs.csv" << cw << QString::number(release);
    this->processSTP->start("JiraScriptPerl/starterSTP_release.cmd", arguments);
    emit STPCreated();
}

void DefaultJiraScriptExecutor::createSTPDevDrop(QString cw, int release)
{
	QDir jira_script_folder = this->m_data->settingData()->create_stp_jira_path();
    if(!jira_script_folder.exists())
    {
        emit jiraScriptFolderNotFound();
        return;
    }

    this->processSTP->setObjectName("Creating STP ticket dev drop");

    QStringList arguments;
    arguments << "STPs.csv" << cw << QString::number(release);
    this->processSTP->start("JiraScriptPerl/starterSTP_dev_drop.cmd", arguments);
    emit STPCreated();
}
