#include "component.h"

ComponentSoftware::ComponentSoftware(QString name, QString version, QString description, QObject *parent):QObject(parent)
{
    this->m_name=name;
    this->m_version=version;
    this->m_description=description;
}

const QString& ComponentSoftware::name()const
{
    return this->m_name;
}

const QString& ComponentSoftware::version()const
{
    return this->m_version;
}

const QString& ComponentSoftware::description()const
{
    return this->m_description;
}

ComponentSoftware::ComponentSoftware(const ComponentSoftware &other):QObject(other.parent())
{
    this->m_name = other.name();
    this->m_version = other.version();
    this->m_description = other.description();
}

ComponentSoftware& ComponentSoftware::operator=(const ComponentSoftware &other)
{
    this->m_name = other.name();
    this->m_version = other.version();
    this->m_description = other.description();
    return *this;
}
