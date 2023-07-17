#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Bans Reset"
#define VERSION "0.0.1"

new g_pCvarBannedCfgFile

public plugin_init()
{
    register_plugin( PLUGIN, VERSION, "ConnorMcLeod" )

    register_concmd("amx_reset_bans", "ConCmd_ResetBans", ADMIN_RCON, "removes all bans")

    g_pCvarBannedCfgFile = get_cvar_pointer("bannedcfgfile")
}

public ConCmd_ResetBans(id , lvl, cid)
{
    if( !cmd_access(id, lvl, cid, 0) )
    {
        return PLUGIN_HANDLED
    }

    new szBannedCfgFile[260]
    get_pcvar_string(g_pCvarBannedCfgFile, szBannedCfgFile, charsmax(szBannedCfgFile))

    server_cmd("writeid")
    server_cmd("writeip")
    server_exec()

    new buffer[64], szSteamIdOrIp[32], crap[2]
    new fp = fopen(szBannedCfgFile, "rt")
    if( fp )
    {
        while( !feof(fp) )
        {
            fgets(fp, buffer, charsmax(buffer))
            trim(buffer)
            if( parse(buffer, crap, 1, crap, 1, szSteamIdOrIp, charsmax(szSteamIdOrIp)) == 3 )
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
    if( fp )
    {
        while( !feof(fp) )
        {
            fgets(fp, buffer, charsmax(buffer))
            trim(buffer)
            if( parse(buffer, crap, 1, crap, 1, szSteamIdOrIp, charsmax(szSteamIdOrIp)) == 3 )
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

    return PLUGIN_HANDLED
} 
