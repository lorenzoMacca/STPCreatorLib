#include "html_table.h"

HtmlTable::HtmlTable(QObject *parent):QObject(parent)
{
}


QString HtmlTable::getCode()
{
    QString code = "<table border='1' style='width: 100%; table-layout: fixed'\tclass='tftable'>\t<caption></caption>\t<tbody>\t\t<!--   DAYS ROW   -->\t\t<tr>";
    QListIterator<HtmlColumn*> iter(this->m_columns);
    while (iter.hasNext())
    {
        code = code + iter.next()->getHeaderColumnCode();
    }
    code = code + "</tr>\t\t<!--  END DAYS ROW   -->\t\t<!--   BLOCKs ROW  -->\t\t<tr>";
    iter.toFront();
    while(iter.hasNext())
    {
        code = code + iter.next()->getBodyColumnCode();
    }
    code = code + "</tr>\t\t<!--   END BLOCKs ROW  -->\t</tbody></table>";
    return code;
}

bool HtmlTable::addColumn(HtmlColumn *html_column){
    if( html_column == 0 ) return false;
    this->m_columns.append(html_column);
    return true;
}
