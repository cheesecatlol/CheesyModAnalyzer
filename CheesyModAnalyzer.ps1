#Requires -Version 5.1
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ================================================================
#  ANIMATION & DISPLAY HELPERS
# ================================================================

$spinnerFrames = @("|", "/", "-", "\")
$spinnerIndex  = 0

function Show-Spinner([string]$Message) {
    $frame = $spinnerFrames[$script:spinnerIndex % 4]
    $script:spinnerIndex++
    Write-Host "`r  $frame  $Message                    " -NoNewline -ForegroundColor DarkYellow
}

function Clear-Line {
    Write-Host "`r" -NoNewline
    Write-Host ("  " + " " * 70) -NoNewline
    Write-Host "`r" -NoNewline
}

function Show-ProgressBar([int]$Current, [int]$Total, [string]$Label) {
    $pct    = [int](($Current / [Math]::Max($Total,1)) * 100)
    $filled = [int](($Current / [Math]::Max($Total,1)) * 40)
    $empty  = 40 - $filled
    $bar    = ("[" + ("#" * $filled) + ("-" * $empty) + "]")
    Write-Host "`r  $bar $pct%  $Label          " -NoNewline -ForegroundColor Yellow
}

function Write-Banner {
    Clear-Host
    Start-Sleep -Milliseconds 80

    $lines = @(
        "                                                                    ",
        "    ____ _  _ ____ ____ ____ _   _    _  _ ____ ____               ",
        "    |    |__| |___ |___ [__   \_/     |\/| |  | |  \               ",
        "    |___ |  | |___ |___ ___]   |      |  | |__| |__/               ",
        "                                                                    ",
        "    ____ _  _ ____ _    _   _ ____  ____ ____                      ",
        "    |__| |\ | |__| |     \_/  [__   |___ |__/                      ",
        "    |  | | \| |  | |___   |   ___]  |___ |  \                      ",
        "                                                                    "
    )

    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor Yellow
        Start-Sleep -Milliseconds 25
    }

    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "  SHA-1 Verification  " -NoNewline -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "  " -NoNewline
    Write-Host "  Pattern Detection  " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host "  Source Tracking  " -ForegroundColor Black -BackgroundColor DarkGray
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "  o O o O o  [ Made by cheese cat ]  o O o O o  " -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
    Write-Host ""
}

function Write-SectionHeader([string]$Title, [ConsoleColor]$Color = "Yellow") {
    Write-Host ""
    Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
    Write-Host "  $Title" -ForegroundColor $Color
    Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
    Write-Host ""
}

function Write-ResultLine([string]$Status, [string]$Name) {
    $tag = switch ($Status) {
        "VERIFIED"   { " VERIFIED  " }
        "UNKNOWN"    { " UNKNOWN   " }
        "SUSPICIOUS" { "SUSPICIOUS " }
        default      { "  ??????   " }
    }
    $tagBg = switch ($Status) {
        "VERIFIED"   { "DarkGreen" }
        "UNKNOWN"    { "DarkBlue"  }
        "SUSPICIOUS" { "DarkRed"   }
        default      { "DarkGray"  }
    }
    Write-Host "  [" -NoNewline -ForegroundColor DarkYellow
    Write-Host $tag -NoNewline -ForegroundColor White -BackgroundColor $tagBg
    Write-Host "]  " -NoNewline -ForegroundColor DarkYellow
    Write-Host $Name -ForegroundColor White
}

function Write-DetailLine([string]$Key, [string]$Value, [ConsoleColor]$ValueColor = "Gray") {
    Write-Host "           " -NoNewline
    Write-Host "$Key" -NoNewline -ForegroundColor DarkGray
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host $Value -ForegroundColor $ValueColor
}

# ================================================================
#  DATA
# ================================================================

