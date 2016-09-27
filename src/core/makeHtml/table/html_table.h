#ifndef HTML_TABLE_H
#define HTML_TABLE_H

#include <QObject>
#include <QString>
#include <QList>
#include <QListIterator>
#include "columns/html_column.h"

class HtmlTable : public QObject{
    
    Q_OBJECT
    
public:
    HtmlTable(QObject *parent=0);
    QString getCode();
    bool addColumn(HtmlColumn *html_column);

public slots:

private:
    QList<HtmlColumn*> m_columns;
    
signals:

};

#endif
