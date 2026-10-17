import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../theme"

FloatingWindow {
    id: picker

    title: "Wallpaper Picker"
    visible: false
    implicitWidth: 960
    implicitHeight: 720
    color: Theme.background

    property string wallpaperDir:
        Quickshell.env("HOME") + "/wallpaper/"

    property var wallpapers: []
    property string query: ""
    property string currentWallpaper: ""
    property string errorMessage: ""

    readonly property var filteredWallpapers:
        wallpapers.filter(name =>
            name.toLowerCase().includes(query.toLowerCase())
        )

    function selectCurrentWallpaper() {
        if (currentWallpaper === "")
            return;
    
        const index = filteredWallpapers.indexOf(currentWallpaper);
    
        if (index < 0)
            return;
    
        grid.currentIndex = index;
        grid.positionViewAtIndex(index, GridView.Center);
    }

    function toggle() {
        if (visible) {
            visible = false;
        } else {
            openPicker();
        }
    }

    function openPicker() {
        query = "";
        searchField.text = "";
        errorMessage = "";
    
        grid.currentIndex = 0;
    
        visible = true;
    
        refreshList.running = true;
        currentReader.running = true;
    
        searchField.forceActiveFocus();
    }

    function applyWallpaper(filename) {
        if (applyProcess.running)
            return;

        errorMessage = "";

        applyProcess.command = [
            Quickshell.env("HOME") + "/.local/bin/zell-wallpaper",
            filename
        ];
        applyProcess.running = true;
    }

    Process {
        id: refreshList

        command: [
            Quickshell.env("HOME") + "/.local/bin/zell-wallpaper",
            "--list"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                picker.wallpapers = text
                    .split(/\r?\n/)
                    .map(name => name.trim())
                    .filter(name => name.length > 0);
            
                picker.selectCurrentWallpaper();
            }
        }
    }

    Process {
        id: currentReader
    
        command: [
            Quickshell.env("HOME") + "/.local/bin/zell-wallpaper",
            "--current"
        ]
    
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
    
                picker.currentWallpaper = path.split("/").pop();
                picker.selectCurrentWallpaper();
            }
        }
    }

    Process {
        id: applyProcess

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                picker.visible = false;
            } else {
                picker.errorMessage = "Failed to apply wallpaper";
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "WALLPAPER PICKER"
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontHeading
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: picker.filteredWallpapers.length
                        + " wallpapers"

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
                        onClicked: picker.visible = false
                    }
                }
            }

            TextField {
                id: searchField

                Layout.fillWidth: true
                placeholderText: "Search wallpapers..."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal

                color: Theme.foreground
                selectionColor: Theme.violet

                background: Rectangle {
                    color: Theme.surface
                    radius: Theme.cornerRadius
                    border.color: searchField.activeFocus
                        ? Theme.cyan : "#343443"
                }

                onTextChanged: {
                    picker.query = text;
                    grid.currentIndex = 0;
                }

                Keys.onEscapePressed: picker.visible = false

                Keys.onReturnPressed: {
                    if (grid.count > 0)
                        picker.applyWallpaper(
                            picker.filteredWallpapers[grid.currentIndex]
                        );
                }

                Keys.onDownPressed: {
                    grid.forceActiveFocus();
                    grid.moveCurrentIndexDown();
                }
                
                Keys.onRightPressed: {
                    grid.forceActiveFocus();
                    grid.moveCurrentIndexRight();
                }
                
                Keys.onLeftPressed: {
                    grid.forceActiveFocus();
                    grid.moveCurrentIndexLeft();
                }

                Keys.onUpPressed: {
                    grid.forceActiveFocus();
                    grid.moveCurrentIndexUp();
                }
            }

            GridView {
                id: grid

                focus: true
                currentIndex: 0

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                cellWidth: 230
                cellHeight: 165

                model: picker.filteredWallpapers
                keyNavigationWraps: true

                delegate: Rectangle {
                    id: tile

                    required property string modelData
                    required property int index

                    width: grid.cellWidth - 10
                    height: grid.cellHeight - 10

                    radius: Theme.cornerRadius
                    clip: true
                    color: Theme.surface

                    readonly property bool selected:
                        modelData === picker.currentWallpaper
                    
                    readonly property bool highlighted:
                        tile.index === grid.currentIndex
                    
                    Image {
                        anchors.fill: parent
                        source: "file://" + picker.wallpaperDir
                            + encodeURIComponent(tile.modelData)

                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 32
                        color: "#cc0c0c10"

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter

                            text: tile.modelData
                            elide: Text.ElideRight

                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                    
                        color: "transparent"
                        radius: tile.radius
                    
                        border.width: tile.highlighted ? 3 : (tile.selected ? 2 : 0)
                        border.color: tile.highlighted
                            ? Theme.violet
                            : Theme.cyan
                    
                        visible: tile.highlighted || tile.selected
                    
                        z: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            grid.currentIndex = tile.index;
                            picker.applyWallpaper(tile.modelData);
                        }
                    }
                }

                Keys.onEscapePressed: picker.visible = false

                Keys.onReturnPressed: {
                    if (currentIndex >= 0 && currentIndex < count)
                        picker.applyWallpaper(
                            picker.filteredWallpapers[currentIndex]
                        );
                }
            }

            Text {
                Layout.fillWidth: true

                text: picker.errorMessage !== ""
                    ? picker.errorMessage
                    : "Enter: Apply  •  Esc: Close  •  Both monitors"

                color: picker.errorMessage !== ""
                    ? Theme.danger : Theme.muted

                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }
    }
}
