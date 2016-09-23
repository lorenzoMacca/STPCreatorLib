#ifndef QUTIL_H
#define QUTIL_H

#include <QObject>
#include <QString>
#include <QChar>
#include <QDate>

class QUtilSTP : public QObject{
    
    Q_OBJECT
    
public:
    QUtilSTP(QObject *parent);
    static const QString getDateDDMMYYYY(const QDate &date, QChar separator);
    static const QString getCurrentDateDDMMYYYY(QString separator);
    static const QString getCurrentDateYYYYMMDD(QString separator);

public slots:

private:
    
signals:

};

#endif
