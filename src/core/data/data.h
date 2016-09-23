#ifndef DATA_H
#define DATA_H

#include <QObject>
#include <QList>
#include "setting_data.h"
#include "../entities/integration_plan.h"

class Data : public QObject{

    Q_OBJECT

public:
    Data(IntegrationPlan *integration_plan, QObject *parent);
    void initSettingData();
    SettingData* settingData();
    IntegrationPlan* integrationPlan();
    void removeIntegrationPlan();
    void setIntegrationPlan(IntegrationPlan *integration_plan);

public slots:

private:
    IntegrationPlan *m_integration_plan_ptr;
    SettingData *m_settingData_ptr;

signals:

};

#endif
