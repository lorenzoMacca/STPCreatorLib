#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QDebug>
#include <QDate>
#include "../util/util.h"

class QLogger : public QObject{
    
    Q_OBJECT
    
public:
    static QLogger* getInstance(QObject *parent);
    //TODO
    void debug(QString message);

protected:
    QLogger(QObject *parent=0);
    QLogger(QFile *file, bool is_debug_mode, QObject *parent);

public slots:

private:
    static QLogger *instance;
    bool m_is_debug_mode;
    QFile *m_file_ptr;
    
signals:

};

#endif
