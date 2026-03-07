"""
Generate Expansion AI config files:
- AISettings.json (global settings)
- AI/Patrols/PatrolSettings.json (patrol definitions)
- AI/Loadouts/*.json (gear loadouts)
- Quests NPCs (quest giver JSON files)
"""
import json, os, random

SERVER = os.path.dirname(os.path.abspath(__file__))
AI_DIR = os.path.join(SERVER, "config", "ExpansionMod", "AI")
LOADOUT_DIR = os.path.join(AI_DIR, "Loadouts")
PATROL_DIR = os.path.join(AI_DIR, "Patrols")
SETTINGS_DIR = os.path.join(SERVER, "config", "ExpansionMod", "Settings")
QUEST_DIR = os.path.join(SERVER, "config", "ExpansionMod", "Quests")
QUEST_NPC_DIR = os.path.join(QUEST_DIR, "NPCs")

for d in [LOADOUT_DIR, PATROL_DIR, SETTINGS_DIR, QUEST_NPC_DIR]:
    os.makedirs(d, exist_ok=True)

# ============================================================
# Helper: create a loadout item entry
# ============================================================
def item(classname, chance=1.0, attachments=None, cargo=None):
    return {
        "ClassName": classname,
        "Chance": chance,
        "Quantity": {"Min": 0.0, "Max": 0.0},
        "Health": [{"Min": 70.0, "Max": 100.0, "Zone": ""}],
        "InventoryAttachments": attachments or [],
        "InventoryCargo": cargo or [],
        "ConstructionPartsBuilt": []
    }

def slot(name, items):
    return {"SlotName": name, "Items": items}

def weapon_attach(items):
    """Weapon attachment sub-items (mag, buttstock, etc.)"""
    return [{"SlotName": "", "Items": items}]

# ============================================================
# LOADOUT: Military (deadly, good gear)
# ============================================================
military_loadout = {
    "ClassName": "",
    "Chance": 1.0,
    "Quantity": {"Min": 0.0, "Max": 0.0},
    "Health": [],
    "InventoryAttachments": [
        slot("Body", [
            item("M65Jacket_Olive", 1.0),
            item("GorkaEJacket_Flat", 1.0),
            item("GorkaEJacket_Summer", 1.0),
            item("TTsKOJacket_Camo", 1.0),
            item("USMCJacket_Woodland", 1.0),
        ]),
        slot("Legs", [
            item("GorkaPants_Flat", 1.0),
            item("GorkaPants_Summer", 1.0),
            item("TTSKOPants", 1.0),
            item("USMCPants_Woodland", 1.0),
            item("CargoPants_Green", 1.0),
        ]),
        slot("Feet", [
            item("MilitaryBoots_Black", 1.0),
            item("MilitaryBoots_Brown", 1.0),
            item("CombatBoots_Black", 1.0),
            item("TTSKOBoots", 1.0),
        ]),
        slot("Vest", [
            item("PlateCarrierVest", 0.5),
            item("HighCapacityVest_Olive", 1.0),
            item("UKAssVest_Camo", 1.0),
            item("SmershVest", 1.0),
        ]),
        slot("Headgear", [
            item("MilitaryBeret_CDF", 1.0),
            item("BallisticHelmet_Green", 1.0),
            item("GorkaHelmet", 1.0),
            item("Mich2001Helmet", 0.5),
            item("BoonieHat_Olive", 1.0),
        ]),
        slot("Back", [
            item("AliceBag_Camo", 1.0),
            item("AssaultBag_Ttsko", 1.0),
            item("AssaultBag_Green", 1.0),
        ]),
        slot("Gloves", [
            item("TacticalGloves_Green", 1.0),
            item("TacticalGloves_Black", 1.0),
            item("OMNOGloves_Gray", 1.0),
        ]),
        slot("Hands", [
            # M4A1 with attachments
            item("M4A1", 1.0, attachments=weapon_attach([
                item("Mag_STANAG_30Rnd", 1.0),
                item("M4_RISHndgrd", 1.0),
                item("M4_OEBttstck", 1.0),
                item("M68Optic", 0.5),
                item("ACOGOptic", 0.5),
            ])),
            # AKM
            item("AKM", 1.0, attachments=weapon_attach([
                item("Mag_AKM_30Rnd", 1.0),
                item("AK_PlasticBttstck", 1.0),
                item("AK_PlasticHndgrd", 1.0),
                item("KobraOptic", 0.5),
            ])),
            # AK74
            item("AK74", 1.0, attachments=weapon_attach([
                item("Mag_AK74_30Rnd", 1.0),
                item("AK_FoldingBttstck", 1.0),
                item("AK_Handguard", 1.0),
                item("PSO1Optic", 0.3),
            ])),
            # SVD
            item("SVD", 0.3, attachments=weapon_attach([
                item("Mag_SVD_10Rnd", 1.0),
                item("PSO1Optic", 1.0),
            ])),
            # FAL
            item("FAL", 0.4, attachments=weapon_attach([
                item("Mag_FAL_20Rnd", 1.0),
                item("Fal_OeBttstck", 1.0),
            ])),
        ]),
    ],
    "InventoryCargo": [
        item("BandageDressing", 0.5),
        item("SodaCan_Cola", 0.2),
        item("TacticalBaconCan", 0.2),
        item("Ammo_762x39", 0.3),
        item("Ammo_556x45", 0.3),
        item("Ammo_762x54", 0.2),
    ],
    "ConstructionPartsBuilt": []
}

