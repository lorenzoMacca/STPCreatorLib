#include "util.h"

QUtilSTP::QUtilSTP(QObject *parent):QObject(parent)
{
}

const QString QUtilSTP::getDateDDMMYYYY(QDate date, QChar separator)
{
    return date.day() + separator + date.month() + separator + date.year();
}
