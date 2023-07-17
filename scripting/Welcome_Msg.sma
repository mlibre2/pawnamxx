#include <amxmodx>

new pspawn[33], cvar_msg, save_msg[256]

public plugin_init() {
    register_plugin("Welcome Msg", "1.0", "mlibre")
    register_event("ResetHUD","playerSpawn","b")
    
    cvar_msg = register_cvar("amx_welcome_msg","Bienvenido al Servidor!^n") // ^n salto de linea
}
public playerSpawn(id) {
    if( is_user_alive(id) && !pspawn[id] ) {
        get_pcvar_string(cvar_msg, save_msg, charsmax(save_msg))
        
        set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, -1.0, 1, 6.0, 12.0)
        show_hudmessage(id, save_msg)
        
        pspawn[id] = 1
    }
}
public client_disconnect(id) pspawn[id] = 0 
