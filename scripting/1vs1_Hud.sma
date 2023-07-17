#include <amxmodx> 
#include <hamsandwich>

new mtt, stt[256], mct, sct[256]

public plugin_init() { 
    register_plugin("1vs1 Hud", "1.1", "~Ice*shOt & mlibre")
    
    mtt = register_cvar("mhud_tt","*** Eres el ultimo TERRORISTA vivo! ***^nVS: ")
    mct = register_cvar("mhud_ct","*** Eres el ultimo ANTI-TERRORISTA vivo! ***^nVS: ")
    
    RegisterHam(Ham_Killed, "player", "Fwd_PlayerKilled", 1)
}
public Fwd_PlayerKilled(id) {
    static TPlayers[32], CTPlayers[32], TNum, CTNum
    get_players(TPlayers, TNum, "ae", "TERRORIST")
    get_players(CTPlayers, CTNum, "ae", "CT") 
    
    if (TNum == 1 && CTNum == 1)
    {
        new TName[32], CTName[32]
        get_user_name(TPlayers[0], TName, charsmax(TName))
        get_user_name(CTPlayers[0], CTName, charsmax(CTName))
        
        if( get_user_team(TPlayers[0]) == 1)
        {
            get_pcvar_string(mtt,stt,charsmax(stt))
            set_hudmessage(255, 0, 0, -1.0, 0.25, 1, 6.0, 10.0)
            show_hudmessage(TPlayers[0], "%s %s", stt, CTName)
        }
        if( get_user_team(CTPlayers[0]) == 2)
        {
            get_pcvar_string(mct,sct,charsmax(sct))
            set_hudmessage(0, 0, 255, -1.0, 0.25, 1, 6.0, 10.0)
            show_hudmessage(CTPlayers[0], "%s %s", sct, TName)
        }
    } 
} 
