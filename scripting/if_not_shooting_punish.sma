#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME "If not shooting gun/Punish"

/*
Description:

	This plugin punishes everyone who does not make a shot in the game after a certain time elapsed.

Credits:

	Copper - idea
	Brad - get_playersnum, has_flag
	Bugsy - IN_ATTACK
	totopizza - formatex, clamp
	meTaLiCroSS - for cvars
	Arkshine - Ham_TakeDamage

Changelog:

	v1.2
	-Added cvar amx_enemy_attack to punish if it does not attack the enemy Ham_TakeDamage
	-Added mp_friendlyfire check in case of being in 1 the friend attack takes it as enemy
	-Added for cvars in plugin_init
	-Replaced some else if a else
	-Removed all conditions of automatic reset of cvars, it is considered unnecessary server_cmd (fix clamp)
	-Removido cvar amx_warning_lang, amx_warning_msg, amx_kick_msg, amx_ban_msg, amx_c4_attack, amx_grenade_attack
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
	-Release 17/Jul/2016
	
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

new const g_cvars[][][] = {
	/*0*/{ "amx_time_no_shoot", "90" }, // seconds left
	/*1*/{ "amx_warning_time", "15" }, // seconds remaining to see the warning
	/*2*/{ "amx_warning_type", "5" }, // 0 = none / 1 = console / 2 = console dev / 3 = chat / 4 = center / 5 = hud
	/*3*/{ "amx_punish_type", "4" }, // 1 = kick / 2 = ban / 3 = slay / 4 = slap
	/*4*/{ "amx_ban_time", "30" }, // 0 = permanent
	/*6*/{ "amx_slap_dmg", "10" }, // slap damage
	/*6*/{ "amx_knife_attack", "1" }, // 0 = off / 1 = on (restart seconds left)
	/*7*/{ "amx_immunity_flags", "abcdefghijklmnopqrst" }, 
	/*8*/{ "amx_omit_punish", "1" },  // 0 = off / 1 = on (omit punishment , if there is X amount of enemies specified in amx_num_players) 
	/*9*/{ "amx_num_players", "1 1" }, /* specify the number of players (TE/CT) if the amx_omit_punish is set to 1
					      example: amx_num_players "17 9" = 17 terrorists and 9 counter-terrorists
					      (always leave a space between the two numbers and must be in quotes) */
	/*10*/{ "amx_enemy_attack", "0" } // punish if you do not attack the enemy
}
enum _:cvars {
	/*0*/amx_time_no_shoot, 
	/*1*/amx_warning_time, 
	/*2*/amx_warning_type, 
	/*3*/amx_punish_type, 
	/*4*/amx_ban_time, 
	/*5*/amx_slap_dmg, 
	/*6*/amx_knife_attack, 
	/*7*/amx_immunity_flags, 
	/*8*/amx_omit_punish, 
	/*9*/amx_num_players,
	/*10*/amx_enemy_attack
}
new g_Cvars[ cvars ], count[33], msg[128], g_aImmunity[32], g_bImmunity, g_friendlyfire

