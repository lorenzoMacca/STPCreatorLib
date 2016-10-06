#ifndef TEST_003_H
#define TEST_003_H

#include <QObject>
#include "TEST.h"
#include <QDebug>
#include <QDate>
#include "../data/data.h"
#include "../entities/component.h"
#include "../entities/build.h"
#include "../entities/integration_plan.h"
#include "../util/util.h"

class TEST_003 : public TEST{
    
    Q_OBJECT
    
public:
    TEST_003(QObject *parent=0);
    TEST_003(const TEST_003 &other);
    const QString& name()const;
    bool executeTest();
    bool operator==(const TEST_003 &other);

public slots:

private:
    QString m_name;
    QString m_filename;
    
signals:

};

#endif
