"""Turn a collect.sh snapshot into a debloat report.

Usage: python -I scripts/analyze.py <backup-dir> [uad_lists.json]
Prints the report and writes it to <backup-dir>/report.md.
"""
import collections
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if len(sys.argv) < 2 or not sys.argv[1] or not (Path(sys.argv[1]) / "getprop.txt").exists():
    sys.exit("usage: analyze.py <backup-dir with getprop.txt> [uad_lists.json]")
B = Path(sys.argv[1])
UAD =Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "uad" / "uad_lists.json"

# Names that usually mean ads, tracking or silent installs. A hint for review, never a verdict.
SUSPECT = re.compile(r"analytic|(?<![a-z])msa(?![a-z])|(?<![a-z])ads?(?![a-z])|adservice|telemetry|tracking|stat(s|istic)|feedback|bugreport|"
                     r"daemon|discover|autoinstall|preinstall|appmanager|facebook\.(services|system)|"
                     r"mipicks|getapps|hiboard|joyose|aiad|adsolution|appcloud|appselector|"
                     r"transsion\.(ahs|ota)|cloudservice", re.I)


def read(name):
    p = B / name
    return p.read_text(encoding="utf-8", errors="replace") if p.exists() else ""


def pkgs(name):
    return {l.strip().removeprefix("package:").split()[0] for l in read(name).splitlines() if l.strip()}


out = []
w = out.append

props = dict(re.findall(r"\[([^\]]+)\]: \[([^\]]*)\]", read("getprop.txt")))
g = lambda *keys: next((props[k] for k in keys if props.get(k)), "?")
w(f"# {g('ro.product.brand')} {g('ro.product.model')} ({g('ro.product.device')})")
w(f"- Android {g('ro.build.version.release')} (SDK {g('ro.build.version.sdk')}), "
  f"security patch {g('ro.build.version.security_patch')}")
skin = {k: props[k] for k in ("ro.miui.ui.version.name", "ro.mi.os.version.name", "ro.build.version.oneui",
                              "ro.build.version.opporom", "ro.vivo.os.version", "ro.tranos.version",
                              "ro.os.version.release", "ro.build.display.id") if props.get(k)}
w(f"- Firmware: {skin}")
w(f"- Uptime: {read('uptime.txt').strip()}")
w(f"- ro.adb.secure={props.get('ro.adb.secure', '?')}")
dp = read("device-policy.txt")
owners = re.findall(r"(Device Owner|Profile Owner)[^\n]*\n[^\n]*?(\S+/\S+|admin=\S+)", dp)
w(f"- Device/profile owners: {owners or 'none'}  (Family Link, MDM, credit locks show here)")

w("\n## Memory")
mi = read("dumpsys-meminfo.txt")
for line in mi.splitlines():
    if re.match(r"\s*(Total|Free|Used|Lost) RAM:|\s*ZRAM:", line):
        w("    " + line.strip())
m = re.search(r"MemAvailable:\s+(\d+)", read("meminfo.txt"))
if m:
    w(f"    MemAvailable: {int(m.group(1)) // 1024} MB")
w("\nTop processes (PSS):")
sec = mi.split("Total PSS by process:")[1] if "Total PSS by process:" in mi else ""
for line in sec.splitlines()[1:26]:
    if not re.match(r"\s+[\d,]+K: ", line):
        break
    w("    " + line.strip())

w("\n## Storage")
w("    " + read("df.txt").strip().replace("\n", "\n    "))

w("\n## Battery")
bat = read("battery.txt")
lvl = re.search(r"level: (\d+)", bat)
temp = re.search(r"temperature: (\d+)", bat)
w(f"- Level {lvl and lvl.group(1)}%, temperature {temp and int(temp.group(1)) / 10}°C")
bs = read("batterystats.txt")
cap = re.search(r"Capacity: (\d+), Computed drain: ([\d.]+), actual drain: ([\d.-]+)", bs)
if cap:
    w(f"- Estimated capacity {cap.group(1)} mAh (compare with the model's design capacity: below ~80% "
      f"means a worn battery). Drain since last charge: computed {cap.group(2)}, actual {cap.group(3)} mAh")
uids = collections.defaultdict(list)
for line in read("packages-all.txt").splitlines():
    mm = re.search(r"=([\w.]+) uid:(\d+)", line)
    if mm:
        uids[int(mm.group(2))].append(mm.group(1))
w("Top battery users since last charge:")
est = bs.split("Estimated power use")[1] if "Estimated power use" in bs else ""
n = 0
for line in est.splitlines():
    mm = re.match(r"\s+UID (u0a(\d+)|\d+): ([\d.]+) \((.*)\)", line)
    if not mm:
        continue
    uid = 10000 + int(mm.group(2)) if mm.group(2) else int(mm.group(1))
    name = " ".join(uids.get(uid, [])) or ("system" if uid == 1000 else f"uid {uid}")
    w(f"    {mm.group(3):>8} mAh  {name}  ({mm.group(4).strip()[:90]})")
    n += 1
    if n >= 15:
        break

system, user, disabled = pkgs("packages-system.txt"), pkgs("packages-user.txt"), pkgs("packages-disabled.txt")
gone = pkgs("packages-incl-uninstalled.txt") - system - user
w(f"\n## Packages: {len(system)} system, {len(user)} user, {len(disabled)} disabled, "
  f"{len(gone)} removed for user 0")
if disabled:
    w("Already disabled: " + " ".join(sorted(disabled)))
if gone:
    w("Already removed for user 0: " + " ".join(sorted(gone)))

installer = {}
for line in read("packages-user-installer.txt").splitlines():
    mm = re.match(r"package:(\S+)\s+installer=(\S+)", line.strip())
    if mm:
        installer[mm.group(1)] = mm.group(2)
itime = dict(l.split(" ", 1) for l in read("user-install-times.txt").splitlines() if " " in l)
w("\n## User apps (installer, first install). Not from Play Store = look closer")
for p in sorted(user):
    ins = installer.get(p, "?")
    flag = "" if ins in ("com.android.vending", "?") else "   <-- not Play Store"
    w(f"    {p}  [{ins}]  {itime.get(p, '').replace('firstInstallTime=', '')}{flag}")

uad = json.loads(UAD.read_text(encoding="utf-8"))
by = collections.defaultdict(list)
for p in sorted((system | user) - disabled):
    e = uad.get(p)
    by[e["removal"] if e else ("Unknown-system" if p in system else "Unknown-user")].append(p)
for level in ("Recommended", "Advanced"):
    w(f"\n## UAD {level} ({len(by[level])}) - enabled now")
    for p in by[level]:
        e = uad[p]
        w(f"    {p} [{e['list']}] {e['description'].splitlines()[0][:110]}")
w(f"\n## UAD Expert ({len(by['Expert'])}) - only with a specific reason")
w("    " + " ".join(by["Expert"]))
w(f"\n## UAD Unsafe ({len(by['Unsafe'])}) - never touch")
w("    " + " ".join(by["Unsafe"]))
w(f"\n## Not in UAD, system ({len(by['Unknown-system'])}) - check with dumpsys package before deciding")
w("    " + " ".join(by["Unknown-system"]))

sus = sorted(p for p in (system | user) - disabled if SUSPECT.search(p))
w(f"\n## Name looks like ads/telemetry/installer ({len(sus)}) - verify each, names lie both ways")
for p in sus:
    e = uad.get(p)
    w(f"    {p}  [{e['removal'] if e else 'not in UAD'}]")

text = "\n".join(out)
(B / "report.md").write_text(text, encoding="utf-8")
print(text)
