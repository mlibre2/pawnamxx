#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#if AMXX_VERSION_NUM > 182
#define client_disconnect client_disconnected
#endif

#define ADMIN_FLAG_1 ADMIN_LEVEL_A // users.ini "m" -> admin_te1 - admin_ct1
#define ADMIN_FLAG_2 ADMIN_LEVEL_B // users.ini "n" -> admin_te2 - admin_ct2

new g_bAdmin[33], fgm[256]

static const g_models[][] = 
{ 
    // cstrike/models/player/admin_te1/admin_te1.mdl
    "admin_te1", "admin_ct1", "admin_te2", "admin_ct2"
}
public plugin_precache() {
    register_plugin("Admin Model", "1.4", "whitemike (edited mlibre)")
    for(new i;i < sizeof g_models;i++) {
        formatex(fgm, charsmax(fgm), "models/player/%s/%s.mdl", g_models[i], g_models[i])
        if(file_exists(fgm)) {
            precache_model(fgm)
        } else {
            new sfs[256]; formatex(sfs, charsmax(sfs), "Falta: ^"%s^"", fgm)
            set_fail_state(sfs)
        }
    }
    RegisterHam(Ham_Spawn, "player", "FwdHamPlayerSpawn", 1)
}
public client_putinserver(id)
    g_bAdmin[id] = (get_user_flags(id) & ADMIN_FLAG_1 ? 1 : get_user_flags(id) & ADMIN_FLAG_2 ? 2 : 0)

public client_disconnect(id) 
    g_bAdmin[id] = 0

public FwdHamPlayerSpawn(const id) {
    if(g_bAdmin[id] > 0 && is_user_alive(id)) {
        new CsTeams:Team = cs_get_user_team(id)
        switch(g_bAdmin[id]) {
            case 1: {
                switch(Team) {
                    case CS_TEAM_T: cs_set_user_model(id, g_models[0])
                    case CS_TEAM_CT: cs_set_user_model(id, g_models[1])
                }
            }
            case 2: {
                switch(Team) {
                    case CS_TEAM_T: cs_set_user_model(id, g_models[2])
                    case CS_TEAM_CT: cs_set_user_model(id, g_models[3])
                }
            }
        }
    }
} 
