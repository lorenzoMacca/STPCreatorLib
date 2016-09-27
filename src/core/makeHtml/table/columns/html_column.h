#ifndef HTML_COLUMN_H
#define HTML_COLUMN_H

#include <QObject>
#include <QString>

class HtmlColumn : public QObject{
    
    Q_OBJECT
    
public:
    HtmlColumn(QObject *parent=0);
    HtmlColumn(const HtmlColumn &other);
    HtmlColumn &operator=(const HtmlColumn &other);
    QString getHeaderColumnCode();
    QString getBodyColumnCode();


public slots:

private:

    
signals:

};

#endif
