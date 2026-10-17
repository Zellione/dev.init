import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"

PopupWindow {
    id: popup

    required property Item targetItem

    visible: false
    grabFocus: true

    implicitWidth: 480
    implicitHeight: 700

    color: "transparent"

    property int currentTab: 0

    anchor {
        item: popup.targetItem
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.color: "#343443"
        border.width: 1
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { title: "Hardware", index: 0 },
                        { title: "Audio", index: 1 },
                        { title: "Devices", index: 2 }
                    ]

                    delegate: Rectangle {
                        id: tabButton

                        required property var modelData

                        readonly property bool selected:
                            popup.currentTab === modelData.index

                        implicitWidth: tabLabel.implicitWidth + 26
                        implicitHeight: 36
                        radius: Theme.cornerRadius

                        color: selected
                            ? "#19303c"
                            : Theme.surface

                        Text {
                            id: tabLabel
                            anchors.centerIn: parent

                            text: tabButton.modelData.title

                            color: tabButton.selected
                                ? Theme.cyan
                                : Theme.muted

                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontNormal
                            font.bold: tabButton.selected
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                popup.currentTab =
                                    tabButton.modelData.index
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "×"
                    color: Theme.muted
                    font.pixelSize: 24

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.visible = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#343443"
            }

            // Panel content
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: popup.currentTab

                HardwarePanel {
                }

                AudioPanel {
                }

                DevicePanel {
                }
            }
        }
    }
}
