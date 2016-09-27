#ifndef HTML_DOCUMENT_H
#define HTML_DOCUMENT_H

#include <QObject>
#include <QString>
#include "html_document_header.h"
#include "html_document_title.h"
#include "../table/html_table.h"

class HtmlDocument : public QObject{
    
    Q_OBJECT
    
public:
    HtmlDocument(HtmlDocumentTitle *html_document_title, HtmlTable *html_table, QObject *parent=0);
    QString getCode();
    HtmlDocumentHeader* htmlDocumentHeader();
    HtmlDocumentTitle* htmlDucumentTitle();
    HtmlTable* htmlTable();
    void setHtmlDocumentHeader(HtmlDocumentHeader* html_document_header);
    void setHtmlDucumentTitle(HtmlDocumentTitle* html_document_header);
    void setHtmlTable(HtmlTable* html_table);

public slots:

private:
    HtmlDocumentHeader *m_html_document_header;
    HtmlDocumentTitle *m_html_ducument_title;
    HtmlTable *m_html_table;
    
signals:

};

#endif
