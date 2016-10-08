#ifndef TEST_005_H
#define TEST_005_H

#include <QObject>
#include "TEST.h"
#include <QDebug>
#include <QDate>
#include "../jiraConnection/JiraSPInputFileCsv.h"
#include "../data/data.h"


class TEST_005 : public TEST{
    
    Q_OBJECT
    
public:
    TEST_005(QObject *parent=0);
    TEST_005(const TEST_005 &other);
    const QString& name()const;
    bool executeTest();
    bool operator==(const TEST_005 &other);

public slots:

private:
    QString m_name;
    QString m_filename;
    
signals:

};

#endif
