#ifndef TEST_001_H
#define TEST_001_H

#include <QObject>
#include "TEST.h"
#include <QDebug>
#include <QDate>
#include "../entities/component.h"
#include "../entities/build.h"
#include "../entities/integration_plan.h"

class TEST_001 : public TEST{
    
    Q_OBJECT
    
public:
    TEST_001(QObject *parent=0);
    TEST_001(const TEST_001 &other);
    const QString& name()const;
    bool executeTest();
    bool operator==(const TEST_001 &other);

public slots:

private:
    QString m_name;
    
signals:

};

#endif
