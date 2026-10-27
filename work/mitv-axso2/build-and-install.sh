#!/usr/bin/env bash
# Build the launcher from launcher/ (with this TV's settings in launcher/app/src/main/res/values/config.xml)
# and install it on the Mi TV as Home. Safe to run again after changing config.xml: it replaces the app,
# keeps it as Home, and only disables the stock launcher if that is still Home.
#
# Usage:   work/mitv-axso2/build-and-install.sh
#          TV_HOST=<other ip> work/mitv-axso2/build-and-install.sh
# Needs USB debugging on (README.md, "Before running any script"), JDK 17 and the Android SDK (already here).
#
# No key helper on purpose: on this TV a bound HomeKeyService costs the volume ramp (holding Volume Up
# moved one step instead of 16 repeats), and power-on reaches Home without it now that
# "Stay on the previous source" is off. Do not add HOME_KEY_SERVICE=1 unless you accept that trade.
set -euo pipefail
cd "$(dirname "$0")/../.."
export TV_HOST="${TV_HOST:-192.168.1.15}"
launcher/build-and-install.sh
