#include <amxmodx>

#define PLUGIN "msg_connect"
#define VERSION "1.1"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM < 183
	#define MAX_PLAYERS 32
#endif

enum
{
	preConnect = 1,
	postConnect
}

new const g_message[][] =
{
	//	colors:
	//
	//	!g	=Yellow
	//	!t	=Team (blue"CT"/red"TE")
	//	!g	=Green
	
	"!g[AMXX]",		//tag
	"!yTrying to connect",	//pre-connect
	"!yConnected",		//post-connect
	"!g"			//color Nick
}

new const g_sound[] = "misc/talk.wav"

new bool:isWav

public plugin_precache() 
{
	if(g_sound[strlen(g_sound) - 4] == '.' 
	&& g_sound[strlen(g_sound) - 3] == 'w'
	&& g_sound[strlen(g_sound) - 2] == 'a'
	&& g_sound[strlen(g_sound) - 1] == 'v')
	{
		isWav = true
	}
	
	precache_sound(g_sound)
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
}

public client_connect(id)
{
	send_msg(id, preConnect)
}

public client_putinserver(id)
{
	send_msg(id, postConnect)
}

stock send_msg(id, x)
{
	new nick[MAX_PLAYERS]; get_user_name(id, nick, charsmax(nick))
	
	switch(x)
	{
		case preConnect:
		{
#if AMXX_VERSION_NUM > 182
			client_print_color(0, print_team_default, "%s %s%s %s", g_message[0], g_message[1], g_message[3], nick)
#else
			client_print_color(0, "%s %s%s %s", g_message[0], g_message[1], g_message[3], nick)
#endif
		}
		case postConnect:
		{
#if AMXX_VERSION_NUM > 182
			client_print_color(0, print_team_default, "%s %s%s %s", g_message[0], g_message[2], g_message[3], nick)
#else
			client_print_color(0, "%s %s%s %s", g_message[0], g_message[2], g_message[3], nick)
#endif
			client_cmd(0, "%s ^"%s^"", isWav ? "spk" : "mp3 play", g_sound)
		}
	}
}

#if AMXX_VERSION_NUM < 183
public client_print_color(id, const input[], any:...) 
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
		
	replace_all(szMsg, charsmax(szMsg), "!y", "^1")
	replace_all(szMsg, charsmax(szMsg), "!t", "^3")
	replace_all(szMsg, charsmax(szMsg), "!g", "^4")
	
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
		return players[i]
	}
	
	return -1
}
#endif
