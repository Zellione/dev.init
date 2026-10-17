import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"
import "../components"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        // Audio output
        Text {
            text: "AUDIO OUTPUT"
            color: Theme.cyan
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontNormal
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 165

            radius: Theme.cornerRadius
            color: Theme.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: Audio.outputName
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: Audio.outputVolume + "%"
                        color: Audio.outputMuted
                            ? Theme.muted : Theme.cyan
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontHeading
                        font.bold: true

                        Layout.fillWidth: true
                    }

                    MuteButton {
                        muted: Audio.outputMuted
                        accent: Theme.cyan
                        enabled: Audio.outputAvailable

                        onClicked: Audio.toggleOutputMute()
                    }
                }

                VolumeSlider {
                    Layout.fillWidth: true

                    accent: Theme.cyan
                    enabled: Audio.outputAvailable
                    value: Audio.outputVolume

                    onMoved: Audio.setOutputVolume(value)
                }
            }
        }

        // Microphone
        Text {
            text: "MICROPHONE"
            color: Theme.violet
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontNormal
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 165

            radius: Theme.cornerRadius
            color: Theme.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: Audio.inputName
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: Audio.inputVolume + "%"
                        color: Audio.inputMuted
                            ? Theme.muted : Theme.violet
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontHeading
                        font.bold: true

                        Layout.fillWidth: true
                    }

                    MuteButton {
                        muted: Audio.inputMuted
                        accent: Theme.violet
                        enabled: Audio.inputAvailable

                        onClicked: Audio.toggleInputMute()
                    }
                }

                VolumeSlider {
                    Layout.fillWidth: true

                    accent: Theme.violet
                    enabled: Audio.inputAvailable
                    value: Audio.inputVolume

                    onMoved: Audio.setInputVolume(value)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
