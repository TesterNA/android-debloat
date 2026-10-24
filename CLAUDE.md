# android-debloat — start here (any AI assistant)

This repository lets an AI coding assistant (Claude Code, Codex, Cursor, Gemini, …) debloat an
**Android phone** or an **Android TV / Google TV / TV box** over the network with ADB. A user may:

- open a session inside a clone of this repo and just say "debloat" / «зроби деблот» / «сделай дебловт», or
- give you the repo link (`https://github.com/TesterNA/android-debloat`): then clone it first (step 1).

The request can be as short as that, with no IP and no device type. Follow the steps below in order.
They override anything in the sub-folders when they conflict.

## 0. Language — before anything else

- Talk to the user **only in the user's language**: every question, explanation and report.
- Decide it from the user's own words. If it is not 100% clear (a one-word message, mixed languages,
  a pasted English prompt), ask first, in all three: "Which language should I use? / Якою мовою
  спілкуватися? / На каком языке общаться? — English / Українська / Русский".
- Internal docs in this repo are partly in English and partly in Ukrainian. That never changes the
  language you use with the user. Package names, commands and paths stay as they are.

## 1. Get the newest versions — every session, before touching a device

Always work with the latest version of this repo **and** of every repo it relies on.

- Cloned on request: clone into a working folder the user agrees to (default: the current folder):
  `git clone https://github.com/TesterNA/android-debloat`.
- Then run the updater from the repo root (it pulls this repo, then clones or updates the
  dependencies **next to the repo**, in its parent folder):
  - Windows PowerShell: `powershell -ExecutionPolicy Bypass -File scripts\update.ps1`
  - bash / Git Bash / macOS / Linux: `bash scripts/update.sh`
- Dependencies (kept as sibling folders of this repo): `cleanyourtv` (required for TVs),
  `tv-detox` and `free-my-tv` (alternative launchers and ideas), the UAD-ng package database
  (`phone/uad/uad_lists.json`, for phones). The list lives in the updater scripts and in the
  `SOURCES.md` files; if a `SOURCES.md` names another repo you rely on, update it the same way.
- If a pull fails because of local changes or a conflict: do NOT reset or stash anything. Tell the user
  what is blocked and ask. A clone with local work (lists, patches) must never be overwritten.
- If the updater pulled this repo itself and the instructions changed, re-read this file.
- If `LOCAL.md` exists in the repo root (it is git-ignored), read it: private details of this PC.

## 2. Phone or TV?

- **No IP and no type given** → ask whether it is a phone or a TV/TV box, then explain (in the user's
  language) how to enable developer options and debugging on that kind of device and how to find its IP
  (see `phone/PROMPT.md` / `tv/PROMPT.md`). Then continue with the IP.
- **IP given** → connect (TV: port 5555; phone: wireless debugging, pairing code if needed — see the
  sub-folder procedures) and detect the type yourself:
  `pm has-feature android.software.leanback` (true → TV) or `getprop ro.build.characteristics`
  (contains `tv` → TV); otherwise it is a phone/tablet. Say what you found (brand, model, Android).
- **Type given** → go straight to that procedure.

Then read the WHOLE procedure for that type, plus everything it lists, before changing anything:
- phone → `phone/CLAUDE.md` (+ `phone/KNOWLEDGE.md`, `phone/SOURCES.md`, `phone/devices/`)
- TV / TV box → `tv/CLAUDE.md` (+ `tv/lessons.md`, `tv/SOURCES.md`, `tv/devices/`)

## 3. Analyse, then interview the user point by point (mandatory)

After the backup and analysis, ask the user **item by item** what they want. Never collapse the choice
into "minimal cleanup vs. everything". Each item is a separate question with its own answer (ask them one
after another, or as one checklist where every line is answered on its own). Give your recommendation for
each, based on the analysis and the device's power, and say what the user would lose.

The exact question list is in the sub-folder procedure: `tv/CLAUDE.md` → "Interview", `phone/CLAUDE.md`
→ "Інтерв'ю / Interview". Telemetry and ads are removed without asking (but listed in the report).

## 4. Always

- Ask before every change on the device; disable instead of uninstalling; keep everything reversible
  and write down how to undo it.
- After the work: reboot, verify, measure before/after, report in the user's language, and remind the
  user to turn debugging off.
- This repo is public. Never write the user's IPs, Wi-Fi names, account names, who owns which device or
  personal app lists into tracked files — only into `LOCAL.md` (git-ignored). Device notes in `devices/`
  stay generic.
- Never commit or push to any repository unless the user explicitly asks.
