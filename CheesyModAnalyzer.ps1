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
    # Combat — specific enough to be real signals
    "AimAssist","AutoCrystal","AutoHitCrystal","TriggerBot","KillAura",
    "BowAimbot","CrystalAura","SurroundBreaker","HoleSnap","BedAura",
    "MultiAura","ForceField","Aimbot","AntiAntiCheat",
    "ClickAura","ShieldBreaker","ShieldDisabler","AxeSpam",
    # Movement — specific cheat names only
    "Antiknockback","NoKnockback","JumpReset","SprintReset","NoJumpDelay",
    "LegitScaffold","BoatFly","Phase","Clip",
    "BunnyHop","Bhop","AirJump","WallClimb",
    # Automation — specific cheat automation
    "AutoTotem","AutoDoubleHand","InventoryTotem","TotemHit",
    "PopSwitch","LagReach","Wtap","FakeLag","Blink","PacketFly",
    # Visual / ESP
    "BlockESP","PackSpoof","PingSpoof","FakeNick","FakeItem",
    "PlayerESP","Wallhack","StorageESP","MobESP","ItemESP","HoleESP","ArmorESP",
    "HealthTags","NameTags","Nametags",
    # World
    "ChestSteal","AutoClicker","Nuker",
    "AutoSign","AutoBuild","Printer","InvMove","InventoryMove",
    "NoRender","AntiHunger","NameProtect",
    # Known clients / packages — only unambiguous names
    "dev.krypton","dev.gambleclient","PrestigeClient","DoomsdayClient",
    "net.wurstclient","wurstclient","wurst-client",
    "Sigma","LiquidBounce","Salhack",
    "Nodus","Wolfram",
    "VapeClient","VapeLite","IntentClient","intent.store",
    "riseclient","rise.today","meteordevelopment","liquidbounce",
    "fdp-client","net.ccbluex","novoware","novoclient","impactclient","azura",
    "pandaware","moonClient","astolfo","futureClient","konas","rusherhack","exhibition",
    "WolframClient","BleachHack","ThemisClient","ravenb","FluxClient","StrafeClient",
    # Malicious / backdoor
    "198Macros","Backdoor","TokenGrabber","Stealer","Keylogger",
    "sendWebhook","grabToken","stealToken","getPassword",
    "discord/webhook","webhooks/",
    "sessionstealer","webhookstealer","cookiethief","discordstealer",
    "iplogger","cryptominer","reverseShell","backdoormod","exploitmod","ratmod","ransomware",
    "exfiltrate","connectBack","callHome","stealSession","accountstealer",
    "discord/token","grabber/cookie","grab_cookies","stealerutils","sendToWebhook","postDiscord",
    "webhookurl","discordwebhook","ReverseShell","C2Server","StashFinder","TrailFinder",
    "SessionStealer","SelfDestruct","HideClient",
    "crasher","lagmachine","booksploit","signcrasher","entityspammer","worldnuker",
    "tntmod","bedexplode","anchorexplode","injectClass","modifyBytecode","hookMethod",
    "attachAgent","VirtualMachine.attach",
    "aHR0cDovL2FwaS5ub3ZhY2xpZW50LmxvbC93ZWJob29rLnR4dA==",
    # Obfuscation / injection libraries
    "chainlibs","phantom-refmap","xyz.greaj","jnativehook",
    "KeyboardMixin","ClientPlayerInteractionManagerMixin","LicenseCheckMixin",
    "Allatori","Stringer","Branchlock","Caesium",
    "me/zero/client","me/rigamortis","net/ccbluex","io/github/nevalackin",
    "FLOW_OBFUSCATION","STRING_ENCRYPTION","RESOURCE_ENCRYPTION",
    "skidfuscator","me/itzsomebody","radon/transform","bozar/","paramorphism","zelix/klassmaster",
    "dasho","com/icqm/smoke","dev.krypton","dev.gambleclient","com.cheatbreaker",
    "client-refmap.json","cheat-refmap.json",
    "imgui.binding","imgui.gl3","imgui.glfw","JNativeHook","GlobalScreen","NativeKeyListener",
    # Anticheat bypass / packet manipulation — specific bypass strings only
    "spoofVersion","brandOverride","overrideBrand","fakeClientBrand","brandSpoof","versionSpoof",
    "cancelPacket","dropPacket","suppressPacket","blockPacket","spoofPacket","injectPacket",
    "sendFakePacket","sendSilentPacket","bypassAC","bypass_ac","evadeAC","evadeAnticheat",
    "isGrimAC","isNoCheat","isAAC","isSpartanAC","isIntave","grimBypass","ncpBypass","aacBypass",
    "spartanBypass",
    "GrimBypass","NCPBypass","AACBypass","IntaveBypass","VulcanBypass","MatrixBypass",
    "WatchdogBypass","VerusDisabler","grim-api","setGrimFlag",
    "GrimVelocity","GrimDisabler","VelocitySpoof","KBReduce",
    "PacketMine","PacketWalk","PacketSneak","PacketCancel","PacketDupe","PacketSpam",
    # Hitbox / velocity / rotation manipulation — specific cheat method names
    "setTimerSpeed","timerSpeed","Timer.timerSpeed","setTickRate","overrideTickRate",
    "fakeTickCount","tickBoost","hitboxExpand","expandHitbox",
    "suppressKnockback","cancelKnockback","noKnockback","setVelocity(0","zeroVelocity",
    "ignoreKnockback","antiKnockback","KnockbackModifier","noVelocity",
    "fakeYaw","fakePitch","spoofYaw","spoofPitch","rotationBypass",
    "renderPlayerSpoofed","spoofRender","hideFromRender",
    "fakeGlowing","GlowBypass","glowBypass","baritone.bypass","pathfindBypass",
    "bypassLicense","fakeAuth","spoofSession","AltManager",
    # Additional combat hacks
    "LegitAura","AimBot","AutoAim","SilentAim",
    "AimLock","HeadSnap","AnchorAura","AnchorFill","AnchorPlace",
    "AutoBed","BedBomb","BedPlace","BowAimbot","BowSpam",
    "CritBypass","AlwaysCrit",
    "ReachHack","ExtendReach","LongReach","HitboxExpand","AntiKB",
    "OffhandTotem","TotemSwitch","AutoWeapon","AutoCity","Burrow","SelfTrap",
    "HoleFiller","AntiSurround","AntiBurrow","WTap","TargetStrafe","AutoGap","AutoPearl",
    "FlyHack","CreativeFlight","PacketFly","SpeedHack",
    "StepHack","FastClimb","HighStep",
    "WaterWalk","LiquidWalk","LavaWalk","NoSlowdown","NoSoulSand",
    "InstantElytra","ScaffoldWalk","AutoBridge",
    "NukerLegit","InstantBreak","GhostHand","NoSwing","PlaceAssist","AirPlace","AutoPlace","InstantPlace",
    "NameTagsHack","XRayHack","OreFinder",
    "OreESP","NewChunks","TunnelFinder","TargetHUD","ReachDisplay",
    "DoubleClicker","JitterClick","ButterflyClick","CPSBoost",
    "InvManager","InvMovebypass","AntiAFK","FakeLatency","FakePing",
    "SpoofRotation","PositionSpoof","GameSpeed","SpeedTimer",
    "autocrystal","auto crystal","cw crystal","dontPlaceCrystal","dontBreakCrystal",
    "canPlaceCrystalServer","healPotSlot","autoCrystalPlaceClock",
    "AutoAnchor","autoanchor","auto anchor","DoubleAnchor",
    "anchortweaks","anchor macro","safe anchor","safeanchor","SafeAnchor","AirAnchor",
    "anchorMacro","LWFH Crystal","AutoBreach","NoBounce","EndCrystalItemMixin",
    # Totem / Pot / Armor — specific cheat strings
    "autototem","auto totem","inventorytotem","HoverTotem","hover totem","legittotem",
    "autopot","auto pot","speedPotSlot","strengthPotSlot","autoarmor","auto armor",
    "AutoPotRefill","AutoMace","MaceSwap","SpearSwap","StunSlam",
    # Shield
    "preventSwordBlockBreaking","preventSwordBlockAttack",
    "Breaking shield with axe...","ShieldDisabler",
    # Aim / Rotations
    "aimassist","aim assist","triggerbot","trigger bot",
    "SilentRotations","Silent Rotations",
    "Rotation Speed","Use Easing","Easing Strength",
    # Lag / Spoof
    "pingspoof","ping spoof","FakeLag","fakePunch","Fake Punch","FakeInv","swapBackToOriginalSlot",
    # Web
    "webmacro","web macro","AntiWeb","AutoWeb","Places Webs On Enemies",
    # Misc cheat features
    "AutoDoubleHand","autodoublehand","auto double hand",
    "AutoFirework","ElytraSwap","FastXP","FastExp",
    "PackSpoof","Antiknockback","catlean","AuthBypass","obfuscatedAuth",
    "BaseFinder","ItemExploit","FreezePlayer","KeyPearl","LootYeeter",
    "setBlockBreakingCooldown","getBlockBreakingCooldown","blockBreakingCooldown",
    "onBlockBreaking","invokeDoAttack","invokeDoItemUse","invokeOnMouseButton",
    "onPushOutOfBlocks","findKnockbackSword","attackRegisteredThisClick",
    "axespam","axe spam","selfdestruct","self destruct",
    "lvstrng","dqrkis","Dqrkis Client","POT_CHEATS",
    "WalksyCrystalOptimizerMod","WalksyOptimizer","WalskyOptimizer",
    "Automatically switches to sword when hitting with totem",
    "Failed to switch to mace after axe!",
    # Config-style option strings (very specific to cheat GUIs)
    "Stop On Kill","damagetick","Anti Weakness","Particle Chance",
    "Trigger Key","Switch Delay","Totem Slot","Glowstone Delay","Glowstone Chance",
    "Explode Delay","Explode Chance","Explode Slot","Only Charge",
    "No Count Glitch","No Bounce","Anchor Macro",
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

