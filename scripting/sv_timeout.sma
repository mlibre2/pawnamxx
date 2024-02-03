#include <amxmodx>

#define PLUGIN "fix overflow/datagram"
#define VERSION "1.x"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
#else
	#define MAX_PLAYERS 32
#endif

//#define TIMEOUT

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

//----------------------------------------------------------------------------

#if defined TIMEOUT
public plugin_cfg()
{
	set_task(5.0, "chkTimeOut")
}

public chkTimeOut()
{
	server_cmd("sv_timeout ^"10^";sv_timeout")
	
	server_exec()
}
#else

//----------------------------------------------------------------------------

enum _:x
{
	isBot,
	isHltv,
	taskk, 
	again,
	reChk
}

new g_Player[MAX_PLAYERS + 1][x]

const TASK_TEST = 124011

public client_putinserver(id)
{
	if(is_user_bot(id))
	{
		g_Player[id][isBot] = 1
	}
	else if(is_user_hltv(id))
	{
		g_Player[id][isHltv] = 1
	}
	else
	{
		set_task(30.0, "chkOnline", id + TASK_TEST, .flags="b")	//<-loop
	}
}

public client_disconnect(id)
{
	for(new i; i < sizeof g_Player[]; i++)
	{
		if(g_Player[id][isBot] || g_Player[id][isHltv])
		{
			g_Player[id][i] = 0
			
			break
		}
		
		if(g_Player[id][i])
		{
			g_Player[id][i] = 0
		}
	}
	
	if(task_exists(id + TASK_TEST))
		remove_task(id + TASK_TEST)
}

new const g_key[] = "&@"

public chkOnline(id)
{
	id -= TASK_TEST
	
	g_Player[id][again]++
	
	if(g_Player[id][again] == 1)	//->putinserver & loop!
	{
		client_cmd(id, g_key)
	}
	else if(g_Player[id][again] == 3)	//->client_command
	{
		g_Player[id][again] = 0
		
		if(g_Player[id][reChk] > 0)
		{
			g_Player[id][reChk] = 0
		}
	}
	else {
		new userid = get_user_userid(id)
		
		if(userid < 0)		//<-disconnect!?
		{
			remove_task(id + TASK_TEST)
			
			return
		}
		
		if(g_Player[id][reChk] >= 2)
		{
			server_cmd("kick #%d ^"%dffl%dne^"", userid, 
			g_Player[id][again], g_Player[id][reChk])
		}
		
		g_Player[id][again] = 0
		
		g_Player[id][reChk]++
	}
	
	if( !g_Player[id][taskk] )
	{
		g_Player[id][taskk] = 1
		
		change_task(id + TASK_TEST, 1.0)	//<-loop
	}
}

public client_command(id)
{
	if(id < 1 || id > 32 || g_Player[id][isBot] || g_Player[id][isHltv])
		return PLUGIN_CONTINUE
	
	new getCmd[3]; read_argv(0, getCmd, charsmax(getCmd))
	
	if(getCmd[strlen(getCmd) - 2] == g_key[0])
	{
		g_Player[id][again]++	//<- 2
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}
#endif
