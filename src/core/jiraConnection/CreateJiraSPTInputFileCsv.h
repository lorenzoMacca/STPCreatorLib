#ifndef CREATE_JIRA_INPUT_FILE_CSV_H
#define CREATE_JIRA_INPUT_FILE_CSV_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QStringList>
#include <QStringListIterator>
#include "../entities/integration_plan.h"
#include "JiraSPInputFileCsv.h"
#include "../util/util.h"

class CreateJiraSPTInputFileCsv : public QObject{
    
    Q_OBJECT
    
public:
    CreateJiraSPTInputFileCsv(QString html_code, IntegrationPlan* ip, QObject *parent);
    JiraSPInputFileCsv* createJiraSPTInputFileCsv();

public slots:

private:
    IntegrationPlan* m_ip;
    QString m_separator;
    QString m_html_code;

    void putHeaderCsv(QStringList *list);
    void putSTPUsingIntegrationPlan(QStringList *list);

signals:

};

#endif
