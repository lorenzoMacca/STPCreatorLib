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

void IntegrationPlan::setSummary(QString& s)
{
    this->m_summary = s;
}

void IntegrationPlan::setDueDate(QDate& d)
{
    this->m_due_date = d;
}

void IntegrationPlan::setStartDate(QDate& d)
{
    this->m_start_date = d;
}

void IntegrationPlan::setCw(QString& s)
{
    this->m_cw = s;
}

void IntegrationPlan::setMergeDate(QDate& d)
{
    this->m_merge_date = d;
}

void IntegrationPlan::setNoMerge(bool b)
{
    this->m_noMerge = b;
}

void IntegrationPlan::setSecurityLevel(QString& s)
{
    this->m_security_level = s;
}

void IntegrationPlan::setAssignees(QString& s)
{
    this->m_assignees = s;
}

void IntegrationPlan::setPic(QString& s)
{
    this->m_pic = s;
}

void IntegrationPlan::setSubProject(QString& s)
{
    this->m_sub_project = s;
}

void IntegrationPlan::setLabel(QString& s)
{
    this->m_label = s;
}

void IntegrationPlan::setPriority(QString& s)
{
    this->m_priority = s;
}

void IntegrationPlan::setStpType(QString& s)
{
    this->m_stp_type = s;
}

void IntegrationPlan::setHtmlCode(QString& s)
{
    this->m_html_code = s;
}

bool IntegrationPlan::addBuild(Build &newBuild)
{
    QListIterator<Build> iter(this->m_builds);
    while(iter.hasNext())
    {
        Build b = iter.next();
        if( b == newBuild )
        {
            return false;
        }
    }
    this->m_builds.append(newBuild);
    return true;
}

int IntegrationPlan::numBuils()const
{
    return this->m_builds.size();
}
