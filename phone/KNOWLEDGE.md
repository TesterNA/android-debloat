# Що дізналися на практиці

Дописуй сюди після кожного телефону: модель, симптом, причина, що спрацювало.

## Загальне (будь-який Android)

- **Ребут одразу після `pm disable-user` повертає останню порцію.** Стан пакетів пишеться на диск
  із затримкою. Чекай ≥30 с перед перезавантаженням. (Redmi Note 10 Pro, 2026-10-21: втратили всю
  TIER 2 після миттєвого ребуту.)
- **Бездротове налагодження вимикається після ребуту, порт щоразу новий.** Спарювання зберігається:
  користувач лише вмикає перемикач, нове підключення через `adb mdns services`. Windows mDNS інколи
  не бачить сервіс хвилинами — простіше попросити IP:порт з екрана.
- **Uptime у місяці** = витоки пам'яті (аудіосервіс на 465 МБ після 142 днів). Ребут дає більше,
  ніж будь-який дебловт; кажи це прямо.
- **`am force-stop` і `disable-user` не діють на persistent-процеси під UID 1000.**
  `dumpsys activity processes <pkg>` → `*PERS*`. Рішення: `pm uninstall -k --user 0`, після ребуту
  процес не стартує.
- **Знімок RAM одразу після ребуту не порівнюваний.** MemAvailable може бути нижчим, бо кеш ядра
  ще не устаканився. Used RAM — кращий показник; ще краще — через день.
- **`ping` в adb shell** користується системним резолвером, тож годиться для перевірки Private DNS.
- **Регулярка `temu`** ловить `systemui` — шукай пакети точним збігом `grep -x`.

## Xiaomi / Redmi / POCO (MIUI 13, Android 12; Redmi Note 10 Pro sweet_eea)

- **`com.xiaomi.discover` («System apps updater») тихо ставить партнерські застосунки**: Binance о
  02:06 ночі, ігри через роки після покупки. У `pm list packages -i` такі мають
  `installer=com.xiaomi.discover` (або `installer=android` для preload). Вимикати першим.
- **«Cannot disable miui core packages»** — для `com.android.updater` (OTA). Обхід:
  `pm uninstall -k --user 0`. Сповіщення про оновлення зникає.
- **`com.miui.daemon` persistent** (UID 1000): вимкнений, але працює. `pm uninstall -k --user 0` +
  ребут — більше не стартує.
- **MIUI скидає `RUN_ANY_IN_BACKGROUND` при старті** зі свого параметра «Економія заряду» для
  застосунку. Тримається тільки якщо користувач в UI поставить «Обмежити фонову активність»
  і вимкне «Автозапуск». `am set-standby-bucket` MIUI ігнорує (завжди 10).
- **`settings put global ...` → SecurityException WRITE_SECURE_SETTINGS.** Потрібен перемикач
  «Налагодження USB (налаштування безпеки)» (Mi-акаунт + SIM). Простіше — користувач ставить
  Private DNS вручну: Налаштування → Підключення та спільний доступ → Приватний DNS.
- Безпечно вимкнулися (жодних побічних ефектів за день): `com.miui.msa.global`, `com.miui.analytics`,
  `com.miui.miservice`, `com.miui.bugreport`, `com.miui.android.fashiongallery`, `com.miui.hybrid*`,
  `com.mi.globalbrowser`, `com.mi.global.bbs`, `com.miui.yellowpage`, `com.xiaomi.payment`,
  `org.mipay.android.manager`, `android.autoinstalls.config.Xiaomi.qssi`, Facebook-помічники
  (`com.facebook.appmanager/.services/.system`), `com.amazon.appmanager`.
- Не чіпати: `com.xiaomi.account`, `com.xiaomi.xmsf` (будильники, Find Device), `com.miui.securitycenter`,
  `com.miui.powerkeeper`, `com.lbe.security.miui`, `miui.systemui.plugin`; `com.android.camera` —
  це камера Xiaomi.
- Family Link на MIUI: «Заблоковано адміністратором» на тапі по «Версія MIUI» — батьки вмикають
  «Параметри розробника» у Family Link.

## Google Pixel (Pixel 3 blueline, Android 12)

- Майже без сміття від виробника. Пакети операторів Verizon/Sprint вже вимкнені з коробки.
- adb має WRITE_SECURE_SETTINGS — Private DNS ставиться з ПК.
- `am set-standby-bucket restricted` працює (45), налаштування переживають ребут.
- Не чіпати: `com.google.android.odad` (Play Protect), `com.google.android.grilservice` (радіо),
  `com.google.android.turboadapter` (оцінки батареї), `com.google.android.apps.nexuslauncher`.
- Pixel 3: батарея на ~78% після 4+ років, остання латка 2021-10 — сказати власнику.

## Сторонні застосунки, що варто показати власнику

- «Погода» `com.weather.free.forecast.dailyweather`: автостарт, спроби SYSTEM_ALERT_WINDOW
  (накладки з рекламою). Видалили.
- ShareMe `com.xiaomi.midrop` на не-Xiaomi: реклама. Kiwi Browser — закинутий, без оновлень.
- Кредитні/мікропозикові застосунки (наприклад `com.mdfin.creditkasa`), особливо на телефоні під Family Link.
