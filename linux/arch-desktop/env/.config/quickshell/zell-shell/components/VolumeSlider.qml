import QtQuick
import QtQuick.Controls

import "../theme"

Slider {
    id: root

    property color accent: Theme.cyan

    from: 0
    to: 100
    stepSize: 1

    implicitHeight: 30
    enabled: true

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2

        width: root.availableWidth
        height: 8

        radius: 4
        color: "#343443"

        Rectangle {
            width: parent.width * root.visualPosition
            height: parent.height
            radius: parent.radius
            color: root.accent
        }
    }

    handle: Rectangle {
        x: root.leftPadding
           + root.visualPosition
           * (root.availableWidth - width)

        y: root.topPadding
           + root.availableHeight / 2 - height / 2

        width: 18
        height: 18
        radius: 9

        color: root.pressed
            ? "#ffffff"
            : root.accent

        border.width: 2
        border.color: Theme.background

        scale: root.pressed ? 1.15 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
            }
        }
    }
}
