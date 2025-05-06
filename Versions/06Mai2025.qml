import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "Application de l'interface pour piloter le drone"

    // Propriétés de l'application
    property bool isDroneCameraActive: true
    property bool showValues: true
    property int joystickOffset: 100
    property int joystickSize: 180
    property int joystickReturnDuration: 100
    property real joystickSensitivity: 0.7
    property real yawSensitivityFactor: 0.5
    property bool isConnected: false
    property string serverAddress: "http://172.18.58.98:8080"
    property int rthDistance: 20

    // Valeurs des axes
    property int gazValue: 0
    property int lacetValue: 0
    property int tangageValue: 0
    property int roulisValue: 0

    // Nouvelle palette de couleurs modernes
    property color primaryColor: "#6200EE"    // Violet profond
    property color secondaryColor: "#03DAC6"  // Cyan vif
    property color accentColor: "#FF0266"     // Rose électrique
    property color darkColor: "#121212"       // Noir profond
    property color lightColor: "#E6E6E6"      // Blanc doux
    property color surfaceColor: "#1E1E1E"    // Surface sombre
    property color cardColor: "#252525"       // Cartes légèrement plus claires

    // Style par défaut pour les boutons
    Component {
        id: buttonStyle
        Button {
            background: Rectangle {
                color: parent.down ? Qt.darker(primaryColor, 1.2) : primaryColor
                radius: 8
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80000000"
                    radius: 8
                    samples: 16
                    verticalOffset: 2
                }
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: 14
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Barre du menu supérieur modernisée
    Rectangle {
        id: topBar
        z: 2
        width: parent.width
        height: 70
        color: darkColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 30

            // Logo/icône
            Rectangle {
                width: 40
                height: 40
                radius: 8
                color: primaryColor
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "✈"
                    font.pixelSize: 24
                    color: "white"
                    anchors.centerIn: parent
                }
            }

            // Affichage de l'heure
            Text {
                id: timeText
                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                font {
                    pixelSize: 24
                    family: "Roboto"
                    weight: Font.Medium
                }
                color: lightColor
                Layout.alignment: Qt.AlignVCenter

                Timer {
                    interval: 50
                    running: true
                    repeat: true
                    onTriggered: timeText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                }
            }

            // Indicateur de connexion
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 40
                color: "transparent"
                radius: 8
                border.color: isConnected ? secondaryColor : "#FF5252"
                border.width: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    Rectangle {
                        width: 16
                        height: 16
                        radius: width / 2
                        color: isConnected ? secondaryColor : "#FF5252"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: isConnected ? "CONNECTÉ" : "DÉCONNECTÉ"
                        color: isConnected ? secondaryColor : "#FF5252"
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "Roboto"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Bouton menu
            Button {
                id: menuButton
                text: "MENU"
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                onClicked: menu.visible = !menu.visible
                background: Rectangle {
                    color: parent.down ? Qt.darker(accentColor, 1.2) : accentColor
                    radius: 8
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        color: "#80000000"
                        radius: 8
                        samples: 16
                        verticalOffset: 2
                    }
                }
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Zone principale avec fond dégradé
    Rectangle {
        id: mainArea
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1A1A1A" }
            GradientStop { position: 1.0; color: darkColor }
        }

        // Joystick de gauche (Gaz et Lacet)
        Item {
            id: leftJoystickContainer
            width: joystickSize
            height: joystickSize
            anchors.left: parent.left
            anchors.leftMargin: joystickOffset
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 40

            // Base du joystick avec effet 3D
            Rectangle {
                id: leftJoystickBase
                anchors.fill: parent
                radius: width/2
                color: cardColor
                border.color: Qt.lighter(cardColor, 1.3)
                border.width: 2

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80000000"
                    radius: 16
                    samples: 32
                    verticalOffset: 4
                }

                // Effet de relief concave
                Rectangle {
                    width: parent.width - 20
                    height: parent.height - 20
                    anchors.centerIn: parent
                    radius: width/2
                    color: "transparent"
                    border.color: "#30FFFFFF"
                    border.width: 2
                }
            }

            // Grille de fond
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = "#30FFFFFF"
                    ctx.lineWidth = 1.5

                    // Lignes principales
                    ctx.beginPath()
                    ctx.moveTo(width/2, 0)
                    ctx.lineTo(width/2, height)
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.moveTo(0, height/2)
                    ctx.lineTo(width, height/2)
                    ctx.stroke()

                    // Cercles concentriques
                    ctx.beginPath()
                    ctx.arc(width/2, height/2, width/4, 0, Math.PI*2)
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.arc(width/2, height/2, width/2.5, 0, Math.PI*2)
                    ctx.stroke()
                }
            }

            // Curseur avec effet 3D
            Rectangle {
                id: leftCursor
                width: 44
                height: 44
                radius: width/2
                x: (leftJoystickContainer.width - width) / 2
                y: (leftJoystickContainer.height - height) / 2 + (leftJoystickContainer.height / 2)
                color: secondaryColor
                border.color: Qt.lighter(secondaryColor, 1.3)
                border.width: 2

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80000000"
                    radius: 12
                    samples: 24
                    verticalOffset: 3
                }

                // Point central pour le relief
                Rectangle {
                    width: 8
                    height: 8
                    radius: width/2
                    anchors.centerIn: parent
                    color: Qt.lighter(parent.color, 1.5)
                }
            }

            // Affichage des valeurs avec nouveau style
            Column {
                anchors.top: parent.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    text: showValues ? "GAZ: " + gazValue : ""
                    font {
                        pixelSize: 16
                        family: "Roboto"
                        weight: Font.Medium
                    }
                    color: lightColor
                }

                Text {
                    text: showValues ? "LACET: " + lacetValue : ""
                    font {
                        pixelSize: 16
                        family: "Roboto"
                        weight: Font.Medium
                    }
                    color: lightColor
                }
            }
        }

        // Joystick de droite (Tangage et Roulis)
        Item {
            id: rightJoystickContainer
            width: joystickSize
            height: joystickSize
            anchors.right: parent.right
            anchors.rightMargin: joystickOffset
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 40

            // Base du joystick avec effet 3D
            Rectangle {
                id: rightJoystickBase
                anchors.fill: parent
                radius: width/2
                color: cardColor
                border.color: Qt.lighter(cardColor, 1.3)
                border.width: 2

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80000000"
                    radius: 16
                    samples: 32
                    verticalOffset: 4
                }

                // Effet de relief concave
                Rectangle {
                    width: parent.width - 20
                    height: parent.height - 20
                    anchors.centerIn: parent
                    radius: width/2
                    color: "transparent"
                    border.color: "#30FFFFFF"
                    border.width: 2
                }
            }

            // Grille de fond
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = "#30FFFFFF"
                    ctx.lineWidth = 1.5

                    // Lignes principales
                    ctx.beginPath()
                    ctx.moveTo(width/2, 0)
                    ctx.lineTo(width/2, height)
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.moveTo(0, height/2)
                    ctx.lineTo(width, height/2)
                    ctx.stroke()

                    // Cercles concentriques
                    ctx.beginPath()
                    ctx.arc(width/2, height/2, width/4, 0, Math.PI*2)
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.arc(width/2, height/2, width/2.5, 0, Math.PI*2)
                    ctx.stroke()
                }
            }

            // Curseur avec effet 3D
            Rectangle {
                id: rightCursor
                width: 44
                height: 44
                radius: width/2
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                color: accentColor
                border.color: Qt.lighter(accentColor, 1.3)
                border.width: 2

                Behavior on x {
                    NumberAnimation { duration: joystickReturnDuration; easing.type: Easing.OutQuad }
                }
                Behavior on y {
                    NumberAnimation { duration: joystickReturnDuration; easing.type: Easing.OutQuad }
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#80000000"
                    radius: 12
                    samples: 24
                    verticalOffset: 3
                }

                // Point central pour le relief
                Rectangle {
                    width: 8
                    height: 8
                    radius: width/2
                    anchors.centerIn: parent
                    color: Qt.lighter(parent.color, 1.5)
                }
            }

            // Affichage des valeurs avec nouveau style
            Column {
                anchors.top: parent.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    text: showValues ? "TANGAGE: " + tangageValue : ""
                    font {
                        pixelSize: 16
                        family: "Roboto"
                        weight: Font.Medium
                    }
                    color: lightColor
                }

                Text {
                    text: showValues ? "ROULIS: " + roulisValue : ""
                    font {
                        pixelSize: 16
                        family: "Roboto"
                        weight: Font.Medium
                    }
                    color: lightColor
                }
            }
        }

        // Zone tactile (inchangée fonctionnellement)
        MultiPointTouchArea {
            id: touchArea
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 2
            mouseEnabled: true

            touchPoints: [
                TouchPoint { id: touch1 },
                TouchPoint { id: touch2 }
            ]

            onPressed: handleTouchPoints()
            onUpdated: handleTouchPoints()
            onReleased: handleRelease()

            property int activeLeftTouch: -1
            property int activeRightTouch: -1

            function handleTouchPoints() {
                if (activeLeftTouch === -1) {
                    if (touch1.pressed && isInLeftJoystickArea(touch1)) {
                        activeLeftTouch = 1;
                    } else if (touch2.pressed && isInLeftJoystickArea(touch2)) {
                        activeLeftTouch = 2;
                    }
                }

                if (activeLeftTouch === 1 && touch1.pressed) {
                    updateLeftJoystick(touch1);
                } else if (activeLeftTouch === 2 && touch2.pressed) {
                    updateLeftJoystick(touch2);
                }

                if (activeRightTouch === -1) {
                    if (touch1.pressed && isInRightJoystickArea(touch1) && activeLeftTouch !== 1) {
                        activeRightTouch = 1;
                    } else if (touch2.pressed && isInRightJoystickArea(touch2) && activeLeftTouch !== 2) {
                        activeRightTouch = 2;
                    }
                }

                if (activeRightTouch === 1 && touch1.pressed) {
                    updateRightJoystick(touch1);
                } else if (activeRightTouch === 2 && touch2.pressed) {
                    updateRightJoystick(touch2);
                }

                sendCombinedRequest();
            }

            function isInLeftJoystickArea(touch) {
                var pos = mapToItem(leftJoystickContainer, touch.x, touch.y);
                return leftJoystickContainer.contains(Qt.point(pos.x, pos.y));
            }

            function isInRightJoystickArea(touch) {
                var pos = mapToItem(rightJoystickContainer, touch.x, touch.y);
                return rightJoystickContainer.contains(Qt.point(pos.x, pos.y));
            }

            function updateLeftJoystick(touch) {
                var touchPos = leftJoystickContainer.mapFromItem(touchArea, touch.x, touch.y);
                var centerX = leftJoystickContainer.width / 2;
                var centerY = leftJoystickContainer.height / 2;
                var radius = leftJoystickContainer.width / 2 - 20;

                var normalizedY = Math.max(0, Math.min(100, 100 - (touchPos.y / leftJoystickContainer.height * 100)));
                gazValue = Math.round(normalizedY);

                var cursorY = centerY + (50 - normalizedY) * (leftJoystickContainer.height / 100);

                var yawSensitivityFactor = 0.7;
                var dx = (touchPos.x - centerX) * yawSensitivityFactor;
                var distanceX = Math.abs(dx);

                var x = centerX + dx;
                if (distanceX > radius) {
                    x = centerX + (dx > 0 ? radius : -radius);
                }

                leftCursor.x = x - leftCursor.width / 2;
                leftCursor.y = cursorY - leftCursor.height / 2;

                lacetValue = Math.round(((x - centerX) / radius) * 100);
            }

            function updateRightJoystick(touch) {
                var touchPos = rightJoystickContainer.mapFromItem(touchArea, touch.x, touch.y);
                var centerX = rightJoystickContainer.width / 2;
                var centerY = rightJoystickContainer.height / 2;
                var maxRadius = rightJoystickContainer.width / 2 - 15;

                var deadZoneRadius = maxRadius * 0.05;
                var effectiveRadius = maxRadius - deadZoneRadius;

                var dx = touchPos.x - centerX;
                var dy = touchPos.y - centerY;
                var distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < deadZoneRadius) {
                    rightCursor.x = centerX - rightCursor.width / 2;
                    rightCursor.y = centerY - rightCursor.height / 2;
                    tangageValue = 0;
                    roulisValue = 0;
                    return;
                }

                var angle = Math.atan2(dy, dx);
                var normalizedDistance = Math.min(1, (distance - deadZoneRadius) / effectiveRadius);
                var adjustedDistance = normalizedDistance * maxRadius;

                var x = centerX + Math.cos(angle) * adjustedDistance;
                var y = centerY + Math.sin(angle) * adjustedDistance;

                rightCursor.x = x - rightCursor.width / 2;
                rightCursor.y = y - rightCursor.height / 2;

                tangageValue = Math.round(-(y - centerY) / effectiveRadius * 100);
                roulisValue = Math.round((x - centerX) / effectiveRadius * 100);
            }

            function resetReturnToCenter() {
                leftCursor.x = (leftJoystickContainer.width - leftCursor.width) / 2;
                lacetValue = 0;

                rightCursor.x = (rightJoystickContainer.width - rightCursor.width) / 2;
                rightCursor.y = (rightJoystickContainer.height - rightCursor.height) / 2;
                tangageValue = 0;
                roulisValue = 0;
            }

            function handleRelease() {
                if ((activeLeftTouch === 1 && !touch1.pressed) ||
                        (activeLeftTouch === 2 && !touch2.pressed)) {
                    activeLeftTouch = -1;
                    leftCursor.x = (leftJoystickContainer.width - leftCursor.width) / 2;
                    lacetValue = 0;
                }

                if ((activeRightTouch === 1 && !touch1.pressed) ||
                        (activeRightTouch === 2 && !touch2.pressed)) {
                    activeRightTouch = -1;
                    rightCursor.x = (rightJoystickContainer.width - rightCursor.width) / 2;
                    rightCursor.y = (rightJoystickContainer.height - rightCursor.height) / 2;
                    tangageValue = 0;
                    roulisValue = 0;
                }

                sendCombinedRequest();
            }
        }
    }

    // Prévisualisation de la caméra modernisée
    Rectangle {
        id: cameraPreview
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 240
        height: 135
        radius: 8
        color: isDroneCameraActive ? "transparent" : surfaceColor
        visible: !isDroneCameraActive
        border.color: "#444"
        border.width: 2

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#80000000"
            radius: 12
            samples: 24
            verticalOffset: 4
        }

        Text {
            anchors.centerIn: parent
            text: "PRÉVISUALISATION CAMÉRA"
            color: "#AAAAAA"
            font {
                pixelSize: 14
                family: "Roboto"
                letterSpacing: 1
            }
            visible: !isDroneCameraActive
        }

        Button {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            width: 32
            height: 32
            text: "↻"
            font.pixelSize: 16
            visible: !isDroneCameraActive

            background: Rectangle {
                radius: width/2
                color: parent.down ? Qt.darker(primaryColor, 1.2) : primaryColor
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: parent.color = parent.color === surfaceColor ? "#2A2A2A" : surfaceColor
        }
    }

    // Menu contextuel modernisé
    Menu {
        id: menu
        width: 240
        visible: false
        topPadding: 8
        bottomPadding: 8
        leftPadding: 8
        rightPadding: 8

        background: Rectangle {
            color: surfaceColor
            radius: 8
            border.color: "#444"
            border.width: 1

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: "#80000000"
                radius: 16
                samples: 32
                verticalOffset: 4
            }
        }

        delegate: MenuItem {
            id: menuItem
            implicitHeight: 42
            implicitWidth: 200

            background: Rectangle {
                color: menuItem.highlighted ? "#333" : "transparent"
                radius: 4
            }

            contentItem: Text {
                text: menuItem.text
                font.pixelSize: 14
                font.family: "Roboto"
                color: menuItem.highlighted ? "white" : "#AAAAAA"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 16
            }

            indicator: Item {
                implicitWidth: 24
                implicitHeight: 24
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    visible: menuItem.checked
                    width: 12
                    height: 12
                    radius: 6
                    anchors.centerIn: parent
                    color: secondaryColor
                }
            }
        }

        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: "#444"
            }
        }

        Menu {
            id: rthMenu
            title: "RTH"
            width: 280

            background: Rectangle {
                color: surfaceColor
                radius: 8
                border.color: "#444"
                border.width: 1
            }

            MenuItem {
                text: "Configurer distance RTH"
                onTriggered: rthDistanceWindow.visible = true
            }

            MenuItem {
                text: "Envoyer RTH (" + rthDistance + "m)"
                onTriggered: sendCombinedRequest(true)
            }
        }

        MenuSeparator {}

        MenuItem {
            id: toggleValuesButton
            text: showValues ? "Masquer les valeurs" : "Afficher les valeurs"
            onTriggered: showValues = !showValues
        }

        MenuItem {
            text: "Paramètres serveur"
            onTriggered: serverWindow.visible = true
        }

        MenuSeparator {}

        MenuItem {
            text: "Quitter"
            onTriggered: Qt.quit()
            contentItem: Text {
                text: parent.text
                color: accentColor
                font.pixelSize: 14
                font.family: "Roboto"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 16
            }
        }

        // Fenêtre de configuration du serveur modernisée
        Window {
            id: serverWindow
            width: 400
            height: 220
            minimumWidth: 400
            minimumHeight: 220
            visible: false
            title: "Configuration du serveur"
            modality: Qt.ApplicationModal
            color: surfaceColor

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                color: "transparent"
                border.color: "#444"
                border.width: 1
                radius: 8
            }

            Column {
                spacing: 20
                anchors.centerIn: parent
                width: parent.width - 40

                Label {
                    text: "ADRESSE DU SERVEUR"
                    font {
                        pixelSize: 14
                        family: "Roboto"
                        letterSpacing: 1
                        bold: true
                    }
                    color: "#AAAAAA"
                }

                TextField {
                    id: serverInput
                    width: parent.width
                    height: 48
                    text: serverAddress
                    placeholderText: "ex: 192.168.1.100:8080"
                    font.pixelSize: 14
                    padding: 12
                    color: "white"
                    selectionColor: primaryColor
                    selectedTextColor: "white"

                    background: Rectangle {
                        color: "#333"
                        radius: 4
                        border.color: serverInput.focus ? primaryColor : "#555"
                        border.width: 1
                    }
                }

                Row {
                    spacing: 12
                    anchors.right: parent.right

                    Button {
                        text: "ANNULER"
                        width: 120
                        height: 40
                        onClicked: serverWindow.visible = false

                        background: Rectangle {
                            color: parent.down ? "#333" : "#444"
                            radius: 4
                            border.color: "#555"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "ENREGISTRER"
                        width: 120
                        height: 40
                        onClicked: {
                            serverAddress = serverInput.text
                            console.log("Nouvelle adresse du serveur : " + serverAddress)
                            serverWindow.visible = false
                        }

                        background: Rectangle {
                            color: parent.down ? Qt.darker(primaryColor, 1.2) : primaryColor
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Fenêtre de configuration RTH modernisée
        Window {
            id: rthDistanceWindow
            width: 400
            height: 240
            minimumWidth: 400
            minimumHeight: 240
            visible: false
            title: "Configuration distance RTH"
            modality: Qt.ApplicationModal
            color: surfaceColor

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                color: "transparent"
                border.color: "#444"
                border.width: 1
                radius: 8
            }

            Column {
                spacing: 20
                anchors.centerIn: parent
                width: parent.width - 40

                Label {
                    text: "DISTANCE DE RETOUR (20m - 100m)"
                    font {
                        pixelSize: 14
                        family: "Roboto"
                        letterSpacing: 1
                        bold: true
                    }
                    color: "#AAAAAA"
                }

                Slider {
                    id: rthDistanceSlider
                    width: parent.width
                    from: 20
                    to: 100
                    stepSize: 1
                    value: rthDistance
                    onValueChanged: rthDistanceValue.text = Math.round(value) + "m"

                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        implicitWidth: parent.width
                        implicitHeight: 4
                        width: parent.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#444"

                        Rectangle {
                            width: parent.width * (rthDistanceSlider.visualPosition)
                            height: parent.height
                            color: secondaryColor
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: rthDistanceSlider.leftPadding + rthDistanceSlider.visualPosition * (rthDistanceSlider.availableWidth - width)
                        y: rthDistanceSlider.topPadding + rthDistanceSlider.availableHeight / 2 - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: rthDistanceSlider.pressed ? Qt.lighter(secondaryColor, 1.2) : secondaryColor
                        border.color: Qt.lighter(secondaryColor, 1.4)
                        border.width: 2

                        layer.enabled: true
                        layer.effect: DropShadow {
                            transparentBorder: true
                            color: "#80000000"
                            radius: 8
                            samples: 16
                            verticalOffset: 2
                        }
                    }
                }

                Text {
                    id: rthDistanceValue
                    text: rthDistance + "m"
                    font {
                        pixelSize: 18
                        family: "Roboto"
                        bold: true
                    }
                    color: secondaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: 12
                    anchors.right: parent.right

                    Button {
                        text: "ANNULER"
                        width: 120
                        height: 40
                        onClicked: rthDistanceWindow.visible = false

                        background: Rectangle {
                            color: parent.down ? "#333" : "#444"
                            radius: 4
                            border.color: "#555"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "ENREGISTRER"
                        width: 120
                        height: 40
                        onClicked: {
                            rthDistance = Math.round(rthDistanceSlider.value)
                            console.log("Nouvelle distance RTH : " + rthDistance + "m")
                            rthDistanceWindow.visible = false
                        }

                        background: Rectangle {
                            color: parent.down ? Qt.darker(primaryColor, 1.2) : primaryColor
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    // Fonctions inchangées
    function sendCombinedRequest(isRestartClicked) {
        var restartValue = isRestartClicked ? 1 : 0
        var url = serverAddress + "?gaz=" + gazValue / 50 +
                "&lacet=" + lacetValue /300 +
                "&tangage=" + tangageValue /300 +
                "&roulis=" + roulisValue /300 +
                "&restart=" + restartValue +
                "&rth_distance=" + rthDistance
        console.log("Envoi de la requête: " + url)
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url, true)
        xhr.send()
        console.log("Gaz:", gazValue, "Lacet:", lacetValue, "Tangage:", tangageValue, "Roulis:", roulisValue);
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "http://172.18.58.98:8080/?", true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        isConnected = true;
                    } else {
                        isConnected = false;
                    }
                }
            }
            xhr.send();
        }
    }
}
