#ifndef COMPONENT_H
#define COMPONENT_H

#include <QObject>
#include <QString>

class ComponentSoftware : public QObject{

    Q_OBJECT

public:
    ComponentSoftware(QString name, QString version, QString description, QObject *parent);

public slots:

private:
    QString m_name;
    QString m_version;
    QString m_description;

signals:

};

#endif