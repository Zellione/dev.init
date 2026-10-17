import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Rectangle {
    id: root

    implicitWidth: content.implicitWidth + 24
    implicitHeight: 34

    radius: Theme.cornerRadius
    color: "#19303c"

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 14

        Text {
            text: "CPU " + Hardware.cpuUsage + "%"
            color: Hardware.cpuUsage >= 90
                ? Theme.danger
                : Hardware.cpuUsage >= 70
                    ? "#ebcb8b"
                    : Theme.cyan

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: "RAM " + Hardware.memoryUsage + "%"
            color: Hardware.memoryUsage >= 90
                ? Theme.danger
                : Hardware.memoryUsage >= 75
                    ? "#ebcb8b"
                    : Theme.cyan

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: Hardware.cpuTemperature < 0
                ? "--°C"
                : Hardware.cpuTemperature + "°C"

            color: Hardware.cpuTemperature >= 85
                ? Theme.danger
                : Theme.cyan

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
