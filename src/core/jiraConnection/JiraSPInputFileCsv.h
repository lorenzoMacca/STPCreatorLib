#ifndef JIRA_SP_INPUT_FILE_H
#define JIRA_SP_INPUT_FILE_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QStringList>
#include <QStringListIterator>
#include "../data/data.h"

class JiraSPInputFileCsv : public QObject{
    
    Q_OBJECT
    
public:
    JiraSPInputFileCsv(Data *data, QStringList *list, QObject *parent);
	const QFile* name()const;
    const QDir& locationinJiraEnv()const;
	const QStringList* rowsList()const;
	const QString toString()const;
    void save();//should generate events

public slots:

private:
    QFile* m_name;
    QDir m_locationinJiraEnv;
    QStringList* m_rowsList;

signals:
    void fileError();
};

#endif
