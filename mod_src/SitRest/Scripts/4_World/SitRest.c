/**
 * SitRest - BAE-Z
 *
 * Freezes hunger (energy) and thirst (water) drain while the player
 * is resting: any sit emote, campfire sit, lying down, or SurvivorAnims
 * SitNew. Eating/drinking while resting still works — the snapshot
 * ratchets upward.
 *
 * Detected emotes:
 *   ID_EMOTE_SITA (14)      — sit cross-legged
 *   ID_EMOTE_SITB (15)      — sit straight
 *   ID_EMOTE_CAMPFIRE (13)  — campfire sit
 *   ID_EMOTE_LYINGDOWN (5)  — lie down
 *   5501                    — SurvivorAnims "SitNew"
 */

modded class EmoteManager
{
	int SitRest_GetGestureID()
	{
		return m_CurrentGestureID;
	}
}

modded class PlayerBase
{
	private bool m_SitRest_IsResting = false;
	private bool m_SitRest_TimerStarted = false;
	private float m_SitRest_Energy = -1;
	private float m_SitRest_Water = -1;

	override void Init()
	{
		super.Init();

		if (!GetGame().IsServer())
			return;

		GetGame().GetCallQueue(CALL_CATEGORY_SYSTEM).CallLater(SitRestTick, 1000, true);
		m_SitRest_TimerStarted = true;
	}

	override void EEDelete(EntityAI parent)
	{
		if (GetGame() && GetGame().IsServer() && m_SitRest_TimerStarted)
		{
			GetGame().GetCallQueue(CALL_CATEGORY_SYSTEM).Remove(SitRestTick);
		}

		super.EEDelete(parent);
	}

	private bool SitRest_IsRestEmoteActive()
	{
		EmoteManager em = GetEmoteManager();
		if (!em)
			return false;

		int id = em.SitRest_GetGestureID();
		if (id != 0)
			Print("[SitRest] GestureID=" + id);

		// SITA=14, SITB=15, Campfire=13, LyingDown=5, SurvivorAnims SitNew=5501
		return (id == EmoteConstants.ID_EMOTE_SITA || id == EmoteConstants.ID_EMOTE_SITB || id == 13 || id == 5 || id == 5501);
	}

	private void SitRestTick()
	{
		if (!GetGame() || !GetGame().IsServer())
			return;

		if (!IsAlive())
			return;

		bool resting = SitRest_IsRestEmoteActive();

		if (resting && !m_SitRest_IsResting)
		{
			// Just started resting — snapshot current stats
			m_SitRest_Energy = GetStatEnergy().Get();
			m_SitRest_Water = GetStatWater().Get();
			m_SitRest_IsResting = true;
		}
		else if (resting && m_SitRest_IsResting)
		{
			// Still resting — freeze drain, allow eating/drinking
			float curEnergy = GetStatEnergy().Get();
			float curWater = GetStatWater().Get();

			if (curEnergy > m_SitRest_Energy)
				m_SitRest_Energy = curEnergy;
			else if (curEnergy < m_SitRest_Energy)
				GetStatEnergy().Set(m_SitRest_Energy);

			if (curWater > m_SitRest_Water)
				m_SitRest_Water = curWater;
			else if (curWater < m_SitRest_Water)
				GetStatWater().Set(m_SitRest_Water);
		}
		else if (!resting && m_SitRest_IsResting)
		{
			// Stood up — clear snapshot, resume normal drain
			m_SitRest_IsResting = false;
			m_SitRest_Energy = -1;
			m_SitRest_Water = -1;
		}
	}
}
