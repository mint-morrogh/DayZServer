/**
 * EnableInventoryInVehicle - BAE-Z
 *
 * Allows inventory access while in vehicles. Replaces removed Workshop mod
 * (3594596641) with a dog-mod-safe implementation — checks for open
 * scripted menus before re-locking inventory so DayZ-Dog's
 * DogManageMenu doesn't get stuck.
 */

modded class PlayerBase
{
    override void OnCommandVehicleStart()
    {
        super.OnCommandVehicleStart();
        if (GetInventory())
            GetInventory().UnlockInventory(LOCK_FROM_SCRIPT);
    }

    override void OnCommandVehicleFinish()
    {
        // Guard: don't re-lock if a scripted menu (e.g. DogManageMenu) is open,
        // otherwise the menu captures input but inventory lock prevents interaction
        if (GetInventory() && !GetGame().GetUIManager().GetMenu())
            GetInventory().LockInventory(LOCK_FROM_SCRIPT);
        super.OnCommandVehicleFinish();
    }

    override bool CanReceiveItemIntoHands(EntityAI item_to_hands)
    {
        if (IsInVehicle())
            return true;
        return super.CanReceiveItemIntoHands(item_to_hands);
    }

}
