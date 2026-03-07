class ActionSearchPlayerAtWallCB : ActionContinuousBaseCB
{
	override void CreateActionComponent()
	{
		m_ActionData.m_ActionComponent = new CAContinuousTime(8);
	}
	/*
	override void InitActionComponent()
	{
		super.InitActionComponent();
		
		RegisterAnimationEvent("CraftingAction", UA_IN_CRAFTING);
	}
	*/
};

class ActionSearchPlayerAtWall: ActionContinuousBase
{	
	void ActionSearchPlayerAtWall()
	{
		m_CallbackClass = ActionSearchPlayerAtWallCB;
		m_CommandUID = 62000;
		m_FullBody = true;
		m_StanceMask = DayZPlayerConstants.STANCEMASK_ERECT;
		m_Sound = "craft_universal_0";
		m_SpecialtyWeight = UASoftSkillsWeight.PRECISE_LOW;
		m_Text = "#SA_search";
	}

	override typename GetInputType()
	{
		return ContinuousInteractActionInput;
	}

	override bool HasProgress()
	{
		return true;
	}

	override void CreateConditionComponents()  
	{
		m_ConditionTarget = new CCTMan(UAMaxDistances.DEFAULT);
		m_ConditionItem = new CCINone;
	}
	
	override bool ActionCondition( PlayerBase player, ActionTarget target, ItemBase item )
	{
		PlayerBase body_EAI;
		Class.CastTo(body_EAI, target.GetObject());
		if ( body_EAI &&  body_EAI.IsAlive() && body_EAI.GetIdentity()) // && body_EAI.GetIdentity().GetName())
		{
			return false; //disabled until finished
			
			EmoteManager em = body_EAI.GetEmoteManager();
			if (em && body_EAI.GetSAEmoteID() == EmoteSurAnmHandsOnWall.CMD_GESTUREFB_HandsOnWall)
			{
				//GetGame().GetMission().OnEvent(ChatMessageEventTypeID, new ChatMessageEventParams(CCDirect, "", "Callback EMOTE " + em.m_Callback.m_callbackID, ""));
				return true;
				/*
				if (em.IsEmotePlaying())
				{
					return true;
					
					if (em.GetGesture())
					{
						if(em.GetGesture() == EMOTE_SAHandsOnWall)
						{
							return true;
						}
						
					}
					
				}
				*/
			}
			
		}
		return false;
	}	
}