$SuspiciousPatterns = @(
    "AimAssist","AutoCrystal","AutoHitCrystal","TriggerBot","Velocity","Criticals",
    "Reach","Hitboxes","ShieldBreaker","ShieldDisabler","AxeSpam","KillAura",
    "BowAimbot","CrystalAura","SurroundBreaker","HoleSnap","BedAura",
    "Flight","Antiknockback","NoKnockback","JumpReset","SprintReset","NoJumpDelay",
    "Scaffold","Tower","Jesus","Dolphin","BoatFly","ElytraFly","Phase","Clip",
    "NoFall","NoSlow","Timer","Strafe","LegitScaffold","FastBridge",
    "AutoTotem","AutoArmor","AutoPot","AutoDoubleHand","InventoryTotem","TotemHit",
    "PopSwitch","LagReach","Wtap","FakeLag","Blink","PacketFly",
    "BlockESP","Freecam","PackSpoof","PingSpoof","FakeNick","FakeItem",
    "ESP","Tracers","ChestESP","PlayerESP","Wallhack","FullBright","XRay",
    "FastPlace","ChestSteal","Refill","AutoEat","AutoMine","AutoClicker","FastXP",
    "Nuker","AutoSign","AutoBuild","Printer",
    "Asteria","Prestige","Xenon","Argon","Hellion","Virgin","Donut","Krypton",
    "dev.krypton","dev.gambleclient","Grim","PrestigeClient","DoomsdayClient",
    "198Macros","Backdoor","TokenGrabber","Stealer",
    "chainlibs","phantom-refmap","xyz.greaj","jnativehook","imgui",
    "KeyboardMixin","ClientPlayerInteractionManagerMixin","LicenseCheckMixin"
)

$JapaneseRegex = [regex]"[\u3040-\u309F\u30A0-\u30FF]"

$SafeSources   = @("curseforge.com","modrinth.com","cdn.modrinth.com","mediafiles.curseforge.com")
$RiskySources  = @(
    @{ Pattern = "cdn.discordapp.com"; Label = "Discord CDN" },
    @{ Pattern = "discord.com";        Label = "Discord" },
    @{ Pattern = "mediafire.com";      Label = "MediaFire" },
    @{ Pattern = "github.com";         Label = "GitHub" },
    @{ Pattern = "mega.nz";            Label = "MEGA" },
    @{ Pattern = "dropbox.com";        Label = "Dropbox" },
    @{ Pattern = "drive.google.com";   Label = "Google Drive" },
    @{ Pattern = "anydesk.com";        Label = "AnyDesk" },
    @{ Pattern = "doomsdayclient";     Label = "DoomsdayClient" },
    @{ Pattern = "prestigeclient";     Label = "PrestigeClient" },
    @{ Pattern = "198macros";          Label = "198Macros" }
)

# ================================================================
#  CORE FUNCTIONS
# ================================================================

function Get-DownloadSource([string]$FilePath) {
    $adsPath = "${FilePath}:Zone.Identifier"
    try {
        if (Test-Path $adsPath) {
            $content = Get-Content -LiteralPath $adsPath -Raw -ErrorAction Stop
            foreach ($safe in $SafeSources) {
                if ($content -match [regex]::Escape($safe)) { return @{ Label = $safe; IsSafe = $true } }
            }
            foreach ($risky in $RiskySources) {
                if ($content -match [regex]::Escape($risky.Pattern)) { return @{ Label = $risky.Label; IsSafe = $false } }
            }
            if ($content -match 'HostUrl=(.+)') { return @{ Label = $Matches[1].Trim(); IsSafe = $null } }
        }
    } catch {}
    return $null
}

function Get-SHA1Hash([string]$FilePath) {
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    try {
        $stream = [System.IO.File]::OpenRead($FilePath)
        $bytes  = $sha1.ComputeHash($stream)
        $stream.Close()
        return ([BitConverter]::ToString($bytes) -replace "-").ToLower()
    } finally { $sha1.Dispose() }
}

