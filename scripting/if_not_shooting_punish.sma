#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "If not shooting gun/Punish"
#define VERSION "1.4a"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
#else
	#define MAX_PLAYERS 32
	#define MAX_IP_LENGTH 16
	#define MAX_AUTHID_LENGTH 64
	#define MAX_RESOURCE_PATH_LENGTH 64
#endif

/*
Description:

	This plugin punishes everyone who does not make a shot in the game after a certain time elapsed.

Credits:

	Copper - idea
	Brad - has_flag
	totopizza - formatex, clamp
	meTaLiCroSS - for cvars
	Arkshine - Ham_TakeDamage
	ConnorMcLeod - NOSHOT_BITSUM

Changelog:

	v1.4a
	-added client_disconnected preprocessor in case AMXX is a version greater than 182

	v1.4 / views 3
	-two stocks were created to obtain the number of players per team and/or alive
	-adjusted get_players in client_disconnect and amx_omit_punish
	-replaced get_user_team with is_user_alive in Ham_SpawnPlayer_Post
	-added verification in Ham_SpawnPlayer_Post to start chk if there are enough players
	
	v1.3 / views 6
	-the code was decompressed and/or simplified a little to be more readable and clean.
	-reorganized cvars
	-amx_time_no_shoot changed from 90 to 60 seconds
	-added Ham_Spawn to keep track of the check loop based on active players
	-an ID was added to the loop to identify it and delete it later when it is not required
	-replaced FM_CmdStart_Pre (too many calls) with Ham_Weapon_PrimaryAttack_Post & Secondary (knife only)
	-now with <ham_weapom...> we see if the gun fires and if runs out of bullets
	-added client_disconnect (_post) to verify teams and subsequently stop loop
	-small adjustments in natives, parameters, conditions and operators
	-added default constants > 182
	-removed the flag that filtered bots in get_players
	-get_playersnum() was removed since get_players returns its value
	-some variables were renamed
	-some variables became static and others stopped being global
	-g_bImmunity was removed, failing which has_flag takes its place
	-replaced client_connect with putinserver
	
	v1.2 / views 20k481
	-Added cvar amx_enemy_attack to punish if it does not attack the enemy Ham_TakeDamage
	-Added mp_friendlyfire check in case of being in 1 the friend attack takes it as enemy
	-Added for cvars in plugin_init
	-Replaced some else if a else
	-Removed all conditions of automatic reset of cvars, it is considered unnecessary server_cmd (fix clamp)
	-Removed cvar amx_warning_lang, amx_warning_msg, amx_kick_msg, amx_ban_msg, amx_c4_attack, amx_grenade_attack
	-Removed g_bImmunity in fw_CmdStart
	
	v1.1b / views 41
	-Added cvar amx_num_players to specify the number of players (TE/CT) if the amx_omit_punish is set to 1
	example: amx_num_players "17 9" = 17 terrorists and 9 counter-terrorists
	(always leave a space between the two numbers and must be in quotes)
	-Replaced some conditions cvars to clamp
	-Moved register_dictionary to plugin_cfg more check file existence lang
	-Removed some unnecessary FORMATEX and duplicate lines
	
	v1.1a / views 31
	-Replaced value cvar amx_warning_lang <1/2> to <0/1>

	v1.1 / views 2
	-Added identify cvars
	-Added cvar amx_warning_lang, to activate lang support or use the cvars msg
	-Added conditions if not properly set the cvar, to auto reset to a correct value
	-Removed idOfTask, remove_task
	-Replaced several formatex to use only one
	-Cvar bImmunity now is global

	v1.0.2 / views 10
	-Added cvar amx_omit_punish

	v1.0.1 / views 4
	-Removed client_disconnect, hamsandwich
	-Replaced fakemeta_util to fakemeta

	v1.0 / views 8
	-Release 07(July)-17-2k16
	
Lang support: (if_not_shooting_punish.txt)	

	[en]
	amx_punish_type_1 = In %d seconds to be kicked by not
	amx_punish_type_2 = In %d seconds to be banned by not
	amx_punish_type_3 = In %d seconds to be killed by not
	amx_punish_type_4 = In %d seconds to be slapped by not
	
	amx_punish_type_a = shoot the gun.
	amx_punish_type_b = attack the enemy.
	
	amx_kick_msg = Kicked for not
	
	amx_ban_msg_1 = Banned permanent Reason: not
	amx_ban_msg_2 = Banned by %d minutes Reason: not
	
	[es]
	amx_punish_type_1 = En %d segundos seras kickeado por no
	amx_punish_type_2 = En %d segundos seras baneado por no
	amx_punish_type_3 = En %d segundos seras asesinado por no
	amx_punish_type_4 = En %d segundos seras abofeteado por no
	
	amx_punish_type_a = disparar el arma.
	amx_punish_type_b = atacar al enemigo.
	
	amx_kick_msg = Kickeado por no
	
	amx_ban_msg_1 = Baneado permanente Razon: no
	amx_ban_msg_2 = Baneado por %d minutos Razon: no

Support: (If you find an bug or can optimize the code, all suggestions are welcome.)

	-https://forums.alliedmods.net/showthread.php?t=285303
	-https://amxmodx-es.com/Thread-Si-no-dispara-el-arma-Castigar-v1-2
*/

