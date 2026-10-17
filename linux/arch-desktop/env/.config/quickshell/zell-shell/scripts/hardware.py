#!/usr/bin/env python3

import csv
import glob
import io
import json
import subprocess
import time


def cpu_times():
    with open("/proc/stat", encoding="utf-8") as f:
        values = list(map(int, f.readline().split()[1:]))

    idle = values[3] + values[4]
    return idle, sum(values)


def cpu_usage():
    idle1, total1 = cpu_times()
    time.sleep(0.2)
    idle2, total2 = cpu_times()

    delta = total2 - total1
    if delta <= 0:
        return 0

    return round(100 * (1 - (idle2 - idle1) / delta))


def memory_usage():
    values = {}

    with open("/proc/meminfo", encoding="utf-8") as f:
        for line in f:
            key, value = line.split(":", 1)
            values[key] = int(value.strip().split()[0])

    total = values["MemTotal"]
    available = values["MemAvailable"]

    return round(100 * (total - available) / total)


def cpu_temperature():
    paths = glob.glob(
        "/sys/devices/pci0000:00/"
        "0000:00:18.3/hwmon/hwmon*/temp1_input"
    )

    for path in paths:
        try:
            with open(path, encoding="utf-8") as f:
                return round(int(f.read().strip()) / 1000)
        except (OSError, ValueError):
            continue

    return None


def gpu_stats():
    fields = [
        "utilization.gpu",
        "temperature.gpu",
        "memory.used",
        "memory.total",
        "power.draw",
        "pstate",
    ]

    try:
        result = subprocess.run(
            [
                "nvidia-smi",
                "--query-gpu=" + ",".join(fields),
                "--format=csv,noheader,nounits",
            ],
            capture_output=True,
            text=True,
            timeout=3,
            check=True,
        )

        rows = list(csv.reader(io.StringIO(result.stdout)))

        if not rows or len(rows[0]) != len(fields):
            return None

        values = [value.strip() for value in rows[0]]

        util, temp, used, total, power, pstate = values

        return {
            "usage": int(util),
            "temperature": int(temp),
            "memoryUsed": round(float(used) / 1024, 1),
            "memoryTotal": round(float(total) / 1024, 1),
            "power": (
                None if power in ("N/A", "[Not Supported]")
                else round(float(power), 1)
            ),
            "pstate": pstate,
        }

    except (
        FileNotFoundError,
        subprocess.SubprocessError,
        ValueError,
        IndexError,
    ):
        return None


if __name__ == "__main__":
    print(json.dumps({
        "cpu": cpu_usage(),
        "memory": memory_usage(),
        "temperature": cpu_temperature(),
        "gpu": gpu_stats(),
    }))
