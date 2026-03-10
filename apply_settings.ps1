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
$zenSkillsCfgFile = Join-Path $root "config\Zenarchist\Skills\ZenSkillsConfig.json"
$zenTreasureFile = Join-Path $root "config\Zenarchist\ZenTreasureConfig.json"
$expansionAIFile = Join-Path $root "config\ExpansionMod\Settings\AISettings.json"
$expansionVehicleFile = Join-Path $root "config\ExpansionMod\Settings\VehicleSettings.json"
$expansionPartyFile = Join-Path $root "config\ExpansionMod\Settings\PartySettings.json"
$expansionGeneralFile = Join-Path $root "config\ExpansionMod\Settings\GeneralSettings.json"
$expansionGarageFile = Join-Path $root "config\ExpansionMod\Settings\GarageSettings.json"
$dayzDogFile = Join-Path $root "config\Dayz-Dog\DayzDog.json"
$dayzHorseFile = Join-Path $root "config\DayZ-Horse\Horse.json"

# --- Load settings ---
if (-not (Test-Path $settingsFile)) {
    Write-Host "ERROR: server_settings.json not found at $settingsFile" -ForegroundColor Red
    exit 1
}

$settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
Write-Host "Loaded settings from server_settings.json" -ForegroundColor Cyan

$patchCount = 0

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
    $patchCount++
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

    # Shock handling
    $gp.PlayerData.ShockHandlingData.shockRefillSpeedConscious = $g.shockRefillSpeedConscious
    $gp.PlayerData.ShockHandlingData.shockRefillSpeedUnconscious = $g.shockRefillSpeedUnconscious

    # Movement
    $gp.PlayerData.MovementData.timeToSprint = $g.timeToSprint
    $gp.PlayerData.MovementData.rotationSpeedJog = $g.rotationSpeedJog

    # World
    $gp.WorldsData.lightingConfig = $g.lightingConfig

    # Vehicle
    $gp.VehicleData.boatDecayMultiplier = $g.boatDecayMultiplier

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
    $patchCount++
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

    # Animal spawn mapping (mod + vanilla)
    $animalMap = @{}
    if ($settings.animals) {
        $a = $settings.animals
        if ($a.wildDogs)   { $animalMap["AnimalWildDog"]   = $a.wildDogs }
        if ($a.wildHorses) { $animalMap["AnimalWildHorse"] = $a.wildHorses }
        if ($a.bears)      { $animalMap["AnimalBear"]      = $a.bears }
        if ($a.cattle)     { $animalMap["AnimalCow"]        = $a.cattle }
        if ($a.deer)       { $animalMap["AnimalDeer"]       = $a.deer }
        if ($a.roeDeer)    { $animalMap["AnimalRoeDeer"]    = $a.roeDeer }
        if ($a.goats)      { $animalMap["AnimalGoat"]       = $a.goats }
        if ($a.sheep)      { $animalMap["AnimalSheep"]      = $a.sheep }
        if ($a.pigs)       { $animalMap["AnimalPig"]         = $a.pigs }
        if ($a.wildBoar)   { $animalMap["AnimalWildBoar"]   = $a.wildBoar }
        if ($a.wolves)     { $animalMap["AnimalWolf"]       = $a.wolves }
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
    $patchCount++
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
    $patchCount++
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
    $patchCount++
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

    # --- Zombie feature toggles ---
    if ($settings.zombieFeatures) {
        $zf = $settings.zombieFeatures

        # Bleeding chance
        $pvzContent = $pvzContent -replace '(<Bleeding_Chance_Activated\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zf.bleedingChanceDay)`${2}$($zf.bleedingChanceNight)`${3}"

        # Door breaking
        $pvzContent = $pvzContent -replace '(<Zombies_Breaking_Doors_Activated\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zf.doorBreakingDay)`${2}$($zf.doorBreakingNight)`${3}"

        # Locked door breaking
        $pvzContent = $pvzContent -replace '(<Zombies_Breaking_LockedDoors_Activated\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zf.lockedDoorBreakingDay)`${2}$($zf.lockedDoorBreakingNight)`${3}"

        # Hit unconscious players
        $pvzContent = $pvzContent -replace '(<Zombies_Hit_Unconscious_Players_Activated\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($zf.hitUnconsciousDay)`${2}$($zf.hitUnconsciousNight)`${3}"

        # Stone throwing
        if ($zf.stoneThrowing) {
            $st = $zf.stoneThrowing
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Activated\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.enabledDay)`${2}$($st.enabledNight)`${3}"
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Only_If_Player_On_Obstacle\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.onlyOnObstacleDay)`${2}$($st.onlyOnObstacleNight)`${3}"
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Damage_Health\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.damageHealthDay)`${2}$($st.damageHealthNight)`${3}"
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Damage_Shock\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.damageShockDay)`${2}$($st.damageShockNight)`${3}"
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Keep_Minimum_Health\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.keepMinHealthDay)`${2}$($st.keepMinHealthNight)`${3}"
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Rate\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.rateDay)`${2}$($st.rateNight)`${3}"
            $pvzContent = $pvzContent -replace '(<Zombies_Throw_Stones_Distance_Maxi\s+Day\s*=\s*")[^"]*("\s+Night\s*=\s*")[^"]*(")', "`${1}$($st.distanceMaxDay)`${2}$($st.distanceMaxNight)`${3}"
        }

        # Vehicle crushing damage
        if ($zf.vehicleDamage) {
            $vd = $zf.vehicleDamage
            $pvzContent = $pvzContent -replace '(<Damages_To_Vehicles\s+Activated\s*=\s*")[^"]*(")', "`${1}$($vd.enabled)`${2}"
            $pvzContent = $pvzContent -replace '(<Damages_To_Vehicles\s+Damages_Per_Impact\s*=\s*")[^"]*(")', "`${1}$($vd.damagePerImpact)`${2}"
            $pvzContent = $pvzContent -replace '(<Damages_To_Vehicles\s+Timer_Between_Impacts\s*=\s*")[^"]*(")', "`${1}$($vd.timerBetweenImpacts)`${2}"
            $pvzContent = $pvzContent -replace '(<Damages_To_Vehicles\s+Speed_Minimum\s*=\s*")[^"]*(")', "`${1}$($vd.speedMinimum)`${2}"
        }

        # Zombies attacking stopped vehicles
        if ($zf.vehicleAttack) {
            $va = $zf.vehicleAttack
            $pvzContent = $pvzContent -replace '(<Attack_Stopped_Vehicles\s+Activated\s*=\s*")[^"]*(")', "`${1}$($va.enabled)`${2}"
            $pvzContent = $pvzContent -replace '(<Attack_Stopped_Vehicles\s+Damage_On_Structure\s*=\s*")[^"]*(")', "`${1}$($va.damageOnStructure)`${2}"
            $pvzContent = $pvzContent -replace '(<Attack_Stopped_Vehicles\s+Damage_On_Attachments\s*=\s*")[^"]*(")', "`${1}$($va.damageOnAttachments)`${2}"
            $pvzContent = $pvzContent -replace '(<Attack_Stopped_Vehicles\s+Attack_Speed_Factor\s*=\s*")[^"]*(")', "`${1}$($va.attackSpeedFactor)`${2}"
            $pvzContent = $pvzContent -replace '(<Attack_Stopped_Vehicles\s+Player_Inside_Can_Be_Hit\s*=\s*")[^"]*(")', "`${1}$($va.playerInsideCanBeHit)`${2}"
        }
    }

    Set-Content $pvzGlobalsFile -Value $pvzContent -NoNewline
    Write-Host "  PvZmoD Globals updated (speed/health/strength + feature toggles)" -ForegroundColor Green
    $patchCount++
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
    $pvzChars = $pvzChars -replace '(<Vision_Distance_Ratio\s+Day=")[^"]*(")', "`${1}$($zb.visionRatioDay)`${2}"

    Set-Content $pvzCharsFile -Value $pvzChars -NoNewline
    Write-Host "  PvZmoD Characteristics updated (vision Day=$($zb.visionRatioDay))" -ForegroundColor Green
    $patchCount++
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
    $patchCount++
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
    $patchCount++
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
    $patchCount++
} else {
    Write-Host "INFO: types_lmplanes.xml not found, skipping" -ForegroundColor DarkYellow
}

