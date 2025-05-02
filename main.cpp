#include <QCoreApplication>
#include "radiocommande.h"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    Joystick joystick;
    return a.exec();
}
