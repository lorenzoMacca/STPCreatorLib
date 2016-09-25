#include "TEST_001.h"

TEST_001::TEST_001(QObject *parent)
:TEST(parent)
{
    this->m_name = "TEST_001";
}

void TEST_001::executeTest()
{

}

const QString& TEST_001::name()const
{
    return this->m_name;
}
