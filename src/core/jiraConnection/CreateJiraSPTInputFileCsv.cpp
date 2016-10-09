#include "CreateJiraSPTInputFileCsv.h"

CreateJiraSPTInputFileCsv::CreateJiraSPTInputFileCsv(IntegrationPlan* ip, QObject *parent):QObject(parent)
{
    this->m_ip = ip;
    this->m_separator = ";";
}

JiraSPInputFileCsv* CreateJiraSPTInputFileCsv::createJiraSPTInputFileCsv()
{
    QStringList *list = new QStringList();
    this->putHeaderCsv(list);
    this->putSTPUsingIntegrationPlan(list);
    JiraSPInputFileCsv *input_file = new JiraSPInputFileCsv(list, this);
    return input_file;
}

void CreateJiraSPTInputFileCsv::putHeaderCsv(QStringList *list)
{
    QString s = this->m_separator;
    list->append("Project"+s+"GL005");
    list->append("IssueType"+s+"SP_Integration");
    list->append("Summary"+s+"Security Level"+s+"Assignee"+s+"Due Date"+s+"Planned Start"+s+"PIC"+s+"Sub Project"+s+"Labels"+s+"Priority"+s+"Short Plan");
}

void CreateJiraSPTInputFileCsv::putSTPUsingIntegrationPlan(QStringList *list)
{
    QUtilSTP util(this);
    QString s = this->m_separator;
    QString summary = this->m_ip->summary();
    QString securityLevel = this->m_ip->security_level();
    QString assignee = this->m_ip->assignees();
    QString dueDate = util.getDateDDMMYYYY(this->m_ip->getRealDueDate(),'.');
    QString plannedStart = util.getDateDDMMYYYY(this->m_ip->getRealStartDate(),'.');
    QString pic = this->m_ip->pic();
    QString subProject = this->m_ip->sub_project();
    QString labels = "Integration_" + subProject;
    QString priority = "Major";
    QString htmlCode; // = "\"" + " " + "\"";

    list->append(summary +s+
                 securityLevel +s+
                 assignee +s+
                 dueDate +s+
                 plannedStart +s+
                 pic +s+
                 subProject +s+
                 labels +s+
                 priority +s+
                 htmlCode
                );
}
