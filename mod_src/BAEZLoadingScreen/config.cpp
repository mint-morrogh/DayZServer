class CfgPatches
{
    class BAEZLoadingScreen
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"DZ_Data"};
    };
};
class CfgMods
{
    class BAEZLoadingScreen
    {
        dir = "BAEZLoadingScreen";
        picture = "";
        action = "";
        hideName = 1;
        hidePicture = 1;
        name = "BAEZLoadingScreen";
        credits = "";
        author = "BAE-Z";
        version = "1.0";
        extra = 0;
        type = "mod";
        dependencies[] = {"Game"};
        class defs
        {
            class gameScriptModule
            {
                value = "";
                files[] = {"BAEZLoadingScreen/Scripts/3_Game"};
            };
        };
    };
};
