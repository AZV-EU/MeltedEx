import subprocess
from packaging.version import Version

target = "MeltedEx.lua"

with open(target + ".backup", "w") as fTo:
    with open(target, "r") as fFrom:
        fTo.writelines(fFrom.readlines())

with open(target, "r") as f:
    lines = f.readlines()
    origVersion = Version(lines[0][17:-2])
    lines[1] = "_G.MX_ENV = \"PROD\"\n"

version = Version(f'{origVersion.major}.{origVersion.minor}.{origVersion.micro + 1}')
lines[0] = f'_G.MX_VERSION = \"{version}\"\n'

with open(target, "w") as f:
    f.writelines(lines)

print(f'Updating v{origVersion} -> v{version}')
subprocess.run(["git", "add", "."])
subprocess.run(["git", "status"])
subprocess.run(["git", "commit", "-m", f"v{origVersion} -> v{version}"])

lines[1] = "_G.MX_ENV = \"DEV\"\n"

with open(target, "w") as f:
    f.writelines(lines)