#include "DefaultjiraScriptExecutor.h"

DefaultJiraScriptExecutor::DefaultJiraScriptExecutor(Data* data, QObject *parent)
{
    this->setParent(parent);
    this->m_data = data;
}

bool DefaultJiraScriptExecutor::createSPTicket()
{
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
        this->createSTP(input_file, 1);

        //create morning/follow-up ticket
        this->createMorningFollowupTicket();

        //link the morning/follow-up ticket to the STP already created
        this->linkMfTicketToStp();
    }else
    {
        this->createSTP(input_file, 0);
    }

    return false;
}

void DefaultJiraScriptExecutor::createSTP(JiraSPInputFileCsv *inputFileCsv, int release)
{

}

void DefaultJiraScriptExecutor::createMorningFollowupTicket()
{

}

void DefaultJiraScriptExecutor::linkMfTicketToStp()
{

}


