pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: virtuoso

    readonly property string runtimeRoot:
        Quickshell.env("XDG_RUNTIME_DIR") || ""

    property int batteryPercent: -1
    property real sampledAt: 0
    property real nowSeconds: Math.floor(Date.now() / 1000)
    property var charging: null

    readonly property bool hasReading:
        batteryPercent >= 0 && sampledAt > 0

    readonly property real ageSeconds:
        Math.max(0, nowSeconds - sampledAt)

    readonly property bool isFresh:
        hasReading
        && sampledAt <= nowSeconds
        && ageSeconds <= 600

    readonly property string ageText: {
        if (!hasReading)
            return "No battery reading";

        if (ageSeconds < 60)
            return "Last sample: just now";

        return "Last sample: "
            + Math.floor(ageSeconds / 60)
            + " min ago";
    }

    Process {
        id: reader

        command: [
            "cat",
            virtuoso.runtimeRoot
                + "/virtuoso-daemon/battery.json"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);

                    const level = data.battery_percent;
                    const timestamp = data.timestamp;

                    if (!Number.isInteger(level)
                            || level < 0
                            || level > 100
                            || !Number.isInteger(timestamp)
                            || timestamp <= 0
                            || timestamp > virtuoso.nowSeconds + 60) {
                        return;
                    }

                    if (timestamp < virtuoso.sampledAt)
                        return;

                    virtuoso.batteryPercent = level;
                    virtuoso.sampledAt = timestamp;
                    virtuoso.charging =
                        typeof data.charging === "boolean"
                            ? data.charging
                            : null;
                } catch (error) {
                    // Cache not available or incomplete.
                    // Preserve the last valid reading.
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            virtuoso.nowSeconds =
                Math.floor(Date.now() / 1000);

            if (virtuoso.runtimeRoot.length > 0
                    && !reader.running) {
                reader.running = true;
            }
        }
    }
}
