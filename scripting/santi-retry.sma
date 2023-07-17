//#define RUN_CMD    //enable to run command X on spawn

#include <amxmodx>

#if defined RUN_CMD
#include <hamsandwich>

new is_user_retry[33]
#endif

#define PLUGIN "s!mple anti-retry"
#define VERSION "2.0b"
#define AUTHOR "mlibre"

new Trie:g_Id

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    g_Id = TrieCreate()
    
    #if defined RUN_CMD
    RegisterHam(Ham_Spawn, "player", "Ham_SpawnPlayer_Post", 1)
    #endif
}

public plugin_end() TrieDestroy(g_Id)

public client_putinserver(id)
{
    if(get_user_flags(id) & ADMIN_MENU || is_user_bot(id) || is_user_hltv(id))
        return
    
    static authid[32]; get_user_authid(id, authid, charsmax(authid))
    
    if( !TrieKeyExists(g_Id, authid) )
    {
        TrieSetCell(g_Id, authid, 1)
    }
    else {
        #if !defined RUN_CMD
        server_cmd("kick #%d ^"have you reconnected... wait for the map change!^"", get_user_userid(id))
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
