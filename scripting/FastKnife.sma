#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <engine>

#define PLUGIN "Fast Knife"
#define VERSION "1.7"
#define AUTHOR "OciXCrom & mlibre"

#if !defined MAX_PLAYERS
const MAX_PLAYERS = 32
#endif

new g_pActive
new g_pLimit
new g_pSpeed
new g_pSprintDuration
new g_pShowSprintMessage
new g_pRespawn
new g_pSound

enum _:x 
{
	fspawn,
	run,
	limit,
	delay
}

new iPlayer[MAX_PLAYERS + 1][x]

const TASK_ID = 59141

// Add a new sound constant for the sprint end sound
new const SPRINT_END_SOUND[] = "fvox/fuzz.wav"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("CRXFastKnife", VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED)
	
	register_event("CurWeapon", "OnSelectKnife", "be", "1=1", "2=29")
	
	g_pActive = register_cvar("fastknife_active", "1")
	g_pLimit = register_cvar("fastknife_limit", "3")
	g_pSpeed = register_cvar("fastknife_speed", "150.0")
	g_pSprintDuration = register_cvar("sprint_duration", "30")
	g_pShowSprintMessage = register_cvar("fastknife_msg", "1")
	g_pRespawn = register_cvar("fastknife_respawn", "1")
	g_pSound = register_cvar("fastknife_sound", "1")
	
	RegisterHam(Ham_Player_ImpulseCommands, "player", "Ham_Player_ImpulseCmds")
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", 1)
	RegisterHam(Ham_Killed, "player", "Ham_KilledPlayer_Post", 1)
}

public plugin_precache()
{
	// Precache the sprint end sound
	precache_sound(SPRINT_END_SOUND)
}

public set_fastknife(id)
{
	if( !get_pcvar_num(g_pActive) )
	{
		client_print(id, print_chat, "%s: is disabled", PLUGIN)
		
		return
	}
	
	if(iPlayer[id][limit] >= get_pcvar_num(g_pLimit))
	{
		client_print(id, print_chat, "%s: you have reached your usage limit. %d maximum allowed.", PLUGIN, iPlayer[id][limit])
		
		return
	}
	
	static iTimestamp; iTimestamp = get_systime()
	
	if(iPlayer[id][delay] > iTimestamp)
	{
		if(iPlayer[id][run])
		{
			client_print(id, print_chat, "%s: you have %d seconds left", PLUGIN, iPlayer[id][delay] - iTimestamp)
		}
		else
		{
			client_print(id, print_chat, "%s: wait %d seconds for your next use!", PLUGIN, iPlayer[id][delay] - iTimestamp)
		}
		
		return
	}
	
	if( !is_user_alive(id) )
	{
		client_print(id, print_chat, "%s: you have to be alive to use this.", PLUGIN)
		
		return
	}
	
	iPlayer[id][run] = 1
	
	iPlayer[id][limit]++
	
	set_task(float(get_pcvar_num(g_pSprintDuration)), "EndFastKnife", id + TASK_ID)
		
	iPlayer[id][delay] = iTimestamp + get_pcvar_num(g_pSprintDuration)
	
	client_print(id, print_chat, "%s: is running! %d seconds remaining, used (%d of %d)", PLUGIN, iPlayer[id][delay] - iTimestamp, iPlayer[id][limit], get_pcvar_num(g_pLimit))
}
	
public OnSelectKnife(id)
{
	if(iPlayer[id][run] && iPlayer[id][limit])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_float(g_pSpeed))
	}
}

public EndFastKnife(id)
{
	id -= TASK_ID
	
	iPlayer[id][run] = 0
	
	if(is_user_alive(id))
	{
		reset_speed(id)
	}
	
	if(iPlayer[id][limit] < get_pcvar_num(g_pLimit))
	{
		iPlayer[id][delay] = get_systime() + get_pcvar_num(g_pSprintDuration)
	}
	
	if(get_pcvar_num(g_pSound))
	{
		client_cmd(id, "spk %s", SPRINT_END_SOUND)
	}
	
	client_print(id, print_chat, "%s: your fun is over! times used (%d of %d)", PLUGIN, iPlayer[id][limit], get_pcvar_num(g_pLimit))
}

public Ham_Player_ImpulseCmds(id)
{
	if(entity_get_int(id, EV_INT_impulse) == 201)	//<-key=T
	{
		set_fastknife(id)
	}
}

public Ham_SpawnPlayer_Post(id)
{
	if(iPlayer[id][fspawn] || !is_user_alive(id))
		return HAM_IGNORED
	
	if(get_pcvar_num(g_pActive) && get_pcvar_num(g_pShowSprintMessage))
	{
		iPlayer[id][fspawn] = 1
		
		client_print(id, print_chat, "%s: you can sprint with a knife in hand for %d seconds!", PLUGIN, get_pcvar_num(g_pSprintDuration))
		client_print(id, print_chat, "%s: activate it with the key ^"T^"", PLUGIN)
	}
	
	return HAM_IGNORED
}

public Ham_KilledPlayer_Post(id)
{
	if(iPlayer[id][run] && get_pcvar_num(g_pRespawn))
	{
		iPlayer[id][run] = 0
		
		remove_task(id + TASK_ID)
		
		reset_speed(id)
		
		client_print(id, print_chat, "%s: you have lost this ability!", PLUGIN)
	}
}

stock reset_speed(id)
{
	set_user_maxspeed(id, 250.0)
}
