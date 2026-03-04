// BandageBoost — doubles bandage uses before consumed

modded class BandageDressing
{
    override int GetQuantityMax()
    {
        return super.GetQuantityMax() * 2;
    }
}
