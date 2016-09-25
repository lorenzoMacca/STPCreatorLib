#include "test_manager.h"

TestManager::TestManager(QObject *parent)
:QObject(parent)
{
    TEST_001 *test001 = new TEST_001(this->parent());
    this->m_testes.append(test001);
}


