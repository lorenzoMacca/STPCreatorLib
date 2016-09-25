#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QString>

class TEST : public QObject{

    Q_OBJECT

public:
    virtual void executeTest()=0;
    virtual const QString& name()const;

};

#endif
