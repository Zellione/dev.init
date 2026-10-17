import QtQuick

Rectangle {
    id: root

    property real value: 0
    property color accent: "#7dd3fc"
    property color trackColor: "#30424b"

    implicitHeight: 5
    radius: height / 2
    color: trackColor
    clip: true

    Rectangle {
        width: parent.width * Math.max(
            0, Math.min(100, root.value)
        ) / 100
        height: parent.height

        radius: parent.radius
        color: root.accent

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
    }
}
