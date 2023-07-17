#include <amxmodx>
#include <cstrike>
#include <fun>

new pfrags[33], weapons[32], num, i, weaponid

const PRIMARY_WEAPONS = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)
|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)
|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)
|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const KNIFE_HE_WEAPONS = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)

public plugin_init() {
    register_plugin("+5kill/AWP", "1.0", "mlibre")
    
    register_event("ResetHUD","playerSpawn","b")
}
public playerSpawn(id) pfrags[id]=0

public client_death(attacker, victim, weapon) {
    if(!is_user_connected(attacker) || victim == attacker) return
    
    pfrags[attacker]=pfrags[attacker]+1
    
    switch(pfrags[attacker]) {
        case 5: {
            if(weapon == PRIMARY_WEAPONS || SECONDARY_WEAPONS || KNIFE_HE_WEAPONS) UTIL_DropPrimary(attacker)
            
            give_item(attacker, "weapon_awp"),cs_set_user_bpammo(attacker, CSW_AWP, 30)
        }
    }
}
UTIL_DropPrimary(id) {
    num = 0; get_user_weapons(id, weapons, num)
    
    for( i = 0; i < num; i++ ) {
        weaponid = weapons[i]
        
        if(( (1<<weaponid) & PRIMARY_WEAPONS)) {
            static wname[32]; get_weaponname(weaponid, wname, charsmax(wname)), engclient_cmd( id, "drop", wname)
        }
    }
} 
