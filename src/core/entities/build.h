#ifndef BUILD_H
#define BUILD_H

#include <QObject>
#include <QString>
#include <QDate>
#include <QList>
#include <QStringList>
#include "component.h"

class Build : public QObject{

    Q_OBJECT

public:
    Build(QObject *parent);
    Build(QString name, QDate start_date, QString build_type, QDate upload_date, QDate delivery_day, bool noMerge, QObject *parent);
    Build(const Build &other);

    static const QString RELEASE;
    static const QString DEV_DROP;
    static const QString ACCEPTANCE;
    static const QString DRY_RUN;
    const QString& name()const;
    const QDate& start_date()const;
    const QString& build_type()const;
    const QDate& upload_day()const;
    const QDate& delivery_day()const;
    const QString& description()const;
    bool noMerge()const;
    const QList<ComponentSoftware>& components()const;
    Build &operator=(const Build &other);
    void setName(QString &name);
    void setStartDate(QDate &start_date);
    void setBuildType(QString &build_type);
    void setUploadDay(QDate &upload_date);
    void setDeliveryDay(QDate &date);
    void setDescription(QString &description);
    void setNoMerge(bool b);
    const QStringList getBuildTypes();
    const QString toString();
    bool addComponent(ComponentSoftware &newComponent);

public slots:

private:
    QString m_name;
    QDate m_start_date;
    QString m_build_type;
    QDate m_upload_day;
    QDate m_delivery_day;
    QString m_description;
    bool m_noMerge;
    QList<ComponentSoftware> m_components;

signals:

};

#endif
