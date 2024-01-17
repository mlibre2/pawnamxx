#include <amxmodx>
#include <engine>

#define PLUGIN "Bot Freeze"
#define VERSION "1.0"
#define AUTHOR "mlibre"

new const bot_cvar[][] =
{
	0,
	"bot_freeze",
	"yb_freeze_bots"
}

new mp_bot_freezetime, type

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_logevent("logevent_round_start", 2, "1=Round_Start") 
	
	mp_bot_freezetime = register_cvar("mp_bot_freezetime", "10")	//<-starts after mp_freezetime
}

public plugin_cfg()
{
	for(new i = 1; i < sizeof bot_cvar; i++)
	{
		if(cvar_exists(bot_cvar[i])) 
		{
			type = i
			
			break
		}
	}
	
	mp_bot_freezetime = get_pcvar_num(mp_bot_freezetime)
}

public logevent_round_start()
{
	if(task_exists(666))
	{
		remove_task(666)
	}
	
	set_task(float(mp_bot_freezetime), "bot_task", 666)
	
	bot_action(1)
}

public bot_task()
{
	bot_action(0)
}

stock bot_action(x)
{
	switch(type) 
	{
		case 1,2: set_cvar_num(bot_cvar[type], x)
		default:
		{
			new bots[32], maxbots
			
			get_players(bots, maxbots, "adh")
			
			for(new i, id; i < maxbots; i++)
			{
				id = bots[i]
				
				if(x)
					entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) | FL_FROZEN)
				else
					entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) & ~FL_FROZEN)
			}
		}
	}
}