function Invoke-ModrinthLookup([string]$Hash) {
    try {
        $resp = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$Hash" -Method Get -TimeoutSec 8 -ErrorAction Stop
        return @{ Found = $true; Name = if ($resp.name) { $resp.name } else { $resp.project_id }; Slug = $resp.project_id; Source = "Modrinth" }
    } catch { return @{ Found = $false } }
}

function Invoke-MegabaseLookup([string]$Hash) {
    try {
        $resp = Invoke-RestMethod -Uri "https://megabase.vercel.app/api/query?hash=$Hash" -Method Get -TimeoutSec 8 -ErrorAction Stop
        if ($resp -and ($resp.name -or $resp.id)) {
            return @{ Found = $true; Name = if ($resp.name) { $resp.name } else { $resp.id }; Source = "Megabase" }
        }
    } catch {}
    return @{ Found = $false }
}

function Invoke-JarScan([string]$FilePath) {
    $found = [System.Collections.Generic.List[string]]::new()
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            foreach ($p in $SuspiciousPatterns) {
                if ($name -match [regex]::Escape($p) -and $found -notcontains $p) { [void]$found.Add($p) }
            }
            if ($JapaneseRegex.IsMatch($name) -and $found -notcontains "Japanese obfuscation") { [void]$found.Add("Japanese obfuscation") }
            $ext = [System.IO.Path]::GetExtension($name).ToLower()
            if (($ext -in @(".json",".txt",".toml",".cfg")) -or ($name -match "MANIFEST\.MF")) {
                if ($entry.Length -lt 1MB) {
                    try {
                        $stream = $entry.Open()
                        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8, $true)
                        $text   = $reader.ReadToEnd()
                        $reader.Close(); $stream.Close()
                        foreach ($p in $SuspiciousPatterns) {
                            if ($text -match [regex]::Escape($p) -and $found -notcontains $p) { [void]$found.Add($p) }
                        }
                        if ($JapaneseRegex.IsMatch($text) -and $found -notcontains "Japanese obfuscation") { [void]$found.Add("Japanese obfuscation") }
                    } catch {}
                }
            }
        }
        $zip.Dispose()
    } catch {
        Write-Host ""
        Write-Host "    [WARN] Could not open JAR: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
    return $found
}

# ================================================================
#  STARTUP
# ================================================================

Write-Banner
Start-Sleep -Milliseconds 200

# Minecraft process check
$procs = Get-Process -Name "java","javaw" -ErrorAction SilentlyContinue
if ($procs) {
    Write-Host "  >> Minecraft is RUNNING" -ForegroundColor Yellow
    foreach ($p in $procs) {
        try {
            $up = (Get-Date) - $p.StartTime
            Write-Host "     $($p.Name) (PID $($p.Id))  |  Started: $($p.StartTime.ToString('HH:mm:ss'))  |  Uptime: $([int]$up.TotalHours)h $($up.Minutes)m" -ForegroundColor DarkYellow
        } catch {}
    }
    Write-Host ""
}

# ── Auto-detect mod folders ────────────────────────────────────
$detectedFolders = [System.Collections.Generic.List[hashtable]]::new()

# Vanilla / Forge / Fabric
$vanillaPath = Join-Path $env:APPDATA ".minecraft\mods"
if (Test-Path $vanillaPath) { $detectedFolders.Add(@{ Label = "Vanilla/Fabric/Forge"; Path = $vanillaPath }) }

# CurseForge
$cfBase = Join-Path $env:USERPROFILE "curseforge\minecraft\Instances"
if (Test-Path $cfBase) {
    Get-ChildItem -Path $cfBase -Directory | ForEach-Object {
        $mp = Join-Path $_.FullName "mods"
        if (Test-Path $mp) { $detectedFolders.Add(@{ Label = "CurseForge: $($_.Name)"; Path = $mp }) }
    }
}

