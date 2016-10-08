#include "JiraSPInputFileCsv.h"

JiraSPInputFileCsv::JiraSPInputFileCsv(Data *data, QStringList *list, QObject *parent):QObject(parent)
{
	this->m_locationinJiraEnv = data->settingData()->create_stp_jira_path();
	this->m_name = new QFile( this->m_locationinJiraEnv.absolutePath() + data->settingData()->sp_input_file_name().absoluteFilePath());
	this->m_rowsList = list;
}

const QFile* JiraSPInputFileCsv::name()const
{
	return this->m_name;
}

const QDir& JiraSPInputFileCsv::locationinJiraEnv()const
{
	return this->m_locationinJiraEnv;
}

const QStringList* JiraSPInputFileCsv::rowsList()const
{
	return this->m_rowsList;
}

const QString JiraSPInputFileCsv::toString()const
{
	return "JiraSPInputFileCsv [fileName=" + this->m_name->fileName() + "]";
}

void JiraSPInputFileCsv::save()
{
	QStringListIterator iter(*this->m_rowsList);
	if ( this->m_name->open(QIODevice::ReadWrite) )
    {
		QTextStream stream( this->m_name );
		while(iter.hasNext())
		{
			stream << iter.next() << endl;
		}
	}
}