public plugin_init() {
	static const V[] = "1.2"
	register_plugin(PLUGIN_NAME, V, "mlibre")
	register_cvar("nsgp_version",V,FCVAR_SERVER|FCVAR_SPONLY)
	
	for(new i = 0; i < cvars; i++) g_Cvars[i] = register_cvar(g_cvars[i][0], g_cvars[i][1]) 
	
	set_task(1.0, "check_no_shoot",_ ,_ ,_ ,"b")
	register_forward(FM_CmdStart, "fw_CmdStart")
	RegisterHam(Ham_TakeDamage, "player", "fwd_TakeDamage")
	g_friendlyfire = get_cvar_pointer("mp_friendlyfire")
}
public plugin_cfg() {
	new dd[256], rt[256]; get_datadir(dd, charsmax(dd))
	formatex(rt, charsmax(rt), "%s/lang/if_not_shooting_punish.txt", dd)
	if(!file_exists(rt)) {
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
public check_no_shoot() {
	if(get_pcvar_num(g_Cvars[ amx_omit_punish ]) > 0) {
		new tep[32], ctp[32], tenum, ctnum
		get_players(tep, tenum, "aceh", "TERRORIST"); get_players(ctp, ctnum, "aceh", "CT") 
		new np[6], arg[3][3]; get_pcvar_string(g_Cvars[ amx_num_players ], np, charsmax(np))
		parse(np, arg[0], charsmax(arg[]), arg[1], charsmax(arg[]))
		if (tenum <= str_to_num(arg[0]) || ctnum <= str_to_num(arg[1]) ) return;
	}
	new playerCnt = get_playersnum(), players[32], id; get_players(players, playerCnt, "ach")
	for (new playerIdx = 0; playerIdx < playerCnt; playerIdx++) {
		id = players[playerIdx]; 
		get_pcvar_string(g_Cvars[ amx_immunity_flags ], g_aImmunity, charsmax(g_aImmunity))
		g_bImmunity = has_flag(id, g_aImmunity)
		if (!g_bImmunity) {
			if(count[id] <= get_pcvar_num(g_Cvars[ amx_warning_time ]) ) {
				switch(clamp(get_pcvar_num(g_Cvars[ amx_punish_type ]), 1, 4) ) {
					case 1: {
						formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_1", count[id], id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					}
					case 2: {
						formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_2", count[id], id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					}
					case 3: {
						formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_3", count[id], id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					}
					case 4: {
						formatex(msg, charsmax(msg), "%L %L", id, "amx_punish_type_4", count[id], id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					}
				}
				switch(clamp(get_pcvar_num(g_Cvars[ amx_warning_type ]), 0, 5) ) {
					case 1: {
						client_print(id, 1, "%s", msg)
					}
					case 2: {
						client_print(id, 2, "%s", msg)
					}
					case 3: {
						client_print(id, 3, "%s", msg)
					}
					case 4: {
						client_print(id, 4, "%s", msg)
					}
					case 5: {
						set_hudmessage(255, 85, 0, -1.0, 0.85, 0, 6.0, 1.0)
						show_hudmessage(id, "%s", msg)
					}
				}
			}
			if(count[id] <= 0) {
				switch(clamp(get_pcvar_num(g_Cvars[ amx_punish_type ]), 1, 4) ) {
					case 1: {
						server_cmd("kick #%d ^"%L %L^"", get_user_userid(id), id, "amx_kick_msg", id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
					}
					case 2: {
						new ip[32], authid[32]
						get_user_ip(id, ip, charsmax(ip), 1)
						get_user_authid(id, authid, charsmax(authid))
						if(get_pcvar_num(g_Cvars[ amx_ban_time ]) < 1) {
							formatex(msg, charsmax(msg), "%L %L", id, "amx_ban_msg_1", id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
						} else {
							formatex(msg, charsmax(msg), "%L %L", id, "amx_ban_msg_2", get_pcvar_num(g_Cvars[ amx_ban_time ]), id, get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1 ? "amx_punish_type_a" : "amx_punish_type_b")
						}
						server_cmd("kick #%d ^"%s^";wait;banid %d %s;writeid;wait;addip %d %s;wait;writeip", get_user_userid(id), msg, get_pcvar_num(g_Cvars[ amx_ban_time ]), authid, get_pcvar_num(g_Cvars[ amx_ban_time ]), ip)
					}
					case 3: {
						user_kill(id), count[id] = get_pcvar_num(g_Cvars[ amx_warning_time ])
					}
					case 4: {
						user_slap(id, get_pcvar_num(g_Cvars[ amx_slap_dmg ]) ), count[id] = get_pcvar_num(g_Cvars[ amx_warning_time ])
					}
				}
			}
			count[id]--
		}
	}
}
public fw_CmdStart(id, uc_handle, seed) {
	if( !is_user_alive(id) ) 
		return FMRES_IGNORED

	if(get_pcvar_num(g_Cvars[ amx_enemy_attack ]) < 1) {
		if(get_pcvar_num(g_Cvars[ amx_knife_attack ]) < 1) {
			if(get_user_weapon(id) == CSW_KNIFE )
				return FMRES_IGNORED
		}
		if( ( get_uc(uc_handle, UC_Buttons) & IN_ATTACK ) 
		&& !( pev( id , pev_oldbuttons ) & IN_ATTACK ) ) {
			count[id] = get_pcvar_num(g_Cvars[ amx_time_no_shoot ])
		}
		if( ( get_uc(uc_handle, UC_Buttons) & IN_ATTACK2 ) 
		&& !( pev( id , pev_oldbuttons ) & IN_ATTACK2 ) ) {
			if(get_user_weapon(id) == CSW_KNIFE) {
				count[id] = get_pcvar_num(g_Cvars[ amx_time_no_shoot ])
			}
			return FMRES_IGNORED
		}
	}
	return FMRES_HANDLED
}
public fwd_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits) {
	if(get_pcvar_num(g_Cvars[ amx_enemy_attack ]) > 0) {
		if(get_user_team(victim) != get_user_team(attacker)) {
			count[attacker] = get_pcvar_num(g_Cvars[ amx_time_no_shoot ])
		}
		else if(get_pcvar_num(g_friendlyfire) > 0) {
			count[attacker] = get_pcvar_num(g_Cvars[ amx_time_no_shoot ])
		}
	}
}
public client_connect(id) count[id] = get_pcvar_num(g_Cvars[ amx_time_no_shoot ])
