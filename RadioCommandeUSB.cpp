#include "radiocommande.h"
#include <QDebug>
#include <QUrl>
#include <QUrlQuery>
#include <QNetworkRequest>

Joystick::Joystick(QObject *parent)
    : QObject(parent),
      serial(new QSerialPort(this)),
      sendTimer(new QTimer(this)),
      networkManager(new QNetworkAccessManager(this))
{
    serial->setPortName("COM3"); // Adapte selon ton port
    serial->setBaudRate(QSerialPort::Baud9600);
    serial->setDataBits(QSerialPort::Data8);
    serial->setParity(QSerialPort::NoParity);
    serial->setStopBits(QSerialPort::OneStop);
    serial->setFlowControl(QSerialPort::NoFlowControl);

    if (!serial->open(QIODevice::ReadOnly)) {
        qCritical() << "Impossible d'ouvrir le port série";
        return;
    }

    connect(serial, &QSerialPort::readyRead, this, &Joystick::lireDonneesSerie);
    connect(sendTimer, &QTimer::timeout, this, &Joystick::envoyerRequete);
    sendTimer->start(200);

    qDebug() << "Joystick connecté via port série COM3";
}

Joystick::~Joystick()
{
    if (serial->isOpen())
        serial->close();
}

void Joystick::setRestartClicked(bool clicked) {
    Q_UNUSED(clicked);
}

void Joystick::setRthDistance(float distance) {
    Q_UNUSED(distance);
}

void Joystick::lireDonneesSerie()
{
    buffer.append(serial->readAll());

    while (buffer.contains('\n')) {
        int index = buffer.indexOf('\n');
        QString line = buffer.left(index).trimmed();
        buffer.remove(0, index + 1);

        // Exemple attendu : "G:100 L:50 T:-20 R:0"
        QStringList parts = line.split(' ');
        for (const QString &part : parts) {
            if (part.startsWith("G:"))
                gazValue = part.mid(2).toInt();
            else if (part.startsWith("L:"))
                lacetValue = part.mid(2).toInt();
            else if (part.startsWith("T:"))
                tangageValue = part.mid(2).toInt();
            else if (part.startsWith("R:"))
                roulisValue = part.mid(2).toInt();
        }
    }
}

void Joystick::envoyerRequete()
{
    QUrl url("http://172.18.58.98:8080/?");
    QUrlQuery query;

    query.addQueryItem("gaz", QString::number(gazValue / 50.0f, 'f', 2));
    query.addQueryItem("lacet", QString::number(lacetValue / 300.0f, 'f', 2));
    query.addQueryItem("tangage", QString::number(tangageValue / 300.0f, 'f', 2));
    query.addQueryItem("roulis", QString::number(roulisValue / 300.0f, 'f', 2));
    url.setQuery(query);

    QNetworkRequest request(url);
    networkManager->get(request);

    qDebug() << "Envoi de la requête:" << url.toString();
}
