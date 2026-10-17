import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"
import "../services"

Rectangle {
    id: root

    implicitWidth: content.implicitWidth + 18
    implicitHeight: 34
    radius: Theme.cornerRadius
    color: Theme.surface

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: !Network.connected
                ? "Offline"
                : "↓ " + Network.formatBits(Network.downloadBps)

            color: Network.connected
                ? Theme.foreground
                : Theme.danger

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
        }

        Text {
            visible: Network.connected

            text: "↑ " + Network.formatBits(Network.uploadBps)
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
        }

        Text {
            visible: Network.connected
            text: Network.wireless ? "" : "󰈀"

            color: Theme.cyan
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ZellTooltip {
        targetItem: root
        hovered: mouseArea.containsMouse

        tooltipText: Network.connected
            ? "Interface: " + Network.interfaceName
            : "No default network route"
    }
}
