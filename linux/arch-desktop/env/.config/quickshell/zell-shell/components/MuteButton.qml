import QtQuick
import QtQuick.Controls

import "../theme"

Button {
    id: root

    property bool muted: false
    property color accent: Theme.cyan

    implicitWidth: 100
    implicitHeight: 36

    text: muted ? "Unmute" : "Mute"

    contentItem: Text {
        text: root.text

        color: root.muted
            ? Theme.danger
            : Theme.foreground

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        font.bold: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: Theme.cornerRadius

        color: root.muted
            ? "#38232b"
            : root.down
                ? "#303946"
                : Theme.surface

        border.width: 1

        border.color: root.muted
            ? Theme.danger
            : root.hovered
                ? root.accent
                : "#343443"
    }
}
