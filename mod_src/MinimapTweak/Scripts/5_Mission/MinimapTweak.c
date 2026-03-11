/**
 * MinimapTweak - BAE-Z
 *
 * - Moves minimap to top-right corner
 * - Hides coordinate/stats overlay on the minimap HUD
 * - Fixes player arrow disappearing after Tab (inventory)
 * - Hides quest tracker when minimap is active (both use right side)
 * - Shows Expansion Groups party members on the minimap
 *
 * Loads AFTER ExpansionGPS_Override via requiredAddons.
 */

modded class IngameHud
{
	private Widget m_QuestHudPanel;
	private MapWidget m_MinimapMapWidget;

	override void Init(Widget hud_panel_widget)
	{
		super.Init(hud_panel_widget);

		if (!m_GPSPanel)
			return;

		// Reposition minimap to top-right corner.
		// Layout uses halign right_ref + valign bottom_ref,
		// so Y increases upward from screen bottom.
		// Panel height is ~0.21, so Y=0.77 puts the top at ~98% (2% margin).
		float px, py;
		m_GPSPanel.GetPos(px, py);
		m_GPSPanel.SetPos(px, 0.77);

		// Get reference to the minimap's MapWidget for party member markers
		m_MinimapMapWidget = MapWidget.Cast(m_GPSPanel.FindAnyWidget("Map"));
	}

	override void RefreshHudVisibility()
	{
		super.RefreshHudVisibility();

		// Force-hide coords/stats on the minimap every HUD refresh
		if (m_MapStatsPanel)
			m_MapStatsPanel.Show(false);
	}

	override void Update(float timeslice)
	{
		super.Update(timeslice);

		// Fix: Expansion hides the player arrow when a menu opens (Tab)
		// but a bad visibility check prevents it from coming back.
		// Re-show the arrow whenever the minimap is active and no menu is open.
		if (m_PlayerArrowMarker && m_ExpansionGPSState && m_ExpansionGPSMapState)
		{
			UIScriptedMenu topMenu = g_Game.GetUIManager().GetMenu();
			if (!topMenu)
				m_PlayerArrowMarker.Show(true);
		}

		// Hide quest tracker when minimap is active to prevent overlap
		if (!m_QuestHudPanel)
			m_QuestHudPanel = GetGame().GetWorkspace().FindAnyWidget("ExpansionQuestHud");

		if (m_QuestHudPanel)
			m_QuestHudPanel.Show(!m_ExpansionGPSState);

		// Draw party members on the minimap when it's active
		if (m_MinimapMapWidget && m_ExpansionGPSState && m_ExpansionGPSMapState)
		{
			m_MinimapMapWidget.ClearUserMarks();
			DisplayMinimapPartyMembers();
		}
	}

	private void DisplayMinimapPartyMembers()
	{
		if (!ExpansionPartyModule.s_Instance)
			return;

		ExpansionPartyData party = ExpansionPartyModule.s_Instance.GetParty();
		if (!party)
			return;

		string myUID = "";
		Man myPlayer = GetGame().GetPlayer();
		if (myPlayer)
		{
			PlayerIdentity myIdentity = myPlayer.GetIdentity();
			if (myIdentity)
				myUID = myIdentity.GetId();
		}

		array<ref ExpansionPartyPlayerData> members = party.GetPlayers();
		if (!members)
			return;

		for (int i = 0; i < members.Count(); i++)
		{
			ExpansionPartyPlayerData member = members.Get(i);
			if (!member)
				continue;

			if (myUID != "" && member.UID == myUID)
				continue;

			if (member.Marker)
			{
				vector memberPos = member.Marker.GetPosition();
				if (memberPos[0] != 0 || memberPos[2] != 0)
				{
					int memberColor = member.GetColor();
					if (memberColor == 0)
						memberColor = ARGB(255, 0, 191, 255);
					m_MinimapMapWidget.AddUserMark(memberPos, member.Name, memberColor, "VanillaPPMap\\GUI\\Textures\\CustomMapIcons\\waypointeditor_CA.paa");
				}
			}
		}
	}
}
