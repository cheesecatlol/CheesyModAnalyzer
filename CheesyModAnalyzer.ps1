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

    $L1  = "  ██████╗██╗  ██╗███████╗███████╗███████╗██╗   ██╗  ███╗   ███╗ ██████╗ ██████╗ "
    $L2  = " ██╔════╝██║  ██║██╔════╝██╔════╝██╔════╝╚██╗ ██╔╝  ████╗ ████║██╔═══██╗██╔══██╗"
    $L3  = " ██║     ███████║█████╗  █████╗  ███████╗ ╚████╔╝   ██╔████╔██║██║   ██║██║  ██║"
    $L4  = " ██║     ██╔══██║██╔══╝  ██╔══╝  ╚════██║  ╚██╔╝    ██║╚██╔╝██║██║   ██║██║  ██║"
    $L5  = " ╚██████╗██║  ██║███████╗███████╗███████║   ██║     ██║ ╚═╝ ██║╚██████╔╝██████╔╝"
    $L6  = "  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ "
    $L7  = "   █████╗ ███╗   ██╗ █████╗ ██╗   ██╗   ██╗███████╗███████╗██████╗  "
    $L8  = "  ██╔══██╗████╗  ██║██╔══██╗██║   ╚██╗ ██╔╝╚══███╔╝██╔════╝██╔══██╗ "
    $L9  = "  ███████║██╔██╗ ██║███████║██║    ╚████╔╝   ███╔╝ █████╗  ██████╔╝ "
    $L10 = "  ██╔══██║██║╚██╗██║██╔══██║██║     ╚██╔╝   ███╔╝  ██╔══╝  ██╔══██╗ "
    $L11 = "  ██║  ██║██║ ╚████║██║  ██║███████╗ ██║   ███████╗███████╗██║  ██║ "
    $L12 = "  ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝ ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝ "

    $cheese = @(
        "                        .::::. ",
        "                      .:  o   :.",
        "                     :  o   o  :",
        "                    :___________:"
    )

    foreach ($line in @($L1,$L2,$L3,$L4,$L5,$L6)) {
        Write-Host $line -ForegroundColor Yellow
        Start-Sleep -Milliseconds 18
    }
    Write-Host ""
    foreach ($line in @($L7,$L8,$L9,$L10,$L11,$L12)) {
        Write-Host $line -ForegroundColor DarkYellow
        Start-Sleep -Milliseconds 18
    }
    Write-Host ""
    foreach ($line in $cheese) {
        Write-Host $line -ForegroundColor Yellow
        Start-Sleep -Milliseconds 30
    }

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
    # Combat
    "AimAssist","AutoCrystal","AutoHitCrystal","TriggerBot","Velocity","Criticals",
    "Reach","Hitboxes","ShieldBreaker","ShieldDisabler","AxeSpam","KillAura",
    "BowAimbot","CrystalAura","SurroundBreaker","HoleSnap","BedAura",
    "MultiAura","ForceField","Aimbot","AntiBot","Regen","AntiAntiCheat",
    "ClickAura","Derp","HeadRoll","LongJump",
    # Movement
    "Flight","Antiknockback","NoKnockback","JumpReset","SprintReset","NoJumpDelay",
    "Scaffold","Tower","Jesus","Dolphin","BoatFly","ElytraFly","Phase","Clip",
    "NoFall","NoSlow","Timer","Strafe","LegitScaffold","FastBridge",
    "Glide","Spider","WallClimb","Bhop","BunnyHop","AirJump",
    "FastLadder","NoWeb","IceSpeed","SafeWalk","EdgeSnap",
    # Automation
    "AutoTotem","AutoArmor","AutoPot","AutoDoubleHand","InventoryTotem","TotemHit",
    "PopSwitch","LagReach","Wtap","FakeLag","Blink","PacketFly",
    "AutoFish","AutoSprint","AutoRespawn","AutoTool","AutoSword","AutoBow",
    "AutoDrop","AutoFarm","AutoWalk","AutoSneak",
    # Visual / ESP
    "BlockESP","Freecam","PackSpoof","PingSpoof","FakeNick","FakeItem",
    "ESP","Tracers","ChestESP","PlayerESP","Wallhack","FullBright","XRay",
    "StorageESP","MobESP","ItemESP","HoleESP","ArmorESP","HealthTags",
    "CaveFinder","NameTags","Nametags",
    # World
    "FastPlace","ChestSteal","Refill","AutoEat","AutoMine","AutoClicker","FastXP",
    "Nuker","AutoSign","AutoBuild","Printer","InvMove","InventoryMove",
    "NoRender","AntiHunger","NameProtect",
    # Known clients / packages
    "Asteria","Prestige","Xenon","Argon","Hellion","Virgin","Donut","Krypton",
    "dev.krypton","dev.gambleclient","PrestigeClient","DoomsdayClient",
    "Wurst","Sigma","LiquidBounce","Meteor","Ares","Salhack",
    "Nodus","Flux","Entropy","Impact","Wolfram","Future",
    "Aristois","Vape","Freezer","Drip","Tenacity","Clamour",
    # Malicious / backdoor
    "198Macros","Backdoor","TokenGrabber","Stealer","Keylogger",
    "sendWebhook","grabToken","stealToken","getPassword",
    "discord/webhook","webhooks/",
    # Obfuscation / injection libraries
    "chainlibs","phantom-refmap","xyz.greaj","jnativehook","imgui",
    "KeyboardMixin","ClientPlayerInteractionManagerMixin","LicenseCheckMixin",
    "Allatori","ZKM","Stringer","Branchlock","Caesium",
    "me/zero/client","me/rigamortis","net/ccbluex","io/github/nevalackin",
    # Crystal / Anchor
    "autocrystal","auto crystal","cw crystal","dontPlaceCrystal","dontBreakCrystal",
    "canPlaceCrystalServer","healPotSlot","autoCrystalPlaceClock",
    "AutoAnchor","autoanchor","auto anchor","DoubleAnchor","HasAnchor",
    "anchortweaks","anchor macro","safe anchor","safeanchor","SafeAnchor","AirAnchor",
    "anchorMacro","LWFH Crystal","AutoBreach","NoBounce","EndCrystalItemMixin",
    # Totem / Pot / Armor
    "autototem","auto totem","inventorytotem","HoverTotem","hover totem","legittotem",
    "autopot","auto pot","speedPotSlot","strengthPotSlot","autoarmor","auto armor",
    "AutoPotRefill","AutoMace","MaceSwap","SpearSwap","StunSlam",
    # Shield
    "preventSwordBlockBreaking","preventSwordBlockAttack",
    "Breaking shield with axe...","ShieldDisabler",
    # Aim / Rotations
    "aimassist","aim assist","triggerbot","trigger bot",
    "SilentRotations","Silent Rotations","SmoothRotations","Smooth Rotations",
    "Rotation Speed","Use Easing","Easing Strength",
    # Lag / Spoof
    "pingspoof","ping spoof","FakeLag","fakePunch","Fake Punch","FakeInv","swapBackToOriginalSlot",
    # Web
    "webmacro","web macro","AntiWeb","AutoWeb","Places Webs On Enemies",
    # Misc cheat features
    "AutoDoubleHand","autodoublehand","auto double hand",
    "AutoClicker","AutoFirework","ElytraSwap","ElytraSwap","FastXP","FastExp",
    "PackSpoof","Antiknockback","catlean","AuthBypass","obfuscatedAuth",
    "BaseFinder","invsee","ItemExploit","FreezePlayer","KeyPearl","LootYeeter",
    "setBlockBreakingCooldown","getBlockBreakingCooldown","blockBreakingCooldown",
    "onBlockBreaking","setItemUseCooldown","setSelectedSlot",
    "invokeDoAttack","invokeDoItemUse","invokeOnMouseButton",
    "onPushOutOfBlocks","onIsGlowing","findKnockbackSword","attackRegisteredThisClick",
    "axespam","axe spam","selfdestruct","self destruct",
    "lvstrng","dqrkis","Dqrkis Client","POT_CHEATS","arrayOfString",
    "WalksyCrystalOptimizerMod","WalksyOptimizer","WalskyOptimizer","autoCrystalPlaceClock",
    "Automatically switches to sword when hitting with totem",
    "Failed to switch to mace after axe!",
    # Config-style option strings (used inside cheat GUIs)
    "Place Delay","Break Delay","Fast Mode","Place Chance","Break Chance",
    "Stop On Kill","Damage Tick","damagetick","Anti Weakness","Particle Chance",
    "Trigger Key","Switch Delay","Totem Slot","Glowstone Delay","Glowstone Chance",
    "Explode Delay","Explode Chance","Explode Slot","Only Charge","Reach Distance",
    "Min Height","Min Fall Speed","Attack Delay","Breach Delay","Require Elytra",
    "Activate Key","Click Simulation","On RMB","No Count Glitch",
    "No Bounce","Place blocks faster","Anchor Macro",
    # Fullwidth obfuscated variants
    "ＡｕｔｏＣｒｙｓｔａｌ","Ａｕｔｏ Ｃｒｙｓｔａｌ","ＡｕｔｏＨｉｔＣｒｙｓｔａｌ",
    "ＡｕｔｏＡｎｃｈｏｒ","Ａｕｔｏ Ａｎｃｈｏｒ","ＤｏｕｂｌｅＡｎｃｈｏｒ","Ｄｏｕｂｌｅ Ａｎｃｈｏｒ",
    "ＳａｆｅＡｎｃｈｏｒ","Ｓａｆｅ Ａｎｃｈｏｒ","Ａｎｃｈｏｒ Ｍａｃｒｏ",
    "ＡｕｔｏＴｏｔｅｍ","Ａｕｔｏ Ｔｏｔｅｍ","ＨｏｖｅｒＴｏｔｅｍ","Ｈｏｖｅｒ Ｔｏｔｅｍ",
    "ＩｎｖｅｎｔｏｒｙＴｏｔｅｍ","Ａｕｔｏ Ｉｎｖｅｎｔｏｒｙ Ｔｏｔｅｍ","Ａｕｔｏ Ｔｏｔｅｍ Ｈｉｔ",
    "ＡｕｔｏＰｏｔ","Ａｕｔｏ Ｐｏｔ","Ａｕｔｏ Ｐｏｔ Ｒｅｆｉｌｌ","ＡｕｔｏＡｒｍｏｒ","Ａｕｔｏ Ａｒｍｏｒ",
    "ＳｈｉｅｌｄＤｉｓａｂｌｅｒ","Ｓｈｉｅｌｄ Ｄｉｓａｂｌｅｒ",
    "ＡｕｔｏＤｏｕｂｌｅＨａｎｄ","Ａｕｔｏ Ｄｏｕｂｌｅ Ｈａｎｄ","ＡｕｔｏＣｌｉｃｋｅｒ",
    "ＡｕｔｏＭａｃｅ","Ａｕｔｏ Ｍａｃｅ","ＭａｃｅＳｗａｐ","Ｍａｃｅ Ｓｗａｐ","Ｓｐｅａｒ Ｓｗａｐ",
    "Ａｕｔｏｍａｔｉｃａｌｌｙ ａｘｅ ａｎｄ ｍａｃｅ ｓｈｉｅｌｄｅｄ ｐｌａｙｅｒｓ","Ｓｔｕｎ Ｓｌａｍ",
    "ＡｉｍＡｓｓｉｓｔ","Ａｉｍ Ａｓｓｉｓｔ","ＴｒｉｇｇｅｒＢｏｔ","Ｔｒｉｇｇｅｒ Ｂｏｔ",
    "Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ","Ｓｍｏｏｔｈ Ｒｏｔａｔｉｏｎｓ",
    "ＦａｋｅＬａｇ","Ｆａｋｅ Ｌａｇ","Ｆａｋｅ Ｐｕｎｃｈ",
    "Ａｎｔｉ Ｗｅｂ","ＡｕｔｏＷｅｂ","Ｐｌａｃｅｓ Ｗｅｂｓ Ｏｎ Ｅｎｅｍｉｅｓ",
    "Ｗａｌｋｓｙ Ｏｐｔｉｍｉｚｅｒ","ＥｌｙｔｒａＳｗａｐ","Ｅｌｙｔｒａ Ｓｗａｐ",
    "Ｆｒｅｅｃａｍ","Ｍｏｖｅ ｆｒｅｅｌｙ ｔｈｒｏｕｇｈ ｗａｌｌｓ","Ｎｏ Ｃｌｉｐ","Ｆｒｅｅｚｅ Ｐｌａｙｅｒ",
    "ＬＷＦＨ Ｃｒｙｓｔａｌ","ＫｅｙＰｅａｒｌ","Ｋｅｙ Ｐｅａｒｌ","Ｌｏｏｔ Ｙｅｅｔｅｒ",
    "Ｆａｓｔ Ｐｌａｃｅ","Ｐｌａｃｅ ｂｌｏｃｋｓ ｆａｓｔｅｒ","Ａｕｔｏ Ｂｒｅａｃｈ",
    "Ｄａｍａｇｅ Ｔｉｃｋ","Ａｎｔｉ Ｗｅａｋｎｅｓｓ","Ｐａｒｔｉｃｌｅ Ｃｈａｎｃｅ",
    "Ｔｒｉｇｇｅｒ Ｋｅｙ","Ｓｗｉｔｃｈ Ｄｅｌａｙ","Ｔｏｔｅｍ Ｓｌｏｔ",
    "Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ","Ｓｍｏｏｔｈ Ｒｏｔａｔｉｏｎｓ","Ｒｏｔａｔｉｏｎ Ｓｐｅｅｄ",
    "Ｕｓｅ Ｅａｓｉｎｇ","Ｅａｓｉｎｇ Ｓｔｒｅｎｇｔｈ","Ｗｈｉｌｅ Ｕｓｅ","Ｓｔｏｐ ｏｎ Ｋｉｌｌ",
    "Ｃｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ","Ｇｌｏｗｓｔｏｎｅ Ｄｅｌａｙ","Ｇｌｏｗｓｔｏｎｅ Ｃｈａｎｃｅ",
    "Ｅｘｐｌｏｄｅ Ｄｅｌａｙ","Ｅｘｐｌｏｄｅ Ｃｈａｎｃｅ","Ｅｘｐｌｏｄｅ Ｓｌｏｔ","Ｏｎｌｙ Ｃｈａｒｇｅ",
    "Ａｎｃｈｏｒ Ｍａｃｒｏ","Ｒｅａｃｈ Ｄｉｓｔａｎｃｅ","Ｍｉｎ Ｈｅｉｇｈｔ","Ｍｉｎ Ｆａｌｌ Ｓｐｅｅｄ",
    "Ａｔｔａｃｋ Ｄｅｌａｙ","Ｂｒｅａｃｈ Ｄｅｌａｙ","Ｒｅｑｕｉｒｅ Ｅｌｙｔｒａ",
    "Ａｃｔｉｖａｔｅ Ｋｅｙ","Ｃｌｉｃｋ Ｓｉｍｕｌａｔｉｏｎ","Ｏｎ ＲＭＢ","Ｎｏ Ｃｏｕｎｔ Ｇｌｉｔｃｈ",
    "Ｎｏ Ｂｏｕｎｃｅ","ＮｏＢｏｕｎｃｅ","Ｒｅｍｏｖｅｓ ｔｈｅ ｃｒｙｓｔａｌ ｂｏｕｎｃｅ ａｎｉｍａｔｉｏｎ",
    "Ｐｌａｃｅ Ｄｅｌａｙ","Ｂｒｅａｋ Ｄｅｌａｙ","Ｆａｓｔ Ｍｏｄｅ","Ｐｌａｃｅ Ｃｈａｎｃｅ","Ｂｒｅａｋ Ｃｈａｎｃｅ",
    "Ｓｔｏｐ Ｏｎ Ｋｉｌｌ","Ｄｑｒｋｉｓ Ｃｌｉｅｎｔ"
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
        if (Test-Path -LiteralPath $FilePath) {
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
    $found = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    # helpers
    function Add-Flag([string]$flag) { [void]$found.Add($flag.Trim()) }

    try {
        $zip     = [System.IO.Compression.ZipFile]::OpenRead($FilePath)
        $entries = $zip.Entries

        # ── collect all class paths for structural analysis ──────
        $classPaths   = $entries | Where-Object { $_.FullName -like "*.class" } | ForEach-Object { $_.FullName }
        $totalClasses = $classPaths.Count

        # ── 1. SHORT PATH OBFUSCATION ────────────────────────────
        # Detects a/b/Foo.class  or  a/b/c/d/Foo.class style hiding
        $shortPathCount = ($classPaths | Where-Object {
            $parts = $_.Split('/')
            # 2-5 path segments where every directory segment is 1-2 chars
            $parts.Count -ge 3 -and $parts.Count -le 6 -and
            ($parts[0..($parts.Count-2)] | Where-Object { $_.Length -gt 2 }).Count -eq 0
        }).Count
        if ($totalClasses -gt 10 -and $shortPathCount / [Math]::Max($totalClasses,1) -gt 0.4) {
            Add-Flag "Short-path obfuscation (a/b/c/ structure)"
        }

        # ── 2. HIGH RATIO OF SINGLE-CHAR CLASS NAMES ────────────
        $singleCharClasses = ($classPaths | Where-Object {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($_)
            $name.Length -le 2
        }).Count
        if ($totalClasses -gt 10 -and $singleCharClasses / [Math]::Max($totalClasses,1) -gt 0.5) {
            Add-Flag "Single-char class names (heavy obfuscation)"
        }

        # ── 3. NESTED JAR / CLASS INSIDE JAR ────────────────────
        $nestedJars = $entries | Where-Object { $_.FullName -like "*.jar" -and $_.FullName -notlike "META-INF/*" }
        foreach ($nj in $nestedJars) {
            Add-Flag "Nested JAR: $($nj.FullName)"
        }

        # ── 4. SUSPICIOUS PACKAGE ROOTS ─────────────────────────
        $suspiciousRoots = @("me/zero","me/alpha","io/github/nevalackin","wtf/zroger",
            "me/rigamortis","net/ccbluex","me/hwnd","xyz/qalcyo","me/odinaka",
            "dev/luna","me/stars","wtf/harvest","gg/essential/loader/stage0")
        foreach ($entry in $entries) {
            foreach ($root in $suspiciousRoots) {
                if ($entry.FullName -like "$root/*") { Add-Flag "Suspicious package: $root" }
            }
        }

        # ── 5. PER-ENTRY PATTERN + OBFUSCATION SCAN ─────────────
        foreach ($entry in $entries) {
            $name = $entry.FullName

            # known string patterns in file paths
            foreach ($p in $SuspiciousPatterns) {
                if ($name -match [regex]::Escape($p)) { Add-Flag $p }
            }

            # Japanese/Chinese obfuscation in class names
            if ($JapaneseRegex.IsMatch($name)) { Add-Flag "Japanese obfuscation" }
            if ([regex]::IsMatch($name, "[\u4E00-\u9FFF]")) { Add-Flag "Chinese obfuscation" }

            # ── 6. READ TEXT FILES FOR STRING MATCHES ───────────
            $ext = [System.IO.Path]::GetExtension($name).ToLower()
            if (($ext -in @(".json",".txt",".toml",".cfg",".properties")) -or ($name -match "MANIFEST\.MF")) {
                if ($entry.Length -lt 2MB) {
                    try {
                        $stream = $entry.Open()
                        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8, $true)
                        $text   = $reader.ReadToEnd()
                        $reader.Close(); $stream.Close()

                        foreach ($p in $SuspiciousPatterns) {
                            if ($text -match [regex]::Escape($p)) { Add-Flag $p }
                        }
                        if ($JapaneseRegex.IsMatch($text))                         { Add-Flag "Japanese obfuscation" }
                        if ([regex]::IsMatch($text, "[\u4E00-\u9FFF]"))            { Add-Flag "Chinese obfuscation" }

                        # ── 7. SUSPICIOUS URLS IN CONFIG/MANIFEST ───────────
                        $suspiciousUrlPatterns = @(
                            "cdn\.discordapp\.com","anonfiles\.com","gofile\.io",
                            "transfer\.sh","file\.io","temp\.sh","pastecord\.com",
                            "hastebin\.com","paste\.gg","api\.myip","checkip\.",
                            "ipinfo\.io","ipapi\.co"
                        )
                        foreach ($urlPat in $suspiciousUrlPatterns) {
                            if ($text -match $urlPat) { Add-Flag "Suspicious URL in config: $urlPat" }
                        }

                        # ── 8. LICENSE / HWID CHECK STRINGS ─────────────────
                        $licenseStrings = @("hwid","HWID","hardware.id","LicenseKey",
                            "licensecheck","validateLicense","checkLicense","activation")
                        foreach ($ls in $licenseStrings) {
                            if ($text -match [regex]::Escape($ls)) { Add-Flag "License/HWID check detected" ; break }
                        }

                    } catch {}
                }
            }

            # ── 9. SCAN CLASS BYTECODE FOR STRINGS ──────────────
            if ($ext -eq ".class" -and $entry.Length -lt 512KB) {
                try {
                    $stream  = $entry.Open()
                    $ms      = [System.IO.MemoryStream]::new()
                    $stream.CopyTo($ms)
                    $stream.Close()
                    $bytes   = $ms.ToArray()
                    $ms.Dispose()

                    # extract readable ASCII strings from bytecode (len >= 5)
                    $ascii  = [System.Text.Encoding]::ASCII.GetString($bytes)

                    foreach ($p in $SuspiciousPatterns) {
                        if ($ascii -match [regex]::Escape($p)) { Add-Flag $p }
                    }

                    # runtime exec / reflection abuse
                    if ($ascii -match "Runtime\.exec|ProcessBuilder|cmd\.exe|/bin/sh") {
                        Add-Flag "Runtime command execution"
                    }
                    if ($ascii -match "Class\.forName|getDeclaredMethod|setAccessible") {
                        Add-Flag "Suspicious reflection usage"
                    }
                    # network calls inside class
                    if ($ascii -match "HttpURLConnection|OkHttpClient|URLConnection" -and
                        $ascii -notmatch "modrinth|curseforge|fabricmc|quiltmc") {
                        Add-Flag "Unexpected network call in class"
                    }
                } catch {}
            }
        }

        $zip.Dispose()
    } catch {
        Write-Host ""
        Write-Host "    [WARN] Could not open JAR: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
    return ($found | Select-Object -Unique)
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

# ── Detect the ONE active Minecraft instance from the running java process ──
$autoFolder = $null
$autoLabel  = $null

if ($procs) {
    foreach ($proc in $procs) {
        try {
            $wmi     = Get-WmiObject Win32_Process -Filter "ProcessId=$($proc.Id)" -ErrorAction SilentlyContinue
            $cmdLine = if ($wmi) { $wmi.CommandLine } else { "" }

            if ($cmdLine) {
                # Strategy 1: --gameDir "C:\path\to\instance" or --gameDir C:\path
                $m = [regex]::Match($cmdLine, '--gameDir\s+"([^"]+)"')
                if (-not $m.Success) {
                    $m = [regex]::Match($cmdLine, '--gameDir\s+(\S+)')
                }
                if ($m.Success) {
                    $gameDir   = $m.Groups[1].Value.TrimEnd('\')
                    $candidate = Join-Path $gameDir "mods"
                    if (Test-Path $candidate) {
                        $autoFolder = $candidate
                        # Derive a friendly name from the folder path
                        $autoLabel  = Split-Path (Split-Path $gameDir -Parent) -Leaf
                        if ([string]::IsNullOrWhiteSpace($autoLabel) -or $autoLabel -eq "instances") {
                            $autoLabel = Split-Path $gameDir -Leaf
                        }
                    }
                }

                # Strategy 2: -Dminecraft.appDir=...  (some launchers use this)
                if (-not $autoFolder) {
                    $m2 = [regex]::Match($cmdLine, '-Dminecraft\.appDir=([^\s"]+)')
                    if ($m2.Success) {
                        $gameDir   = $m2.Groups[1].Value.Trim('"').TrimEnd('\')
                        $candidate = Join-Path $gameDir "mods"
                        if (Test-Path $candidate) {
                            $autoFolder = $candidate
                            $autoLabel  = Split-Path $gameDir -Leaf
                        }
                    }
                }
            }
        } catch {}
        if ($autoFolder) { break }
    }
}

# ── Display & selection ────────────────────────────────────────
if ($autoFolder) {
    Write-Host "  " -NoNewline
    Write-Host " ACTIVE INSTANCE DETECTED " -ForegroundColor Black -BackgroundColor Yellow
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " >> " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host "  $autoLabel" -NoNewline -ForegroundColor Yellow
    Write-Host "  " -NoNewline
    Write-Host $autoFolder -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press " -NoNewline -ForegroundColor DarkGray
    Write-Host "Enter" -NoNewline -ForegroundColor Yellow
    Write-Host " to scan this instance, or type a custom path to override:" -ForegroundColor DarkGray
    Write-Host ""
    $userInput = Read-Host "  Choice"

    if ([string]::IsNullOrWhiteSpace($userInput)) {
        $modsPath = $autoFolder
    } else {
        $modsPath = $userInput.Trim()
    }
} else {
    # Minecraft not running or gameDir not found in command line
    if ($procs) {
        Write-Host "  " -NoNewline
        Write-Host " Minecraft is running but the instance path could not be detected. " -ForegroundColor Black -BackgroundColor DarkYellow
        Write-Host ""
    } else {
        Write-Host "  " -NoNewline
        Write-Host " Minecraft is not running. " -ForegroundColor Black -BackgroundColor DarkGray
        Write-Host ""
    }
    Write-Host "  Enter the path to your mods folder:" -ForegroundColor DarkGray
    Write-Host ""
    $userInput = Read-Host "  Path"
    $modsPath  = $userInput.Trim()
}

if (-not (Test-Path $modsPath)) {
    Write-Host ""
    Write-Host "  [ERROR] Folder not found: $modsPath" -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
}

$jarFiles = Get-ChildItem -Path $modsPath -File | Where-Object { $_.Name -like "*.jar" -or $_.Name -like "*.jar.disabled" }
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

    # Skip disabled mods
    if ($jar.Name -like "*.jar.disabled") {
        $displayName = $jar.Name -replace '\.disabled$', ''
        Write-Host "  [" -NoNewline -ForegroundColor DarkYellow
        Write-Host " DISABLED " -NoNewline -ForegroundColor Black -BackgroundColor DarkGray
        Write-Host "]  $displayName  (disabled)" -ForegroundColor DarkGray
        continue
    }

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
