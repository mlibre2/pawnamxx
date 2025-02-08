#include <amxmodx>

#define PLUGIN "msg_connect"
#define VERSION "1.0"
#define AUTHOR "mlibre"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
}

new const g_sound[] = "misc/talk.wav"

public plugin_precache() 
{
	precache_sound(g_sound)
}

public client_connect(id)
{
	new nick[32]; get_user_name(id, nick, charsmax(nick))
#if AMXX_VERSION_NUM > 182
	client_print_color(0, print_team_default, "[AMXX]^4 %s^1 trying to connect.", nick)
#else
	client_print(0, print_chat, "[AMXX] %s trying to connect.", nick)
#endif
}

public client_putinserver(id)
{
	new nick[32]; get_user_name(id, nick, charsmax(nick))
#if AMXX_VERSION_NUM > 182
	client_print_color(0, print_team_default, "[AMXX]^4 %s^1 connected.", nick)
#else
	client_print(0, print_chat, "[AMXX] %s connected.", nick)
#endif
	client_cmd(0, "spk ^"%s^"", g_sound)
}
