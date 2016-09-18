#include "build.h"

const QString Build::RELEASE="release";
const QString Build::DEV_DROP="dev_drop";
const QString Build::ACCEPTANCE="acceptance";
const QString Build::DRY_RUN="dry_run";

Build::Build(QObject *parent):QObject(parent)
{

}
