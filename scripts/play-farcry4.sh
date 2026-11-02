#!/bin/bash
# =============================================================
#  Far Cry 4 - Linux Launcher Script
#  Handles: DXVK (Vulkan), PipeWire audio sync,
#           AMD Radeon optimizations, 1-tap auto-heal macro
#
#  Usage: ./play-farcry4.sh
#  Works on any Linux user — no hardcoded paths.
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
