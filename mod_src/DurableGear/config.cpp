class CfgPatches
{
	class DurableGear
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"DZ_Data"};
	};
};
class CfgMods
{
	class DurableGear
	{
		dir = "DurableGear";
		picture = "";
		action = "";
		hideName = 1;
		hidePicture = 1;
		name = "DurableGear";
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
				files[] = {"DurableGear/Scripts/4_World"};
			};
		};
	};
};