enum _:cvars_name 
{
	amx_time_no_shoot, 
	amx_warning_time, 
	amx_warning_type, 
	amx_punish_type, 
	amx_ban_time, 
	amx_slap_dmg, 
	amx_knife_attack, 
	amx_immunity_flags, 
	amx_omit_punish, 
	amx_num_players,
	amx_enemy_attack
}

new const g_cvars[][][] = 
{
	{ "amx_time_no_shoot", 		"60" }, // seconds left
	{ "amx_warning_time", 		"15" }, // seconds remaining to see the warning
	{ "amx_warning_type", 		"5" }, 	// 0 = none / 1 = notify / 2 = console / 3 = chat / 4 = center / 5 = hud
	{ "amx_punish_type", 		"4" }, 	// 1 = kick / 2 = ban / 3 = slay / 4 = slap
	{ "amx_ban_time", 		"30" }, // 0 = permanent
	{ "amx_slap_dmg", 		"10" }, // slap damage
	{ "amx_knife_attack", 		"1" }, 	// 0 = off / 1 = on (restart seconds left)
	{ "amx_immunity_flags", 	"ab" }, // users.ini (a - immunity / b - reservation...)
	{ "amx_omit_punish", 		"1" },  // 0 = off / 1 = on (omit punishment , if there is X amount of enemies specified in amx_num_players) 
	{ "amx_num_players", 		"1 1" }, /* specify the number of players (TE/CT) if the amx_omit_punish is set to 1
						example: amx_num_players "17 9" = 17 terrorists and 9 counter-terrorists
						(always leave a space between the two numbers and must be in quotes) */
	{ "amx_enemy_attack", 		"0" } 	// punish if you do not attack the enemy
}

new g_Cvars[cvars_name], g_count[MAX_PLAYERS + 1], g_friendlyfire, bool:g_started

const id_task = 666

// offsets
#define XO_WEAPON 4
#define m_pPlayer 41
#define m_iId 43
#define m_iClientClip 52

enum
{
	TERRORIST = 1,
	CT
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("nsgp_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	for(new i; i < cvars_name; i++)
	{
		g_Cvars[i] = register_cvar(g_cvars[i][0], g_cvars[i][1])
	}
	
	#if AMXX_VERSION_NUM < 183
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", true)
	#else
	RegisterHamPlayer(Ham_Spawn, "Ham_SpawnPlayer_Post", true)
	#endif
	
	new NOSHOT_BITSUM = (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE)
	
	for(new i = CSW_P228, weapon_name[20]; i <= CSW_P90; i++)
	{
		if( ~NOSHOT_BITSUM & 1<<i && get_weaponname(i, weapon_name, charsmax(weapon_name)) )
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "Ham_Weapon_PrimaryAttack_Post", true)
		}
	}
	
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Weapon_SecondaryAttack_Post", true)
	
	RegisterHam(Ham_TakeDamage, "player", "Ham_TakeDamage_Pre")
}

