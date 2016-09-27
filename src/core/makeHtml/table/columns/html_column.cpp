#include "html_column.h"

HtmlColumn::HtmlColumn(QObject *parent):QObject(parent)
{
}

QString HtmlColumn::getHeaderColumnCode()
{
    return "";
}

QString HtmlColumn::getBodyColumnCode()
{
    return "";
}

HtmlColumn::HtmlColumn(const HtmlColumn &other)
:QObject(other.parent())
{

}

HtmlColumn &HtmlColumn::operator=(const HtmlColumn &other)
{
    this->setParent(other.parent());
    return *this;
}

