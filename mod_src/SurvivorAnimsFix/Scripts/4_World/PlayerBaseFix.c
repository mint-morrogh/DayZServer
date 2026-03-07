// Fix: SurvivorAnims crashes with "Object::GetHealth01 cannot be called on client"
// when Expansion AI entities go through the CommandHandler chain on the client.
// SurvivorAnims calls GetAnimInterface()/AnimSetInt() on all PlayerBase entities,
// but remote AI proxies on the client don't have health state, causing the engine
// to throw GetHealth01 errors every frame until the client crashes.
//
// This mod loads AFTER SurvivorAnims and wraps ModCommandHandlerAfter so it only
// runs for the local player on the client side.

modded class PlayerBase
{
    override bool ModCommandHandlerAfter(float pDt, int pCurrentCommandID, bool pCurrentCommandFinished)
    {
        // On client in multiplayer, only process for the local player entity.
        // Remote players and AI entities don't need client-side animation updates
        // and calling GetAnimInterface()/AnimSetInt() on them crashes the engine.
        if (GetGame().IsMultiplayer() && !GetGame().IsServer())
        {
            if (GetGame().GetPlayer() != this)
                return false;
        }

        return super.ModCommandHandlerAfter(pDt, pCurrentCommandID, pCurrentCommandFinished);
    }
}
