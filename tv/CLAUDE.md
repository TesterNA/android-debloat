# Android TV / Google TV / TV box — procedure

Read `../CLAUDE.md` first (language, updating, phone-or-TV). Talk to the user only in their language;
this file is in English so any assistant can follow it. `lessons.md` and `devices/*/notes.md` are in
Ukrainian: read them anyway, they hold what was learned on real devices.

Base: **CleanYourTV** — https://github.com/Gathin23/cleanyourtv. Its clone sits **next to this repo**:
`<CYT>` = `../../cleanyourtv` from this folder (`scripts/update.*` clones/updates it and creates
`<CYT>/tools/venv` with `adb-shell`). Its `PROMPT.md` is the base procedure; this file adds to it and
WINS where they differ. CleanYourTV's undo records: `~/.cleanyourtv/`.
Alternatives, also kept up to date next to this repo: `../../tv-detox` (tiny launcher, package
classifier), `../../free-my-tv` (launcher, also LG webOS / Samsung Tizen).

Before working read: `../LOCAL.md` (if present: private details of this PC — IPs, owners; not in git),
`devices/README.md`, `lessons.md`, `SOURCES.md`, and for a known device its `devices/<name>/notes.md`.
The repo is public: IPs, Wi-Fi names, people and absolute paths go only into `../LOCAL.md`.

## Steps

1. **Fresh versions.** `../scripts/update.*` must have run this session (see `../CLAUDE.md`). Look at
   what changed in CleanYourTV (`git -C <CYT> log --oneline -20`, new `examples/`).
2. **Connect and identify.** `TV_HOST=<ip>`; `<CYT>/tools/tv.py --probe` (model, codename, Android,
   firmware). Tell the user when the "Allow debugging?" prompt will appear on the TV (tick "Always").
   Also: `getprop ro.board.platform`, `ro.config.low_ram`, `wm size`, `df -h /data`, RAM
   (`/proc/meminfo`), who owns HOME (`cmd package resolve-activity --brief -a
   android.intent.action.MAIN -c android.intent.category.HOME`), the remote (`getevent -i | grep name`:
   Bluetooth or IR), what opens at power-on (`logcat -b events -d | grep wm_set_resumed_activity`).
3. **Find a match.** Search `<CYT>/examples/*/debloat.txt` by model, board codename
   (`ro.product.device`), maker (Changhong/Homwee, TCL, MStar/MediaTek, Amlogic…) and firmware. Another
   brand on the same board fits too (ERGO = RCA AI PONT). Check `devices/` here and tv-detox's
   `candidates.sh` lists. Nothing found → research (below).
4. **Backup + baseline BEFORE any change** (see "Measuring"): save `pm list packages -f` to
   `~/.cleanyourtv/<device>-packages-all.txt`.
5. **Analyse.** What runs (`dumpsys meminfo`, `dumpsys procstats --hours 3`), what starts at boot
   (`logcat -d | grep "Start proc"`), which of it is telemetry / ads / ACR / promo / updaters / preloads.
   For every candidate: flags (`dumpsys package <p> | grep pkgFlags` — never PERSISTENT), whether other
   lists disable it, what breaks.
