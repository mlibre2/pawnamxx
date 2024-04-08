#include <amxmodx>

#define PLUGIN "amx_slayteam"
#define VERSION "1.0"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM < 183
	const MAX_PLAYERS = 32
	const MAX_NAME_LENGTH = 32
	const ADMIN_BAN_TEMP = (1<<21) /* flag "v" */
#endif

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	register_concmd(PLUGIN, "cmdSlay")
}

public cmdSlay(id) 
{
	if( ~get_user_flags(id) & ADMIN_BAN_TEMP )
	{
		console_print(id, "[%s] no tienes privilegios para usar este comando", PLUGIN)
		
		return PLUGIN_HANDLED
	}
	
	new arg[2], x, y, players[MAX_PLAYERS], playernum
	
	read_argv(1, arg, charsmax(arg))
	
	switch(arg[0])
	{
		case 't': x = 1
		case 'c': x = 2
	}
	
	if(x < 1 || x > 2)
	{
		console_print(id, "] ----------------------------------------------------")
		console_print(id, "] has ingresado un parametro invalido!^n]")
		console_print(id, "] especifica cual ^"team^" quieres matar...")
		console_print(id, "] ejemplo:^n]")
		console_print(id, "] Terrorists")
		console_print(id, "] %s ^"t^"^n]", PLUGIN)
		console_print(id, "] Counter-Terrorists")
		console_print(id, "] %s ^"c^"", PLUGIN)
		console_print(id, "] ----------------------------------------------------")
		
		return PLUGIN_HANDLED
	}
	
	get_players(players, playernum, "ae", x == 1 ? "TERRORIST" : "CT")
	
	for(new i, j; i < playernum; i++)
	{
		j = players[i]
		
		if(j == id)
		{
			//yo mismo -.-
			
			continue
		}
		
		user_kill(j, 0)
		
		y++
	}
	
	if( !y )
	{
		console_print(id, "[%s] no hay ^"%s^" vivos!", PLUGIN, x == 1 ? "TTs" : "CTs")
		
		return PLUGIN_HANDLED
	}
	
	new nick[MAX_NAME_LENGTH]; get_user_name(id, nick, charsmax(nick))
	
	client_print(0, print_chat, "[%s] ADMIN: %s mato a los %s", PLUGIN, nick, x == 1 ? "TTs" : "CTs")
	
	return PLUGIN_HANDLED
}
