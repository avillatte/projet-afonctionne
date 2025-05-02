#ifndef JOYSTICK_H
#define JOYSTICK_H

#include "qnetworkaccessmanager.h"
#include <QObject>
#include <QSocketNotifier>
#include <QTimer>

class Joystick : public QObject
{
    Q_OBJECT

public:
    explicit Joystick(QObject *parent = nullptr);
    ~Joystick();

    void setRestartClicked(bool clicked);  // Appelé de l'extérieur
    void setRthDistance(float distance);   // Appelé de l'extérieur

private slots:
    void lireEvenement();
    void envoyerRequete();

private:
    int fd;
    QSocketNotifier *notifier;
    QNetworkAccessManager *networkManager;
    QTimer *sendTimer;

    int gazValue = 0;
    int lacetValue = 0;
    int tangageValue = 0;
    int roulisValue = 0;
    bool restartClicked = false;
    float rthDistance = 0.0f;
};

#endif // JOYSTICK_H
