#include "setting_data.h"

SettingData::SettingData(QObject *parent):QObject(parent)
{
    qDebug() << "Initialize Setting data instance";
    this->m_create_stp_jira_path=QDir("jiraScriptPerl");
    this->m_create_stp_jira_name=QFileInfo("jiraScriptPerl/starter.cmd");
    this->m_sp_input_file_name=QFileInfo("configFile/STPs.csv");
    this->m_sp_input_file_destination=QDir("jiraScriptPerl");
    this->m_file_listed_name=QFileInfo("conf/components.xml");
    this->loadConfigFile();
    qDebug() << "Setting data instance inizialized";
}

const QDir& SettingData::create_stp_jira_path()const
{
    return this->m_create_stp_jira_path;
}

const QFileInfo& SettingData::create_stp_jira_name()const
{
    return this->m_create_stp_jira_name;
}

const QFileInfo& SettingData::sp_input_file_name()const
{
    return this->m_sp_input_file_name;
}

const QDir& SettingData::sp_input_file_destination()const
{
    return this->m_sp_input_file_destination;
}

const QFileInfo& SettingData::file_listed_name()const
{
    return this->m_file_listed_name;
}

void SettingData::loadConfigFile()
{
    if(!this->m_file_listed_name.exists() || !this->m_file_listed_name.isFile())
    {
        qDebug() << this->m_file_listed_name.absoluteFilePath() << "not found";
        //TODO inserire un signal
        return;
    }
    QFile xmlFile(this->m_file_listed_name.absoluteFilePath());
    if(!xmlFile.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << this->m_file_listed_name.absoluteFilePath() << "not found";
        //TODO inserire un signal
        return;
    }
    if(!this->m_config_file.setContent(&xmlFile))
    {
        qDebug() << this->m_file_listed_name.absoluteFilePath() << "is not an xml or it is corrupted";
        xmlFile.close();
        //TODO inserire un signal
        return;
    }
    xmlFile.close();
    this->m_components = this->getComponentListFromDefaultList();
}

QList<ComponentSoftware> SettingData::getComponentListFromDefaultList()
{
    QList<ComponentSoftware>components;
    ComponentSoftware amfm(QString("AMFM"), QString("061.000.000"), QString(""), this);
    components<<amfm;
    return components;
}


