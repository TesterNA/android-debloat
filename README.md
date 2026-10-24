# android-debloat

Let an AI coding assistant (Claude Code, Codex, Cursor, Gemini, …) clean up an **Android phone** or an
**Android TV / Google TV / TV box** over your network: ads, telemetry, sponsored rows, silent installers and
background junk go; your apps, remote buttons and inputs keep working. Everything is reversible.
Works from Windows, macOS and Linux.

> 🇺🇦 Інструкції для агента англійською, але він спілкуватиметься з вами вашою мовою.
> 🇷🇺 Инструкции для агента на английском, но общаться с вами он будет на вашем языке.

## Quick start

1. **On the device**: turn on developer options and debugging (the agent will walk you through it if
   needed). Phone and computer must be on the same Wi-Fi.
2. **Either** clone this repo and open your assistant inside it:
   ```bash
   git clone https://github.com/TesterNA/android-debloat
   cd android-debloat
   ```
   **or** just give your assistant the link: *"Use https://github.com/TesterNA/android-debloat"*.
3. Say, in any language: **"debloat"** / **«зроби деблот»** / **«сделай дебловт»**. Optionally add the
   device's IP and whether it's a phone or a TV — otherwise the agent asks or detects it.

The agent then (see [`CLAUDE.md`](CLAUDE.md)):
- asks which language to use if that isn't obvious;
- updates this repo and every repo it builds on to the newest version;
- connects, detects phone vs TV, backs up and measures memory;
- **asks you point by point**: launcher, remote buttons, which preinstalled apps you really use,
  Chromecast / casting / voice search / updates one by one — telemetry and ads go without asking;
- applies changes in small reversible batches, reboots, verifies and shows before/after numbers.

## What's inside

| Folder | For | Procedure |
|---|---|---|
| [`phone/`](phone/) | Phones (Xiaomi/MIUI, Pixel, …), UAD-ng based analysis | [phone/CLAUDE.md](phone/CLAUDE.md) |
| [`tv/`](tv/) | Android TV / Google TV / boxes, built on [CleanYourTV](https://github.com/Gathin23/cleanyourtv) | [tv/CLAUDE.md](tv/CLAUDE.md) |
| [`scripts/`](scripts/) | `update.ps1` / `update.sh`: update this repo + dependencies | |

`AGENTS.md` next to every `CLAUDE.md` points non-Claude assistants to the same instructions.
`devices/` folders hold real examples (generic notes, no private data): drafts for similar models only —
every package is checked on your own device.

## Requirements
- `git`; Python 3 (TV tools); PowerShell (Windows built-in, or PowerShell 7 `pwsh` on macOS/Linux) for
  `tv/tools/*.ps1`; bash (Git Bash on Windows) for `phone/scripts/*.sh`.
- adb for phones: Google's platform-tools (the agent can download it into `phone/platform-tools/`).
- Dependencies are cloned **next to this repo** by `scripts/update.*`: `cleanyourtv`, `tv-detox`,
  `free-my-tv`, plus the UAD-ng database into `phone/uad/`.

## Not in git (`.gitignore`)
- `LOCAL.md` — your private details (paths, device IPs, owners). Agents read it if present.
- Raw phone backups and action logs (IMEI, serial numbers, e-mails), `platform-tools`, the UAD database,
  adb keys, APKs. CleanYourTV's undo records live in `~/.cleanyourtv/`.

**Use at your own risk**: system apps get disabled. The agent asks before every change and keeps an undo
list, but some TVs have been known to boot-loop after the wrong package was turned off.
