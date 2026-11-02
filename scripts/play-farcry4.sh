#!/bin/bash
cd /home/dipu/Games/Far-Cry-4/bin || exit 1

# Force Wine to use DXVK (Vulkan translation) instead of buggy WineD3D
export WINEDLLOVERRIDES="d3d11,dxgi,d3d10core,d3d9=n,b"
export WINEPREFIX="/home/dipu/.wine"

# Audio sync and low-latency fixes for Wine/PipeWire (Fixes voice delay & volume jumps)
export PULSE_LATENCY_MSEC=50
export PIPEWIRE_LATENCY="512/48000"

# Performance optimizations for AMD Radeon Graphics
export RADV_PERFTEST=gpl
export mesa_glthread=true

# Start 1-tap Auto Heal helper (Pressing H automatically executes full heal hold)
python3 /home/dipu/Games/Far-Cry-4/auto_heal.py &
HEAL_PID=$!

# Cleanup helper when game exits
cleanup() {
    kill "$HEAL_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

if command -v gamemoderun >/dev/null 2>&1; then
    gamemoderun /usr/bin/wine64 ./FarCry4.exe "$@"
else
    /usr/bin/wine64 ./FarCry4.exe "$@"
fi
