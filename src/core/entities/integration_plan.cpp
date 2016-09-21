#include "integration_plan.h"

const QString IntegrationPlan::RELEASE="release";
const QString IntegrationPlan::DEV_DROP="dev_drop";

IntegrationPlan::IntegrationPlan(QObject *parent):QObject(parent)
{

}

IntegrationPlan::IntegrationPlan(QString summary, QDate due_date, QDate start_date, QString cw, QDate merge_date, QObject *parent)
:QObject(parent)
{
    this->m_summary = summary;
    this->m_due_date = due_date;
    this->m_start_date = start_date;
    this->m_cw = cw;
    this->m_merge_date = merge_date;
}

const QString& IntegrationPlan::summary()const
{
    return this->m_summary;
}

const QDate& IntegrationPlan::due_date()const
{
    return this->m_due_date;
}

const QDate& IntegrationPlan::start_date()const
{
    return this->m_start_date;
}

const QString& IntegrationPlan::cw()const
{
    return this->m_cw;
}

const QDate& IntegrationPlan::merge_date()const
{
    return this->m_merge_date;
}

const QList<Build>& IntegrationPlan::builds()const
{
    return this->m_builds;
}

bool IntegrationPlan::noMerge()const
{
    return this->m_noMerge;
}

const QString& IntegrationPlan::security_level()const
{
    return this->m_security_level;
}

const QString& IntegrationPlan::assignees()const
{
    return this->m_assignees;
}

const QString& IntegrationPlan::pic()const
{
    return this->m_pic;
}

const QString& IntegrationPlan::sub_project()const
{
    return this->m_sub_project;
}

const QString& IntegrationPlan::label()const
{
    return this->m_label;
}

const QString& IntegrationPlan::priority()const
{
    return this->m_priority;
}

const QString& IntegrationPlan::stp_type()const
{
    return this->m_stp_type;
}

const QString& IntegrationPlan::html_code()const
{
    return this->m_html_code;
}