# Known cheat client filename tokens (matched against JAR filename)
$knownCheatFileTokens = @(
    "doomsday","doomsdayclient","dqrkis","dqrk",
    "vape","vapeclient","vape-client","vapelite",
    "meteor","meteorclient","meteor-client",
    "liquidbounce","liquid-bounce",
    "wurst","wurst-client",
    "futureclient","future-client",
    "konas","inertia","exhibition",
    "pandaware","astolfo","rusherhack",
    "novaclient","nova-client","novaware",
    "impactclient","aristois","azura",
    "intentclient","intentstore",
    "prestigeclient",
    "cheatbreaker","kamiblue","fdpclient",
    "skidfuscator","skidware",
    "wolframclient","wolfram-client",
    "bleachhack","bleach-hack",
    "themisclient","ravenb",
    "fluxclient","flux-client",
    "strafeclient","strafe-client"
)

# Deep cheat string list — scanned inside class bytecode and config files
# Only very specific strings that would ONLY appear in cheat code, not legitimate mods
$cheatStrings = @(
    # Crystal automation — very specific to cheat clients
    "AutoCrystal","autocrystal","auto crystal","cw crystal","dontPlaceCrystal","dontBreakCrystal",
    "AutoHitCrystal","autohitcrystal","canPlaceCrystalServer","healPotSlot","autoCrystalPlaceClock",
    "EndCrystalItemMixin","LWFH Crystal",
    # Anchor automation
    "AutoAnchor","autoanchor","auto anchor","DoubleAnchor",
    "anchortweaks","anchor macro","safe anchor","safeanchor","SafeAnchor","AirAnchor","anchorMacro",
    # Totem / pot cheats
    "AutoTotem","autototem","auto totem","InventoryTotem","inventorytotem","HoverTotem","hover totem","legittotem",
    "autopot","auto pot","speedPotSlot","strengthPotSlot","autoarmor","auto armor","AutoPotRefill",
    # Shield breaking
    "preventSwordBlockBreaking","preventSwordBlockAttack","ShieldDisabler","ShieldBreaker",
    "Breaking shield with axe...",
    # Mace / double hand
    "AutoDoubleHand","autodoublehand","auto double hand","Failed to switch to mace after axe!",
    "AutoMace","MaceSwap","SpearSwap","StunSlam",
    # Combat automation specifics
    "JumpReset","axespam","axe spam","findKnockbackSword","attackRegisteredThisClick",
    "AimAssist","aimassist","aim assist","triggerbot","trigger bot","SilentRotations","Silent Rotations",
    "FakeInv","swapBackToOriginalSlot","FakeLag","fakePunch","Fake Punch",
    # Known cheat tools
    "webmacro","web macro","AntiWeb","AutoWeb","lvstrng","dqrkis",
    "WalksyCrystalOptimizerMod","WalksyOptimizer","WalskyOptimizer",
    # Cheat automation
    "AutoFirework","ElytraSwap","NoJumpDelay",
    "PackSpoof","Antiknockback","catlean","AuthBypass","obfuscatedAuth","LicenseCheckMixin",
    "BaseFinder","ItemExploit","FreezePlayer","KeyPearl","LootYeeter","FastPlace","AutoBreach",
    "setBlockBreakingCooldown","getBlockBreakingCooldown","blockBreakingCooldown",
    "onBlockBreaking","invokeDoAttack","invokeDoItemUse","invokeOnMouseButton",
    "onPushOutOfBlocks","Automatically switches to sword when hitting with totem",
    "POT_CHEATS","Dqrkis Client",
    # Cheat GUI option strings — these are very specific to cheat config screens
    "Stop On Kill","damagetick","Particle Chance","Trigger Key",
    "Switch Delay","Totem Slot","Glowstone Delay","Glowstone Chance",
    "Explode Delay","Explode Chance","Explode Slot","Only Charge",
    "No Count Glitch","NoBounce","No Bounce","Anchor Macro",
    "Auto Inventory Totem","Strict One-Tick","Mace Priority","Min Totems","Min Pearls",
    "Totem First","Loot Yeeter","holdCrystal","stopOnKill","placeInterval","breakInterval",
    "activateOnRightClick",
    # Kill aura / combat cheats
    "KillAura","ClickAura","MultiAura","ForceField","LegitAura","SilentAim","AimLock",
    "CrystalAura","AnchorAura","BedAura","BedBomb","BedPlace","BowAimbot",
    "CritBypass","AlwaysCrit",
    "ReachHack","ExtendReach","LongReach","HitboxExpand","AntiKB",
    "OffhandTotem","TotemSwitch","AutoCity","SelfTrap",
    "HoleFiller","AntiSurround","AntiBurrow","WTap","TargetStrafe",
    "PacketFly","SpeedHack",
    "NameTagsHack","XRayHack",
    "ChestStealer","InvMovebypass",
    "GrimBypass","VulcanBypass","MatrixBypass","AACBypass","VerusDisabler","IntaveBypass","WatchdogBypass",
    "PacketMine","PacketWalk","PacketSneak","PacketCancel","PacketDupe","PacketSpam",
    "SelfDestruct","HideClient","SessionStealer","TokenLogger","TokenGrabber","DiscordToken",
    "ReverseShell","C2Server","KeyLogger","StashFinder","TrailFinder",
    # Libraries that only appear in cheats
    "imgui.binding","imgui.gl3","imgui.glfw","JNativeHook","GlobalScreen","NativeKeyListener",
    "client-refmap.json","cheat-refmap.json","phantom-refmap.json",
    "aHR0cDovL2FwaS5ub3ZhY2xpZW50LmxvbC93ZWJob29rLnR4dA==",
    # Cheat client packages
    "meteordevelopment","cc/novoline","com/alan/clients","club/maxstats","wtf/moonlight",
    "me/zeroeightsix/kami","net/ccbluex","today/opai","net/minecraft/injection",
    "org/chainlibs/module/impl/modules","xyz/greaj","com/cheatbreaker",
    "doomsdayclient","DoomsdayClient","doomsday.jar","novaclient","api.novaclient.lol",
    "vape.gg","vapeclient","VapeClient","VapeLite","intent.store","IntentClient",
    "rise.today","riseclient.com","meteor-client","meteorclient","meteordevelopment.meteorclient",
    "liquidbounce","fdp-client","net.ccbluex","novoware","novoclient","azura",
    "pandaware","moonClient","astolfo","futureClient","konas","rusherhack","exhibition",
    # Malware strings
    "sessionstealer","tokengrabber","webhookstealer","cookiethief","discordstealer","keylogger",
    "iplogger","cryptominer","reverseShell","backdoormod","exploitmod","ratmod","ransomware",
    "sendWebhook","exfiltrate","connectBack","callHome","grabToken","stealSession","accountstealer",
    "discord/token","grabber/cookie","grab_cookies","stealerutils","sendToWebhook","postDiscord",
    "webhookurl","discordwebhook",
    "crasher","lagmachine","booksploit","signcrasher","entityspammer","nukermod","worldnuker",
    "tntmod","bedexplode","anchorexplode","injectClass","modifyBytecode","hookMethod",
    "attachAgent","VirtualMachine.attach",
    # Obfuscation markers
    "FLOW_OBFUSCATION","STRING_ENCRYPTION","RESOURCE_ENCRYPTION",
    "skidfuscator","me/itzsomebody","radon/transform","bozar/","paramorphism","zelix/klassmaster",
    "allatori","dasho","com/icqm/smoke","dev.krypton","dev.gambleclient","com.cheatbreaker",
    # AC bypass
    "spoofVersion","brandOverride","overrideBrand","fakeClientBrand","brandSpoof","versionSpoof",
    "cancelPacket","dropPacket","suppressPacket","blockPacket","spoofPacket","injectPacket",
    "sendFakePacket","sendSilentPacket","bypassAC","bypass_ac","evadeAC","evadeAnticheat",
    "isGrimAC","isNoCheat","isAAC","isSpartanAC","isIntave","grimBypass","ncpBypass","aacBypass",
    "spartanBypass","GrimBypass","NCPBypass","AACBypass","IntaveBypass",
    "setTimerSpeed","timerSpeed","Timer.timerSpeed","setTickRate",
    "overrideTickRate","fakeTickCount","tickBoost","hitboxExpand","expandHitbox",
    "suppressKnockback","cancelKnockback","noKnockback","setVelocity(0","zeroVelocity","ignoreKnockback",
    "antiKnockback","KnockbackModifier","noVelocity",
    "renderPlayerSpoofed","spoofRender","hideFromRender",
    "fakeGlowing","GlowBypass","glowBypass","baritone.bypass","pathfindBypass","suppressPathfind",
    "bypassLicense","fakeAuth","spoofSession","AltManager","setGrimFlag","rotationBypass",
    "fakeYaw","fakePitch","spoofYaw","spoofPitch",
    # Fullwidth obfuscated variants
    "ＡｕｔｏＣｒｙｓｔａｌ","Ａｕｔｏ Ｃｒｙｓｔａｌ","ＡｕｔｏＨｉｔＣｒｙｓｔａｌ","ＡｕｔｏＡｎｃｈｏｒ","Ａｕｔｏ Ａｎｃｈｏｒ",
    "ＤｏｕｂｌｅＡｎｃｈｏｒ","ＳａｆｅＡｎｃｈｏｒ","Ｓａｆｅ Ａｎｃｈｏｒ","Ａｎｃｈｏｒ Ｍａｃｒｏ","ＡｕｔｏＴｏｔｅｍ",
    "Ａｕｔｏ Ｔｏｔｅｍ","ＨｏｖｅｒＴｏｔｅｍ","ＩｎｖｅｎｔｏｒｙＴｏｔｅｍ","ＡｕｔｏＰｏｔ","Ａｕｔｏ Ｐｏｔ",
    "ＡｕｔｏＡｒｍｏｒ","ＳｈｉｅｌｄＤｉｓａｂｌｅｒ","ＡｕｔｏＤｏｕｂｌｅＨａｎｄ","ＡｕｔｏＭａｃｅ","ＭａｃｅＳｗａｐ",
    "ＡｉｍＡｓｓｉｓｔ","ＴｒｉｇｇｅｒＢｏｔ","Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ","ＦａｋｅＬａｇ","Ｆａｋｅ Ｌａｇ",
    "ＬＷＦＨＣｒｙｓｔａｌ","ＬＷＦＨ Ｃｒｙｓｔａｌ","ＬｏｏｔＹｅｅｔｅｒ","Ｌｏｏｔ Ｙｅｅｔｅｒ","ＡｕｔｏＢｒｅａｃｈ","Ｆｒｅｅｚｅ Ｐｌａｙｅｒ"
)