# ============================================================
# LOADOUT: Bandit (basic weapons, scrappy gear)
# ============================================================
bandit_loadout = {
    "ClassName": "",
    "Chance": 1.0,
    "Quantity": {"Min": 0.0, "Max": 0.0},
    "Health": [],
    "InventoryAttachments": [
        slot("Body", [
            item("HikingJacket_Black", 1.0),
            item("HikingJacket_Blue", 1.0),
            item("BomberJacket_Black", 1.0),
            item("RidersJacket_Black", 1.0),
            item("Hoodie_Black", 1.0),
            item("Hoodie_Grey", 1.0),
        ]),
        slot("Legs", [
            item("Jeans_Black", 1.0),
            item("Jeans_BlueDark", 1.0),
            item("CargoPants_Black", 1.0),
            item("SlacksPants_Black", 1.0),
        ]),
        slot("Feet", [
            item("WorkingBoots_Brown", 1.0),
            item("HikingBootsLow_Black", 1.0),
            item("CombatBoots_Black", 1.0),
            item("Sneakers_Black", 1.0),
        ]),
        slot("Headgear", [
            item("BaseballCap_Black", 1.0),
            item("SkiMask_Black", 0.5),
            item("BandanaMask_BlackPattern", 0.5),
            item("Balaclava3Holes_Black", 0.3),
            item("Ushanka_Black", 0.5),
        ]),
        slot("Back", [
            item("TaloonBag_Green", 1.0),
            item("TaloonBag_Blue", 1.0),
            item("DryBag_Black", 0.5),
        ]),
        slot("Hands", [
            # Shotguns
            item("Izh43Shotgun", 1.0),
            item("Mp133Shotgun", 1.0),
            # Rifles
            item("MosinNagant", 0.7, attachments=weapon_attach([
                item("PUScopeOptic", 0.3),
            ])),
            item("SKS", 1.0),
            item("CZ527", 0.8),
            # Pistols
            item("MakarovIJ70", 1.0, attachments=weapon_attach([
                item("Mag_IJ70_8Rnd", 1.0),
            ])),
            item("CZ75", 0.8, attachments=weapon_attach([
                item("Mag_CZ75_15Rnd", 1.0),
            ])),
            item("FNX45", 0.5, attachments=weapon_attach([
                item("Mag_FNX45_15Rnd", 1.0),
            ])),
        ]),
    ],
    "InventoryCargo": [
        item("BandageDressing", 0.3),
        item("Ammo_12gaPellets", 0.3),
        item("Ammo_762x54", 0.2),
        item("Ammo_762x39", 0.2),
        item("Apple", 0.1),
    ],
    "ConstructionPartsBuilt": []
}

