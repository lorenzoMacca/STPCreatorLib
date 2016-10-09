#include "TEST_005.h"

TEST_005::TEST_005(QObject *parent)
{
    this->setParent(parent);
    this->m_name = "TEST_005";
    this->m_filename="html_text_TEST_005.txt";
}

bool TEST_005::executeTest()
{

    qDebug() << "###########Running: " + this->m_name + " ###########";
    QStringList *list = new QStringList();
    *list << "A" << "B" << "B";
    //JiraSPInputFileCsv *jira_input_file = new JiraSPInputFileCsv(list, this);
    //jira_input_file->save("JiraScriptPerl/configFile/STPs.csv");
    delete list;
    qDebug() << "###########Ending : " + this->m_name + " ###########";
    return true;
}

const QString& TEST_005::name()const
{
    return this->m_name;
}

TEST_005::TEST_005(const TEST_005 &other)
{
    this->setParent(other.parent());
    this->m_name = other.name();
}

bool TEST_005::operator==(const TEST_005 &other)
{
    if(this->m_name == other.name())
    {
        return true;
    }
    return false;
}
