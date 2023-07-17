#include <amxmodx>

#define PLUGIN "Bans Reset"
#define VERSION "0.0.3"
#define AUTHOR "ConnorMcLeod & mlibre"

#define ADMIN_FLAG ADMIN_RCON

new g_pCvarBannedCfgFile, g_cvarActive, g_cvarMonth

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_concmd("amx_reset_bans", "ConCmd_ResetBans")        // removes all bans
    
    g_cvarActive = register_cvar("amx_reset_bans_active", "1")    // 1 = on / 0 = off
    g_cvarMonth = register_cvar("amx_reset_bans_month", "31/12")    // run every December 31
    
    g_pCvarBannedCfgFile = get_cvar_pointer("bannedcfgfile")
}

public plugin_cfg()
{
    if(get_pcvar_num(g_cvarActive))
    {
        new getString[11], getTime[11]
        
        get_pcvar_string(g_cvarMonth, getString, charsmax(getString))
        
        get_time("%d/%m", getTime, charsmax(getTime))
        
        if(equal(getTime, getString))
        {
            ConCmd_ResetBans(0)
        }
    }
}

public ConCmd_ResetBans(id)
{
    if( !(get_user_flags(id) & ADMIN_FLAG) ) 
    {
        engclient_print(id, engprint_console, "[AMXX] access denied (only admins)")
        
        return
    }
    
    static szBannedCfgFile[260]
    
    get_pcvar_string(g_pCvarBannedCfgFile, szBannedCfgFile, charsmax(szBannedCfgFile))
    
    server_cmd("writeid;writeip")
    server_exec()
    
    new buffer[64], szSteamIdOrIp[32], crap[2]
    
    new fp = fopen(szBannedCfgFile, "rt")
    
    if(fp)
    {
        while(fgets(fp, buffer, charsmax(buffer)))
        {
            trim(buffer)
            
            if(parse(buffer, crap, 1, crap, 1, szSteamIdOrIp, charsmax(szSteamIdOrIp)) == 3)
            {
                server_cmd("removeid %s", szSteamIdOrIp)
            }
        }
        server_exec()
            
        fclose(fp)
        
        fp = 0
            
        server_cmd("writeid")
        server_exec()
    }
    
    fp = fopen("listip.cfg", "rt")
    
    if(fp)
    {
        while(fgets(fp, buffer, charsmax(buffer)))
        {
            trim(buffer)
            
            if(parse(buffer, crap, 1, crap, 1, szSteamIdOrIp, charsmax(szSteamIdOrIp)) == 3)
            {
                server_cmd("removeip %s", szSteamIdOrIp)
            }
        }
        server_exec()
            
        fclose(fp)
        
        fp = 0
            
        server_cmd("writeip")
        server_exec()
    }
} 
