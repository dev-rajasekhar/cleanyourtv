# Living-room Mi TV (MiTV-AXSO2): what was changed and how to change it back

Xiaomi MiTV-AXSO2 (`dangalUHD`), Android TV 9, firmware PI.6432. Cleaned up on 27 October 2026.
Everything here is reversible: apps were **disabled**, never uninstalled.

## What is different now

- **28 preinstalled apps are disabled.** The list, grouped and commented, is [`debloat.txt`](debloat.txt):
  Xiaomi and Google telemetry, PatchWall and its content rows, the partner auto-installers, the TV Manager
  cleaner, Mi Cast discovery, Mi Music, Mi Gallery, Play Movies, Play Games, YouTube Music, Hungama Play,
  the File Manager, Camera, Gallery, the print spooler, TalkBack and the basic screensaver.
- **Kept:** every streaming app you use, Google Assistant, Chromecast, Miracast, the firmware updater,
  Play Store, the keyboard, Bluetooth, and everything behind HDMI, AV and the tuner.
- **New Home screen:** the launcher in `launcher/`, with JioHotstar, YouTube, Apple TV and Sony LIV
  in the dock. The stock Google TV home (`com.google.android.tvlauncher`) is disabled.
- **Power-on goes to Home.** The TV's own setting *Stay on the previous source* is off
  (`settings global set_auto_play 0`). Before, the TV reopened Live TV or the last HDMI input.
- **Ad-blocking DNS:** Private DNS is `dns.adguard-dns.com`. It blocks many ad and tracking domains but
  **not YouTube ads**.
- **Network debugging is closed again** (see the last section).

## Before running any script

The scripts talk to the TV over the network, so debugging has to be on while you use them:

1. On the TV: Settings → Device Preferences → Developer options → **USB debugging** on.
2. Check the TV's address: Settings → Network & Internet → your Wi-Fi network. These scripts assume
   `192.168.1.15`; if the router gave it another one, put `TV_HOST=<new ip>` in front of the command.
3. Run the scripts from the repo folder (`~/arena/cleanyourtv`). The first time, the TV asks
   **"Allow USB debugging?"**: tick *Always allow* and press OK.
4. When you are done, switch USB debugging off again (port 5555 is unencrypted).

## Re-enable one app

On the TV, without a computer: Settings → Apps → See all apps → *Show system apps* → pick the app →
**Enable**.

From the computer, with debugging on:

```sh
TV_HOST=192.168.1.15 tools/tv.py 'pm enable com.google.android.youtube.tvmusic'
```

Then put a `#` in front of that line in `debloat.txt`, so a later re-apply leaves it alone. To find a
package name, look in `debloat.txt` (each one has a comment) or run `tools/tv.py 'pm list packages -d'`.

## Undo everything

```sh
work/mitv-axso2/restore.sh                    # re-enables all 28, gives Home back to the stock launcher,
                                              # resets Private DNS and "Stay on the previous source"
REMOVE_LAUNCHER=1 work/mitv-axso2/restore.sh  # the same, and uninstalls the new launcher
```

It replays the state recorded before the first change (`~/.cleanyourtv/recovery-192.168.1.15-*.json`).
**Keep that file.** The raw backup from before any change is in `backup/2026-10-27-mitv-axso2/`
(package lists, `getprop`, every setting).

Only the DNS by hand: `tools/tv.py 'settings put global private_dns_mode opportunistic'`, or on the TV:
Settings → Network & Internet → Private DNS → Automatic.

## Change the dock (apps, order, number of slots)

Edit `launcher/app/src/main/res/values/config.xml`:

```xml
<string-array name="dock_apps">
    <item>in.startv.hotstar</item>                  <!-- JioHotstar -->
    <item>com.google.android.youtube.tv</item>      <!-- YouTube -->
    <item>com.apple.atve.androidtv.appletv</item>   <!-- Apple TV -->
    <item>com.sonyliv</item>                        <!-- Sony LIV -->
</string-array>
...
<integer name="columns">4</integer>                 <!-- dock slots and grid columns: 4 to 7 -->
```

Other package names: Netflix `com.netflix.ninja`, Prime Video `com.amazon.amazonvideo.livingroom`,
ZEE5 `com.graymatrix.did`, Sun NXT `com.suntv.sunnxt`, FanCode `com.fancode.tv`, OTTplay
`com.htlabs.ottplay`. Then rebuild and install (about two minutes):

```sh
work/mitv-axso2/build-and-install.sh
```

To change it without a rebuild, put the same keys in a theme instead (next section):
`{"dock_apps": ["com.netflix.ninja", "com.google.android.youtube.tv"], "columns": 5}`.

## Change the wallpaper

The Home screen is plain black with a glow taken from the focused app. To use a picture, make a folder
with a `config.json` and your picture as `wallpaper.jpg` (1920×1080, a dark picture keeps the text
readable):

```sh
mkdir -p work/mitv-axso2/my-theme
echo '{"wallpaper_dim": 30}' > work/mitv-axso2/my-theme/config.json   # 0-90: how much to darken it
cp ~/Pictures/something.jpg work/mitv-axso2/my-theme/wallpaper.jpg
TV_HOST=192.168.1.15 tools/theme.sh work/mitv-axso2/my-theme
```

Back to plain black: `TV_HOST=192.168.1.15 tools/theme.sh --reset`. Ready-made themes are in
`themes/`, e.g. `tools/theme.sh themes/aurora`. All keys are listed in `themes/README.md`.

## Good to know

- **Remote:** Home, Back, the mic (Google Assistant), Netflix and Prime Video all work. The **PatchWall**
  button does nothing now, because PatchWall is disabled.
- **Volume:** holding Volume Up ramps the soundbar normally. Don't install the launcher with
  `HOME_KEY_SERVICE=1`: on this TV that helper turns a held volume key into a single step.
- **Inputs:** the *Inputs* pill (top right) lists HDMI 1–3, AV and Live TV. Holding OK on *Settings*
  opens the launcher's own settings.
- **Google sign-in:** the stock home and `com.google.android.tvrecommendations` showed Google's
  notifications. If Play Store ever says *"Authentication is required"*, enable both, open
  `com.google.android.tvlauncher/.notifications.NotificationsSidePanelActivity`, sign in, then run
  `work/mitv-axso2/build-and-install.sh` and re-apply the list
  (`TV_HOST=192.168.1.15 TVINPUT_ALLOW=1 tools/disable.sh work/mitv-axso2/debloat.txt`).
- **Storage is tight** (about 700 MB free of 4.4 GB). If Play installs fail with error 1008:
  `tools/tv.py 'pm trim-caches 64G'`.
- **Miracast** was kept but not yet tested after the cleanup. If mirroring fails, run
  `tools/tv.py 'pm enable com.mitv.milinkservice'` and try again.
- **After a big firmware update**, run `tools/venv/bin/python -I tools/check.py work/mitv-axso2/debloat.txt`.
  It reports apps the update switched back on, and `--fix` disables them again.

## Files here

| File | What it is |
|---|---|
| `debloat.txt` | The list of disabled apps, with notes from this TV |
| `restore.sh` | Undo everything (see above) |
| `build-and-install.sh` | Rebuild the launcher from `config.xml` and install it as Home |
| `focus.sh` | Test helper: press one key and print what has focus |
| `disabled-*.txt`, `*.log` | Snapshots and logs from the session |