public plugin_cfg() 
{
	g_friendlyfire = get_cvar_pointer("mp_friendlyfire")
	
	new dd[MAX_RESOURCE_PATH_LENGTH / 2], rt[MAX_RESOURCE_PATH_LENGTH]; get_datadir(dd, charsmax(dd))
	
	formatex(rt, charsmax(rt), "%s/lang/if_not_shooting_punish.txt", dd)
	
	if( !file_exists(rt) ) 
	{
		new file = fopen(rt, "w")
		
		fputs(file, "[en]^n")
		fputs(file, "amx_punish_type_1 = In %d seconds to be kicked by not^n")
		fputs(file, "amx_punish_type_2 = In %d seconds to be banned by not^n")
		fputs(file, "amx_punish_type_3 = In %d seconds to be killed by not^n")
		fputs(file, "amx_punish_type_4 = In %d seconds to be slapped by not^n^n")
		fputs(file, "amx_punish_type_a = shoot the gun.^n")
		fputs(file, "amx_punish_type_b = attack the enemy.^n^n")
		fputs(file, "amx_kick_msg = Kicked for not^n^n")
		fputs(file, "amx_ban_msg_1 = Banned permanent Reason: not^n")
		fputs(file, "amx_ban_msg_2 = Banned by %d minutes Reason: not^n^n")
		fputs(file, "[es]^n")
		fputs(file, "amx_punish_type_1 = En %d segundos seras kickeado por no^n")
		fputs(file, "amx_punish_type_2 = En %d segundos seras baneado por no^n")
		fputs(file, "amx_punish_type_3 = En %d segundos seras asesinado por no^n")
		fputs(file, "amx_punish_type_4 = En %d segundos seras abofeteado por no^n^n")
		fputs(file, "amx_punish_type_a = disparar el arma.^n")
		fputs(file, "amx_punish_type_b = atacar al enemigo.^n^n")
		fputs(file, "amx_kick_msg = Kickeado por no^n^n")
		fputs(file, "amx_ban_msg_1 = Baneado permanente Razon: no^n")
		fputs(file, "amx_ban_msg_2 = Baneado por %d minutos Razon: no")
		
		fclose(file)
	}
	
	register_dictionary("if_not_shooting_punish.txt")
}

public Ham_SpawnPlayer_Post(id)
{
	if( !g_started && is_user_alive(id) )
	{
		if(getPlayersNum(TERRORIST) && getPlayersNum(CT) )
		{
			set_task(1.0, "chk_no_shoot", id_task, .flags="b")
				
			g_started = true
		}
	}
}

public client_disconnect(id)
{
	if( !g_started )
		return
	
	set_task(0.1, "client_disconnect_post")
}
	
public client_disconnect_post()
{
	if( !g_started )
		return
		
	if( !getPlayersNum(TERRORIST) || !getPlayersNum(CT) )
	{
		#if AMXX_VERSION_NUM > 182
		remove_task(id_task)
		#else
		if(task_exists(id_task))
		{
			remove_task(id_task)
		}
		#endif
		
		g_started = false
	}
}

