# Джерела

Чужі списки — підказки. Кожен пакет все одно перевіряється на конкретному пристрої
(`dumpsys package`, прапорці PERSISTENT, що зламається).

## Основа
- **CleanYourTV** — https://github.com/Gathin23/cleanyourtv (локально `..\cleanyourtv`).
  `examples/<модель>/debloat.txt` з шапками KEEP/quirks для ~160 моделей, `PROMPT.md`,
  `docs/TROUBLESHOOTING.md`, `tools/` (ADB через adb-shell, disable/restore з записом стану),
  `launcher/` (легкий нативний лаунчер, теми без перезбирання). Перед роботою — `git pull`, глянути
  нові `examples/`, PR та issues.

## Інші деблот-проєкти (звіряти, брати ідеї)
- **tv-detox** — https://github.com/Ansub/tv-detox (MIT). Промпт для Claude Code/Codex, крихітний
  лаунчер (40 КБ), `candidates.sh` (класифікація never/keep/safe/review зі списками пакетів),
  `check.sh --fix` (повернути вимкнене після оновлень), `undo.sh`, `docs/debloat.md` (правила).
  Застереження щодо `launcherx` на Google TV.
- **free-my-tv** — https://github.com/simbasjungles/free-my-tv. Головний екран для Google TV, а також
  **LG webOS і Samsung Tizen**; відкат однією кнопкою на ТВ, Watchdog, захищений список пакетів,
  бренд-правила (TCL, Philco, Multilaser, KTC, Sony, Vestel). Важкий (мережеві віджети), Android APK
  треба збирати. Перший кандидат, якщо трапиться LG чи Samsung.

## Бази пакетів
- **Universal Android Debloater (UAD-ng)** — опис і рівні безпеки пакетів; база вже є в
  `..\phone\uad\uad_lists.json` (оновлення — `..\phone\scripts\update-uad.sh`).
  Для ТВ-специфічних пакетів (Homwee, MediaTek tvcenter, PatchWall) покриття слабке.

## Лаунчери (для порівнянь)
- FLauncher (Flutter, розробка зупинилась 2023) — https://github.com/svrooij/flauncher
- LtvLauncher (живий форк FLauncher, Flutter, ~10 МБ APK) — https://github.com/leanbitlab-org/LtvLauncher
- Точної опенсорсної копії стокового Android TV лаунчера не існує (він закритий, Google).

## Де шукати про нову модель / незнайомий пакет
- Точна назва пакета в лапках у пошуку; GitHub code search.
- XDA Developers, 4pda, Reddit r/AndroidTV, r/googletv, AVS Forum.
- Для Changhong/Homwee/MediaTek: інші бренди на тій самій платі (RCA, realme, CHiQ, Aiwa, BenQ,
  Haier, Hitachi, ERGO) — шукай за `ro.product.device` і версією прошивки.

## Що вже перевіряли і не знайшли
- Спосіб прибрати автостарт Live TV на Changhong/Homwee без root (2026-10) — не знайшли; зробили свій:
  `power_on_home`, https://github.com/Gathin23/cleanyourtv/pull/1445. Нотатки ERGO/MOOR2 для upstream —
  https://github.com/Gathin23/cleanyourtv/pull/1446.
