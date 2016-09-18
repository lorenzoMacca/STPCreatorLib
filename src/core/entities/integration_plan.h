#ifndef INTEGRATION_PLAN_H
#define INTEGRATION_PLAN_H

#include <QObject>
#include <QString>

class IntegrationPlan : public QObject{

    Q_OBJECT

public:
    IntegrationPlan(QObject *parent);
    static const QString RELEASE;
    static const QString DEV_DROP;

public slots:

private:

signals:

};

#endif
