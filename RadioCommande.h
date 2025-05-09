#ifndef JOYSTICKXINPUT_H
#define JOYSTICKXINPUT_H

#include <QObject>
#include <QTimer>
#include <windows.h>
#include <Xinput.h>

#pragma comment(lib, "XInput.lib")

class JoystickXInput : public QObject
{
    Q_OBJECT

public:
    explicit JoystickXInput(QObject *parent = nullptr);
    ~JoystickXInput() = default;

signals:
    void joystickUpdated(float lx, float ly, float rx, float ry, int buttons);

private slots:
    void updateState();

private:
    QTimer pollTimer;
};

#endif // JOYSTICKXINPUT_H
