#ifndef SETTING_DATA_H
#define SETTING_DATA_H

#include <QObject>
#include <QString>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QList>
#include <QDebug>
#include <QStringList>
#include <QDomDocument>
#include "../entities/component.h"
#include "../entities/integration_plan.h"

class SettingData : public QObject{

    Q_OBJECT

public:
    SettingData(QObject *parent);
    const QDir& create_stp_jira_path()const;
    const QFileInfo& create_stp_jira_name()const;
    const QString& sp_input_file_name()const;
    const QDir& sp_input_file_destination()const;
    const QFileInfo& file_listed_name()const;
    const QList<ComponentSoftware>& getComponentsSoftware()const;
    const QString& cw()const;
    const QStringList& securityLevels()const;
    const QStringList& assignees()const;
    const QStringList& pics()const;
    const QStringList& subProjects()const;
    const QStringList& stp_types()const;

public slots:

private:
    QDir      m_create_stp_jira_path;
    QFileInfo m_create_stp_jira_name;
    QString   m_sp_input_file_name;
    QDir      m_sp_input_file_destination;
    QFileInfo m_file_listed_name;
    QDomDocument m_config_file;
    QList<ComponentSoftware> m_components;
    QString m_cw;
    QStringList m_securityLevels;
    QStringList m_assignees;
    QStringList m_pics;
    QStringList m_subProjects;
    QStringList m_stp_types;

    void loadConfigFile();
    QList<ComponentSoftware> getComponentListFromDefaultList();
    void getInfoFromXmlConfigFile();
    QStringList getSecurityLevelsByDefault();
    QStringList getAssigneeByDefault();
    QStringList getPicsByDefault();
    QStringList getSubProjectsByDefault();

signals:
    void errorCinfigFile(QString message);

};

#endif