# Prism Launcher
$prismBases = @(
    (Join-Path $env:APPDATA "PrismLauncher\instances"),
    (Join-Path $env:LOCALAPPDATA "PrismLauncher\instances")
)
foreach ($prismBase in $prismBases) {
    if (Test-Path $prismBase) {
        Get-ChildItem -Path $prismBase -Directory | ForEach-Object {
            $mp = Join-Path $_.FullName ".minecraft\mods"
            if (Test-Path $mp) { $detectedFolders.Add(@{ Label = "Prism: $($_.Name)"; Path = $mp }) }
        }
    }
}

# Show detected folders
Write-Host "  Detected mod folders:" -ForegroundColor DarkGray
Write-Host ""
if ($detectedFolders.Count -gt 0) {
    for ($n = 0; $n -lt $detectedFolders.Count; $n++) {
        Write-Host "  " -NoNewline
        Write-Host " $($n+1) " -NoNewline -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "  $($detectedFolders[$n].Label)" -NoNewline -ForegroundColor White
        Write-Host "  $($detectedFolders[$n].Path)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Enter a number to select, or type a custom path:" -ForegroundColor DarkGray
} else {
    Write-Host "  No mod folders detected automatically." -ForegroundColor DarkYellow
    Write-Host "  Enter a custom path:" -ForegroundColor DarkGray
}

Write-Host ""
$userInput = Read-Host "  Choice"

if ($userInput -match '^\d+$') {
    $idx = [int]$userInput - 1
    if ($idx -ge 0 -and $idx -lt $detectedFolders.Count) {
        $modsPath = $detectedFolders[$idx].Path
    } else {
        Write-Host "  [ERROR] Invalid number." -ForegroundColor Red
        Read-Host "  Press Enter to exit"
        exit 1
    }
} elseif ([string]::IsNullOrWhiteSpace($userInput) -and $detectedFolders.Count -gt 0) {
    $modsPath = $detectedFolders[0].Path
} else {
    $modsPath = $userInput.Trim()
}

if (-not (Test-Path $modsPath)) {
    Write-Host ""
    Write-Host "  [ERROR] Folder not found: $modsPath" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

$jarFiles = Get-ChildItem -Path $modsPath -Filter "*.jar" -File
if ($jarFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "  No .jar files found in: $modsPath" -ForegroundColor DarkYellow
    Read-Host "  Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "  Found " -NoNewline -ForegroundColor DarkGray
Write-Host "$($jarFiles.Count)" -NoNewline -ForegroundColor Yellow
Write-Host " mod(s) in: " -NoNewline -ForegroundColor DarkGray
Write-Host $modsPath -ForegroundColor White
Write-Host ""
Start-Sleep -Milliseconds 400

# ================================================================
#  ANALYSIS LOOP
# ================================================================

Write-SectionHeader "SCANNING YOUR MODS..." "Yellow"

$verified   = [System.Collections.Generic.List[hashtable]]::new()
$unknown    = [System.Collections.Generic.List[hashtable]]::new()
$suspicious = [System.Collections.Generic.List[hashtable]]::new()

$i = 0
foreach ($jar in $jarFiles) {
    $i++

    Write-Host "`r  [$i/$($jarFiles.Count)] $($jar.Name)..." -NoNewline -ForegroundColor DarkGray

    $src  = Get-DownloadSource -FilePath $jar.FullName
    $hash = Get-SHA1Hash       -FilePath $jar.FullName

    $result = Invoke-ModrinthLookup -Hash $hash
    if (-not $result.Found) { $result = Invoke-MegabaseLookup -Hash $hash }

    if ($result.Found) {
        Clear-Line
        Write-Host "  [" -NoNewline -ForegroundColor DarkYellow
        Write-Host " VERIFIED " -NoNewline -ForegroundColor Black -BackgroundColor DarkGreen
        Write-Host "]  $($jar.Name)  " -NoNewline -ForegroundColor White
        Write-Host $result.Name -ForegroundColor DarkGreen
        $verified.Add(@{ File = $jar.Name; Name = $result.Name; Slug = $result.Slug; DbSource = $result.Source; Hash = $hash; DlSource = $src })
        continue
    }

    $patterns = Invoke-JarScan -FilePath $jar.FullName

    Clear-Line
    if ($patterns.Count -gt 0) {
        Write-Host "  [" -NoNewline -ForegroundColor DarkYellow
        Write-Host "SUSPICIOUS" -NoNewline -ForegroundColor White -BackgroundColor DarkRed
        Write-Host "]  $($jar.Name)  " -NoNewline -ForegroundColor White
        Write-Host "$($patterns.Count) pattern(s) found" -ForegroundColor Red
        $suspicious.Add(@{ File = $jar.Name; Hash = $hash; Patterns = $patterns; DlSource = $src })
    } else {
        Write-Host "  [" -NoNewline -ForegroundColor DarkYellow
        Write-Host " UNKNOWN  " -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host "]  $($jar.Name)" -ForegroundColor White
        $unknown.Add(@{ File = $jar.Name; Hash = $hash; DlSource = $src })
    }
}

Write-Host ""

# ================================================================
#  RESULTS REPORT
# ================================================================

Write-Host ""
Write-Host ""
Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
Write-Host "  CHEESY RESULTS" -ForegroundColor Yellow
Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
Write-Host ""

Write-Host "  " -NoNewline
Write-Host " $($verified.Count) VERIFIED " -NoNewline -ForegroundColor Black -BackgroundColor DarkGreen
Write-Host "  " -NoNewline
Write-Host " $($unknown.Count) UNKNOWN " -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "  " -NoNewline
Write-Host " $($suspicious.Count) SUSPICIOUS " -ForegroundColor White -BackgroundColor DarkRed
Write-Host ""

# ── VERIFIED ──────────────────────────────────────────────────
if ($verified.Count -gt 0) {
    Write-SectionHeader "VERIFIED MODS  ($($verified.Count))" "Green"
    foreach ($m in $verified) {
        Write-Host "  " -NoNewline
        Write-Host " OK " -NoNewline -ForegroundColor Black -BackgroundColor DarkGreen
        Write-Host "  $($m.File)" -ForegroundColor White
    }
    Write-Host ""
}

# ── UNKNOWN ───────────────────────────────────────────────────
if ($unknown.Count -gt 0) {
    Write-SectionHeader "UNKNOWN MODS  ($($unknown.Count))" "Cyan"
    foreach ($m in $unknown) {
        Write-Host "  " -NoNewline
        Write-Host " ?? " -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host "  $($m.File)" -ForegroundColor White
    }
    Write-Host ""
}

# ── SUSPICIOUS ────────────────────────────────────────────────
if ($suspicious.Count -gt 0) {
    Write-SectionHeader "SUSPICIOUS MODS  ($($suspicious.Count))" "Red"
    foreach ($m in $suspicious) {
        Write-ResultLine "SUSPICIOUS" $m.File
        Write-DetailLine "Hash    " "$($m.Hash.Substring(0,20))..." "DarkGray"

        if ($m.DlSource) {
            $c = if ($m.DlSource.IsSafe -eq $false) { "Red" } else { "DarkGray" }
            Write-DetailLine "Source  " $m.DlSource.Label $c
        }

        # Specific pattern explanations
        Write-Host ""
        Write-Host "           Detected strings:" -ForegroundColor DarkRed
        foreach ($p in $m.Patterns) {
            $explanation = switch -Wildcard ($p) {
                "AimAssist"                            { "Automatically aims at players" }
                "KillAura"                             { "Auto-attacks nearby players/entities" }
                "AutoCrystal"                          { "Automatically places and detonates end crystals" }
                "AutoHitCrystal"                       { "Auto-hits crystals for burst damage" }
                "TriggerBot"                           { "Auto-clicks when crosshair is on a player" }
                "Velocity"                             { "Reduces or nullifies knockback received" }
                "Criticals"                            { "Forces critical hits without jumping" }
                "Reach"                                { "Extends melee attack range beyond normal" }
                "Hitboxes"                             { "Enlarges entity hitboxes for easier hits" }
                "ShieldBreaker"                        { "Automatically disables opponent shields" }
                "ShieldDisabler"                       { "Blocks opponent from raising their shield" }
                "AxeSpam"                              { "Rapidly spams axe to break shields faster" }
                "BowAimbot"                            { "Auto-aims bow at players" }
                "CrystalAura"                          { "Full crystal PvP automation aura" }
                "SurroundBreaker"                      { "Breaks surround protection crystals" }
                "HoleSnap"                             { "Snaps player into obsidian holes" }
                "BedAura"                              { "Automates bed PvP in the Nether/End" }
                "Flight"                               { "Allows flying in survival mode" }
                "Antiknockback"                        { "Reduces knockback received from hits" }
                "NoKnockback"                          { "Completely removes all knockback" }
                "JumpReset"                            { "Resets sprint mid-air for W-tap advantage" }
                "SprintReset"                          { "Resets sprint to boost hit reach" }
                "NoJumpDelay"                          { "Removes delay between jumps" }
                "Scaffold"                             { "Auto-places blocks under player while moving" }
                "Tower"                                { "Rapidly towers upward with blocks" }
                "Jesus"                                { "Allows walking on water surfaces" }
                "Dolphin"                              { "Speeds through water abnormally" }
                "BoatFly"                              { "Flies using a boat entity" }
                "ElytraFly"                            { "Elytra flight speed/control hack" }
                "Phase"                                { "Phases through solid blocks" }
                "Clip"                                 { "Clips through walls or terrain" }
                "NoFall"                               { "Prevents fall damage entirely" }
                "NoSlow"                               { "Removes slowdown from items/terrain" }
                "Timer"                                { "Speeds up or slows down game tick rate" }
                "Strafe"                               { "Auto-strafes around targets during combat" }
                "LegitScaffold"                        { "Scaffold that mimics legit player movement" }
                "FastBridge"                           { "Places bridge blocks faster than normal" }
                "AutoTotem"                            { "Auto-moves totem to offhand before death" }
                "AutoArmor"                            { "Automatically equips best available armor" }
                "AutoPot"                              { "Auto-throws splash potions in combat" }
                "AutoDoubleHand"                       { "Manages both hands automatically in combat" }
                "InventoryTotem"                       { "Uses totem from inventory slot" }
                "TotemHit"                             { "Activates totem on hit rather than on death" }
                "PopSwitch"                            { "Switches totem after it pops" }
                "LagReach"                             { "Exploits lag to extend reach" }
                "Wtap"                                 { "W-tap automation for hit distance advantage" }
                "FakeLag"                              { "Simulates lag to desync from server" }
                "Blink"                                { "Holds packets then releases for teleport effect" }
                "PacketFly"                            { "Flies by manipulating movement packets" }
                "BlockESP"                             { "Highlights hidden blocks through terrain" }
                "Freecam"                              { "Detaches camera from player body" }
                "PackSpoof"                            { "Spoofs resource pack to other players" }
                "PingSpoof"                            { "Fakes displayed ping value" }
                "FakeNick"                             { "Disguises player name for others" }
                "FakeItem"                             { "Makes items appear different to others" }
                "ESP"                                  { "Entity/player wallhack overlay" }
                "Tracers"                              { "Draws lines to nearby players/entities" }
                "ChestESP"                             { "Shows chest locations through walls" }
                "PlayerESP"                            { "Highlights players through walls" }
                "Wallhack"                             { "Renders entities through solid blocks" }
                "FullBright"                           { "Removes all darkness/lighting effects" }
                "XRay"                                 { "Makes stone transparent to reveal ores" }
                "FastPlace"                            { "Places blocks faster than the game allows" }
                "ChestSteal"                           { "Instantly steals all items from containers" }
                "Refill"                               { "Auto-refills hotbar items from inventory" }
                "AutoEat"                              { "Automatically eats food when hungry" }
                "AutoMine"                             { "Automatically mines blocks" }
                "AutoClicker"                          { "Clicks faster than humanly possible" }
                "FastXP"                               { "Collects XP orbs at abnormal speed" }
                "Nuker"                                { "Destroys large areas of blocks instantly" }
                "AutoSign"                             { "Auto-fills sign text" }
                "AutoBuild"                            { "Automatically constructs structures" }
                "Printer"                              { "Places schematic blocks automatically" }
                "Asteria"                              { "Known cheat client: Asteria" }
                "Prestige"                             { "Known cheat client: Prestige" }
                "Xenon"                                { "Known cheat client: Xenon" }
                "Argon"                                { "Known cheat client: Argon" }
                "Hellion"                              { "Known cheat client: Hellion" }
                "Virgin"                               { "Known cheat client: Virgin" }
                "Donut"                                { "Known cheat client: Donut" }
                "Krypton"                              { "Known cheat client: Krypton" }
                "dev.krypton"                          { "Known cheat client package: dev.krypton" }
                "dev.gambleclient"                     { "Known cheat client package: dev.gambleclient" }
                "Grim"                                 { "Reference to Grim anticheat bypass code" }
                "PrestigeClient"                       { "Known cheat client: PrestigeClient" }
                "DoomsdayClient"                       { "Known cheat client: DoomsdayClient" }
                "198Macros"                            { "Known macro/cheat tool: 198Macros" }
                "Backdoor"                             { "Hidden remote access code detected" }
                "TokenGrabber"                         { "Discord/account token stealing code" }
                "Stealer"                              { "Credential/data stealing code" }
                "chainlibs"                            { "Known obfuscated cheat library package" }
                "phantom-refmap"                       { "Refmap name used by known cheat clients" }
                "xyz.greaj"                            { "Known cheat developer package: xyz.greaj" }
                "jnativehook"                          { "Native keyboard/mouse hook library (input capture)" }
                "imgui"                                { "ImGui UI library, common in injected cheat overlays" }
                "KeyboardMixin"                        { "Suspicious keyboard input mixin" }
                "ClientPlayerInteractionManagerMixin"  { "Suspicious player interaction override mixin" }
                "LicenseCheckMixin"                    { "License check mixin, typical in paid cheats" }
                "Japanese obfuscation"                 { "Japanese character class names used to obfuscate code" }
                default                                { "Suspicious string matched in JAR contents" }
            }
            Write-Host "             " -NoNewline
            Write-Host " $p " -NoNewline -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "  $explanation" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# ── VERDICT ───────────────────────────────────────────────────
Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
Write-Host ""

if ($suspicious.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " SUSPICIOUS MODS DETECTED " -ForegroundColor Black -BackgroundColor Red
    Write-Host ""
    foreach ($m in $suspicious) {
        Write-Host "  '$($m.File)' contains the following suspicious strings:" -ForegroundColor Red
        foreach ($p in $m.Patterns) {
            Write-Host "    - $p" -ForegroundColor DarkRed
        }
        Write-Host ""
    }
} elseif ($unknown.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " UNIDENTIFIED CHEESE " -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host ""
    foreach ($m in $unknown) {
        Write-Host "  '$($m.File)' was not found in any database." -ForegroundColor Yellow
        Write-Host "  No cheat patterns were detected, but it cannot be verified as safe." -ForegroundColor DarkYellow
    }
    Write-Host ""
    Write-Host "  Download mods only from CurseForge or Modrinth when possible." -ForegroundColor DarkGray
} else {
    Write-Host "  " -NoNewline
    Write-Host " ALL MODS CLEAN " -ForegroundColor Black -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "  All $($verified.Count) mod(s) verified. No suspicious patterns detected." -ForegroundColor Green
}

Write-Host ""
Write-Host ("  " + "~" * 62) -ForegroundColor DarkYellow
Write-Host ""
Read-Host "  Press Enter to exit"
