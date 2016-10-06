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
    src/core/entities/integration_plan.cpp \
    src/core/entities/build.cpp \
    src/core/util/util.cpp \
    src/core/logger/logger.cpp \
    src/core/test/TEST_001.cpp \
    src/core/test/test_manager.cpp \
    src/core/makeHtml/document/html_document_title.cpp \
    src/core/makeHtml/document/html_document_header.cpp \
    src/core/makeHtml/table/html_table.cpp \
    src/core/makeHtml/document/html_document.cpp \
    src/core/makeHtml/table/columns/html_column.cpp \
    src/core/test/TEST_002.cpp \
    src/core/test/TEST_003.cpp \
    src/core/test/TEST_004.cpp

HEADERS += \
    inc/traininglib.h \
    src/user/user.h \
    src/core/data/data.h \
    src/core/data/setting_data.h \
    src/core/entities/component.h \
    src/core/entities/integration_plan.h \
    src/core/entities/build.h \
    src/core/util/util.h \
    src/core/logger/logger.h \
    src/core/test/TEST_001.h \
    src/core/test/TEST.h \
    src/core/test/test_manager.h \
    src/core/makeHtml/document/html_document_title.h \
    src/core/makeHtml/document/html_document_header.h \
    src/core/makeHtml/table/html_table.h \
    src/core/makeHtml/document/html_document.h \
    src/core/makeHtml/table/columns/html_column.h \
    src/core/test/TEST_002.h \
    src/core/test/TEST_003.h \
    src/core/test/TEST_004.h
unix {
    target.path = /usr/lib
    INSTALLS += target
}

DISTFILES += \
    config/configFile.xml
