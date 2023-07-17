#include <amxmodx>
#include <cstrike>
#include <csx>

new hm, cvar_msg, save_msg[256]

public plugin_init() {
    register_plugin("HeadShot Money", "1.1", "mlibre")
    
    cvar_msg = register_cvar("amx_headshot_msg","[UP-CTF] Has hecho un HeadShot recibiste")
    hm = register_cvar("amx_headshot_money","500")

}
public client_death( attacker, victim, weapon, hitplace )
{
    if(!is_user_connected(attacker) || victim == attacker) return
    
    if( hitplace == HIT_HEAD ) {
        get_pcvar_string(cvar_msg, save_msg, charsmax(save_msg))

        set_hudmessage(255, 0, 0, -1.0, 0.25, 1, 6.0, 12.0)
        show_hudmessage(attacker, "%s %d$", save_msg, get_pcvar_num(hm))
        
        cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(hm))
    }
} 
