#include <amxmodx>
#include <amxmisc>
#define keys (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)

new const g_MsgArgs[][] = { "#Team_Select","#Team_Select_Spect","#IG_Team_Select","#IG_Team_Select_Spect" } 

public plugin_init() {
    register_plugin("Team Select TE/SPEC", "1.1", "Manu & mlibre")
    
    register_message(get_user_msgid("ShowMenu"),"message_showmenu")
    register_message(get_user_msgid("VGUIMenu"),"message_vguimenu") 
     
    register_clcmd("chooseteam","cmd_block"), register_clcmd("jointeam","cmd_block") 
    
    register_menu("Team_select", keys, "team_select")
}
public message_showmenu(msgid,dest,id) { 
    static szMsg[32];get_msg_arg_string(4,szMsg,charsmax(szMsg))

    for(new i;i < sizeof g_MsgArgs;i++) { 
        if(equal(szMsg,g_MsgArgs[i])) menu_teams(id)
    }
} 
public message_vguimenu(msgid,dest,id) { 
    if(get_msg_arg_int(1) != 2) return PLUGIN_CONTINUE 
    menu_teams(id); return PLUGIN_HANDLED 
} 
public cmd_block(id) { 
    menu_teams(id) 
    return PLUGIN_HANDLED 
} 
public menu_teams(id) {
    static menu[128]; new len = format(menu, sizeof menu - 1, "\ySelecciona un Equipo:^n^n")
    
    len += format(menu[len], sizeof menu - len, "\r1.\w Terrorista^n^n")
    len += format(menu[len], sizeof menu - len, "\r6.\w Espectador^n^n^n")
    
    len += format(menu[len], sizeof menu - len, "\r0.\w Salir")
    
    show_menu(id, keys, menu, -1, "Team_select")
    
    return PLUGIN_HANDLED
}
public team_select(id, key) {
    switch(key) {
        case 0: engclient_cmd(id, "jointeam", "1")
        case 1..4: menu_teams(id)
        case 5: engclient_cmd(id, "jointeam", "6")
        case 6..8: menu_teams(id)
        case 9: {
        }
    }
    return PLUGIN_HANDLED
} 
public client_connect(id) set_user_info(id, "_vgui_menus", "1") 
