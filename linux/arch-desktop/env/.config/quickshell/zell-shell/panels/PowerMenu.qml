import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../theme"

PopupWindow {
    id: popup

    required property Item targetItem

    visible: false
    grabFocus: true

    implicitWidth: 180
    implicitHeight: confirmation !== "" ? 180 : 260

    color: "transparent"

    property string confirmation: ""

    function closeMenu() {
        confirmation = "";
        visible = false;
    }

    function execute(command) {
        action.command = command;
        action.running = true;
        closeMenu();
    }

    Process {
        id: action
    }

    anchor {
        item: popup.targetItem
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.background
        border.color: "#343443"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                text: popup.confirmation === ""
                    ? "POWER"
                    : "CONFIRM " + popup.confirmation.toUpperCase()

                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#343443"
            }

            Repeater {
                model: popup.confirmation === ""
                    ? [
                        { label: "Lock", icon: "󰌾", action: "lock" },
                        { label: "Logout", icon: "󰍃", action: "logout" },
                        { label: "Reboot", icon: "󰜉", action: "reboot" },
                        { label: "Shutdown", icon: "󰐥", action: "shutdown" }
                    ]
                    : [
                        { label: "Cancel", icon: "󰜺", action: "cancel" },
                        { label: "Confirm", icon: "󰄬", action: "confirm" }
                    ]

                delegate: Rectangle {
                    id: entry

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: Theme.cornerRadius

                    color: mouseArea.containsMouse
                        ? "#343443"
                        : Theme.surface

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 12
                        spacing: 6

                        Text {
                            Layout.preferredWidth: 26
                            Layout.alignment: Qt.AlignVCenter

                            text: entry.modelData.icon
                            color: Theme.violet
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontHeading
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            text: entry.modelData.label
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontNormal
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            const selected = entry.modelData.action;

                            if (selected === "cancel") {
                                popup.confirmation = "";
                                return;
                            }

                            if (selected === "confirm") {
                                if (popup.confirmation === "reboot")
                                    popup.execute(["systemctl", "reboot"]);
                                else if (popup.confirmation === "shutdown")
                                    popup.execute(["systemctl", "poweroff"]);
                                return;
                            }

                            if (selected === "lock") {
                                popup.execute(["loginctl", "lock-session"]);
                            } else if (selected === "logout") {
                                popup.execute(["uwsm", "stop"]);
                            } else {
                                popup.confirmation = selected;
                            }
                        }
                    }
                }
            }
        }
    }
}
