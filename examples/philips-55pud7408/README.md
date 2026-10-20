# Philips 55PUD7408/77

Google TV 14 on a TPV-built Philips (MediaTek m7332, 1.9 GB RAM). Debloated and given the Clean Your
TV launcher on 2026-10-20. The disabled packages are listed in [`debloat.txt`](debloat.txt), with the
reason for each one. Nothing was uninstalled.

All commands run from the repo root. They need ADB switched on (see "Turning ADB back on" below) and the
Python tools set up once:

```sh
python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt
export TV_HOST=192.168.1.84
```

## What changed

| | |
|---|---|
| Disabled | TP Vision analytics (`candeebug`, `gel`), Android ad services, MediaTek partner row injector, retail demo, European operator portals, Health Connect, Prime Video, Google TV app, Projectivy, setup wizard, stock launcher |
| Kept | Assistant, Chromecast, firmware updates, ambient screensaver, Netflix, YouTube, YouTube Music, every app you installed, all TV/HDMI/remote services |
| Home | `com.gathin.tvhome`; dock: Spotify, YouTube, Netflix, Stremio; greeting "Fresa" |
| Remote | Settings button (scancode 357) mapped through the launcher's `HomeKeyService` accessibility helper |
| DNS | Private DNS `dns.adguard-dns.com` (blocks ad and tracker domains; does **not** block YouTube ads) |
| Location | Turned on, so the Wi-Fi pill can show the network name |

## Undo everything

```sh
examples/philips-55pud7408/restore.sh
```

This re-enables every package in the list from the record saved before the first change
(`~/.cleanyourtv/recovery-192.168.1.84-*.json`; keep that file). It also gives Home back to the stock
Google TV launcher and resets Private DNS and Location.

## Re-enable one app

```sh
tools/venv/bin/python -I tools/tv.py 'pm enable com.amazon.amazonvideo.livingroom'   # e.g. Prime Video
```

Package names and what they do are in `debloat.txt`. To disable it again: `pm disable-user --user 0 <package>`.
Don't re-enable `com.google.android.tungsten.setupwraith` or `com.google.android.apps.tv.launcherx`
on their own: they take Home back. Use `restore.sh` for that.

## Turn the ad-blocking DNS off

```sh
tools/venv/bin/python -I tools/tv.py 'settings put global private_dns_mode opportunistic'
```

You can also do it on the TV: Settings > Network & Internet > Private DNS > Automatic. If an app stops
loading, try this first.

## Change the dock order, hidden apps or greeting

Edit `launcher/app/src/main/res/values/config.xml`:

- `dock_apps`: the four dock apps, left to right, by package name (`tools/tv.py 'pm list packages'`)
- `hidden_apps`: tiles never shown (Live TV and the Philips Help manual are hidden now)
- `greeting_name`: the name after GOOD EVENING

Then rebuild and install:

```sh
examples/philips-55pud7408/build-and-install.sh
```

Always use this script rather than `launcher/build-and-install.sh` directly. It passes
`HOME_KEY_SERVICE=1`, without which the remote's Settings button stops working again: Android turns
accessibility services off on every reinstall.

You can also reorder tiles on the TV: long-press the Settings pill, then Reorder.

## Change the wallpaper

Make a theme folder with a `config.json` and a dark 1920×1080 `wallpaper.jpg`:

```sh
mkdir -p themes/mine && cp ~/Pictures/my-wallpaper.jpg themes/mine/wallpaper.jpg
echo '{ "wallpaper": true, "wallpaper_dim": 30 }' > themes/mine/config.json
tools/theme.sh themes/mine          # tools/theme.sh --reset goes back to plain black
```

`themes/README.md` lists every key: wallpaper rotation, sky backdrop, columns and more. On the TV,
Launcher settings also has a Wallpaper row.

## Turning ADB back on

ADB was switched off when setup finished. To change anything above, switch it back on first:
Settings > System > Developer options > USB debugging (and Network debugging), then accept the
"Allow USB debugging?" prompt on the TV. When you're done, switch both off again. Port 5555 is
unencrypted.
