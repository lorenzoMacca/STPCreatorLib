#ifndef TEST_002_H
#define TEST_002_H

#include <QObject>
#include "TEST.h"
#include <QDebug>
#include <QDate>
#include "../data/data.h"
#include "../entities/component.h"
#include "../entities/build.h"
#include "../entities/integration_plan.h"
#include "../util/util.h"
#include "../jiraConnection/CreateJiraSPTInputFileCsv.h"
#include "../jiraConnection/JiraSPInputFileCsv.h"

class TEST_002 : public TEST{
    
    Q_OBJECT
    
public:
    TEST_002(QObject *parent=0);
    TEST_002(const TEST_002 &other);
    const QString& name()const;
    bool executeTest();
    bool operator==(const TEST_002 &other);

public slots:

private:
    QString m_name;
    QString m_filename;
    
signals:

};

#endif
