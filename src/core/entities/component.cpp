#include "component.h"

ComponentSoftware::ComponentSoftware(QString name, QString version, QString description, QObject *parent):QObject(parent)
{
    this->m_name=name;
    this->m_version=version;
    this->m_description=description;
}
