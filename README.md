# 🎮 Ubuntu / Linux Gaming Guide & Setup Documentation

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20%2F%2026.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![AMD Radeon](https://img.shields.io/badge/AMD%20Radeon-Barcelo%20%2F%20Vega%20iGPU-ED1C24?style=for-the-badge&logo=amd&logoColor=white)](https://www.amd.com/)
[![Wine](https://img.shields.io/badge/Wine-v10.x%20Staging-722F37?style=for-the-badge&logo=wine&logoColor=white)](https://www.winehq.org/)
[![DXVK](https://img.shields.io/badge/DXVK-Direct3D%20to%20Vulkan-red?style=for-the-badge&logo=vulkan&logoColor=white)](https://github.com/doitsujin/dxvk)
[![PipeWire](https://img.shields.io/badge/Audio-PipeWire%20%2B%20WirePlumber-00ADD8?style=for-the-badge)](https://pipewire.org/)
[![Python](https://img.shields.io/badge/Python-3.10%2B%20%7C%20evdev-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A comprehensive, field-tested guide and turnkey setup for running Windows games (pre-installed, portable, repacks, and standalone) smoothly on **Ubuntu Linux** without relying on Steam client UI overhead. 

This repository documents the exact fixes for **DirectX-to-Vulkan translation (DXVK)**, **PipeWire Bluetooth audio latency sync**, **AMD Radeon iGPU graphic glitch fixes (Far Cry 4 tree spike glitch)**, **Wine key-stuck/auto-run bugs**, and a **custom low-level 1-tap auto-heal keyboard macro via `evdev` & `uinput`** running without `sudo`.

---

## 📑 Table of Contents (সূচিপত্র)

- [📌 System Specification (Reference Testbed)](#-system-specification-reference-testbed)
- [🗺️ কোন টাইপের গেম কিসে চালাবেন? (Gaming Decision Matrix)](#️-কোন-টাইপের-গেম-কিসে-চালাবেন-gaming-decision-matrix)
- [📂 ফাইল ও ডিরেক্টরি আর্কিটেকচার (File Locations)](#-ফাইল-ও-ডিরেক্টরি-আর্কিটেকচার-file-locations)
- [🛠️ প্রয়োজনীয় প্যাকেজ ও টুলস ইনস্টলেশন (Prerequisites)](#️-প্রয়োজনীয়-প্যাকেজ-ও-টুলস-ইনস্টলেশন-prerequisites)
- [🚀 বিস্তারিত কনফিগারেশন ও স্ক্রিপ্টসমূহ (Detailed Setup)](#-বিস্তারিত-কনফিগারেশন-ও-স্ক্রিপ্টসমূহ-detailed-setup)
  - [১. কাস্টম গেম রানার স্ক্রিপ্ট (`play-farcry4.sh`)](#১-কাস্টম-গেম-রানার-স্ক্রিপ্ট-play-farcry4sh)
  - [২. গ্রাফিক্স ও ট্রি-স্পাইক গ্লিচ ফিক্স (`GamerProfile.xml`)](#২-গ্রাফিক্স-ও-ট্রি-স্পাইক-গ্লিচ-ফিক্স-gamerprofilexml)
  - [৩. ১-ট্যাপ অটো-হিল ম্যাক্রো স্ক্রিপ্ট (`auto_heal.py`)](#৩-১-ট্যাপ-অটো-হিল-ম্যাক্রো-স্ক্রিপ্ট-auto_healpy)
  - [৪. রুট ছাড়া ইনপুট পারমিশন রুল (`99-game-input.rules`)](#৪-রুট-ছাড়া-ইনপুট-পারমিশন-রুল-99-game-inputrules)
  - [৫. ডেক্সটপ এন্ট্রি ও ১-ক্লিক লঞ্চার (`FarCry4.desktop`)](#৫-ডেক্সটপ-এন্ট্রি-ও-১-ক্লিক-লঞ্চার-farcry4desktop)
  - [৬. ওয়াইন রেজিস্ট্রি অপ্টিমাইজেশন (Wine Key-Stuck & DLL Overrides)](#৬-ওয়াইন-রেজিস্ট্রি-অপ্টিমাইজেশন-wine-key-stuck--dll-overrides)
  - [৭. ব্লুটুথ ও পাইপওয়্যারে অডিও ল্যাটেন্সি ফিক্স (PipeWire Low Latency)](#৭-ব্লুটুথ-ও-পাইপওয়্যারে-অডিও-ল্যাটেন্সি-ফিক্স-pipewire-low-latency)
- [⚡ Quick Start Guide (এক নজরে ফুল সেটআপ)](#-quick-start-guide-এক-নজরে-ফুল-সেটআপ)
- [❓ সাধারণ সমস্যা ও সমাধান (Troubleshooting & FAQ)](#-সাধারণ-সমস্যা-ও-সমাধান-troubleshooting--faq)
- [📄 লাইসেন্স (License)](#-লাইসেন্স-license)

---

## 📌 System Specification (Reference Testbed)

এই সেটআপটি নিচের হার্ডওয়্যার ও অপারেটিং সিস্টেমে পরীক্ষিত এবং ১০০% কার্যকর:

| Component | Specification |
| :--- | :--- |
| **OS** | Ubuntu 24.04 / 26.04 LTS (x86_64, Linux 6.8+ kernel) |
| **CPU** | AMD Ryzen 5 7530U (6 Cores, 12 Threads, up to 4.5 GHz) |
| **iGPU** | AMD Radeon Graphics (Barcelo / Vega 7 Architecture) |
| **Mesa Driver** | Mesa 24.x+ (RADV Vulkan driver with GPL support) |
| **Wine Version** | Wine 9.0 / 10.0 (Staging / Development) 64-bit |
| **Vulkan Layer** | DXVK 2.x / 3.x (Direct3D 9/10/11 translation) |
| **Audio Server** | PipeWire 1.0+ with WirePlumber (Bluetooth AVRCP / A2DP) |
| **Input Subsystem** | Linux `evdev` + `uinput` with non-root uaccess rules |

---

## 🗺️ কোন টাইপের গেম কিসে চালাবেন? (Gaming Decision Matrix)

লিনাক্সে গেম খেলার সময় সঠিক টুল নির্বাচন করা সবচেয়ে জরুরি:

| গেমের ধরন (Game Type) | সেরা রানার (Best Tool) | কেন ব্যবহার করবেন? (Reason) |
| :--- | :--- | :--- |
| **Steam এর নিজস্ব গেম** | **Steam + Proton / Proton Experimental** | অটোমেটিক শেডার ক্যাশ ডাউনলোড ও ভালভ-এর প্রোটন দিয়ে কোনো ঝামেলা ছাড়াই সরাসরি রান হয়। |
| **Epic Games / GOG / Amazon Games** | **Heroic Games Launcher** | ক্লাউড সেভ সিঙ্ক সাপোর্ট করে, সম্পূর্ণ ওপেন সোর্স এবং সহজে Proton-GE নির্বাচন করা যায়। |
| **পোর্টেবল / ক্র্যাকড / প্রি-ইনস্টল্ড ফোল্ডার গেম** | **Wine 10 + DXVK (Custom Runner Script) / Lutris** | লঞ্চার অ্যাপের ব্যাকগ্রাউন্ড সিপিইউ/র‍্যাম ওভারহেড ছাড়া সরাসরি নেটিভ স্পিডে চলে। |
| **মাল্টিপ্লেয়ার গেম (Kernel Anti-Cheat)** | **লিনাক্সে খেলা সম্ভব নয় (Unless Native)** | Valorant (Vanguard), COD Warzone (Ricochet), Fortnite (EAC/BattlEye) লিনাক্স কার্নেল ব্লক করে। |

---

## 📂 ফাইল ও ডিরেক্টরি আর্কিটেকচার (File Locations)

সিস্টেমে কোন ফাইল কোথায় থাকবে তার একটি পরিচ্ছন্ন রোডম্যাপ:

```
📁 System Root
│
├── 📂 /home/$USER/Games/Far-Cry-4/
│   ├── 📜 play-farcry4.sh                    # [Executable] মূল গেম রানার স্ক্রিপ্ট
│   ├── 📜 auto_heal.py                       # [Python] 1-ট্যাপ অটো-হিল ব্যাকগ্রাউন্ড ম্যাক্রো
│   └── 📂 bin/
│       ├── 🎮 FarCry4.exe                    # মূল গেম এক্সিকিউটেবল
│       ├── 🖼️ farcry4.png                    # গেমের ডেক্সটপ আইকন
│       ├── ⚙️ d3d11.dll                      # DXVK Direct3D 11 লাইব্রেরি
│       ├── ⚙️ dxgi.dll                       # DXVK DXGI লাইব্রেরি
│       ├── ⚙️ d3d10core.dll                  # DXVK Direct3D 10 লাইব্রেরি
│       └── ⚙️ d3d9.dll                       # DXVK Direct3D 9 লাইব্রেরি
│
├── 📂 /home/$USER/.wine/drive_c/windows/system32/
│   └── ⚙️ [DXVK DLLs]                        # Wine গ্লোবাল DXVK ব্যাকআপ
│
├── 📂 /home/$USER/Documents/My Games/Far Cry 4/AnkerGames/
│   └── ⚙️ GamerProfile.xml                   # গ্রাফিক্স সেটিংস ও ট্রি-স্পাইক ফিক্স কনফিগ
│
├── 📂 /home/$USER/Desktop/
│   └── 🚀 FarCry4.desktop                    # ডেক্সটপ শর্টকাট আইকন
│
├── 📂 /home/$USER/.local/share/applications/
│   └── 🚀 FarCry4.desktop                    # উবুন্টু অ্যাপ মেনু শর্টকাট
│
└── 📂 /etc/udev/rules.d/
    └── 📜 99-game-input.rules                # uinput ও কিবোর্ড ইভেন্ট নন-রুট পারমিশন রুল
```

---

## 🛠️ প্রয়োজনীয় প্যাকেজ ও টুলস ইনস্টলেশন (Prerequisites)

### ধাপ ১: সিস্টেম আপডেট এবং প্রয়োজনীয় ডিপেন্ডেন্সি ইনস্টল
টার্মিনালে নিচের কমান্ডটি একবারে রান করুন:

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

### ধাপ ২: DXVK (Vulkan Translation Layer) ডাউনলোড ও সেটআপ
DXVK ডিরেক্টএক্স ৯, ১০ এবং ১১ কলগুলোকে আধুনিক ভালকানে কনভার্ট করে এফপিএস দ্বিগুণ করে দেয়:

```bash
# ১. লেটেস্ট রিলিজ ডাউনলোড
wget https://github.com/doitsujin/dxvk/releases/download/v2.4/dxvk-2.4.tar.gz
tar -xzf dxvk-2.4.tar.gz

# ২. Wine সিস্টেম ডিরেক্টরিতে 64-bit DLL গুলো কপি
mkdir -p ~/.wine/drive_c/windows/system32
cp dxvk-2.4/x64/*.dll ~/.wine/drive_c/windows/system32/

# ৩. গেমের নিজস্ব bin ফোল্ডারে কপি (গেম যেন সরাসরি লোড করে)
cp dxvk-2.4/x64/*.dll /home/$USER/Games/Far-Cry-4/bin/
```

---

## 🚀 বিস্তারিত কনফিগারেশন ও স্ক্রিপ্টসমূহ (Detailed Setup)

### ১. কাস্টম গেম রানার স্ক্রিপ্ট (`play-farcry4.sh`)
**লোকেশন:** `/home/$USER/Games/Far-Cry-4/play-farcry4.sh`  
**কাজ:** গেম চালু করার সময় গ্রাফিক্স (DXVK), অডিও সিনক্রোনাইজেশন (PipeWire), জিপিইউ অপ্টিমাইজেশন এবং অটো-হিল ম্যাক্রো একসাথে লোড করে এবং গেম বন্ধ হলে ক্লিনআপ করে।

```bash
#!/bin/bash
# -------------------------------------------------------------
# Linux Game Runner Script with DXVK, Audio Sync & Evdev Macro
# -------------------------------------------------------------
cd /home/$USER/Games/Far-Cry-4/bin || exit 1

# ১. Wine কে ডিফল্ট WineD3D এর বদলে নেটিভ DXVK (Vulkan) ব্যবহার করতে বাধ্য করা
export WINEDLLOVERRIDES="d3d11,dxgi,d3d10core,d3d9=n,b"
export WINEPREFIX="/home/$USER/.wine"

# ২. ব্লুটুথ হেডফোন ও পাইপওয়্যারে অডিও ডিলে / ভলিউম ওঠানামা ফিক্স
export PULSE_LATENCY_MSEC=50
export PIPEWIRE_LATENCY="512/48000"

# ৩. AMD Radeon iGPU পারফরম্যান্স অপ্টিমাইজেশন (GPL Shader Pre-caching & Multithreading)
export RADV_PERFTEST=gpl
export mesa_glthread=true

# ৪. ১-ট্যাপ অটো-হিল হেল্পার ব্যাকগ্রাউন্ড ডেমন হিসেবে চালু
python3 /home/$USER/Games/Far-Cry-4/auto_heal.py &
HEAL_PID=$!

# গেম এক্সিট করলে ব্যাকগ্রাউন্ড হেল্পার বন্ধ করার ক্লিনআপ ট্র্যাপ
cleanup() {
    kill "$HEAL_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# ৫. GameMode দিয়ে গেম রান (প্রসেস প্রায়োরিটি ও সিপিইউ গভর্নেন্স বুস্ট)
if command -v gamemoderun >/dev/null 2>&1; then
    gamemoderun /usr/bin/wine64 ./FarCry4.exe "$@"
else
    /usr/bin/wine64 ./FarCry4.exe "$@"
fi
```

স্ক্রিপ্টটিকে এক্সিকিউটেবল পারমিশন দিন:
```bash
chmod +x /home/$USER/Games/Far-Cry-4/play-farcry4.sh
```

---

### ২. গ্রাফিক্স ও ট্রি-স্পাইক গ্লিচ ফিক্স (`GamerProfile.xml`)
**লোকেশন:** `/home/$USER/Documents/My Games/Far Cry 4/AnkerGames/GamerProfile.xml`  

#### সমস্যা:
AMD Radeon Integrated Graphics (Vega/Barcelo) এ লিনাক্সে DXVK দিয়ে গেমটি রান করলে গাছপালার ডাল ও পাতা স্ট্রেচ হয়ে স্ক্রিনজুড়ে অদ্ভুত লম্বা সূঁচালো পিক্সেল (Spikes) তৈরি হতো এবং পাতার চারপাশে কালো বক্স আসতো।

#### সমাধান:
`GamerProfile.xml` ফাইলের `<RenderProfile>` সেকশনে নিচের প্যারামিটারগুলো পরিবর্তন করা হয়েছে:

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

#### মূল ফিক্সগুলোর ব্যাখ্যা:
- `AlphaToCoverage="0"`: পাতার চারপাশের অস্বস্তিকর কালো চারকোনা বক্স দূর করে।
- `TreeTessellationLevel="0"`: গাছের ডালের পলিগন ব্রেকিং এবং স্ক্রিনজুড়ে স্পাইক ছড়িয়ে পড়া বন্ধ করে।
- `<RealTreeProfile Quality="Low" />`: ভেজিটেশন রেন্ডারিং গ্লিচ সম্পূর্ণ রিমুভ করে।
- `GPUMaxBufferedFrames="1"`: ইনপুট ল্যাগ এবং ফ্রেম পেসিং স্টাটারিং বন্ধ করে রেসপন্সিভনেস বাড়ায়।

---

### ৩. ১-ট্যাপ অটো-হিল ম্যাক্রো স্ক্রিপ্ট (`auto_heal.py`)
**লোকেশন:** `/home/$USER/Games/Far-Cry-4/auto_heal.py`  

#### সমস্যা:
ফার ক্রাই ৪-এ হিল করতে `H` বা `Ctrl` কি-টি প্রায় ১.১ সেকেন্ড ধরে চেপে রেখে চাকা ভরাতে হয়, যা ফাইট চলাকালীন মুভমেন্ট নষ্ট করে।

#### সমাধান:
Linux কার্নেল ইনপুট সাবসিস্টেম (`evdev`) এবং ভার্চুয়াল ইনপুট ডিভাইস (`uinput`) ব্যবহার করে ব্যাকগ্রাউন্ড ম্যাক্রো তৈরি করা হয়েছে। কিবোর্ডে `H` বাটন একবার প্রেস করলেই এটি স্বয়ংক্রিয়ভাবে গেমের ভেতরে `Ctrl` কি-টি নিখুঁত ১.০৫ সেকেন্ড হোল্ড করে রেখে ছেড়ে দেয়।

```python
#!/usr/bin/env python3
"""
1-Tap Auto Heal Macro for Far Cry 4 via Linux evdev & uinput.
Listens for a quick tap on 'H' and automatically triggers a 1.05s
simulated hold of 'KEY_LEFTCTRL' without blocking user input.
"""

import time
import threading
import sys
import os
import evdev
from evdev import ecodes

HEAL_DURATION = 1.05  # সেকেন্ড ধরে হিল কি হোল্ড করবে
is_healing = False

def do_heal(ui):
    """ভার্চুয়াল কীবোর্ডের মাধ্যমে বাম Ctrl কি চেপে ধরে রেখে ছেড়ে দেয়"""
    global is_healing
    try:
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 1)  # Key Down
        ui.syn()
        time.sleep(HEAL_DURATION)
        ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, 0)  # Key Up
        ui.syn()
    finally:
        is_healing = False

def find_keyboards():
    """সিস্টেমের সক্রিয় ফিজিক্যাল কীবোর্ড ডিভাইসগুলো স্বয়ংক্রিয়ভাবে শনাক্ত করে"""
    keyboards = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY in caps:
                keys = caps[ecodes.EV_KEY]
                # সাধারণ কীবোর্ডে H এবং W কি অবশ্যই থাকবে
                if ecodes.KEY_H in keys and ecodes.KEY_W in keys:
                    keyboards.append(dev)
        except Exception:
            pass
    return keyboards

def listen_device(dev, ui):
    """কীবোর্ড থেকে 'H' কি প্রেস ইভেন্ট শোনে"""
    global is_healing
    try:
        for event in dev.read_loop():
            if event.type == ecodes.EV_KEY and event.code == ecodes.KEY_H:
                if event.value == 1 and not is_healing:  # বাটন প্রেস
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
        print(f"Error initializing UInput: {e}")
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
```

---

### ৪. রুট ছাড়া ইনপুট পারমিশন রুল (`99-game-input.rules`)
**লোকেশন:** `/etc/udev/rules.d/99-game-input.rules`  
**কাজ:** সাধারণ ইউজার অ্যাকাউন্টকে কোনো `sudo` বা রুট পারমিশন ছাড়াই ভার্চুয়াল ইনপুট (`uinput`) এবং কীবোর্ড ইভেন্ট রিড করার সুযোগ দেয়।

```udev
KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
KERNEL=="event*", SUBSYSTEM=="input", TAG+="uaccess"
```

রুলটি অ্যাপ্লাই ও অ্যাক্টিভেট করার কমান্ড:
```bash
sudo tee /etc/udev/rules.d/99-game-input.rules << 'EOF'
KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
KERNEL=="event*", SUBSYSTEM=="input", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

### ৫. ডেক্সটপ এন্ট্রি ও ১-ক্লিক লঞ্চার (`FarCry4.desktop`)
**লোকেশন:**  
- ডেক্সটপ: `/home/$USER/Desktop/FarCry4.desktop`
- সিস্টেম অ্যাপ ড্রয়ার: `/home/$USER/.local/share/applications/FarCry4.desktop`

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Far Cry 4
Comment=Play Far Cry 4 on Ubuntu Linux
Exec=/home/dipu/Games/Far-Cry-4/play-farcry4.sh
Path=/home/dipu/Games/Far-Cry-4/bin
Icon=/home/dipu/Games/Far-Cry-4/bin/farcry4.png
Terminal=false
Categories=Game;
StartupNotify=true
```

ডেক্সটপে ডাবল-ক্লিক কাজ করার জন্য পারমিশন ও ট্রাস্ট সেট করুন:
```bash
chmod +x ~/Desktop/FarCry4.desktop
gio set ~/Desktop/FarCry4.desktop metadata::trusted true 2>/dev/null || true
```

---

### ৬. ওয়াইন রেজিস্ট্রি অপ্টিমাইজেশন (Wine Key-Stuck & DLL Overrides)
Wine এনভায়রনমেন্টে গেমের মধ্যে কিবোর্ড চাপলে অনেক সময় কি-স্টাক (Auto-run/Auto-walk) হয়ে যায় এবং ফোকাস লস্ট হয়। এটি বন্ধ করতে এবং DXVK এনফোর্স করতে এই কমান্ডগুলো রান করুন:

```bash
# ১. DXVK DllOverrides নিশ্চিত করা
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /t REG_SZ /d 'native,builtin' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi /t REG_SZ /d 'native,builtin' /f

# ২. কি-স্টাক / অটো-রান বাগ ফিক্স (X11 Driver Focus Settings)
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v UseTakeFocus /t REG_SZ /d 'N' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v GrabPointer /t REG_SZ /d 'Y' /f
```

---

### ৭. ব্লুটুথ ও পাইপওয়্যারে অডিও ল্যাটেন্সি ফিক্স (PipeWire Low Latency)
Wine দিয়ে গেম খেললে ব্লুটুথ হেডফোনে (A2DP/SBC/AAC কোডেক) সাধারণত ২০০-৩০০ মিলি-সেকেন্ড অডিও ল্যাগ তৈরি হয় অথবা ভলিউম হঠাৎ কম-বেশি হয়।

`play-farcry4.sh` স্ক্রিপ্টে নিচের এনভায়রনমেন্ট ভ্যারিয়েবলগুলো যোগ করে অডিও সম্পূর্ণ বাফারলেস ও ইনস্ট্যান্ট সিঙ্ক করা হয়েছে:
- `PULSE_LATENCY_MSEC=50`: পালসঅডিও ইমুলেশন বাফার কমিয়ে ৫০ মিলি-সেকেন্ডে নামিয়ে আনে।
- `PIPEWIRE_LATENCY="512/48000"`: পাইপওয়্যারের হার্ডওয়্যার বাফার সাইজ ৫১২ ফ্রেমে লক করে সাউন্ড ক্র্যাকল ও ডিলে বন্ধ করে।

---

## ⚡ Quick Start Guide (এক নজরে ফুল সেটআপ)

আপনি যদি সম্পূর্ণ কনফিগারেশন নতুন পিসিতে সেটআপ করতে চান:

```bash
# ১. রিপোজিটরি ক্লোন করুন
git clone https://github.com/rakibdipu/linux-gaming-guide.git
cd linux-gaming-guide

# ২. ডিপেন্ডেন্সি ইনস্টল করুন
sudo apt update && sudo apt install -y wine wine64 winetricks lutris gamemode python3-evdev

# ৩. Udev রুল বসান
sudo cp configs/99-game-input.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

# ৪. ওয়াইন রেজিস্ট্রি টুইক প্রয়োগ করুন
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /t REG_SZ /d 'native,builtin' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi /t REG_SZ /d 'native,builtin' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v UseTakeFocus /t REG_SZ /d 'N' /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v GrabPointer /t REG_SZ /d 'Y' /f

# ৫. স্ক্রিপ্ট রান করুন
chmod +x scripts/*.sh scripts/*.py
./scripts/play-farcry4.sh
```

---

## ❓ সাধারণ সমস্যা ও সমাধান (Troubleshooting & FAQ)

### প্র: গেম অন করার পর ব্ল্যাক স্ক্রিন এসে বন্ধ হয়ে যায় কেন?
> **উ:** `WINEDLLOVERRIDES` ঠিকমতো লোড না হলে এমন হয়। গেমের `bin/` ফোল্ডারে `d3d11.dll` এবং `dxgi.dll` ঠিকমতো কপি করা আছে কি না চেক করুন এবং `vulkaninfo` কমান্ড দিয়ে ভালকান ড্রাইভার ইনস্টল্ড আছে কি না নিশ্চিত করুন।

### প্র: কিবোর্ডে ক্যারেক্টার নিজে নিজে সামনে হাঁটতে থাকে (Key Stuck)?
> **উ:** এটি Wine এর X11 ফোকাস বাগ। রেজিস্ট্রি কি `UseTakeFocus=N` এবং `GrabPointer=Y` দিলে এই সমস্যা ১০০% সমাধান হয়ে যায় (সেকশন ৬ দেখুন)।

### প্র: `auto_heal.py` রান করার সময় `PermissionError: /dev/uinput` দেখায় কেন?
> **উ:** আপনার বর্তমান ইউজার uinput ডিভাইসে অ্যাক্সেস পাচ্ছে না। `/etc/udev/rules.d/99-game-input.rules` ফাইলটি তৈরি করে সিস্টেম একবার রিস্টার্ট দিন বা `sudo udevadm trigger` কমান্ড চালান।

---

## 📄 লাইসেন্স (License)

This documentation and accompanying scripts are licensed under the [MIT License](LICENSE). Feel free to adapt and share!

Happy Gaming on Linux! 🐧🎮
