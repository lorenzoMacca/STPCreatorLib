#include "util.h"

QUtilSTP::QUtilSTP(QObject *parent):QObject(parent)
{
}

const QString QUtilSTP::getDateDDMMYYYY(const QDate &date, QChar separator)
{
    return QString::number(date.day()) + separator + QString::number(date.month()) + separator + QString::number(date.year());
}

const QString QUtilSTP::getCurrentDate(QString separator)
{
    QDate d = QDate::currentDate();
    return QString::number(d.day()) + separator + QString::number(d.month()) + separator + QString::number(d.day());
}
