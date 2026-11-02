# 🎮 Ubuntu / Linux Gaming Guide & Setup Documentation

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20%2F%2026.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![AMD Radeon](https://img.shields.io/badge/AMD%20Radeon-Barcelo%20%2F%20Vega%20iGPU-ED1C24?style=for-the-badge&logo=amd&logoColor=white)](https://www.amd.com/)
[![Wine](https://img.shields.io/badge/Wine-v10.x%20Staging-722F37?style=for-the-badge&logo=wine&logoColor=white)](https://www.winehq.org/)
[![DXVK](https://img.shields.io/badge/DXVK-Direct3D%20to%20Vulkan-red?style=for-the-badge&logo=vulkan&logoColor=white)](https://github.com/doitsujin/dxvk)
[![PipeWire](https://img.shields.io/badge/Audio-PipeWire%20%2B%20WirePlumber-00ADD8?style=for-the-badge)](https://pipewire.org/)
[![Python](https://img.shields.io/badge/Python-3.10%2B%20%7C%20evdev-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A comprehensive, field-tested guide and turnkey setup for running Windows games (pre-installed, portable, repacks, and standalone) smoothly on **Ubuntu Linux** without relying on Steam client UI overhead. 

This repository documents production-ready fixes for:
- **DirectX-to-Vulkan Translation (DXVK)** for near-native frame rates.
- **PipeWire & Bluetooth Audio Sync** (eliminates the ~200ms audio delay and volume spikes).
- **AMD Radeon iGPU Graphic Glitch Fixes** (resolves Far Cry 4 Dunia engine tree-spike and stretched polygon bugs).
- **Wine Key-Stuck / Focus Bug Fixes** (prevents character auto-running/walking infinitely).
- **Non-Root 1-Tap Auto-Heal Macro** built on the Linux kernel input subsystem (`evdev` & `uinput`).
- **Turnkey Automation (`install.sh`)** for instant, one-click setup across any user profile.

---

## 📑 Table of Contents

- [📌 System Specification (Reference Testbed)](#-system-specification-reference-testbed)
- [🗺️ Gaming Decision Matrix (Which Runner to Use?)](#️-gaming-decision-matrix-which-runner-to-use)
- [📂 Directory & File Architecture](#-directory--file-architecture)
- [🛠️ Prerequisites & Package Installation](#️-prerequisites--package-installation)
- [🚀 Detailed Configuration & Implementation](#-detailed-configuration--implementation)
  - [1. Custom Game Runner Script (`play-farcry4.sh`)](#1-custom-game-runner-script-play-farcry4sh)
  - [2. Graphics Glitch & Tree-Spike Fix (`GamerProfile.xml`)](#2-graphics-glitch--tree-spike-fix-gamerprofilexml)
  - [3. 1-Tap Auto-Heal Keyboard Macro (`auto_heal.py`)](#3-1-tap-auto-heal-keyboard-macro-auto_healpy)
  - [4. Non-Root Input Permission Rule (`99-game-input.rules`)](#4-non-root-input-permission-rule-99-game-inputrules)
  - [5. Desktop Entry & 1-Click Launcher (`FarCry4.desktop`)](#5-desktop-entry--1-click-launcher-farcry4desktop)
  - [6. Wine Registry Optimization (Key-Stuck & DLL Overrides)](#6-wine-registry-optimization-key-stuck--dll-overrides)
  - [7. PipeWire Low-Latency Bluetooth Audio Tuning](#7-pipewire-low-latency-bluetooth-audio-tuning)
- [⚡ Quick Start Guide](#-quick-start-guide)
- [❓ Frequently Asked Questions (Troubleshooting & FAQ)](#-frequently-asked-questions-troubleshooting--faq)
- [📄 License](#-license)

---

## 📌 System Specification (Reference Testbed)

This configuration has been thoroughly benchmarked and verified on the following hardware and software environment:

| Component | Specification |
| :--- | :--- |
| **OS** | Ubuntu 24.04 / 26.04 LTS (x86_64, Linux Kernel 6.8+) |
| **CPU** | AMD Ryzen 5 7530U (6 Cores, 12 Threads, up to 4.5 GHz) |
| **iGPU** | AMD Radeon Graphics (Barcelo / Vega 7 Architecture) |
| **Mesa Driver** | Mesa 24.x+ (RADV Vulkan driver with GPL support enabled) |
| **Wine Version** | Wine 9.0 / 10.0 (Staging / Development) 64-bit |
| **Vulkan Layer** | DXVK 2.x / 3.x (Direct3D 9/10/11 translation) |
| **Audio Server** | PipeWire 1.0+ with WirePlumber (Bluetooth AVRCP / A2DP) |
| **Input Subsystem** | Linux `evdev` + `uinput` with non-root `uaccess` rules |

---

## 🗺️ Gaming Decision Matrix (Which Runner to Use?)

Selecting the appropriate runtime environment is critical for seamless Linux gaming:

| Game Type | Recommended Runner | Why Use It? |
| :--- | :--- | :--- |
| **Steam Native Games** | **Steam + Proton / Proton Experimental** | Automatic shader pre-caching and 1-click execution backed by Valve's Proton compatibility layer. |
| **Epic Games / GOG / Amazon Prime** | **Heroic Games Launcher** | Open-source client supporting cloud saves, clean Wine prefix isolation, and direct Proton-GE switching. |
| **Portable / Pre-Installed / Repacks** | **Wine 10 + DXVK (Custom Script) / Lutris** | Bypasses third-party launcher bloat; runs games with native performance and direct fine-grained environment controls. |
| **Multiplayer Games with Anti-Cheat** | **Unsupported on Linux (Unless Native)** | Titles enforcing Kernel-level (Ring 0) anti-cheat (e.g., Valorant/Vanguard, Fortnite, COD Warzone, FC 24/25) will block Wine/Proton. |

---

## 📂 Directory & File Architecture

A visual blueprint of how files and configurations are structured in the system:

```
📁 System Root
│
├── 📂 $HOME/Games/Far-Cry-4/
│   ├── 📜 play-farcry4.sh                    # [Executable] Master game runner & environment manager
│   ├── 📜 auto_heal.py                       # [Python] Non-blocking 1-tap heal macro daemon
│   └── 📂 bin/
│       ├── 🎮 FarCry4.exe                    # Main game binary
│       ├── 🖼️ farcry4.png                    # Game desktop icon
│       ├── ⚙️ d3d11.dll                      # DXVK Direct3D 11 translation DLL
│       ├── ⚙️ dxgi.dll                       # DXVK DXGI translation DLL
│       ├── ⚙️ d3d10core.dll                  # DXVK Direct3D 10 translation DLL
│       └── ⚙️ d3d9.dll                       # DXVK Direct3D 9 translation DLL
│
├── 📂 $HOME/.wine/drive_c/windows/system32/
│   └── ⚙️ [DXVK DLLs]                        # Wine global system32 DXVK backup
│
├── 📂 $HOME/Documents/My Games/Far Cry 4/AnkerGames/
│   └── ⚙️ GamerProfile.xml                   # Engine config (Tree-spike & shadow bug patch)
│
├── 📂 $HOME/Desktop/
│   └── 🚀 FarCry4.desktop                    # Desktop 1-click launcher
│
├── 📂 $HOME/.local/share/applications/
│   └── 🚀 FarCry4.desktop                    # Application drawer integration
│
└── 📂 /etc/udev/rules.d/
    └── 📜 99-game-input.rules                # uinput & evdev non-root permission rule
```

---

## 🛠️ Prerequisites & Package Installation

### Step 1: Install Core System Dependencies
Run the following command to install the required packages:

```bash
sudo apt update && sudo apt install -y \
    wine \
    wine64 \
    winetricks \
    lutris \
    gamemode \
    xdotool \
    libxdo3 \
    python3-evdev \
    vulkan-tools \
    mesa-vulkan-drivers
```

### Step 2: Download & Setup DXVK (Vulkan Translation Layer)
DXVK translates Direct3D 9, 10, and 11 API calls to Vulkan, dramatically boosting frame rate stability:

```bash
# 1. Download latest DXVK release
#    Check latest release version at: https://github.com/doitsujin/dxvk/releases
DXVK_VER="2.4.1"
wget "https://github.com/doitsujin/dxvk/releases/download/v${DXVK_VER}/dxvk-${DXVK_VER}.tar.gz"
tar -xzf "dxvk-${DXVK_VER}.tar.gz"

# 2. Copy 64-bit DLLs to Wine system32
mkdir -p ~/.wine/drive_c/windows/system32
cp "dxvk-${DXVK_VER}/x64/"*.dll ~/.wine/drive_c/windows/system32/

# 3. Copy DLLs into the game's executable directory
cp "dxvk-${DXVK_VER}/x64/"*.dll ~/Games/Far-Cry-4/bin/
```

---

## 🚀 Detailed Configuration & Implementation

### 1. Custom Game Runner Script (`play-farcry4.sh`)
**Location:** `$HOME/Games/Far-Cry-4/play-farcry4.sh`  
**Purpose:** Sets up environment variables, forces DXVK over WineD3D, manages PipeWire audio buffers, tunes AMD Mesa drivers, starts the background auto-heal daemon, and guarantees clean process teardown on exit.

```bash
#!/bin/bash
# =============================================================
#  Far Cry 4 - Linux Launcher Script
#  Handles: DXVK (Vulkan), PipeWire audio sync,
#           AMD Radeon optimizations, 1-tap auto-heal macro
#
#  Usage: ./play-farcry4.sh
# =============================================================

GAME_DIR="$HOME/Games/Far-Cry-4"
GAME_BIN="$GAME_DIR/bin"
HEAL_SCRIPT="$GAME_DIR/auto_heal.py"

# Validate game directory
if [ ! -d "$GAME_BIN" ]; then
    echo "[ERROR] Game directory not found: $GAME_BIN"
    echo "        Please install Far Cry 4 to ~/Games/Far-Cry-4/"
    exit 1
fi

cd "$GAME_BIN" || exit 1

# 1. Force Wine to use DXVK (Vulkan) instead of slow WineD3D
export WINEDLLOVERRIDES="d3d11,dxgi,d3d10core,d3d9=n,b"
export WINEPREFIX="$HOME/.wine"

# 2. Bluetooth & PipeWire audio latency fix
#    Eliminates ~200ms Bluetooth audio delay and volume spikes
export PULSE_LATENCY_MSEC=50
export PIPEWIRE_LATENCY="512/48000"

# 3. AMD Radeon iGPU performance optimizations
#    GPL: enables Graphics Pipeline Library for faster shader compilation
#    mesa_glthread: offloads GL calls to a separate CPU thread
export RADV_PERFTEST=gpl
export mesa_glthread=true

# 4. Launch 1-tap auto-heal helper as a background daemon
if [ -f "$HEAL_SCRIPT" ]; then
    python3 "$HEAL_SCRIPT" &
    HEAL_PID=$!
else
    echo "[WARN] auto_heal.py not found, skipping heal macro."
    HEAL_PID=""
fi

# Cleanup: kill background heal helper when game exits
cleanup() {
    if [ -n "$HEAL_PID" ]; then
        kill "$HEAL_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

# 5. Run game via GameMode (CPU governor boost) if available
if command -v gamemoderun >/dev/null 2>&1; then
    gamemoderun /usr/bin/wine64 ./FarCry4.exe "$@"
else
    /usr/bin/wine64 ./FarCry4.exe "$@"
fi
```

Make the script executable:
```bash
chmod +x ~/Games/Far-Cry-4/play-farcry4.sh
```

---

### 2. Graphics Glitch & Tree-Spike Fix (`GamerProfile.xml`)
**Location:** `$HOME/Documents/My Games/Far Cry 4/AnkerGames/GamerProfile.xml`  

#### The Problem:
On AMD Radeon integrated graphics (Vega / Barcelo), running Far Cry 4 through DXVK caused foliage and tree branches to stretch into long, spiked polygon artifacts extending across the screen, along with rectangular black bounding boxes around leaves.

#### The Fix:
Modify the `<RenderProfile>` section in `GamerProfile.xml`:

```xml
<RenderProfile 
    AntiAliasingMode="0" 
    UseTrippleBuffering="0" 
    VSyncMode="1" 
    UseMotionBlur="0" 
    SSAOLevel="0" 
    EnableNvidiaPCSS="0" 
    GodRaysLevel="0" 
    FurLevel="0" 
    TreeTessellationLevel="0" 
    AlphaToCoverage="0" 
    ResolutionX="1920" 
    ResolutionY="1080" 
    Quality="low" 
    Fullscreen="1" 
    UseD3D11="1" 
    GPUMaxBufferedFrames="1" 
    AllowAsynchShaderLoading="1">
    <RealTreeProfile Quality="Low" />
</RenderProfile>
```

#### Key Adjustments Explained:
- `AlphaToCoverage="0"`: Removes black box artifacts around leaves and transparent textures.
- `TreeTessellationLevel="0"`: Disables geometry tessellation on vegetation, eliminating stretched polygon spikes.
- `<RealTreeProfile Quality="Low" />`: Prevents vegetation rendering bugs on integrated AMD hardware.
- `GPUMaxBufferedFrames="1"`: Minimizes input latency and reduces frame pacing stutter.

---

### 3. 1-Tap Auto-Heal Keyboard Macro (`auto_heal.py`)
**Location:** `$HOME/Games/Far-Cry-4/auto_heal.py`  

#### The Problem:
Far Cry 4 requires holding the heal button (`H` or `Ctrl`) for ~1.1 seconds to fill the radial syringe wheel. Holding a key during intense gunfights interrupts player movement and evasive maneuvering.

#### The Solution:
Using Linux kernel input events (`evdev`) and a virtual input device (`uinput`), this script listens for a single quick tap on `H` and simulates holding `KEY_LEFTCTRL` for exactly 1.05 seconds asynchronously in a background thread.

```python
#!/usr/bin/env python3
"""
1-Tap Auto Heal Macro for Far Cry 4 — Linux evdev & uinput
===========================================================
Listens for a single tap on KEY_H and automatically holds
LEFT_CTRL for HEAL_DURATION seconds via a virtual uinput
device without requiring sudo (requires udev rule).
"""

import time
import threading
import sys
import logging
import evdev
from evdev import ecodes

HEAL_DURATION = 1.05   # Seconds to hold the heal key
LOG_LEVEL     = logging.WARNING

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
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 1)  # Key Down
        ui.syn()
        time.sleep(HEAL_DURATION)
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 0)  # Key Up
        ui.syn()
    except Exception as exc:
        log.error("Error during heal simulation: %s", exc)
    finally:
        is_healing = False

def find_keyboards() -> list:
    """Auto-detect physical keyboard devices via evdev."""
    keyboards = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY in caps:
                keys = caps[ecodes.EV_KEY]
                if ecodes.KEY_H in keys and ecodes.KEY_W in keys:
                    keyboards.append(dev)
        except PermissionError:
            log.debug("Permission denied for %s — verify udev rules.", path)
        except Exception:
            pass
    return keyboards

def listen_device(dev: evdev.InputDevice, ui: evdev.UInput) -> None:
    """Listen for KEY_H tap events on a keyboard device."""
    global is_healing
    try:
        for event in dev.read_loop():
            if (
                event.type == ecodes.EV_KEY
                and event.code == ecodes.KEY_H
                and event.value == 1  # Key Down
                and not is_healing
            ):
                is_healing = True
                t = threading.Thread(target=do_heal, args=(ui,), daemon=True)
                t.start()
    except OSError:
        pass

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
            "Cannot open /dev/uinput (Permission denied).\n"
            "Install udev rule:\n"
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

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        ui.close()

if __name__ == "__main__":
    main()
```

---

### 4. Non-Root Input Permission Rule (`99-game-input.rules`)
**Location:** `/etc/udev/rules.d/99-game-input.rules`  
**Purpose:** Grants the active desktop user access to `/dev/uinput` and `/dev/input/event*` nodes via `uaccess` without requiring root or `sudo` privileges.

```udev
KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
KERNEL=="event*", SUBSYSTEM=="input", TAG+="uaccess"
```

Apply and reload rules immediately:
```bash
sudo cp configs/99-game-input.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

### 5. Desktop Entry & 1-Click Launcher (`FarCry4.desktop`)
**Location:**  
- Desktop: `~/Desktop/FarCry4.desktop`
- App Drawer: `~/.local/share/applications/FarCry4.desktop`

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Far Cry 4
Comment=Play Far Cry 4 on Ubuntu Linux via Wine + DXVK
Exec=/home/YOUR_USERNAME/Games/Far-Cry-4/play-farcry4.sh
Path=/home/YOUR_USERNAME/Games/Far-Cry-4/bin
Icon=/home/YOUR_USERNAME/Games/Far-Cry-4/bin/farcry4.png
Terminal=false
Categories=Game;
StartupNotify=true
```

Enable double-click launching on Ubuntu desktop:
```bash
chmod +x ~/Desktop/FarCry4.desktop
gio set ~/Desktop/FarCry4.desktop metadata::trusted true 2>/dev/null || true
```

---

### 6. Wine Registry Optimization (Key-Stuck & DLL Overrides)
Wine sessions occasionally trigger key-stuck bugs (characters endlessly auto-running or strafing) when focus changes. Apply the following registry keys to resolve X11 focus and enforce native DXVK:

```bash
# 1. Enforce native DXVK overrides in Wine registry
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /t REG_SZ /d 'native,builtin' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi /t REG_SZ /d 'native,builtin' /f

# 2. Prevent key-stuck and input focus loss (X11 Driver)
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v UseTakeFocus /t REG_SZ /d 'N' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v GrabPointer /t REG_SZ /d 'Y' /f
```

---

### 7. PipeWire Low-Latency Bluetooth Audio Tuning
Wine with PulseAudio emulation often induces 200–300ms latency on Bluetooth headphones (A2DP/AAC/SBC) and random volume fluctuations.

The following variables in `play-farcry4.sh` resolve this:
- `PULSE_LATENCY_MSEC=50`: Locks the audio buffer latency to 50ms.
- `PIPEWIRE_LATENCY="512/48000"`: Forces PipeWire hardware buffer quantum to 512 samples at 48kHz, preventing crackling while keeping audio synchronized with gameplay actions.

---

## ⚡ Quick Start Guide

To set up everything on a fresh machine in one single command:

```bash
# 1. Clone the repository
git clone https://github.com/rakibdipu/linux-gaming-guide.git
cd linux-gaming-guide

# 2. Run the automated installer
bash install.sh
```

> **Note:** `install.sh` automatically installs all system packages, deploys udev rules, applies Wine registry optimizations, and generates desktop launchers with your dynamic `$HOME` path.

---

## ❓ Frequently Asked Questions (Troubleshooting & FAQ)

### Q: The game opens to a black screen and closes immediately.
> **Answer:** This typically indicates that `WINEDLLOVERRIDES` could not locate DXVK DLLs or Vulkan is not initialized. Verify that `d3d11.dll` and `dxgi.dll` are in `~/Games/Far-Cry-4/bin/` and test your Vulkan stack using `vulkaninfo`.

### Q: My character keeps walking forward automatically (Key Stuck bug).
> **Answer:** This is a known Wine X11 window focus bug. Setting `UseTakeFocus=N` and `GrabPointer=Y` in the Wine registry resolves it (see [Section 6](#6-wine-registry-optimization-key-stuck--dll-overrides)).

### Q: Running `auto_heal.py` gives `PermissionError: /dev/uinput`.
> **Answer:** The current user lacks permission to access the input subsystem. Copy `configs/99-game-input.rules` to `/etc/udev/rules.d/` and reload udev using `sudo udevadm trigger` (or reboot).

### Q: Can I run DirectX 12 games with this exact setup?
> **Answer:** DXVK handles DirectX 9, 10, and 11. For DirectX 12 games (e.g., Cyberpunk 2077, Elden Ring), use **VKD3D-Proton** (included natively in Lutris or Heroic Games Launcher).

---

## 📄 License

This documentation and accompanying scripts are licensed under the [MIT License](LICENSE). Contributions, issues, and forks are welcome!

Happy Gaming on Linux! 🐧🎮
