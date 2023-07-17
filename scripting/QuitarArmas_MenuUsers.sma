#include <amxmodx>
#include <amxmisc>
#include <fun>

new g_menuPosition[33], g_menuPlayers[33][32], g_menuPlayersNum[33], g_coloredMenus

public plugin_init() {
    register_plugin("Quitar Armas/Menu Users", "1.0", "mlibre")
    
    register_concmd("cmd_quitar_armas","cmd_quitar_armas",ADMIN_KICK,"<nick>")
    register_concmd("menu_quitar_armas","menu_quitar_armas",ADMIN_KICK)
    
    register_menucmd(register_menuid("Strip Menu"), 1023, "action_quitar_armasMenu")
}
public action_quitar_armasMenu(id, key) {
    switch (key) {
        case 8: display_quitar_armasMenu(id, ++g_menuPosition[id])
        case 9: display_quitar_armasMenu(id, --g_menuPosition[id])
        default: {
            new player = g_menuPlayers[id][g_menuPosition[id] * 8 + key]
            new authid2[32], name[32], name2[32]
            
            get_user_authid(player, authid2, 31)
            get_user_name(id, name, 31)
            get_user_name(player, name2, 31)
            
            new userid2 = get_user_userid(player)

            client_print(0, 3, "[AMXX] %s le quito todas las armas a: %s", name, name2)

            server_cmd("cmd_quitar_armas #%d", userid2)
            
            server_exec()

            display_quitar_armasMenu(id, g_menuPosition[id])
        }
    }
    return PLUGIN_HANDLED
}
display_quitar_armasMenu(id, pos) {
    if (pos < 0) return

    get_players(g_menuPlayers[id], g_menuPlayersNum[id])

    new menuBody[512], b = 0, i, name[32], start = pos * 8

    if (start >= g_menuPlayersNum[id]) start = pos = g_menuPosition[id] = 0

    new len = format(menuBody, 511, g_coloredMenus ? "\y%s\R%d/%d^n\w^n" : "%s %d/%d^n^n", "Menu Quitar Armas", pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
    
    //new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "KICK_MENU", pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
    new end = start + 8; new keys = MENU_KEY_0

    if (end > g_menuPlayersNum[id]) end = g_menuPlayersNum[id]

    for (new a = start; a < end; ++a) {
        i = g_menuPlayers[id][a]
        get_user_name(i, name, 31)

        if (access(i, ADMIN_IMMUNITY) && i != id)
        {
            ++b
        
            if (g_coloredMenus)
                len += format(menuBody[len], 511-len, "\d%d. %s^n\w", b, name)
            else
                len += format(menuBody[len], 511-len, "#. %s^n", name)
        } else {
            keys |= (1<<b)
                
            if (is_user_admin(i))
                len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *^n", ++b, name)
            else
                len += format(menuBody[len], 511-len, "%d. %s^n", ++b, name)
        }
    }
    if (end != g_menuPlayersNum[id]) {
        format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
        keys |= MENU_KEY_9
    }
    else
        format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

    show_menu(id, keys, menuBody, -1, "Strip Menu")
}
public menu_quitar_armas(id, level, cid) {
    if (cmd_access(id, level, cid, 1)) display_quitar_armasMenu(id, g_menuPosition[id] = 0)

    return PLUGIN_HANDLED
}
public cmd_quitar_armas(id,level,cid){
    if (!cmd_access(id,level,cid,2)) return PLUGIN_HANDLED
    
    new arg[32]; read_argv(1, arg, charsmax(arg)); new target = cmd_target(id,arg,1)
    
    if(!target) return PLUGIN_HANDLED
    
    if(is_user_alive(target)) strip_user_weapons(target)
    
    return PLUGIN_HANDLED
} 
