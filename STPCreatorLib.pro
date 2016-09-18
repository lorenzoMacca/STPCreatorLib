#-------------------------------------------------
#
# Project created by QtCreator 2016-09-13T18:20:41
#
#-------------------------------------------------

QT       += xml
QT       -= gui

TARGET = STPCreatorLib
TEMPLATE = lib
CONFIG += staticlib

SOURCES += \
    src/traininglib.cpp \
    src/user/user.cpp \
    src/core/data/data.cpp \
    src/core/data/setting_data.cpp \
    src/core/entities/component.cpp \
    src/core/entities/integration_plan.cpp

HEADERS += \
    inc/traininglib.h \
    src/user/user.h \
    src/core/data/data.h \
    src/core/data/setting_data.h \
    src/core/entities/component.h \
    src/core/entities/integration_plan.h
unix {
    target.path = /usr/lib
    INSTALLS += target
}

DISTFILES += \
    config/configFile.xml
