#ifndef DATA_H
#define DATA_H

#include <QObject>
#include <QList>
#include "setting_data.h"
#include "../entities/integration_plan.h"

class Data : public QObject{

    Q_OBJECT

public:
    static Data* getInstance();

protected:
    Data(QObject *parent);

public slots:

private:
    static Data *instance;
    IntegrationPlan *m_intgeration_plan_ptr;
    SettingData *m_settingData_ptr;

signals:

};

#endif
