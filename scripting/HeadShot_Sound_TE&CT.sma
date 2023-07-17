#include <amxmodx>
#include <csx>

new const SONIDO_WAV[][] = { 
    "mi_sonidos/HeadShot_TE.wav", "mi_sonidos/HeadShot_CT.wav"
}
public plugin_precache() {
    register_plugin("HeadShot Sound (TE/CT)", "1.0", "mlibre")
    
    for(new i; i < sizeof SONIDO_WAV; i++) 
        precache_sound(SONIDO_WAV[i])
}
public client_death( attacker, victim, weapon, hitplace ) {
    if(!is_user_connected(attacker) || victim == attacker) return
    
    if( hitplace == HIT_HEAD ) {
        switch( get_user_team(victim) ) { 
            case 1: client_cmd(0, "spk ^"%s^"", SONIDO_WAV[0])
            case 2: client_cmd(0, "spk ^"%s^"", SONIDO_WAV[1])
        }
    }
} 