# Context-only strings — only flagged when combined with other indicators
$contextOnlyStrings = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
@(
    "HttpClient","HttpURLConnection","openConnection","URLConnection",
    "getOutputStream","getInputStream","ProcessBuilder","powershell.exe",
    "Runtime.exec","cmd.exe"
) | ForEach-Object { [void]$contextOnlyStrings.Add($_) }

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

# ── Whitelisted JAR filename substrings (case-insensitive) ──────────────────
# Mods/clients known to contain strings that look suspicious but are legitimate.
# If a JAR filename contains any of these tokens, soft-flagging is suppressed
# and only hard indicators (malware, injectors, known cheat packages) are kept.
$whitelistedFileTokens = @(
    # Feather Client mods
    "feather","feathermc","feather-fabric","feather-forge",
    # Essential / Cosmetica ecosystem
    "essential","cosmetica","cosmetic","emotes","emotecraft",
    # Common performance / QoL mods that may reference AC or packet internals
    "sodium","lithium","phosphor","iris","indium","starlight",
    "ferritecore","memoryleakfix","smoothboot","lazydfu",
    "immediatelyfast","nvidium","modernfix","c2me",
    # Replay / debug mods with legitimate network code
    "replaymod","replay-mod","carpet","tweakeroo","itemscroller",
    # Fabric / Quilt ecosystem internals that ship inside modpacks
    "fabric-api","fabric_api","quilt-standard","quilted_fabric",
    "modmenu","cloth-config","cloth_config","yacl","yet-another-config",
    # Skin / rendering mods
    "skinsrestorer","customskinloader","skinport",
    # Legitimate totem / HUD mods (false-flag on totem strings)
    "totemic","totemguard",
    # FPS / optimization clients
    "lunar","badlion","blc","labymod","laby-mod"
)

