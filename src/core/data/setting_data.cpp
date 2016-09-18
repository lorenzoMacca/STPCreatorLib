#include "setting_data.h"

SettingData::SettingData(QObject *parent):QObject(parent)
{
    qDebug() << "Initialize Setting data instance";
    this->m_create_stp_jira_path=QDir("jiraScriptPerl");
    this->m_create_stp_jira_name=QFileInfo("jiraScriptPerl/starter.cmd");
    this->m_sp_input_file_name=QFileInfo("configFile/STPs.csv");
    this->m_sp_input_file_destination=QDir("jiraScriptPerl");
    this->m_file_listed_name=QFileInfo("config/configFile.xml");
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
        this->m_components = this->getComponentListFromDefaultList();
        //TODO inserire un signal
        return;
    }
    QFile xmlFile(this->m_file_listed_name.absoluteFilePath());
    if(!xmlFile.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << this->m_file_listed_name.absoluteFilePath() << "not found";
        this->m_components = this->getComponentListFromDefaultList();
        //TODO inserire un signal
        return;
    }
    if(!this->m_config_file.setContent(&xmlFile))
    {
        qDebug() << this->m_file_listed_name.absoluteFilePath() << "is not an xml or it is corrupted";
        xmlFile.close();
        this->m_components = this->getComponentListFromDefaultList();
        //TODO inserire un signal
        return;
    }
    xmlFile.close();
    this->m_components = this->getComponentListFromXmlFile();
}

QList<ComponentSoftware> SettingData::getComponentListFromDefaultList()
{
    QList<ComponentSoftware>components;
    ComponentSoftware amfm(QString("AMFM"), QString("061.000.000"), QString(""), this);
    ComponentSoftware hd(QString("HDRADIO"), QString("061.000.000"), QString(""), this);
    ComponentSoftware dab(QString("DAB"), QString("061.000.000"), QString(""), this);
    ComponentSoftware drm(QString("DRM"), QString("061.000.000"), QString(""), this);
    ComponentSoftware sdars(QString("SDARS"), QString("061.000.000"), QString(""), this);
    ComponentSoftware tunutil(QString("TUNUTIL"), QString("061.000.000"), QString(""), this);
    ComponentSoftware cpf(QString("CPF"), QString("061.000.000"), QString(""), this);
    ComponentSoftware audio(QString("AUDIO"), QString("061.000.000"), QString(""), this);
    ComponentSoftware gra_amfmhd(QString("GRA_AMFMHD"), QString("061.000.000"), QString(""), this);
    ComponentSoftware gra_dab(QString("GRA_DAB"), QString("061.000.000"), QString(""), this);
    ComponentSoftware gra_sdars(QString("GRA_SDARS"), QString("061.000.000"), QString(""), this);
    ComponentSoftware gra_if(QString("GRA_IF"), QString("061.000.000"), QString(""), this);
    ComponentSoftware gra_mstr(QString("GRA_MSTR"), QString("061.000.000"), QString(""), this);
    components<<amfm;
    components<<hd;
    components<<dab;
    components<<drm;
    components<<sdars;
    components<<tunutil;
    components<<cpf;
    components<<audio;
    components<<gra_amfmhd;
    components<<gra_dab;
    components<<gra_if;
    components<<gra_mstr;
    components<<gra_sdars;
    return components;
}

QList<ComponentSoftware> SettingData::getComponentListFromXmlFile()
{
    QList<ComponentSoftware>components;
    QDomElement documentElement = this->m_config_file.documentElement();
    QDomNode node = documentElement.firstChild();
    while(!node.isNull())
    {
        if(node.isElement())
        {
            QDomElement element = node.toElement();
            qDebug() << "Element " << element.tagName();
            QString attributeName = element.attribute("name", "not set");
            qDebug() << "attribute name " << attributeName;
            if(attributeName == "components"){
                QDomNode nodeComponents = element.firstChild();
                while(!nodeComponents.isNull())
                {
                    if(nodeComponents.isElement())
                    {
                        QDomElement elementComponent = nodeComponents.toElement();
                        QString attributeNameComponent = elementComponent.attribute("name", "not set");
                        QString attributeVersionComponent = elementComponent.attribute("version", "not set");
                        QString attributeDescriptionComponent = elementComponent.attribute("description", "not set");
                        qDebug() << attributeNameComponent << " " << attributeVersionComponent;
                        components.append(ComponentSoftware(attributeNameComponent, attributeVersionComponent, attributeDescriptionComponent, this));
                    }
                    nodeComponents = nodeComponents.nextSibling();
                }
            }
        }
        if(node.isText())
        {
            QDomText text = node.toText();
            qDebug() << text.data();
        }
        node = node.nextSibling();
    }
    return components;
}

const QList<ComponentSoftware>& SettingData::getComponentsSoftware()const
{
    return this->m_components;
}


