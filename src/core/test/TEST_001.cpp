#include "TEST_001.h"

TEST_001::TEST_001(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_001";
}

bool TEST_001::executeTest()
{
    qDebug() << "###########Running: " + this->m_name + " ###########";

    qDebug() << "Components creation (HON02 build simulation)";
    ComponentSoftware amfm1("AMFM", "060.001.00", "", 0);
    ComponentSoftware cpf1("CPF", "061.001.00", "", 0);
    ComponentSoftware hdradio1("HDRADIO", "059.001.00", "", 0);
    ComponentSoftware tunutil1("TUNUTIL", "028.001.00", "", 0);

    qDebug() << "HON02 build creation";
    Build hon02("HON02_C02_001_R00", QDate(2016,10,4), Build::RELEASE, QDate(2016,10,5), QDate(2016,10,6), false, 0);
    hon02.addComponent(amfm1);
    hon02.addComponent(cpf1);
    hon02.addComponent(hdradio1);
    hon02.addComponent(tunutil1);

    qDebug() << "HON02 ShortTermPlan creation";
    IntegrationPlan stpHon02Rel("HON02 Release CW", QDate(2016,10,7), QDate(2016,10,3), "54", QDate(2016,9,28), 0);
    stpHon02Rel.addBuild(hon02);



    qDebug() << "###########Ending : " + this->m_name + " ###########";
    return true;
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
