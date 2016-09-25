#ifndef TEST_MANAGER_H
#define TEST_MANAGER_H

#include <QObject>
#include "TEST_001.h"
#include "TEST.h"
#include <QList>

class TestManager : public QObject{
    
    Q_OBJECT
    
public:
    TestManager(QObject *parent);

public slots:

private:
    QList<TEST> m_testes;
    
signals:

};

#endif
