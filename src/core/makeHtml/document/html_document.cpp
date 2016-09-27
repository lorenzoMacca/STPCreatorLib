#include "html_document.h"

HtmlDocument::HtmlDocument(HtmlDocumentTitle *html_document_title, HtmlTable *html_table,QObject *parent):QObject(parent)
{
    this->m_html_ducument_title = html_document_title;
    this->m_html_table = html_table;
    this->m_html_document_header = new HtmlDocumentHeader(this->parent());
}

QString HtmlDocument::getCode()
{
    return "{html}" +
            this->m_html_document_header->getCode() +
            this->m_html_ducument_title->getCode() +
            this->m_html_table->getCode()
            + "<!-- for vacation use: #d3d3d3  -->{html}";
}

HtmlDocumentHeader* HtmlDocument::htmlDocumentHeader()
{
    return this->m_html_document_header;
}

HtmlDocumentTitle* HtmlDocument::htmlDucumentTitle()
{
    return this->m_html_ducument_title;
}

HtmlTable* HtmlDocument::htmlTable()
{
    return this->m_html_table;
}

void HtmlDocument::setHtmlDocumentHeader(HtmlDocumentHeader* html_document_header)
{
    this->m_html_document_header = html_document_header;
}

void HtmlDocument::setHtmlDucumentTitle(HtmlDocumentTitle* html_document_title)
{
    this->m_html_ducument_title = html_document_title;
}

void HtmlDocument::setHtmlTable(HtmlTable* html_table)
{
    this->m_html_table = html_table;
}
