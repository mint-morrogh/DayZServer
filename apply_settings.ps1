## ============================================
## DayZ Server Settings Patcher
## Reads server_settings.json and patches all
## config files across the server directory.
## ============================================

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$settingsFile = Join-Path $root "server_settings.json"
$serverCfg = Join-Path $root "serverDZ.cfg"
$missionDir = Join-Path $root "mpmissions\dayzOffline.chernarusplus"
$gameplayFile = Join-Path $missionDir "cfggameplay.json"
$eventsFile = Join-Path $missionDir "db\events.xml"
$globalsFile = Join-Path $missionDir "db\globals.xml"
$zenSkillsFile = Join-Path $missionDir "custom\types_zenskills.xml"
$horseGearFile = Join-Path $missionDir "custom\types_dayzhorse.xml"
$dogGearFile = Join-Path $missionDir "custom\types_dayzdog.xml"
$planesFile = Join-Path $missionDir "custom\types_lmplanes.xml"
$pvzGlobalsFile = Join-Path $root "config\PvZmoD_CustomisableZombies_Profile\PvZmoD_CustomisableZombies_Globals.xml"
$pvzCharsFile = Join-Path $root "config\PvZmoD_CustomisableZombies_Profile\PvZmoD_CustomisableZombies_Characteristics.xml"
$zenSleepFile = Join-Path $root "config\Zenarchist\ZenSleepConfig.json"

# --- Load settings ---
if (-not (Test-Path $settingsFile)) {
    Write-Host "ERROR: server_settings.json not found at $settingsFile" -ForegroundColor Red
    exit 1
}

$settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
Write-Host "Loaded settings from server_settings.json" -ForegroundColor Cyan

# =============================================
# 1. PATCH serverDZ.cfg
# =============================================
if (Test-Path $serverCfg) {
    Write-Host "`nPatching serverDZ.cfg..." -ForegroundColor Yellow
    $cfg = Get-Content $serverCfg -Raw

    $s = $settings.server
    $t = $settings.time
    $n = $settings.network

    # Server settings
    $cfg = $cfg -replace '(?m)^hostname\s*=\s*"[^"]*"', "hostname = `"$($s.name)`""
    $cfg = $cfg -replace '(?m)^password\s*=\s*"[^"]*"', "password = `"$($s.password)`""
    $cfg = $cfg -replace '(?m)^passwordAdmin\s*=\s*"[^"]*"', "passwordAdmin = `"$($s.adminPassword)`""
    $cfg = $cfg -replace '(?m)^maxPlayers\s*=\s*\d+', "maxPlayers = $($s.maxPlayers)"

    # Time settings
    $cfg = $cfg -replace '(?m)^serverTime\s*=\s*"[^"]*"', "serverTime = `"$($t.startTime)`""
    $cfg = $cfg -replace '(?m)^serverTimeAcceleration\s*=\s*[\d.]+', "serverTimeAcceleration = $($t.acceleration)"
    $cfg = $cfg -replace '(?m)^serverNightTimeAcceleration\s*=\s*[\d.]+', "serverNightTimeAcceleration = $($t.nightAcceleration)"
    $persistVal = if ($t.persistent) { "1" } else { "0" }
    $cfg = $cfg -replace '(?m)^serverTimePersistent\s*=\s*\d+', "serverTimePersistent = $persistVal"

    # Network settings
    $vonVal = if ($n.vonEnabled) { "0" } else { "1" }  # disableVoN is inverted
    $cfg = $cfg -replace '(?m)^disableVoN\s*=\s*\d+', "disableVoN = $vonVal"
    $cfg = $cfg -replace '(?m)^vonCodecQuality\s*=\s*\d+', "vonCodecQuality = $($n.vonQuality)"
    $tpVal = if ($n.thirdPerson) { "0" } else { "1" }  # disable3rdPerson is inverted
    $cfg = $cfg -replace '(?m)^disable3rdPerson\s*=\s*\d+', "disable3rdPerson = $tpVal"
    $chVal = if ($n.crosshair) { "0" } else { "1" }    # disableCrosshair is inverted
    $cfg = $cfg -replace '(?m)^disableCrosshair\s*=\s*\d+', "disableCrosshair = $chVal"

    Set-Content $serverCfg -Value $cfg -NoNewline
    Write-Host "  serverDZ.cfg updated" -ForegroundColor Green
} else {
    Write-Host "WARNING: serverDZ.cfg not found, skipping" -ForegroundColor Red
}

