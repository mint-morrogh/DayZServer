class CfgPatches
{
    class SurvivorAnimsFix
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"DZ_Data"};
    };
};
class CfgMods
{
    class SurvivorAnimsFix
    {
        dir = "SurvivorAnimsFix";
        picture = "";
        action = "";
        hideName = 1;
        hidePicture = 1;
        name = "SurvivorAnimsFix";
        credits = "";
        author = "BAE-Z";
        version = "1.0";
        extra = 0;
        type = "mod";
        dependencies[] = {"World"};
        class defs
        {
            class worldScriptModule
            {
                value = "";
                files[] = {"SurvivorAnimsFix/Scripts/4_World"};
            };
        };
    };
};
