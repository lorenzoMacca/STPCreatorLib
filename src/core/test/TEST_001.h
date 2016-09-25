#ifndef TEST_001_H
#define TEST_001_H

#include <QObject>
#include "TEST.h"

class TEST_001 : public TEST{
    
    Q_OBJECT
    
public:
    TEST_001(QObject *parent=0);
    const QString& name()const;
    void executeTest();

public slots:

private:
    
signals:

};

#endif