# =============================================
# 2. PATCH cfggameplay.json
# =============================================
if (Test-Path $gameplayFile) {
    Write-Host "`nPatching cfggameplay.json..." -ForegroundColor Yellow
    $gp = Get-Content $gameplayFile -Raw | ConvertFrom-Json
    $g = $settings.gameplay

    # General
    $gp.GeneralData.disableBaseDamage = $g.disableBaseDamage
    $gp.GeneralData.disableContainerDamage = $g.disableContainerDamage

    # Stamina
    $gp.PlayerData.StaminaData.staminaMax = $g.staminaMax
    $gp.PlayerData.StaminaData.staminaMinCap = $g.staminaMinCap
    $gp.PlayerData.StaminaData.staminaWeightLimitThreshold = $g.staminaWeightThreshold
    $gp.PlayerData.StaminaData.sprintStaminaModifierErc = $g.sprintStaminaModifier
    $gp.PlayerData.StaminaData.sprintStaminaModifierCro = $g.sprintStaminaModifier
    $gp.PlayerData.StaminaData.meleeStaminaModifier = $g.meleeStaminaModifier

    # World
    $gp.WorldsData.lightingConfig = $g.lightingConfig

    # Base building
    if ($g.relaxedBaseBuilding) {
        $gp.BaseBuildingData.HologramData.disableIsCollidingBBoxCheck = $true
        $gp.BaseBuildingData.HologramData.disableIsClippingRoofCheck = $true
        $gp.BaseBuildingData.HologramData.disableIsCollidingGPlotCheck = $true
        $gp.BaseBuildingData.HologramData.disableIsCollidingAngleCheck = $true
        $gp.BaseBuildingData.HologramData.disableHeightPlacementCheck = $true
        $gp.BaseBuildingData.HologramData.disableColdAreaBuildingCheck = $true
        $gp.BaseBuildingData.ConstructionData.disablePerformRoofCheck = $true
        $gp.BaseBuildingData.ConstructionData.disableIsCollidingCheck = $true
        $gp.BaseBuildingData.ConstructionData.disableDistanceCheck = $true
    } else {
        $gp.BaseBuildingData.HologramData.disableIsCollidingBBoxCheck = $false
        $gp.BaseBuildingData.HologramData.disableIsClippingRoofCheck = $false
        $gp.BaseBuildingData.HologramData.disableIsCollidingGPlotCheck = $false
        $gp.BaseBuildingData.HologramData.disableIsCollidingAngleCheck = $false
        $gp.BaseBuildingData.HologramData.disableHeightPlacementCheck = $false
        $gp.BaseBuildingData.HologramData.disableColdAreaBuildingCheck = $false
        $gp.BaseBuildingData.ConstructionData.disablePerformRoofCheck = $false
        $gp.BaseBuildingData.ConstructionData.disableIsCollidingCheck = $false
        $gp.BaseBuildingData.ConstructionData.disableDistanceCheck = $false
    }

    # UI / Map
    $gp.UIData.use3DMap = $g.use3DMap
    $gp.MapData.displayPlayerPosition = $g.showPlayerOnMap
    $gp.MapData.ignoreMapOwnership = $g.mapWithoutItem
    $gp.MapData.ignoreNavItemsOwnership = $g.compassWithoutItem

    $gp | ConvertTo-Json -Depth 10 | Set-Content $gameplayFile
    Write-Host "  cfggameplay.json updated" -ForegroundColor Green
} else {
    Write-Host "WARNING: cfggameplay.json not found, skipping" -ForegroundColor Red
}

