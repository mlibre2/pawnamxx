#include <amxmodx>

new const SONIDO_WAV[] = { "mi_sonidos/mi_sonido.wav" } 

public plugin_init() {
    register_plugin("Kill Knife/Sound", "1.0", "mlibre")
}

public plugin_precache() precache_sound(SONIDO_WAV)

public client_death(attacker, victim, weapon) {
    if(!is_user_connected(attacker) || victim == attacker) return
    
    if(weapon == CSW_KNIFE) client_cmd(attacker, "spk %s", SONIDO_WAV)
} 
