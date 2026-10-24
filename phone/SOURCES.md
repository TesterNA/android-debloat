# Джерела

Чужі списки — підказки. Кожен пакет все одно перевіряється на конкретному телефоні.

## Бази пакетів (універсальні)

- **UAD-ng** — https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation
  `resources/assets/uad_lists.json`: ~5400 пакетів з описами і рівнями Recommended/Advanced/Expert/Unsafe,
  списки AOSP, Google, Carrier, Misc, OEM (Xiaomi, Samsung, Oppo/Realme/OnePlus, Huawei, Motorola,
  Nokia, Sony, Tecno, Asus...). Локальна копія: `uad/uad_lists.json`, оновлення `scripts/update-uad.sh`.
  Попередження з README: вийти з облікового запису виробника перед видаленням його пакетів.
- **cleanyourtv** — https://github.com/Gathin23/cleanyourtv — для Android TV, але найкраща методика:
  формат списку з DO NOT DISABLE, запобіжники (HOME, HDMI-входи, Wi-Fi від setup wizard), бекап до
  змін, порції з перевіркою, PROMPT.md для асистента. ~150 моделей ТВ у `examples/`.

## Xiaomi / Redmi / POCO (MIUI, HyperOS)

- https://github.com/BloodBlinker/hyperos-debloat — 168 пакетів, аналітика, MSA, хмара
- https://github.com/ovsky/hyperos-debloater — рівні safe / telemetry, зворотний
- https://github.com/barteqcz/MIUI-debloater — мінімальний безпечний набір
- XiaomiADBFastbootTools — https://github.com/Szaki/XiaomiADBFastbootTools (оригінал),
  https://github.com/abdullahnaseem/XiaomiADBFastbootTools-DLG (форк з онлайн-списком)

## Samsung (One UI)

- https://github.com/Willie169/Samsung-Android-Debloat-List — One UI 8, Android 16, з поясненнями
- https://github.com/khlam/debloat-samsung-android — агресивніший, Knox і Play не ламає

## Кілька брендів

- https://github.com/farag2/adb-debloating — PowerShell: MIUI/HyperOS, One UI, Pixel

## Ще не знайдено / шукати при нагоді

- Tecno / Infinix / itel (Transsion, HiOS/XOS): окремого якісного списку не знайдено, є розділ Tecno
  в UAD. Шукати: `transsion debloat`, `hios xos adb debloat`.
- Oppo / Realme (ColorOS / Realme UI), Vivo (Funtouch / OriginOS), Honor (MagicOS): перевірити
  свіжі репо при першому такому телефоні.
