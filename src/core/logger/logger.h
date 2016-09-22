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
    QLogger(QObject *parent);
    QLogger(QFile *file, bool is_debug_mode, QObject *parent);
    //TODO
    void debug(QString message);

public slots:

private:
    bool m_is_debug_mode;
    QFile *m_file_ptr;
    
signals:

};

#endif
