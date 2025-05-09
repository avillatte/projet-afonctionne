#include "joystickxinput.h"
#include <QDebug>

JoystickXInput::JoystickXInput(QObject *parent)
    : QObject(parent)
{
    connect(&pollTimer, &QTimer::timeout, this, &JoystickXInput::updateState);
    pollTimer.start(50); // toutes les 50 ms
}

void JoystickXInput::updateState()
{
    XINPUT_STATE state;
    ZeroMemory(&state, sizeof(XINPUT_STATE));

    DWORD result = XInputGetState(0, &state); // 0 = première manette

    if (result == ERROR_SUCCESS) {
        float lx = state.Gamepad.sThumbLX / 32767.0f;
        float ly = state.Gamepad.sThumbLY / 32767.0f;
        float rx = state.Gamepad.sThumbRX / 32767.0f;
        float ry = state.Gamepad.sThumbRY / 32767.0f;
        int buttons = state.Gamepad.wButtons;

        emit joystickUpdated(lx, ly, rx, ry, buttons);
    } else {
        qWarning() << "Aucune manette détectée.";
    }
}
