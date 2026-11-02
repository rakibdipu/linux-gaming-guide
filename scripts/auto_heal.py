#!/usr/bin/env python3
"""
1-Tap Auto Heal Macro for Far Cry 4 — Linux evdev & uinput
===========================================================
Problem : Far Cry 4 requires holding H/Ctrl for ~1.1s to fill
          the heal wheel, which breaks movement mid-fight.
Solution: This daemon listens for a single tap on KEY_H and
          automatically holds LEFT_CTRL for HEAL_DURATION seconds
          via a virtual uinput device — no sudo required
          (needs udev rule: configs/99-game-input.rules).

Usage   : python3 auto_heal.py   (launched by play-farcry4.sh)
"""

import time
import threading
import sys
import logging
import evdev
from evdev import ecodes

# ── Configuration ────────────────────────────────────────────
HEAL_DURATION = 1.05   # seconds to hold the heal key
LOG_LEVEL     = logging.WARNING  # change to DEBUG for verbose output
# ─────────────────────────────────────────────────────────────

logging.basicConfig(
    format="[auto_heal] %(levelname)s: %(message)s",
    level=LOG_LEVEL,
)
log = logging.getLogger(__name__)

is_healing = False


def do_heal(ui: evdev.UInput) -> None:
    """Simulate holding LEFT_CTRL for HEAL_DURATION seconds."""
    global is_healing
    try:
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 1)  # key down
        ui.syn()
        log.debug("Heal started (holding CTRL for %.2fs)", HEAL_DURATION)
        time.sleep(HEAL_DURATION)
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 0)  # key up
        ui.syn()
        log.debug("Heal finished.")
    except Exception as exc:
        log.error("Error during heal simulation: %s", exc)
    finally:
        is_healing = False


def find_keyboards() -> list:
    """
    Auto-detect physical keyboard devices via evdev.
    A keyboard must expose KEY_H and KEY_W (basic WASD check).
    """
    keyboards = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY in caps:
                keys = caps[ecodes.EV_KEY]
                if ecodes.KEY_H in keys and ecodes.KEY_W in keys:
                    keyboards.append(dev)
                    log.debug("Found keyboard: %s (%s)", dev.name, path)
        except PermissionError:
            log.debug("Permission denied for %s — check udev rules.", path)
        except Exception as exc:
            log.debug("Skipping %s: %s", path, exc)
    return keyboards


def listen_device(dev: evdev.InputDevice, ui: evdev.UInput) -> None:
    """Listen for KEY_H tap events on a single keyboard device."""
    global is_healing
    log.debug("Listening on: %s", dev.name)
    try:
        for event in dev.read_loop():
            if (
                event.type == ecodes.EV_KEY
                and event.code == ecodes.KEY_H
                and event.value == 1  # key-press (not repeat or release)
                and not is_healing
            ):
                is_healing = True
                t = threading.Thread(target=do_heal, args=(ui,), daemon=True)
                t.start()
    except OSError as exc:
        log.warning("Device %s disconnected: %s", dev.name, exc)
    except Exception as exc:
        log.error("Unexpected error on %s: %s", dev.name, exc)


def main() -> None:
    keyboards = find_keyboards()
    if not keyboards:
        log.error(
            "No keyboard found. Ensure udev rule is installed:\n"
            "  sudo cp configs/99-game-input.rules /etc/udev/rules.d/\n"
            "  sudo udevadm control --reload-rules && sudo udevadm trigger"
        )
        sys.exit(1)

    try:
        ui = evdev.UInput({ecodes.EV_KEY: [ecodes.KEY_LEFTCTRL]}, name="auto-heal-macro")
    except PermissionError:
        log.error(
            "Cannot open /dev/uinput — permission denied.\n"
            "Install the udev rule and re-login (or reboot):\n"
            "  sudo cp configs/99-game-input.rules /etc/udev/rules.d/\n"
            "  sudo udevadm control --reload-rules && sudo udevadm trigger"
        )
        sys.exit(1)
    except Exception as exc:
        log.error("Failed to create UInput device: %s", exc)
        sys.exit(1)

    threads = []
    for kbd in keyboards:
        t = threading.Thread(target=listen_device, args=(kbd, ui), daemon=True)
        t.start()
        threads.append(t)

    log.warning("Auto-heal macro active. Tap H to heal. Ctrl+C to stop.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        ui.close()
        log.warning("Auto-heal macro stopped.")


if __name__ == "__main__":
    main()
