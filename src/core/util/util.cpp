#include "util.h"

QUtilSTP::QUtilSTP(QObject *parent):QObject(parent)
{
}

const QString QUtilSTP::getDateDDMMYYYY(const QDate &date, QChar separator)
{
    return QString::number(date.day()) + separator + QString::number(date.month()) + separator + QString::number(date.year());
}

const QString QUtilSTP::getCurrentDateDDMMYYYY(QString separator)
{
    QDate d = QDate::currentDate();
    return QString::number(d.day()) + separator + QString::number(d.month()) + separator + QString::number(d.year());
}

const QString QUtilSTP::getCurrentDateYYYYMMDD(QString separator)
{
    QDate d = QDate::currentDate();
    return QString::number(d.year()) + separator + QString::number(d.month()) + separator + QString::number(d.day());
}

const QList<QDate> QUtilSTP::getDatesBetween(QDate A, QDate B)
{
    QList<QDate> dates;
    dates << A;
    while(A!=B)
    {
        A=A.addDays(1);
        if(A.dayOfWeek() != 6 && A.dayOfWeek() != 7)
        {
            dates << A;
        }
    }
    return dates;
}
