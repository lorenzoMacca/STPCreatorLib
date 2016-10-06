#ifndef TEST_004_H
#define TEST_004_H

#include <QObject>
#include "TEST.h"
#include <QDebug>
#include <QDate>
#include "../data/data.h"
#include "../entities/component.h"
#include "../entities/build.h"
#include "../entities/integration_plan.h"
#include "../util/util.h"

class TEST_004 : public TEST{
    
    Q_OBJECT
    
public:
    TEST_004(QObject *parent=0);
    TEST_004(const TEST_004 &other);
    const QString& name()const;
    bool executeTest();
    bool operator==(const TEST_004 &other);

public slots:

private:
    QString m_name;
    QString m_filename;
    
signals:

};

#endif
