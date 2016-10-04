#ifndef DATA_H
#define DATA_H

#include <QObject>
#include <QList>
#include <QDate>
#include "setting_data.h"
#include "../entities/integration_plan.h"
#include "../makeHtml/document/html_document.h"
#include "../makeHtml/document/html_document_title.h"
#include "../makeHtml/table/html_table.h"
#include "../makeHtml/table/columns/html_column.h"
#include "../util/util.h"

class Data : public QObject{

    Q_OBJECT

public:
    Data(IntegrationPlan *integration_plan, QObject *parent);
    void initSettingData();
    SettingData* settingData();
    IntegrationPlan* integrationPlan();
    void removeIntegrationPlan();
    void setIntegrationPlan(IntegrationPlan *integration_plan);
    //TODO
    const QString getHTMLCode();


public slots:

private:
    IntegrationPlan *m_integration_plan_ptr;
    SettingData *m_settingData_ptr;

signals:

};

#endif
