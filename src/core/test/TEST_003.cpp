#include "TEST_003.h"

TEST_003::TEST_003(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_003";
    this->m_filename="html_text_TEST_003.txt";
}

bool TEST_003::executeTest()
{

    qDebug() << "###########Running: " + this->m_name + " ###########";

    ComponentSoftware drm("DRM", "028.001.005", "", 0);
    ComponentSoftware cpf1("CPF", "063.001.005", "", 0);
    Build suz01_h("SUZ01_H04_031.002.R05", QDate(2016,9,30), Build::RELEASE, QDate(2016,10,4), QDate(2016,10,6), false, 0);
    suz01_h.addComponent(drm);
    suz01_h.addComponent(cpf1);  
	
	IntegrationPlan *stpSuz2Rel = new IntegrationPlan("SUZ01 Release CW", QDate(2016,10,6), QDate(2016,9,29), "40", QDate(2016,9,28), 0);
    stpSuz2Rel->addBuild(suz01_h);

    Data data(stpSuz2Rel, this);
    QString htmlOut = data.getHTMLCode();
    qDebug() << htmlOut;

    QFile file( this->m_filename );
    if ( file.open(QIODevice::ReadWrite) )
    {
        QTextStream stream( &file );
        stream << htmlOut << endl;
    }

    qDebug() << "###########Ending : " + this->m_name + " ###########";
    return true;
}

const QString& TEST_003::name()const
{
    return this->m_name;
}

TEST_003::TEST_003(const TEST_003 &other)
{
    this->setParent(other.parent());
    this->m_name = other.name();
}

bool TEST_003::operator==(const TEST_003 &other)
{
    if(this->m_name == other.name())
    {
        return true;
    }
    return false;
}
