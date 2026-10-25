# Уроки з практики (оновлюй після кожного пристрою)

## Пам'ять і продуктивність
- Найбільші «пожирачі», яких не можна вимкнути: `system`, Google Play Services (gms), Play Store під
  час оновлень. Вимкнення автооновлень у Play Store прибирає сплески на 60–110 МБ (робиться в UI:
  профіль → Налаштування → Автоматично оновлювати додатки → Не оновлювати; через `tools\ui.ps1`).
- Стоковий лаунчер Android TV — найбільший процес (105–150 МБ). Наш лаунчер — 31 МБ після старту,
  50–76 МБ після використання. Вимкнення рекомендацій/промо-каналів зменшує стоковий до ~92–106 МБ.
- Системні застосунки, що висять у фоні (приклад — Netflix: ~50 МБ, ~30% часу), можна не вимикати, а
  приборкати: `cmd appops set <p> RUN_ANY_IN_BACKGROUND ignore`, `cmd appops set <p>
  RUN_IN_BACKGROUND ignore`, `am force-stop <p>` (→ `stopped=true`, не стартує при завантаженні,
  поки його не відкриють), `cmd deviceidle sys-whitelist -<p>`. `am set-standby-bucket` на
  system-exempt пакети не діє. Процес `android.hardware.drm@*.netflixdrm` — нативний HAL, це не застосунок.
- Згорнуті кнопкою Home застосунки — просто кеш, система (lmkd) вивантажує їх сама; «чистильники»
  шкодять. Проблема — лише ті, що мають фонові служби/автозапуск.
- Обмеження фонових процесів у параметрах розробника не радити: застосунки щоразу стартують з нуля.
- Анімації 0.5: `settings put global window_animation_scale|transition_animation_scale|animator_duration_scale 0.5`.

## Прошивка і обмеження
- Android 14: `pm disable-user` на окремий КОМПОНЕНТ системного застосунку з shell заборонено
  (SecurityException). Вимикається тільки пакет цілком.
- Деякі пакети прошивка вмикає назад після ребута (Changhong: `com.cltv.fast`). Перевіряй
  `pm list packages -d` після перезавантаження; таке — `pm uninstall --user 0` (з дозволу).
- Changhong/Homwee (ERGO, RCA, CHiQ, realme, Aiwa…) при кожному ввімкненні відкривають Live TV
  (`com.mediatek.wwtv.tvcenter`, BootBroadcastReceiver) + «готельне» вікно `com.homwee.factory/
  com.gdch.hotel.ui.ProtocolActivity`. У меню опції немає (перевірено все меню Live TV і Налаштувань),
  в інтернеті рішення немає. Рішення — ключ `power_on_home` лаунчера CleanYourTV (див. нижче).
- Скріншоти Live TV/HDMI порожні (захищений шар) — читай екран через `tools\ui.ps1` (uiautomator)
  або `dumpsys activity activities | grep topResumedActivity`.
- Xiaomi Mi Box S: поки ввімкнено налагодження USB, USB-порт без живлення.
- Changhong redwood: тільки «Налагодження USB» відкриває порт 5555; після ребута може змінитись IP.

## Стоковий головний екран (коли лаунчер не міняємо)
- Налаштування головного екрана: `am start -n com.google.android.tvlauncher/.settings.HomeScreenSettingsActivity`
  → вимкнути превʼю відео/аудіо; «Налаштувати канали» → вимкнути промо-канали.
- «Основні сервіси Android TV: Оригінальні додатки» — це реклама Google Play (Prime, ABEMA, Twitch…).
- Канали застосунків, які встановив і використовує власник (напр. Київстар ТБ, MEGOGO, SWEET.TV) — питати, НЕ вимикати
  без згоди. «Вибране» (Play Next) — залишати.
- Після зміни каналів: `am force-stop com.google.android.tvlauncher`, потім Home — інакше старий кеш.

## Лаунчер CleanYourTV
- Док/Live TV/приховані застосунки міняються ТЕМОЮ без перезбирання: `tools\theme.ps1 -TvHost <ip>
  <папка з config.json>` (ключі: `dock_apps`, `hidden_apps`, `live_tv_package`, `columns`…).
  Приклад — `devices/ergo-dvb92yc/theme/config.json`.
- `config.xml` у локальній копії зараз налаштований під Xiaomi MOOR2 (док Netflix+YouTube,
  Live TV = `com.mitv.livetv`); для інших пристроїв — тема.
- JDK окремо не потрібен: `JAVA_HOME=C:\Program Files\Android\Android Studio\jbr`. SDK 34 Gradle
  докачує сам.
