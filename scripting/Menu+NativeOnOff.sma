#include <amxmodx>
#include <hamsandwich>

#define PLUGIN "Menu+NativeOnOff"
#define VERSION "1.1"
#define AUTHOR "mlibre"

#if !defined MAX_PLAYERS
	#define MAX_PLAYERS 32
#endif

new const g_menu[][] = 
{ 
	//-----------------------------
	//
	// colors:
	//
	//	rojo:		\r
	//	amarillo:	\y
	//	blanco:		\w
	//	gris:		\d
	//
	// salto de linea:	^n
	//
	//-----------------------------
	
	"\r* \wNOMBRE DE LA COMUNIDAD^n",
	"\r* \yGrupo: \dfb.com/xxx^n",
	"\r* \wDeseas ver los modelos de \rADMIN \wy \rARMAS?^n^n",
	"\r* \yNota: \dEste menu solo saldra una vez^n^n",
	"\r1. \wSi^n",
	"\r2. \wNo"
}

enum _:x
{
	menu,
	active
}

new g_player[MAX_PLAYERS + 1][x]

const keys = (1<<0)|(1<<1)

new const menuName[] = "menuActivarArmas"

public plugin_natives()
{
	register_native("pluginMenuExterno_native", "pluginMenuLocal_native", 1)
}

public pluginMenuLocal_native(id)
{
	return g_player[id][active]
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	register_clcmd("say /models", "getCmdPlayer")
	
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", true)
	
	register_menucmd(register_menuid(menuName), keys, "actionMenu")
}

public getCmdPlayer(id) 
{
	g_player[id][active] =! g_player[id][active]
	
#if AMXX_VERSION_NUM > 182
	client_print_color(id, print_team_default, "^4[AMXX]^1 Has^3 %sACTIVADO^1 las armas!", g_player[id][active] ? "" : "DES")
	client_print_color(id, print_team_default, "^4[AMXX]^1 para cambiar de parecer, escribe^3 /models")
#else
	client_print_color(id, "^4[AMXX]^1 Has^3 %sACTIVADO^1 las armas!", g_player[id][active] ? "" : "DES")
	client_print_color(id, "^4[AMXX]^1 para cambiar de parecer, escribe^3 /models")
#endif
}

public Ham_SpawnPlayer_Post(id) 
{
	if( !g_player[id][menu] && is_user_alive(id) && !is_user_bot(id) )
	{
		g_player[id][menu] = true
		
		abrirMenu(id)
	}
}

public abrirMenu(id) 
{
	new fmtx[512]
	
	for(new i, len; i < sizeof g_menu; i++)
	{
		len += formatex(fmtx[len], charsmax(fmtx) - len, g_menu[i])
	}
	
	show_menu(id, keys, fmtx, -1, menuName)
}

public actionMenu(id, key) 
{
	g_player[id][active] = (key ? true : false)
	
	getCmdPlayer(id)
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