# ============================================================
# LOADOUT: Civilian (junk, no real weapons)
# ============================================================
civilian_loadout = {
    "ClassName": "",
    "Chance": 1.0,
    "Quantity": {"Min": 0.0, "Max": 0.0},
    "Health": [],
    "InventoryAttachments": [
        slot("Body", [
            item("TShirt_White", 1.0),
            item("TShirt_Red", 1.0),
            item("TShirt_Blue", 1.0),
            item("TShirt_Grey", 1.0),
            item("Shirt_BlueCheck", 1.0),
            item("Shirt_RedCheck", 1.0),
            item("Hoodie_Blue", 1.0),
            item("Hoodie_Green", 1.0),
        ]),
        slot("Legs", [
            item("Jeans_Blue", 1.0),
            item("Jeans_Grey", 1.0),
            item("Jeans_Brown", 1.0),
            item("SlacksPants_Blue", 1.0),
            item("SlacksPants_DarkGrey", 1.0),
        ]),
        slot("Feet", [
            item("AthleticShoes_Blue", 1.0),
            item("AthleticShoes_Grey", 1.0),
            item("Sneakers_Black", 1.0),
            item("Sneakers_White", 1.0),
            item("HikingBootsLow_Blue", 1.0),
        ]),
        slot("Headgear", [
            item("BaseballCap_Blue", 0.5),
            item("BaseballCap_Red", 0.5),
            item("BaseballCap_Olive", 0.5),
            item("Ushanka_Blue", 0.3),
            item("FlatCap_Grey", 0.3),
        ]),
        slot("Hands", [
            # Melee only
            item("BaseballBat", 1.0),
            item("Pipe", 1.0),
            item("Wrench", 0.5),
            item("SledgeHammer", 0.3),
        ]),
    ],
    "InventoryCargo": [
        item("Apple", 0.2),
        item("Pear", 0.2),
        item("SodaCan_Cola", 0.15),
        item("SodaCan_Spite", 0.15),
        item("BandageDressing", 0.1),
        item("Screwdriver", 0.1),
        item("Rag", 0.15),
        item("Battery9V", 0.1),
        item("Flashlight", 0.1),
    ],
    "ConstructionPartsBuilt": []
}

# Write loadouts
for name, data in [("MilitaryLoadout", military_loadout),
                   ("BanditLoadout", bandit_loadout),
                   ("CivilianLoadout", civilian_loadout)]:
    path = os.path.join(LOADOUT_DIR, f"{name}.json")
    with open(path, 'w') as f:
        json.dump(data, f, indent=4)
    print(f"Wrote {path}")

# ============================================================
# AI SETTINGS (global)
# ============================================================
ai_settings = {
    "m_Version": 2,
    "AccuracyMin": 0.15,
    "AccuracyMax": 0.5,
    "ThreatDistanceLimit": 300.0,
    "DamageMultiplier": 1.0,
    "DamageReceivedMultiplier": 1.0,
    "NoiseInvestigationDistanceLimit": 200.0,
    "MaximumDynamicPatrols": -1,
    "Vaulting": 1,
    "Manners": 1,
    "CanRecruitFriendly": 0,
    "CanRecruitGuards": 0,
    "Admins": [],
    "LogAIHitBy": 1,
    "LogAIKilled": 1,
    "SniperProneDistanceThreshold": 100.0,
    "MemeLevel": 0
}

path = os.path.join(SETTINGS_DIR, "AISettings.json")
with open(path, 'w') as f:
    json.dump(ai_settings, f, indent=4)
print(f"Wrote {path}")

# ============================================================
# PATROL DEFINITIONS
# ============================================================
# Chernarus key locations (X, Y, Z)
# Y=0 lets the engine resolve terrain height

