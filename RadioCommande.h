#ifndef JOYSTICK_H
#define JOYSTICK_H

#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QNetworkAccessManager>

class Joystick : public QObject
{
    Q_OBJECT

public:
    explicit Joystick(QObject *parent = nullptr);
    ~Joystick();

    void setRestartClicked(bool clicked);
    void setRthDistance(float distance);

private slots:
    void lireDonneesSerie();
    void envoyerRequete();

private:
    QSerialPort *serial;
    QTimer *sendTimer;
    QNetworkAccessManager *networkManager;

    int gazValue = 0;
    int lacetValue = 0;
    int tangageValue = 0;
    int roulisValue = 0;
    QString buffer;
};

#endif // JOYSTICK_H
