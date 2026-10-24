# android-debloat

Набір для деблоту Android-пристроїв по мережі через ADB з Claude Code (або іншим AI-асистентом —
див. `AGENTS.md`). Усе зворотне: пакети вимикаються, а не видаляються, кожен крок має відкат.

| Папка | Для чого | Старт |
|---|---|---|
| [`phone/`](phone/) | Телефони (Xiaomi/MIUI, Pixel, …): реклама, телеметрія, тихі встановлювачі, RAM і батарея | [phone/PROMPT.md](phone/PROMPT.md) |
| [`tv/`](tv/) | Android TV / Google TV телевізори й приставки, на основі [CleanYourTV](https://github.com/Gathin23/cleanyourtv) | [tv/PROMPT.md](tv/PROMPT.md) |

Як почати: відкрий сесію Claude Code **у потрібній підпапці** (`phone` або `tv`) — тоді її
`CLAUDE.md` з процедурою підхопиться автоматично — і встав текст із її `PROMPT.md`.

`devices/` у кожній папці — реальні приклади з наших пристроїв: використовуй як чернетку для
схожої моделі, але кожен пакет перевіряй на своєму пристрої.

## Підготовка
- `phone/`: adb від Google — https://dl.google.com/android/repository/platform-tools-latest-windows.zip,
  розпакувати в `phone/` (вийде `phone/platform-tools/`). База UAD-ng: `bash phone/scripts/update-uad.sh`.
- `tv/`: склонуй CleanYourTV **поруч із цим репозиторієм** (в ту саму батьківську папку):
  `git clone https://github.com/Gathin23/cleanyourtv`, створи в ньому venv з `tools/requirements.txt`
  і за потреби накладай патчі з `tv/patches/` (`git apply`). Скрипти в `tv/tools/` шукають його там.

## Що не потрапляє в git (див. `.gitignore`)
- `LOCAL.md` — приватні деталі конкретного ПК (абсолютні шляхи, IP пристроїв, власники). Агенти
  читають його, якщо він є. Хочеш так само — створи свій.
- Сирі бекапи телефонів і журнали дій (`phone/devices/*/backup-*`, `applied.log`): там IMEI, серійні
  номери, пошти.
- `phone/platform-tools/`, база UAD, ключі adb, APK.
- Записи для відкату CleanYourTV лежать у `~/.cleanyourtv/` (поза репозиторієм).
