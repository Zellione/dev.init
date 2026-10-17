import QtQuick
import QtQuick.Layouts
import "../theme"
import "."

Rectangle {
    id: root

    property string title: ""
    property string value: ""
    property real percentage: 0

    property color accent: Theme.cyan
    property color cardBackground: "#19303c"
    property color trackColor: "#30424b"

    property bool showBar: true

    implicitHeight: 118
    radius: 9
    color: cardBackground

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        Text {
            text: root.title
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
        }

        Text {
            text: root.value
            color: root.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontLarge
            font.bold: true
        }

        MetricBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 5
            Layout.topMargin: 3

            visible: root.showBar
            value: root.percentage
            accent: root.accent
            trackColor: root.trackColor
        }
    }
}
