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
