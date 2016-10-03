#include "TEST_001.h"

TEST_001::TEST_001(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_001";
}

bool TEST_001::executeTest()
{
    int totTestsPassed = 0;
    int totTestsFaild = 0;

    qDebug() << "###########Running: " + this->m_name + " ###########";

    qDebug() << "Components creation (HON02 build simulation)";
    ComponentSoftware amfm1("AMFM", "060.001.00", "", 0);
    ComponentSoftware cpf1("CPF", "061.001.00", "", 0);
    ComponentSoftware hdradio1("HDRADIO", "059.001.00", "", 0);
    ComponentSoftware tunutil1("TUNUTIL", "028.001.00", "", 0);

    qDebug() << "HON02 build creation";
    Build hon02("HON02_C02_001_R00", QDate(2016,10,4), Build::RELEASE, QDate(2016,10,5), QDate(2016,10,6), false, 0);
    bool isThatComponentAdded = true;
    isThatComponentAdded = hon02.addComponent(amfm1);
    isThatComponentAdded = hon02.addComponent(cpf1);
    isThatComponentAdded = hon02.addComponent(hdradio1);
    isThatComponentAdded = hon02.addComponent(tunutil1);

    qDebug() << "TEST_001.001 - adding the components to the build";
    if(isThatComponentAdded)
    {
        qDebug() << "---> passed";
        totTestsPassed++;
    }else
    {
        qDebug() << "---> faild, one or more components have not been added to the build";
        totTestsFaild++;
    }

    IntegrationPlan stpHon02Rel("HON02 Release CW", QDate(2016,10,7), QDate(2016,10,3), "54", QDate(2016,9,28), 0);

    qDebug() << "TEST_001.002 - adding the built to the stp";
    if(stpHon02Rel.addBuild(hon02))
    {
        qDebug() << "---> passed";
        totTestsPassed++;
    }else
    {
        qDebug() << "---> faild, the build has not been added to the stp";
        totTestsFaild++;
    }


    qDebug() << "TEST_001.003 - Checking the number of components";
    const int componentNumber = 4;
    int numComponentIntoTheFirstBuild = stpHon02Rel.builds().first().numComponents();
    if( numComponentIntoTheFirstBuild == componentNumber )
    {
        qDebug() << "---> passed";
        totTestsPassed++;
    }else
    {
        qDebug() << "---> faild, the number of component should be 4 but it's " + QString::number(numComponentIntoTheFirstBuild);
        totTestsFaild++;
    }

    int totTests = totTestsFaild + totTestsPassed;

    qDebug() << "Results:";
    if( totTestsFaild > 0 )
    {
        qDebug() << "Numer of failures: " + QString::number(totTestsFaild) + "/" + QString::number(totTests);
    }else
    {
        qDebug() << "Numer of tests: " + QString::number(totTestsPassed) + "/" + QString::number(totTests);
    }

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
