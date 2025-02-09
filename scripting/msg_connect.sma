#include <amxmodx>

#define PLUGIN "msg_connect"
#define VERSION "1.3"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
#else
	#define MAX_PLAYERS 32
#endif

enum _:str
{
	tag,
	preConnect,
	postConnect,
	disConnect,
	color
}

new const g_message[str][] =
{
	//	colors:
	//
	//	^1	=Yellow
	//	^3	=Team (blue"CT"/red"TE")
	//	^4	=Green
	
	"^1[AMXX]",		//tag
	"Trying to connect",	//pre-connect
	"Connected",		//post-connect
	"Disconnected",		//disconnect
	"^4"			//color Nick
}

new const g_sound[] = "buttons/bell1.wav"

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

public client_disconnect(id)
{
	send_msg(id, disConnect)
}

stock send_msg(id, x)
{
	new nick[MAX_PLAYERS]; get_user_name(id, nick, charsmax(nick))
	
	switch(x)
	{
		case preConnect:
		{
			new ip[MAX_PLAYERS / 2]; get_user_ip(id, ip, charsmax(ip), 1)
			
#if AMXX_VERSION_NUM > 182
			client_print_color(0, print_team_default, "%s %s %s %s", g_message[tag], nick, ip, g_message[preConnect])
#else
			client_print_color(0, "%s %s %s %s", g_message[tag], nick, ip, g_message[preConnect])
#endif
		}
		case postConnect, disConnect:
		{
#if AMXX_VERSION_NUM > 182
			client_print_color(0, print_team_default, "%s%s %s", g_message[color], nick, x == postConnect ? g_message[postConnect] : g_message[disConnect])
#else
			client_print_color(0, "%s%s %s", g_message[color], nick, x == postConnect ? g_message[postConnect] : g_message[disConnect])
#endif
			if(x == postConnect)
				client_cmd(0, "%s ^"%s^"", isWav ? "spk" : "mp3 play", g_sound)
		}
	}
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
