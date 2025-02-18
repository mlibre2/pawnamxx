#include <amxmodx>

#define PLUGIN "LimitSlap"
#define VERSION "1.0"
#define AUTHOR "mlibre"

new g_countSlap[33]

const g_limitSlap = 3

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	
	register_concmd("amx_slap", "cmdSlap")
}

public event_new_round()
{
	new players[32], num; get_players(players, num, "ch")
	
	for(new i, id; i < num; i++)
	{
		id = players[i]
		
		if(g_countSlap[id])
		{
			g_countSlap[id] = 0
		}
	}
}

public cmdSlap(id)
{
	if(g_countSlap[id] >= g_limitSlap)
	{
		client_print(id, print_chat, "[AMXX] reached limit (%d) of use per round.", g_limitSlap)
		
		return PLUGIN_HANDLED
	}
	
	g_countSlap[id]++
	
	return PLUGIN_CONTINUE
}
