class CfgPatches
{
    class HealthBoost
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"DZ_Data"};
    };
};
class CfgMods
{
    class HealthBoost
    {
        dir = "HealthBoost";
        picture = "";
        action = "";
        hideName = 1;
        hidePicture = 1;
        name = "HealthBoost";
        credits = "Blood and Barter";
        author = "Blood and Barter";
        version = "1.0";
        extra = 0;
        type = "mod";
        dependencies[] = {"World"};
        class defs
        {
            class worldScriptModule
            {
                value = "";
                files[] = {"HealthBoost/Scripts/4_World"};
            };
        };
    };
};
