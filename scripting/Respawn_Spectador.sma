#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <cstrike>

public plugin_init() {
    register_plugin("Respawn Spectador", "1.1", "mlibre")
    
    register_event("TeamInfo", "player_joinTeam", "a")
    register_event("HLTV", "new_round", "a", "1=0", "2=0")

    RegisterHam(Ham_Spawn, "player", "FwdHamPlayerSpawn", 1)
}
public player_joinTeam() {
    new id = read_data(1)
    
    if(is_user_alive(id)) return

    new szTeam[2]; read_data(2, szTeam, charsmax(szTeam))

    switch(szTeam[0]) {
        case 'S': set_task(0.1, "spec_revive", id)
    }
}
public new_round() {
    new maxplayers = get_maxplayers()
    
    for(new i = 1; i <= maxplayers; i++ ) {    
        if(get_user_team(i) == 3 && !is_user_alive(i)) set_task(0.1, "spec_revive", i)
    }
}
public spec_revive(id) {
    ExecuteHamB(Ham_CS_RoundRespawn, id)
            
    give_item(id, "item_suit"), give_item(id, "item_kevlar"), give_item(id, "item_assaultsuit"), give_item(id, "weapon_knife"), give_item(id, "weapon_hegrenade")

    give_item(id, "weapon_deagle"), cs_set_user_bpammo(id, CSW_DEAGLE, 35)
    give_item(id, "weapon_m4a1"), cs_set_user_bpammo(id, CSW_M4A1, 90)

    if(task_exists(id)) remove_task(id)
}
public FwdHamPlayerSpawn(const id) {
    if(is_user_alive(id) && get_user_team(id) == 3) cs_set_user_model(id, "vip")
} 