# Strings that are ONLY flagged on non-whitelisted JARs
# (too broad / too common in legitimate mods to flag everywhere)
$whitelistSuppressedPatterns = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@(
    # Movement words used by dozens of legitimate QoL mods
    "AutoSprint","AutoSneak","AutoJump","AutoWalk","AutoRespawn","AutoFish",
    "AutoTool","AutoBow","AutoDrop","AutoFarm","AutoEat","AutoMine",
    "AutoSword","AutoStep","AutoBridge","AutoPearl","AutoGap",
    "NoFall","NoSlow","NoWeb","NoFallDamage","AntiFall",
    "FastBridge","Scaffold","Strafe","Freecam","FullBright",
    "CaveFinder","XRay","Tracers","ElytraSpeed","FastLadder",
    "FastPlace","Refill","FastXP","FastExp","Spider","Glide",
    "Flight","Tower","Jesus","Dolphin","Clip","Phase","SafeWalk",
    "EdgeSnap","IceSpeed","Bhop","BunnyHop","AirJump",
    "HighStep","FastClimb","WaterWalk","LiquidWalk","LavaWalk",
    # Overly generic single words that appear in tons of legitimate code
    "Timer","Velocity","Reach","Hitboxes","Regen","Criticals",
    "Derp","HeadRoll","LongJump","AntiBot","Impact","Entropy","Flux",
    "Future","Ares","Freezer","Drip","Tenacity","Clamour","Vape",
    "Asteria","Prestige","Xenon","Argon","Hellion","Virgin","Donut","Krypton",
    "Sigma","Meteor","Aristois","inertia","Refill",
    "WallHack","Wallhack","TargetHUD","ReachDisplay","NewChunks",
    "TunnelFinder","OreFinder","OreESP","Tracers","InvManager",
    "AntiAFK","FakeLatency","FakePing","SpoofRotation","PositionSpoof",
    "GameSpeed","SpeedTimer","InvMovebypass","ChestSteal",
    "AutoClicker","CriticalHit","AutoAim","AutoBow","AutoCrit","AutoSword",
    "AutoWeapon","AutoCity","Burrow","SelfTrap","HoleFiller","AntiSurround",
    "AntiBurrow","AutoBed","AirPlace","AutoPlace","InstantPlace","PlaceAssist",
    "GhostHand","NoSwing","InstantBreak","NukerLegit","ScaffoldWalk",
    "SpeedHack","FlyHack","CreativeFlight","StepHack","NoSlowdown","NoSoulSand",
    "InstantElytra","HeadSnap","AimLock","TargetStrafe","AnchorFill","AnchorPlace",
    "BedBomb","BedPlace","BowSpam","AlwaysCrit","LongReach","ExtendReach",
    "ReachHack","HitboxExpand","OffhandTotem","TotemSwitch","BoatFly",
    "CPSBoost","ButterflyClick","JitterClick","DoubleClicker",
    # Reflection / network patterns common in legitimate mods
    "setSelectedSlot","setItemUseCooldown","onIsGlowing",
    "HttpURLConnection","URLConnection","openConnection",
    "getDeclaredMethod","setAccessible","Class.forName",
    "Unexpected network call in class","Suspicious reflection usage",
    # AC-related strings used by legitimate anticheat-aware mods
    "noKnockback","cancelKnockback","suppressKnockback",
    "checkAnticheat","detectAnticheat","getAnticheat",
    "GrimAC","ac.grim","game.grim","imgui",
    # Generic config words used in any mod's settings
    "Place Delay","Break Delay","Fast Mode","Place Chance","Break Chance",
    "Damage Tick","Reach Distance","Min Height","Min Fall Speed",
    "Attack Delay","Breach Delay","Require Elytra","Activate Key",
    "Click Simulation","On RMB","Place blocks faster",
    "Smooth Rotations","SmoothRotations","arrayOfString",
    # Nametag strings are vanilla Minecraft rendering concepts used by many legit mods
    "NameTags","Nametags",
    # getPassword is standard Java API (KeyStore, audio devices, etc.)
    "getPassword",
    # KeyboardMixin is used by any mod with keybind handling (e.g. push-to-talk)
    "KeyboardMixin",
    # Blink is used in UI/animation code — only meaningful alongside other cheat flags
    "Blink",
    # ElytraFly is a vanilla player state name used in animation mods
    "ElytraFly",
    # ChestESP and Wurst are too short/generic and cause bytecode false positives
    "ChestESP","Wurst"
) | ForEach-Object { [void]$whitelistSuppressedPatterns.Add($_) }

# ── Helper: verify mod identity via metadata inside the JAR ─────────────────
# Returns $true only if the mod ID in fabric.mod.json or mods.toml matches a
# whitelisted token. Filename is intentionally NOT used — renaming a cheat JAR
# to "feather-fabric.jar" will NOT bypass this check.
function Get-ModWhitelisted([string]$FilePath) {
    try {
        $z   = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        # ── Fabric: fabric.mod.json ──────────────────────────────
        $fmj = $z.Entries | Where-Object { $_.FullName -eq "fabric.mod.json" } | Select-Object -First 1
        if ($fmj) {
            $sr  = [System.IO.StreamReader]::new($fmj.Open())
            $raw = $sr.ReadToEnd(); $sr.Close()
            if ($raw -match '"id"\s*:\s*"([^"]+)"') {
                $modId = $Matches[1].ToLower()
                foreach ($token in $whitelistedFileTokens) {
                    if ($modId -like "*$($token.ToLower())*") { $z.Dispose(); return $true }
                }
            }
        }

        # ── Forge / NeoForge: META-INF/mods.toml ────────────────
        $toml = $z.Entries | Where-Object { $_.FullName -eq "META-INF/mods.toml" } | Select-Object -First 1
        if ($toml) {
            $sr  = [System.IO.StreamReader]::new($toml.Open())
            $raw = $sr.ReadToEnd(); $sr.Close()
            if ($raw -match 'modId\s*=\s*"([^"]+)"') {
                $modId = $Matches[1].ToLower()
                foreach ($token in $whitelistedFileTokens) {
                    if ($modId -like "*$($token.ToLower())*") { $z.Dispose(); return $true }
                }
            }
        }

        $z.Dispose()
    } catch {}
    return $false
}

