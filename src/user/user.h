#ifndef QUSER_H
#define QUSER_H

#include <QObject>
#include <QString>

class Quser : public QObject{
    
    Q_OBJECT
    
public:
    Quser(QString username, QString password, QObject *parent);

public slots:
    bool logIn();
    bool logOff();

private:
    QString m_username;
    QString m_password;
    
signals:
    void userIn(Quser *u);
    void userOut(Quser *u);

};

struct UserStatus {
    Quser user;
    bool isLogged;
};

#endif
