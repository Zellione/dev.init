pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: audioService

    readonly property var output: Pipewire.defaultAudioSink
    readonly property var input: Pipewire.defaultAudioSource

    readonly property bool ready: Pipewire.ready

    readonly property bool outputAvailable:
        ready && output !== null
        && output.ready && output.audio !== null

    readonly property bool inputAvailable:
        ready && input !== null
        && input.ready && input.audio !== null

    readonly property string outputName:
        outputAvailable
        ? output.description
        : "No output device"

    readonly property string inputName:
        inputAvailable
        ? input.description
        : "No input device"

    readonly property int outputVolume:
        outputAvailable
        ? Math.round(output.audio.volume * 100)
        : 0

    readonly property int inputVolume:
        inputAvailable
        ? Math.round(input.audio.volume * 100)
        : 0

    readonly property bool outputMuted:
        outputAvailable ? output.audio.muted : false

    readonly property bool inputMuted:
        inputAvailable ? input.audio.muted : false

    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    function clampVolume(percent) {
        return Math.max(0, Math.min(100, percent)) / 100;
    }

    function setOutputVolume(percent) {
        if (!outputAvailable)
            return;

        output.audio.volume = clampVolume(percent);
    }

    function setInputVolume(percent) {
        if (!inputAvailable)
            return;

        input.audio.volume = clampVolume(percent);
    }

    function toggleOutputMute() {
        if (!outputAvailable)
            return;

        output.audio.muted = !output.audio.muted;
    }

    function toggleInputMute() {
        if (!inputAvailable)
            return;

        input.audio.muted = !input.audio.muted;
    }

    function isSelectableOutput(node) {
        return node !== null
            && node.audio !== null
            && !node.isStream
            && node.isSink
            && node.name.startsWith("alsa_output.");
    }
    
    function isSelectableInput(node) {
        return node !== null
            && node.audio !== null
            && !node.isStream
            && !node.isSink
            && node.name.startsWith("alsa_input.");
    }
    
    function selectOutput(node) {
        if (!Pipewire.ready || !isSelectableOutput(node)) {
            console.warn("[Audio] Selection rejected");
            return;
        }
    
        if (node === Pipewire.defaultAudioSink) {
            return;
        }
    
        Pipewire.preferredDefaultAudioSink = node;
    }
    
    function selectInput(node) {
        if (!Pipewire.ready || !isSelectableInput(node)) {
            console.warn("[Audio] Input selection rejected");
            return;
        }
    
        if (node === Pipewire.defaultAudioSource) {
            return;
        }
    
        Pipewire.preferredDefaultAudioSource = node;
    }
}
