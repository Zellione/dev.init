import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../theme"

RowLayout {
    id: root

    required property var screen

    spacing: 4

    readonly property var monitor: Hyprland.monitorFor(screen)

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: workspaceButton

            required property var modelData

            readonly property bool onThisMonitor:
                root.monitor !== null
                && modelData.monitor !== null
                && modelData.monitor.name === root.monitor.name

            readonly property bool focused:
                onThisMonitor
                && Hyprland.focusedWorkspace !== null
                && modelData.id === Hyprland.focusedWorkspace.id

            visible: onThisMonitor
            Layout.preferredWidth: onThisMonitor ? 38 : 0
            Layout.preferredHeight: 34

            radius: Theme.cornerRadius

            color: workspaceButton.focused
                ? "#193241"
                : "transparent"

            Text {
                anchors.centerIn: parent

                text: workspaceButton.modelData.name

                color: workspaceButton.focused
                    ? Theme.cyan
                    : Theme.muted

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: workspaceButton.focused
            }

            MouseArea {
                anchors.fill: parent
                enabled: workspaceButton.onThisMonitor
                cursorShape: Qt.PointingHandCursor

                onClicked: workspaceButton.modelData.activate()
            }
        }
    }
}