# =============================================
# 3. PATCH events.xml (zombie + animal spawns)
# =============================================
if (Test-Path $eventsFile) {
    Write-Host "`nPatching events.xml (zombie + animal spawns)..." -ForegroundColor Yellow
    [xml]$events = Get-Content $eventsFile

    # Zombie spawn mapping
    $zombieMap = @{
        "InfectedCity"          = $settings.zombies.city
        "InfectedCityTier1"     = $settings.zombies.cityCoastal
        "InfectedArmy"          = $settings.zombies.military
        "InfectedArmyHard"      = $settings.zombies.militaryHard
        "InfectedVillage"       = $settings.zombies.village
        "InfectedVillageTier1"  = $settings.zombies.villageCoastal
        "InfectedSolitude"      = $settings.zombies.wilderness
        "InfectedPolice"        = $settings.zombies.police
        "InfectedPoliceHard"    = $settings.zombies.policeHard
        "InfectedMedic"         = $settings.zombies.medic
        "InfectedFirefighter"   = $settings.zombies.firefighter
        "InfectedIndustrial"    = $settings.zombies.industrial
        "InfectedReligious"     = $settings.zombies.religious
        "InfectedPrisoner"      = $settings.zombies.prisoner
        "InfectedNBC"           = $settings.zombies.nbc
        "InfectedNBCYellow"     = $settings.zombies.nbc
    }

    # Animal spawn mapping
    if ($settings.animals) {
        $animalMap = @{
            "AnimalWildDog"   = $settings.animals.wildDogs
            "AnimalWildHorse" = $settings.animals.wildHorses
        }
    } else {
        $animalMap = @{}
    }

    foreach ($event in $events.events.event) {
        if ($zombieMap.ContainsKey($event.name)) {
            $vals = $zombieMap[$event.name]
            $event.nominal = [string]$vals.nominal
            $event.min = [string]$vals.min
            $event.max = [string]$vals.max
        }
        if ($animalMap.ContainsKey($event.name)) {
            $vals = $animalMap[$event.name]
            $event.nominal = [string]$vals.nominal
            $event.min = [string]$vals.min
            $event.max = [string]$vals.max
        }
    }

    $events.Save($eventsFile)
    Write-Host "  events.xml updated" -ForegroundColor Green
} else {
    Write-Host "WARNING: events.xml not found, skipping" -ForegroundColor Red
}

# =============================================
# 4. PATCH globals.xml (loot economy)
# =============================================
if (Test-Path $globalsFile) {
    Write-Host "`nPatching globals.xml (loot economy)..." -ForegroundColor Yellow
    [xml]$globals = Get-Content $globalsFile

    $globalMap = @{
        "ZombieMaxCount"              = $settings.lootEconomy.zombieMaxCount
        "AnimalMaxCount"              = $settings.lootEconomy.animalMaxCount
        "LootDamageMin"               = $settings.lootEconomy.lootDamageMin
        "LootDamageMax"               = $settings.lootEconomy.lootDamageMax
        "FoodDecay"                   = $settings.lootEconomy.foodDecay
        "CleanupLifetimeDeadPlayer"   = $settings.lootEconomy.cleanupLifetimeDeadPlayer
        "CleanupLifetimeRuined"       = $settings.lootEconomy.cleanupLifetimeRuined
        "RespawnLimit"                = $settings.lootEconomy.respawnLimit
        "FlagRefreshFrequency"        = $settings.lootEconomy.flagRefreshFrequency
        "FlagRefreshMaxDuration"      = $settings.lootEconomy.flagRefreshMaxDuration
    }

    foreach ($var in $globals.variables.var) {
        if ($globalMap.ContainsKey($var.name)) {
            $var.value = [string]$globalMap[$var.name]
        }
    }

    $globals.Save($globalsFile)
    Write-Host "  globals.xml updated" -ForegroundColor Green
} else {
    Write-Host "WARNING: globals.xml not found, skipping" -ForegroundColor Red
}

# =============================================
# 5. PATCH custom/types_zenskills.xml
# =============================================
if (Test-Path $zenSkillsFile) {
    Write-Host "`nPatching custom/types_zenskills.xml (skill items)..." -ForegroundColor Yellow
    [xml]$zen = Get-Content $zenSkillsFile

    $zenMap = @{
        "ZenSkills_Injector_ExpBoost"   = $settings.zenSkills.expBoostInjector
        "ZenSkills_Injector_PerkReset"  = $settings.zenSkills.perkResetInjector
        "ZenSkills_Book_Survival"       = $settings.zenSkills.survivalBook
        "ZenSkills_Book_Crafting"       = $settings.zenSkills.craftingBook
        "ZenSkills_Book_Hunting"        = $settings.zenSkills.huntingBook
        "ZenSkills_Book_Gathering"      = $settings.zenSkills.gatheringBook
    }

    foreach ($type in $zen.types.type) {
        if ($zenMap.ContainsKey($type.name)) {
            $vals = $zenMap[$type.name]
            $type.nominal = [string]$vals.nominal
            $type.min = [string]$vals.min
        }
    }

    $zen.Save($zenSkillsFile)
    Write-Host "  custom/types_zenskills.xml updated" -ForegroundColor Green
} else {
    Write-Host "INFO: custom/types_zenskills.xml not found, skipping (ZenSkills mod not installed?)" -ForegroundColor DarkYellow
}

