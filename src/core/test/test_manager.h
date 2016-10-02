#ifndef TEST_MANAGER_H
#define TEST_MANAGER_H

#include <QObject>
#include <QListIterator>
#include "TEST_001.h"
#include "TEST.h"
#include <QList>

class TestManager : public QObject{
    
    Q_OBJECT
    
public:
    TestManager(QObject *parent);
    bool executeAllTestes();

public slots:

private:
    QList<TEST*> m_testes;
    
signals:

};

#endif
