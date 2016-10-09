#include "JiraSPInputFileCsv.h"

JiraSPInputFileCsv::JiraSPInputFileCsv(QStringList *list, QObject *parent):QObject(parent)
{
	this->m_rowsList = list;
}

const QStringList* JiraSPInputFileCsv::rowsList()const
{
	return this->m_rowsList;
}

void JiraSPInputFileCsv::save(QString path)
{
	QStringListIterator iter(*this->m_rowsList);

    QFile file( path);
    bool error = false;

    if(file.exists())
    {
        if(!file.remove())
        {
            error = true;
        }
    }

    if (!error && file.open(QIODevice::WriteOnly) )
    {
        QTextStream stream( &file );
		while(iter.hasNext())
		{
			stream << iter.next() << endl;
		}
    }else
    {
        qDebug() << "ERROR";
        emit fileError();
    }
}
