#ifndef HTML_DOCUMENT_HEADER_H
#define HTML_DOCUMENT_HEADER_H

#include <QObject>
#include <QString>

class HtmlDocumentHeader : public QObject{
    
    Q_OBJECT
    
public:
    HtmlDocumentHeader(QObject *parent=0);
    QString getCode();


public slots:

private:

    
signals:

};

#endif
