#include "logger.h"

QLogger *instance = 0;

QLogger::QLogger(QObject *parent):QObject(parent)
{
    this->m_is_debug_mode = true;
}

QLogger::QLogger(QFile *file, bool is_debug_mode, QObject *parent):QObject(parent)
{
    this->m_is_debug_mode = is_debug_mode;
    this->m_file_ptr = file;
}

void QLogger::debug(QString message)
{
    qDebug() << "[" << QUtilSTP::getCurrentDate(" - ") << "]" << message;
}

QLogger* QLogger::getInstance(QObject *parent)
{
    if( instance == 0 )
    {
        instance = new QLogger(parent);
    }
    return instance;
}
