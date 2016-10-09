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
    JiraSPInputFileCsv(QStringList *list, QObject *parent);
	const QStringList* rowsList()const;
    void save(QString path);//should generate events

public slots:

private:
    QStringList* m_rowsList;

signals:
    void fileError();
};

#endif
