import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../theme"

FloatingWindow {
    id: picker

    title: "Clipboard Picker"
    visible: false
    implicitWidth: 1100
    implicitHeight: 680
    color: Theme.background

    property var entries: []
    property int activeTab: 0
    property bool confirmingWipe: false
    property string errorMessage: ""

    readonly property string backend:
        Quickshell.env("HOME")
        + "/.config/quickshell/zell-shell/scripts/clipboard.py"

    readonly property var visibleEntries: {
        const images = activeTab === 1;
        const query = searchField.text.toLowerCase().trim();

        return entries.filter(entry =>
            entry.image === images
            && (query === ""
                || entry.preview.toLowerCase().includes(query))
        );
    }

    function selectedIndex() {
        return activeTab === 0
            ? textList.currentIndex
            : imageGrid.currentIndex;
    }

    function selectedEntry() {
        const index = selectedIndex();

        if (index < 0 || index >= visibleEntries.length)
            return null;

        return visibleEntries[index];
    }

    function resetSelection() {
        const index = visibleEntries.length > 0 ? 0 : -1;

        if (activeTab === 0) {
            textList.currentIndex = index;
            textList.positionViewAtBeginning();
        } else {
            imageGrid.currentIndex = index;
            imageGrid.positionViewAtBeginning();
        }
    }

    function switchTab(tab) {
        if (tab < 0 || tab > 1)
            return;
    
        activeTab = tab;
        searchField.text = "";
        resetSelection();
    
        if (activeTab === 0)
            searchField.forceActiveFocus();
        else
            contentStack.forceActiveFocus();
    }

    function openPicker() {
        confirmingWipe = false;
        errorMessage = "";
        activeTab = 0;
        searchField.text = "";

        visible = true;
        refresh();
        resetSelection();
        searchField.forceActiveFocus();
    }

    function closePicker() {
        visible = false;
        confirmingWipe = false;
    }

    function toggle() {
        if (visible)
            closePicker();
        else
            openPicker();
    }

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true;
    }

    function restoreEntry(entry) {
        if (entry === null || actionProcess.running)
            return;

        errorMessage = "";

        actionProcess.command = [
            "python3", backend, "restore", entry.id
        ];
        actionProcess.running = true;
    }

    function restoreSelected() {
        restoreEntry(selectedEntry());
    }

    function deleteSelected() {
        const entry = selectedEntry();

        if (entry === null || actionProcess.running)
            return;

        errorMessage = "";

        actionProcess.command = [
            "python3", backend, "delete", entry.id
        ];
        actionProcess.running = true;
    }

    function wipeHistory() {
        if (actionProcess.running)
            return;

        errorMessage = "";
        confirmingWipe = false;

        actionProcess.command = [
            "python3", backend, "wipe"
        ];
        actionProcess.running = true;
    }

    function navigate(delta) {
        const count = visibleEntries.length;

        if (count === 0)
            return;

        const current = Math.max(0, selectedIndex());
        const next = Math.max(0, Math.min(count - 1, current + delta));

        if (activeTab === 0) {
            textList.currentIndex = next;
            textList.positionViewAtIndex(next, ListView.Contain);
        } else {
            imageGrid.currentIndex = next;
            imageGrid.positionViewAtIndex(next, GridView.Contain);
        }
    }

    function handleKey(event) {
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        const shift = (event.modifiers & Qt.ShiftModifier) !== 0;
        const alt = (event.modifiers & Qt.AltModifier) !== 0;

        if (confirmingWipe) {
            if (event.key === Qt.Key_Escape) {
                confirmingWipe = false;
            } else if (event.key === Qt.Key_Return
                       || event.key === Qt.Key_Enter) {
                wipeHistory();
            } else {
                return;
            }

            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_Tab) {
            switchTab(shift ? 0 : 1);
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_Backtab) {
            switchTab(0);
            event.accepted = true;
            return;
        }

        if (alt && event.key === Qt.Key_1) {
            switchTab(0);
            event.accepted = true;
            return;
        }

        if (alt && event.key === Qt.Key_2) {
            switchTab(1);
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_Delete) {
            if (shift)
                confirmingWipe = true;
            else
                deleteSelected();

            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Down) {
            navigate(activeTab === 0 ? 1 : 3);
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Up) {
            navigate(activeTab === 0 ? -1 : -3);
            event.accepted = true;
            return;
        }

        if (activeTab === 1 && event.key === Qt.Key_Right) {
            navigate(1);
            event.accepted = true;
            return;
        }

        if (activeTab === 1 && event.key === Qt.Key_Left) {
            navigate(-1);
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter) {
            restoreSelected();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Escape) {
            closePicker();
            event.accepted = true;
        }
    }

    Process {
        id: listProcess

        command: ["python3", picker.backend, "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    picker.entries = JSON.parse(text);
                    picker.resetSelection();
                    picker.errorMessage = "";
                } catch (error) {
                    picker.errorMessage =
                        "Could not read clipboard history";
                }
            }
        }

        onExited: (code, status) => {
            if (code !== 0)
                picker.errorMessage = "Clipboard history unavailable";
        }
    }

    Process {
        id: actionProcess

        onExited: (code, status) => {
            if (code !== 0) {
                picker.errorMessage = "Clipboard operation failed";
                searchField.forceActiveFocus();
                return;
            }

            if (command[2] === "restore") {
                picker.closePicker();
            } else {
                picker.refresh();
                searchField.forceActiveFocus();
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
                    text: "CLIPBOARD"
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontHeading
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: picker.visibleEntries.length + " entries"
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
                        onClicked: picker.closePicker()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { label: "TEXT", icon: "󰈙" },
                        { label: "IMAGES", icon: "󰋩" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: Theme.cornerRadius

                        color: picker.activeTab === index
                            ? "#39304b" : Theme.surface

                        border.width: picker.activeTab === index ? 1 : 0
                        border.color: Theme.violet

                        Text {
                            anchors.centerIn: parent

                            text: modelData.icon + "  " + modelData.label
                            color: picker.activeTab === index
                                ? Theme.foreground : Theme.muted

                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: picker.switchTab(index)
                        }
                    }
                }
            }

            TextField {
                id: searchField

                Layout.fillWidth: true
                visible: picker.activeTab === 0
                Layout.preferredHeight: visible ? 44 : 0

                placeholderText: picker.activeTab === 0
                    ? "Search text..."
                    : "Search images..."

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                color: Theme.foreground

                background: Rectangle {
                    color: Theme.surface
                    radius: Theme.cornerRadius

                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: Theme.violet
                }

                onTextChanged: picker.resetSelection()

                Keys.onPressed: event => picker.handleKey(event)
            }

            StackLayout {
                id: contentStack
            
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: picker.activeTab
            
                focus: picker.activeTab === 1
                Keys.onPressed: event => picker.handleKey(event)

                ListView {
                    id: textList

                    clip: true
                    spacing: 6

                    model: picker.activeTab === 0
                        ? picker.visibleEntries
                        : []

                    currentIndex: count > 0 ? 0 : -1

                    delegate: Rectangle {
                        id: textRow

                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: 64
                        radius: Theme.cornerRadius

                        readonly property bool selected:
                            textList.currentIndex === index

                        color: selected ? "#39304b" : Theme.surface

                        border.width: selected ? 1 : 0
                        border.color: Theme.violet

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 14

                            Text {
                                Layout.fillWidth: true

                                text: textRow.modelData.preview
                                color: Theme.foreground

                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontNormal

                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }

                            Text {
                                text: "ID " + textRow.modelData.id
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: textList.currentIndex = textRow.index

                            onClicked: {
                                textList.currentIndex = textRow.index;
                                picker.restoreEntry(textRow.modelData);
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }

                GridView {
                    id: imageGrid

                    clip: true

                    readonly property int columns: 3

                    cellWidth: Math.floor(width / columns)
                    cellHeight: 210

                    model: picker.activeTab === 1
                        ? picker.visibleEntries
                        : []

                    currentIndex: count > 0 ? 0 : -1

                    delegate: Rectangle {
                        id: imageTile

                        required property var modelData
                        required property int index

                        width: imageGrid.cellWidth - 10
                        height: imageGrid.cellHeight - 10

                        radius: Theme.cornerRadius

                        readonly property bool selected:
                            imageGrid.currentIndex === index

                        color: selected ? "#39304b" : Theme.surface

                        border.width: selected ? 1 : 0
                        border.color: Theme.violet

                        Image {
                            anchors.fill: parent
                            anchors.margins: 8

                            source: imageTile.modelData.thumbnail
                            sourceSize.width: 440
                            sourceSize.height: 310

                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: imageGrid.currentIndex = imageTile.index

                            onClicked: {
                                imageGrid.currentIndex = imageTile.index;
                                picker.restoreEntry(imageTile.modelData);
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }

            Text {
                visible: picker.errorMessage !== ""
                text: picker.errorMessage
                color: Theme.danger
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            Text {
                Layout.alignment: Qt.AlignRight

                text: "Ctrl+Tab Switch   Arrows Navigate"
                    + "   Enter Copy   Ctrl+Del Delete"
                    + "   Ctrl+Shift+Del Clear   Esc Close"

                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: picker.confirmingWipe
        color: "#e6000000"
        z: 10

        Rectangle {
            anchors.centerIn: parent
            width: 430
            height: 180

            radius: Theme.cornerRadius
            color: Theme.surface

            border.width: 1
            border.color: Theme.violet

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Text {
                    text: "Clear clipboard history?"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontHeading
                }

                Text {
                    text: "All saved clipboard entries will be removed."
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "Cancel"
                        onClicked: {
                            picker.confirmingWipe = false;
                            searchField.forceActiveFocus();
                        }
                    }

                    Button {
                        text: "Clear history"
                        onClicked: picker.wipeHistory()
                    }
                }
            }
        }
    }
}
