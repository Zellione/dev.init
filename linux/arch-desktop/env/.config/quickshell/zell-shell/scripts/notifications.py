#!/usr/bin/env python3
"""Backend for the Quickshell Mako notification history."""

import json
import subprocess
import sys


def run(*args, input_data=None):
    return subprocess.run(
        args,
        input=input_data,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    ).stdout


def history():
    data = json.loads(run("makoctl", "history", "-j"))
    if not isinstance(data, list):
        raise ValueError("Unexpected Mako history format")

    result = []
    for index, item in enumerate(data):
        if not isinstance(item, dict):
            continue

        result.append({
            "index": index,
            "id": item.get("id"),
            "app": str(item.get("app_name") or "Unknown"),
            "icon": str(item.get("app_icon") or ""),
            "urgency": str(item.get("urgency") or "normal"),
            "summary": str(item.get("summary") or ""),
            "body": str(item.get("body") or ""),
        })

    return result


def copy_notification(notification_id, field):
    item = next(
        (
            item for item in history()
            if str(item["id"]) == notification_id
        ),
        None,
    )

    if item is None:
        raise ValueError("Notification no longer in history")

    if field == "summary":
        value = item["summary"]
    elif field == "body":
        value = item["body"]
    elif field == "full":
        value = item["summary"] + "\n\n" + item["body"]
    else:
        raise ValueError("Unknown copy action")

    process = subprocess.Popen(
        [
            "wl-copy",
            "--foreground",
            "--type",
            "text/plain;charset=utf-8",
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    
    assert process.stdin is not None
    process.stdin.write(value.encode("utf-8"))
    process.stdin.close()


def main():
    args = sys.argv[1:]

    if args == ["list"]:
        print(json.dumps(history(), ensure_ascii=False))
    elif len(args) == 3 and args[0] == "copy":
        copy_notification(args[1], args[2])
    else:
        raise ValueError(
            "Usage: notifications.py list|copy ID FIELD"
        )


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"notifications: {error}", file=sys.stderr)
        sys.exit(1)
