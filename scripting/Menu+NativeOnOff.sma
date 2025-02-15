#include <amxmodx>
#include <hamsandwich>

#define PLUGIN "Menu+NativeOnOff"
#define VERSION "1.0"
#define AUTHOR "mlibre"

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
	opcion
}

new g_player[33][x]

const keys = (1<<0)|(1<<1)

new const menuName[] = "menuActivarArmas"

public plugin_natives()
{
	register_native("pluginMenuExterno_native", "pluginMenuLocal_native", 1)
}

public pluginMenuLocal_native(id)
{
	return g_player[id][opcion]
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
	g_player[id][opcion] =! g_player[id][opcion]
	
	client_print(id, 3, "[AMXX] Has %sACTIVADO las armas!", g_player[id][opcion] ? "" : "DES")
	client_print(id, 3, "[AMXX] para cambiar de parecer, escribe /models")
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
	g_player[id][opcion] = (key ? true : false)
	
	getCmdPlayer(id)
}
