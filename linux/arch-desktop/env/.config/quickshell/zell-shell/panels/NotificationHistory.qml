import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../theme"

FloatingWindow {
    id: historyWindow

    title: "Notification History"
    visible: false
    implicitWidth: 920
    implicitHeight: 600
    color: Theme.background

    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
    
        onActivated: {
            if (historyWindow.selectedNotification !== null)
                historyWindow.closeDetail();
            else
                historyWindow.closeHistory();
        }
    }

    property var notifications: []
    property string filterMode: "all"
    property string query: ""
    property var selectedNotification: null
    property string errorMessage: ""

    readonly property string backend:
        Quickshell.env("HOME")
        + "/.config/quickshell/zell-shell/scripts/notifications.py"

    readonly property var filteredNotifications: {
        const search = query.trim().toLowerCase();

        return notifications.filter(item => {
            if (filterMode !== "all" && item.urgency !== filterMode)
                return false;

            if (search === "")
                return true;

            return (
                item.app + " " + item.summary + " " + item.body
            ).toLowerCase().includes(search);
        });
    }

    function openHistory(mode) {
        filterMode = ["all", "normal", "critical"].includes(mode)
            ? mode : "all";

        selectedNotification = null;
        errorMessage = "";
        query = "";
        searchField.text = "";

        visible = true;
        loadHistory();
        searchField.forceActiveFocus();
    }

    function closeHistory() {
        visible = false;
        selectedNotification = null;
    }

    function loadHistory() {
        if (!loadProcess.running)
            loadProcess.running = true;
    }

    function switchFilter(mode) {
        filterMode = mode;
        selectedNotification = null;
        query = "";
        searchField.text = "";
        notificationList.currentIndex = 0;
        notificationList.positionViewAtBeginning();
        searchField.forceActiveFocus();
    }

    function openSelected() {
        const index = notificationList.currentIndex;

        if (index < 0 || index >= filteredNotifications.length)
            return;

        selectedNotification = filteredNotifications[index];
    }

    function closeDetail() {
        selectedNotification = null;
        searchField.forceActiveFocus();
    }

    function copyField(field) {
        if (selectedNotification === null || copyProcess.running)
            return;

        copyProcess.command = [
            "python3",
            backend,
            "copy",
            String(selectedNotification.id),
            field
        ];

        copyProcess.running = true;
    }

    Process {
        id: loadProcess
        command: ["python3", historyWindow.backend, "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    historyWindow.notifications = JSON.parse(text);
                    historyWindow.errorMessage = "";
                    notificationList.currentIndex =
                        historyWindow.filteredNotifications.length > 0
                        ? 0 : -1;
                } catch (error) {
                    historyWindow.errorMessage =
                        "Could not parse notification history";
                }
            }
        }

        onExited: (code, status) => {
            if (code !== 0)
                historyWindow.errorMessage =
                    "Could not load Mako history";
        }
    }

    Process {
        id: copyProcess
    
        stdout: null
        stderr: null
    
        onExited: (code, status) => {
            if (code !== 0) {
                historyWindow.errorMessage =
                    "Could not copy notification";
            } else {
                historyWindow.errorMessage = "";
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "NOTIFICATIONS"
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontHeading
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: historyWindow.filteredNotifications.length
                        + " entries"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }

                Text {
                    text: "×"
                    color: Theme.muted
                    font.pixelSize: 26

                    MouseArea {
                        anchors.fill: parent
                        onClicked: historyWindow.closeHistory()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { mode: "all", label: "ALL" },
                        { mode: "normal", label: "NORMAL" },
                        { mode: "critical", label: "CRITICAL" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: Theme.cornerRadius

                        readonly property bool selected:
                            historyWindow.filterMode === modelData.mode

                        color: selected ? "#39304b" : Theme.surface
                        border.width: selected ? 1 : 0
                        border.color: Theme.violet

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label

                            color: parent.selected
                                ? Theme.foreground : Theme.muted

                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:
                                historyWindow.switchFilter(modelData.mode)
                        }
                    }
                }
            }

            TextField {
                id: searchField

                Layout.fillWidth: true
                Layout.preferredHeight: 44
                visible: historyWindow.selectedNotification === null

                placeholderText: "Search notifications..."
                text: historyWindow.query

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                color: Theme.foreground

                background: Rectangle {
                    color: Theme.surface
                    radius: Theme.cornerRadius

                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: Theme.violet
                }

                onTextChanged: {
                    historyWindow.query = text;
                    notificationList.currentIndex =
                        historyWindow.filteredNotifications.length > 0
                        ? 0 : -1;
                    notificationList.positionViewAtBeginning();
                }

                Keys.onDownPressed: event => {
                    if (notificationList.count > 0) {
                        notificationList.currentIndex = Math.min(
                            notificationList.count - 1,
                            notificationList.currentIndex + 1
                        );
                        notificationList.positionViewAtIndex(
                            notificationList.currentIndex,
                            ListView.Contain
                        );
                    }
                    event.accepted = true;
                }

                Keys.onUpPressed: event => {
                    if (notificationList.count > 0) {
                        notificationList.currentIndex = Math.max(
                            0,
                            notificationList.currentIndex - 1
                        );
                        notificationList.positionViewAtIndex(
                            notificationList.currentIndex,
                            ListView.Contain
                        );
                    }
                    event.accepted = true;
                }

                Keys.onReturnPressed: event => {
                    historyWindow.openSelected();
                    event.accepted = true;
                }

                Keys.onEnterPressed: event => {
                    historyWindow.openSelected();
                    event.accepted = true;
                }

                Keys.onEscapePressed: event => {
                    historyWindow.closeHistory();
                    event.accepted = true;
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex:
                    historyWindow.selectedNotification === null ? 0 : 1

                ListView {
                    id: notificationList

                    clip: true
                    spacing: 6

                    model: historyWindow.filteredNotifications
                    currentIndex: count > 0 ? 0 : -1

                    delegate: Rectangle {
                        id: notificationRow

                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: 84
                        radius: Theme.cornerRadius

                        readonly property bool selected:
                            notificationList.currentIndex === index

                        color: selected ? "#39304b" : Theme.surface
                        border.width: selected ? 1 : 0
                        border.color: Theme.violet

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: notificationRow.modelData.urgency
                                    === "critical" ? "⚠" : "●"

                                color: notificationRow.modelData.urgency
                                    === "critical"
                                    ? Theme.danger : Theme.cyan

                                font.pixelSize: 22
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: notificationRow.modelData.app
                                        color: Theme.violet

                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSmall
                                        font.bold: true
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: notificationRow.modelData.urgency
                                        color: Theme.muted

                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSmall
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text:
                                        notificationRow.modelData.summary
                                    color: Theme.foreground

                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontNormal

                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: notificationRow.modelData.body
                                    color: Theme.muted

                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSmall

                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    visible: text.length > 0
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered:
                                notificationList.currentIndex =
                                    notificationRow.index

                            onClicked: {
                                notificationList.currentIndex =
                                    notificationRow.index;
                                historyWindow.openSelected();
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }

                Item {
                    id: detailPage

                    property var notification:
                        historyWindow.selectedNotification

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48

                            color: Theme.surface
                            radius: Theme.cornerRadius

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12

                                Text {
                                    text: "←  BACK"
                                    color: Theme.cyan

                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontNormal

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked:
                                            historyWindow.closeDetail()
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: detailPage.notification
                                        ? detailPage.notification.app
                                        : ""

                                    color: Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSmall
                                }
                            }
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            clip: true
                            contentWidth: width
                            contentHeight: detailContent.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds

                            ColumnLayout {
                                id: detailContent

                                width: parent.width
                                spacing: 16

                                Text {
                                    Layout.fillWidth: true

                                    text: detailPage.notification
                                        ? detailPage.notification.summary
                                        : ""

                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontHeading
                                    font.bold: true

                                    wrapMode: Text.Wrap
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: detailPage.notification
                                        ? detailPage.notification.body
                                        : ""

                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontNormal

                                    wrapMode: Text.Wrap
                                    textFormat: Text.PlainText
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: [
                                    { label: "Copy full", field: "full" },
                                    { label: "Copy body", field: "body" },
                                    { label: "Copy title", field: "summary" }
                                ]

                                delegate: Button {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    text: modelData.label

                                    onClicked:
                                        historyWindow.copyField(
                                            modelData.field
                                        )
                                }
                            }
                        }
                    }

                    Item {
                        id: detailFocus
                        anchors.fill: parent
                        focus: historyWindow.selectedNotification !== null

                        Keys.onEscapePressed: event => {
                            historyWindow.closeDetail();
                            event.accepted = true;
                        }
                        
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Backspace) {
                                historyWindow.closeDetail();
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            Text {
                visible: historyWindow.errorMessage !== ""
                text: historyWindow.errorMessage
                color: Theme.danger

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Text {
                Layout.alignment: Qt.AlignRight

                text: historyWindow.selectedNotification === null
                    ? "↑ ↓ Navigate   Enter Details   Esc Close"
                    : "Esc Back   Copy using buttons"

                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }
    }
}
