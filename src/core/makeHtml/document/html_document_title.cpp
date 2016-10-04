#include "html_document_title.h"

HtmlDocumentTitle::HtmlDocumentTitle(const QString& cw, QObject *parent):QObject(parent)
{
    this->m_cw = cw;
}

const QString& HtmlDocumentTitle::cw()const
{
    return this->m_cw;
}

void HtmlDocumentTitle::setCw(QString& cw)
{
    this->m_cw = cw;
}

QString HtmlDocumentTitle::getCode()
{
    return "<table border='1' style='width: 100%; table-layout: fixed'\tclass='tftable'>\t<!-- TITLE Row --> <tr><td style='text-align: center; margin-left: auto; margin-right: auto; font-size: 16pt'><span style='font-size: 20pt'> <span style='font-family: Arial, Helvetica, sans-serif'><strong>Integration Line - CW" + this->m_cw + "</strong></span></span></td></tr>\t<!-- END TITLE -->\t<tr><td\tstyle='text-align: center; margin-left: auto; margin-right: auto; font-family: Arial, Helvetica, sans-serif; font-size: 10pt; background-color: #ece9d8;'></td>\t</tr></table>";
}