6. **Interview** (next section) — mandatory, item by item, in the user's language.
7. **Apply** in batches. Lists go to `devices/<device>/debloat*.txt` (header: model, firmware, what was
   kept and why, undo command), applied with `<CYT>/tools/disable.ps1 -TvHost <ip> <list>` (or
   `disable.sh`); it records the undo state. Every later round is a SEPARATE file (undo records are bound
   to the list's full path: never move or rename a list after applying it).
8. **Verify after a reboot**: same-uptime measurement, nothing re-enabled (`pm list packages -d`), HOME,
   HDMI inputs, **the user presses the real remote buttons** (Home, Settings, Input/Source, app buttons),
   screenshot of the home screen to the user.
9. **Report** in the user's language: before/after table, what was disabled / restricted / kept, how to
   undo, what is unverified. Update `devices/<device>/notes.md`, `devices/README.md`, `lessons.md`
   (generic, no private data). Remind the user to turn USB / network / wireless debugging off.

## Interview (ask every item; never offer only "minimal vs everything")

Ask after the analysis, one item at a time (or one checklist with a separate answer per line). For each:
your recommendation, why, and what the user loses. Do not bundle items.

1. **Launcher.**
   - (a) Keep the stock launcher, cleaned: promo/ads channels off, video/audio previews off,
     recommendations off (`tools/channels.ps1`, home-screen settings), or
   - (b) a custom launcher. You choose which, by device power, and explain:
     ≤ 1 GB RAM or `ro.config.low_ram=true` → the lightest that fits (tv-detox ~40 KB, or CleanYourTV with
     `reduced_motion`); 1.5–2 GB+ → CleanYourTV (measured 31–76 MB); free-my-tv only on ≥ 2 GB and only if
     the user wants its network widgets. Check the APK installs before planning around it (CYT `PROMPT.md`).
     Google TV: disabling `com.google.android.apps.tv.launcherx` has boot-looped some devices — do it
     only where a tested `examples/` list does, otherwise keep it (see `lessons.md`).
   - Custom launcher, optional sub-question: **what should open at power-on** — Home, Live TV or the last
     input? Check what opens now (step 2). Firmware that forces Live TV (Changhong/Homwee) → CleanYourTV
     key `power_on_home` with `HOME_KEY_SERVICE=1` (in CleanYourTV since PR #1445, 2026-10-25); user wants
     Live TV first → `boot_to_live_tv`. Never both.
2. **Remote control — core buttons must keep working: Home, Settings, Input/Source.** Not a yes/no question:
   tell the user they will be checked, and after changes ask them to press each. Stock launcher gone → fix
   with the launcher's key services (`HomeKeyService`: Home/Settings, `settings_key_keycodes`;
   `InputKeyService`: Input, `input_key_keycodes`). App buttons (Netflix, YouTube, Prime…) → after item 3.
3. **Preinstalled apps** (Netflix, Prime Video, YouTube, YouTube Music, Mi TV/PatchWall, Apple TV, vendor
   stores…): ask which ones are really used.
   - Not used → disable (`pm disable-user`), or, if the user wants to keep it installed, freeze it:
     `cmd appops set <p> RUN_ANY_IN_BACKGROUND ignore`, `cmd appops set <p> RUN_IN_BACKGROUND ignore`,
     `am force-stop <p>` (→ `stopped=true`, no start at boot until opened), `cmd deviceidle sys-whitelist
     -<p>`, its home-screen channels off. Check after a reboot that it did not start.
   - Used → keep it fully working, but no autostart "just in case": no background start at boot, channels
     only if wanted. Test that it opens and plays.
   - Then ask about the **app buttons** on the remote: keep, remap to another app (`app_keys`), or nothing.
4. **Telemetry, analytics, ad tracking, ACR, promo rows, silent installers** — removed without asking
   (respect every KEEP/DO-NOT-DISABLE note). List them in the report.
5. **Features — one separate question each**, never all on or all off: Chromecast (`mediashell`),
   Miracast / vendor casting, AirPlay receivers, voice search / mic button (`katniss`, assistant),
   phone-as-remote (`tv.remote.service`), firmware updates, Play Store auto-updates, screensaver /
   ambient (OLED: keep a screensaver), animations 0.5.
6. **Everything else** — follow CleanYourTV's matching `examples/` list, `lessons.md` and this file.

## Measuring (honest numbers)

- Main metric: `MemAvailable` (`/proc/meminfo`) + used swap (`SwapTotal-SwapFree`) + top PSS
  (`dumpsys meminfo`); launcher alone: `dumpsys meminfo <pkg> | grep TOTAL`.
- Compare only the **same uptime after boot** (`/proc/uptime`): "before" N minutes after a boot,
  "after" reboot and wait the same N. Script: `tools/measure.ps1`.
- Say clearly what is measured and what is estimated; if "before" was not fresh after a boot, say part
  of the gain is just the reboot. ~400 processes in `ps -A` are mostly kernel threads.

## Never

- Only `pm disable-user --user 0`. `pm uninstall --user 0` only for packages the firmware re-enables by
  itself (e.g. `com.cltv.fast`) and only with the user's OK; undo `cmd package install-existing <p>`.
  Uninstall the user's own apps only on request.
- Don't touch: Live TV / tuner (HDMI goes through it), input services, the remote and Bluetooth (BT
  remotes), the keyboard, Play Store / Play Services, factory / service / hotel menus, PERSISTENT
  packages, anything marked KEEP in the matching `examples/` header.
- `setupwraith` (setup wizard): first `dumpsys wifi | grep cname=`. If it owns the network the TV is on,
  do NOT disable it (the TV drops off Wi-Fi). Only an old/guest network → `FORCE_SETUPWRAITH=1`, after
  warning that network will be erased.
- User said "keep the launcher" → no custom launcher, stock launcher stays enabled.
- No commits or pushes without the user's explicit request.

## Research (new model, or to check for something better)

Delegate web search to a sub-agent while you work with the device. Look for: new/updated lists in
CleanYourTV (`examples/`, PRs, issues), tv-detox / free-my-tv rules for the brand, other debloat lists
(GitHub `<brand> android tv debloat`, the exact package name in quotes, XDA, 4pda, Reddit r/AndroidTV),
known firmware issues (Live TV autostart, packages re-enabling, ACR). UAD-ng descriptions:
`../phone/uad/uad_lists.json`. Confirmed findings → `lessons.md` / the device's `notes.md`; new sources →
`SOURCES.md`.

## Tools

- `tools/ui.ps1 -TvHost <ip> -Keys '...'` — press keys and read the screen AS TEXT (uiautomator); works
  where screenshots are empty (Live TV, protected windows) and for Settings / Play Store menus.
  `start:<pkg>/<activity>` opens a screen.
- `tools/channels.ps1` — switch off rows on the stock Android TV home screen (`-DryRun` first).
- `tools/measure.ps1 -TvHost <ip> -Uptime <s> [-Reboot]` — reboot, wait, measure.
- Screenshot: `screencap -p /sdcard/s.png` → `tv.py --pull` → read → `rm`.
- CleanYourTV launcher: themes instead of rebuilding, `power_on_home` (upstream) — see `lessons.md`.
  `patches/` only holds device config (Xiaomi MOOR2 dock). Before applying a patch, check upstream doesn't
  already have it, then `git -C <CYT> apply --check`.
