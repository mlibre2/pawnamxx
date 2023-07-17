#include <amxmodx>
#include <engine>

new prew[256], vp_arma[][] = {
    "models/v_knife_r.mdl",                    //Knife
    "models/v_9mmar.mdl", "models/p_9mmar.mdl",        //M4A1
    "models/v_egon.mdl", "models/p_egon.mdl"        //AK47
}
public plugin_init() {
    register_plugin("Admin Knife/M4a1/Ak47", "1.1", "PlayBoy (edited mlibre)")
    register_event( "CurWeapon", "Event_CurWeapon", "be", "1=1" )
}
public plugin_precache() {
    for(new i;i < sizeof vp_arma;i++)
        formatex(prew, charsmax(prew), "%s", vp_arma[i]), precache_model(prew)
}
public Event_CurWeapon(id) {
    if(!is_user_alive(id))
        return
    if( get_user_flags(id) & ADMIN_RESERVATION) {
         switch(read_data(2)) {
             case CSW_KNIFE: {
                entity_set_string(id, EV_SZ_viewmodel, vp_arma[0])
            }
            case CSW_M4A1: {
                entity_set_string(id, EV_SZ_viewmodel , vp_arma[1])
                entity_set_string(id, EV_SZ_weaponmodel, vp_arma[2])
            }
            case CSW_AK47: {
                entity_set_string(id, EV_SZ_viewmodel , vp_arma[3])
                entity_set_string(id, EV_SZ_weaponmodel, vp_arma[4])
            }
        }
    }
} 
