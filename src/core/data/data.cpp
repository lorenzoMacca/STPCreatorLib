#include "data.h"

Data::Data(IntegrationPlan *integration_plan, QObject *parent):QObject(parent)
{
    this->m_settingData_ptr = 0;
    this->m_integration_plan_ptr = integration_plan;
    this->initSettingData();
}

Data::Data(QObject *parent):QObject(parent)
{
    this->m_settingData_ptr = 0;
    this->m_integration_plan_ptr = new IntegrationPlan(this);
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
    QUtilSTP util(this);
    HtmlDocumentTitle *documentTitle = new HtmlDocumentTitle(this->integrationPlan()->cw(), this);
    HtmlTable *htmlTable = new HtmlTable(this);
    QDate A(this->integrationPlan()->start_date());
    QDate B(this->integrationPlan()->due_date());
    QList<QDate> datesInBetween = util.getDatesBetween(A, B);
    QListIterator<QDate> datesIter(datesInBetween);
    while(datesIter.hasNext())
    {
        QDate currentDate = datesIter.next();
        QString day = currentDate.shortDayName(currentDate.dayOfWeek());
        QString ddMm = QString::number(currentDate.day()) + "." + QString::number(currentDate.month());
        htmlTable->addColumn(new HtmlColumn(day,
                                      ddMm,
                                      this->integrationPlan()->builds(),
                                      currentDate,
                                      util.getDateDDMMYYYY(this->integrationPlan()->merge_date(), '.'),
                                      this));
    }

    HtmlDocument document(documentTitle,htmlTable,this);
    return document.getCode();

}

