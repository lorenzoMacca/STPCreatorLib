#ifndef DATA_H
#define DATA_H

#include <QObject>
#include "setting_data.h"

class Data : public QObject{

    Q_OBJECT

public:
    static Data* getInstance();

protected:
    Data(QObject *parent);

public slots:

private:
    static Data *instance;

signals:

};

#endif
