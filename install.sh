#!/bin/bash
# =============================================================
#  Linux Gaming Setup — Auto-Installer
#  Installs all required configs, udev rules, and desktop entry
#  for Far Cry 4 on Ubuntu/Debian-based Linux systems.
#
#  Usage: bash install.sh
# =============================================================

set -e

GAME_DIR="$HOME/Games/Far-Cry-4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Far Cry 4 Linux Setup — Auto Installer ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Install system packages ──────────────────────────
echo "[1/5] Installing system dependencies..."
sudo apt update -qq
sudo apt install -y wine wine64 winetricks lutris gamemode python3-evdev vulkan-tools mesa-vulkan-drivers
echo "      ✓ Packages installed."

# ── Step 2: Install udev permission rule ─────────────────────
echo "[2/5] Installing udev rules (non-root keyboard input)..."
sudo cp "$SCRIPT_DIR/configs/99-game-input.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
echo "      ✓ Udev rules installed."

# ── Step 3: Apply Wine registry tweaks ───────────────────────
echo "[3/5] Applying Wine registry tweaks (DXVK + key-stuck fix)..."
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /t REG_SZ /d 'native,builtin' /f 2>/dev/null
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi   /t REG_SZ /d 'native,builtin' /f 2>/dev/null
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver'   /v UseTakeFocus /t REG_SZ /d 'N' /f 2>/dev/null
wine reg add 'HKEY_CURRENT_USER\Software\Wine\X11 Driver'   /v GrabPointer  /t REG_SZ /d 'Y' /f 2>/dev/null
echo "      ✓ Wine registry updated."

# ── Step 4: Copy scripts to game directory ───────────────────
echo "[4/5] Copying launcher scripts to $GAME_DIR ..."
if [ ! -d "$GAME_DIR" ]; then
    echo "      [WARN] Game folder not found: $GAME_DIR"
    echo "             Please install Far Cry 4 there first, then re-run this script."
else
    cp "$SCRIPT_DIR/scripts/play-farcry4.sh" "$GAME_DIR/"
    cp "$SCRIPT_DIR/scripts/auto_heal.py"    "$GAME_DIR/"
    chmod +x "$GAME_DIR/play-farcry4.sh" "$GAME_DIR/auto_heal.py"
    echo "      ✓ Scripts installed."
fi

# ── Step 5: Install desktop entry ────────────────────────────
echo "[5/5] Installing desktop shortcut..."
DESKTOP_FILE="$HOME/.local/share/applications/FarCry4.desktop"
mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Far Cry 4
Comment=Play Far Cry 4 on Ubuntu Linux via Wine + DXVK
Exec=$GAME_DIR/play-farcry4.sh
Path=$GAME_DIR/bin
Icon=$GAME_DIR/bin/farcry4.png
Terminal=false
Categories=Game;
StartupNotify=true
EOF

# Also place on Desktop if it exists
if [ -d "$HOME/Desktop" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/FarCry4.desktop"
    chmod +x "$HOME/Desktop/FarCry4.desktop"
    gio set "$HOME/Desktop/FarCry4.desktop" metadata::trusted true 2>/dev/null || true
fi

echo "      ✓ Desktop shortcut created."
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         ✅ Setup Complete!               ║"
echo "║                                          ║"
echo "║  Next: Download & install DXVK DLLs:    ║"
echo "║  See README.md → Prerequisites → Step 2  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
