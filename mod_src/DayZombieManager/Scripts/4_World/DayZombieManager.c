/**
 * DayZombieManager - BAE-Z
 *
 * 1. Prevents zombies from spawning near trader safe zones by
 *    despawning them immediately on init.
 * 2. Reduces zombie population during daytime by despawning a
 *    percentage of zombies as they spawn. At night, all zombies
 *    spawn normally.
 *
 * The Central Economy keeps trying to maintain its target counts,
 * but this mod continuously thins the herd during daylight hours,
 * resulting in roughly half the normal zombie population during the day.
 */

modded class ZombieBase
{
	// Probability that a zombie despawns during daytime (0.0 to 1.0)
	// 0.55 = roughly 45% of zombies survive during day
	static const float DAY_DESPAWN_CHANCE = 0.55;

	// Daytime window (24h format) - outside this range is "night"
	static const int DAY_START_HOUR = 6;
	static const int DAY_END_HOUR = 20;

	// Trader safe zone centers [X, Z] and exclusion radius
	// Hub 1: west traders (~3705, 5985)
	// Hub 2: Kumyrna traders (~8360, 5984)
	static const float SZ1_X = 3705.0;
	static const float SZ1_Z = 5985.0;
	static const float SZ2_X = 8360.0;
	static const float SZ2_Z = 5984.0;
	static const float SZ_RADIUS_SQ = 22500.0; // 150m squared

	override void EEInit()
	{
		super.EEInit();

		if (!GetGame().IsServer())
			return;

		// Check safe zones first — always despawn, day or night
		vector pos = GetPosition();
		float dx, dz;

		dx = pos[0] - SZ1_X;
		dz = pos[2] - SZ1_Z;
		if ((dx * dx + dz * dz) < SZ_RADIUS_SQ)
		{
			GetGame().GetCallQueue(CALL_CATEGORY_SYSTEM).CallLater(DeferredDespawn, 150, false);
			return;
		}

		dx = pos[0] - SZ2_X;
		dz = pos[2] - SZ2_Z;
		if ((dx * dx + dz * dz) < SZ_RADIUS_SQ)
		{
			GetGame().GetCallQueue(CALL_CATEGORY_SYSTEM).CallLater(DeferredDespawn, 150, false);
			return;
		}

		// Day/night population thinning
		int year, month, day, hour, minute;
		GetGame().GetWorld().GetDate(year, month, day, hour, minute);

		if (hour >= DAY_START_HOUR && hour < DAY_END_HOUR)
		{
			if (Math.RandomFloat01() < DAY_DESPAWN_CHANCE)
			{
				GetGame().GetCallQueue(CALL_CATEGORY_SYSTEM).CallLater(DeferredDespawn, 150, false);
			}
		}
	}

	private void DeferredDespawn()
	{
		if (this)
		{
			GetGame().ObjectDelete(this);
		}
	}
}