public chk_no_shoot() 
{
	static players[MAX_PLAYERS]
	
	new playerCnt; get_players(players, playerCnt, "ah")
	
	if( !playerCnt )
		return
	
	if(get_pcvar_num(g_Cvars[amx_omit_punish])) 
	{
		new np[6], arg[3][3]; get_pcvar_string(g_Cvars[amx_num_players], np, charsmax(np))
		
		parse(np, arg[0], charsmax(arg[]), arg[1], charsmax(arg[]))
		
		if(getPlayersNumAlive(TERRORIST) == str_to_num(arg[0]) 
		&& getPlayersNumAlive(CT) == str_to_num(arg[1]))
			return
	}
	
	static sImmunity[MAX_PLAYERS]
	
	for(new i, id; i < playerCnt; i++)
	{
		id = players[i]
		
		get_pcvar_string(g_Cvars[amx_immunity_flags], sImmunity, charsmax(sImmunity))
		
		if( ~has_flag(id, sImmunity) ) 
		{
			new msg[MAX_RESOURCE_PATH_LENGTH / 2]
			
			if(g_count[id] != 0 && g_count[id] <= get_pcvar_num(g_Cvars[amx_warning_time])) 
			{
				switch(clamp(get_pcvar_num(g_Cvars[amx_punish_type]), 1, 4)) 
				{
					case 1: formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_1", g_count[id], id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					case 2: formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_2", g_count[id], id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					case 3: formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_3", g_count[id], id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					case 4: formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_4", g_count[id], id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
				}
				
				switch(clamp(get_pcvar_num(g_Cvars[amx_warning_type]), 0, 5)) 
				{
					case 1: client_print(id, print_notify, "%s", msg)
					case 2: client_print(id, print_console, "%s", msg)
					case 3: client_print(id, print_chat, "%s", msg)
					case 4: client_print(id, print_center, "%s", msg)
					case 5: 
					{
						set_hudmessage(255, 85, 0, -1.0, 0.85, 0, 6.0, 1.0)
						show_hudmessage(id, "%s", msg)
					}
				}
			}
			
			if(g_count[id] == 0) 
			{
				switch(clamp(get_pcvar_num(g_Cvars[amx_punish_type]), 1, 4)) 
				{
					case 1: server_cmd("kick #%d ^"%L %L^"", get_user_userid(id), id, "amx_kick_msg", id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					case 2: 
					{
						new ip[MAX_IP_LENGTH], authid[MAX_AUTHID_LENGTH]
						
						get_user_ip(id, ip, charsmax(ip), 1)
						
						get_user_authid(id, authid, charsmax(authid))
						
						if(get_pcvar_num(g_Cvars[amx_ban_time]) < 1) 
						{
							formatex(msg, charsmax(msg), "%L %L", id, "amx_ban_msg_1", id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
						} 
						else {
							formatex(msg, charsmax(msg), "%L %L", id, "amx_ban_msg_2", get_pcvar_num(g_Cvars[amx_ban_time]), id, get_pcvar_num(g_Cvars[amx_enemy_attack]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
						}
						
						server_cmd("kick #%d ^"%s^";wait;banid %d %s;writeid;wait;addip %d %s;wait;writeip", get_user_userid(id), msg, get_pcvar_num(g_Cvars[amx_ban_time]), authid, get_pcvar_num(g_Cvars[amx_ban_time]), ip)
					}
					case 3: 
					{
						user_kill(id)
						
						g_count[id] = get_pcvar_num(g_Cvars[amx_warning_time])
					}
					case 4: 
					{
						user_slap(id, get_pcvar_num(g_Cvars[amx_slap_dmg]))
						
						g_count[id] = get_pcvar_num(g_Cvars[amx_warning_time])
					}
				}
			}
			
			g_count[id]--
		}
	}
}

public Ham_Weapon_PrimaryAttack_Post(iEnt)
{
	if(pev_valid(iEnt) && !get_pcvar_num(g_Cvars[amx_enemy_attack])) 
	{
		//no bullets
		if( !get_pdata_int(iEnt, m_iClientClip, XO_WEAPON) )
			return HAM_IGNORED
			
		if(get_pdata_int(iEnt, m_iId, XO_WEAPON) == CSW_KNIFE && !get_pcvar_num(g_Cvars[amx_knife_attack]))
			return HAM_IGNORED
			
		g_count[get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)] = get_pcvar_num(g_Cvars[amx_time_no_shoot])
	}
	
	return HAM_IGNORED
}

public Ham_Weapon_SecondaryAttack_Post(iEnt)
{
	if(pev_valid(iEnt))
	{
		g_count[get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)] = get_pcvar_num(g_Cvars[amx_time_no_shoot])
	}
}

public Ham_TakeDamage_Pre(victim, inflictor, attacker, Float:damage, damagebits) 
{
	if(get_pcvar_num(g_Cvars[amx_enemy_attack])) 
	{
		if(get_user_team(victim) != get_user_team(attacker)) 
		{
			g_count[attacker] = get_pcvar_num(g_Cvars[amx_time_no_shoot])
		}
		else if(get_pcvar_num(g_friendlyfire)) 
		{
			g_count[attacker] = get_pcvar_num(g_Cvars[amx_time_no_shoot])
		}
	}
}

public client_putinserver(id)
{
	g_count[id] = get_pcvar_num(g_Cvars[amx_time_no_shoot])
}

stock getPlayersNum(x)
{
	new players[MAX_PLAYERS], num
    
	get_players(players, num, "eh", x == 1 ? "TERRORIST" : "CT")
    
	return num
}

stock getPlayersNumAlive(x)
{
	new players[MAX_PLAYERS], num
    
	get_players(players, num, "aeh", x == 1 ? "TERRORIST" : "CT")
    
	return num
}
