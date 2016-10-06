#include "TEST_004.h"

TEST_004::TEST_004(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_004";
    this->m_filename="html_text_TEST_004.txt";
}

bool TEST_004::executeTest()
{

    qDebug() << "###########Running: " + this->m_name + " ###########";

    ComponentSoftware amfm("AMFM", "054.001.013", "", 0);
	ComponentSoftware hdradio("HDRADIO", "054.001.009", "", 0);
    ComponentSoftware cpf1("CPF", "040.001.011.013", "", 0);
    Build cry01_c_B2("CRY01_C06_022.002.R31", QDate(2016,10,5), Build::RELEASE, QDate(2016,10,7), QDate(2016,10,11), false, 0);
    cry01_c_B2.addComponent(amfm);
    cry01_c_B2.addComponent(hdradio);
	cry01_c_B2.addComponent(cpf1); 

	ComponentSoftware dab("DAB", "028.001.005", "", 0);
    Build cry01_b_B2("CRY01_B06_022.002.R31", QDate(2016,10,5), Build::RELEASE, QDate(2016,10,7), QDate(2016,10,11), false, 0);
    cry01_b_B2.addComponent(dab);
    cry01_b_B2.addComponent(cpf1);

	ComponentSoftware sdars("SDARS", "050.001.012", "", 0);
    Build cry01_D_B2("CRY01_D06_022.002.R31", QDate(2016,10,6), Build::RELEASE, QDate(2016,10,7), QDate(2016,10,11), false, 0);
    cry01_D_B2.addComponent(sdars);
    cry01_D_B2.addComponent(cpf1);
	
	IntegrationPlan *stpCry01B2Rel = new IntegrationPlan("SUZ01 Release CW", QDate(2016,10,11), QDate(2016,10,5), "40", QDate(2016,9,30), 0);
    stpCry01B2Rel->addBuild(cry01_c_B2);
	stpCry01B2Rel->addBuild(cry01_b_B2);
	stpCry01B2Rel->addBuild(cry01_D_B2);

    Data data(stpCry01B2Rel, this);
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

const QString& TEST_004::name()const
{
    return this->m_name;
}

TEST_004::TEST_004(const TEST_004 &other)
{
    this->setParent(other.parent());
    this->m_name = other.name();
}

bool TEST_004::operator==(const TEST_004 &other)
{
    if(this->m_name == other.name())
    {
        return true;
    }
    return false;
}
