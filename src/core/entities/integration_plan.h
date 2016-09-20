#ifndef INTEGRATION_PLAN_H
#define INTEGRATION_PLAN_H

#include <QObject>
#include <QString>
#include <QDate>
#include <QList>
#include "build.h"

class IntegrationPlan : public QObject{

    Q_OBJECT

public:
    IntegrationPlan(QObject *parent);
    IntegrationPlan(QString summary, QDate due_date, QDate start_date, QString cw, QDate merge_date, QObject *parent);
    static const QString RELEASE;
    static const QString DEV_DROP;
    //todo
    const QString toString();
    const QString getDateDDMMYYYY(QDate date);
    const QDate getRealStartDate(); /*giono della prima attività*/
    const QDate getRealDueDate();   /*giorno dell'ultima attività*/
    bool checkIntegrationPlan();
    int compareDate(QDate d1, QDate d2); /*return -1 for d1 ; 1 for d2 ; 0 d1==d2*/

public slots:

private:
    QString m_summary;
    QDate m_due_date;
    QDate m_start_date;
    QString m_cw;
    QDate m_merge_date;
    QList<Build> m_builds;
    bool m_noMerge;
    QString m_security_level;
    QString m_assignees;
    QString m_pic;
    QString sub_project;
    QString m_label;
    QString m_priority;
    QString m_stp_type;
    QString m_html_code;

signals:

};

#endif
