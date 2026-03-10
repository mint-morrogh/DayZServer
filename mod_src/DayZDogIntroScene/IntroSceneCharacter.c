modded class IntroSceneCharacter
{
	protected Object m_DogObj;
	override protected void CharacterLoad( int character_id, vector char_pos, vector char_rot )
	{
		super.CharacterLoad( character_id, char_pos, char_rot );
		/*
		if ( character_id == -1 )
		{
			Error("IntroSceneCharacter->CharacterLoad: character_id = "+ character_id +" Cant Load Character!!!");
			return;
		}
		
		CharacterUnload();
		
		SetCharacterID( character_id );
				
		m_CharacterObj = PlayerBase.Cast( m_CharacterDta.CreateCharacterPerson( character_id ) );
		*/
		if ( m_CharacterObj )
		{
			
			//m_CharacterObj.PlaceOnSurface();
			//m_CharacterObj.SetPosition(char_pos);
			//m_CharacterObj.SetOrientation(char_rot);
			if (m_CharacterObj.HaveDog() && !m_DogObj )
			{
				m_DogObj = g_Game.CreateObjectEx("Doggo_Stay" + m_CharacterObj.GetDogIndex(), m_CharacterObj.ModelToWorld("-0.6 0 -0.5"), ECE_PLACE_ON_SURFACE);
				m_DogObj.SetOrientation(char_rot);
				//DayZAnimalInputController inputController = AnimalBase.Cast(m_DogObj).GetInputController();
				//inputController.OverrideBehaviourAction(true, DayZAnimalBehaviourAction.RESTING_INPUT);
				//crashing!!!
				//m_CharacterObj.RestoreDogInventory();
			}

		}	
	}
}