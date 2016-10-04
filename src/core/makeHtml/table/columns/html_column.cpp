#include "html_column.h"

HtmlColumn::HtmlColumn(QString day, QString ggMm, const QList<Build>& builds, const QDate date, QString mergeDay, QObject *parent):QObject(parent)
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
    QString code = "<!-- COLUMN  --><td>";
    QListIterator<Build> buildIter(this->m_builds);
    while(buildIter.hasNext())
    {
        Build build(buildIter.next());
        if( build.start_date() == this->m_date )
        {
            if(!build.noMerge())
            {
                code = code + "<div class='aui-message-max' style='background-color: #d2f4ff'>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;; font-size: 10pt;'>\t\t<strong>Radio_App</strong> - Ver." + this->m_merge_day + "</p></div>";
            }
            QListIterator<ComponentSoftware> componentsIter(build.components());
            while(componentsIter.hasNext())
            {
                ComponentSoftware component(componentsIter.next());
                code = code + "<div class='aui-message-max' style='background-color: #d2f4ff'>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;; font-size: 10pt;'>\t\t<strong>" + component.name() + "</strong>\t</p>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;; font-size: 10pt;'>\t\t<strong>" + component.description() + "</strong>\t</p>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;; font-size: 10pt;'>Ver." + component.version() + "</p></div>";
            }
        }
        code = code + "<div style='background-color: #ffffff'>\t<p\t\tstyle='text-align: left; margin-left: auto; margin-right: auto;; font-size: 10pt; color: #ff0000;'>\t\t<strong>" + build.description() + "</strong>\t</p></div>";
        code = code + "<div class='aui-message-max' style='background-color: #ffffff'>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;; font-size: 10pt;'>\t\t<strong><a\thref='http://bugs.lng.pce.cz.pan.eu:8081/secure/Dashboard.jspa?selectPageId=19331'>" +
                build.name() + "</a></strong>\t</p></div>";
        code = code + "<HR COLOR='blue'>";
        if ((build.build_type() ==  "dev_drop" || build.build_type() ==  "release") &&
          build.upload_day() == this->m_date)
        {
          code = code + "<p></p><div class='aui-message-max' style='background-color: #d2ffd5'>\t<p class='title'\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;'>\t\t<strong><span style='color: #ff0000; font-size: 10pt;'>Upload</span></strong>\t</p>\t<p class='title'\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;'>\t\t<strong><span style='font-size: 10pt;'>" +
                  build.name() + "</span></strong>\t</p>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto; font-size: 10pt;'>Time:\t\t18:00</p></div> <!-- .aui-message-max --><p></p>";
        }
        if (build.build_type() == "release" &&
          build.delivery_day() ==  this->m_date) {
          code = code + "<p></p><div class='aui-message-max' style='background-color: #d2ffd5'>\t<p class='title'\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;'>\t\t<strong><span style='color: #ff0000; font-size: 10pt;'>Delivery</span></strong>\t</p>\t<p class='title'\t\tstyle='text-align: center; margin-left: auto; margin-right: auto;'>\t\t<strong><span style='font-size: 10pt;'>" +
                  build.name() + "</span></strong>\t</p>\t<p\t\tstyle='text-align: center; margin-left: auto; margin-right: auto; font-size: 10pt;'>Time:\t\t18:00</p></div> <!-- .aui-message-max --><p></p>";
        }

    }
    code = code + "</td>";
    return code;
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

