import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import "../theme"
import "../services"

Item {
    id: root

    readonly property real preferredHeight:
        deviceColumn.implicitHeight

    function sortedPhysical(input, states, defaultNode, nodes) {
        const prefix = input ? "alsa_input." : "alsa_output.";

        function rank(node) {
            if (node === defaultNode)
                return 0;

            const state = states[node.name] || "unknown";

            if (state === "available")
                return 1;

            if (state === "unavailable")
                return 3;

            return 2;
        }

        return [...nodes]
            .filter(node =>
                node.audio !== null
                && !node.isStream
                && (input ? !node.isSink : node.isSink)
                && node.name.startsWith(prefix)
            )
            .sort((a, b) =>
                rank(a) - rank(b)
                || (a.description || a.name).localeCompare(
                    b.description || b.name
                )
            );
    }

ScriptModel {
    id: sortedOutputs

    values: root.sortedPhysical(
        false,
        AudioPorts.sinkStates,
        Pipewire.defaultAudioSink,
        Pipewire.nodes.values
    )
}

ScriptModel {
    id: sortedInputs

    values: root.sortedPhysical(
        true,
        AudioPorts.sourceStates,
        Pipewire.defaultAudioSource,
        Pipewire.nodes.values
    )
}

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
            // VR audio automation
            // =========================

            Text {
                text: "VR AUDIO AUTOMATION"

                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Rectangle {
                width: deviceColumn.width
                height: 76
                radius: Theme.cornerRadius
                color: Theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Automatic device switching"
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            text: VrAudio.pending
                                ? "Updating..."
                                : VrAudio.errorMessage !== ""
                                    ? VrAudio.errorMessage
                                    : !VrAudio.known
                                        ? "Service status unknown"
                                        : VrAudio.active
                                            ? "Active · Device selection locked"
                                            : "Inactive · Manual selection enabled"

                            color: VrAudio.errorMessage !== ""
                                ? Theme.danger : Theme.muted

                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }

                    Rectangle {
                        id: vrToggle

                        width: 46
                        height: 26
                        radius: 13

                        readonly property bool enabled:
                            VrAudio.known && !VrAudio.pending

                        opacity: enabled ? 1 : 0.5

                        color: VrAudio.active
                            ? Theme.cyan : "#343443"

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10

                            x: VrAudio.active ? parent.width - width - 3 : 3
                            anchors.verticalCenter: parent.verticalCenter

                            color: Theme.background

                            Behavior on x {
                                NumberAnimation {
                                    duration: 130
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: vrToggle.enabled
                            cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                            onClicked: VrAudio.toggle()
                        }
                    }
                }
            }

            // =========================
            // Physical output devices
            // =========================

            Text {
                text: "OUTPUT DEVICES"
                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Repeater {
                model: sortedOutputs

                delegate: AudioDeviceRow {
                    inputDevice: false
                    managed: false
                }
            }

            // =========================
            // Physical input devices
            // =========================

            Rectangle {
                width: deviceColumn.width
                height: 1
                color: "#343443"
            }

            Text {
                text: "INPUT DEVICES"
                color: Theme.violet
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Repeater {
                model: sortedInputs

                delegate: AudioDeviceRow {
                    inputDevice: true
                    managed: false
                }
            }

            // =========================
            // Managed / virtual devices
            // =========================

            Rectangle {
                width: deviceColumn.width
                height: 1
                color: "#343443"
            }

            Text {
                text: "VIRTUAL / MANAGED DEVICES"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Repeater {
                model: Pipewire.nodes

                delegate: AudioDeviceRow {
                    inputDevice: false
                    managed: true
                }
            }

            Repeater {
                model: Pipewire.nodes

                delegate: AudioDeviceRow {
                    inputDevice: true
                    managed: true
                }
            }
        }
    }
}
