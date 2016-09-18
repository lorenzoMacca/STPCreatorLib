#ifndef SETTING_DATA_H
#define SETTING_DATA_H

#include <QObject>
#include <QString>
#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QList>
#include <QDebug>
#include <QDomDocument>
#include "../entities/component.h"

class SettingData : public QObject{

    Q_OBJECT

public:
    SettingData(QObject *parent);
    const QDir& create_stp_jira_path()const;
    const QFileInfo& create_stp_jira_name()const;
    const QFileInfo& sp_input_file_name()const;
    const QDir& sp_input_file_destination()const;
    const QFileInfo& file_listed_name()const;
    const QList<ComponentSoftware>& getComponentsSoftware()const;

public slots:

private:
    QDir      m_create_stp_jira_path;
    QFileInfo m_create_stp_jira_name;
    QFileInfo m_sp_input_file_name;
    QDir      m_sp_input_file_destination;
    QFileInfo m_file_listed_name;
    QDomDocument m_config_file;
    QList<ComponentSoftware> m_components;

    void loadConfigFile();
    QList<ComponentSoftware> getComponentListFromDefaultList();
    QList<ComponentSoftware> getComponentListFromXmlFile();

signals:

};

#endif
