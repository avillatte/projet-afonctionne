#include <QObject>
#include <QGamepad>
#include <QTimer>
#include <QNetworkAccessManager>

class Joystick : public QObject
{
    Q_OBJECT
public:
    Joystick(QObject *parent = nullptr);
    ~Joystick();

private slots:
    void envoyerRequete();

private:
    QGamepad *gamepad;
    QTimer *sendTimer;
    QNetworkAccessManager *networkManager;
};
