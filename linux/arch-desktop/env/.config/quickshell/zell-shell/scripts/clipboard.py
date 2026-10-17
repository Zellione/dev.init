#!/usr/bin/env python3
"""Small cliphist backend for the Quickshell clipboard picker."""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

os.umask(0o077)

CACHE = (
    Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    / "cliphist-rofi"
)
ID_RE = re.compile(r"^[0-9]+$")
LIMIT = 200


def run(*args, input_data=None):
    return subprocess.run(
        args,
        input=input_data,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    ).stdout


def entries():
    lines = run("cliphist", "list").decode(
        "utf-8", errors="replace"
    ).splitlines()

    result = []

    for line in lines[:LIMIT]:
        if "\t" not in line:
            continue

        entry_id, preview = line.split("\t", 1)

        if not ID_RE.fullmatch(entry_id):
            continue

        is_image = preview.startswith("[[ binary data")
        thumbnail = ""

        if is_image:
            cache_path = CACHE / f"{entry_id}.png"

            if not cache_path.exists():
                try:
                    data = run(
                        "cliphist",
                        "decode",
                        input_data=line.encode("utf-8"),
                    )
                    if len(data) <= 32 * 1024 * 1024:
                        CACHE.mkdir(parents=True, exist_ok=True)
                        cache_path.write_bytes(data)
                except (OSError, subprocess.CalledProcessError):
                    pass

            if cache_path.exists():
                thumbnail = cache_path.as_uri()

        result.append({
            "id": entry_id,
            "preview": preview.replace("\n", " "),
            "image": is_image,
            "thumbnail": thumbnail,
        })

    return result


def validate_id(entry_id):
    if not ID_RE.fullmatch(entry_id):
        raise ValueError("Invalid clipboard ID")
    return entry_id


def entry_line(entry_id):
    entry_id = validate_id(entry_id)
    lines = run("cliphist", "list").splitlines()

    for line in lines:
        if line.split(b"\t", 1)[0] == entry_id.encode("ascii"):
            return line + b"\n"

    raise ValueError("Clipboard entry no longer exists")


def restore(entry_id):
    line = entry_line(entry_id)

    data = run(
        "cliphist",
        "decode",
        input_data=line,
    )

    preview = line.split(b"\t", 1)[1] if b"\t" in line else b""
    is_image = preview.startswith(b"[[ binary data")

    if is_image:
        if data.startswith(b"\x89PNG\r\n\x1a\n"):
            mime = "image/png"
        elif data.startswith(b"\xff\xd8\xff"):
            mime = "image/jpeg"
        elif data.startswith((b"GIF87a", b"GIF89a")):
            mime = "image/gif"
        elif data.startswith(b"RIFF") and data[8:12] == b"WEBP":
            mime = "image/webp"
        else:
            raise ValueError("Unsupported clipboard image format")

        run("wl-copy", "--type", mime, input_data=data)
    else:
        run("wl-copy", "--type", "text/plain;charset=utf-8", input_data=data)


def delete(entry_id):
    run(
        "cliphist",
        "delete",
        input_data=entry_line(entry_id),
    )

    thumbnail = CACHE / f"{entry_id}.png"
    thumbnail.unlink(missing_ok=True)


def wipe():
    run("cliphist", "wipe")

    if CACHE.is_dir():
        for thumbnail in CACHE.glob("*.png"):
            if ID_RE.fullmatch(thumbnail.stem):
                thumbnail.unlink()


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else ""

    if action == "list":
        print(json.dumps(entries(), ensure_ascii=False))
    elif action == "restore" and len(sys.argv) == 3:
        restore(sys.argv[2])
    elif action == "delete" and len(sys.argv) == 3:
        delete(sys.argv[2])
    elif action == "wipe":
        wipe()
    else:
        raise ValueError("Usage: clipboard.py list|restore ID|delete ID|wipe")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"clipboard: {error}", file=sys.stderr)
        sys.exit(1)
