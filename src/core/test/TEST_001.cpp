#include "TEST_001.h"

TEST_001::TEST_001(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_001";
}

void TEST_001::executeTest()
{
    qDebug() << "###########Running: " + this->m_name + " ###########";
    qDebug() << "###########Ending : " + this->m_name + " ###########";
}

const QString& TEST_001::name()const
{
    return this->m_name;
}

TEST_001::TEST_001(const TEST_001 &other):TEST_001(other.parent())
{
    this->m_name = other.name();
}

bool TEST_001::operator==(const TEST_001 &other)
{
    if(this->m_name == other.name())
    {
        return true;
    }
    return false;
}
