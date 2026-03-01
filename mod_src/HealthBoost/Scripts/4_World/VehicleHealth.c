/**
 * VehicleHealth - Blood & Barter (HealthBoost)
 *
 * Every 60 seconds, vehicle global health is repaired to max.
 * Vehicles are effectively unbreakable — fluids and gas still
 * need managing, but the chassis stays pristine.
 */

modded class CarScript
{
	private bool m_VehicleRepairStarted = false;

	override void EEInit()
	{
		super.EEInit();

		if (!GetGame().IsServer())
			return;

		if (m_VehicleRepairStarted)
			return;

		m_VehicleRepairStarted = true;
		VehicleRepairTick();
		GetGame().GetCallQueue(CALL_CATEGORY_SYSTEM).CallLater(VehicleRepairTick, 60000, true);
	}

	void VehicleRepairTick()
	{
		if (!GetGame() || !GetGame().IsServer())
			return;

		if (!IsAlive())
			return;

		float maxHp = GetMaxHealth("", "Health");
		float curHp = GetHealth("", "Health");
		if (curHp < maxHp)
			SetHealth("", "Health", maxHp);
	}
}
