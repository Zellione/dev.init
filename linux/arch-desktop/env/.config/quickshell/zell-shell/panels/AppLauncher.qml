import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../theme"

FloatingWindow {
    id: launcher

    title: "App Launcher"
    visible: false
    implicitWidth: 760
    implicitHeight: 600
    color: Theme.background

    function toggle() {
        if (visible) {
            closeLauncher();
        } else {
            openLauncher();
        }
    }

    function openLauncher() {
        searchField.text = "";
        visible = true;
        appList.currentIndex = 0;
        searchField.forceActiveFocus();
    }

    function closeLauncher() {
        visible = false;
    }

    function launchSelected() {
        const index = appList.currentIndex;
        const apps = filteredApps.values;

        if (index < 0 || index >= apps.length)
            return;

        const app = apps[index];

        if (!app.id) {
            console.warn("Cannot launch app without desktop entry ID");
            return;
        }

        const desktopId = app.id.endsWith(".desktop")
            ? app.id
            : app.id + ".desktop";

        Quickshell.execDetached([
            "uwsm", "app", "-t", "scope", "--", desktopId
        ]);

        closeLauncher();
    }

    ScriptModel {
        id: filteredApps

        values: {
            const query = searchField.text.trim().toLowerCase();

            const apps = [...DesktopEntries.applications.values]
                .filter(app => app.name && !app.noDisplay);

            const matches = apps.filter(app => {
                if (query === "")
                    return true;

                const name = (app.name || "").toLowerCase();
                const generic = (app.genericName || "").toLowerCase();
                const description = (app.comment || "").toLowerCase();
                const keywords = (app.keywords || []).join(" ").toLowerCase();

                return name.includes(query)
                    || generic.includes(query)
                    || description.includes(query)
                    || keywords.includes(query);
            });

            return matches.sort((a, b) => {
                const aName = a.name.toLowerCase();
                const bName = b.name.toLowerCase();

                if (query !== "") {
                    const aExact = aName === query;
                    const bExact = bName === query;

                    if (aExact !== bExact)
                        return aExact ? -1 : 1;

                    const aPrefix = aName.startsWith(query);
                    const bPrefix = bName.startsWith(query);

                    if (aPrefix !== bPrefix)
                        return aPrefix ? -1 : 1;
                }

                return a.name.localeCompare(b.name);
            });
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
                    text: "APPLICATIONS"
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontHeading
                    font.bold: true

                    Layout.fillWidth: true
                }

                Text {
                    text: filteredApps.values.length + " apps"
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
                        onClicked: launcher.closeLauncher()
                    }
                }
            }

            TextField {
                id: searchField

                Layout.fillWidth: true
                Layout.preferredHeight: 44

                placeholderText: "Search applications..."

                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal

                background: Rectangle {
                    color: Theme.surface
                    radius: Theme.cornerRadius
                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: Theme.violet
                }

                onTextChanged: {
                    appList.currentIndex = filteredApps.values.length > 0
                        ? 0 : -1;
                
                    appList.positionViewAtBeginning();
                }

                Keys.onDownPressed: event => {
                    if (appList.count > 0)
                        appList.currentIndex =
                            (appList.currentIndex + 1) % appList.count;

                    event.accepted = true;
                }

                Keys.onUpPressed: event => {
                    if (appList.count > 0)
                        appList.currentIndex =
                            (appList.currentIndex - 1 + appList.count)
                            % appList.count;

                    event.accepted = true;
                }

                Keys.onReturnPressed: event => {
                    launcher.launchSelected();
                    event.accepted = true;
                }

                Keys.onEnterPressed: event => {
                    launcher.launchSelected();
                    event.accepted = true;
                }

                Keys.onEscapePressed: event => {
                    launcher.closeLauncher();
                    event.accepted = true;
                }
            }

            ListView {
                id: appList

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                spacing: 4

                model: filteredApps
                currentIndex: count > 0 ? 0 : -1

                keyNavigationWraps: true

                delegate: Rectangle {
                    id: appRow

                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: 64

                    radius: Theme.cornerRadius

                    readonly property bool selected:
                        appList.currentIndex === index

                    color: selected ? "#39304b" : Theme.surface

                    border.width: selected ? 1 : 0
                    border.color: Theme.violet

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        spacing: 12

                        IconImage {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38

                            source: Quickshell.iconPath(
                                appRow.modelData.icon,
                                "application-x-executable"
                            )
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                Layout.fillWidth: true

                                text: appRow.modelData.name
                                color: Theme.foreground

                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontNormal
                                font.bold: appRow.selected

                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true

                                text: appRow.modelData.genericName
                                    || appRow.modelData.comment
                                    || ""

                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSmall

                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: appList.currentIndex = appRow.index

                        onClicked: {
                            appList.currentIndex = appRow.index;
                            launcher.launchSelected();
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }

            Text {
                Layout.alignment: Qt.AlignRight

                text: "↑ ↓ Navigate   Enter Launch   Esc Close"

                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }
        }
    }
}
