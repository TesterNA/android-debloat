# ERGO DVB92YC (Changhong AI PONT, redwood, MT5867), Android TV 14

- Прошивка UKNV.260514.001 (як `examples/rca-ai-pont`). 1 ГБ RAM (`low_ram=true`), 1280×720, /data 4 ГБ.
- Стоковий лаунчер: `com.google.android.tvlauncher` (класичний Android TV). Live TV: `com.mediatek.wwtv.tvcenter`.
- Пульт: Bluetooth LE «TVC0GWBT» → Bluetooth і `com.mediatek.autopair` не чіпати.
- Майстру налаштування (`setupwraith`) належить основна Wi‑Fi, через яку ТВ підключений → НЕ вимикати. HOME він тут не займає.
- Нативний демон `vendor.anoki.acrservice` (ACR) не вимикається без root; без застосунку він простоює.
- Дата: 2026-10-20.

## Що зроблено
1. `debloat.txt` (27): Anoki ACR, FAST-канали, рекомендації, автовстановлення, магазин/довідка/інсталятор/
   оновлювач застосунків/TV Manager/медіа/Miracast/Alexa від Homwee; Google Feedback, YouTube Music, Play Ігри,
   Google TV, TTS, Ambient, календар; голос (katniss), Chromecast, Prime Video.
2. `com.cltv.fast` прошивка вмикала назад → `pm uninstall --user 0` (повернення: `cmd package install-existing com.cltv.fast`).
   Після ребута не повернувся.
3. Лаунчер CleanYourTV + тема `theme/config.json` (док: Київстар ТБ, MEGOGO, SWEET.TV, YouTube; Live TV = tvcenter).
4. Live TV при ввімкненні прибрано ключем `power_on_home` (`HOME_KEY_SERVICE=1`, тема з `"power_on_home": true`),
   https://github.com/Gathin23/cleanyourtv/pull/1445. Live TV вискакує на ~1,5 с і ТВ сам іде на Home.
   Перевірено 2026-10-24: ребут, сон/пробудження, справжній пульт (Live TV, відкритий вручну, лишається).
   До 24.10 тут стояла наша перша версія — окрема служба BootHomeService; її замінено.
5. Netflix: фон обмежено (appops ignore, force-stop → stopped=true, прибрано з sys-whitelist). Працює при ручному запуску.
6. Автооновлення Play Store вимкнено. Анімації 0.5.

## Результат (замір через ~7,5 хв після ребута)
| | Початок | 1-й раунд | Фінал |
|---|---|---|---|
| MemAvailable | 263 МБ | 330 МБ | 343 МБ |
| swap використано | 386 МБ | 216 МБ | 209 МБ |
Стоковий лаунчер 105 МБ → наш 31 МБ (після старту).

## Залишено свідомо
Пульт з телефона (`com.google.android.tv.remote.service`), оновлення прошивки (`com.homwee.dmt.upgrade`),
`com.homwee.factory`, `com.homwee.synckey`, `com.homwee.dynamicbacklight`, partnercustomizer, усі `com.mediatek.*`.
Ще можна (не зроблено, питали): privacy sandbox (adservices/ondevicepersonalization/federatedcompute), Health Connect,
devicelockcontroller; setupwraith — лише після «забути і перепідключити Wi‑Fi».
При завантаженні самі стартують деякі застосунки власника (файловий менеджер, стрімінг) — залишено (кеш).

## Списки (для відкату — ОРИГІНАЛЬНІ шляхи)
- `<CYT>\ergo-debloat.txt` → `restore.ps1 -TvHost <IP> <він> -Stock com.google.android.tvlauncher`
- Тема: `<CYT>\ergo-theme` (копія — `theme/`). `<CYT>` — локальна копія CleanYourTV, точні шляхи в `LOCAL.md`.
- Перевстановлення лаунчера: свіжа CleanYourTV (`power_on_home` у ній з 25.10, #1445),
  `build-and-install.ps1 -TvHost <IP> -HomeKeyService`, потім `theme.ps1` з темою
  (`theme/config.json` уже містить `"power_on_home": true`).
