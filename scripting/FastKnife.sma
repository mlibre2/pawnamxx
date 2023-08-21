#include <amxmodx>
#include <hamsandwich>
#include <fun>

#define PLUGIN "Fast Knife"
#define VERSION "1.5a"
#define AUTHOR "OciXCrom & mlibre"

new g_pActive
new g_pLimit
new g_pSpeed
new g_pSprintDuration
new g_pRespawn
new g_pShowSprintMessage

enum _:x 
{
	fspawn,
	run,
	limit,
	seconds
}

new iWaitNext[33][x]

const TASK_ID = 59141

new const g_cmd[] = "say /fk"

// Add a new sound constant for the sprint end sound
new const SPRINT_END_SOUND[] = "sound/breathe2.wav"

public plugin_precache()
{
	// Precache the sprint end sound
	precache_sound(SPRINT_END_SOUND)
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("CRXFastKnife", VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED)
	
	register_event("CurWeapon", "OnSelectKnife", "be", "1=1", "2=29")
	
	register_clcmd(g_cmd, "set_fastknife")
	
	g_pActive = register_cvar("fastknife_active", "1")
	g_pLimit = register_cvar("fastknife_limit", "3")
	g_pSpeed = register_cvar("fastknife_speed", "150.0")
	g_pSprintDuration = register_cvar("sprint_duration", "30")
	g_pRespawn = register_cvar("fastknife_respawn", "1")
	g_pShowSprintMessage = register_cvar("fastknife_msg", "1")
	
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", 1)
	RegisterHam(Ham_Killed, "player", "Ham_KilledPlayer_Post", 1)
}

public set_fastknife(id)
{
	if( !get_pcvar_num(g_pActive) )
	{
		client_print(id, print_chat, "%s: is disabled", PLUGIN)
		
		return
	}
	
	if(iWaitNext[id][limit] >= get_pcvar_num(g_pLimit))
	{
		client_print(id, print_chat, "%s: you have reached your usage limit. %d maximum allowed.", PLUGIN, iWaitNext[id][limit])
		
		return
	}
	
	static iTimestamp; iTimestamp = get_systime()
	
	if(iWaitNext[id][seconds] > iTimestamp)
	{
		if(iWaitNext[id][run])
		{
			client_print(id, print_chat, "%s: you have %d seconds left", PLUGIN, iWaitNext[id][seconds] - iTimestamp)
		}
		else
		{
			client_print(id, print_chat, "%s: wait %d seconds for your next use!", PLUGIN, iWaitNext[id][seconds] - iTimestamp)
		}
		
		return
	}
	
	if( !is_user_alive(id) )
	{
		client_print(id, print_chat, "%s: you have to be alive to use this.", PLUGIN)
		
		return
	}
	
	iWaitNext[id][run] = 1
	
	iWaitNext[id][limit]++
	
	if( !task_exists(id + TASK_ID) )
	{
		set_task(float(get_pcvar_num(g_pSprintDuration)), "EndFastKnife", id + TASK_ID)
	}
	
	iWaitNext[id][seconds] = iTimestamp + get_pcvar_num(g_pSprintDuration)
	
	client_print(id, print_chat, "%s: is running! %d seconds remaining, used (%d of %d)", PLUGIN, iWaitNext[id][seconds] - iTimestamp, iWaitNext[id][limit], get_pcvar_num(g_pLimit))
}
	
public OnSelectKnife(id)
{
	if(iWaitNext[id][run] && iWaitNext[id][limit])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_float(g_pSpeed))
	}
}

public EndFastKnife(id)
{
	id -= TASK_ID
	
	iWaitNext[id][run] = 0
	
	if(is_user_alive(id))
	{
		reset_speed(id)
	}
	
	if(iWaitNext[id][limit] < get_pcvar_num(g_pLimit))
	{
		iWaitNext[id][seconds] = get_systime() + get_pcvar_num(g_pSprintDuration)
	}
	
	// Play the sprint end sound
	client_cmd(id, "spk %s", SPRINT_END_SOUND)
	
	client_print(id, print_chat, "%s: your fun is over! times used (%d of %d)", PLUGIN, iWaitNext[id][limit], get_pcvar_num(g_pLimit))
}

public Ham_SpawnPlayer_Post(id)
{
	if( !is_user_alive(id) )
		return HAM_IGNORED
	
	if(get_pcvar_num(g_pActive) && get_pcvar_num(g_pShowSprintMessage) && !iWaitNext[id][fspawn])
	{
		iWaitNext[id][fspawn] = 1
		
		client_print(id, print_chat, "%s: you can sprint with a knife in hand for %d seconds!", PLUGIN, get_pcvar_num(g_pSprintDuration))
		client_print(id, print_chat, "%s: activate it with %s", PLUGIN, g_cmd)
	}
	
	return HAM_IGNORED
}

public Ham_KilledPlayer_Post(id)
{
	if(iWaitNext[id][run] && get_pcvar_num(g_pRespawn))
	{
		iWaitNext[id][run] = 0
		
		if(task_exists(id + TASK_ID))
		{
			remove_task(id + TASK_ID)
		}
		
		reset_speed(id)
		
		client_print(id, print_chat, "%s: you have lost this ability!", PLUGIN)
	}
}

stock reset_speed(id)
{
	set_user_maxspeed(id, 250.0)
}