# =============================================
# 11. PATCH Zen's Sleep config
# =============================================
if ($settings.sleep -and (Test-Path $zenSleepFile)) {
    Write-Host "`nPatching config/Zenarchist/ZenSleepConfig.json (sleep)..." -ForegroundColor Yellow
    $sleepCfg = Get-Content $zenSleepFile -Raw | ConvertFrom-Json
    $sl = $settings.sleep

    # Drain
    $sleepCfg.DrainConfig.GlobalDrainMultiplier = $sl.globalDrainMultiplier

    # General
    $sleepCfg.GeneralConfig.FreshSpawnFatiguePercent = $sl.freshSpawnFatiguePercent
    $sleepCfg.GeneralConfig.SecondsAsleepUntilFullRestApprox = $sl.secondsAsleepUntilFullRest

    # Gain
    $sleepCfg.GainConfig.GainNightMultiplier = $sl.gainNightMultiplier
    $sleepCfg.GainConfig.GainBedObjectUsed = $sl.gainBedObjectUsed
    $sleepCfg.GainConfig.GainInsideMultiplier = $sl.gainInsideMultiplier
    $sleepCfg.GainConfig.BedHealthGainPerSec = $sl.bedHealthGainPerSec
    $sleepCfg.GainConfig.BedHealthMaxGain = $sl.bedHealthMaxGain

    $sleepCfg | ConvertTo-Json -Depth 10 | Set-Content $zenSleepFile
    Write-Host "  ZenSleepConfig.json updated (drain=$($sl.globalDrainMultiplier), rest=$($sl.secondsAsleepUntilFullRest)s)" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: ZenSleepConfig.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 12. PATCH Zen's Skills config
# =============================================
if ($settings.zenSkillsConfig -and (Test-Path $zenSkillsCfgFile)) {
    Write-Host "`nPatching config/Zenarchist/Skills/ZenSkillsConfig.json (skill progression)..." -ForegroundColor Yellow
    $skillsCfg = Get-Content $zenSkillsCfgFile -Raw | ConvertFrom-Json
    $zsc = $settings.zenSkillsConfig

    # Shared config
    $skillsCfg.SharedConfig.PercentOfExpLostOnDeath = $zsc.expLostOnDeath
    $skillsCfg.SharedConfig.EXP_InjectorBoostMulti = $zsc.injectorBoostMultiplier
    $skillsCfg.SharedConfig.EXP_InjectorBoostTime = $zsc.injectorBoostTimeSecs

    # Per-skill settings (apply to all 4 skill trees)
    foreach ($skillName in @("survival", "hunting", "gathering", "crafting")) {
        if ($skillsCfg.SkillDefs.$skillName) {
            $skillsCfg.SkillDefs.$skillName.EXP_Per_Perk = $zsc.expPerPerk
            $skillsCfg.SkillDefs.$skillName.MaxAllowedPerks = $zsc.maxAllowedPerks
        }
    }

    $skillsCfg | ConvertTo-Json -Depth 10 | Set-Content $zenSkillsCfgFile
    Write-Host "  ZenSkillsConfig.json updated (expPerPerk=$($zsc.expPerPerk), maxPerks=$($zsc.maxAllowedPerks))" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: ZenSkillsConfig.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 13. PATCH Zen's Treasure config
# =============================================
if ($settings.zenTreasure -and (Test-Path $zenTreasureFile)) {
    Write-Host "`nPatching config/Zenarchist/ZenTreasureConfig.json (treasure)..." -ForegroundColor Yellow
    $treasureCfg = Get-Content $zenTreasureFile -Raw | ConvertFrom-Json
    $zt = $settings.zenTreasure

    $treasureCfg.TreasurePersistenceSecs = $zt.treasurePersistenceSecs
    $treasureCfg.SpawnPhotosOnZombiesChance = $zt.spawnPhotosOnZombiesChance

    $treasureCfg | ConvertTo-Json -Depth 10 | Set-Content $zenTreasureFile
    Write-Host "  ZenTreasureConfig.json updated (persistence=$($zt.treasurePersistenceSecs)s, photoChance=$($zt.spawnPhotosOnZombiesChance))" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: ZenTreasureConfig.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 14. PATCH Expansion AI settings
# =============================================
if ($settings.expansionAI -and (Test-Path $expansionAIFile)) {
    Write-Host "`nPatching config/ExpansionMod/Settings/AISettings.json (AI)..." -ForegroundColor Yellow
    $aiCfg = Get-Content $expansionAIFile -Raw | ConvertFrom-Json
    $ai = $settings.expansionAI

    $aiCfg.AccuracyMin = $ai.accuracyMin
    $aiCfg.AccuracyMax = $ai.accuracyMax
    $aiCfg.ThreatDistanceLimit = $ai.threatDistanceLimit
    $aiCfg.DamageMultiplier = $ai.damageMultiplier
    $aiCfg.DamageReceivedMultiplier = $ai.damageReceivedMultiplier
    $aiCfg.MaxRecruitableAI = $ai.maxRecruitableAI
    $aiCfg.AggressionTimeout = $ai.aggressionTimeout
    $aiCfg.GuardAggressionTimeout = $ai.guardAggressionTimeout
    $aiCfg.MaxFlankingDistance = $ai.maxFlankingDistance
    $aiCfg.SniperProneDistanceThreshold = $ai.sniperProneDistanceThreshold

    $aiCfg | ConvertTo-Json -Depth 10 | Set-Content $expansionAIFile
    Write-Host "  AISettings.json updated (accuracy=$($ai.accuracyMin)-$($ai.accuracyMax), dmg=$($ai.damageMultiplier)x)" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: AISettings.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 15. PATCH Expansion Vehicle settings
# =============================================
if ($settings.expansionVehicles -and (Test-Path $expansionVehicleFile)) {
    Write-Host "`nPatching config/ExpansionMod/Settings/VehicleSettings.json (vehicles)..." -ForegroundColor Yellow
    $vehCfg = Get-Content $expansionVehicleFile -Raw | ConvertFrom-Json
    $ev = $settings.expansionVehicles

    $vehCfg.VehicleRequireKeyToStart = $ev.requireKeyToStart
    $vehCfg.VehicleRequireAllDoors = $ev.requireAllDoors
    $vehCfg.CanPickLock = $ev.canPickLock
    $vehCfg.PickLockChancePercent = $ev.pickLockChancePercent
    $vehCfg.PickLockTimeSeconds = $ev.pickLockTimeSeconds
    $vehCfg.Towing = $ev.towing
    $vehCfg.DisableVehicleDamage = $ev.disableVehicleDamage
    $vehCfg.FuelConsumptionPercent = $ev.fuelConsumptionPercent
    $vehCfg.VehicleCrewDamageMultiplier = $ev.crewDamageMultiplier
    $vehCfg.VehicleSpeedDamageMultiplier = $ev.speedDamageMultiplier
    $vehCfg.EnableHelicopterExplosions = $ev.enableHelicopterExplosions
    $vehCfg.EnableTailRotorDamage = $ev.enableTailRotorDamage
    $vehCfg.CollisionDamageMinSpeedKmh = $ev.collisionDamageMinSpeedKmh

    $vehCfg | ConvertTo-Json -Depth 10 | Set-Content $expansionVehicleFile
    Write-Host "  VehicleSettings.json updated (fuel=$($ev.fuelConsumptionPercent)%, keys=$($ev.requireKeyToStart))" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: VehicleSettings.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 16. PATCH Expansion Party settings
# =============================================
if ($settings.expansionParty -and (Test-Path $expansionPartyFile)) {
    Write-Host "`nPatching config/ExpansionMod/Settings/PartySettings.json (party)..." -ForegroundColor Yellow
    $partyCfg = Get-Content $expansionPartyFile -Raw | ConvertFrom-Json
    $ep = $settings.expansionParty

    $partyCfg.MaxMembersInParty = $ep.maxMembersInParty
    $partyCfg.ShowPartyMember3DMarkers = $ep.showPartyMember3DMarkers
    $partyCfg.ShowDistanceUnderPartyMembersMarkers = $ep.showDistanceUnderMarkers
    $partyCfg.ShowNameOnPartyMembersMarkers = $ep.showNameOnMarkers
    $partyCfg.ShowPartyMemberHUD = $ep.showPartyMemberHUD
    $partyCfg.ShowHUDMemberBlood = $ep.showHUDMemberBlood
    $partyCfg.ShowHUDMemberStates = $ep.showHUDMemberStates
    $partyCfg.EnableQuickMarker = $ep.enableQuickMarker

    $partyCfg | ConvertTo-Json -Depth 10 | Set-Content $expansionPartyFile
    Write-Host "  PartySettings.json updated (maxMembers=$($ep.maxMembersInParty))" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: PartySettings.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 17. PATCH Expansion General settings
# =============================================
if ($settings.expansionGeneral -and (Test-Path $expansionGeneralFile)) {
    Write-Host "`nPatching config/ExpansionMod/Settings/GeneralSettings.json (general)..." -ForegroundColor Yellow
    $genCfg = Get-Content $expansionGeneralFile -Raw | ConvertFrom-Json
    $eg = $settings.expansionGeneral

    $genCfg.EnableGravecross = $eg.enableGravecross
    $genCfg.GravecrossDeleteBody = $eg.gravecrossDeleteBody
    $genCfg.EnableLamps = $eg.enableLamps
    $genCfg.EnableGenerators = $eg.enableGenerators
    $genCfg.EnableLighthouses = $eg.enableLighthouses
    $genCfg.EnableAutoRun = $eg.enableAutoRun
    $genCfg.EnableHUDNightvisionOverlay = $eg.enableHUDNightvisionOverlay
    $genCfg.DisableMagicCrosshair = $eg.disableMagicCrosshair

    $genCfg | ConvertTo-Json -Depth 10 | Set-Content $expansionGeneralFile
    Write-Host "  GeneralSettings.json updated (lamps=$($eg.enableLamps), autorun=$($eg.enableAutoRun))" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: GeneralSettings.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 18. PATCH Expansion Garage settings
# =============================================
if ($settings.expansionGarage -and (Test-Path $expansionGarageFile)) {
    Write-Host "`nPatching config/ExpansionMod/Settings/GarageSettings.json (garage)..." -ForegroundColor Yellow
    $garageCfg = Get-Content $expansionGarageFile -Raw | ConvertFrom-Json
    $gg = $settings.expansionGarage

    $garageCfg.MaxStorableVehicles = $gg.maxStorableVehicles
    $garageCfg.VehicleSearchRadius = $gg.vehicleSearchRadius
    $garageCfg.MaxDistanceFromStoredPosition = $gg.maxDistanceFromStoredPosition
    $garageCfg.CanStoreWithCargo = $gg.canStoreWithCargo
    $garageCfg.NeedKeyToStore = $gg.needKeyToStore

    $garageCfg | ConvertTo-Json -Depth 10 | Set-Content $expansionGarageFile
    Write-Host "  GarageSettings.json updated (maxVehicles=$($gg.maxStorableVehicles), radius=$($gg.vehicleSearchRadius)m)" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: GarageSettings.json not found, skipping (boot server once to generate)" -ForegroundColor DarkYellow
}

# =============================================
# 19. PATCH DayZ-Dog settings
# =============================================
if ($settings.dayzDog -and (Test-Path $dayzDogFile)) {
    Write-Host "`nPatching config/Dayz-Dog/DayzDog.json (dog behaviour)..." -ForegroundColor Yellow
    $dogCfg = Get-Content $dayzDogFile -Raw | ConvertFrom-Json
    $dd = $settings.dayzDog

    $dogCfg.EnableDogWaypoints = $dd.enableDogWaypoints
    $dogCfg.PunishDogKillers = $dd.punishDogKillers
    $dogCfg.DisablePlayerAttack = $dd.disablePlayerAttack
    $dogCfg.SummonItem = $dd.summonItem

    $dogCfg | ConvertTo-Json -Depth 10 | Set-Content $dayzDogFile
    Write-Host "  DayzDog.json updated (summon=$($dd.summonItem))" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: DayzDog.json not found, skipping" -ForegroundColor DarkYellow
}

# =============================================
# 20. PATCH DayZ-Horse settings
# =============================================
if ($settings.dayzHorse -and (Test-Path $dayzHorseFile)) {
    Write-Host "`nPatching config/DayZ-Horse/Horse.json (horse behaviour)..." -ForegroundColor Yellow
    $horseCfg = Get-Content $dayzHorseFile -Raw | ConvertFrom-Json
    $dh = $settings.dayzHorse

    $horseCfg.HorseCallRange = $dh.horseCallRange

    $horseCfg | ConvertTo-Json -Depth 10 | Set-Content $dayzHorseFile
    Write-Host "  Horse.json updated (callRange=$($dh.horseCallRange)m)" -ForegroundColor Green
    $patchCount++
} else {
    Write-Host "INFO: Horse.json not found, skipping" -ForegroundColor DarkYellow
}

# =============================================
# DONE
# =============================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "All settings applied! ($patchCount config files patched)" -ForegroundColor Cyan
Write-Host "Restart your server for changes to take effect." -ForegroundColor Cyan
Write-Host "(PvZmoD zombie changes can also be applied in-game with Numpad4)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
