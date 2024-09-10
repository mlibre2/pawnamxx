#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#define PLUGIN "Admin Model"
#define VERSION "1.5"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
#else
	#define MAX_PLAYERS 32
#endif

#define ADMIN_FLAG_1 ADMIN_LEVEL_A // users.ini "m" -> admin_te1 - admin_ct1
#define ADMIN_FLAG_2 ADMIN_LEVEL_B // users.ini "n" -> admin_te2 - admin_ct2

new g_bAdmin[MAX_PLAYERS + 1]

new const g_mdl_te[][] =
{
	// cstrike/models/player/admin_te1/admin_te1.mdl
	//
	// ADMIN_FLAG_1		ADMIN_FLAG_2
	
	"admin_te1", 		"admin_te2"
}

new const g_mdl_ct[][] =
{
	// cstrike/models/player/admin_ct1/admin_ct1.mdl
	//
	// ADMIN_FLAG_1		ADMIN_FLAG_2
	
	"admin_ct1", 		"admin_ct2"
}

public plugin_precache() 
{
	new str[256]
	
	for(new i;i < sizeof g_mdl_te;i++) 
	{
		formatex(str, charsmax(str), "models/player/%s/%s.mdl", g_mdl_te[i], g_mdl_te[i])
		
		precache_model_x(str)
	}
	
	for(new i;i < sizeof g_mdl_ct;i++) 
	{
		formatex(str, charsmax(str), "models/player/%s/%s.mdl", g_mdl_ct[i], g_mdl_ct[i])
		
		precache_model_x(str)
	}
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	#if AMXX_VERSION_NUM < 183
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", true)
	#else
	RegisterHamPlayer(Ham_Spawn, "Ham_SpawnPlayer_Post", true)
	#endif
}

new g_random

public plugin_cfg()
{
	g_random = register_cvar("admin_model_random", "0") //0=disabled - 1=random selection
}

public client_putinserver(id)
{
	new getFlags = get_user_flags(id)
	
	g_bAdmin[id] = (getFlags & ADMIN_FLAG_1 ? 1 : getFlags & ADMIN_FLAG_2 ? 2 : 0)
}

public client_disconnect(id)
	g_bAdmin[id] = 0

public Ham_SpawnPlayer_Post(const id) 
{
	if(g_bAdmin[id] > 0 && is_user_alive(id)) 
	{
		new CsTeams:Team = cs_get_user_team(id)
		
		if(Team == CS_TEAM_T || Team == CS_TEAM_CT)
		{
			static selected[MAX_PLAYERS + 1]
			
			if(get_pcvar_num(g_random))
			{
				selected[id] = random_num(0, Team == CS_TEAM_T ? charsmax(g_mdl_te) : charsmax(g_mdl_ct))
			}
			else {
				switch(g_bAdmin[id]) 
				{
					case 1: 
					{
						if(selected[id] != 0)
						{
							selected[id] = 0
						}
					}
					case 2: 
					{
						if(selected[id] != 1)
						{
							selected[id] = 1
						}
					}
				}
			}
			
			cs_set_user_model(id, Team == CS_TEAM_T ? g_mdl_te[selected[id]] : g_mdl_ct[selected[id]])
		}
	}
}

stock precache_model_x(mdl[])
{
	if( !file_exists(mdl) ) 
	{
		precache_fail(mdl)
	}
	
	precache_model(mdl)
}

stock precache_fail(str[])
{
	#if AMXX_VERSION_NUM <= 182
	new sfs[64]; formatex(sfs, charsmax(sfs), "%s does not exist...", str)
	
	set_fail_state(sfs)
	#else
	set_fail_state("%s does not exist...", str)
	#endif
}
