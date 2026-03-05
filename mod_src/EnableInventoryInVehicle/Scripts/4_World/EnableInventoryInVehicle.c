/**
 * EnableInventoryInVehicle - BAE-Z
 *
 * Allows inventory access while in vehicles and during sit emotes.
 * Replaces removed Workshop mod (3594596641) with a dog-mod-safe
 * implementation — checks for open scripted menus before re-locking
 * inventory so DayZ-Dog's DogManageMenu doesn't get stuck.
 */

modded class EmoteManager
{
    int EIIV_GetGestureID()
    {
        return m_CurrentGestureID;
    }
}

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

    override bool CanManipulateInventory()
    {
        // Allow inventory during sit emotes (SitA, SitB, SurvivorAnims SitNew)
        EmoteManager em = GetEmoteManager();
        if (em)
        {
            int id = em.EIIV_GetGestureID();
            if (id == EmoteConstants.ID_EMOTE_SITA || id == EmoteConstants.ID_EMOTE_SITB || id == 5501)
                return true;
        }
        return super.CanManipulateInventory();
    }
}
