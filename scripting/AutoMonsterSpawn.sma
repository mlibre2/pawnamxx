#include <amxmodx>
#include <engine>

#define PLUGIN "AutoMonsterSpawn" 
#define VERSION "1.0"
#define AUTHOR "mlibre"

new Array:monster_names

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	monster_names = ArrayCreate(15)
	
	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
}

public plugin_end() ArrayDestroy(monster_names)

public plugin_cfg()
{
	if( !cvar_exists("monster_spawn") )
	{
		monster_fail("monster module")
	}
	
	new cfg[] = "monster_precache.cfg"
	
	if(file_exists(cfg))
	{
		new file = fopen(cfg, "rt"), output[15], a
		
		if( !file )
		{
			monster_fail(cfg)
		}
		
		while(fgets(file, output, charsmax(output)))
		{
			trim(output)
			
			if( !output[0] 
			|| output[0] == ' ' 
			|| output[0] == '/' 
			|| output[0] == EOS 
			|| output[0] == ';' 
			)
			{
				continue
			}
			
			a++
			
			ArrayPushString(monster_names, output)
		}
		
		fclose(file)
		
		if( !a )
		{
			monster_fail("monster names")
		}
	}
	else
	{
		monster_fail(cfg)
	}
}

public logevent_round_start()
{
	new players[32], num; get_players(players, num, "ach")
	
	if( !num )
		return
	
	new rnd = random_num(0, ArraySize(monster_names)), selected_monster[15]
	
	ArrayGetString(monster_names, rnd, selected_monster, charsmax(selected_monster))
	
	set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0)
	show_hudmessage(0, ":: Monster Spawned ::^n%s", selected_monster)
	
	server_cmd("monster %s #%d", selected_monster, players[random(num)])
}

public logevent_round_end()
{
	set_task(1.0, "remove_monster")
}

public remove_monster()
{
	new func_monster[] = "func_wall", monster = find_ent_by_class(-1, func_monster)
	
	while(monster > 0)
	{
		if(entity_get_int(monster, EV_INT_flags) & FL_MONSTER)
		{
			entity_set_int(monster, EV_INT_flags, FL_KILLME)
			
			monster = find_ent_by_class(-1, func_monster)
		}
		else
		{
			monster = find_ent_by_class(monster, func_monster)
		}
	}
}

stock monster_fail(str[])
{
	#if AMXX_VERSION_NUM <= 182
	new sfs[64]; formatex(sfs, charsmax(sfs), "%s not loaded...", str)
	
	set_fail_state(sfs)
	#else
	set_fail_state("%s not loaded...", str)
	#endif
}
