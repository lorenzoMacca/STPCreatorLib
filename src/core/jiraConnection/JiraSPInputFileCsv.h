#ifndef JIRA_SP_INPUT_FILE_H
#define JIRA_SP_INPUT_FILE_H

#include <QObject>
#include <QString>
#include <QStringList>
#include "../data/data.h"

class JiraSPInputFileCsv : public QObject{
    
    Q_OBJECT
    
public:
    JiraSPInputFileCsv(Data *data, QStringList *list, QObject *parent);

public slots:

private:
    QString m_name;
    QString m_locationinJiraEnv;
    
signals:

};

#endif
