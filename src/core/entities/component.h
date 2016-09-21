#ifndef COMPONENT_H
#define COMPONENT_H

#include <QObject>
#include <QString>

class ComponentSoftware : public QObject{

    Q_OBJECT

public:
    ComponentSoftware(QString name, QString version, QString description, QObject *parent);
    ComponentSoftware(const ComponentSoftware &other);
    ComponentSoftware &operator=(const ComponentSoftware &other);
    bool operator==(const ComponentSoftware &other);
    const QString& name()const;
    const QString& version()const;
    const QString& description()const;
    void setName(QString name);
    void setVersion(QString version);
    void setDescription(QString description);
    const QString toString()const;

public slots:

private:
    QString m_name;
    QString m_version;
    QString m_description;

signals:

};

#endif
