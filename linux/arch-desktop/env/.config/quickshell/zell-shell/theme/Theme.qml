pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color background: "#0c0c10"
    readonly property color surface: "#24242d"
    readonly property color foreground: "#d8dee9"
    readonly property color muted: "#7f849c"

    readonly property color cyan: "#7dd3fc"
    readonly property color violet: "#c4b5fd"
    readonly property color danger: "#bf616a"

    readonly property int barHeight: 44
    readonly property int cornerRadius: 7

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 16
    readonly property int fontSmall: 14
    readonly property int fontNormal: 16
    readonly property int fontHeading: 18
    readonly property int fontLarge: 26
}
