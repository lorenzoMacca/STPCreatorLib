#include "test_manager.h"

TestManager::TestManager(QObject *parent)
:QObject(parent)
{
    TEST_001 *test001 = new TEST_001(this->parent());
    this->m_testes.append(test001);
}

void TestManager::executeAllTestes()
{
    QListIterator<TEST*> testIter(this->m_testes);
    while(testIter.hasNext())
    {
        TEST* currentTest = testIter.next();
        currentTest->executeTest();
    }
}