- **`power_on_home`** (наша доробка, злита в CleanYourTV 2026-10-25: https://github.com/Gathin23/cleanyourtv/pull/1445;
  підтверджена й на CHiQ DVB92CQ тієї ж плати): ключ теми / `config.xml` + `HOME_KEY_SERVICE=1`
  (`build-and-install.ps1 -HomeKeyService`). Коли прошивка сама відкриває Live TV (`live_tv_package`) при
  завантаженні (3 хв) або після пробудження (60 с), `HomeKeyService` повертає на Home — до першої кнопки
  пульта. Ігнорується з `boot_to_live_tv` або коли Live TV обрано в Open on start. Перевірено на ERGO:
  ребут, сон/пробудження, справжній пульт (Live TV, відкритий вручну, лишається). Після КОЖНОГО
  перевстановлення лаунчера `-HomeKeyService` потрібен знову. Замінив нашу першу версію BootHomeService.
- Порядок плиток: затиснути OK на кнопці Settings → «Змінити порядок застосунків».
- Кнопку Settings на пульті Google TV обробляв стоковий лаунчер; без нього вона мертва. Лікується
  службою доступності `HomeKeyService` (вже є в APK): `settings put secure enabled_accessibility_services
  com.gathin.tvhome/.HomeKeyService; settings put secure accessibility_enabled 1`. Якщо пульт шле інший
  код — `settings_key_keycodes` у темі; панель замість Налаштувань — `settings_key_panel: true`.
- Українського перекладу в лаунчері немає.
- Порівняння з LtvLauncher (Flutter, ~10 МБ APK, оцінка 70–120 МБ RAM) — наш легший; точної
  опенсорсної копії стокового лаунчера не існує.

## З інших проєктів (tv-detox, free-my-tv; перевірено читанням коду 2026-10-23, не на наших ТВ)
- ⚠️ **Google TV: вимкнення `com.google.android.apps.tv.launcherx`** на деяких пристроях давало
  нескінченне перезавантаження, рятувало лише скидання до заводських (tv-detox з v1.4.1 його не
  вимикає без `GOOGLE_TV=1`). На Xiaomi MOOR2 ми його вимкнули за протестованим списком CleanYourTV —
  ребут пережив. Перед оновленням прошивки чи скиданням такого ТВ — спершу відкат (`restore.ps1`).
  Для нового Google TV: питати користувача і пояснювати ризик; якщо в `examples/` немає перевіреного
  списку саме для моделі — стоковий лаунчер не вимикати.
- **Перевірка після оновлення прошивки** (ідея `check.sh --fix` з tv-detox): оновлення може ввімкнути
  вимкнені пакети / скинути налаштування. Після OTA — порівняти `pm list packages -d` зі списками
  пристрою і `settings get global *_animation_scale`, повторно застосувати те, що злетіло.
- **Автокласифікація пакетів** (`candidates.sh` з tv-detox): never (потрібне ТВ + усе PERSISTENT) /
  keep (функція: Chromecast, голос, Live TV) / safe (типове сміття) / review (невідоме). Хороший
  перший прохід перед ручним аналізом; їхні списки NEVER/KEEP/SAFE — корисна звірка.
- **`device_config activity_manager max_cached_processes 4`** (tv-detox) — менше застосунків у кеші.
  Не радимо: застосунки частіше стартують з нуля (той самий компроміс, що й ліміт фонових процесів).
- **OLED:** заставку не вимикати, сон через 5 хв (tv-detox). Питати, чи екран OLED.
- **Страховки free-my-tv, яких немає в CleanYourTV:** Watchdog — після 3 падінь головного екрана за
  5 хв сам повертає стоковий; відкат однією кнопкою на ТВ без ПК (застосунок ходить у власний ADB
  телевізора `127.0.0.1:5555`); перед вимкненням питає ТВ, чи від пакета залежать входи / кнопка
  Input; не чіпає пакети, що володіють збереженою Wi‑Fi.
- **Бренд-специфіка з free-my-tv:** TCL (TCL Channel, готельне меню, демо, мануали, дзеркалення,
  логування; для фону потрібне `appops set <pkg> AUTO_START allow`), Philco (AI PONT), Multilaser і
  KTC/NextStar (Anoki ACR), перепризначення кнопок пульта на TCL, Sony, Vestel, Formovie.
- **LG webOS і Samsung Tizen** — CleanYourTV не підтримує; free-my-tv ставить свій головний екран
  через їхні Developer Mode (деблоту як такого там немає).
- **Розміри лаунчерів:** tv-detox 40 КБ APK (найменший, лише застосунки + HDMI + годинник);
  CleanYourTV ~400 КБ, 31–76 МБ RAM (наш замір); free-my-tv — збирати самому, ~96 МБ RAM за даними
  автора, постійно ходить у мережу (TMDB, погода, крипта) — для ТВ з 1 ГБ не радити.

## Відкат
- Запис для відкату прив'язаний до ПОВНОГО ШЛЯХУ файлу-списку (`recovery-<ip>-<sha1(шлях)>.json` у
  `~\.cleanyourtv\`). Не переміщай і не перейменовуй список після застосування.
- `cleanyourtv\tools\restore.ps1 -TvHost <ip> <список> [-Stock <стоковий лаунчер>]`.
