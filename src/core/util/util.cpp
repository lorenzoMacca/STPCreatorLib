#include "util.h"

QUtilSTP::QUtilSTP(QObject *parent):QObject(parent)
{
}

const QString QUtilSTP::getDateDDMMYYYY(const QDate &date, QChar separator)
{
    QString day = QString::number(date.day());
    QString month = QString::number(date.month());
    QString year = QString::number(date.year());

    if(date.day() < 10)
    {
        day = QString('0') + day;
    }

    if(date.month() < 10)
    {
        month = QString('0') + month;
    }

    return day + separator + month + separator + year;
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
