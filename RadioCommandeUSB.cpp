#include "radiocommande.h"
#include <QDebug>
#include <QUrlQuery>
#include <QNetworkRequest>

Joystick::Joystick(QObject *parent)
    : QObject(parent),
      gamepad(new QGamepad(0, this)), // 0 = premier gamepad détecté
      sendTimer(new QTimer(this)),
      networkManager(new QNetworkAccessManager(this))
{
    connect(sendTimer, &QTimer::timeout, this, &Joystick::envoyerRequete);
    sendTimer->start(200);
}

Joystick::~Joystick() {}

void Joystick::envoyerRequete()
{
    QUrl url("http://172.18.58.98:8080/?");
    QUrlQuery query;

    query.addQueryItem("gaz", QString::number(-gamepad->axisLeftY(), 'f', 2));
    query.addQueryItem("lacet", QString::number(gamepad->axisRightX(), 'f', 2));
    query.addQueryItem("tangage", QString::number(gamepad->axisLeftX(), 'f', 2));
    query.addQueryItem("roulis", QString::number(gamepad->axisRightY(), 'f', 2));
    url.setQuery(query);

    QNetworkRequest request(url);
    networkManager->get(request);

    qDebug() << "Requête envoyée :" << url.toString();
}
