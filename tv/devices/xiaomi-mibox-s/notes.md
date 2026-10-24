# Xiaomi Mi Box S (MIBOX4, oneday, Amlogic gxl), Android TV 9

**ЛАУНЧЕР НЕ МІНЯТИ** (вимога власника). Стоковий: `com.google.android.tvlauncher`.

- Прошивка PI.3933 (остання, 2021). 2 ГБ RAM, 1080p, /data 4,9 ГБ (зайнято 73%).
- Поки ввімкнено налагодження USB — USB-порт без живлення.
- Netflix і Prime Video були вимкнені ще до нас.
- Встановлені власником застосунки (стрімінги, ігри, AirPlay-приймач, файловий менеджер, браузер) не
  чіпали; точний список — у `LOCAL.md`.
- Дата: 2026-10-21.

## Що зроблено
1. `debloat.txt` (20), база `examples/xiaomi-mi-box-s` без лаунчера/Ambient/голосу/Chromecast/пульта з телефона:
   аналітика Xiaomi, Alphonso, Feedback/звіти, PatchWall, Mi Channel, промо, рекомендації, автовстановлення,
   оновлення Xiaomi + завантажувач, Mi Cast + плеєр, Live Channels, Play Фільми, YouTube Music, Play Ігри,
   камера, TalkBack, друк. Анімації 0.5.
2. Автооновлення Play Store вимкнено.
3. Налаштування головного екрана: превʼю відео/аудіо вимкнено; канали вимкнено: «Основні сервіси Android TV»
   (реклама Google Play), Netflix, Prime Video, Mi Channel, PatchWall, Alphonso, BrowseHere, AirConsole.
   Залишено: «Вибране» і канали стрімінгових застосунків, якими власник користується (за його вибором).

## Результат
MemAvailable ≈900 МБ → ≈1100 МБ (обидва заміри ~6,6–7 хв після ребута). Стоковий лаунчер 116 МБ → 92–106 МБ.

## Залишено свідомо
Голосовий пошук (katniss + speech.pumpkin + tts), Chromecast, пульт з телефона, Ambient-заставка,
сполучення пульта (partnercustomizer, setupwraith), mitv.service, com.droidlogic*.

## Списки (для відкату — ОРИГІНАЛЬНИЙ шлях)
- `<CYT>\mibox-debloat.txt` (локальна копія CleanYourTV, шлях у `LOCAL.md`) → `restore.ps1 -TvHost <IP> <він>`
  (стоковий лаунчер не вимикався, -Stock не потрібен).
