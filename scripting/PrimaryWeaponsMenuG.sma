#include <amxmodx>
#include <cstrike>
#include <fun>

#define PLUGIN "PrimaryWeaponsMenuG"
#define VERSION "1.2a"
#define AUTHOR "mlibre"

#if !defined MAX_PLAYERS
	#define MAX_PLAYERS 32
#endif

enum _:x
{
	wpn_name[10],	wpn_csw,	wpn_prices
}

new const primaryWeapons[][x] =
{
	{"M4A1",	CSW_M4A1,	3100},
	{"AK47",	CSW_AK47,	2500},
	{"AWP",		CSW_AWP,	4750},
	{"MP5 Navy",	CSW_MP5NAVY,	1500},
	{"XM1014",	CSW_XM1014,	3000},
	{"M3",		CSW_M3,		1700},
	{"Galil",	CSW_GALIL,	2000},
	{"FAMAS",	CSW_FAMAS,	2250},
	{"SG552",	CSW_SG552,	3500},
	{"AUG",		CSW_AUG,	3500},
	{"Scout",	CSW_SCOUT,	2750},
	{"G3SG1",	CSW_G3SG1,	5000},
	{"SG550", 	CSW_SG550,	4200},
	{"M249",	CSW_M249,	5750}
}

new g_menu[MAX_PLAYERS + 1], makecallback

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	makecallback = menu_makecallback("menu_callback")
	
	register_clcmd("say /guns", "show_mymenu")
	register_clcmd("drop", "menu_close")
}

public show_mymenu(id)
{
	new menu = menu_create("\yPrimary equip^n\dTo close the menu - press\y 'G'\R\d", "menu_handler")
	
	for(new i, fmtx[22]; i < sizeof primaryWeapons; i++)
	{
		formatex(fmtx, charsmax(fmtx), "%s\R\d$%d", primaryWeapons[i], primaryWeapons[i][wpn_prices])
		
		if(user_has_weapon(id, primaryWeapons[i][wpn_csw]))
		{
			menu_additem(menu, fmtx, _, _, makecallback)
		}
		else
		{
			if(cs_get_user_money(id) >= primaryWeapons[i][wpn_prices]) 
			{
				menu_additem(menu, fmtx, _)
			}
			else
			{
				menu_additem(menu, fmtx, _, _, makecallback)
			}
		}
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	menu_display(id, menu, 0)
	
	g_menu[id] = 1
}

public menu_callback(id, menu, item)
{
	return ITEM_DISABLED
}

public menu_handler(id, menu, item)
{
	if(item == MENU_EXIT) 
	{
		menu_remove(id, menu)
		
		return PLUGIN_HANDLED
	}
	
	if( !is_user_alive(id) )
	{
		menu_remove(id, menu)
		
#if AMXX_VERSION_NUM > 182
		client_print_color(id, print_team_default, "^4[AMXX]^1 You must be alive to select a weapon")
#else
		client_print_color(id, "^4[AMXX]^1 You must be alive to select a weapon")
#endif
		return PLUGIN_HANDLED
	}
	
	if(user_has_weapon(id, primaryWeapons[item][wpn_csw]))
	{
		menu_remove(id, menu)
		
#if AMXX_VERSION_NUM > 182
		client_print_color(id, print_team_default, "^4[AMXX]^1 You already own this weapon")
#else
		client_print_color(id, "^4[AMXX]^1 You already own this weapon")
#endif
		return PLUGIN_HANDLED
	}
	
	new money = cs_get_user_money(id)
	
	if(money >= primaryWeapons[item][wpn_prices]) 
	{
		new weapon_name[15]
		
		get_weaponname(primaryWeapons[item][wpn_csw], weapon_name, charsmax(weapon_name))
		
		give_item(id, weapon_name)
		
		cs_set_user_money(id, money - primaryWeapons[item][wpn_prices])
		
#if AMXX_VERSION_NUM > 182
		client_print_color(id, print_team_default, "^4[AMXX]^1 You have bought a^4 %s^1 by^4 $%d.", primaryWeapons[item][wpn_name], primaryWeapons[item][wpn_prices])
#else
		client_print_color(id, "^4[AMXX]^1 You have bought a^4 %s^1 by^4 $%d.", primaryWeapons[item][wpn_name], primaryWeapons[item][wpn_prices])
#endif
	} 
	else 
	{
#if AMXX_VERSION_NUM > 182
		client_print_color(id, print_team_default, "^4[AMXX]^1 You don't have enough money to buy a^4 %s.", primaryWeapons[item][wpn_name])
#else
		client_print_color(id, "^4[AMXX]^1 You don't have enough money to buy a^4 %s.", primaryWeapons[item][wpn_name])
#endif
	}
	
	menu_remove(id, menu)
	
	return PLUGIN_CONTINUE
}

stock menu_remove(id, menu)
{
	g_menu[id] = 0
		
	menu_destroy(menu)
}

public menu_close(id)
{
	if(g_menu[id])
	{
		menu_cancel(id)	//action MENU_EXIT
		
		show_menu(id, 0, "^n", 1)	//first we close the menu
		
		return PLUGIN_HANDLED	//drop blocked
	}
	
	return PLUGIN_CONTINUE	//drop normal
}

#if AMXX_VERSION_NUM < 183
stock client_print_color(id, const input[], any:...) 
{
	new szMsg[191], MSG_Type
	
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	if(id)
	{
		MSG_Type = MSG_ONE_UNRELIABLE
	} 
	else {
		id = isPlayer()
		
		MSG_Type = MSG_BROADCAST
	}
	
	static msgSayText
	
	if( !msgSayText ) 
		msgSayText = get_user_msgid("SayText")
	
	message_begin(MSG_Type, msgSayText, _, id)
	write_byte(id)	
	write_string(szMsg)
	message_end()
}

stock isPlayer()
{
	new players[MAX_PLAYERS], num; get_players(players, num, "ch")
	
	for(new i; i < num; i++)
	{
		if(is_user_connected(players[i]))
		{
			return players[i]
		}
	}
	
	return -1
}
#endif
