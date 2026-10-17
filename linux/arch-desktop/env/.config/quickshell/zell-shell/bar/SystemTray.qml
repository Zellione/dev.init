import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

import "../theme"

Row {
    id: root

    required property var panelWindow

    spacing: 5

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayEntry

            required property var modelData

            width: 34
            height: 34
            radius: Theme.cornerRadius
            color: mouseArea.containsMouse
                ? "#343443"
                : Theme.surface

            Image {
                anchors.centerIn: parent
                width: 21
                height: 21

                source: trayEntry.modelData.icon
                sourceSize: Qt.size(32, 32)
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            function openMenu() {
                if (!modelData.hasMenu)
                    return;

                const position = trayEntry.mapToItem(
                    root.panelWindow.contentItem,
                    0,
                    trayEntry.height
                );

                modelData.display(
                    root.panelWindow,
                    Math.round(position.x),
                    Math.round(position.y)
                );
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons:
                    Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        trayEntry.openMenu();
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayEntry.modelData.secondaryActivate();
                    } else if (trayEntry.modelData.onlyMenu) {
                        trayEntry.openMenu();
                    } else {
                        trayEntry.modelData.activate();
                    }
                }

                onWheel: wheel => {
                    trayEntry.modelData.scroll(
                        wheel.angleDelta.y,
                        false
                    );
                }
            }
        }
    }
}
