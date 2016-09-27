#ifndef HTML_DOCUMENT_TITLE_H
#define HTML_DOCUMENT_TITLE_H

#include <QObject>
#include <QString>

class HtmlDocumentTitle : public QObject{
    
    Q_OBJECT
    
public:
    HtmlDocumentTitle(QString& cw, QObject *parent=0);
    const QString& cw()const;
    void setCw(QString& cw);
    QString getCode();

public slots:

private:
    QString m_cw;
    
signals:

};

#endif
