#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
 $OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ================================================================
#  ANIMATION & DISPLAY HELPERS
# ================================================================

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

# ================================================================
#  DATA — PATTERN & STRING LISTS
# ================================================================

 $SuspiciousPatterns = @(
    "AimAssist","AutoCrystal","AutoHitCrystal","TriggerBot","KillAura",
    "BowAimbot","CrystalAura","SurroundBreaker","HoleSnap","BedAura",
    "MultiAura","ForceField","Aimbot","AntiAntiCheat",
    "ClickAura","ShieldBreaker","ShieldDisabler","AxeSpam",
    "Antiknockback","NoKnockback","JumpReset","SprintReset","NoJumpDelay",
    "LegitScaffold","BoatFly","Phase","Clip",
    "BunnyHop","Bhop","AirJump","WallClimb",
    "AutoTotem","AutoDoubleHand","InventoryTotem","TotemHit",
    "PopSwitch","LagReach","Wtap","FakeLag","Blink","PacketFly",
    "BlockESP","PackSpoof","PingSpoof","FakeNick","FakeItem",
    "PlayerESP","Wallhack","StorageESP","MobESP","ItemESP","HoleESP","ArmorESP",
    "HealthTags","NameTags","Nametags",
    "ChestSteal","AutoClicker","Nuker",
    "AutoSign","AutoBuild","Printer","InvMove","InventoryMove",
    "NoRender","AntiHunger","NameProtect",
    "dev.krypton","dev.gambleclient","PrestigeClient","DoomsdayClient",
    "Sigma","LiquidBounce","Salhack","Nodus","Wolfram",
    "VapeClient","VapeLite","IntentClient","intent.store",
    "riseclient","rise.today","meteordevelopment","liquidbounce",
    "fdp-client","net.ccbluex","novoware","novoclient","impactclient","azura",
    "pandaware","moonClient","astolfo","futureClient","konas","rusherhack","exhibition",
    "WolframClient","BleachHack","ThemisClient","ravenb","FluxClient","StrafeClient",
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
    "chainlibs","phantom-refmap","xyz.greaj","jnativehook",
    "org.chainlibs.module.impl.modules.Crystal.Y","org.chainlibs.module.impl.modules.Crystal.bF",
    "org.chainlibs.module.impl.modules.Crystal.bM","org.chainlibs.module.impl.modules.Crystal.bY",
    "org.chainlibs.module.impl.modules.Crystal.bq","org.chainlibs.module.impl.modules.Crystal.cv",
    "org.chainlibs.module.impl.modules.Crystal.o","org.chainlibs.module.impl.modules.Blatant.I",
    "org.chainlibs.module.impl.modules.Blatant.bR","org.chainlibs.module.impl.modules.Blatant.bx",
    "org.chainlibs.module.impl.modules.Blatant.cj","org.chainlibs.module.impl.modules.Blatant.dk",
    "KeyboardMixin","ClientPlayerInteractionManagerMixin","LicenseCheckMixin",
    "Allatori","Stringer","Branchlock","Caesium",
    "me/zero/client","me/rigamortis","net/ccbluex","io/github/nevalackin",
    "FLOW_OBFUSCATION","STRING_ENCRYPTION","RESOURCE_ENCRYPTION",
    "skidfuscator","me/itzsomebody","radon/transform","bozar/","paramorphism","zelix/klassmaster",
    "dasho","com/icqm/smoke","dev.krypton","dev.gambleclient","com.cheatbreaker",
    "client-refmap.json","cheat-refmap.json",
    "imgui.binding","imgui.gl3","imgui.glfw","JNativeHook","GlobalScreen","NativeKeyListener",
    "spoofVersion","brandOverride","overrideBrand","fakeClientBrand","brandSpoof","versionSpoof",
    "cancelPacket","dropPacket","suppressPacket","blockPacket","spoofPacket","injectPacket",
    "sendFakePacket","sendSilentPacket","bypassAC","bypass_ac","evadeAC","evadeAnticheat",
    "isGrimAC","isNoCheat","isAAC","isSpartanAC","isIntave","grimBypass","ncpBypass","aacBypass",
    "spartanBypass",
    "GrimBypass","NCPBypass","AACBypass","IntaveBypass","VulcanBypass","MatrixBypass",
    "WatchdogBypass","VerusDisabler","grim-api","setGrimFlag",
    "GrimVelocity","GrimDisabler","VelocitySpoof","KBReduce",
    "PacketMine","PacketWalk","PacketSneak","PacketCancel","PacketDupe","PacketSpam",
    "setTimerSpeed","timerSpeed","Timer.timerSpeed","setTickRate","overrideTickRate",
    "fakeTickCount","tickBoost","hitboxExpand","expandHitbox",
    "suppressKnockback","cancelKnockback","noKnockback","setVelocity(0","zeroVelocity",
    "ignoreKnockback","antiKnockback","KnockbackModifier","noVelocity",
    "fakeYaw","fakePitch","spoofYaw","spoofPitch","rotationBypass",
    "renderPlayerSpoofed","spoofRender","hideFromRender",
    "fakeGlowing","GlowBypass","glowBypass","baritone.bypass","pathfindBypass",
    "bypassLicense","fakeAuth","spoofSession","AltManager",
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
    "autototem","auto totem","inventorytotem","HoverTotem","hover totem","legittotem",
    "autopot","auto pot","speedPotSlot","strengthPotSlot","autoarmor","auto armor",
    "AutoPotRefill","AutoMace","MaceSwap","SpearSwap","StunSlam",
    "preventSwordBlockBreaking","preventSwordBlockAttack",
    "Breaking shield with axe...","ShieldDisabler",
    "aimassist","aim assist","triggerbot","trigger bot",
    "SilentRotations","Silent Rotations",
    "Rotation Speed","Use Easing","Easing Strength",
    "pingspoof","ping spoof","FakeLag","fakePunch","Fake Punch","FakeInv","swapBackToOriginalSlot",
    "webmacro","web macro","AntiWeb","AutoWeb","Places Webs On Enemies",
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
    "Stop On Kill","damagetick","Anti Weakness","Particle Chance",
    "Trigger Key","Switch Delay","Totem Slot","Glowstone Delay","Glowstone Chance",
    "Explode Delay","Explode Chance","Explode Slot","Only Charge",
    "No Count Glitch","No Bounce","Anchor Macro",
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
    "Ｓｔｏｐ Ｏｎ Ｋｉｌｌ","Ｄｑｒｋｉｓ Ｃｌｉｅｎｔ",
    "FINDING_SPAWNER","OPENING_SPAWNER","WAITING_SPAWNER_GUI","LOOTING_BONES","CLOSING_SPAWNER",
    "ORDER_COMMAND","WAIT_ORDER_GUI","SELECT_ORDER_ITEM","WAIT_DELIVERY_GUI","DELIVERING_BONES",
    "WAIT_AFTER_DELIVERY_1","CLOSING_DELIVERY","WAIT_AFTER_CLOSE_DELIVERY",
    "WAIT_CONFIRM_GUI","WAIT_CONFIRM_SETTLE","CLICK_CONFIRM_SLOT",
    "WAIT_AFTER_CONFIRM_1","WAIT_AFTER_CONFIRM_2","WAIT_AFTER_CONFIRM_3",
    "DOUBLE_ESCAPE","DOUBLE_RIGHTCLICK_FIRST","DOUBLE_RIGHTCLICK_SECOND","POST_CYCLE_DELAY"
)

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

 $cheatStrings = @(
    "AutoCrystal","autocrystal","auto crystal","cw crystal","dontPlaceCrystal","dontBreakCrystal",
    "AutoHitCrystal","autohitcrystal","canPlaceCrystalServer","healPotSlot","autoCrystalPlaceClock",
    "EndCrystalItemMixin","LWFH Crystal",
    "AutoAnchor","autoanchor","auto anchor","DoubleAnchor",
    "anchortweaks","anchor macro","safe anchor","safeanchor","SafeAnchor","AirAnchor","anchorMacro",
    "AutoTotem","autototem","auto totem","InventoryTotem","inventorytotem","HoverTotem","hover totem","legittotem",
    "autopot","auto pot","speedPotSlot","strengthPotSlot","autoarmor","auto armor","AutoPotRefill",
    "preventSwordBlockBreaking","preventSwordBlockAttack","ShieldDisabler","ShieldBreaker",
    "Breaking shield with axe...",
    "AutoDoubleHand","autodoublehand","auto double hand","Failed to switch to mace after axe!",
    "AutoMace","MaceSwap","SpearSwap","StunSlam",
    "JumpReset","axespam","axe spam","findKnockbackSword","attackRegisteredThisClick",
    "AimAssist","aimassist","aim assist","triggerbot","trigger bot","SilentRotations","Silent Rotations",
    "FakeInv","swapBackToOriginalSlot","FakeLag","fakePunch","Fake Punch",
    "webmacro","web macro","AntiWeb","AutoWeb","lvstrng","dqrkis",
    "WalksyCrystalOptimizerMod","WalksyOptimizer","WalskyOptimizer",
    "AutoFirework","ElytraSwap","NoJumpDelay",
    "PackSpoof","Antiknockback","catlean","AuthBypass","obfuscatedAuth","LicenseCheckMixin",
    "BaseFinder","ItemExploit","FreezePlayer","KeyPearl","LootYeeter","FastPlace","AutoBreach",
    "setBlockBreakingCooldown","getBlockBreakingCooldown","blockBreakingCooldown",
    "onBlockBreaking","invokeDoAttack","invokeDoItemUse","invokeOnMouseButton",
    "onPushOutOfBlocks","Automatically switches to sword when hitting with totem",
    "POT_CHEATS","Dqrkis Client",
    "Stop On Kill","damagetick","Particle Chance","Trigger Key",
    "Switch Delay","Totem Slot","Glowstone Delay","Glowstone Chance",
    "Explode Delay","Explode Chance","Explode Slot","Only Charge",
    "No Count Glitch","NoBounce","No Bounce","Anchor Macro",
    "Auto Inventory Totem","Strict One-Tick","Mace Priority","Min Totems","Min Pearls",
    "Totem First","Loot Yeeter","holdCrystal","stopOnKill","placeInterval","breakInterval",
    "activateOnRightClick","HasAnchor","Blatant",
    "Auto Switch Back","Check Line of Sight","Only When Falling","Require Crit",
    "Show Status Display","Stop On Crystal","Check Shield","On Pop","Predict Damage",
    "On Ground","Check Players","Predict Crystals","Check Aim","Check Items",
    "Activates Above","Force Totem","Stay Open For","Only On Pop",
    "Vertical Speed","Hover Totem","Swap Speed","Drop Interval","Random Pattern",
    "Horizontal Aim Speed","Vertical Aim Speed","Include Head",
    "Web Delay","Holding Web","Not When Affects Player","Hit Delay",
    "Require Hold Axe","Auto Pot","Macro Key",
    "Ｂｌａｔａｎｔ","Ｆｏｒｃｅ Ｔｏｔｅｍ","Ｓｔａｙ Ｏｐｅｎ Ｆｏｒ","Ｏｎｌｙ Ｏｎ Ｐｏｐ",
    "Ｖｅｒｔｉｃａｌ Ｓｐｅｅｄ","Ｓｗａｐ Ｓｐｅｅｄ","Ｄｒｏｐ Ｉｎｔｅｒｖａｌ","Ｒａｎｄｏｍ Ｐａｔｔｅｒｎ",
    "Ｈｏｒｉｚｏｎｔａｌ Ａｉｍ Ｓｐｅｅｄ","Ｖｅｒｔｉｃａｌ Ａｉｍ Ｓｐｅｅｄ","Ｉｎｃｌｕｄｅ Ｈｅａｄ",
    "Ｗｅｂ Ｄｅｌａｙ","Ｈｏｌｄｉｎｇ Ｗｅｂ","Ｈｉｔ Ｄｅｌａｙ","Ｒｅｑｕｉｒｅ Ｈｏｌｄ Ａｘｅ",
    "Ａｕｔｏ Ｓｗｉｔｃｈ Ｂａｃｋ","Ｃｈｅｃｋ Ｌｉｎｅ ｏｆ Ｓｉｇｈｔ","Ｏｎｌｙ Ｗｈｅｎ Ｆａｌｌｉｎｇ",
    "Ｒｅｑｕｉｒｅ Ｃｒｉｔ","Ｓｔｏｐ Ｏｎ Ｃｒｙｓｔａｌ","Ｃｈｅｃｋ Ｓｈｉｅｌｄ","Ｏｎ Ｐｏｐ",
    "Ｐｒｅｄｉｃｔ Ｄａｍａｇｅ","Ｐｒｅｄｉｃｔ Ｃｒｙｓｔａｌｓ","Ｃｈｅｃｋ Ａｉｍ","Ｃｈｅｃｋ Ｉｔｅｍｓ",
    "Ａｃｔｉｖａｔｅｓ Ａｂｏｖｅ","Ｈｏｖｅｒ Ｔｏｔｅｍ","Ｓｗｉｔｃｈ Ｂａｃｋ","Ｍａｃｒｏ Ｋｅｙ",
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
    "imgui.binding","imgui.gl3","imgui.glfw","JNativeHook","GlobalScreen","NativeKeyListener",
    "client-refmap.json","cheat-refmap.json","phantom-refmap.json",
    "aHR0cDovL2FwaS5ub3ZhY2xpZW50LmxvbC93ZWJob29rLnR4dA==",
    "meteordevelopment","cc/novoline","com/alan/clients","club/maxstats","wtf/moonlight",
    "me/zeroeightsix/kami","net/ccbluex","today/opai","net/minecraft/injection",
    "org/chainlibs/module/impl/modules","xyz/greaj","com/cheatbreaker",
    "doomsdayclient","DoomsdayClient","doomsday.jar","novaclient","api.novaclient.lol",
    "vape.gg","vapeclient","VapeClient","VapeLite","intent.store","IntentClient",
    "rise.today","riseclient.com","meteor-client","meteorclient","meteordevelopment.meteorclient",
    "liquidbounce","fdp-client","net.ccbluex","novoware","novoclient","azura",
    "pandaware","moonClient","astolfo","futureClient","konas","rusherhack","exhibition",
    "sessionstealer","tokengrabber","webhookstealer","cookiethief","discordstealer","keylogger",
    "iplogger","cryptominer","reverseShell","backdoormod","exploitmod","ratmod","ransomware",
    "sendWebhook","exfiltrate","connectBack","callHome","grabToken","stealSession","accountstealer",
    "discord/token","grabber/cookie","grab_cookies","stealerutils","sendToWebhook","postDiscord",
    "webhookurl","discordwebhook",
    "crasher","lagmachine","booksploit","signcrasher","entityspammer","nukermod","worldnuker",
    "tntmod","bedexplode","anchorexplode","injectClass","modifyBytecode","hookMethod",
    "attachAgent","VirtualMachine.attach",
    "FLOW_OBFUSCATION","STRING_ENCRYPTION","RESOURCE_ENCRYPTION",
    "skidfuscator","me/itzsomebody","radon/transform","bozar/","paramorphism","zelix/klassmaster",
    "allatori","dasho","com/icqm/smoke","dev.krypton","dev.gambleclient","com.cheatbreaker",
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
    "ＡｕｔｏＣｒｙｓｔａｌ","Ａｕｔｏ Ｃｒｙｓｔａｌ","ＡｕｔｏＨｉｔＣｒｙｓｔａｌ","ＡｕｔｏＡｎｃｈｏｒ","Ａｕｔｏ Ａｎｃｈｏｒ",
    "ＤｏｕｂｌｅＡｎｃｈｏｒ","ＳａｆｅＡｎｃｈｏｒ","Ｓａｆｅ Ａｎｃｈｏｒ","Ａｎｃｈｏｒ Ｍａｃｒｏ","ＡｕｔｏＴｏｔｅｍ",
    "Ａｕｔｏ Ｔｏｔｅｍ","ＨｏｖｅｒＴｏｔｅｍ","ＩｎｖｅｎｔｏｒｙＴｏｔｅｍ","ＡｕｔｏＰｏｔ","Ａｕｔｏ Ｐｏｔ",
    "ＡｕｔｏＡｒｍｏｒ","ＳｈｉｅｌｄＤｉｓａｂｌｅｒ","ＡｕｔｏＤｏｕｂｌｅＨａｎｄ","ＡｕｔｏＭａｃｅ","ＭａｃｅＳｗａｐ",
    "ＡｉｍＡｓｓｉｓｔ","ＴｒｉｇｇｅｒＢｏｔ","Ｓｉｌｅｎｔ Ｒｏｔａｔｉｏｎｓ","ＦａｋｅＬａｇ","Ｆａｋｅ Ｌａｇ",
    "ＬＷＦＨＣｒｙｓｔａｌ","ＬＷＦＨ Ｃｒｙｓｔａｌ","ＬｏｏｔＹｅｅｔｅｒ","Ｌｏｏｔ Ｙｅｅｔｅｒ","ＡｕｔｏＢｒｅａｃｈ","Ｆｒｅｅｚｅ Ｐｌａｙｅｒ"
)

