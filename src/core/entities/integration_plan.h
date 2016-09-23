#ifndef INTEGRATION_PLAN_H
#define INTEGRATION_PLAN_H

#include <QObject>
#include <QString>
#include <QDate>
#include <QList>
#include <QChar>
#include <QListIterator>
#include <QListIterator>
#include "build.h"
#include "../logger/logger.h"

class IntegrationPlan : public QObject{

    Q_OBJECT

public:
    IntegrationPlan(QObject *parent);
    IntegrationPlan(QString summary, QDate due_date, QDate start_date, QString cw, QDate merge_date, QObject *parent);
    /*IntegrationPlan(const IntegrationPlan &other);
    IntegrationPlan &operator=(const IntegrationPlan &other);*/
    static const QString RELEASE;
    static const QString DEV_DROP;
    //get
    const QString& summary()const;
    const QDate& due_date()const;
    const QDate& start_date()const;
    const QString& cw()const;
    const QDate& merge_date()const;
    const QList<Build>& builds()const;
    bool noMerge()const;
    const QString& security_level()const;
    const QString& assignees()const;
    const QString& pic()const;
    const QString& sub_project()const;
    const QString& label()const;
    const QString& priority()const;
    const QString& stp_type()const;
    const QString& html_code()const;
    //set
    void setSummary(QString& s);
    void setDueDate(QDate& d);
    void setStartDate(QDate& d);
    void setCw(QString& s);
    void setMergeDate(QDate& d);
    void setNoMerge(bool b);
    void setSecurityLevel(QString& s);
    void setAssignees(QString& s);
    void setPic(QString& s);
    void setSubProject(QString& s);
    void setLabel(QString& s);
    void setPriority(QString& s);
    void setStpType(QString& s);
    void setHtmlCode(QString& s);

    int compareDate(QDate d1, QDate d2); /*return -1 for d1 ; 1 for d2 ; 0 d1==d2*/
    bool addBuild(Build &newBuild);
    int numBuils()const;
    const QDate getRealStartDate(); /*giono della prima attività*/
    const QDate getRealDueDate();   /*giorno dell'ultima attività*/
    const QString toString();
    bool checkIntegrationPlan()const;
    //todo




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
    QString m_sub_project;
    QString m_label;
    QString m_priority;
    QString m_stp_type;
    QString m_html_code;

signals:

};

#endif
