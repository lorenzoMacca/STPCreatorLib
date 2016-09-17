#ifndef DATA_H
#define DATA_H

#include <QObject>
#include <QString>

class Data : public QObject{

    Q_OBJECT

public:
    Data(QObject *parent);

public slots:

private:
    QString m_text;

signals:

};

#endif
