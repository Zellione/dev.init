pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: hardware

    // CPU / RAM
    property int cpuUsage: 0
    property int memoryUsage: 0
    property int cpuTemperature: -1

    // NVIDIA
    property bool gpuAvailable: false
    property int gpuUsage: 0
    property int gpuTemperature: -1
    property real gpuMemoryUsed: 0
    property real gpuMemoryTotal: 0
    property real gpuPower: -1
    property string gpuPstate: ""

    // External GPU
    property var egpu: null

    readonly property bool egpuPresent:
        egpu !== null

    readonly property bool egpuNvidiaAvailable:
        egpuPresent
        && egpu.driver === "nvidia"
        && egpu.gpu !== null

    Process {
        id: sampler

        command: [
            "python3",
            Quickshell.env("HOME")
                + "/.config/quickshell/zell-shell/scripts/hardware.py"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);

                    hardware.egpu = data.egpu ?? null;

                    hardware.cpuUsage = data.cpu;
                    hardware.memoryUsage = data.memory;
                    hardware.cpuTemperature =
                        data.temperature ?? -1;

                    if (data.gpu !== null && data.gpu !== undefined) {
                        const gpu = data.gpu;

                        hardware.gpuAvailable = true;
                        hardware.gpuUsage = gpu.usage ?? 0;
                        hardware.gpuTemperature = gpu.temperature ?? -1;
                        hardware.gpuMemoryUsed = gpu.memoryUsed ?? 0;
                        hardware.gpuMemoryTotal = gpu.memoryTotal ?? 0;
                        hardware.gpuPower = gpu.power ?? -1;
                        hardware.gpuPstate = gpu.pstate ?? "";
                    } else {
                        hardware.gpuAvailable = false;
                        hardware.gpuUsage = 0;
                        hardware.gpuTemperature = -1;
                        hardware.gpuMemoryUsed = 0;
                        hardware.gpuMemoryTotal = 0;
                        hardware.gpuPower = -1;
                        hardware.gpuPstate = "";
                    }
                } catch (error) {
                    console.warn(
                        "Hardware sample invalid:",
                        error
                    );
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