# Military base areas
MILITARY_LOCATIONS = [
    # NWAF - Northwest Airfield
    {"name": "NWAF_North", "pos": [4500, 0, 10250], "spread": 200},
    {"name": "NWAF_South", "pos": [4850, 0, 9950], "spread": 200},
    {"name": "NWAF_Hangars", "pos": [4300, 0, 10450], "spread": 150},
    # Tisy Military Base
    {"name": "Tisy_Base", "pos": [1700, 0, 13800], "spread": 200},
    {"name": "Tisy_Tents", "pos": [1450, 0, 14050], "spread": 150},
    # Balota Airfield
    {"name": "Balota_AF", "pos": [4500, 0, 2450], "spread": 200},
    # Myshkino Tents
    {"name": "Myshkino", "pos": [1300, 0, 7350], "spread": 150},
    # Pavlovo Military
    {"name": "Pavlovo_Mil", "pos": [2100, 0, 3400], "spread": 100},
    # Zeleno Military
    {"name": "Zeleno_Mil", "pos": [2700, 0, 5400], "spread": 100},
    # Kamensk
    {"name": "Kamensk", "pos": [12300, 0, 14500], "spread": 150},
    # Troitskoe
    {"name": "Troitskoe", "pos": [11200, 0, 14400], "spread": 100},
]

# Road patrol points (spread across main highways)
ROAD_LOCATIONS = [
    {"name": "Road_South_Coast", "pos": [6500, 0, 2300], "spread": 500},
    {"name": "Road_East_Coast", "pos": [13000, 0, 5500], "spread": 500},
    {"name": "Road_Central_NS", "pos": [6500, 0, 7000], "spread": 500},
    {"name": "Road_Central_EW", "pos": [8500, 0, 7500], "spread": 500},
    {"name": "Road_West", "pos": [3500, 0, 8000], "spread": 500},
    {"name": "Road_North", "pos": [7500, 0, 12000], "spread": 500},
    {"name": "Road_NE", "pos": [12000, 0, 10000], "spread": 500},
    {"name": "Road_Stary_Novy", "pos": [6600, 0, 7700], "spread": 300},
]

# Town locations for civilians
TOWN_LOCATIONS = [
    {"name": "Cherno", "pos": [6700, 0, 2600], "spread": 300},
    {"name": "Elektro", "pos": [10400, 0, 2100], "spread": 300},
    {"name": "Berezino", "pos": [12400, 0, 9800], "spread": 250},
    {"name": "Svetlo", "pos": [14400, 0, 13200], "spread": 200},
    {"name": "Stary_Sobor", "pos": [6100, 0, 7700], "spread": 200},
    {"name": "Novy_Sobor", "pos": [7100, 0, 7700], "spread": 200},
    {"name": "Gorka", "pos": [9600, 0, 8900], "spread": 200},
    {"name": "Zelenogorsk", "pos": [2650, 0, 5300], "spread": 250},
    {"name": "Vybor", "pos": [3800, 0, 8900], "spread": 200},
    {"name": "Solnichniy", "pos": [13300, 0, 6100], "spread": 200},
    {"name": "Polana", "pos": [10600, 0, 8200], "spread": 200},
    {"name": "Kamyshovo", "pos": [12100, 0, 3500], "spread": 200},
    {"name": "Novodmitrovsk", "pos": [11200, 0, 14200], "spread": 250},
    {"name": "Severograd", "pos": [7900, 0, 12600], "spread": 250},
    {"name": "Novaya_Petrovka", "pos": [3500, 0, 12900], "spread": 200},
]

# Bandit hotspots (wilderness, industrial, crossroads)
BANDIT_LOCATIONS = [
    {"name": "Bandit_NWAF_woods", "pos": [4000, 0, 10800], "spread": 400},
    {"name": "Bandit_Tisy_woods", "pos": [1900, 0, 13400], "spread": 400},
    {"name": "Bandit_Debug_Forest", "pos": [2500, 0, 10500], "spread": 600},
    {"name": "Bandit_Berezino_outskirts", "pos": [12800, 0, 10200], "spread": 400},
    {"name": "Bandit_Elektro_hills", "pos": [10800, 0, 2800], "spread": 400},
    {"name": "Bandit_Cherno_industrial", "pos": [6300, 0, 2800], "spread": 300},
    {"name": "Bandit_Balota_strip", "pos": [4800, 0, 2200], "spread": 300},
    {"name": "Bandit_Stary_woods", "pos": [6800, 0, 8200], "spread": 400},
    {"name": "Bandit_Black_Forest", "pos": [900, 0, 9000], "spread": 500},
    {"name": "Bandit_Kamy_coast", "pos": [12500, 0, 3200], "spread": 300},
    {"name": "Bandit_NE_woods", "pos": [13500, 0, 12000], "spread": 500},
    {"name": "Bandit_Central_hills", "pos": [8000, 0, 9500], "spread": 400},
    {"name": "Bandit_Severo_outskirts", "pos": [8500, 0, 12800], "spread": 400},
    {"name": "Bandit_Pavlovo_road", "pos": [2500, 0, 4000], "spread": 400},
    {"name": "Bandit_Zeleno_woods", "pos": [2200, 0, 5800], "spread": 400},
]

