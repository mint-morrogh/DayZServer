class CfgPatches
{
	class BatteryBoost
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"DZ_Data", "DZ_Gear_Consumables"};
	};
};
class CfgMods
{
	class BatteryBoost
	{
		dir = "BatteryBoost";
		picture = "";
		action = "";
		hideName = 1;
		hidePicture = 1;
		name = "BatteryBoost";
		credits = "";
		author = "";
		version = "1.0";
		extra = 0;
		type = "mod";
		dependencies[] = {"World"};
		class defs
		{
			class worldScriptModule
			{
				value = "";
				files[] = {};
			};
		};
	};
};
class CfgVehicles
{
	class Inventory_Base;
	class Battery9V: Inventory_Base
	{
		class EnergyManager
		{
			hasIcon = 1;
			switchOnAtSpawn = 1;
			isPassiveDevice = 1;
			energyStorageMax = 250;
			energyAtSpawn = 250;
			convertEnergyToQuantity = 1;
			reduceMaxEnergyByDamageCoef = 0;
			powerSocketsCount = 1;
		};
	};
};
