#include "user.h"

Quser::Quser(QString username, QString password, QObject *parent)
:QObject(parent){
    this->m_username = username;
    this->m_password = password;
}

bool Quser::logIn(){
    emit userIn(this);
    return true;
}

bool Quser::logOff(){
    emit userOut(this);
    return true;
}