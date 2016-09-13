#-------------------------------------------------
#
# Project created by QtCreator 2016-09-13T18:20:41
#
#-------------------------------------------------

QT       -= gui

TARGET = trainingLib
TEMPLATE = lib
CONFIG += staticlib

SOURCES += \
    src/traininglib.cpp \
    src/user/user.cpp

HEADERS += \
    inc/traininglib.h \
    src/user/user.h
unix {
    target.path = /usr/lib
    INSTALLS += target
}
