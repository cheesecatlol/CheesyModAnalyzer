# CheesyModAnalyzer
CMD script to analyze Minecraft mods and identify potential cheat mod clients.

## Installation

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cheesecatlol/CheesyModAnalyzer/main/CheesyModAnalyzer.ps1')"
```

## Usage
Open command prompt with admin and paste the script in.

On startup, the script automatically detects the active Minecraft instance:

* If Minecraft is **running**, it reads the Java process command line to find the exact instance folder and pre-selects it — just press **Enter** to confirm
* If Minecraft is **not running** or the path cannot be detected, enter a custom path manually

## How It Works

### Phase 1: Database Verification

The script calculates the SHA1 hash of each JAR file and compares it with official databases:

**Modrinth API** `https://api.modrinth.com/v2/version_file/{hash}`
* Main database of verified mods
* Returns project name and slug if found

**Megabase API** `https://megabase.vercel.app/api/query?hash={hash}`
* Alternative database for known mods
* Backup in case Modrinth doesn't find matches

Found mods are classified as **VERIFIED**.

### Phase 2: Pattern Analysis

For unverified mods, the script:

1. Extracts JAR file contents using `System.IO.Compression.ZipFile`
2. Analyzes internal file names and paths
3. Reads content of `.class`, `.json`, `.toml`, `.cfg`, `.properties`, and `MANIFEST.MF` files
4. Searches for suspicious patterns via regex matching
5. Detects obfuscation techniques (short path names, single-char class names, Japanese/Chinese characters)

### Download Source Tracking

The script reads Windows' `Zone.Identifier` stream (Alternate Data Stream) to identify where the mod was downloaded from.

## Detected Cheat Patterns

The script contains over 100 patterns associated with cheat clients:

**Obfuscated patterns:**
* Package `org.chainlibs.module.impl.modules.*`
* Classes with Japanese/Chinese characters (`じ.class`, `ふ.class`, etc.)
* Suspicious mixins: `KeyboardMixin`, `ClientPlayerInteractionManagerMixin`, `LicenseCheckMixin`
* Files: `phantom-refmap.json`, `xyz.greaj`
* Libraries: `jnativehook`, `imgui`, `imgui.gl3`, `imgui.glfw`
* Runtime command execution, suspicious reflection, unexpected network calls

And more patterns...

## Output

The script categorizes mods into three groups:

**✅ VERIFIED MODS** — Mods found in official databases, considered safe.

**❓ UNKNOWN MODS** — Mods not present in databases but without suspicious patterns. Shows download source when available.

**🚨 SUSPICIOUS MODS** — Mods containing one or more patterns associated with cheats. Lists all detected patterns with explanations for each mod.

## Additional Information

If Minecraft is running, the script displays:
* Process name (`java` / `javaw`)
* Process PID
* Startup timestamp
* Current uptime
* Active instance path (auto-detected from the process command line)

## Contacts

Discord: `cheese_cat0`  
GitHub: [cheesecatlol](https://github.com/cheesecatlol)  