# ================================================================
#  OPTIMIZED REGEX — Unified pattern matching (MAJOR SPEEDUP)
# ================================================================

 $allUniquePatterns = @($SuspiciousPatterns) + @($cheatStrings | Where-Object { $SuspiciousPatterns -notcontains $_ }) | Select-Object -Unique

 $UnifiedPatternRegex = [regex]::new(
    '(?<![A-Za-z])(' + (($allUniquePatterns | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(?![A-Za-z])',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

 $FullwidthRegex = [regex]::new(
    "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}",
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

 $JapaneseRegex = [regex]::new("[\u3040-\u309F\u30A0-\u30FF]", [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $ChineseRegex  = [regex]::new("[\u4E00-\u9FFF]", [System.Text.RegularExpressions.RegexOptions]::Compiled)

 $ScanExtensions = [System.Collections.Generic.HashSet[string]]::new([string[]]@(".class",".json",".txt",".toml",".cfg",".properties"))
 $TextExtensions = [System.Collections.Generic.HashSet[string]]::new([string[]]@(".json",".txt",".toml",".cfg",".properties"))

 $fwCheatPool = @($cheatStrings | Where-Object { $_ -cmatch "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]" })

 $SafeSources  = @("curseforge.com","modrinth.com","cdn.modrinth.com","mediafiles.curseforge.com")
 $RiskySources = @(
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

 $whitelistedFileTokens = @(
    "feather","feathermc","feather-fabric","feather-forge",
    "essential","cosmetica","cosmetic","emotes","emotecraft",
    "sodium","lithium","phosphor","iris","indium","starlight",
    "ferritecore","memoryleakfix","smoothboot","lazydfu",
    "immediatelyfast","nvidium","modernfix","c2me",
    "replaymod","replay-mod","carpet","tweakeroo","itemscroller",
    "fabric-api","fabric_api","quilt-standard","quilted_fabric",
    "modmenu","cloth-config","cloth_config","yacl","yet-another-config",
    "skinsrestorer","customskinloader","skinport",
    "totemic","totemguard",
    "wi-zoom","wizoom","wi_zoom","zoom","zoomify","okzoomer",
    "lunar","badlion","blc","labymod","laby-mod"
)

 $whitelistSuppressedPatterns = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@(
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
    "setSelectedSlot","setItemUseCooldown","onIsGlowing",
    "HttpURLConnection","URLConnection","openConnection",
    "getDeclaredMethod","setAccessible","Class.forName",
    "Unexpected network call in class","Suspicious reflection usage",
    "noKnockback","cancelKnockback","suppressKnockback",
    "checkAnticheat","detectAnticheat","getAnticheat",
    "GrimAC","ac.grim","game.grim","imgui",
    "Place Delay","Break Delay","Fast Mode","Place Chance","Break Chance",
    "Damage Tick","Reach Distance","Min Height","Min Fall Speed",
    "Attack Delay","Breach Delay","Require Elytra","Activate Key",
    "Click Simulation","On RMB","Place blocks faster",
    "Smooth Rotations","SmoothRotations","arrayOfString",
    "NameTags","Nametags",
    "getPassword","KeyboardMixin","Blink","ElytraFly","ChestESP","Wurst"
) | ForEach-Object { [void]$whitelistSuppressedPatterns.Add($_) }

 $cheatObfuscators = @{
    "Skidfuscator"   = @("dev/skidfuscator","Skidfuscator","skidfuscator.dev")
    "Paramorphism"   = @("Paramorphism","paramorphism-","dev/paramorphism")
    "Radon"          = @("ItzSomebody/Radon","me/itzsomebody/radon","Radon Obfuscator")
    "Caesium"        = @("sim0n/Caesium","Caesium Obfuscator","dev/sim0n/caesium")
    "Bozar"          = @("vimasig/Bozar","Bozar Obfuscator","com/bozar")
    "Branchlock"     = @("Branchlock","branchlock.dev")
    "Binscure"       = @("Binscure","com/binscure")
    "SuperBlaubeere" = @("superblaubeere","superblaubeere27")
    "Qprotect"       = @("Qprotect","QProtect","mdma.dev/qprotect")
    "Zelix"          = @("ZKMFLOW","ZKM","ZelixKlassMaster","com/zelix")
    "Stringer"       = @("StringerJavaObfuscator","com/licel/stringer")
    "JNIC"           = @("JNIC","jnic.obf","jnic-obfuscator")
    "Scuti"          = @("ScutiObf","scuti.obf")
    "Smoke"          = @("SmokeObf","smoke.obf")
}

# ================================================================
#  FIX: Corrected parenthesis grouping in $ObfuscatorRegex
# ================================================================
 $ObfuscatorRegex = [regex]::new(
    ('(?:' + (($cheatObfuscators.Values | ForEach-Object { $_ } | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')'),
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

 $SuspiciousUrlRegex = [regex]::new(
    'cdn\.discordapp\.com|anonfiles\.com|gofile\.io|transfer\.sh|file\.io|temp\.sh|pastecord\.com|hastebin\.com|paste\.gg|api\.myip|checkip\.|ipinfo\.io|ipapi\.co',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

 $LicenseHwidRegex = [regex]::new(
    'hwid|HWID|hardware\.id|LicenseKey|licensecheck|validateLicense|checkLicense|activation',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

 $DictFileRegex = [regex]::new(
    '(?i)(?:dict(?:ionar(?:y|ies))?|wordlist|words|spelling|hunspell|aspell|enchant)[^/]*\.(?:txt|dic|aff|json)$|(?i)/dicts?/[^/]+$|(?i)/words?/[^/]+\.txt$',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

 $suspiciousRoots = @("me/zero","me/alpha","io/github/nevalackin","wtf/zroger",
    "me/rigamortis","net/ccbluex","me/hwnd","xyz/qalcyo","me/odinaka",
    "dev/luna","me/stars","wtf/harvest","gg/essential/loader/stage0",
    "net/wurstclient","com/wurstclient")

 $RuntimeExecRegex = [regex]::new('Runtime\.exec|ProcessBuilder|cmd\.exe|/bin/sh', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $NetworkCallRegex = [regex]::new('HttpURLConnection|OkHttpClient|URLConnection|openConnection', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $MalwareStrRegex  = [regex]::new('webhook|grabToken|stealToken|discord/token|reverseShell|connectBack', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $ReflectionRegex  = [regex]::new('Class\.forName|getDeclaredMethod|setAccessible', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $LegitDomainRegex = [regex]::new('modrinth|curseforge|fabricmc|quiltmc', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $LangFileRegex    = [regex]::new('(?i)(?:^|/)assets/[^/]+/lang/[^/]+\.(?:json|lang)$', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $ManifestRegex    = [regex]::new('MANIFEST\.MF$', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $NestedJarRegex   = [regex]::new('^META-INF/jars/.+\.jar$', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $WordLineRegex    = [regex]::new('^[A-Za-z''-]{1,30}$', [System.Text.RegularExpressions.RegexOptions]::Compiled)

# Pre-compiled whitelist regex — replaces nested -like loop in Pass 2 outer loop
 $WhitelistTokenRegex = [regex]::new(
    ($whitelistedFileTokens | ForEach-Object { [regex]::Escape($_) }) -join '|',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
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


function Resolve-FullwidthMatches([System.Collections.Generic.HashSet[string]]$found) {
    $fwMatches = @($found | Where-Object { $FullwidthRegex.IsMatch($_) })
    foreach ($fw in $fwMatches) {
        $bestMatch = $null
        foreach ($cs in $fwCheatPool) {
            if ($cs.Contains($fw)) {
                if ($null -eq $bestMatch -or $cs.Length -lt $bestMatch.Length) { $bestMatch = $cs }
            }
        }
        if ($null -ne $bestMatch) {
            [void]$found.Remove($fw)
            [void]$found.Add($bestMatch)
        }
    }
}

# ================================================================
#  OPTIMIZED JAR SCAN
# ================================================================

function Invoke-JarScan([string]$FilePath) {
    $found = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    # Local copies of script-scope variables (scope fix)
    $TextExtensions              = $script:TextExtensions
    $ManifestRegex               = $script:ManifestRegex
    $NestedJarRegex              = $script:NestedJarRegex
    $LangFileRegex               = $script:LangFileRegex
    $DictFileRegex               = $script:DictFileRegex
    $WordLineRegex               = $script:WordLineRegex
    $UnifiedPatternRegex         = $script:UnifiedPatternRegex
    $FullwidthRegex              = $script:FullwidthRegex
    $JapaneseRegex               = $script:JapaneseRegex
    $ChineseRegex                = $script:ChineseRegex
    $ObfuscatorRegex             = $script:ObfuscatorRegex
    $RuntimeExecRegex            = $script:RuntimeExecRegex
    $NetworkCallRegex            = $script:NetworkCallRegex
    $MalwareStrRegex             = $script:MalwareStrRegex
    $ReflectionRegex             = $script:ReflectionRegex
    $LegitDomainRegex            = $script:LegitDomainRegex
    $SuspiciousUrlRegex          = $script:SuspiciousUrlRegex
    $LicenseHwidRegex            = $script:LicenseHwidRegex
    $whitelistSuppressedPatterns = $script:whitelistSuppressedPatterns
    $WhitelistTokenRegex         = $script:WhitelistTokenRegex
    $cheatObfuscators            = $script:cheatObfuscators
    $suspiciousRoots             = $script:suspiciousRoots
    $fwCheatPool                 = $script:fwCheatPool

    $script:buffer = $null
    $script:hasNonAscii = $false

    function Add-Flag([string]$flag) { [void]$found.Add($flag.Trim()) }
    function Add-Filtered([string]$flag) {
        $t = $flag.Trim()
        if (-not $whitelistSuppressedPatterns.Contains($t)) { [void]$found.Add($t) }
    }

    # OPTIMIZATION: vectorized non-ASCII detection via .NET Array.FindIndex
    # instead of a per-byte PowerShell loop — ~10x faster on large class files.
    function Read-EntryBytes([System.IO.Compression.ZipArchiveEntry]$entry) {
        $stream = $entry.Open()
        $size = [int]$entry.Length
        if ($null -eq $script:buffer -or $script:buffer.Length -lt $size) {
            $script:buffer = New-Object byte[] ($size + 1024)
        }
        $read = 0
        while ($read -lt $size) {
            $r = $stream.Read($script:buffer, $read, $size - $read)
            if ($r -eq 0) { break }
            $read += $r
        }
        $stream.Close()
        # Use .NET predicate to find first byte > 127 — avoids PowerShell loop entirely
        $script:hasNonAscii = [Array]::FindIndex($script:buffer, 0, $read, [Predicate[byte]]{ param($b) $b -gt 127 }) -ge 0
        return $read
    }

    function Process-Content([string]$ascii, [int]$byteLen, [bool]$isLangFile, [bool]$isClassFile) {
        $matches = $UnifiedPatternRegex.Matches($ascii)
        foreach ($m in $matches) { Add-Filtered $m.Value }

        if ($script:hasNonAscii) {
            $utf8 = [System.Text.Encoding]::UTF8.GetString($script:buffer, 0, $byteLen)
            $utf8Matches = $UnifiedPatternRegex.Matches($utf8)
            foreach ($m in $utf8Matches) { Add-Filtered $m.Value }
            $fwMatches = $FullwidthRegex.Matches($utf8)
            foreach ($m in $fwMatches) { [void]$found.Add($m.Value) }
            if (-not $isLangFile) {
                if ($isClassFile) {
                    # class file Japanese/Chinese is counted via obfuscation stats, not flagged here
                } else {
                    if ($JapaneseRegex.IsMatch($utf8)) { Add-Flag "Japanese text in config/resource" }
                    if ($ChineseRegex.IsMatch($utf8))  { Add-Flag "Chinese text in config/resource" }
                }
            }
        }

        if ($isClassFile) {
            if ($RuntimeExecRegex.IsMatch($ascii) -and ($NetworkCallRegex.IsMatch($ascii) -or $MalwareStrRegex.IsMatch($ascii))) {
                Add-Flag "Runtime command execution"
            }
            if ($ReflectionRegex.IsMatch($ascii)) { Add-Filtered "Suspicious reflection usage" }
            if ($NetworkCallRegex.IsMatch($ascii) -and -not $LegitDomainRegex.IsMatch($ascii)) {
                Add-Filtered "Unexpected network call in class"
            }
            $obfMatch = $ObfuscatorRegex.Match($ascii)
            if ($obfMatch.Success) {
                foreach ($obfName in $cheatObfuscators.Keys) {
                    foreach ($pat in $cheatObfuscators[$obfName]) {
                        if ($ascii.Contains($pat)) { Add-Flag "Known obfuscator: $obfName"; break }
                    }
                }
            }
        } else {
            if ($SuspiciousUrlRegex.IsMatch($ascii)) {
                $urlPats = @("cdn.discordapp.com","anonfiles.com","gofile.io","transfer.sh","file.io","temp.sh","pastecord.com","hastebin.com","paste.gg","api.myip","checkip.","ipinfo.io","ipapi.co")
                foreach ($up in $urlPats) {
                    if ($ascii.Contains($up)) { Add-Flag "Suspicious URL in config: $up" }
                }
            }
            if ($LicenseHwidRegex.IsMatch($ascii)) { Add-Flag "License/HWID check detected" }
        }
    }

    # OPTIMIZATION: returns $true if a .txt file looks like a plain word list
    # and should be skipped. Extracted to avoid duplicating this logic for
    # both text entries and nested-jar entries.
    function Test-IsWordFile([string]$ascii) {
        $lines = $ascii -split "`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -First 200
        if ($lines.Count -lt 50) { return $false }
        $wordLines = ($lines | Where-Object { $WordLineRegex.IsMatch($_.Trim()) }).Count
        return ($wordLines / $lines.Count -gt 0.90)
    }

    # Helper: scan one entry's path + optionally its content
    function Invoke-EntryPathScan([string]$name, [bool]$isLangFile) {
        $pathMatches = $UnifiedPatternRegex.Matches($name)
        foreach ($m in $pathMatches) { Add-Filtered $m.Value }
    }

    $zip = $null
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        # OPTIMIZATION: whitelist check reuses the same $zip instance opened above —
        # avoids a second ZipFile::OpenRead/Dispose cycle (was a separate function call before).
        foreach ($entry in $zip.Entries) {
            $n = $entry.FullName
            if ($n -eq "fabric.mod.json") {
                $srW = [System.IO.StreamReader]::new($entry.Open())
                $rawW = $srW.ReadToEnd(); $srW.Close()
                $fieldsW = @()
                if ($rawW -match '"id"\s*:\s*"([^"]+)"')   { $fieldsW += $Matches[1] }
                if ($rawW -match '"name"\s*:\s*"([^"]+)"') { $fieldsW += $Matches[1] }
                foreach ($field in $fieldsW) {
                    if ($WhitelistTokenRegex.IsMatch($field)) { return @() }
                }
                break
            }
        }
        foreach ($entry in $zip.Entries) {
            $n = $entry.FullName
            if ($n -eq "META-INF/mods.toml") {
                $srW = [System.IO.StreamReader]::new($entry.Open())
                $rawW = $srW.ReadToEnd(); $srW.Close()
                if ($rawW -match 'modId\s*=\s*"([^"]+)"') {
                    if ($WhitelistTokenRegex.IsMatch($Matches[1])) { return @() }
                }
                break
            }
        }

        # OPTIMIZATION: single pass over zip entries to populate all buckets.
        # Previously the entry list was walked 5+ separate times (once to find
        # whitelist files, once for the main categorisation loop, then again
        # separately for class obfuscation stats). Now it's one loop.
        $classPaths   = [System.Collections.Generic.List[string]]::new()
        $textEntries  = [System.Collections.Generic.List[object]]::new()
        $classEntries = [System.Collections.Generic.List[object]]::new()
        $manifestEntry = $null
        $nestedJars   = [System.Collections.Generic.List[object]]::new()

        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            $ext  = [System.IO.Path]::GetExtension($name).ToLower()
            if ($ext -eq ".class") {
                $classPaths.Add($name)
                if ($entry.Length -lt 512KB -and $entry.Length -gt 10) { $classEntries.Add($entry) }
            } elseif ($TextExtensions.Contains($ext) -and $entry.Length -lt 2MB -and $entry.Length -gt 10) {
                $textEntries.Add($entry)
            } elseif ($ManifestRegex.IsMatch($name) -and $entry.Length -lt 100KB) {
                $manifestEntry = $entry
            } elseif ($NestedJarRegex.IsMatch($name)) {
                $nestedJars.Add($entry)
            }
        }

        $totalClasses = $classPaths.Count

        # Obfuscation heuristics — short-path and single-char class names
        if ($totalClasses -gt 10) {
            $shortPathCount = 0
            $singleCharCount = 0
            foreach ($cp in $classPaths) {
                # Short-path check (a/b/c/ structure)
                $parts = $cp.Split('/')
                if ($parts.Count -ge 3 -and $parts.Count -le 6) {
                    $allShort = $true
                    for ($i = 0; $i -lt $parts.Count - 1; $i++) {
                        if ($parts[$i].Length -gt 2) { $allShort = $false; break }
                    }
                    if ($allShort) { $shortPathCount++ }
                }
                # Single-char class name check (merged into same loop — was a second foreach before)
                if ([System.IO.Path]::GetFileNameWithoutExtension($cp).Length -le 2) { $singleCharCount++ }
            }
            if ($shortPathCount  / $totalClasses -gt 0.4) { Add-Flag "Short-path obfuscation (a/b/c/ structure)" }
            if ($singleCharCount / $totalClasses -gt 0.5)  { Add-Flag "Single-char class names (heavy obfuscation)" }
        }

        # Suspicious package roots — use a HashSet for O(1) prefix lookup
        if ($classPaths.Count -gt 0) {
            $rootsFound = [System.Collections.Generic.HashSet[string]]::new()
            foreach ($cp in $classPaths) {
                foreach ($root in $suspiciousRoots) {
                    if (-not $rootsFound.Contains($root) -and $cp.StartsWith("$root/")) {
                        Add-Filtered "Suspicious package: $root"
                        [void]$rootsFound.Add($root)
                    }
                }
            }
        }

        # Nested JAR content scan
        foreach ($nj in $nestedJars) {
            try {
                $njStream = $nj.Open()
                $njMs = [System.IO.MemoryStream]::new()
                $njStream.CopyTo($njMs)
                $njStream.Close()
                $njMs.Position = 0
                $njZip = [System.IO.Compression.ZipArchive]::new($njMs, [System.IO.Compression.ZipArchiveMode]::Read)
                foreach ($njEntry in $njZip.Entries) {
                    $njName = $njEntry.FullName
                    $njExt  = [System.IO.Path]::GetExtension($njName).ToLower()
                    $isLangFile = $LangFileRegex.IsMatch($njName)
                    $isDictFile = $DictFileRegex.IsMatch($njName)
                    Invoke-EntryPathScan -name $njName -isLangFile $isLangFile
                    if (($TextExtensions.Contains($njExt) -or $ManifestRegex.IsMatch($njName)) -and $njEntry.Length -lt 2MB -and -not $isDictFile) {
                        try {
                            $len   = Read-EntryBytes -entry $njEntry
                            $ascii = [System.Text.Encoding]::ASCII.GetString($script:buffer, 0, $len)
                            if ($njExt -eq ".txt" -and (Test-IsWordFile -ascii $ascii)) { continue }
                            Process-Content -ascii $ascii -byteLen $len -isLangFile $isLangFile -isClassFile $false
                        } catch {}
                    }
                    if ($njExt -eq ".class" -and $njEntry.Length -lt 512KB -and $njEntry.Length -gt 10) {
                        try {
                            $len   = Read-EntryBytes -entry $njEntry
                            $ascii = [System.Text.Encoding]::ASCII.GetString($script:buffer, 0, $len)
                            Process-Content -ascii $ascii -byteLen $len -isLangFile $false -isClassFile $true
                        } catch {}
                    }
                }
                $njZip.Dispose()
                $njMs.Dispose()
            } catch {}
        }

        # Text entry scan
        foreach ($entry in $textEntries) {
            $name       = $entry.FullName
            $isLangFile = $LangFileRegex.IsMatch($name)
            $isDictFile = $DictFileRegex.IsMatch($name)
            Invoke-EntryPathScan -name $name -isLangFile $isLangFile
            if ($isDictFile) { continue }
            try {
                $len   = Read-EntryBytes -entry $entry
                $ascii = [System.Text.Encoding]::ASCII.GetString($script:buffer, 0, $len)
                $ext   = [System.IO.Path]::GetExtension($name).ToLower()
                if ($ext -eq ".txt" -and (Test-IsWordFile -ascii $ascii)) { continue }
                Process-Content -ascii $ascii -byteLen $len -isLangFile $isLangFile -isClassFile $false
            } catch {}
        }

        # Manifest scan
        if ($null -ne $manifestEntry) {
            try {
                $len   = Read-EntryBytes -entry $manifestEntry
                $ascii = [System.Text.Encoding]::ASCII.GetString($script:buffer, 0, $len)
                Process-Content -ascii $ascii -byteLen $len -isLangFile $false -isClassFile $false
            } catch {}
        }

        # Class content scan
        foreach ($entry in $classEntries) {
            $name       = $entry.FullName
            $isLangFile = $LangFileRegex.IsMatch($name)
            Invoke-EntryPathScan -name $name -isLangFile $isLangFile
            try {
                $len   = Read-EntryBytes -entry $entry
                $ascii = [System.Text.Encoding]::ASCII.GetString($script:buffer, 0, $len)
                Process-Content -ascii $ascii -byteLen $len -isLangFile $isLangFile -isClassFile $true
            } catch {}
        }

    } catch {
        Write-Host ""
        Write-Host "    [WARN] Could not open JAR: $($_.Exception.Message)" -ForegroundColor DarkYellow
    } finally {
        if ($null -ne $zip) { $zip.Dispose() }
    }

    Resolve-FullwidthMatches -found $found
    return ($found | Select-Object -Unique)
}

# ================================================================
#  MERGED SCAN — Passes 3 + 4 combined into Invoke-FullScan
#  One ZIP open per JAR handles bypass detection, obfuscation
#  analysis, and agent/manifest checks in a single entry pass.
# ================================================================

function Invoke-FullScan([string]$FilePath) {
    # --- shared regex/data pulled from script scope ---
    $ManifestRegex    = $script:ManifestRegex
    $NestedJarRegex   = $script:NestedJarRegex
    $FullwidthRegex   = $script:FullwidthRegex
    $RuntimeExecRegex = $script:RuntimeExecRegex
    $NetworkCallRegex = $script:NetworkCallRegex
    $MalwareStrRegex  = $script:MalwareStrRegex
    $cheatObfuscators = $script:cheatObfuscators
    $WhitelistTokenRegex = $script:WhitelistTokenRegex

    $bypassFlags = [System.Collections.Generic.List[string]]::new()
    $obfFlags    = [System.Collections.Generic.List[string]]::new()

    $mavenPrefixes = [string[]]@("com_","org_","net_","io_","dev_","gs_","xyz_","app_","me_","tv_","uk_","be_","fr_","de_")
    function Test-SuspiciousJarName([string]$name) {
        $base = [System.IO.Path]::GetFileNameWithoutExtension($name)
        if ($base -match '\d' -or $base.Length -gt 20) { return $false }
        foreach ($p in $mavenPrefixes) { if ($base.ToLower().StartsWith($p)) { return $false } }
        return $true
    }

    $zip = $null
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)

        # --- whitelist check (reuse open zip) ---
        $isWhitelisted = $false
        foreach ($e in $zip.Entries) {
            $n = $e.FullName
            if ($n -eq "fabric.mod.json") {
                $sr = [System.IO.StreamReader]::new($e.Open()); $raw = $sr.ReadToEnd(); $sr.Close()
                if ($raw -match '"id"\s*:\s*"([^"]+)"'   -and $WhitelistTokenRegex.IsMatch($Matches[1])) { $isWhitelisted = $true; break }
                if ($raw -match '"name"\s*:\s*"([^"]+)"' -and $WhitelistTokenRegex.IsMatch($Matches[1])) { $isWhitelisted = $true; break }
            }
            if ($n -eq "META-INF/mods.toml") {
                $sr = [System.IO.StreamReader]::new($e.Open()); $raw = $sr.ReadToEnd(); $sr.Close()
                if ($raw -match 'modId\s*=\s*"([^"]+)"' -and $WhitelistTokenRegex.IsMatch($Matches[1])) { $isWhitelisted = $true; break }
            }
        }

        # --- single entry categorisation pass ---
        $outerClasses  = 0
        $outerModId    = ""
        $nestedJarEntries = [System.Collections.Generic.List[object]]::new()

        # bypass counters
        $runtimeExecFound  = $false; $httpDownloadFound = $false; $httpExfilFound = $false
        $byObfCount = 0; $byNumCount = 0; $byUniCount = 0; $byTotal = 0

        # obfuscation counters (only populated when not whitelisted)
        $totalClass = 0; $numericCount = 0; $unicodeCount = 0; $fullwidthCount = 0
        $japaneseCount = 0; $singleLetterCount = 0; $twoLetterCount = 0
        $gibberishCount = 0; $noVowelCount = 0; $confusionCount = 0; $singleCharPkg = 0
        $contentSample = [System.Text.StringBuilder]::new(); $sampleSize = 0

        $buf = $null
        $ClassExtRegex = [regex]'\.class$'  # local compiled — avoids -match string interp overhead

        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            $isClass = $ClassExtRegex.IsMatch($name)

            # ---- manifest check (bypass pass) ----
            if ($ManifestRegex.IsMatch($name) -and $entry.Length -lt 100KB) {
                try {
                    $sr = [System.IO.StreamReader]::new($entry.Open()); $txt = $sr.ReadToEnd(); $sr.Close()
                    if ($outerModId -eq "" -and $txt -match 'Manifest-Version') {}  # just a marker
                    if ($txt -match "Premain-Class|Agent-Class|Can-Redefine-Classes|Can-Retransform-Classes") {
                        $bypassFlags.Add("Java agent manifest — Premain-Class or Agent-Class declared")
                    }
                } catch {}
                continue
            }

            # ---- fabric.mod.json — grab modId for fake-identity check ----
            if ($name -eq "fabric.mod.json") {
                try {
                    $sr = [System.IO.StreamReader]::new($entry.Open()); $txt = $sr.ReadToEnd(); $sr.Close()
                    if ($txt -match '"id"\s*:\s*"([^"]+)"') { $outerModId = $Matches[1] }
                } catch {}
                continue
            }

            # ---- nested jars ----
            if ($NestedJarRegex.IsMatch($name)) {
                $njBase = [System.IO.Path]::GetFileName($name)
                if (Test-SuspiciousJarName -name $njBase) {
                    $bypassFlags.Add("Suspicious nested JAR — no version, unknown dependency: $njBase")
                }
                $nestedJarEntries.Add($entry)
                continue
            }

            if (-not $isClass) { continue }

            # ---- class entry — shared work for both bypass + obf passes ----
            $outerClasses++
            $segs      = ($name -replace '\.class$','') -split '/'
            $className = $segs[-1]

            # bypass: consecutive single-char path segments
            $byTotal++
            if ($className -match '^\d+$')        { $byNumCount++ }
            if ($className -match '[^\x00-\x7F]') { $byUniCount++ }
            $consec = 0; $maxConsec = 0
            foreach ($seg in $segs) {
                if ($seg.Length -eq 1) { $consec++; if ($consec -gt $maxConsec) { $maxConsec = $consec } }
                else { $consec = 0 }
            }
            if ($maxConsec -ge 3) { $byObfCount++ }

            # obfuscation counters (skip when whitelisted — saves ~40% of work on clean installs)
            if (-not $isWhitelisted) {
                $totalClass++
                if ($className -match '^\d+$')                                              { $numericCount++ }
                if ($className -match '[^\x00-\x7F]')                                       { $unicodeCount++ }
                if ($className -match '[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]')         { $fullwidthCount++ }
                if ($className -match '[\u3040-\u309F\u30A0-\u30FF]')                      { $japaneseCount++ }
                if ($className -match '^[a-zA-Z]$')                                         { $singleLetterCount++ }
                if ($className -match '^[a-zA-Z]{2}$')                                      { $twoLetterCount++ }
                if ($className -match '^[Il1O0]+$' -or $className -match '^[_]+$')         { $confusionCount++ }
                if ($className.Length -ge 3 -and $className.Length -le 8 -and $className -match '^[a-zA-Z]+$') {
                    # OPTIMIZATION: regex match count replaces ToCharArray()|Where-Object pipeline
                    $vowelCount = ([regex]::Matches($className,'[aeiouAEIOU]')).Count
                    if ($vowelCount -eq 0) { $noVowelCount++ }
                    if ($className -match '[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]{3,}' -and ($vowelCount / $className.Length) -lt 0.3) { $gibberishCount++ }
                }
                foreach ($seg in $segs[0..($segs.Count-2)]) { if ($seg.Length -eq 1) { $singleCharPkg++ } }
            }

            # class content read — shared buffer for both bypass + obf sample
            if ($entry.Length -lt 512KB -and $entry.Length -gt 10) {
                try {
                    $st   = $entry.Open()
                    $size = [int]$entry.Length
                    if ($null -eq $buf -or $buf.Length -lt $size) { $buf = New-Object byte[] $size }
                    $read = 0
                    while ($read -lt $size) { $r = $st.Read($buf, $read, $size - $read); if ($r -eq 0) { break }; $read += $r }
                    $st.Close()
                    $ct = [System.Text.Encoding]::ASCII.GetString($buf, 0, $read)

                    # bypass checks
                    if ($RuntimeExecRegex.IsMatch($ct))                                                                             { $runtimeExecFound  = $true }
                    if ($ct.Contains("openConnection") -and $ct.Contains("HttpURLConnection") -and $ct.Contains("FileOutputStream")){ $httpDownloadFound = $true }
                    if ($ct.Contains("openConnection") -and $ct.Contains("setDoOutput") -and $ct.Contains("getOutputStream") -and $ct.Contains("getProperty")) { $httpExfilFound = $true }

                    # obfuscation content sample
                    if (-not $isWhitelisted -and $sampleSize -lt 150000 -and $entry.Length -lt 100000) {
                        [void]$contentSample.Append($ct); $sampleSize += $read
                    }
                } catch {}
            }
        }

        # ---- expand nested jars (bypass pass only — same logic as before) ----
        $innerZips = [System.Collections.Generic.List[object]]::new()
        foreach ($nj in $nestedJarEntries) {
            try {
                $ns = $nj.Open(); $ms = [System.IO.MemoryStream]::new(); $ns.CopyTo($ms); $ns.Close(); $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $innerZips.Add($iz)
                foreach ($ie in $iz.Entries) {
                    $iname = $ie.FullName
                    if (-not $ClassExtRegex.IsMatch($iname)) { continue }
                    $byTotal++
                    $isegs  = ($iname -replace '\.class$','') -split '/'
                    $icn    = $isegs[-1]
                    if ($icn -match '^\d+$')        { $byNumCount++ }
                    if ($icn -match '[^\x00-\x7F]') { $byUniCount++ }
                    $c2 = 0; $m2 = 0
                    foreach ($s in $isegs) { if ($s.Length -eq 1) { $c2++; if ($c2 -gt $m2) { $m2 = $c2 } } else { $c2 = 0 } }
                    if ($m2 -ge 3) { $byObfCount++ }
                    if ($ie.Length -lt 512KB -and $ie.Length -gt 10) {
                        try {
                            $ist  = $ie.Open(); $isz = [int]$ie.Length
                            if ($null -eq $buf -or $buf.Length -lt $isz) { $buf = New-Object byte[] $isz }
                            $ird = 0
                            while ($ird -lt $isz) { $ir = $ist.Read($buf, $ird, $isz - $ird); if ($ir -eq 0) { break }; $ird += $ir }
                            $ist.Close()
                            $ict = [System.Text.Encoding]::ASCII.GetString($buf, 0, $ird)
                            if ($RuntimeExecRegex.IsMatch($ict))                                                                                 { $runtimeExecFound  = $true }
                            if ($ict.Contains("openConnection") -and $ict.Contains("HttpURLConnection") -and $ict.Contains("FileOutputStream")) { $httpDownloadFound = $true }
                            if ($ict.Contains("openConnection") -and $ict.Contains("setDoOutput") -and $ict.Contains("getOutputStream") -and $ict.Contains("getProperty")) { $httpExfilFound = $true }
                        } catch {}
                    }
                }
            } catch {}
        }
        foreach ($iz in $innerZips) { try { $iz.Dispose() } catch {} }

        if ($nestedJarEntries.Count -eq 1 -and $outerClasses -lt 3) {
            $njName = [System.IO.Path]::GetFileName($nestedJarEntries[0].FullName)
            $bypassFlags.Add("Hollow shell — only $outerClasses own class(es), wraps: $njName")
        }

        # ---- bypass flag evaluation ----
        $byObfPct = if ($byTotal -ge 10) { [math]::Round(($byObfCount / $byTotal) * 100) } else { 0 }
        $byNumPct = if ($byTotal -ge 5)  { [math]::Round(($byNumCount / $byTotal) * 100) } else { 0 }
        $byUniPct = if ($byTotal -ge 5)  { [math]::Round(($byUniCount / $byTotal) * 100) } else { 0 }
        if ($runtimeExecFound -and $byObfPct -ge 25) { $bypassFlags.Add("Runtime.exec() in obfuscated code — can run arbitrary OS commands") }
        if ($httpDownloadFound) { $bypassFlags.Add("HTTP file download — fetches and writes files from a remote server at runtime") }
        if ($httpExfilFound)    { $bypassFlags.Add("HTTP POST exfiltration — sends system data to an external server") }
        if ($byTotal -ge 10 -and $byObfPct -ge 25) { $bypassFlags.Add("Heavy obfuscation — $byObfPct% of classes use single-letter path segments (a/b/c style)") }
        if ($byNumPct -ge 20)   { $bypassFlags.Add("Numeric class names — $byNumPct% of classes have numeric-only names (e.g. 1234.class)") }
        if ($byUniPct -ge 10)   { $bypassFlags.Add("Unicode class names — $byUniPct% of classes use non-ASCII characters") }

        $knownLegitModIds = [System.Collections.Generic.HashSet[string]]([string[]]@("vmp-fabric","vmp","lithium","sodium","iris","fabric-api","modmenu","ferrite-core","lazydfu","starlight","entityculling","memoryleakfix","krypton","c2me-fabric","smoothboot-fabric","immediatelyfast","noisium","threadtweak"))
        $dangerCount = ($bypassFlags | Where-Object { $_ -match "Runtime\.exec|HTTP file download|HTTP POST|Heavy obfuscation|Suspicious nested JAR" }).Count
        if ($outerModId -and $knownLegitModIds.Contains($outerModId) -and $dangerCount -gt 0) {
            $bypassFlags.Add("Fake mod identity — claims to be '$outerModId' but contains dangerous code")
        }

        # ---- obfuscation flag evaluation ----
        if (-not $isWhitelisted -and $totalClass -ge 5) {
            $pct = { param($n) [math]::Round(($n / $totalClass) * 100) }
            $numPct  = & $pct $numericCount;  $uniPct  = & $pct $unicodeCount
            $fwPct   = & $pct $fullwidthCount; $jpPct  = & $pct $japaneseCount
            $s1Pct   = & $pct $singleLetterCount; $s2Pct = & $pct $twoLetterCount
            $gibPct  = & $pct $gibberishCount; $novPct = & $pct $noVowelCount; $confPct = & $pct $confusionCount

            if ($numPct  -ge 20) { $obfFlags.Add("Numeric class names — $numPct% of classes have numeric-only names") }
            if ($uniPct  -ge 10) { $obfFlags.Add("Unicode class names — $uniPct% of classes use non-ASCII characters") }
            if ($fwPct   -gt  0) { $obfFlags.Add("Fullwidth Unicode class names — $fwPct% use ａｂｃ/ＡＢＣ/０１２ chars ($fullwidthCount classes)") }
            if ($jpPct   -gt  0) { $obfFlags.Add("Japanese obfuscation — $jpPct% use hiragana/katakana class names ($japaneseCount classes)") }
            if ($s1Pct   -ge 15) { $obfFlags.Add("Single-letter class names — $s1Pct% ($singleLetterCount classes)") }
            if ($s2Pct   -ge 20) { $obfFlags.Add("Two-letter class names — $s2Pct% ($twoLetterCount classes)") }
            if ($gibPct  -ge  5) { $obfFlags.Add("Gibberish class names — $gibPct% have no vowels / consonant clusters ($gibberishCount classes)") }
            if ($novPct  -ge  8) { $obfFlags.Add("No-vowel class names — $novPct% ($noVowelCount classes)") }
            if ($confPct -ge  3) { $obfFlags.Add("Confusion-char names (Il1O0/_) — $confPct% ($confusionCount classes)") }
            if ($singleCharPkg -ge 6) { $obfFlags.Add("Single-char package paths — $singleCharPkg path segments like a/b/c") }

            $sampleStr = $contentSample.ToString()
            $fwMatches = $FullwidthRegex.Matches($sampleStr)
            if ($fwMatches.Count -gt 0) {
                $examples = ($fwMatches | Select-Object -First 3 | ForEach-Object { $_.Value }) -join ", "
                $obfFlags.Add("Fullwidth strings in class content — $($fwMatches.Count) occurrences (e.g. $examples)")
            }
            foreach ($obfName in $cheatObfuscators.Keys) {
                foreach ($pat in $cheatObfuscators[$obfName]) {
                    if ($sampleStr.Contains($pat)) { $obfFlags.Add("Known cheat obfuscator detected — $obfName (matched: $pat)"); break }
                }
            }
        }

    } catch {
    } finally {
        if ($null -ne $zip) { $zip.Dispose() }
    }

    return @{ Bypass = $bypassFlags; Obf = $obfFlags }
}

# ================================================================
#  PASS 5 — JVM AGENT SCAN
# ================================================================

function Invoke-JvmScan {
    $results = [System.Collections.Generic.List[string]]::new()
    $javaProc = Get-Process -Name "java","javaw" -ErrorAction SilentlyContinue
    if (-not $javaProc) { return $results }
    $javaPid = ($javaProc | Select-Object -First 1).Id
    try {
        $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $javaPid" -ErrorAction Stop
        $cmdLine = $wmi.CommandLine
        if ($cmdLine) {
            $agentMatches = [regex]::Matches($cmdLine, '-javaagent:([^\s"]+)')
            foreach ($m in $agentMatches) {
                $agentPath = $m.Groups[1].Value.Trim('"').Trim("'")
                $agentName = [System.IO.Path]::GetFileName($agentPath)
                $legitAgents = @("jmxremote","yjp","jrebel","newrelic","jacoco","theseus","JetBrains","intellij","idea","eclipse","fabric-installer","modrinth","prismlauncher","multimc","atlauncher","curseforge","forge-installer","quilt-installer")
                $isLegit = $false
                foreach ($la in $legitAgents) { if ($agentName -match $la) { $isLegit = $true; break } }
                if (-not $isLegit) { $results.Add("Suspicious -javaagent: $agentName (path: $agentPath)") }
            }
            $suspiciousFlags = @(
                @{ Flag = "-Xbootclasspath/p:"; Desc = "prepends to bootstrap classpath, overrides core Java classes" },
                @{ Flag = "-Xbootclasspath/a:"; Desc = "appends to bootstrap classpath, injects below classloader" },
                @{ Flag = "-agentlib:jdwp";     Desc = "JDWP debug agent, remote debugging enabled" },
                @{ Flag = "-agentpath:";         Desc = "native agent loaded, bypasses Java sandbox" },
                @{ Flag = "-XX:+DisableAttachMechanism"; Desc = "disables JVM attach (anti-analysis)" }
            )
            foreach ($sf in $suspiciousFlags) {
                if ($cmdLine -match [regex]::Escape($sf.Flag)) { $results.Add("Suspicious JVM flag — $($sf.Flag) ($($sf.Desc))") }
            }
        }
    } catch {}
    return $results
}

# ================================================================
#  STARTUP
# ================================================================

Write-Banner
Start-Sleep -Milliseconds 200

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

 $autoFolder = $null; $autoLabel = $null
if ($procs) {
    foreach ($proc in $procs) {
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId=$($proc.Id)" -ErrorAction SilentlyContinue
            $cmdLine = if ($wmi) { $wmi.CommandLine } else { "" }
            if ($cmdLine) {
                $m = [regex]::Match($cmdLine, '--gameDir\s+"([^"]+)"')
                if (-not $m.Success) { $m = [regex]::Match($cmdLine, '--gameDir\s+(\S+)') }
                if ($m.Success) {
                    $gameDir = $m.Groups[1].Value.TrimEnd('\')
                    $candidate = Join-Path $gameDir "mods"
                    if (Test-Path $candidate) {
                        $autoFolder = $candidate
                        $autoLabel = Split-Path (Split-Path $gameDir -Parent) -Leaf
                        if ([string]::IsNullOrWhiteSpace($autoLabel) -or $autoLabel -eq "instances") { $autoLabel = Split-Path $gameDir -Leaf }
                    }
                }
                if (-not $autoFolder) {
                    $m2 = [regex]::Match($cmdLine, '-Dminecraft\.appDir=([^\s"]+)')
                    if ($m2.Success) {
                        $gameDir = $m2.Groups[1].Value.Trim('"').TrimEnd('\')
                        $candidate = Join-Path $gameDir "mods"
                        if (Test-Path $candidate) { $autoFolder = $candidate; $autoLabel = Split-Path $gameDir -Leaf }
                    }
                }
            }
        } catch {}
        if ($autoFolder) { break }
    }
}

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
    $modsPath = if ([string]::IsNullOrWhiteSpace($userInput)) { $autoFolder } else { $userInput.Trim() }
} else {
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
        if ([string]::IsNullOrWhiteSpace($modsPath)) { Write-Host "  [ERROR] No path entered. Please enter the full path to your mods folder." -ForegroundColor Red }
    } while ([string]::IsNullOrWhiteSpace($modsPath))
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
 $injected   = [System.Collections.Generic.List[hashtable]]::new()
 $obfuscated = [System.Collections.Generic.List[hashtable]]::new()
 $hashMap    = @{}
 $srcMap     = @{}

 $activeJars = $jarFiles | Where-Object { $_.Name -notlike "*.jar.disabled" }

# ================================================================
#  PASS 1 — HASH VERIFICATION
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 1" -NoNewline -ForegroundColor Yellow
Write-Host " — Hash verification (Modrinth + Megabase)..." -ForegroundColor DarkGray
Write-Host ""

 $i = 0
foreach ($jar in $activeJars) {
    $i++
    $pct = [int](($i / $activeJars.Count) * 100)
    $bar = "#" * [int]($pct / 5); $empty = "-" * (20 - $bar.Length)
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
#  PASSES 2 + 3 + 4 — PARALLEL DEEP SCAN
#  All three scans run in one pass per JAR, all JARs run in
#  parallel via a runspace pool (one thread per logical CPU core).
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 2" -NoNewline -ForegroundColor Yellow
Write-Host " — Deep-scanning all $($activeJars.Count) mod(s)..." -ForegroundColor DarkGray
Write-Host ""

# Capture all script-scope data that runspaces need — runspaces
# don't inherit the caller's variable scope.
$rsInitVars = @{
    UnifiedPatternRegex      = $UnifiedPatternRegex
    FullwidthRegex           = $FullwidthRegex
    JapaneseRegex            = $JapaneseRegex
    ChineseRegex             = $ChineseRegex
    ObfuscatorRegex          = $ObfuscatorRegex
    RuntimeExecRegex         = $RuntimeExecRegex
    NetworkCallRegex         = $NetworkCallRegex
    MalwareStrRegex          = $MalwareStrRegex
    ReflectionRegex          = $ReflectionRegex
    LegitDomainRegex         = $LegitDomainRegex
    SuspiciousUrlRegex       = $SuspiciousUrlRegex
    LicenseHwidRegex         = $LicenseHwidRegex
    ManifestRegex            = $ManifestRegex
    NestedJarRegex           = $NestedJarRegex
    LangFileRegex            = $LangFileRegex
    DictFileRegex            = $DictFileRegex
    WordLineRegex            = $WordLineRegex
    WhitelistTokenRegex      = $WhitelistTokenRegex
    TextExtensions           = $TextExtensions
    whitelistSuppressedPatterns = $whitelistSuppressedPatterns
    cheatObfuscators         = $cheatObfuscators
    suspiciousRoots          = $suspiciousRoots
    fwCheatPool              = $fwCheatPool
    knownCheatFileTokens     = $knownCheatFileTokens
}

# Scriptblock that runs inside each runspace — receives one JAR path
# and returns a hashtable with DeepFlags, BypassFlags, ObfFlags.
$rsScanBlock = [scriptblock]::Create({
    param([string]$FilePath, [string]$FileName, [hashtable]$V)

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # Restore all variables from the init hashtable into local scope
    foreach ($kv in $V.GetEnumerator()) { Set-Variable -Name $kv.Key -Value $kv.Value }

    # ── helpers ──────────────────────────────────────────────────
    $found = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    function Add-Flag([string]$f)     { [void]$found.Add($f.Trim()) }
    function Add-Filtered([string]$f) { $t=$f.Trim(); if(-not $whitelistSuppressedPatterns.Contains($t)){[void]$found.Add($t)} }

    $buf = $null; $hasNonAscii = $false
    function Read-Bytes([System.IO.Compression.ZipArchiveEntry]$e) {
        $st=$e.Open(); $sz=[int]$e.Length
        if($null -eq $buf -or $buf.Length -lt $sz){$script:buf=New-Object byte[]($sz+1024)}
        $rd=0; while($rd -lt $sz){$r=$st.Read($script:buf,$rd,$sz-$rd);if($r -eq 0){break};$rd+=$r}
        $st.Close()
        $script:hasNonAscii=[Array]::FindIndex($script:buf,0,$rd,[Predicate[byte]]{param($b)$b -gt 127}) -ge 0
        return $rd
    }

    function Proc-Content([string]$ascii,[int]$blen,[bool]$isLang,[bool]$isCls) {
        foreach($m in $UnifiedPatternRegex.Matches($ascii)){Add-Filtered $m.Value}
        if($script:hasNonAscii){
            $u=[System.Text.Encoding]::UTF8.GetString($script:buf,0,$blen)
            foreach($m in $UnifiedPatternRegex.Matches($u)){Add-Filtered $m.Value}
            foreach($m in $FullwidthRegex.Matches($u)){[void]$found.Add($m.Value)}
            if(-not $isLang -and -not $isCls){if($JapaneseRegex.IsMatch($u)){Add-Flag "Japanese text in config/resource"};if($ChineseRegex.IsMatch($u)){Add-Flag "Chinese text in config/resource"}}
        }
        if($isCls){
            if($RuntimeExecRegex.IsMatch($ascii)-and($NetworkCallRegex.IsMatch($ascii)-or $MalwareStrRegex.IsMatch($ascii))){Add-Flag "Runtime command execution"}
            if($ReflectionRegex.IsMatch($ascii)){Add-Filtered "Suspicious reflection usage"}
            if($NetworkCallRegex.IsMatch($ascii)-and -not $LegitDomainRegex.IsMatch($ascii)){Add-Filtered "Unexpected network call in class"}
            if($ObfuscatorRegex.IsMatch($ascii)){
                foreach($on in $cheatObfuscators.Keys){foreach($p in $cheatObfuscators[$on]){if($ascii.Contains($p)){Add-Flag "Known obfuscator: $on";break}}}
            }
        } else {
            if($SuspiciousUrlRegex.IsMatch($ascii)){
                foreach($up in @("cdn.discordapp.com","anonfiles.com","gofile.io","transfer.sh","file.io","temp.sh","pastecord.com","hastebin.com","paste.gg","api.myip","checkip.","ipinfo.io","ipapi.co")){
                    if($ascii.Contains($up)){Add-Flag "Suspicious URL in config: $up"}
                }
            }
            if($LicenseHwidRegex.IsMatch($ascii)){Add-Flag "License/HWID check detected"}
        }
    }

    function Is-WordFile([string]$a){
        $lines=$a -split "`n"|Where-Object{$_.Trim()-ne ""}|Select-Object -First 200
        if($lines.Count -lt 50){return $false}
        return (($lines|Where-Object{$WordLineRegex.IsMatch($_.Trim())}).Count/$lines.Count) -gt 0.90
    }

    function Scan-EntryPath([string]$n,[bool]$isLang){
        foreach($m in $UnifiedPatternRegex.Matches($n)){Add-Filtered $m.Value}
    }

    $bypassFlags = [System.Collections.Generic.List[string]]::new()
    $obfFlags    = [System.Collections.Generic.List[string]]::new()

    $mavenPfx=[string[]]@("com_","org_","net_","io_","dev_","gs_","xyz_","app_","me_","tv_","uk_","be_","fr_","de_")
    function Is-SuspiciousJar([string]$n){
        $b=[System.IO.Path]::GetFileNameWithoutExtension($n)
        if($b -match '\d' -or $b.Length -gt 20){return $false}
        foreach($p in $mavenPfx){if($b.ToLower().StartsWith($p)){return $false}}
        return $true
    }

    $ClassRx=[regex]'\.class$'

    $zip=$null
    try {
        $zip=[System.IO.Compression.ZipFile]::OpenRead($FilePath)

        # whitelist check
        $isWL=$false
        foreach($e in $zip.Entries){
            $n=$e.FullName
            if($n -eq "fabric.mod.json"){
                $sr=[System.IO.StreamReader]::new($e.Open());$raw=$sr.ReadToEnd();$sr.Close()
                if(($raw -match '"id"\s*:\s*"([^"]+)"'   -and $WhitelistTokenRegex.IsMatch($Matches[1]))-or
                   ($raw -match '"name"\s*:\s*"([^"]+)"' -and $WhitelistTokenRegex.IsMatch($Matches[1]))){$isWL=$true;break}
            }
            if($n -eq "META-INF/mods.toml"){
                $sr=[System.IO.StreamReader]::new($e.Open());$raw=$sr.ReadToEnd();$sr.Close()
                if($raw -match 'modId\s*=\s*"([^"]+)"' -and $WhitelistTokenRegex.IsMatch($Matches[1])){$isWL=$true;break}
            }
        }

        # categorise entries in one pass
        $classPaths=[System.Collections.Generic.List[string]]::new()
        $textEntries=[System.Collections.Generic.List[object]]::new()
        $classEntries=[System.Collections.Generic.List[object]]::new()
        $manifestEntry=$null; $nestedJars=[System.Collections.Generic.List[object]]::new()
        $outerClassCount=0; $outerModId=""

        foreach($e in $zip.Entries){
            $n=$e.FullName; $ext=[System.IO.Path]::GetExtension($n).ToLower()
            if($ext -eq ".class"){
                $classPaths.Add($n); $outerClassCount++
                if($e.Length -lt 512KB -and $e.Length -gt 10){$classEntries.Add($e)}
            } elseif($TextExtensions.Contains($ext)-and $e.Length -lt 2MB -and $e.Length -gt 10){
                $textEntries.Add($e)
            } elseif($ManifestRegex.IsMatch($n)-and $e.Length -lt 100KB){
                $manifestEntry=$e
            } elseif($NestedJarRegex.IsMatch($n)){
                $nestedJars.Add($e)
                if(Is-SuspiciousJar $n){$bypassFlags.Add("Suspicious nested JAR — no version, unknown dependency: $([System.IO.Path]::GetFileName($n))")}
            } elseif($n -eq "fabric.mod.json"){
                try{$sr=[System.IO.StreamReader]::new($e.Open());$t=$sr.ReadToEnd();$sr.Close();if($t -match '"id"\s*:\s*"([^"]+)"'){$outerModId=$Matches[1]}}catch{}
            }
        }

        # manifest / agent check
        if($null -ne $manifestEntry){
            try{$sr=[System.IO.StreamReader]::new($manifestEntry.Open());$t=$sr.ReadToEnd();$sr.Close()
                if($t -match "Premain-Class|Agent-Class|Can-Redefine-Classes|Can-Retransform-Classes"){$bypassFlags.Add("Java agent manifest — Premain-Class or Agent-Class declared")}
            }catch{}
        }

        # hollow shell check
        if($nestedJars.Count -eq 1 -and $outerClassCount -lt 3){
            $bypassFlags.Add("Hollow shell — only $outerClassCount own class(es), wraps: $([System.IO.Path]::GetFileName($nestedJars[0].FullName))")
        }

        $totalClasses=$classPaths.Count

        # obfuscation heuristics on class paths (merged two loops into one)
        if($totalClasses -gt 10){
            $shortCnt=0;$singleCnt=0
            foreach($cp in $classPaths){
                $parts=$cp.Split('/')
                if($parts.Count -ge 3 -and $parts.Count -le 6){
                    $allS=$true;for($i=0;$i -lt $parts.Count-1;$i++){if($parts[$i].Length -gt 2){$allS=$false;break}}
                    if($allS){$shortCnt++}
                }
                if([System.IO.Path]::GetFileNameWithoutExtension($cp).Length -le 2){$singleCnt++}
            }
            if($shortCnt/$totalClasses -gt 0.4){Add-Flag "Short-path obfuscation (a/b/c/ structure)"}
            if($singleCnt/$totalClasses -gt 0.5){Add-Flag "Single-char class names (heavy obfuscation)"}
        }

        # suspicious roots
        $rootsSeen=[System.Collections.Generic.HashSet[string]]::new()
        foreach($cp in $classPaths){
            foreach($root in $suspiciousRoots){
                if(-not $rootsSeen.Contains($root)-and $cp.StartsWith("$root/")){
                    Add-Filtered "Suspicious package: $root";[void]$rootsSeen.Add($root)
                }
            }
        }

        # bypass + obfuscation counters gathered in single class read loop
        $rtExec=$false;$httpDl=$false;$httpEx=$false
        $byObf=0;$byNum=0;$byUni=0;$byTot=0
        $obTot=0;$obNum=0;$obUni=0;$obFW=0;$obJP=0;$obS1=0;$obS2=0;$obGib=0;$obNV=0;$obConf=0;$obPkg=0
        $sample=[System.Text.StringBuilder]::new();$sampSz=0

        foreach($e in $classEntries){
            $n=$e.FullName; $segs=($n -replace '\.class$','') -split '/'; $cn=$segs[-1]
            $isLang=$LangFileRegex.IsMatch($n)
            Scan-EntryPath $n $isLang

            # bypass path counters
            $byTot++
            if($cn -match '^\d+$'){$byNum++}
            if($cn -match '[^\x00-\x7F]'){$byUni++}
            $cs=0;$mc=0;foreach($s in $segs){if($s.Length -eq 1){$cs++;if($cs -gt $mc){$mc=$cs}}else{$cs=0}};if($mc -ge 3){$byObf++}

            # obfuscation name counters
            if(-not $isWL){
                $obTot++
                if($cn -match '^\d+$'){$obNum++}
                if($cn -match '[^\x00-\x7F]'){$obUni++}
                if($cn -match '[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]'){$obFW++}
                if($cn -match '[\u3040-\u309F\u30A0-\u30FF]'){$obJP++}
                if($cn -match '^[a-zA-Z]$'){$obS1++}
                if($cn -match '^[a-zA-Z]{2}$'){$obS2++}
                if($cn -match '^[Il1O0]+$' -or $cn -match '^[_]+$'){$obConf++}
                if($cn.Length -ge 3 -and $cn.Length -le 8 -and $cn -match '^[a-zA-Z]+$'){
                    $vc=([regex]::Matches($cn,'[aeiouAEIOU]')).Count
                    if($vc -eq 0){$obNV++}
                    if($cn -match '[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]{3,}' -and ($vc/$cn.Length) -lt 0.3){$obGib++}
                }
                foreach($s in $segs[0..($segs.Count-2)]){if($s.Length -eq 1){$obPkg++}}
            }

            # content read
            try{
                $rd=Read-Bytes $e; $ct=[System.Text.Encoding]::ASCII.GetString($script:buf,0,$rd)
                Proc-Content $ct $rd $isLang $true
                if($RuntimeExecRegex.IsMatch($ct)){$rtExec=$true}
                if($ct.Contains("openConnection")-and $ct.Contains("HttpURLConnection")-and $ct.Contains("FileOutputStream")){$httpDl=$true}
                if($ct.Contains("openConnection")-and $ct.Contains("setDoOutput")-and $ct.Contains("getOutputStream")-and $ct.Contains("getProperty")){$httpEx=$true}
                if(-not $isWL -and $sampSz -lt 150000 -and $e.Length -lt 100000){[void]$sample.Append($ct);$sampSz+=$rd}
            }catch{}
        }

        # text entries
        foreach($e in $textEntries){
            $n=$e.FullName; $isLang=$LangFileRegex.IsMatch($n); $isDct=$DictFileRegex.IsMatch($n)
            Scan-EntryPath $n $isLang
            if($isDct){continue}
            try{
                $rd=Read-Bytes $e; $ascii=[System.Text.Encoding]::ASCII.GetString($script:buf,0,$rd)
                $ext=[System.IO.Path]::GetExtension($n).ToLower()
                if($ext -eq ".txt" -and (Is-WordFile $ascii)){continue}
                Proc-Content $ascii $rd $isLang $false
            }catch{}
        }

        # manifest content scan (deep patterns)
        if($null -ne $manifestEntry){
            try{$rd=Read-Bytes $manifestEntry;$ascii=[System.Text.Encoding]::ASCII.GetString($script:buf,0,$rd);Proc-Content $ascii $rd $false $false}catch{}
        }

        # nested jars
        foreach($nj in $nestedJars){
            try{
                $ns=$nj.Open();$ms=[System.IO.MemoryStream]::new();$ns.CopyTo($ms);$ns.Close();$ms.Position=0
                $iz=[System.IO.Compression.ZipArchive]::new($ms,[System.IO.Compression.ZipArchiveMode]::Read)
                foreach($ie in $iz.Entries){
                    $in=$ie.FullName; $iext=[System.IO.Path]::GetExtension($in).ToLower()
                    $iLang=$LangFileRegex.IsMatch($in); $iDct=$DictFileRegex.IsMatch($in)
                    Scan-EntryPath $in $iLang
                    if(($TextExtensions.Contains($iext)-or $ManifestRegex.IsMatch($in))-and $ie.Length -lt 2MB -and -not $iDct){
                        try{$rd=Read-Bytes $ie;$ascii=[System.Text.Encoding]::ASCII.GetString($script:buf,0,$rd);if($iext -eq ".txt" -and (Is-WordFile $ascii)){continue};Proc-Content $ascii $rd $iLang $false}catch{}
                    }
                    if($iext -eq ".class" -and $ie.Length -lt 512KB -and $ie.Length -gt 10){
                        $byTot++
                        $isegs=($in -replace '\.class$','') -split '/'; $icn=$isegs[-1]
                        if($icn -match '^\d+$'){$byNum++};if($icn -match '[^\x00-\x7F]'){$byUni++}
                        $c2=0;$m2=0;foreach($s in $isegs){if($s.Length -eq 1){$c2++;if($c2 -gt $m2){$m2=$c2}}else{$c2=0}};if($m2 -ge 3){$byObf++}
                        try{$rd=Read-Bytes $ie;$ict=[System.Text.Encoding]::ASCII.GetString($script:buf,0,$rd);Proc-Content $ict $rd $false $true
                            if($RuntimeExecRegex.IsMatch($ict)){$rtExec=$true}
                            if($ict.Contains("openConnection")-and $ict.Contains("HttpURLConnection")-and $ict.Contains("FileOutputStream")){$httpDl=$true}
                            if($ict.Contains("openConnection")-and $ict.Contains("setDoOutput")-and $ict.Contains("getOutputStream")-and $ict.Contains("getProperty")){$httpEx=$true}
                        }catch{}
                    }
                }
                $iz.Dispose();$ms.Dispose()
            }catch{}
        }

    }catch{
    }finally{if($null -ne $zip){$zip.Dispose()}}

    # resolve fullwidth matches
    $fwMs=@($found|Where-Object{$FullwidthRegex.IsMatch($_)})
    foreach($fw in $fwMs){
        $best=$null
        foreach($cs in $fwCheatPool){if($cs.Contains($fw)-and($null -eq $best -or $cs.Length -lt $best.Length)){$best=$cs}}
        if($null -ne $best){[void]$found.Remove($fw);[void]$found.Add($best)}
    }

    # cheat filename tokens
    $filePatterns=[System.Collections.Generic.List[string]]::new($found)
    if(-not $WhitelistTokenRegex.IsMatch([System.IO.Path]::GetFileNameWithoutExtension($FileName))){
        $fnLow=$FileName.ToLower()
        foreach($tok in $knownCheatFileTokens){if($fnLow -match [regex]::Escape($tok.ToLower())){$filePatterns.Add("Known cheat filename token: $tok")}}
    }

    # bypass flag evaluation
    $byObfPct=if($byTot -ge 10){[math]::Round(($byObf/$byTot)*100)}else{0}
    $byNumPct=if($byTot -ge 5){[math]::Round(($byNum/$byTot)*100)}else{0}
    $byUniPct=if($byTot -ge 5){[math]::Round(($byUni/$byTot)*100)}else{0}
    if($rtExec -and $byObfPct -ge 25){$bypassFlags.Add("Runtime.exec() in obfuscated code — can run arbitrary OS commands")}
    if($httpDl){$bypassFlags.Add("HTTP file download — fetches and writes files from a remote server at runtime")}
    if($httpEx){$bypassFlags.Add("HTTP POST exfiltration — sends system data to an external server")}
    if($byTot -ge 10 -and $byObfPct -ge 25){$bypassFlags.Add("Heavy obfuscation — $byObfPct% of classes use single-letter path segments (a/b/c style)")}
    if($byNumPct -ge 20){$bypassFlags.Add("Numeric class names — $byNumPct% of classes have numeric-only names (e.g. 1234.class)")}
    if($byUniPct -ge 10){$bypassFlags.Add("Unicode class names — $byUniPct% of classes use non-ASCII characters")}
    $legitIds=[System.Collections.Generic.HashSet[string]]([string[]]@("vmp-fabric","vmp","lithium","sodium","iris","fabric-api","modmenu","ferrite-core","lazydfu","starlight","entityculling","memoryleakfix","krypton","c2me-fabric","smoothboot-fabric","immediatelyfast","noisium","threadtweak"))
    $dCnt=($bypassFlags|Where-Object{$_ -match "Runtime\.exec|HTTP file download|HTTP POST|Heavy obfuscation|Suspicious nested JAR"}).Count
    if($outerModId -and $legitIds.Contains($outerModId) -and $dCnt -gt 0){$bypassFlags.Add("Fake mod identity — claims to be '$outerModId' but contains dangerous code")}

    # obfuscation flag evaluation
    if(-not $isWL -and $obTot -ge 5){
        $pct={param($n)[math]::Round(($n/$obTot)*100)}
        $nP=&$pct $obNum;$uP=&$pct $obUni;$fP=&$pct $obFW;$jP=&$pct $obJP
        $s1P=&$pct $obS1;$s2P=&$pct $obS2;$gP=&$pct $obGib;$nvP=&$pct $obNV;$cP=&$pct $obConf
        if($nP  -ge 20){$obfFlags.Add("Numeric class names — $nP% of classes have numeric-only names")}
        if($uP  -ge 10){$obfFlags.Add("Unicode class names — $uP% of classes use non-ASCII characters")}
        if($fP  -gt  0){$obfFlags.Add("Fullwidth Unicode class names — $fP% use ａｂｃ/ＡＢＣ/０１２ chars ($obFW classes)")}
        if($jP  -gt  0){$obfFlags.Add("Japanese obfuscation — $jP% use hiragana/katakana class names ($obJP classes)")}
        if($s1P -ge 15){$obfFlags.Add("Single-letter class names — $s1P% ($obS1 classes)")}
        if($s2P -ge 20){$obfFlags.Add("Two-letter class names — $s2P% ($obS2 classes)")}
        if($gP  -ge  5){$obfFlags.Add("Gibberish class names — $gP% have no vowels / consonant clusters ($obGib classes)")}
        if($nvP -ge  8){$obfFlags.Add("No-vowel class names — $nvP% ($obNV classes)")}
        if($cP  -ge  3){$obfFlags.Add("Confusion-char names (Il1O0/_) — $cP% ($obConf classes)")}
        if($obPkg -ge 6){$obfFlags.Add("Single-char package paths — $obPkg path segments like a/b/c")}
        $sStr=$sample.ToString()
        $fwM=$FullwidthRegex.Matches($sStr)
        if($fwM.Count -gt 0){
            $ex=($fwM|Select-Object -First 3|ForEach-Object{$_.Value})-join ", "
            $obfFlags.Add("Fullwidth strings in class content — $($fwM.Count) occurrences (e.g. $ex)")
        }
        foreach($on in $cheatObfuscators.Keys){foreach($p in $cheatObfuscators[$on]){if($sStr.Contains($p)){$obfFlags.Add("Known cheat obfuscator detected — $on (matched: $p)");break}}}
    }

    return @{ File=$FileName; DeepFlags=$filePatterns; BypassFlags=$bypassFlags; ObfFlags=$obfFlags }
})

# ── Runspace pool dispatcher ──────────────────────────────────────
$threadCount = [Math]::Min([Environment]::ProcessorCount, $activeJars.Count)
$pool = [RunspaceFactory]::CreateRunspacePool(1, $threadCount)
$pool.ApartmentState = "MTA"; $pool.Open()

$jobs = [System.Collections.Generic.List[hashtable]]::new()
foreach ($jar in $activeJars) {
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript($rsScanBlock).AddArgument($jar.FullName).AddArgument($jar.Name).AddArgument($rsInitVars)
    $jobs.Add(@{ PS = $ps; Handle = $ps.BeginInvoke(); Name = $jar.Name })
}

# Progress + collect loop — EndInvoke is called as each job completes
# so runspaces are freed immediately and can't deadlock the pool.
$total    = $jobs.Count
$pending  = [System.Collections.Generic.List[hashtable]]::new($jobs)
$lastShown = ""
$doneCount = 0

$hardCheatIndicators = [string[]]@(
    "Backdoor","Stealer","TokenGrabber","ReverseShell","C2Server",
    "KillAura","AimAssist","AutoCrystal","Blink","FakeLag","PacketFly",
    "AntiAntiCheat","GrimBypass","NCPBypass","AACBypass","WatchdogBypass",
    "Runtime command execution","Known cheat filename token","Known obfuscator"
)
$verifiedNamesSet = [System.Collections.Generic.HashSet[string]]::new([string[]]@($verifiedNames), [System.StringComparer]::OrdinalIgnoreCase)

while ($pending.Count -gt 0) {
    $finished = $pending | Where-Object { $_.Handle.IsCompleted }
    foreach ($job in $finished) {
        [void]$pending.Remove($job)
        $doneCount++
        $lastShown = $job.Name

        $result = $null
        try { $result = $job.PS.EndInvoke($job.Handle) | Select-Object -Last 1 } catch {}
        $job.PS.Dispose()

        if ($null -ne $result) {
            $hash = $hashMap[$result.File]; $src = $srcMap[$result.File]

            # Deep scan classification
            $patterns = [System.Collections.Generic.List[string]]$result.DeepFlags
            if ($patterns.Count -gt 0) {
                $hasHard = $false
                foreach ($p in $patterns) { foreach ($hc in $hardCheatIndicators) { if ($p -like "*$hc*") { $hasHard = $true; break } }; if ($hasHard) { break } }
                if (-not $hasHard) { $patterns = [System.Collections.Generic.List[string]]@($patterns | Where-Object { $_ -ne "ClientPlayerInteractionManagerMixin" }) }
                $obfuscationOnlyFlags = @(
                    "Short-path obfuscation (a/b/c/ structure)",
                    "Single-char class names (heavy obfuscation)",
                    "Japanese text in config/resource",
                    "Chinese text in config/resource"
                )
                $seriousNonLic = @($patterns | Where-Object {
                    $_ -ne "License/HWID check detected" -and $obfuscationOnlyFlags -notcontains $_
                })
                if (($patterns | Where-Object { $_ -eq "License/HWID check detected" }).Count -gt 0 -and $seriousNonLic.Count -eq 0) {
                    $patterns = [System.Collections.Generic.List[string]]@($patterns | Where-Object { $_ -ne "License/HWID check detected" })
                }
                if ($patterns.Count -gt 0) {
                    $suspicious.Add(@{ File = $result.File; Hash = $hash; Patterns = $patterns; DlSource = $src })
                } elseif (-not $verifiedNamesSet.Contains($result.File)) {
                    $unknown.Add(@{ File = $result.File; Hash = $hash; DlSource = $src })
                }
            } elseif (-not $verifiedNamesSet.Contains($result.File)) {
                $unknown.Add(@{ File = $result.File; Hash = $hash; DlSource = $src })
            }

            # Bypass / injection flags
            if ($result.BypassFlags.Count -gt 0) { $injected.Add(@{ File = $result.File; Flags = $result.BypassFlags }) }

            # Obfuscation flags (only if not already flagged as suspicious or injected)
            if ($result.ObfFlags.Count -gt 0) {
                $alreadyFlagged = ($suspicious | Where-Object { $_.File -eq $result.File }).Count -gt 0 -or
                                  ($injected   | Where-Object { $_.File -eq $result.File }).Count -gt 0
                if (-not $alreadyFlagged) { $obfuscated.Add(@{ File = $result.File; Flags = $result.ObfFlags }) }
            }
        }
    }

    # Update progress bar after processing all newly-finished jobs this tick
    $pct2 = [int](($doneCount / $total) * 100)
    $bar2 = "#" * [int]($pct2 / 5); $emp2 = "-" * (20 - $bar2.Length)
    Write-Host "`r  [$bar2$emp2] $pct2%  $lastShown                              " -NoNewline -ForegroundColor Yellow

    if ($pending.Count -gt 0) { Start-Sleep -Milliseconds 100 }
}
Write-Host "`r  [####################] 100% Done                                                    " -ForegroundColor Green
Write-Host ""

$pool.Close(); $pool.Dispose()

# ── Pass 2 summary (original style) ─────────────────────────────
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

# ================================================================
#  PASS 3 — BYPASS / INJECTION RESULTS
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 3" -NoNewline -ForegroundColor Yellow
Write-Host " — Bypass/injection scan complete." -ForegroundColor DarkGray
Write-Host ""

if ($injected.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " $($injected.Count) INJECTED/BYPASS MOD(S) DETECTED " -ForegroundColor White -BackgroundColor DarkRed
    foreach ($n in $injected) {
        Write-Host "    - $($n.File)" -ForegroundColor Red
        foreach ($f in $n.Flags) { Write-Host "        $f" -ForegroundColor DarkGray }
    }
} else {
    Write-Host "  " -NoNewline
    Write-Host " No injection or bypass markers found " -ForegroundColor Black -BackgroundColor DarkGreen
}
Write-Host ""

# ================================================================
#  PASS 4 — OBFUSCATION RESULTS
# ================================================================

Write-Host "  " -NoNewline
Write-Host "Pass 4" -NoNewline -ForegroundColor Yellow
Write-Host " — Obfuscation analysis complete." -ForegroundColor DarkGray
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

 $jvmSteps = @("Reading process list","Fetching command lines","Checking -javaagent flags","Checking JVM boot flags","Finalizing")
 $m2 = 0
foreach ($step in $jvmSteps) {
    $m2++
    $pct5 = [int](($m2 / $jvmSteps.Count) * 100)
    $bar5 = "#" * [int]($pct5 / 5); $emp5 = "-" * (20 - $bar5.Length)
    Write-Host "`r  [$bar5$emp5] $pct5%  $step                              " -NoNewline -ForegroundColor Yellow
    Start-Sleep -Milliseconds 120
}

 $jvmIssues = Invoke-JvmScan

Write-Host "`r  [####################] 100% Done                                                    " -ForegroundColor Green
Write-Host ""
if ($jvmIssues.Count -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host " JVM ISSUES DETECTED " -ForegroundColor White -BackgroundColor DarkRed
    foreach ($issue in $jvmIssues) {
        if ($issue -match "^(.+?) — (.+) \(path: (.+)\)$") {
            Write-Host "    - $($Matches[1])" -ForegroundColor Red
            Write-Host "        $($Matches[2])" -ForegroundColor DarkGray
            $display = if ($Matches[3].Length -gt 60) { "..." + $Matches[3].Substring($Matches[3].Length - 57) } else { $Matches[3] }
            Write-Host "        $display" -ForegroundColor DarkGray
        } else { Write-Host "    - $issue" -ForegroundColor Red }
    }
} else {
    Write-Host "  " -NoNewline
    Write-Host " JVM looks clean " -ForegroundColor Black -BackgroundColor DarkGreen
}
Write-Host ""

# ================================================================
#  RESULTS
# ================================================================

 $sep = "  " + ("=" * 74)

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
    if ($m.Name -and $m.Name -ne $m.File) { Write-Host "  ->  $($m.File)" -ForegroundColor DarkGray } else { Write-Host "" }
}

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
        } else { Write-Host "" }
    }
}

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
                "AimAssist"                           { "Automatically aims at players" }
                "KillAura"                            { "Auto-attacks nearby players/entities" }
                "AutoCrystal"                         { "Automatically places and detonates end crystals" }
                "AutoHitCrystal"                      { "Auto-hits crystals for burst damage" }
                "TriggerBot"                          { "Auto-clicks when crosshair is on a player" }
                "ShieldBreaker"                       { "Bypasses or breaks opponent's shield" }
                "ShieldDisabler"                      { "Blocks opponent from raising their shield" }
                "AutoTotem"                           { "Auto-moves totem to offhand before death" }
                "AutoArmor"                           { "Automatically equips best available armor" }
                "AutoPot"                             { "Auto-throws splash potions in combat" }
                "AutoDoubleHand"                      { "Manages both hands automatically in combat" }
                "FakeLag"                             { "Simulates lag to desync from server" }
                "Blink"                               { "Holds packets then releases for teleport effect" }
                "PacketFly"                           { "Flies by manipulating movement packets" }
                "Backdoor"                            { "Hidden remote access code detected" }
                "TokenGrabber"                        { "Discord/account token stealing code" }
                "Stealer"                             { "Credential/data stealing code" }
                "chainlibs"                           { "Known obfuscated cheat library package" }
                "phantom-refmap"                      { "Refmap name used by known cheat clients" }
                "xyz.greaj"                           { "Known cheat developer package: xyz.greaj" }
                "jnativehook"                         { "Native keyboard/mouse hook library (input capture)" }
                "imgui*"                              { "ImGui UI library, common in injected cheat overlays" }
                "LicenseCheckMixin"                   { "License check mixin, typical in paid cheats" }
                "Japanese obfuscation"                { "Japanese character class names used to obfuscate code" }
                "Known obfuscator*"                   { "Professional obfuscator tool detected in bytecode" }
                "Fake mod identity*"                  { "JAR claims to be a trusted mod but contains malicious code" }
                "HTTP POST exfiltration*"             { "Sends system/user data to a remote server" }
                "HTTP file download*"                 { "Downloads and writes files from remote server at runtime" }
                "Runtime command execution*"          { "Executes OS commands from obfuscated code" }
                "Hollow shell*"                       { "Outer JAR has almost no code — likely a wrapper for hidden payload" }
                "Java agent manifest*"                { "Declares a Java agent — can modify classes at runtime" }
                "Suspicious nested JAR*"              { "Contains unversioned nested JAR with no known dependency" }
                default                               { "Suspicious string matched in JAR contents" }
            }
            Write-Host "         " -NoNewline
            Write-Host " $p " -NoNewline -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "  $explanation" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

if ($injected.Count -gt 0) {
    Write-Host ""
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host " o " -NoNewline -ForegroundColor White -BackgroundColor DarkMagenta
    Write-Host "  BYPASS / INJECTION  ($($injected.Count))" -ForegroundColor Magenta
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host ""
    foreach ($m in $injected) {
        Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkMagenta
        Write-Host "  │ " -ForegroundColor DarkMagenta -NoNewline
        Write-Host " INJECTION " -NoNewline -ForegroundColor White -BackgroundColor DarkMagenta
        Write-Host "  $($m.File)" -ForegroundColor Yellow
        Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkMagenta
        foreach ($flag in $m.Flags) {
            if ($flag -match "^(.+?) — (.+)$") { $ft = $Matches[1]; $fd = $Matches[2] } else { $ft = $flag; $fd = "" }
            Write-Host "  │" -ForegroundColor DarkMagenta
            Write-Host "  │  " -ForegroundColor DarkMagenta -NoNewline
            Write-Host "◉ " -ForegroundColor Magenta -NoNewline
            Write-Host $ft -ForegroundColor White
            if ($fd -ne "") { Write-Host "  │    " -ForegroundColor DarkMagenta -NoNewline; Write-Host $fd -ForegroundColor DarkGray }
        }
        Write-Host "  │" -ForegroundColor DarkMagenta
        Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkMagenta
        Write-Host ""
    }
}

if ($obfuscated.Count -gt 0) {
    Write-Host ""
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host " o " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host "  OBFUSCATED MODS  ($($obfuscated.Count))" -ForegroundColor Yellow
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host ""
    foreach ($o in $obfuscated) {
        Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
        Write-Host "  │ " -ForegroundColor DarkYellow -NoNewline
        Write-Host " OBFUSCATED " -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
        Write-Host "  $($o.File)" -ForegroundColor Yellow
        Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkYellow
        foreach ($f in $o.Flags) {
            if ($f -match "^(.+?) — (.+)$") { $ft = $Matches[1]; $fd = $Matches[2] } else { $ft = $f; $fd = "" }
            Write-Host "  │" -ForegroundColor DarkYellow
            Write-Host "  │  " -ForegroundColor DarkYellow -NoNewline
            Write-Host "⚑ " -ForegroundColor Yellow -NoNewline
            Write-Host $ft -ForegroundColor White
            if ($fd -ne "") { Write-Host "  │    " -ForegroundColor DarkYellow -NoNewline; Write-Host $fd -ForegroundColor DarkGray }
        }
        Write-Host "  │" -ForegroundColor DarkYellow
        Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
        Write-Host ""
    }
}

if ($jvmIssues.Count -gt 0) {
    Write-Host ""
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host "  " -NoNewline
    Write-Host " o " -NoNewline -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "  JVM / RUNTIME INJECTION  ($($jvmIssues.Count))" -ForegroundColor Yellow
    Write-Host $sep -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
    Write-Host "  │ " -ForegroundColor DarkYellow -NoNewline
    Write-Host " JVM " -ForegroundColor Black -BackgroundColor Yellow -NoNewline
    Write-Host "  javaw / java process" -ForegroundColor Yellow
    Write-Host ("  │ " + ("─" * 66)) -ForegroundColor DarkYellow
    foreach ($issue in $jvmIssues) {
        if ($issue -match "^(.+?) — (.+) \(path: (.+)\)$") { $ft = $Matches[1]; $fd = $Matches[2]; $fp = $Matches[3] }
        elseif ($issue -match "^(.+?) — (.+)$") { $ft = $Matches[1]; $fd = $Matches[2]; $fp = "" }
        else { $ft = $issue; $fd = ""; $fp = "" }
        Write-Host "  │" -ForegroundColor DarkYellow
        Write-Host "  │  " -ForegroundColor DarkYellow -NoNewline
        Write-Host "◉ " -ForegroundColor Yellow -NoNewline
        Write-Host $ft -ForegroundColor White
        if ($fd -ne "") { Write-Host "  │    " -ForegroundColor DarkYellow -NoNewline; Write-Host $fd -ForegroundColor DarkGray }
        if ($fp -ne "") {
            $display = if ($fp.Length -gt 60) { "..." + $fp.Substring($fp.Length - 57) } else { $fp }
            Write-Host "  │    " -ForegroundColor DarkYellow -NoNewline; Write-Host $display -ForegroundColor DarkGray
        }
    }
    Write-Host "  │" -ForegroundColor DarkYellow
    Write-Host ("  " + ("─" * 70)) -ForegroundColor DarkYellow
    Write-Host ""
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
