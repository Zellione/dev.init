pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: network

    property bool connected: false
    property bool wireless: false
    property string interfaceName: ""
    property real downloadBps: 0
    property real uploadBps: 0

    function formatBits(bits) {
        if (bits >= 1000000000)
            return (bits / 1000000000).toFixed(1) + "Gb/s";

        if (bits >= 1000000)
            return (bits / 1000000).toFixed(1) + "Mb/s";

        if (bits >= 1000)
            return (bits / 1000).toFixed(1) + "kb/s";

        return Math.round(bits) + "b/s";
    }

    Process {
        id: sampler

        command: [
            "python3",
            Quickshell.env("HOME")
                + "/.config/quickshell/zell-shell/scripts/network.py"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);

                    network.connected = data.connected === true;
                    network.interfaceName = data.interface || "";
                    network.wireless = data.wireless === true;
                    network.downloadBps = data.down_bps || 0;
                    network.uploadBps = data.up_bps || 0;
                } catch (error) {
                    console.warn("Invalid network sample:", error);
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!sampler.running)
                sampler.running = true;
        }
    }
}
