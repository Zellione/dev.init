import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"
import "../components"

Item {
    id: root

    Flickable {
        anchors.fill: parent
        clip: true

        contentWidth: width
        contentHeight: hardwareContent.implicitHeight

        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: hardwareContent
            width: parent.width
            spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "CPU & MEMORY"
                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: "Ryzen 7 9800X3D"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MetricCard {
                Layout.fillWidth: true
                title: "CPU Load"
                value: Hardware.cpuUsage + "%"
                percentage: Hardware.cpuUsage
                accent: Theme.cyan
            }

            MetricCard {
                Layout.fillWidth: true
                title: "RAM Usage"
                value: Hardware.memoryUsage + "%"
                percentage: Hardware.memoryUsage
                accent: Theme.cyan
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "CPU Temperature"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                Layout.fillWidth: true
            }

            Text {
                text: Hardware.cpuTemperature < 0
                    ? "N/A"
                    : Hardware.cpuTemperature + "°C"

                color: Hardware.cpuTemperature >= 85
                    ? Theme.danger
                    : Theme.cyan

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#343443"
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "NVIDIA GPU"
                color: Theme.violet
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: "RTX 5090"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MetricCard {
                Layout.fillWidth: true
                title: "GPU Load"
                value: Hardware.gpuAvailable
                    ? Hardware.gpuUsage + "%"
                    : "N/A"

                percentage: Hardware.gpuAvailable
                    ? Hardware.gpuUsage
                    : 0

                accent: Theme.violet
                cardBackground: "#292438"
                trackColor: "#3c354b"
            }

            MetricCard {
                Layout.fillWidth: true
                title: "VRAM"
                value: Hardware.gpuAvailable
                    ? Hardware.gpuMemoryUsed.toFixed(1) + " GiB"
                    : "N/A"

                percentage: Hardware.gpuAvailable
                    && Hardware.gpuMemoryTotal > 0
                    ? 100 * Hardware.gpuMemoryUsed
                        / Hardware.gpuMemoryTotal
                    : 0

                accent: Theme.violet
                cardBackground: "#292438"
                trackColor: "#3c354b"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [
                    {
                        label: "TEMPERATURE",
                        value: Hardware.gpuAvailable
                            ? Hardware.gpuTemperature + "°C"
                            : "N/A"
                    },
                    {
                        label: "POWER",
                        value: Hardware.gpuAvailable
                            && Hardware.gpuPower >= 0
                            ? Hardware.gpuPower.toFixed(1) + " W"
                            : "N/A"
                    },
                    {
                        label: "P-STATE",
                        value: Hardware.gpuAvailable
                            ? Hardware.gpuPstate
                            : "N/A"
                    }
                ]

                delegate: Item {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: metricColumn.implicitHeight

                    ColumnLayout {
                        id: metricColumn
                        anchors.fill: parent
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: modelData.label
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.value
                            color: Theme.violet
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#343443"
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "NETWORK TRAFFIC"
                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: Network.connected
                    ? Network.interfaceName
                    : "Offline"

                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MetricCard {
                Layout.fillWidth: true
                title: "Download"
                value: Network.connected
                    ? Network.formatBits(Network.downloadBps)
                    : "N/A"

                accent: Theme.cyan
                showBar: false
            }

            MetricCard {
                Layout.fillWidth: true
                title: "Upload"
                value: Network.connected
                    ? Network.formatBits(Network.uploadBps)
                    : "N/A"

                accent: Theme.cyan
                showBar: false
            }
        }
        }
    }
}
