//#define RUN_CMD    //enable to run command X on spawn

#include <amxmodx>

#if AMXX_VERSION_NUM < 183
	#define MAX_PLAYERS 32
	#define MAX_NAME_LENGTH 32
	#define MAX_IP_LENGTH 16
	#define MAX_AUTHID_LENGTH 64
	#define MAX_USER_INFO_LENGTH 256
#endif

#if defined RUN_CMD
#include <hamsandwich>

new is_user_retry[MAX_PLAYERS + 1]
#else
new g_pWait, g_pMsg, g_pType
#endif

#define PLUGIN "s!mple anti-retry"
#define VERSION "3.5"
#define AUTHOR "mlibre"

new Trie:g_Id, g_pImmunity

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_Id = TrieCreate()
	
	g_pImmunity = register_cvar("antiretry_immunity", "0") //<-admin flag "u" omitted
	
	#if !defined RUN_CMD
	g_pWait = register_cvar("antiretry_wait", "60") //<-seconds waiting to reconnect...
	g_pMsg = register_cvar("antiretry_msg", "wait %d segs for reconnect!") //<-msg show to the player when being kicked NOTE: "%d" return num segs
	g_pType = register_cvar("antiretry_type", "1") //obtain->authid=1 / ip=2 or name=3
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
	
	new authid[MAX_AUTHID_LENGTH], ip[MAX_IP_LENGTH], name[MAX_NAME_LENGTH], type
	
	switch(clamp(get_pcvar_num(g_pType), 1, 3))
	{
		case 1: 
		{
			get_user_authid(id, authid, charsmax(authid))
			
			if(containi(authid,"_ID") != -1) 
			{
				get_user_name(id, name, charsmax(name))
				
				log_amx("** WARNING! ^"%s^" there will be conflict, we change to get the name instead.", authid)
				
				type = 3
				
				set_pcvar_num(g_pType, type)
			}
			else
			{
				type = 1
			}
		}
		case 2: 
		{
			get_user_ip(id, ip, charsmax(ip), 1)
			
			type = 2
		}
		case 3: 
		{
			get_user_name(id, name, charsmax(name))
			
			type = 3
		}
	}
	
	#if !defined RUN_CMD
	static iTimestamp; iTimestamp = get_systime()
	#endif
	
	if( !TrieKeyExists(g_Id, type == 1 ? authid : type == 2 ? ip : name) )
	{
		#if !defined RUN_CMD
		TrieSetCell(g_Id, type == 1 ? authid : type == 2 ? ip : name, iTimestamp + get_pcvar_num(g_pWait))
		#else
		TrieSetCell(g_Id, type == 1 ? authid : type == 2 ? ip : name, 1)
		#endif
	}
	else 
	{
		#if !defined RUN_CMD
		new get_user_wait
		
		TrieGetCell(g_Id, type == 1 ? authid : type == 2 ? ip : name, get_user_wait)
		
		if(get_user_wait > iTimestamp)
		{
			new setMsg[MAX_USER_INFO_LENGTH]; get_pcvar_string(g_pMsg, setMsg, charsmax(setMsg))
			
			formatex(setMsg, charsmax(setMsg), setMsg, get_user_wait - iTimestamp)
			
			server_cmd("kick #%d ^"%s^"", get_user_userid(id), setMsg)
		}
		else
		{
			TrieDeleteKey(g_Id, type == 1 ? authid : type == 2 ? ip : name)
			
			TrieSetCell(g_Id, type == 1 ? authid : type == 2 ? ip : name, iTimestamp + get_pcvar_num(g_pWait))
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
