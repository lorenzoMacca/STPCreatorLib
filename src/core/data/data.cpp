#include "data.h"

Data* Data::instance = 0;

Data::Data(QObject *parent):QObject(parent)
{}

Data* Data::getInstance()
{
    if( instance == 0 )
    {
        instance = new Data(0);
    }
    return instance;
}
