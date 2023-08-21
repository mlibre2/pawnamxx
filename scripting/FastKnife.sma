#include <amxmodx>
#include <fun>

#define PLUGIN_VERSION "1.0.1"
new g_pSpeed
new g_pSprintDuration

public plugin_init()
{
    register_plugin("Fast Knife", PLUGIN_VERSION, "OciXCrom")
    register_cvar("CRXFastKnife", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED)
    register_event("CurWeapon", "OnSelectKnife", "be", "1=1", "2=29")
    
    g_pSpeed = register_cvar("fastknife_speed", "150.0");
    g_pSprintDuration = register_cvar("sprint_duration", "2.5");
    
    set_task(20.0, "ShowSprintMessage", 0); // Показваме съобщение след X секунди.
}

public OnSelectKnife(id)
{
    if (is_user_alive(id))
    {
        set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_float(g_pSpeed));
        set_task(get_pcvar_float(g_pSprintDuration), "EndFastKnife", id); // Активираме таймер за деактивиране след X секунди.
    }
}

public EndFastKnife(id)
{
    if (is_user_alive(id))
    {
        set_user_maxspeed(id, 250.0); // Връщаме нормалната скорост.
    }
}

public ShowSprintMessage(id)
{
    client_print(id, print_chat, "You can sprint with a knife in hand for 2.5 seconds!");
}
