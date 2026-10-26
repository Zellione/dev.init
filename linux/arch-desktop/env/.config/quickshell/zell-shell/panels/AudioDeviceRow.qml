import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../theme"
import "../services"

Rectangle {
    id: root

    required property var modelData

    property bool inputDevice: false
    property bool managed: false

    readonly property bool candidate:
        modelData !== null
        && modelData.audio !== null
        && !modelData.isStream
        && (inputDevice ? !modelData.isSink : modelData.isSink)
        && !modelData.name.endsWith(".monitor")
        && (
            managed
                ? !modelData.name.startsWith(
                    inputDevice ? "alsa_input." : "alsa_output."
                )
                : modelData.name.startsWith(
                    inputDevice ? "alsa_input." : "alsa_output."
                )
        )

    readonly property bool current:
        modelData === (
            inputDevice
                ? Pipewire.defaultAudioSource
                : Pipewire.defaultAudioSink
        )

    readonly property string portAvailability:
        AudioPorts.forNode(modelData.name, inputDevice)
    
    readonly property bool unavailable:
        portAvailability === "unavailable"

    readonly property bool selectable:
        candidate
        && !managed
        && !unavailable
        && Pipewire.ready
        && VrAudio.known
        && !VrAudio.active
        && !VrAudio.pending
        && !current

    width: parent ? parent.width : 0
    height: candidate ? 72 : 0
    visible: candidate

    radius: Theme.cornerRadius

    color: current
        ? (inputDevice ? "#292438" : "#19303c")
        : Theme.surface

    border.width: current ? 1 : 0
    border.color: inputDevice ? Theme.violet : Theme.cyan

    opacity: root.managed
        || root.unavailable
        || !VrAudio.known
        || VrAudio.active
        || VrAudio.pending
            ? 0.45 : 1.0

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        RowLayout {
            width: parent.width

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight

                text: root.modelData.description
                    || root.modelData.name

                color: root.current
                    ? (root.inputDevice ? Theme.violet : Theme.cyan)
                    : Theme.foreground

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Text {
                text: root.unavailable
                    ? "UNAVAILABLE"
                    : root.current
                        ? "DEFAULT"
                        : root.managed
                            ? "READ ONLY"
                            : ""

                color: root.unavailable
                    ? Theme.muted
                    : root.current
                        ? (root.inputDevice ? Theme.violet : Theme.cyan)
                        : Theme.muted

                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
            }
        }

        Text {
            width: parent.width
            elide: Text.ElideRight

            text: root.managed
                ? "Virtual / Managed · " + root.modelData.name
                : root.modelData.name

            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.selectable

        cursorShape: enabled
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor

        onClicked: {
            if (root.inputDevice)
                Audio.selectInput(root.modelData);
            else
                Audio.selectOutput(root.modelData);
        }
    }
}
