#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
#endif

#define ADMIN_FLAG_1 ADMIN_LEVEL_A // users.ini "m" -> admin_te1 - admin_ct1
#define ADMIN_FLAG_2 ADMIN_LEVEL_B // users.ini "n" -> admin_te2 - admin_ct2

new g_bAdmin[33]

new const g_models[][] = 
{ 
	// cstrike/models/player/admin_te1/admin_te1.mdl
	"admin_te1", "admin_ct1", "admin_te2", "admin_ct2"
}
public plugin_precache() 
{
	register_plugin("Admin Model", "1.4b", "whitemike & mlibre")
	
	for(new i, fgm[256];i < sizeof g_models;i++) 
	{
		formatex(fgm, charsmax(fgm), "models/player/%s/%s.mdl", g_models[i], g_models[i])
		
		if(file_exists(fgm)) 
		{
			precache_model(fgm)
		} 
		else {
			#if AMXX_VERSION_NUM <= 182
			formatex(fgm, charsmax(fgm), "Falta: ^"%s^"", fgm)
			
			set_fail_state(fgm)
			#else
			set_fail_state("Falta: ^"%s^"", fgm)
			#endif
		}
	}
	
	#if AMXX_VERSION_NUM < 183
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", true)
	#else
	RegisterHamPlayer(Ham_Spawn, "Ham_SpawnPlayer_Post", true)
	#endif
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
		
		switch(g_bAdmin[id]) 
		{
			case 1: 
			{
				switch(Team) 
				{
					case CS_TEAM_T: cs_set_user_model(id, g_models[0])
					case CS_TEAM_CT: cs_set_user_model(id, g_models[1])
				}
			}
			case 2: 
			{
				switch(Team) 
				{
					case CS_TEAM_T: cs_set_user_model(id, g_models[2])
					case CS_TEAM_CT: cs_set_user_model(id, g_models[3])
				}
			}
		}
	}
} 
