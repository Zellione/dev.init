//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "panels"
import "bar"

ShellRoot {
    WallpaperPicker {
        id: wallpaperPicker
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            wallpaperPicker.toggle();
        }

        function open(): void {
            wallpaperPicker.openPicker();
        }

        function close(): void {
            wallpaperPicker.visible = false;
        }
    }

    Variants {
        model: Quickshell.screens

        TopBar {
            modelData: null
        }
    }
}
