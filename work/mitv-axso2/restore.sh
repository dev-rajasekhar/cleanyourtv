#!/usr/bin/env bash
# Put this Mi TV (MiTV-AXSO2) back the way it was before the cleanup on 2026-10-27:
#   - re-enables every package work/mitv-axso2/debloat.txt disabled (from the recovery record that
#     tools/disable.sh wrote in ~/.cleanyourtv/ before the first change) and the stock launcher,
#   - gives Home back to com.google.android.tvlauncher,
#   - switches the launcher's Home-key helper off and Private DNS back to Android's default,
#   - turns "Stay on the previous source" back on (set_auto_play 1, as the TV shipped).
# The new launcher stays installed but is no longer Home; REMOVE_LAUNCHER=1 uninstalls it too.
#
# Usage, from anywhere:   work/mitv-axso2/restore.sh
#                         TV_HOST=<other ip> work/mitv-axso2/restore.sh
# Needs network ADB on the TV (Developer options > USB debugging) and tools/venv (see README.md).
set -euo pipefail
cd "$(dirname "$0")/../.."
export TV_HOST="${TV_HOST:-192.168.1.15}"
tv() { tools/venv/bin/python -I tools/tv.py "$@"; }

# Accessibility helpers first: with the launcher no longer Home they would keep filtering keys.
tv 's=$(settings get secure enabled_accessibility_services); case "$s" in *com.gathin.tvhome*) n=$(echo "$s" | tr ":" "\n" | grep -v com.gathin.tvhome | paste -sd: -); if [ -z "$n" ]; then settings put secure enabled_accessibility_services ""; settings put secure accessibility_enabled 0; else settings put secure enabled_accessibility_services "$n"; fi; echo "key helpers off";; *) echo "no key helpers were on";; esac'

tools/restore.sh work/mitv-axso2/debloat.txt com.google.android.tvlauncher

# Private DNS: the TV had no value set before (Android's default, "opportunistic").
tv 'settings put global private_dns_mode opportunistic'
tv 'settings delete global private_dns_specifier'

# Settings > "Stay on the previous source": on when the TV came (power-on reopened Live TV / the last input).
tv 'settings put global set_auto_play 1'

if [ "${REMOVE_LAUNCHER:-0}" = 1 ]; then
  tv 'pm uninstall com.gathin.tvhome'
fi

tv 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -n 1'
echo "Done. Press Home on the remote; reboot the TV once if anything looks stale."