# =============================================
# 6. PATCH PvZmoD zombie behaviour (Globals)
# =============================================
if ($settings.zombieBehavior -and (Test-Path $pvzGlobalsFile)) {
    Write-Host "`nPatching PvZmoD_CustomisableZombies_Globals.xml (zombie behaviour)..." -ForegroundColor Yellow
    $zb = $settings.zombieBehavior
    $pvzContent = Get-Content $pvzGlobalsFile -Raw

    # Speed clamp max (Day / Night)
    $pvzContent = $pvzContent -replace '(<Zombies_Clamp_Speed_Maxi\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zb.speedClampMaxDay)`${2}$($zb.speedClampMaxNight)`${3}"

    # Speed ratio (Day / Night)
    $pvzContent = $pvzContent -replace '(<Zombies_Speed_Ratio\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zb.speedRatioDay)`${2}$($zb.speedRatioNight)`${3}"

    # Health ratio (Day / Night)
    $pvzContent = $pvzContent -replace '(<Zombies_Health_Ratio\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zb.healthRatioDay)`${2}$($zb.healthRatioNight)`${3}"

    # Strength ratio (Day / Night)
    $pvzContent = $pvzContent -replace '(<Zombies_Strength_Ratio\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zb.strengthRatioDay)`${2}$($zb.strengthRatioNight)`${3}"

    Set-Content $pvzGlobalsFile -Value $pvzContent -NoNewline
    Write-Host "  PvZmoD Globals updated (speed/health/strength)" -ForegroundColor Green
} else {
    Write-Host "INFO: PvZmoD Globals not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 7. PATCH PvZmoD zombie vision (Characteristics)
# =============================================
if ($settings.zombieBehavior -and (Test-Path $pvzCharsFile)) {
    Write-Host "`nPatching PvZmoD_CustomisableZombies_Characteristics.xml (zombie vision)..." -ForegroundColor Yellow
    $zb = $settings.zombieBehavior
    $pvzChars = Get-Content $pvzCharsFile -Raw

    # Replace all Vision_Distance_Ratio Day values
    # Matches Day="<any>" and replaces with the configured value, preserving Night and other attributes
    $pvzChars = $pvzChars -replace '(<Vision_Distance_Ratio\s+Day=")[^"]*(")', "`${1}$($zb.visionRatioDay)`${2}"

    Set-Content $pvzCharsFile -Value $pvzChars -NoNewline
    Write-Host "  PvZmoD Characteristics updated (vision Day=$($zb.visionRatioDay))" -ForegroundColor Green
} else {
    Write-Host "INFO: PvZmoD Characteristics not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 8. PATCH horse gear (types_dayzhorse.xml)
# =============================================
if ($settings.horseGear -and (Test-Path $horseGearFile)) {
    Write-Host "`nPatching custom/types_dayzhorse.xml (horse tack)..." -ForegroundColor Yellow
    [xml]$horse = Get-Content $horseGearFile

    $horseMap = @{
        "Saddle"         = $settings.horseGear.saddle
        "Bridle"         = $settings.horseGear.bridle
        "HorseBags"      = $settings.horseGear.horseBags
        "Stable_dayz_kit"= $settings.horseGear.stableKit
    }

    foreach ($type in $horse.types.type) {
        if ($horseMap.ContainsKey($type.name)) {
            $vals = $horseMap[$type.name]
            $type.nominal = [string]$vals.nominal
            $type.min = [string]$vals.min
        }
    }

    $horse.Save($horseGearFile)
    Write-Host "  custom/types_dayzhorse.xml updated" -ForegroundColor Green
} else {
    Write-Host "INFO: types_dayzhorse.xml not found, skipping" -ForegroundColor DarkYellow
}

# =============================================
# 9. PATCH dog gear (types_dayzdog.xml)
# =============================================
if ($settings.dogGear -and (Test-Path $dogGearFile)) {
    Write-Host "`nPatching custom/types_dayzdog.xml (dog accessories)..." -ForegroundColor Yellow
    [xml]$dog = Get-Content $dogGearFile

    # Map class names to settings categories
    $collarNames = @("dog_collar","dog_collar_blue","dog_collar_red","dog_collar_green","dog_collar_white","dog_collar_yellow","dog_collar_grey")
    $vestNames = @("dog_vest_sheriff","dog_vest_black","dog_vest_black_k9","dog_vest_blackgreen","dog_vest_blackmedic","dog_vest_blackgreenz")
    $houseKitNames = @("dog_shed_small_kit","dog_shed_big_kit")

    foreach ($type in $dog.types.type) {
        if ($collarNames -contains $type.name) {
            $type.nominal = [string]$settings.dogGear.collar.nominal
            $type.min = [string]$settings.dogGear.collar.min
        }
        elseif ($vestNames -contains $type.name) {
            $type.nominal = [string]$settings.dogGear.vest.nominal
            $type.min = [string]$settings.dogGear.vest.min
        }
        elseif ($type.name -eq "dog_gasmask") {
            $type.nominal = [string]$settings.dogGear.gasMask.nominal
            $type.min = [string]$settings.dogGear.gasMask.min
        }
        elseif ($houseKitNames -contains $type.name) {
            $type.nominal = [string]$settings.dogGear.dogHouseKit.nominal
            $type.min = [string]$settings.dogGear.dogHouseKit.min
        }
    }

    $dog.Save($dogGearFile)
    Write-Host "  custom/types_dayzdog.xml updated" -ForegroundColor Green
} else {
    Write-Host "INFO: types_dayzdog.xml not found, skipping" -ForegroundColor DarkYellow
}

# =============================================
# 10. PATCH planes (types_lmplanes.xml)
# =============================================
if ($settings.planes -and (Test-Path $planesFile)) {
    Write-Host "`nPatching custom/types_lmplanes.xml (planes)..." -ForegroundColor Yellow
    [xml]$planes = Get-Content $planesFile

    $planeMap = @{
        "LM_DC_3"          = $settings.planes.dc3
        "LM_Stuntplane"    = $settings.planes.stuntplane
        "LM_Catalina"      = $settings.planes.catalina
        "LM_Tigermoth"     = $settings.planes.tigermoth
        "LM_Tigermoth_MK2" = $settings.planes.tigermothMk2
        "LM_Tigermoth_MK3" = $settings.planes.tigermothMk3
        "LM_Spitfire"      = $settings.planes.spitfire
        "LM_Cessna180"     = $settings.planes.cessna
    }

    foreach ($type in $planes.types.type) {
        if ($planeMap.ContainsKey($type.name)) {
            $vals = $planeMap[$type.name]
            $type.nominal = [string]$vals.nominal
            $type.min = [string]$vals.min
        }
    }

    $planes.Save($planesFile)
    Write-Host "  custom/types_lmplanes.xml updated" -ForegroundColor Green
} else {
    Write-Host "INFO: types_lmplanes.xml not found, skipping" -ForegroundColor DarkYellow
}

# =============================================
# 11. PATCH Zen's Sleep config
# =============================================
if ($settings.sleep -and (Test-Path $zenSleepFile)) {
    Write-Host "`nPatching config/Zenarchist/ZenSleepConfig.json (sleep fatigue)..." -ForegroundColor Yellow
    $sleepCfg = Get-Content $zenSleepFile -Raw | ConvertFrom-Json

    $sleepCfg.DrainConfig.GlobalDrainMultiplier = $settings.sleep.globalDrainMultiplier

    $sleepCfg | ConvertTo-Json -Depth 10 | Set-Content $zenSleepFile
    Write-Host "  ZenSleepConfig.json updated (drain=$($settings.sleep.globalDrainMultiplier))" -ForegroundColor Green
} else {
    Write-Host "INFO: ZenSleepConfig.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# DONE
# =============================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "All settings applied! Restart your server for changes to take effect." -ForegroundColor Cyan
Write-Host "(PvZmoD zombie changes can also be applied in-game with Numpad4)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
