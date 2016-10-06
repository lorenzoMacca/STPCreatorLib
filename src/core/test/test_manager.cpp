#include "test_manager.h"

TestManager::TestManager(QObject *parent)
:QObject(parent)
{
    TEST_001 *test001 = new TEST_001(this->parent());
    TEST_002 *test002 = new TEST_002(this->parent());
	TEST_003 *test003 = new TEST_003(this->parent());
	TEST_004 *test004 = new TEST_004(this->parent());
    this->m_testes.append(test001);
    this->m_testes.append(test002);
	this->m_testes.append(test003);
	this->m_testes.append(test004);
}

bool TestManager::executeAllTestes()
{
    QListIterator<TEST*> testIter(this->m_testes);
    while(testIter.hasNext())
    {
        TEST* currentTest = testIter.next();
        if(currentTest->executeTest() == false)
        {
            return false;
        }
    }
    return true;
}
