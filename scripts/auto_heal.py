#!/usr/bin/env python3
import time
import threading
import sys
import os
import evdev
from evdev import ecodes

HEAL_DURATION = 1.05  # seconds to hold heal key
is_healing = False

def do_heal(ui):
    global is_healing
    try:
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 1)
        ui.syn()
        time.sleep(HEAL_DURATION)
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 0)
        ui.syn()
    finally:
        is_healing = False

def find_keyboards():
    keyboards = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY in caps:
                keys = caps[ecodes.EV_KEY]
                if ecodes.KEY_H in keys and ecodes.KEY_W in keys:
                    keyboards.append(dev)
        except Exception:
            pass
    return keyboards

def listen_device(dev, ui):
    global is_healing
    try:
        for event in dev.read_loop():
            if event.type == ecodes.EV_KEY and event.code == ecodes.KEY_H:
                if event.value == 1 and not is_healing:
                    is_healing = True
                    t = threading.Thread(target=do_heal, args=(ui,), daemon=True)
                    t.start()
    except Exception:
        pass

def main():
    keyboards = find_keyboards()
    if not keyboards:
        sys.exit(1)

    try:
        ui = evdev.UInput({ecodes.EV_KEY: [ecodes.KEY_LEFTCTRL]})
    except Exception as e:
        sys.exit(1)

    threads = []
    for kbd in keyboards:
        t = threading.Thread(target=listen_device, args=(kbd, ui), daemon=True)
        t.start()
        threads.append(t)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        ui.close()

if __name__ == '__main__':
    main()
