#include <amxmodx>
#include <engine>
#include <hamsandwich>

#define PLUGIN "Bot Freeze"
#define VERSION "1.2a"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
#else
	#define MAX_PLAYERS 32
#endif

new const bot_cvar[][] =
{
	0,
	"bot_freeze",
	"yb_freeze_bots"
}

enum _:x
{
	type,
	bool:spawn,
	isBot[MAX_PLAYERS + 1],
	count
}

new mp_bot_freezetime, bot_enum[x]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	mp_bot_freezetime = register_cvar("mp_bot_freezetime", "10")	//<-starts after mp_freezetime
	
	register_logevent("logevent_round_start", 2, "1=Round_Start") 
}

public plugin_cfg()
{
	for(new i = 1; i < sizeof bot_cvar; i++)
	{
		if(cvar_exists(bot_cvar[i])) 
		{
			bot_enum[type] = i
			
			break
		}
	}
}

public client_putinserver(id)
{
	if( !bot_enum[spawn] && is_user_bot(id) )
	{
		bot_enum[spawn] = true
		
		set_task(0.1, "bot_RegisterHamFromEntity", id)
	}
}

public bot_RegisterHamFromEntity(id)
{
	RegisterHamFromEntity(Ham_Spawn, id, "bot_spawn", true)
}

public bot_spawn(id)
{
	if( !bot_enum[isBot][id] && is_user_alive(id) )
	{
		bot_enum[isBot][id] = 1
		
		bot_enum[count]++
	}
}

public client_disconnect(id)
{
	if(bot_enum[isBot][id])
	{
		bot_enum[isBot][id] = 0
		
		bot_enum[count]--
	}
}

public logevent_round_start()
{
	if(bot_enum[count] < 1)
	{
		return
	}
	
	if(task_exists(666))
	{
		remove_task(666)
	}
	
	set_task(float(get_pcvar_num(mp_bot_freezetime)), "bot_task", 666)
	
	bot_action(1)
}

public bot_task()
{
	bot_action(0)
}

stock bot_action(y)
{
	switch(bot_enum[type]) 
	{
		case 1,2: set_cvar_num(bot_cvar[bot_enum[type]], y)
		default:
		{
			new bots[MAX_PLAYERS], maxbots
			
			get_players(bots, maxbots, "adh")
			
			for(new i, id; i < maxbots; i++)
			{
				id = bots[i]
				
				if(y)
					entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) | FL_FROZEN)
				else
					entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) & ~FL_FROZEN)
			}
		}
	}
}
