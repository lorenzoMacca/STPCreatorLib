#ifndef BUILD_H
#define BUILD_H

#include <QObject>
#include <QString>

class Build : public QObject{

    Q_OBJECT

public:
    Build(QObject *parent);
    static const QString RELEASE;
    static const QString DEV_DROP;
    static const QString ACCEPTANCE;
    static const QString DRY_RUN;

public slots:

private:

signals:

};

#endif
