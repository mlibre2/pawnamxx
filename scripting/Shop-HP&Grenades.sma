#include <amxmodx> 
#include <amxmisc> 
#include <cstrike> 
#include <fun> 

new chp[26]

public plugin_init() { 
    register_plugin("Shop HP/Grenades", "1.1", "mlibre") 
     
    chp[0] = register_cvar("amx_50hp_cost", "2000")  
    chp[1] = register_cvar("amx_100hp_cost", "4000") 
    chp[2] = register_cvar("amx_150hp_cost", "8000") 
    chp[3] = register_cvar("amx_hegrenade_cost", "1000") 
    chp[4] = register_cvar("amx_flashbang_cost", "500") 
    chp[5] = register_cvar("amx_smokegrenade_cost", "1500") 
     
    register_clcmd("say /shop" , "my_menu") 
} 
public my_menu(id) { 
    if (!is_user_alive(id)) { 
        client_print(id, 3, "[AMXX] You have to be alive to see the menu") 
        return PLUGIN_HANDLED 
    } else if (get_user_team(id) == 2 ) { 
        new szMenu; szMenu = menu_create("\yShop HP/Grenades\w", "buy_item") 
         
        menu_additem(szMenu, "\w50\y HP", "", 0 ) 
        menu_additem(szMenu, "\w100\y HP", "", 1 ) 
        menu_additem(szMenu, "\w150\y HP", "", 2 ) 
        menu_additem(szMenu, "\wHE\y Grenade", "", 3 ) 
        menu_additem(szMenu, "\wFlashbang\y Grenade", "", 4 ) 
        menu_additem(szMenu, "\wSmoke\y Grenade", "", 5 ) 
     
        menu_display(id, szMenu, 0) 
        return PLUGIN_HANDLED 
    } else { 
        client_print(id, 3, "[AMXX] This menu is only for Counter-Terrorist") 
        return PLUGIN_HANDLED 
    } 
    return PLUGIN_HANDLED; 
} 
public buy_item(id, menu, item) { 
    if(item == MENU_EXIT) menu_destroy(menu) 
    switch(item) { 
        case 0: { 
            if (cs_get_user_money(id) >= get_pcvar_num(chp[0])) cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(chp[0])), set_user_health(id,get_user_health(id) + 50) 
            else client_print(id, 3, "[AMXX] You need money ^"$%d^" to buy 50HP", get_pcvar_num(chp[0])) 
        } 
        case 1: { 
            if (cs_get_user_money(id) >= get_pcvar_num(chp[1])) cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(chp[1])), set_user_health(id,get_user_health(id) + 100) 
            else client_print(id, 3, "[AMXX] You need money ^"$%d^" to buy 100HP", get_pcvar_num(chp[1])) 
        } 
        case 2: { 
            if (cs_get_user_money(id) >= get_pcvar_num(chp[2])) cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(chp[2])), set_user_health(id,get_user_health(id) + 150) 
            else client_print(id, 3, "[AMXX] You need money ^"$%d^" to buy 150HP", get_pcvar_num(chp[2])) 
        } 
        case 3: { 
            if (cs_get_user_money(id) >= get_pcvar_num(chp[3])) cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(chp[3])), give_item(id, "weapon_hegrenade") 
            else client_print(id, 3, "[AMXX] You need money ^"$%d^" to buy HE Grenade", get_pcvar_num(chp[3])) 
        } 
        case 4: { 
            if (cs_get_user_money(id) >= get_pcvar_num(chp[4])) cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(chp[4])), give_item(id, "weapon_flashbang") 
            else client_print(id, 3, "[AMXX] You need money ^"$%d^" to buy Flashbang Grenade", get_pcvar_num(chp[4])) 
        } 
        case 5: { 
            if (cs_get_user_money(id) >= get_pcvar_num(chp[5])) cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(chp[5])), give_item(id, "weapon_smokegrenade") 
            else client_print(id, 3, "[AMXX] You need money ^"$%d^" to buy Smoke Grenade", get_pcvar_num(chp[5])) 
        } 
    } 
    return PLUGIN_HANDLED; 
} 
