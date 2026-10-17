pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool active: false
    property bool known: false
    property bool pending: false
    property string errorMessage: ""

    function refresh() {
        if (pending || statusProcess.running)
            return;

        statusProcess.running = true;
    }

    function toggle() {
        if (!known || pending)
            return;

        pending = true;
        errorMessage = "";

        actionProcess.command = [
            "systemctl",
            "--user",
            active ? "stop" : "start",
            "vr-mic-switch.service"
        ];

        actionProcess.running = true;
    }

    property Process statusProcess: Process {
        command: [
            "systemctl",
            "--user",
            "show",
            "vr-mic-switch.service",
            "--property=ActiveState",
            "--value"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const state = text.trim();

                if (state === "active") {
                    root.active = true;
                    root.known = true;
                } else if (
                    state === "inactive"
                    || state === "failed"
                    || state === "activating"
                    || state === "deactivating"
                ) {
                    root.active = state === "active";
                    root.known = true;
                } else {
                    root.known = false;
                }
            }
        }
    }

    property Process actionProcess: Process {
        onExited: (exitCode, exitStatus) => {
            root.pending = false;

            if (exitCode !== 0) {
                root.errorMessage =
                    "Failed to change VR audio service";
            }

            root.refresh();
        }
    }

    property Timer statusTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }
}
