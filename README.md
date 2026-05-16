[README.md](https://github.com/user-attachments/files/27852494/README.md)
# CheesyModAnalyzer
**Made by cheese cat**

A PowerShell tool that scans your Minecraft mods folder for suspicious or unknown mods. It checks each `.jar` file against Modrinth and Megabase databases using SHA-1 hashing, and scans for known suspicious patterns.

---

## How to run

Paste this into CMD and press Enter — no installation needed:

```cmd
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cheesecatlol/CheesyModAnalyzer/main/CheesyModAnalyzer.ps1')"
```

Or if you downloaded the file manually:

```cmd
powershell -ExecutionPolicy Bypass -File "%USERPROFILE%\Downloads\CheesyModAnalyzer.ps1"
```

---

## What it does

- Scans all `.jar` files in your mods folder
- Computes a SHA-1 hash for each mod
- Looks up each hash on **Modrinth** and **Megabase**
- Scans file contents for known suspicious strings
- Shows one of three results per mod:

| Result | Meaning |
|--------|---------|
| ✅ VERIFIED | Found in Modrinth or Megabase database |
| 🔵 UNKNOWN | Not in any database, but no suspicious patterns found |
| 🔴 SUSPICIOUS | Contains known suspicious or malicious strings |

---

## Requirements

- Windows
- PowerShell 5.1 or higher (built into Windows 10/11)
- Internet connection (for database lookups)

---

## Notes

- The default mods folder is `%APPDATA%\.minecraft\mods`
- You can enter a custom path when prompted
- UNKNOWN does not mean a mod is dangerous — it just means it isn't in any known database
