import subprocess
from packaging.version import Version

target = "MeltedEx.lua"

with open(target + ".backup", "w") as fTo:
    with open(target, "r") as fFrom:
        fTo.writelines(fFrom.readlines())

with open(target, "r") as f:
    lines = f.readlines()
    origVersion = lines[0][17:-2]
    lines[1] = "_G.MX_ENV = \"PROD\"\n"

with open(target, "w") as f:
    f.writelines(lines)

print(f'Updating to v{origVersion}')
subprocess.run(["git", "add", "."])
subprocess.run(["git", "status"])
subprocess.run(["git", "commit", "-m", f"v{origVersion}"])
subprocess.run(["git", "push"])

micro = int(origVersion[origVersion.rindex('.')+1:][0])
minor = int(origVersion[origVersion.index('.')+1:origVersion.rindex('.')])
major = int(origVersion[:origVersion.index('.')])
buildAlpha = chr(97 + ((ord(origVersion[-1:].lower()) - 96) % 26))
if buildAlpha == 'a':
    micro += 1
    if micro >= 10:
        micro = 0
        minor += 1
        if minor >= 10:
            minor = 0
            major += 1
version = f'{major}.{minor}.{micro}{buildAlpha}'
lines[0] = f'_G.MX_VERSION = \"{version}\"\n'
lines[1] = "_G.MX_ENV = \"DEV\"\n"

with open(target, "w") as f:
    f.writelines(lines)