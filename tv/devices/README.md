# Відомі пристрої

| Пристрій | Модель / плата / Android | Відповідник у CleanYourTV | Лаунчер | Нотатки |
|---|---|---|---|---|
| Xiaomi TV | MiTV-MOOR2 / venom (MediaTek) / Google TV 11, 1,8 ГБ | `examples/xiaomi-mitv-moor2` | CleanYourTV | [notes](xiaomi-mitv-moor2/notes.md) |
| ERGO TV | ERGO DVB92YC / Changhong redwood, MT5867 / Android TV 14, 1 ГБ | `examples/rca-ai-pont` (та сама плата і прошивка) | CleanYourTV + `power_on_home` (#1445) | [notes](ergo-dvb92yc/notes.md) |
| Mi Box S | MIBOX4 / oneday (Amlogic gxl) / Android TV 9, 2 ГБ | `examples/xiaomi-mi-box-s` | **стоковий, НЕ міняти** | [notes](xiaomi-mibox-s/notes.md) |

IP пристроїв і інші приватні деталі — у `..\..\LOCAL.md` (лише локально). IP може змінитися після
перезавантаження (DHCP): перевіряй `tv.py --probe`, що це той самий пристрій.

Записи для відкату: `~\.cleanyourtv\recovery-<ip>-*.json` (прив'язані до шляху списку — див.
«Списки» в нотатках кожного пристрою).
