#include "html_document_header.h"

HtmlDocumentHeader::HtmlDocumentHeader(QObject *parent):QObject(parent)
{
}

QString HtmlDocumentHeader::getCode()
{
    return "<style type='text/css'>.tftable {\tfont-size: 12px;\tcolor: #333333;\twidth: 100%;\tborder-width: 1px;\tborder-color: #729ea5;\tborder-collapse: collapse;}.tftable th {\tfont-size: 12px;\tbackground-color: #acc8cc;\tborder-width: 1px;\tpadding: 8px;\tborder-style: solid;\tborder-color: #729ea5;\ttext-align: left;}.tftable tr {\tbackground-color: #ffffff;}.tftable td {\tfont-size: 12px;\tborder-width: 1px;\tpadding: 8px;\tborder-style: solid;\tborder-color: #729ea5;}.aui-message-max {\tbackground: #f0f0f0;\tborder: 1px solid #bbb;\tborder-radius: 5px;\t-moz-border-radius: 5px;\t-webkit-border-radius: 5px;\tcolor: #333;\tmargin: 0 0 1em 0;\tmin-height: 1em;\tpadding: 1em 1em 1em 5px;\tposition: relative;}</style>";
}
