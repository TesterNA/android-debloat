# Xiaomi MiTV-MOOR2 (venom), Google TV / Android 11

- Прошивка RTM5.220609.003.1917 (у списку репо — .2674). MediaTek. 1,8 ГБ RAM.
- Стоковий лаунчер: `com.google.android.apps.tv.launcherx`. Live TV / HDMI-перемикач: `com.mitv.livetv` (НЕ чіпати).
- Пульт: Bluetooth (`com.mi.bluetooth`).
- Дата: 2026-10-20.

## Що зроблено
1. `debloat.txt` (18 пакетів, база — `examples/xiaomi-mitv-moor2`, без відсутніх manualhelp/milinkservice/ZEE5):
   телеметрія Xiaomi, рекламні ряди, PatchWall, промо, демо, TV Manager, Mi Music, Play Games, Miracast.
2. `setupwraith.txt` — майстер налаштування (на цій прошивці займає HOME). Основна Wi‑Fi
   належала системі; гостьова мережа належала майстру і могла зникнути. Застосовано з FORCE_SETUPWRAITH=1.
3. Лаунчер CleanYourTV (док: Netflix, YouTube + автозаповнення), стоковий launcherx вимкнено.
4. `debloat-2.txt` (14): Prime Video, Google TV/Play Фільми, YouTube Music, TalkBack, друк, Feedback,
   календар-синхр.; оновлення прошивки Xiaomi (3 служби), плеєр/галерея/медіапровідник Xiaomi, CI-модуль.
5. Apple TV видалено повністю (`pm uninstall`, користувацький застосунок). Анімації 0.5.
6. 2026-10-24: кнопка Settings на пульті нічого не робила (її обробляв вимкнений launcherx). Увімкнено
   службу доступності лаунчера без перезбирання:
   `settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService; settings put secure accessibility_enabled 1`.
   Після перевстановлення лаунчера — повторити. Відкат: `settings delete secure enabled_accessibility_services`.

## Результат
MemAvailable ≈625 МБ (довгий аптайм) → ≈994 МБ після ребута; swap 337 → 104 МБ.
Частина приросту — ефект свіжого старту (чесного «до» після ребута не було).

## Залишено свідомо
Голосовий пошук (katniss), Chromecast (mediashell), пульт з телефона, Netflix, YouTube, Play Store.

## Списки (для відкату — використовуй ОРИГІНАЛЬНІ шляхи)
Оригінали лежать у локальній копії CleanYourTV (`<CYT>`): `my-tv-debloat.txt`, `my-tv-setupwraith.txt`,
`my-tv-debloat-2.txt` (точні шляхи — у `LOCAL.md`).
Копії тут — лише для довідки. Відкат: `restore.ps1 -TvHost <IP> <оригінал> -Stock com.google.android.apps.tv.launcherx`.

## Не зроблено / можливо далі
- Автооновлення Play Store на цьому ТВ НЕ вимикались.
- Голос/Chromecast/пульт з телефона — можна вимкнути, якщо попросить.
- Налагодження USB, ймовірно, ще ввімкнене.
