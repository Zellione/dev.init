#!/usr/bin/env python3
"""Sample network throughput using Linux interface counters."""

import json
import time
from pathlib import Path


NET = Path("/sys/class/net")


def active_interface():
    """Find the interface used for the IPv4 default route."""
    try:
        for line in Path("/proc/net/route").read_text().splitlines()[1:]:
            fields = line.split()
            if len(fields) >= 4:
                if fields[1] == "00000000" and int(fields[3], 16) & 1:
                    return fields[0]
    except OSError:
        pass

    return None


def counters(interface):
    base = NET / interface / "statistics"
    return (
        int((base / "rx_bytes").read_text()),
        int((base / "tx_bytes").read_text()),
    )


def main():
    interface = active_interface()

    if interface is None:
        print(json.dumps({"connected": False}))
        return

    try:
        rx1, tx1 = counters(interface)
        start = time.monotonic()
        time.sleep(1)
        rx2, tx2 = counters(interface)
        elapsed = time.monotonic() - start

        print(json.dumps({
            "connected": True,
            "interface": interface,
            "down_bps": max(0, int((rx2 - rx1) * 8 / elapsed)),
            "up_bps": max(0, int((tx2 - tx1) * 8 / elapsed)),
            "wireless": (NET / interface / "wireless").exists(),
        }))
    except (OSError, ValueError, ZeroDivisionError):
        print(json.dumps({"connected": False}))


if __name__ == "__main__":
    main()
