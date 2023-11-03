//#define RUN_CMD    //enable to run command X on spawn

#include <amxmodx>

#if defined RUN_CMD
#include <hamsandwich>

new is_user_retry[33]
#else
new g_pWait
#endif

#define PLUGIN "s!mple anti-retry"
#define VERSION "3.0"
#define AUTHOR "mlibre"

new Trie:g_Id, g_pImmunity

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_Id = TrieCreate()
	
	g_pImmunity = register_cvar("antiretry_immunity", "0") //<-admin flag "u" omitted
	
	#if !defined RUN_CMD
	g_pWait = register_cvar("antiretry_wait", "60") //<-seconds waiting to reconnect...
	#else
	RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", 1)
	#endif
}

public plugin_end() TrieDestroy(g_Id)

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return
	
	if(get_pcvar_num(g_pImmunity) && get_user_flags(id) & ADMIN_MENU)
		return
	
	new authid[32]; get_user_authid(id, authid, charsmax(authid))
	
	#if !defined RUN_CMD
	static iTimestamp; iTimestamp = get_systime()
	#endif
	
	if( !TrieKeyExists(g_Id, authid) )
	{
		#if !defined RUN_CMD
		TrieSetCell(g_Id, authid, iTimestamp + get_pcvar_num(g_pWait))
		#else
		TrieSetCell(g_Id, authid, 1)
		#endif
	}
	else 
	{
		#if !defined RUN_CMD
		new get_user_wait
		
		TrieGetCell(g_Id, authid, get_user_wait)
		
		if(get_user_wait > iTimestamp)
		{
			server_cmd("kick #%d ^"wait %d segs for reconnect!^"", get_user_userid(id), get_user_wait - iTimestamp)
			
			return
		}
		else
		{
			TrieDeleteKey(g_Id, authid)
			
			TrieSetCell(g_Id, authid, iTimestamp + get_pcvar_num(g_pWait))
		}
		#else
		is_user_retry[id] = 1
		#endif
	}
}

#if defined RUN_CMD
public Ham_SpawnPlayer_Post(const id) 
{
	if( !is_user_alive(id) ) 
		return HAM_IGNORED
	
	if(is_user_retry[id])
	{
		server_cmd("amx_infect #%d", get_user_userid(id))
		
		is_user_retry[id] = 0
	}
	
	return HAM_IGNORED
}
#endif 
