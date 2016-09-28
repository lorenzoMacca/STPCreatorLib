#include "html_column.h"

HtmlColumn::HtmlColumn(QString day, QString ggMm, QList<Build> builds, QDate date, QString mergeDay, QObject *parent):QObject(parent)
{
    this->m_day = day;
    this->m_ggMM = ggMm;
    this->m_builds = builds;
    this->m_date = date;
    this->m_merge_day = mergeDay;
    this->m_isEmpty = true;
    QListIterator<Build> buildIter(this->m_builds);
    while(buildIter.hasNext())
    {
        Build buildTmp(buildIter.next());
        if(
                this->m_date == buildTmp.start_date() ||
                this->m_date == buildTmp.upload_day() ||
                this->m_date == buildTmp.delivery_day())
        {
            this->m_isEmpty = false;
        }
    }
    if(this->m_isEmpty)
    {
        this->m_width = "width='4%'";
    }else
    {
        this->m_width = "";
    }
}

QString HtmlColumn::getHeaderColumnCode()
{
    return "<!-- COLUMN  -->\t\t\t<td\t" +
            this->m_width +
            "style='text-align: center; margin-left: auto; margin-right: auto; font-family: Arial, Helvetica, sans-serif; font-size: 10pt; background-color: #ffff80; line-height: 1.5em;'>\t\t\t\t<span style='font-size: 10pt'><strong>" +
            this->m_date.shortDayName(this->m_date.dayOfWeek())
            + "</strong> </span>\t\t\t\t<p>\t\t\t\t\t<span style='font-size: 10pt'><strong>" +
            this->m_ggMM +
            "</strong></span>\t\t\t\t</p>\t\t\t</td>";
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

