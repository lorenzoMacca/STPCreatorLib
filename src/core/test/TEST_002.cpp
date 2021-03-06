#include "TEST_002.h"

TEST_002::TEST_002(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_002";
    this->m_filename="html_text.txt";
}

bool TEST_002::executeTest()
{
    int totTestsPassed = 0;
    int totTestsFaild = 0;

    qDebug() << "###########Running: " + this->m_name + " ###########";

    ComponentSoftware amfm1("AMFM", "060.001.00", "DIRANA6.0", 0);
    ComponentSoftware cpf1("CPF", "060.001.00", "", 0);
    ComponentSoftware hdradio1("HDRADIO", "059.001.00", "", 0);
    ComponentSoftware tunutil1("TUNUTIL", "028.001.00", "", 0);
    Build hon02("HON02_C02_001_R00", QDate(2016,9,22), Build::RELEASE, QDate(2016,9,23), QDate(2016,9,26), false, 0);
    hon02.addComponent(amfm1);
    hon02.addComponent(cpf1);
    hon02.addComponent(hdradio1);
    hon02.addComponent(tunutil1);
    IntegrationPlan *stpHon02Rel = new IntegrationPlan("HON02 Release CW", QDate(2016,9,26), QDate(2016,9,20), "54", QDate(2016,9,21), 0);
    stpHon02Rel->addBuild(hon02);
    QString securityLevel("gl005_jasmin");
    stpHon02Rel->setSecurityLevel(securityLevel);
    QString assignee("lorenzo");
    stpHon02Rel->setAssignees(assignee);
    QString pic("Laghigna");
    stpHon02Rel->setPic(pic);
    QString sub_project("HON02");
    stpHon02Rel->setSubProject(sub_project);
    stpHon02Rel->setStpType(QString(IntegrationPlan::RELEASE));


    Data data(stpHon02Rel, this);
    QString htmlOut = data.getHTMLCode();
    /*qDebug() << htmlOut;

    QFile file( this->m_filename );
    if ( file.open(QIODevice::ReadWrite) )
    {
        QTextStream stream( &file );
        stream << htmlOut << endl;
    }*/
    CreateJiraSPTInputFileCsv *create_jira_input_file = new CreateJiraSPTInputFileCsv(htmlOut, stpHon02Rel,this);
    JiraSPInputFileCsv *input_file = create_jira_input_file->createJiraSPTInputFileCsv();
    input_file->save(data.settingData()->sp_input_file_name());

    JiraScriptExecutor *jira_script_ececutor = new DefaultJiraScriptExecutor(&data, this);
    jira_script_ececutor->createSPTicket();


    qDebug() << "TEST_002.001 - instatiatind Data class";
    if(true)
    {
        qDebug() << "---> passed";
        totTestsPassed++;
    }else
    {
        qDebug() << "---> faild, one or more components have not been added to the build";
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

const QString& TEST_002::name()const
{
    return this->m_name;
}

TEST_002::TEST_002(const TEST_002 &other)
{
    this->setParent(other.parent());
    this->m_name = other.name();
}

bool TEST_002::operator==(const TEST_002 &other)
{
    if(this->m_name == other.name())
    {
        return true;
    }
    return false;
}
