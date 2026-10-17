#!/usr/bin/env python3

from pathlib import Path
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


EGPU_VENDOR = "0x10de"
EGPU_DEVICE = "0x2c05"


def normalize_pci(address):
    """Normalize NVIDIA and sysfs PCI bus addresses."""
    try:
        domain, bus, device_function = address.strip().split(":")
        device, function = device_function.split(".")

        return (
            f"{int(domain, 16):04x}:"
            f"{int(bus, 16):02x}:"
            f"{int(device, 16):02x}."
            f"{int(function, 16):x}"
        )
    except (ValueError, AttributeError):
        return None


def egpu_pci():
    """Locate the external NVIDIA GPU without changing its state."""
    for path in Path("/sys/bus/pci/devices").glob("*"):
        try:
            vendor = (path / "vendor").read_text().strip().lower()
            device = (path / "device").read_text().strip().lower()

            if (vendor, device) != (EGPU_VENDOR, EGPU_DEVICE):
                continue

            driver_link = path / "driver"
            driver = (
                driver_link.resolve().name
                if driver_link.exists()
                else "unbound"
            )

            return {
                "pci": normalize_pci(path.name),
                "driver": driver,
            }
        except OSError:
            continue

    return None


def nvidia_gpu_stats():
    fields = [
        "pci.bus_id",
        "name",
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

        devices = {}

        for row in csv.reader(io.StringIO(result.stdout)):
            if len(row) != len(fields):
                continue

            (
                pci, name, util, temp,
                used, total, power, pstate
            ) = [value.strip() for value in row]

            pci = normalize_pci(pci)
            if pci is None:
                continue

            def numeric(value, converter):
                try:
                    return converter(value)
                except (ValueError, TypeError):
                    return None

            used_mib = numeric(used, float)
            total_mib = numeric(total, float)

            devices[pci] = {
                "pci": pci,
                "name": name,
                "usage": numeric(util, int),
                "temperature": numeric(temp, int),
                "memoryUsed": (
                    round(used_mib / 1024, 1)
                    if used_mib is not None else None
                ),
                "memoryTotal": (
                    round(total_mib / 1024, 1)
                    if total_mib is not None else None
                ),
                "power": numeric(power, float),
                "pstate": pstate,
            }

        return devices

    except (
        FileNotFoundError,
        subprocess.SubprocessError,
        OSError,
    ):
        return {}


def gpu_stats():
    external = egpu_pci()
    devices = nvidia_gpu_stats()

    external_pci = external["pci"] if external else None

    internal = next(
        (
            gpu for pci, gpu in devices.items()
            if pci != external_pci
        ),
        None,
    )

    if external is None:
        return internal, None

    egpu = {
        "pci": external_pci,
        "driver": external["driver"],
        "gpu": (
            devices.get(external_pci)
            if external["driver"] == "nvidia"
            else None
        ),
    }

    return internal, egpu


if __name__ == "__main__":
    internal_gpu, external_gpu = gpu_stats()

    print(json.dumps({
        "cpu": cpu_usage(),
        "memory": memory_usage(),
        "temperature": cpu_temperature(),
        "gpu": internal_gpu,
        "egpu": external_gpu,
    }))
