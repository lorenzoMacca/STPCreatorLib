#ifndef TEST_H
#define TEST_H

#include <QObject>
#include <QString>

class TEST : public QObject{

    Q_OBJECT

public:
    TEST(QObject *parent=0);
    virtual void executeTest()=0;
    virtual const QString& name()const;

public slots:

protected:
    QString m_name;

signals:

};

#endif
