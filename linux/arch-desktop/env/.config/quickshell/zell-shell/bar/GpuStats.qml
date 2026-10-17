import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Rectangle {
    id: root

    implicitWidth: content.implicitWidth + 24
    implicitHeight: 34

    radius: Theme.cornerRadius
    color: "#292438"

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 14

        Text {
            text: Hardware.gpuAvailable
                ? "GPU " + Hardware.gpuUsage + "%"
                : "GPU N/A"

            color: Theme.violet
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            visible: Hardware.gpuAvailable

            text: Hardware.gpuTemperature + "°C"
            color: Theme.violet

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            visible: Hardware.gpuAvailable && Hardware.gpuPower >= 0

            text: Hardware.gpuPower.toFixed(0) + " W"
            color: Theme.violet

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            visible: Hardware.gpuAvailable

            text: "VRAM "
                + Hardware.gpuMemoryUsed.toFixed(1)
                + "/"
                + Hardware.gpuMemoryTotal.toFixed(1)
                + "G"

            color: Theme.violet
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
