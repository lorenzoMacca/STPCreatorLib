#include "data.h"

Data::Data(IntegrationPlan *integration_plan, QObject *parent):QObject(parent)
{
    this->m_settingData_ptr = 0;
    this->m_integration_plan_ptr = integration_plan;
    this->initSettingData();
}

void Data::initSettingData()
{
    this->m_settingData_ptr = new SettingData(this);
}

SettingData* Data::settingData()
{
    return this->m_settingData_ptr;
}

IntegrationPlan* Data::integrationPlan()
{
    return this->m_integration_plan_ptr;
}

void Data::removeIntegrationPlan()
{
    delete this->m_integration_plan_ptr;
    this->m_integration_plan_ptr = 0;
}

void Data::setIntegrationPlan(IntegrationPlan *integration_plan)
{
    if( !this->m_integration_plan_ptr )
    {
        this->removeIntegrationPlan();
    }
    this->m_integration_plan_ptr = integration_plan;
}

const QString Data::getHTMLCode()
{
    QString html_code = "<html></html>";
    return html_code;
}

