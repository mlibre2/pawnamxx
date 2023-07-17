#include <amxmodx>
#include <amxmisc>

#define SELECTMAPS  4
#define charsof(%1) (sizeof(%1)-1)

new n_rounds, p_galileo, g_maxrounds, Array:g_mapName, g_mapNums, g_lastMap[32], g_nextName[SELECTMAPS], c

public plugin_init() {
    register_plugin("Count Round+Nextmap Chooser", AMXX_VERSION_STR, "AMXX Dev Team (edited mlibre)")
    
    p_galileo = register_cvar("amx_galileo","0")
    g_maxrounds = register_cvar("amx_maxrounds","20")
    
    register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0")
    register_event("TextMsg", "event_GameRestart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
    
    g_mapName=ArrayCreate(32)
    
    get_localinfo("lastMap", g_lastMap, charsmax(g_lastMap))
    set_localinfo("lastMap", "")
    
    new maps_ini_file[64]; get_configsdir(maps_ini_file, charsmax(maps_ini_file))
    
    formatex(maps_ini_file, charsmax(maps_ini_file), "%s/maps.ini", maps_ini_file)
    
    if (!file_exists(maps_ini_file)) 
        get_cvar_string("mapcyclefile", maps_ini_file, charsmax(maps_ini_file))
    
    loadSettings(maps_ini_file)
}
bool:isInMenu(id)
{
    for (new a = 0; a < c; ++a)
    {
        if (id == g_nextName[a])
            return true
    }    
    return false
}
public event_RoundStart()
{
    n_rounds++
    
    if( n_rounds >= get_pcvar_num(g_maxrounds) )
    {
        if( get_pcvar_num(p_galileo) )
        {
            set_cvar_num("gal_rtv_wait", -1), server_cmd("gal_startvote")
        }
        else {
            new map[128], a, dmax = (g_mapNums > SELECTMAPS) ? SELECTMAPS : g_mapNums, x
            
            for (c = 0; c < dmax; ++c)
            {
                a = random_num(0, g_mapNums - 1)
                
                while (isInMenu(a))
                    if (++a >= g_mapNums) a = 0
                
                g_nextName[c] = a
                
                x += formatex(map[x], charsmax(map), " %a", ArrayGetStringHandle(g_mapName, a) )
            }
            server_cmd("amx_votemap%s", map[0])
            
            client_cmd(0, "spk Gman/Gman_Choose2")
        }
    }
}
public event_GameRestart()
{
    n_rounds = 0
}
loadSettings(filename[])
{
    if (!file_exists(filename))
        return 0
    
    new szText[32], currentMap[32], buff[256]; get_mapname(currentMap, charsmax(currentMap))
    
    new fp=fopen(filename,"r");
    
    while (!feof(fp))
    {
        buff[0]='^0';
        szText[0]='^0';
        
        fgets(fp, buff, charsof(buff));
        
        parse(buff, szText, charsof(szText));
        
        if (szText[0] != ';' &&
        ValidMap(szText) &&
        !equali(szText, g_lastMap) &&
        !equali(szText, currentMap))
        {
            ArrayPushString(g_mapName, szText);
            ++g_mapNums;
        }
    
    }
    fclose(fp);
    
    return g_mapNums
}
stock bool:ValidMap(mapname[])
{
    if ( is_map_valid(mapname) )
    {
        return true;
    }
    // If the is_map_valid check failed, check the end of the string
    new len = strlen(mapname) - 4;
    
    // The mapname was too short to possibly house the .bsp extension
    if (len < 0)
    {
        return false;
    }
    if ( equali(mapname[len], ".bsp") )
    {
        // If the ending was .bsp, then cut it off.
        // the string is byref'ed, so this copies back to the loaded text.
        mapname[len] = '^0';
        
        // recheck
        if ( is_map_valid(mapname) )
        {
            return true;
        }
    }
    return false;
}
public plugin_end()
{
    new current_map[32]; get_mapname(current_map, charsmax(current_map))
    
    set_localinfo("lastMap", current_map)
} 
