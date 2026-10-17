pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Node name -> "available", "unavailable", "unknown"
    property var sinkStates: ({})
    property var sourceStates: ({})

    function forNode(name, inputDevice) {
        const states = inputDevice ? sourceStates : sinkStates;
        return states[name] || "unknown";
    }

    function readAvailability(node) {
        const ports = node.ports || [];
        const activePort = node.active_port || "";

        if (ports.length === 0)
            return "unknown";

        const selected = ports.find(port =>
            port.name === activePort
        );

        if (!selected)
            return "unknown";

        if (selected.availability === "not available")
            return "unavailable";

        if (selected.availability === "available")
            return "available";

        return "unknown";
    }

    function parseNodes(text, inputDevice) {
        try {
            const nodes = JSON.parse(text);
            const result = {};

            for (const node of nodes) {
                if (!node.name)
                    continue;

                result[node.name] = readAvailability(node);
            }

            if (inputDevice)
                sourceStates = result;
            else
                sinkStates = result;

        } catch (error) {
            console.warn(
                "[AudioPorts] Failed to parse PipeWire devices:",
                error
            );
        }
    }

    function refresh() {
        if (!sinkProcess.running)
            sinkProcess.running = true;

        if (!sourceProcess.running)
            sourceProcess.running = true;
    }

    Process {
        id: sinkProcess

        command: [
            "pactl", "--format=json", "list", "sinks"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseNodes(text, false);
            }
        }
    }

    Process {
        id: sourceProcess

        command: [
            "pactl", "--format=json", "list", "sources"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseNodes(text, true);
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }
}
