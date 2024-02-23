#include <amxmodx>

#define PLUGIN "autoResetStats"
#define VERSION "1.2a"
#define AUTHOR "mlibre"

new const cvar_csx[] = "csstats_reset"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
}

public plugin_cfg()
{
	if(cvar_exists(cvar_csx))
	{
		autoResetStats()
	}
	else
	{
		server_print("[%s] The csx module is not loaded!", PLUGIN)
	}
}

autoResetStats()
{
	set_cvar_num(cvar_csx, 0)
	
	server_print("[%s] Checking day!", PLUGIN)
	
	new getDay[3]; get_time("%d", getDay, charsmax(getDay))
	
	if(equal(getDay, "01")) //<-every first day of the month
	{
		if(chk(PLUGIN))
		{
			server_print("[%s] The statistics have already been reset this month!", PLUGIN)
			
			return
		}
		
		set_cvar_num(cvar_csx, 1)
		
		server_print("[%s] Statistics have been reset!", PLUGIN)
		
		new fp = fopen(PLUGIN, "w"); fclose(fp)
	}
	else
	{
		server_print("[%s] It's not time!", PLUGIN)
		
		if(chk(PLUGIN))
		{
			delete_file(PLUGIN)
		}
	}
}

stock chk(file[])
{
	if(file_exists(file))
	{
		return 1
	}
	
	return 0
}
