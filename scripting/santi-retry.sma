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

new bool:is_user_retry[MAX_PLAYERS + 1]
#else
new g_pWait, g_pMsg
#endif

#define PLUGIN "s!mple anti-retry"
#define VERSION "3.6e"
#define AUTHOR "mlibre"

new Trie:g_Id, g_pImmunity, g_pType

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_Id = TrieCreate()
	
	g_pImmunity = register_cvar("antiretry_immunity", "0") //<-admin flag "u" omitted
	g_pType = register_cvar("antiretry_type", "1") //obtain->authid=1 / ip=2 or name=3
	
	#if !defined RUN_CMD
	g_pWait = register_cvar("antiretry_wait", "60") //<-seconds waiting to reconnect...
	g_pMsg = register_cvar("antiretry_msg", "wait %d segs for reconnect!") //<-msg show to the player when being kicked NOTE: "%d" return num segs
	#else
		#if AMXX_VERSION_NUM < 183
		RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", true)
		#else
		RegisterHamPlayer(Ham_Spawn, "Ham_SpawnPlayer_Post", true)
		#endif
	#endif
}

public plugin_end() TrieDestroy(g_Id)

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return
	
	if(get_pcvar_num(g_pImmunity) && get_user_flags(id) & ADMIN_MENU)
		return
	
	new authid[MAX_AUTHID_LENGTH], ip[MAX_IP_LENGTH], nick[MAX_NAME_LENGTH]
	
	switch(clamp(get_pcvar_num(g_pType), 1, 3))
	{
		case 1: 
		{
			get_user_authid(id, authid, charsmax(authid))
			
			if(containi(authid, "_ID") != -1) 
			{
				get_user_name(id, nick, charsmax(nick))
				
				log_amx("** WARNING! ^"%s^" there will be conflict, we change to get the name instead.", authid)
				
				set_pcvar_num(g_pType, 3)
			}
		}
		case 2: get_user_ip(id, ip, charsmax(ip), 1)
		case 3: get_user_name(id, nick, charsmax(nick))
	}
	
	#if !defined RUN_CMD
	static iTimestamp; iTimestamp = get_systime()
	#endif
	
	if( !TrieKeyExists(g_Id, get_pcvar_num(g_pType) == 1 ? authid : get_pcvar_num(g_pType) == 2 ? ip : encode(nick)) )
	{
		#if !defined RUN_CMD
		TrieSetCell(g_Id, get_pcvar_num(g_pType) == 1 ? authid : get_pcvar_num(g_pType) == 2 ? ip : encode(nick), iTimestamp + get_pcvar_num(g_pWait))
		#else
		TrieSetCell(g_Id, get_pcvar_num(g_pType) == 1 ? authid : get_pcvar_num(g_pType) == 2 ? ip : encode(nick), 1)
		#endif
	}
	else 
	{
		#if !defined RUN_CMD
		new get_user_wait
		
		TrieGetCell(g_Id, get_pcvar_num(g_pType) == 1 ? authid : get_pcvar_num(g_pType) == 2 ? ip : encode(nick), get_user_wait)
		
		if(get_user_wait > iTimestamp)
		{
			new setMsg[MAX_USER_INFO_LENGTH]; get_pcvar_string(g_pMsg, setMsg, charsmax(setMsg))
			
			formatex(setMsg, charsmax(setMsg), setMsg, get_user_wait - iTimestamp)
			
			server_cmd("kick #%d ^"%s^"", get_user_userid(id), setMsg)
		}
		else
		{
			TrieDeleteKey(g_Id, get_pcvar_num(g_pType) == 1 ? authid : get_pcvar_num(g_pType) == 2 ? ip : encode(nick))
			
			TrieSetCell(g_Id, get_pcvar_num(g_pType) == 1 ? authid : get_pcvar_num(g_pType) == 2 ? ip : encode(nick), iTimestamp + get_pcvar_num(g_pWait))
		}
		#else
		is_user_retry[id] = true
		#endif
	}
}

stock encode(const str[])
{
	new buffer[34]
	#if AMXX_VERSION_NUM < 183
	md5(str, buffer)
	#else
	hash_string(str, Hash_Md5, buffer, charsmax(buffer))
	#endif
	
	return buffer
}

#if defined RUN_CMD
public Ham_SpawnPlayer_Post(const id) 
{
	if(is_user_retry[id] && is_user_alive(id))
	{
		server_cmd("amx_infect #%d", get_user_userid(id))
		
		is_user_retry[id] = false
	}
}
#endif 
