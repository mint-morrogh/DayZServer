// AmmoStacks — doubles max stack size for all loose ammo

modded class Ammunition_Base
{
    override int GetQuantityMax()
    {
        return super.GetQuantityMax() * 2;
    }
}
