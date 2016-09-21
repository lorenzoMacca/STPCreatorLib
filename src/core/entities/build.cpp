#include "build.h"

const QString Build::RELEASE="release";
const QString Build::DEV_DROP="dev_drop";
const QString Build::ACCEPTANCE="acceptance";
const QString Build::DRY_RUN="dry_run";

Build::Build(QObject *parent):QObject(parent)
{

}

Build::Build(QString name, QDate start_date, QString build_type, QDate upload_date, QDate delivery_day, bool noMerge, QObject *parent)
    :QObject(parent)
{
    this->m_name = name;
    this->m_start_date = start_date;
    this->m_build_type = build_type;
    this->m_upload_day = upload_date;
    this->m_delivery_day  = delivery_day;
    this->m_noMerge = noMerge;
}

Build::Build(const Build &other):QObject(other.parent())
{
    this->m_name = other.name();
    this->m_start_date = other.start_date();
    this->m_build_type = other.build_type();
    this->m_upload_day = other.upload_day();
    this->m_delivery_day  = other.delivery_day();
    this->m_noMerge = other.noMerge();
}

Build& Build::operator=(const Build &other)
{
    this->m_name = other.name();
    this->m_start_date = other.start_date();
    this->m_build_type = other.build_type();
    this->m_upload_day = other.upload_day();
    this->m_delivery_day  = other.delivery_day();
    this->m_noMerge = other.noMerge();
    return *this;
}

const QString& Build::name()const
{
    return this->m_name;
}

const QDate& Build::start_date()const
{
    return this->m_start_date;
}

const QString& Build::build_type()const
{
    return this->m_build_type;
}

const QDate& Build::upload_day()const
{
    return this->m_upload_day;
}

const QDate& Build::delivery_day()const
{
    return this->m_delivery_day;
}

const QString& Build::description()const
{
    return this->m_description;
}

bool Build::noMerge()const
{
    return this->m_noMerge;
}

const QList<ComponentSoftware>& Build::components()const
{
    return this->m_components;
}

void Build::setName(QString &name)
{
    this->m_name = name;
}

void Build::setStartDate(QDate &start_date)
{
    this->m_start_date = start_date;
}

void Build::setBuildType(QString &build_type)
{
    this->m_build_type = build_type;
}

void Build::setUploadDay(QDate &upload_date)
{
    this->m_upload_day = upload_date;
}

void Build::setDeliveryDay(QDate &date)
{
    this->m_delivery_day = date;
}

void Build::setDescription(QString &description)
{
    this->m_description = description;
}

void Build::setNoMerge(bool b)
{
    this->m_noMerge = b;
}

const QStringList Build::getBuildTypes()
{
    QStringList buildTypes;
    buildTypes << Build::RELEASE << Build::DEV_DROP << Build::ACCEPTANCE << Build::DRY_RUN;
    return buildTypes;
}

const QString Build::toString()
{
    return "Build [" + this->m_name + " " +
            this->m_build_type + " " +
            this->m_start_date.toString() + " " +
            this->m_upload_day.toString() + " " +
            this->m_delivery_day.toString() + " " +
            this->m_noMerge + " ]";
}

bool Build::addComponent(ComponentSoftware &newComponent)
{
    QListIterator<ComponentSoftware> compIter(this->components());
    while(compIter.hasNext())
    {
        ComponentSoftware component = compIter.next();
        if(component == newComponent)
        {
            return false;
        }
    }
    this->m_components.append(newComponent);
    return true;
}
