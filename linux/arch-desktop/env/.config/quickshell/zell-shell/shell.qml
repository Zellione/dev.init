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

    AppLauncher {
        id: appLauncher
    }

    ClipboardPicker {
        id: clipboardPicker
    }

    NotificationHistory {
        id: notificationHistory
    }
    
    IpcHandler {
        target: "notifications"
    
        function open(mode: string): void {
            notificationHistory.openHistory(mode);
        }
    
        function close(): void {
            notificationHistory.closeHistory();
        }
    }
    
    IpcHandler {
        target: "clipboard"
    
        function toggle(): void {
            clipboardPicker.toggle();
        }
    
        function open(): void {
            clipboardPicker.openPicker();
        }
    
        function close(): void {
            clipboardPicker.closePicker();
        }
    }
    
    IpcHandler {
        target: "launcher"
    
        function toggle(): void {
            appLauncher.toggle();
        }
    
        function open(): void {
            appLauncher.openLauncher();
        }
    
        function close(): void {
            appLauncher.closeLauncher();
        }
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
