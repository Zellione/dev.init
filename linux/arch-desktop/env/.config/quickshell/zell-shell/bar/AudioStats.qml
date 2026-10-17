import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../components"
import "../theme"
import "../services"

Rectangle {
    id: root

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 34

    radius: Theme.cornerRadius
    color: Theme.surface

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: Audio.outputMuted ? "󰝟" : "󰕾"

            color: Audio.outputMuted
                ? Theme.muted
                : Theme.foreground

            font.family: Theme.fontFamily
            font.pixelSize: 18
        }

        Text {
            text: Audio.ready
                ? Audio.outputVolume + "%"
                : "..."

            color: Audio.outputMuted
                ? Theme.muted
                : Theme.foreground

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: Audio.inputMuted ? "󰍭" : "󰍬"

            color: Audio.inputMuted
                ? Theme.danger
                : Theme.muted

            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        enabled: Audio.outputAvailable
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Audio.toggleOutputMute();
        }

        onWheel: function(wheel) {
            const steps = wheel.angleDelta.y / 120;
            if (steps === 0)
                return;

            Audio.setOutputVolume(
                Audio.outputVolume + steps * 2
            );

            wheel.accepted = true;
        }
    }

    ZellTooltip {
        targetItem: root
        hovered: mouseArea.containsMouse

        tooltipText:
            "Output: " + Audio.outputName
            + "\nVolume: " + Audio.outputVolume + "%"
            + (Audio.outputMuted ? " (Muted)" : "")
            + "\n\nInput: " + Audio.inputName
            + "\nVolume: " + Audio.inputVolume + "%"
            + (Audio.inputMuted ? " (Muted)" : "")
    }
}
