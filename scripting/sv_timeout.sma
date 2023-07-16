#include <amxmodx>

#define PLUGIN "fix overflow/datagram"
#define VERSION "1.x"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM > 182
	#define client_disconnect client_disconnected
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

const TASK_TEST = 124011

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return
	
	set_task(30.0, "chkOnline", id + TASK_TEST, .flags="b")	//<-loop
}

enum _:x
{
	taskk, 
	again,
	rechk
}

new g_Player[33][x]

public client_disconnect(id)
{
	if(g_Player[id][taskk])
		g_Player[id][taskk] = 0
		
	if(g_Player[id][again])
		g_Player[id][again] = 0
		
	if(g_Player[id][rechk])
		g_Player[id][rechk] = 0
	
	if(task_exists(id + TASK_TEST))
		remove_task(id + TASK_TEST)
}

public chkOnline(id)
{
	id = id - TASK_TEST
	
	g_Player[id][again]++
	
	if(g_Player[id][again] == 1)	//->putinserver & loop!
	{
		client_cmd(id, "onl1ne")
	}
	else if(g_Player[id][again] == 3)	//->client_command
	{
		g_Player[id][again] = 0
		
		if(g_Player[id][rechk] > 0)
		{
			g_Player[id][rechk] = 0
		}
	}
	else {
		new userid = get_user_userid(id)
		
		if(userid < 0)		//<-disconnect!?
		{
			remove_task(id + TASK_TEST)
			
			return
		}
		
		if(g_Player[id][rechk] >= 2)
		{
			server_cmd("kick #%d ^"%dffl%dne^"", userid, 
			g_Player[id][again], g_Player[id][rechk])
		}
		
		g_Player[id][again] = 0
		
		g_Player[id][rechk]++
	}
	
	if( !g_Player[id][taskk] )
	{
		g_Player[id][taskk] = 1
		
		change_task(id + TASK_TEST, 1.0)	//<-loop
	}
}

public client_command(id)
{
	if(id < 1 || id > 32 || is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_HANDLED
	
	new getCmd[127]; read_argv(0, getCmd, charsmax(getCmd))
	
	if(strlen(getCmd) == 6 && equal(getCmd, "onl1ne"))
	{
		g_Player[id][again]++	//<- 2
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}