function Invoke-JarScan([string]$FilePath) {
    $found = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    # helpers
    function Add-Flag([string]$flag) { [void]$found.Add($flag.Trim()) }

    # ── Whitelist check via mod metadata (NOT filename) ──────────
    # Get-ModWhitelisted reads fabric.mod.json / mods.toml inside the JAR.
    # Renaming a cheat JAR to "feather-fabric.jar" will NOT bypass this.
    if (Get-ModWhitelisted -FilePath $FilePath) { return @() }

    function Add-FlagFiltered([string]$flag) {
        if (-not $whitelistSuppressedPatterns.Contains($flag.Trim())) {
            [void]$found.Add($flag.Trim())
        }
    }

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

        # ── 3. NESTED JAR / CLASS INSIDE JAR — deep scan ────────
        $nestedJars = $entries | Where-Object { $_.FullName -like "*.jar" -and $_.FullName -notlike "META-INF/*" }
        foreach ($nj in $nestedJars) {
            Add-Flag "Nested JAR: $($nj.FullName)"
            # Extract nested JAR into memory and scan its entries
            try {
                $njStream = $nj.Open()
                $njMs     = [System.IO.MemoryStream]::new()
                $njStream.CopyTo($njMs)
                $njStream.Close()
                $njMs.Position = 0

                $njZip = [System.IO.Compression.ZipArchive]::new($njMs, [System.IO.Compression.ZipArchiveMode]::Read)
                foreach ($njEntry in $njZip.Entries) {
                    $njName = $njEntry.FullName
                    $njExt  = [System.IO.Path]::GetExtension($njName).ToLower()

                    # path-level pattern scan
                    foreach ($p in $SuspiciousPatterns) {
                        if ($njName -match [regex]::Escape($p)) { Add-FlagFiltered $p }
                    }
                    $njIsLangFile = $njName -match "(?i)(^|/)assets/[^/]+/lang/[^/]+\.(json|lang)$"
                    if (-not $njIsLangFile) {
                        if ($JapaneseRegex.IsMatch($njName)) { Add-Flag "Japanese obfuscation" }
                        if ([regex]::IsMatch($njName, "[\u4E00-\u9FFF]")) { Add-Flag "Chinese obfuscation" }
                    }

                    # text file scan
                    if (($njExt -in @(".json",".txt",".toml",".cfg",".properties")) -or ($njName -match "MANIFEST\.MF")) {
                        if ($njEntry.Length -lt 2MB) {
                            try {
                                $s  = $njEntry.Open()
                                $r  = [System.IO.StreamReader]::new($s, [System.Text.Encoding]::UTF8, $true)
                                $t  = $r.ReadToEnd(); $r.Close(); $s.Close()
                                foreach ($p in $SuspiciousPatterns) { if ($t -match [regex]::Escape($p)) { Add-FlagFiltered $p } }
                                foreach ($p in $cheatStrings)        { if ($t -match [regex]::Escape($p)) { Add-FlagFiltered $p } }
                                if ($JapaneseRegex.IsMatch($t) -and -not $njIsLangFile)              { Add-Flag "Japanese obfuscation" }
                                if ([regex]::IsMatch($t, "[\u4E00-\u9FFF]") -and -not $njIsLangFile) { Add-Flag "Chinese obfuscation" }
                            } catch {}
                        }
                    }

                    # class bytecode scan
                    if ($njExt -eq ".class" -and $njEntry.Length -lt 512KB) {
                        try {
                            $s    = $njEntry.Open()
                            $bms  = [System.IO.MemoryStream]::new()
                            $s.CopyTo($bms); $s.Close()
                            $asc  = [System.Text.Encoding]::ASCII.GetString($bms.ToArray())
                            $bms.Dispose()
                            foreach ($p in $SuspiciousPatterns) { if ($asc -match [regex]::Escape($p)) { Add-FlagFiltered $p } }
                            foreach ($p in $cheatStrings)        { if ($asc -match [regex]::Escape($p)) { Add-FlagFiltered $p } }
                            $njHasExec    = $asc -match "Runtime\.exec|ProcessBuilder|cmd\.exe|/bin/sh"
                            $njHasNet     = $asc -match "HttpURLConnection|OkHttpClient|URLConnection|openConnection"
                            $njHasMalware = $asc -match "webhook|grabToken|stealToken|discord/token|reverseShell|connectBack"
                            if ($njHasExec -and ($njHasNet -or $njHasMalware)) { Add-Flag "Runtime command execution" }
                            if ($asc -match "Class\.forName|getDeclaredMethod|setAccessible") { Add-FlagFiltered "Suspicious reflection usage" }
                            if ($asc -match "HttpURLConnection|OkHttpClient|URLConnection" -and
                                $asc -notmatch "modrinth|curseforge|fabricmc|quiltmc") { Add-FlagFiltered "Unexpected network call in class" }
                        } catch {}
                    }
                }
                $njZip.Dispose()
                $njMs.Dispose()
            } catch {}
        }

        # ── 4. SUSPICIOUS PACKAGE ROOTS ─────────────────────────
        $suspiciousRoots = @("me/zero","me/alpha","io/github/nevalackin","wtf/zroger",
            "me/rigamortis","net/ccbluex","me/hwnd","xyz/qalcyo","me/odinaka",
            "dev/luna","me/stars","wtf/harvest","gg/essential/loader/stage0")
        foreach ($entry in $entries) {
            foreach ($root in $suspiciousRoots) {
                if ($entry.FullName -like "$root/*") { Add-FlagFiltered "Suspicious package: $root" }
            }
        }

        # ── 5. PER-ENTRY PATTERN + OBFUSCATION SCAN ─────────────
        foreach ($entry in $entries) {
            $name = $entry.FullName

            # known string patterns in file paths
            foreach ($p in $SuspiciousPatterns) {
                if ($name -match [regex]::Escape($p)) { Add-FlagFiltered $p }
            }

            # Japanese/Chinese obfuscation in class names
            # Skip legitimate lang/ translation files (e.g. assets/mod/lang/zh_cn.json, ja_jp.json)
            $isLangFile = $name -match "(?i)(^|/)assets/[^/]+/lang/[^/]+\.(json|lang)$"
            if (-not $isLangFile) {
                if ($JapaneseRegex.IsMatch($name)) { Add-Flag "Japanese obfuscation" }
                if ([regex]::IsMatch($name, "[\u4E00-\u9FFF]")) { Add-Flag "Chinese obfuscation" }
            }

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
                            if ($text -match [regex]::Escape($p)) { Add-FlagFiltered $p }
                        }
                        foreach ($p in $cheatStrings) {
                            if ($text -match [regex]::Escape($p)) { Add-FlagFiltered $p }
                        }
                        if ($JapaneseRegex.IsMatch($text) -and -not $isLangFile)                         { Add-Flag "Japanese obfuscation" }
                        if ([regex]::IsMatch($text, "[\u4E00-\u9FFF]") -and -not $isLangFile)            { Add-Flag "Chinese obfuscation" }

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
                        if ($ascii -match [regex]::Escape($p)) { Add-FlagFiltered $p }
                    }
                    foreach ($p in $cheatStrings) {
                        if ($ascii -match [regex]::Escape($p)) { Add-FlagFiltered $p }
                    }

                    # runtime exec / reflection abuse
                    # Only flag if combined with a network call or known malware string —
                    # ProcessBuilder/Runtime.exec are used legitimately by mods that open
                    # browsers, launchers, or system dialogs.
                    $hasRuntimeExec = $ascii -match "Runtime\.exec|ProcessBuilder|cmd\.exe|/bin/sh"
                    $hasNetworkCall = $ascii -match "HttpURLConnection|OkHttpClient|URLConnection|openConnection"
                    $hasMalwareStr  = $ascii -match "webhook|grabToken|stealToken|discord/token|reverseShell|connectBack"
                    if ($hasRuntimeExec -and ($hasNetworkCall -or $hasMalwareStr)) {
                        Add-Flag "Runtime command execution"
                    }
                    if ($ascii -match "Class\.forName|getDeclaredMethod|setAccessible") {
                        Add-FlagFiltered "Suspicious reflection usage"
                    }
                    # network calls inside class
                    if ($ascii -match "HttpURLConnection|OkHttpClient|URLConnection" -and
                        $ascii -notmatch "modrinth|curseforge|fabricmc|quiltmc") {
                        Add-FlagFiltered "Unexpected network call in class"
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
    do {
        $userInput = Read-Host "  Path"
        $modsPath  = $userInput.Trim()
        if ([string]::IsNullOrWhiteSpace($modsPath)) {
            Write-Host "  [ERROR] No path entered. Please enter the full path to your mods folder." -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($modsPath))
}

if ([string]::IsNullOrWhiteSpace($modsPath)) {
    Write-Host ""
    Write-Host "  [ERROR] No mods folder path was provided." -ForegroundColor Red
    Read-Host "  Press Enter to exit"
    exit 1
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
Write-Host "  Scanning directory: " -NoNewline -ForegroundColor DarkGray
Write-Host $modsPath -ForegroundColor Yellow
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "Found $($jarFiles.Count) JAR files to analyze" -ForegroundColor White
Write-Host ""
Start-Sleep -Milliseconds 300

$verified   = [System.Collections.Generic.List[hashtable]]::new()
$unknown    = [System.Collections.Generic.List[hashtable]]::new()
$suspicious = [System.Collections.Generic.List[hashtable]]::new()
$hashMap    = @{}
$srcMap     = @{}

# ================================================================
#  PASS 1 — HASH VERIFICATION
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 1" -NoNewline -ForegroundColor Yellow
Write-Host " — Hash verification (Modrinth + Megabase)..." -ForegroundColor DarkGray
Write-Host ""

$activeJars = $jarFiles | Where-Object { $_.Name -notlike "*.jar.disabled" }
$i = 0
foreach ($jar in $activeJars) {
    $i++
    $pct = [int](($i / $activeJars.Count) * 100)
    $bar = "#" * [int]($pct / 5)
    $empty = "-" * (20 - $bar.Length)

    Write-Host "`r  [$bar$empty] $pct%  $($jar.Name)                    " -NoNewline -ForegroundColor Yellow

    $hash = Get-SHA1Hash -FilePath $jar.FullName
    $src  = Get-DownloadSource -FilePath $jar.FullName
    $hashMap[$jar.Name] = $hash
    $srcMap[$jar.Name]  = $src

    $result = Invoke-ModrinthLookup -Hash $hash
    if (-not $result.Found) { $result = Invoke-MegabaseLookup -Hash $hash }

    if ($result.Found) {
        $verified.Add(@{ File = $jar.Name; Name = $result.Name; Slug = $result.Slug; DbSource = $result.Source; Hash = $hash; DlSource = $src })
    }
}

Write-Host "`r  [####################] 100% Done                                              " -ForegroundColor Green
Write-Host ""

$verifiedNames = $verified | ForEach-Object { $_.File }

# ================================================================
#  PASS 2 — DEEP SCAN ALL MODS
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 2" -NoNewline -ForegroundColor Yellow
Write-Host " — Deep-scanning all $($activeJars.Count) mod(s)..." -ForegroundColor DarkGray
Write-Host ""

if ($activeJars.Count -eq 0) {
    Write-Host "  No active mods to deep scan." -ForegroundColor DarkGray
    Write-Host ""
} else {
    $j = 0
    foreach ($jar in $activeJars) {
        $j++
        $pct2  = [int](($j / $activeJars.Count) * 100)
        $bar2  = "#" * [int]($pct2 / 5)
        $emp2  = "-" * (20 - $bar2.Length)
        Write-Host "`r  [$bar2$emp2] $pct2%  $($jar.Name)                              " -NoNewline -ForegroundColor Yellow

        $patterns = Invoke-JarScan -FilePath $jar.FullName
        $hash     = $hashMap[$jar.Name]
        $src      = $srcMap[$jar.Name]

        # Whitelist check — verify mod identity via fabric.mod.json / mods.toml,
        # NOT by filename (renaming a cheat to "feather-fabric.jar" won't bypass this)
        $isJarWhitelisted = Get-ModWhitelisted -FilePath $jar.FullName

        if (-not $isJarWhitelisted) {
            $fileNameLower = $jar.Name.ToLower()
            foreach ($token in $knownCheatFileTokens) {
                if ($fileNameLower -match [regex]::Escape($token.ToLower())) {
                    [void]$patterns.Add("Known cheat filename token: $token")
                }
            }
        }

        if ($patterns.Count -gt 0) {
            # ── Post-scan false-positive reduction ───────────────────────────────────
            # ClientPlayerInteractionManagerMixin is part of Fabric's standard API and
            # is used by many legitimate mods (crosshair addons, shield status displays,
            # etc.). Only keep it if at least one *other* hard cheat indicator is present.
            $hardCheatIndicators = @(
                "Backdoor","Stealer","TokenGrabber","ReverseShell","C2Server",
                "KillAura","AimAssist","AutoCrystal","Blink","FakeLag","PacketFly",
                "AntiAntiCheat","GrimBypass","NCPBypass","AACBypass","WatchdogBypass",
                "Runtime command execution","Known cheat filename token"
            )
            $hasHardIndicator = $patterns | Where-Object {
                $p = $_
                $hardCheatIndicators | Where-Object { $p -like "*$_*" }
            }
            if (-not $hasHardIndicator) {
                $patterns = $patterns | Where-Object { $_ -ne "ClientPlayerInteractionManagerMixin" }
            }

            # License/HWID: suppress when the only non-CJK flag — common in mods that
            # bundle dependency JARs with their own licensing code (voice chat libs, etc.)
            $seriousNonLicenseFlags = $patterns | Where-Object {
                $_ -ne "License/HWID check detected" -and
                $_ -notmatch "obfuscation"
            }
            if (($patterns | Where-Object { $_ -eq "License/HWID check detected" }) -and
                -not $seriousNonLicenseFlags) {
                $patterns = $patterns | Where-Object { $_ -ne "License/HWID check detected" }
            }
            # ────────────────────────────────────────────────────────────────────────

            if ($patterns.Count -gt 0) {
                $suspicious.Add(@{ File = $jar.Name; Hash = $hash; Patterns = $patterns; DlSource = $src })
            } elseif ($verifiedNames -notcontains $jar.Name) {
                $unknown.Add(@{ File = $jar.Name; Hash = $hash; DlSource = $src })
            }
        } elseif ($verifiedNames -notcontains $jar.Name) {
            $unknown.Add(@{ File = $jar.Name; Hash = $hash; DlSource = $src })
        }
    }
    Write-Host "`r  [####################] 100% Done                                                    " -ForegroundColor Green
    Write-Host ""
    foreach ($m in $suspicious) {
        Write-Host "  " -NoNewline
        Write-Host " SUSPICIOUS " -NoNewline -ForegroundColor White -BackgroundColor DarkRed
        Write-Host " $($m.File) — $($m.Patterns.Count) pattern(s)" -ForegroundColor Red
    }
    foreach ($m in $unknown) {
        Write-Host "  " -NoNewline
        Write-Host " UNKNOWN " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
        Write-Host " $($m.File)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# ================================================================
#  PASS 3 — BYPASS/INJECTION SCAN
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 3" -NoNewline -ForegroundColor Yellow
Write-Host " — Bypass/injection scan on all $($activeJars.Count) mods..." -ForegroundColor DarkGray
Write-Host ""

$injected = [System.Collections.Generic.List[string]]::new()
$k = 0
foreach ($jar in $activeJars) {
    $k++
    $pct3 = [int](($k / $activeJars.Count) * 100)
    $bar3 = "#" * [int]($pct3 / 5)
    $emp3 = "-" * (20 - $bar3.Length)
    Write-Host "`r  " -NoNewline
    Write-Host "`r  [$bar3$emp3] $pct3%  $($jar.Name)                              " -NoNewline -ForegroundColor Yellow

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -match "MANIFEST\.MF" -and $entry.Length -lt 100KB) {
                $stream = $entry.Open()
                $reader = [System.IO.StreamReader]::new($stream)
                $text   = $reader.ReadToEnd()
                $reader.Close(); $stream.Close()
                if ($text -match "Premain-Class|Agent-Class|Can-Redefine-Classes|Can-Retransform-Classes") {
                    if ($injected -notcontains $jar.Name) { $injected.Add($jar.Name) }
                }
            }
            if ($entry.FullName -match "-injected\.class$|-agent\.class$|JavaAgent") {
                if ($injected -notcontains $jar.Name) { $injected.Add($jar.Name) }
            }
        }
        $zip.Dispose()
    } catch {}
}
Write-Host "`r  [####################] 100% Done                                                    " -ForegroundColor Green
Write-Host ""
if ($injected.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " $($injected.Count) INJECTED MOD(S) DETECTED " -ForegroundColor White -BackgroundColor DarkRed
    foreach ($n in $injected) { Write-Host "    - $n" -ForegroundColor Red }
} else {
    Write-Host "  " -NoNewline
    Write-Host " No injection markers found " -ForegroundColor Black -BackgroundColor DarkGreen
}
Write-Host ""

# ================================================================
#  PASS 4 — OBFUSCATION ANALYSIS
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 4" -NoNewline -ForegroundColor Yellow
Write-Host " — Obfuscation analysis on all $($activeJars.Count) mods..." -ForegroundColor DarkGray
Write-Host ""

$obfuscated = [System.Collections.Generic.List[hashtable]]::new()
$l = 0
foreach ($jar in $activeJars) {
    $l++
    $pct4 = [int](($l / $activeJars.Count) * 100)
    $bar4 = "#" * [int]($pct4 / 5)
    $emp4 = "-" * (20 - $bar4.Length)
    Write-Host "`r  [$bar4$emp4] $pct4%  $($jar.Name)                              " -NoNewline -ForegroundColor Yellow

    # Skip whitelisted JARs — verified via mod metadata, not filename
    if (Get-ModWhitelisted -FilePath $jar.FullName) { continue }

    try {
        $zip        = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
        $classPaths = $zip.Entries | Where-Object { $_.FullName -like "*.class" } | ForEach-Object { $_.FullName }
        $total      = $classPaths.Count
        $flags      = [System.Collections.Generic.List[string]]::new()
        if ($total -gt 10) {
            $shortCount = ($classPaths | Where-Object {
                $parts = $_.Split('/')
                $parts.Count -ge 3 -and ($parts[0..($parts.Count-2)] | Where-Object { $_.Length -gt 2 }).Count -eq 0
            }).Count
            if ($shortCount / $total -gt 0.4) { $flags.Add("Single-char package paths ($shortCount path segments)") }

            $gibCount = ($classPaths | Where-Object {
                $n2 = [System.IO.Path]::GetFileNameWithoutExtension($_)
                $n2.Length -ge 3 -and $n2 -notmatch '[aeiouAEIOU]'
            }).Count
            if ($gibCount / $total -gt 0.04) {
                $pctG = [int](($gibCount / $total) * 100)
                $flags.Add("Gibberish class names ($pctG% have no vowels, $gibCount classes)")
            }
        }
        $zip.Dispose()
        if ($flags.Count -gt 0) { $obfuscated.Add(@{ File = $jar.Name; Flags = $flags }) }
    } catch {}
}
Write-Host "`r  [####################] 100% Done                                                    " -ForegroundColor Green
Write-Host ""
if ($obfuscated.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " $($obfuscated.Count) OBFUSCATED MOD(S) " -ForegroundColor Black -BackgroundColor DarkYellow
    foreach ($o in $obfuscated) {
        Write-Host "    $($o.File)" -ForegroundColor Yellow
        foreach ($f in $o.Flags) { Write-Host "      - $f" -ForegroundColor DarkGray }
    }
} else {
    Write-Host "  " -NoNewline
    Write-Host " No heavy obfuscation detected " -ForegroundColor Black -BackgroundColor DarkGreen
}
Write-Host ""

# ================================================================
#  PASS 5 — JVM AGENT SCAN
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 5" -NoNewline -ForegroundColor Yellow
Write-Host " — Scanning JVM for agents and injections..." -ForegroundColor DarkGray
Write-Host ""

$jvmIssues = [System.Collections.Generic.List[string]]::new()
$jvmSteps  = @("Reading process list","Fetching command lines","Checking -javaagent flags","Checking JVM boot flags","Finalizing")
$m2 = 0
foreach ($step in $jvmSteps) {
    $m2++
    $pct5 = [int](($m2 / $jvmSteps.Count) * 100)
    $bar5 = "#" * [int]($pct5 / 5)
    $emp5 = "-" * (20 - $bar5.Length)
    Write-Host "`r  [$bar5$emp5] $pct5%  $step                              " -NoNewline -ForegroundColor Yellow
    Start-Sleep -Milliseconds 120
}
if ($procs) {
    foreach ($proc in $procs) {
        try {
            $wmi     = Get-WmiObject Win32_Process -Filter "ProcessId=$($proc.Id)" -ErrorAction SilentlyContinue
            $cmdLine = if ($wmi) { $wmi.CommandLine } else { "" }
            if ($cmdLine -match "\-javaagent:") {
                $agents = [regex]::Matches($cmdLine, '-javaagent:([^\s"]+)')
                foreach ($a in $agents) {
                    $agentPath = $a.Groups[1].Value
                    if ($agentPath -notmatch "JetBrains|intellij|idea|eclipse|fabric-installer|theseus|modrinth|prismlauncher|multimc|atlauncher|curseforge|forge-installer|quilt-installer") {
                        $jvmIssues.Add("Suspicious -javaagent: $agentPath")
                    }
                }
            }
            if ($cmdLine -match "\-Xbootclasspath|\-XX:\+DisableAttachMechanism") {
                $jvmIssues.Add("Suspicious JVM flag in process $($proc.Id)")
            }
        } catch {}
    }
}
Write-Host "`r  [####################] 100% Done                                                    " -ForegroundColor Green
Write-Host ""
if ($jvmIssues.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " JVM ISSUES DETECTED " -ForegroundColor White -BackgroundColor DarkRed
    foreach ($issue in $jvmIssues) { Write-Host "    - $issue" -ForegroundColor Red }
} else {
    Write-Host "  " -NoNewline
    Write-Host " JVM looks clean " -ForegroundColor Black -BackgroundColor DarkGreen
}
Write-Host ""

# ================================================================
#  RESULTS
# ================================================================

$sep = "  " + ("=" * 74)

# ── VERIFIED ──────────────────────────────────────────────────
Write-Host ""
Write-Host $sep -ForegroundColor DarkYellow
Write-Host "  " -NoNewline
Write-Host " o " -NoNewline -ForegroundColor Black -BackgroundColor DarkGreen
Write-Host "  VERIFIED MODS  ($($verified.Count))" -ForegroundColor Green
Write-Host $sep -ForegroundColor DarkYellow
Write-Host ""
foreach ($m in $verified) {
    $label = if ($m.Name) { $m.Name } else { $m.File }
    Write-Host "  " -NoNewline
    Write-Host " + " -NoNewline -ForegroundColor Black -BackgroundColor DarkGreen
    Write-Host "  $label" -NoNewline -ForegroundColor Green
    if ($m.Name -and $m.Name -ne $m.File) {
        Write-Host "  ->  $($m.File)" -ForegroundColor DarkGray
    } else {
        Write-Host ""
    }
}

# ── UNKNOWN ───────────────────────────────────────────────────
Write-Host ""
Write-Host $sep -ForegroundColor DarkYellow
Write-Host "  " -NoNewline
Write-Host " o " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
Write-Host "  UNKNOWN MODS  ($($unknown.Count))" -ForegroundColor Yellow
Write-Host $sep -ForegroundColor DarkYellow
Write-Host ""
if ($unknown.Count -eq 0) {
    Write-Host "  None." -ForegroundColor DarkGray
} else {
    foreach ($m in $unknown) {
        Write-Host "  " -NoNewline
        Write-Host " ? " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
        Write-Host "  $($m.File)" -NoNewline -ForegroundColor Yellow
        if ($m.DlSource) {
            $sc = if ($m.DlSource.IsSafe -eq $false) { "Red" } else { "DarkGray" }
            Write-Host "   Source: $($m.DlSource.Label)" -ForegroundColor $sc
        } else {
            Write-Host ""
        }
    }
}

# ── SUSPICIOUS ────────────────────────────────────────────────
Write-Host ""
Write-Host $sep -ForegroundColor DarkYellow
Write-Host "  " -NoNewline
Write-Host " o " -NoNewline -ForegroundColor White -BackgroundColor DarkRed
Write-Host "  SUSPICIOUS MODS  ($($suspicious.Count))" -ForegroundColor Red
Write-Host $sep -ForegroundColor DarkYellow
Write-Host ""
if ($suspicious.Count -eq 0) {
    Write-Host "  None." -ForegroundColor DarkGray
} else {
    foreach ($m in $suspicious) {
        Write-Host "  " -NoNewline
        Write-Host " ! " -NoNewline -ForegroundColor White -BackgroundColor DarkRed
        Write-Host "  $($m.File)" -ForegroundColor Red
        Write-Host "       Hash   : $($m.Hash.Substring(0,20))..." -ForegroundColor DarkGray
        if ($m.DlSource) {
            $sc = if ($m.DlSource.IsSafe -eq $false) { "Red" } else { "DarkGray" }
            Write-Host "       Source : $($m.DlSource.Label)" -ForegroundColor $sc
        }
        Write-Host "       Detected patterns:" -ForegroundColor DarkGray
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
                "ShieldBreaker"                        { "Bypasses or breaks opponent's shield" }
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
            Write-Host "         " -NoNewline
            Write-Host " $p " -NoNewline -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "  $explanation" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# ── OBFUSCATED (summary) ───────────────────────────────────────
if ($obfuscated.Count -gt 0) {
    Write-Host ""
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host " o " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host "  OBFUSCATED MODS  ($($obfuscated.Count))" -ForegroundColor Yellow
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host ""
    foreach ($o in $obfuscated) {
        Write-Host "  " -NoNewline
        Write-Host " ~ " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
        Write-Host "  $($o.File)" -ForegroundColor Yellow
        foreach ($f in $o.Flags) { Write-Host "       - $f" -ForegroundColor DarkGray }
        Write-Host ""
    }
}

# ================================================================
#  SUMMARY
# ================================================================

Write-Host ""
Write-Host $sep -ForegroundColor Yellow
Write-Host "  SUMMARY" -ForegroundColor Yellow
Write-Host $sep -ForegroundColor Yellow
Write-Host ""
Write-Host "  Total files scanned : " -NoNewline -ForegroundColor DarkGray; Write-Host "$($activeJars.Count)" -ForegroundColor White
Write-Host "  Verified mods       : " -NoNewline -ForegroundColor DarkGray; Write-Host "$($verified.Count)" -ForegroundColor Green
Write-Host "  Unknown mods        : " -NoNewline -ForegroundColor DarkGray; Write-Host "$($unknown.Count)" -ForegroundColor Yellow
Write-Host "  Suspicious mods     : " -NoNewline -ForegroundColor DarkGray
if ($suspicious.Count -gt 0) { Write-Host "$($suspicious.Count)" -ForegroundColor Red } else { Write-Host "0" -ForegroundColor Green }
Write-Host "  Bypass/Injected     : " -NoNewline -ForegroundColor DarkGray
if ($injected.Count -gt 0) { Write-Host "$($injected.Count)" -ForegroundColor Red } else { Write-Host "0" -ForegroundColor Green }
Write-Host "  Obfuscated mods     : " -NoNewline -ForegroundColor DarkGray
if ($obfuscated.Count -gt 0) { Write-Host "$($obfuscated.Count)" -ForegroundColor Yellow } else { Write-Host "0" -ForegroundColor Green }
Write-Host "  JVM issues          : " -NoNewline -ForegroundColor DarkGray
if ($jvmIssues.Count -gt 0) { Write-Host "$($jvmIssues.Count)" -ForegroundColor Red } else { Write-Host "0" -ForegroundColor Green }
Write-Host ""
Write-Host $sep -ForegroundColor Yellow
Write-Host ""

if ($suspicious.Count -gt 0 -or $injected.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " !! SUSPICIOUS MODS DETECTED — check the results above !! " -ForegroundColor White -BackgroundColor DarkRed
} elseif ($unknown.Count -gt 0 -or $obfuscated.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " Some mods could not be verified — stay cautious. " -ForegroundColor Black -BackgroundColor DarkYellow
} else {
    Write-Host "  " -NoNewline
    Write-Host " All mods verified. Looking clean! " -ForegroundColor Black -BackgroundColor DarkGreen
}

Write-Host ""
Write-Host "  Analysis complete! Thanks for using CheesyModAnalyzer " -NoNewline -ForegroundColor White
Write-Host "o" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Created by  : " -NoNewline -ForegroundColor DarkGray
Write-Host "cheese cat" -ForegroundColor Yellow
Write-Host "  Discord     : " -NoNewline -ForegroundColor DarkGray
Write-Host "cheese_cat0" -ForegroundColor Yellow
Write-Host "  GitHub      : " -NoNewline -ForegroundColor DarkGray
Write-Host "github.com/cheesecatlol" -ForegroundColor Yellow
Write-Host ""
Write-Host $sep -ForegroundColor DarkYellow
Write-Host ""
Read-Host "  Press Enter to exit"
