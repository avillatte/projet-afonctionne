#include "radiocommande.h"
#include <QDebug>
#include <fcntl.h>
#include <unistd.h>
#include <linux/joystick.h>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>
#include <QTimer>

#define AXE_TANGAGE 2
#define AXE_GAZ     1
#define AXE_ROULIS  0
#define AXE_LACET   5

Joystick::Joystick(QObject *parent)
    : QObject(parent),
    fd(open("/dev/input/js0", O_RDONLY | O_NONBLOCK)),
    networkManager(new QNetworkAccessManager(this)),
    sendTimer(new QTimer(this))
{
    if (fd < 0) {
        qFatal("Impossible d'ouvrir /dev/input/js0 (permissions ou périphérique manquant)");
    }

    notifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);
    connect(notifier, &QSocketNotifier::activated, this, &Joystick::lireEvenement);

    // Envoi toutes les 200 ms (ajuste si besoin)
    connect(sendTimer, &QTimer::timeout, this, &Joystick::envoyerRequete);
    sendTimer->start(200);

    qDebug() << "Joystick connecté sur /dev/input/js0";
}

Joystick::~Joystick()
{
    if (fd >= 0) {
        close(fd);
    }
}

void Joystick::lireEvenement()
{
    struct js_event event;
    ssize_t bytes = read(fd, &event, sizeof(event));

    if (bytes == sizeof(event) && (event.type & JS_EVENT_AXIS)) {
        switch (event.number) {
        case AXE_TANGAGE:
            tangageValue = event.value / 250 ;
            break;
        case AXE_GAZ:
            gazValue = -event.value / 250 ;
            break;
        case AXE_ROULIS:
            roulisValue = event.value / 250 ;
            break;
        case AXE_LACET:
            lacetValue = event.value / 250 ;
            break;
        default:
            break;
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
    qDebug() << "Gaz:" << gazValue << "Lacet:" << lacetValue << "Tangage:" << tangageValue << "Roulis:" << roulisValue;
}