def make_patrol(name, faction, loadout, num_ai, behaviour, speed, chance,
                pos, spread, respawn_time=-2.0,
                accuracy_min=-1.0, accuracy_max=-1.0,
                damage_mult=-1.0, damage_recv_mult=-1.0,
                threat_dist=-1.0, can_be_looted=1,
                unlimited_reload=0):
    return {
        "Name": name,
        "Faction": faction,
        "LoadoutFile": loadout,
        "NumberOfAI": num_ai,
        "Behaviour": behaviour,
        "Speed": speed,
        "UnderThreatSpeed": "JOG",
        "CanBeLooted": can_be_looted,
        "UnlimitedReload": unlimited_reload,
        "AccuracyMin": accuracy_min,
        "AccuracyMax": accuracy_max,
        "DamageMultiplier": damage_mult,
        "DamageReceivedMultiplier": damage_recv_mult,
        "ThreatDistanceLimit": threat_dist,
        "Chance": chance,
        "MinDistRadius": 500.0,
        "MaxDistRadius": 1200.0,
        "DespawnRadius": 300.0,
        "MinSpreadRadius": float(spread // 2),
        "MaxSpreadRadius": float(spread),
        "RespawnTime": respawn_time,
        "DespawnTime": 60.0,
        "Persist": 0,
        "StartPos": [float(pos[0]), float(pos[1]), float(pos[2])],
        "Waypoints": [
            [float(pos[0]), float(pos[1]), float(pos[2])]
        ],
        "HeadshotResistance": 0.0,
        "DefaultStance": "STANDING",
        "DefaultLookAngle": 0.0,
        "LootingBehaviour": "NONE",
        "SniperProneDistanceThreshold": -1.0,
        "FormationScale": -1.0,
        "FormationLooseness": 1.0,
    }

groups = []

# --- Military Patrols at bases (spawn chance 0.5, deadly) ---
for loc in MILITARY_LOCATIONS:
    groups.append(make_patrol(
        name=f"Mil_{loc['name']}",
        faction="West",
        loadout="MilitaryLoadout",
        num_ai=-4,  # 1-4 random
        behaviour="ROAMING",
        speed="WALK",
        chance=0.5,
        pos=loc["pos"],
        spread=loc["spread"],
        respawn_time=1800000.0,  # 30 minutes
        accuracy_min=0.4,
        accuracy_max=0.8,
        damage_mult=1.0,
        damage_recv_mult=1.0,
        threat_dist=300.0,
        unlimited_reload=6,  # 2 (animals) + 4 (infected) = unlimited vs AI enemies
    ))

# --- Military Road Patrols (spawn chance 0.35, deadly) ---
for loc in ROAD_LOCATIONS:
    groups.append(make_patrol(
        name=f"Mil_Road_{loc['name']}",
        faction="West",
        loadout="MilitaryLoadout",
        num_ai=-3,  # 1-3 random
        behaviour="ROAMING",
        speed="WALK",
        chance=0.35,
        pos=loc["pos"],
        spread=loc["spread"],
        respawn_time=2700000.0,  # 45 minutes
        accuracy_min=0.4,
        accuracy_max=0.8,
        damage_mult=1.0,
        damage_recv_mult=1.0,
        threat_dist=300.0,
        unlimited_reload=6,
    ))

# --- Bandit Patrols (rare, low accuracy, half damage) ---
for loc in BANDIT_LOCATIONS:
    groups.append(make_patrol(
        name=f"Bandit_{loc['name']}",
        faction="Raiders",
        loadout="BanditLoadout",
        num_ai=-3,  # 1-3 random
        behaviour="ROAMING",
        speed="WALK",
        chance=0.25,  # Rare - only 25% chance
        pos=loc["pos"],
        spread=loc["spread"],
        respawn_time=3600000.0,  # 60 minutes
        accuracy_min=0.1,
        accuracy_max=0.2,
        damage_mult=0.5,
        damage_recv_mult=1.0,
        threat_dist=120.0,  # Short detection range
        unlimited_reload=0,  # Limited ammo
    ))

# --- Friendly Town Civilians (common, no weapons, junk loot) ---
for loc in TOWN_LOCATIONS:
    groups.append(make_patrol(
        name=f"Civ_{loc['name']}",
        faction="Passive",
        loadout="CivilianLoadout",
        num_ai=-3,  # 1-3 random
        behaviour="ROAMING",
        speed="WALK",
        chance=0.6,  # More common
        pos=loc["pos"],
        spread=loc["spread"],
        respawn_time=900000.0,  # 15 minutes
        accuracy_min=0.05,
        accuracy_max=0.1,
        damage_mult=0.2,  # Basically can't hurt anything
        damage_recv_mult=1.0,
        threat_dist=30.0,  # Only notice things right next to them
        unlimited_reload=0,
    ))

patrol_settings = {
    "RespawnTime": 1800.0,
    "MinDistRadius": 500.0,
    "MaxDistRadius": 1200.0,
    "DespawnRadius": 300.0,
    "Group": groups
}

path = os.path.join(PATROL_DIR, "PatrolSettings.json")
with open(path, 'w') as f:
    json.dump(patrol_settings, f, indent=4)
print(f"Wrote {path} ({len(groups)} patrols)")
print(f"  Military base patrols: {len(MILITARY_LOCATIONS)}")
print(f"  Military road patrols: {len(ROAD_LOCATIONS)}")
print(f"  Bandit patrols: {len(BANDIT_LOCATIONS)}")
print(f"  Civilian groups: {len(TOWN_LOCATIONS)}")

# ============================================================
# QUEST NPCs at trader safe zones
# ============================================================
quest_npcs = [
    # Green Mountain trader - 3 quest NPCs
    {
        "ConfigVersion": 8,
        "ID": 1,
        "ClassName": "ExpansionQuestNPCBoris",
        "IsAI": 0,
        "Position": [3695.0, 402.13, 5975.0],
        "Orientation": [30.0, 0.0, 0.0],
        "NPCName": "Boris the Scout",
        "DefaultNPCText": "I don't have anything for you right now. Check back later.",
        "Active": 1,
        "NPCLoadoutFile": "",
        "NPCType": 0,
        "NPCFaction": "",
        "Waypoints": [],
        "NPCEmoteID": -1,
        "NPCEmoteIsStatic": 0,
        "NPCInteractionEmoteID": -1,
        "NPCQuestStartEmoteID": -1,
        "NPCQuestCompleteEmoteID": -1,
        "NPCQuestCancelEmoteID": -1,
    },
    {
        "ConfigVersion": 8,
        "ID": 2,
        "ClassName": "ExpansionQuestNPCLinda",
        "IsAI": 0,
        "Position": [3705.0, 402.13, 5990.0],
        "Orientation": [-60.0, 0.0, 0.0],
        "NPCName": "Linda the Hunter",
        "DefaultNPCText": "Nothing for you at the moment. Come back when you're ready for a challenge.",
        "Active": 1,
        "NPCLoadoutFile": "",
        "NPCType": 0,
        "NPCFaction": "",
        "Waypoints": [],
        "NPCEmoteID": -1,
        "NPCEmoteIsStatic": 0,
        "NPCInteractionEmoteID": -1,
        "NPCQuestStartEmoteID": -1,
        "NPCQuestCompleteEmoteID": -1,
        "NPCQuestCancelEmoteID": -1,
    },
    {
        "ConfigVersion": 8,
        "ID": 3,
        "ClassName": "ExpansionQuestNPCSeth",
        "IsAI": 0,
        "Position": [3710.0, 403.153, 5968.0],
        "Orientation": [-130.0, 0.0, 0.0],
        "NPCName": "Seth the Supplier",
        "DefaultNPCText": "Got nothing for you. Try the others.",
        "Active": 1,
        "NPCLoadoutFile": "",
        "NPCType": 0,
        "NPCFaction": "",
        "Waypoints": [],
        "NPCEmoteID": -1,
        "NPCEmoteIsStatic": 0,
        "NPCInteractionEmoteID": -1,
        "NPCQuestStartEmoteID": -1,
        "NPCQuestCompleteEmoteID": -1,
        "NPCQuestCancelEmoteID": -1,
    },
    # Kumyrna trader - 3 quest NPCs
    {
        "ConfigVersion": 8,
        "ID": 4,
        "ClassName": "ExpansionQuestNPCHassan",
        "IsAI": 0,
        "Position": [8350.0, 293.143, 6002.0],
        "Orientation": [-170.0, 0.0, 0.0],
        "NPCName": "Hassan the Wanderer",
        "DefaultNPCText": "The road is quiet today. Come back tomorrow.",
        "Active": 1,
        "NPCLoadoutFile": "",
        "NPCType": 0,
        "NPCFaction": "",
        "Waypoints": [],
        "NPCEmoteID": -1,
        "NPCEmoteIsStatic": 0,
        "NPCInteractionEmoteID": -1,
        "NPCQuestStartEmoteID": -1,
        "NPCQuestCompleteEmoteID": -1,
        "NPCQuestCancelEmoteID": -1,
    },
    {
        "ConfigVersion": 8,
        "ID": 5,
        "ClassName": "ExpansionQuestNPCFrida",
        "IsAI": 0,
        "Position": [8362.0, 292.034, 5970.0],
        "Orientation": [-90.0, 0.0, 0.0],
        "NPCName": "Frida the Collector",
        "DefaultNPCText": "I'm not looking for anything right now.",
        "Active": 1,
        "NPCLoadoutFile": "",
        "NPCType": 0,
        "NPCFaction": "",
        "Waypoints": [],
        "NPCEmoteID": -1,
        "NPCEmoteIsStatic": 0,
        "NPCInteractionEmoteID": -1,
        "NPCQuestStartEmoteID": -1,
        "NPCQuestCompleteEmoteID": -1,
        "NPCQuestCancelEmoteID": -1,
    },
    {
        "ConfigVersion": 8,
        "ID": 6,
        "ClassName": "ExpansionQuestNPCDenis",
        "IsAI": 0,
        "Position": [8372.0, 293.277, 5990.0],
        "Orientation": [-120.0, 0.0, 0.0],
        "NPCName": "Denis the Mercenary",
        "DefaultNPCText": "No jobs right now. Stay sharp out there.",
        "Active": 1,
        "NPCLoadoutFile": "",
        "NPCType": 0,
        "NPCFaction": "",
        "Waypoints": [],
        "NPCEmoteID": -1,
        "NPCEmoteIsStatic": 0,
        "NPCInteractionEmoteID": -1,
        "NPCQuestStartEmoteID": -1,
        "NPCQuestCompleteEmoteID": -1,
        "NPCQuestCancelEmoteID": -1,
    },
]

for npc in quest_npcs:
    path = os.path.join(QUEST_NPC_DIR, f"QuestNPC_{npc['ID']}.json")
    with open(path, 'w') as f:
        json.dump(npc, f, indent=4)
    print(f"Wrote {path} - {npc['NPCName']}")

print("\n=== SUMMARY ===")
print(f"AI Patrols: {len(groups)} total")
print(f"  {len(MILITARY_LOCATIONS)} military base patrols (West, 0.4-0.8 accuracy, 50% spawn, 30min respawn)")
print(f"  {len(ROAD_LOCATIONS)} military road patrols (West, 0.4-0.8 accuracy, 35% spawn, 45min respawn)")
print(f"  {len(BANDIT_LOCATIONS)} bandit patrols (Raiders, 0.1-0.2 accuracy, 0.5x dmg, 25% spawn, 60min respawn)")
print(f"  {len(TOWN_LOCATIONS)} civilian groups (Passive, melee only, 60% spawn, 15min respawn)")
print(f"Quest NPCs: {len(quest_npcs)} (3 at Green Mountain, 3 at Kumyrna)")
print(f"Loadouts: 3 (Military, Bandit, Civilian)")
