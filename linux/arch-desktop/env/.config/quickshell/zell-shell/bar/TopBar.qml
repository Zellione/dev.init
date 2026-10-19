import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../panels"

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        left: true
        right: true
        top: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: Qt.rgba(
        Theme.background.r,
        Theme.background.g,
        Theme.background.b,
        0.90
    )

    property bool showInfo: false
    property string currentTime: ""

    function updateClock() {
        currentTime = Qt.formatDateTime(
            new Date(),
            "ddd, dd.MM.yyyy  HH:mm"
        )
    }

    Component.onCompleted: updateClock()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: bar.updateClock()
    }

    // Left: Hyprland workspaces
    Workspaces {
        id: workspaces
    
        screen: bar.modelData
    
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    // Center: Clock
    Rectangle {
        id: clockBox
        anchors.centerIn: parent
    
        width: clockLabel.implicitWidth + 24
        height: 34
        radius: Theme.cornerRadius
        color: Theme.surface
    
        Text {
            id: clockLabel
            anchors.centerIn: parent
            text: bar.currentTime
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    ControlCenter {
        id: dashboard
        targetItem: controlButton
        targetScreen: bar.modelData
    }

    PowerMenu {
        id: powerMenu
        targetItem: powerButton
    }

    Rectangle {
        id: powerButton

        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        width: 38
        height: 34
        radius: Theme.cornerRadius
        color: Theme.surface

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            color: Theme.danger
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontHeading
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                powerMenu.confirmation = "";
                powerMenu.visible = !powerMenu.visible;
            }
        }
    }

    // Right: Future Control Center
    Rectangle {
        id: controlButton

        anchors.right: powerButton.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        width: 38
        height: 34
        radius: Theme.cornerRadius

        color: bar.showInfo
            ? "#39304b"
            : Theme.surface

        Text {
            id: controlLabel
            anchors.centerIn: parent
            text: "󰒓"
            color: Theme.violet
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
        
            onClicked: {
                dashboard.visible = !dashboard.visible
            }
        }
    }

    // System tray
    SystemTray {
        id: systemTray

        panelWindow: bar

        anchors.right: controlButton.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    // GPU monitoring
    GpuStats {
        id: gpuStats

        anchors.right: systemTray.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }

    // CPU / RAM monitoring
    HardwareStats {
        id: hardwareStats

        anchors.right: gpuStats.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    // Network traffic, directly left of the clock
    NetworkStats {
        id: networkStats
    
        anchors.right: clockBox.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    // Audio status
    AudioStats {
        anchors.right: hardwareStats.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }
}
