#include <amxmodx>
#include <amxmisc>

#define keys (1<<0|1<<1|1<<4|1<<5)

new const g_MsgArgs[][] = { "#Team_Select","#Team_Select_Spect","#IG_Team_Select","#IG_Team_Select_Spect" } 

public plugin_init() {
 register_plugin("Team Select TE/CT/Auto/SPEC", "1.x", "Manu & mlibre")
 
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
 static menu[500]; new len = format(menu, sizeof menu - 1, "\ySelecciona un Equipo:^n^n")
 
 len += format(menu[len], sizeof menu - len, "\r1.\w Terrorista^n")
 len += format(menu[len], sizeof menu - len, "\r2.\w Anti-Terrorista^n^n^n")
 len += format(menu[len], sizeof menu - len, "\r5.\w Autoseleccinar^n")
 len += format(menu[len], sizeof menu - len, "\r6.\w Espectador")
 
 show_menu(id, keys, menu, -1, "Team_select")
 
 return PLUGIN_HANDLED
}
public team_select(id, key) {
 switch(key) {
 case 0: engclient_cmd(id, "jointeam", "1")
 case 1: engclient_cmd(id, "jointeam", "2")
 case 4: engclient_cmd(id, "jointeam", "5")
 case 5: engclient_cmd(id, "jointeam", "6")
 }
 return PLUGIN_HANDLED
} 
public client_connect(id) set_user_info(id, "_vgui_menus", "1") 
