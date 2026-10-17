import QtQuick
import Quickshell

import "../theme"

PopupWindow {
    id: tooltip

    required property Item targetItem

    property string tooltipText: ""
    property bool hovered: false

    visible: false
    grabFocus: false

    implicitWidth: Math.min(420, tooltipLabel.implicitWidth + 28)
    implicitHeight: tooltipLabel.implicitHeight + 20

    color: "transparent"

    anchor {
        item: tooltip.targetItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.SlideX
    }

    onHoveredChanged: {
        if (!hovered)
            visible = false;
    }

    Timer {
        interval: 450
        repeat: false

        running: tooltip.hovered && !tooltip.visible

        onTriggered: {
            if (tooltip.hovered && tooltip.tooltipText !== "")
                tooltip.visible = true;
        }
    }

    Rectangle {
        anchors.fill: parent

        radius: Theme.cornerRadius
        color: Theme.background
        border.color: "#343443"
        border.width: 1

        Text {
            id: tooltipLabel

            anchors.centerIn: parent
            width: parent.width - 28

            text: tooltip.tooltipText
            color: Theme.foreground

            font.family: Theme.fontFamily
            font.pixelSize: 23

            wrapMode: Text.Wrap
        }
    }
}
