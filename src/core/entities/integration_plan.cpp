#include "integration_plan.h"

const QString IntegrationPlan::RELEASE="release";
const QString IntegrationPlan::DEV_DROP="dev_drop";

IntegrationPlan::IntegrationPlan(QObject *parent):QObject(parent)
{
    this->clearIntegrationPLan();
}

IntegrationPlan::IntegrationPlan(QString summary, QDate due_date, QDate start_date, QString cw, QDate merge_date, QObject *parent)
:QObject(parent)
{
    this->clearIntegrationPLan();
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

QList<Build>& IntegrationPlan::buildsMod()
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

void IntegrationPlan::setSummary(QString s)
{
    this->m_summary = s;
}

void IntegrationPlan::setDueDate(QDate d)
{
    this->m_due_date = d;
}

void IntegrationPlan::setStartDate(QDate d)
{
    this->m_start_date = d;
}

void IntegrationPlan::setCw(QString s)
{
    this->m_cw = s;
}

void IntegrationPlan::setMergeDate(QDate d)
{
    this->m_merge_date = d;
}

void IntegrationPlan::setNoMerge(bool b)
{
    this->m_noMerge = b;
}

void IntegrationPlan::setSecurityLevel(QString s)
{
    this->m_security_level = s;
}

void IntegrationPlan::setAssignees(QString s)
{
    this->m_assignees = s;
}

void IntegrationPlan::setPic(QString s)
{
    this->m_pic = s;
}

void IntegrationPlan::setSubProject(QString s)
{
    this->m_sub_project = s;
}

void IntegrationPlan::setLabel(QString s)
{
    this->m_label = s;
}

void IntegrationPlan::setPriority(QString s)
{
    this->m_priority = s;
}

void IntegrationPlan::setStpType(QString s)
{
    this->m_stp_type = s;
}

void IntegrationPlan::setHtmlCode(QString s)
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

/*return -1 for d1 ; 1 for d2 ; 0 d1==d2*/
int IntegrationPlan::compareDate(QDate d1, QDate d2)
{
    if( d1 == d2 )
    {
        return 0;
    }else if( d1 > d2 ){
        return -1;
    }
    return 1;
}

const QDate IntegrationPlan::getRealDueDate()
{
    QDate dateOfTheLastBuild;
    bool isInit = false;
    QListIterator<Build> buildsIter(this->m_builds);
    while(buildsIter.hasNext())
    {
        QDate currentDate = buildsIter.next().delivery_day();
        if(!isInit)
        {
            dateOfTheLastBuild = currentDate;
        }else
        {
            int compareResult = this->compareDate(dateOfTheLastBuild, currentDate);
            if(compareResult == 1)
            {
                dateOfTheLastBuild = currentDate;
            }
        }
    }
    return dateOfTheLastBuild;
}

const QDate IntegrationPlan::getRealStartDate()
{
    QDate dateOfTheFirstBuild;
    bool isInit = false;
    QListIterator<Build> buildsIter(this->m_builds);
    while(buildsIter.hasNext())
    {
        QDate currentDate = buildsIter.next().start_date();
        if(!isInit)
        {
            dateOfTheFirstBuild = currentDate;
        }else
        {
            int compareResult = this->compareDate(dateOfTheFirstBuild, currentDate);
            if(compareResult == -1)
            {
                dateOfTheFirstBuild = currentDate;
            }
        }
    }
    return dateOfTheFirstBuild;
}

const QString IntegrationPlan::toString()
{
    return "IntegrationPlan [" +
            this->m_summary + " " +
            this->m_due_date.toString() + " " +
            this->m_start_date.toString() + " " +
            this->m_merge_date.toString() + " " +
            this->m_cw + " " +
            "NumBuild: " + this->numBuils() + " " +
            this->m_security_level + " " +
            this->m_assignees + " " +
            this->m_pic + " " +
            this->m_sub_project + " " +
            this->m_label + " " +
            this->m_priority + " " +
            this->m_stp_type + " ]";
}

bool IntegrationPlan::checkIntegrationPlan()const
{
    if( this->m_summary == "" )
    {
        return false;
    }
    if( this->m_due_date.isNull() ){
        return false;
    }
    if( this->m_start_date.isNull() ){
        return false;
    }
    if( this->m_cw == "" ){
        return false;
    }
    if( this->numBuils() == 0 ){
        return false;
    }
    if( this->m_security_level == "" ){
        return false;
    }
    if( this->m_assignees == "" ){
        return false;
    }
    if( this->m_pic == "" ){
        return false;
    }
    if( this->m_sub_project == "" ){
        return false;
    }

    return true;
}

void IntegrationPlan::clearIntegrationPLan()
{
    this->m_summary = "";
    this->m_due_date = QDate::currentDate();
    this->m_start_date = QDate::currentDate();
    this->m_cw = QString::number(QDate::currentDate().weekNumber());
    this->m_merge_date = QDate::currentDate();
    this->m_noMerge = false;
    this->m_security_level = "";
    this->m_assignees = "";
    this->m_pic = "";
    this->m_sub_project = "";
    this->m_label = "";
    this->m_priority = "";
    this->m_stp_type = "";
}
