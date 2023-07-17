#include <amxmodx>
#include <cstrike>
#include <fun>

new pfrags[33]

public plugin_init() {
    register_plugin("+5kill/M4A1 | +10kill/AK47", "1.1", "mlibre")
    
    register_event("ResetHUD","playerSpawn","b")
}

public playerSpawn(id) pfrags[id]=0

public client_death(attacker, victim, weapon) {
    if(!is_user_connected(attacker) || victim == attacker) return
    
    pfrags[attacker]=pfrags[attacker]+1
    
    switch(pfrags[attacker]) {
        case 5: {
            if(weapon == CSW_AK47) engclient_cmd(attacker, "drop", "weapon_ak47")
            
            give_item(attacker, "weapon_m4a1"),cs_set_user_bpammo(attacker, CSW_M4A1, 90),
            engclient_cmd(attacker, "weapon_m4a1")
        }
        case 10: {
            if(weapon == CSW_M4A1) engclient_cmd(attacker, "drop", "weapon_m4a1")
        
            give_item(attacker, "weapon_ak47"),cs_set_user_bpammo(attacker, CSW_AK47, 90),
            engclient_cmd(attacker, "weapon_ak47")
        }
    }

} 
