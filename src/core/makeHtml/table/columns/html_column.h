#ifndef HTML_COLUMN_H
#define HTML_COLUMN_H

#include <QObject>
#include <QString>
#include <QList>
#include <QDate>
#include <QListIterator>
#include "../../../entities/build.h"

class HtmlColumn : public QObject{
    
    Q_OBJECT
    
public:
    HtmlColumn(QString day, QString ggMm, const QList<Build>& builds, QDate date, const QString mergeDay, QObject *parent=0);
    HtmlColumn(const HtmlColumn &other);
    HtmlColumn &operator=(const HtmlColumn &other);
    QString getHeaderColumnCode();
    QString getBodyColumnCode();


public slots:

private:
    QString m_day;
    QString m_ggMM;
    QList<Build> m_builds;
    QDate m_date;
    QString m_merge_day;
    bool m_isEmpty;
    QString m_width;
    
signals:

};

#endif
