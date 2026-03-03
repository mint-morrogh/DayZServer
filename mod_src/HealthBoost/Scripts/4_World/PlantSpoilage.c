/**
 * PlantSpoilage - BAE-Z (HealthBoost)
 *
 * Planted crops last 3x longer after reaching full maturity
 * before spoiling (default 4 hours → 12 hours).
 */

modded class PlantBase
{
	override void Init(SeedBase seed, float fertility, float harvesting_quantity, float water)
	{
		super.Init(seed, fertility, harvesting_quantity, water);

		if (!GetGame().IsServer())
			return;

		m_SpoilAfterFullMaturityTime = 43200; // 12 hours (default 14400 = 4 hours)
	}
}
