import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../theme"
import "../services"

Item {
    id: root

    Flickable {
        anchors.fill: parent
        clip: true

        contentWidth: width
        contentHeight: deviceColumn.implicitHeight

        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: deviceColumn

            width: parent.width
            spacing: 12

            // =========================
            // Corsair Virtuoso battery
            // =========================

            Text {
                text: "WIRELESS HEADSET"

                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Rectangle {
                width: deviceColumn.width
                height: 108
                radius: Theme.cornerRadius
                color: Theme.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        width: parent.width

                        Text {
                            Layout.fillWidth: true
                            text: "Corsair Virtuoso Wireless"
                            elide: Text.ElideRight

                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                            font.bold: true
                        }

                        Text {
                            text: Virtuoso.hasReading
                                ? Virtuoso.batteryPercent + "%"
                                : "--"

                            color: !Virtuoso.isFresh
                                ? Theme.muted
                                : Virtuoso.batteryPercent <= 20
                                    ? "#f5a35a"
                                    : Theme.cyan

                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 7
                        radius: 4
                        color: "#343443"
                        clip: true

                        Rectangle {
                            width: parent.width
                                * (Virtuoso.hasReading
                                    ? Virtuoso.batteryPercent / 100
                                    : 0)

                            height: parent.height
                            radius: 4

                            color: !Virtuoso.isFresh
                                ? Theme.muted
                                : Virtuoso.batteryPercent <= 20
                                    ? "#f5a35a"
                                    : Theme.cyan
                        }
                    }

                    RowLayout {
                        width: parent.width

                        Text {
                            Layout.fillWidth: true
                            text: Virtuoso.ageText

                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }

                        Text {
                            text: !Virtuoso.isFresh
                                ? "Status outdated"
                                : Virtuoso.charging === true
                                    ? "Charging"
                                    : Virtuoso.charging === false
                                        ? "On battery"
                                        : "Charging status unknown"

                            color: Virtuoso.isFresh
                                ? Theme.cyan
                                : Theme.muted

                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#343443"
            }

            // =========================
            // Output devices
            // =========================

            Text {
                text: "OUTPUT DEVICES"

                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Repeater {
                model: Pipewire.nodes

                delegate: Rectangle {
                    id: outputRow

                    required property var modelData

                    readonly property bool candidate:
                        modelData.audio !== null
                        && !modelData.isStream
                        && modelData.isSink
                        && !modelData.name.endsWith(".monitor")

                    readonly property bool current:
                        modelData === Pipewire.defaultAudioSink

                    readonly property bool selectable:
                        Audio.isSelectableOutput(modelData)

                    readonly property bool virtualDevice:
                        modelData.name.startsWith("easyeffects_")

                    width: deviceColumn.width
                    height: candidate ? 72 : 0
                    visible: candidate

                    radius: Theme.cornerRadius

                    color: current
                        ? "#19303c"
                        : Theme.surface

                    border.width: current ? 1 : 0
                    border.color: Theme.cyan

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        RowLayout {
                            width: parent.width

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight

                                text: outputRow.modelData.description
                                    || outputRow.modelData.name

                                color: outputRow.current
                                    ? Theme.cyan
                                    : Theme.foreground

                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSmall
                            }

                            Text {
                                text: outputRow.current
                                    ? "DEFAULT"
                                    : ""

                                color: Theme.cyan
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Text {
                            width: parent.width
                            elide: Text.ElideRight

                            text: outputRow.virtualDevice
                                ? "Virtual / EasyEffects"
                                : outputRow.modelData.name

                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }

                    // MouseArea is a direct child
                    // of the delegate Rectangle.
                    MouseArea {
                        anchors.fill: parent
                    
                        enabled: true
                        cursorShape: Qt.PointingHandCursor
                    
                        onClicked: {
                            console.log(
                                "[Devices] Click:",
                                outputRow.modelData.name,
                                "selectable:",
                                outputRow.selectable,
                                "current:",
                                outputRow.current
                            );
                    
                            if (outputRow.selectable && !outputRow.current) {
                                console.log("[Devices] Calling selectOutput");
                                Audio.selectOutput(outputRow.modelData);
                            }
                        }
                    }
                }
            }

            // =========================
            // Separator
            // =========================

            Rectangle {
                width: parent.width
                height: 1
                color: "#343443"
            }

            // =========================
            // Input devices
            // =========================

            Text {
                text: "INPUT DEVICES"

                color: Theme.violet
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Repeater {
                model: Pipewire.nodes

                delegate: Rectangle {
                    id: inputRow

                    required property var modelData

                    readonly property bool candidate:
                        modelData.audio !== null
                        && !modelData.isStream
                        && !modelData.isSink
                        && !modelData.name.endsWith(".monitor")

                    readonly property bool current:
                        modelData === Pipewire.defaultAudioSource

                    readonly property bool selectable:
                        Audio.isSelectableInput(modelData)

                    readonly property bool virtualDevice:
                        modelData.name.startsWith("easyeffects_")

                    width: deviceColumn.width
                    height: candidate ? 72 : 0
                    visible: candidate

                    radius: Theme.cornerRadius

                    color: current
                        ? "#292438"
                        : Theme.surface

                    border.width: current ? 1 : 0
                    border.color: Theme.violet

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        RowLayout {
                            width: parent.width

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight

                                text: inputRow.modelData.description
                                    || inputRow.modelData.name

                                color: inputRow.current
                                    ? Theme.violet
                                    : Theme.foreground

                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSmall
                            }

                            Text {
                                text: inputRow.current
                                    ? "DEFAULT"
                                    : ""

                                color: Theme.violet
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Text {
                            width: parent.width
                            elide: Text.ElideRight

                            text: inputRow.virtualDevice
                                ? "Virtual / EasyEffects"
                                : inputRow.modelData.name

                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }

                    // MouseArea is a direct child
                    // of the delegate Rectangle.
                    MouseArea {
                        anchors.fill: parent

                        enabled: inputRow.selectable
                            && !inputRow.current

                        cursorShape: enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            Audio.selectInput(
                                inputRow.modelData
                            );
                        }
                    }
                }
            }
        }
    }
}
