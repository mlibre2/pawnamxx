#include <amxmodx>
#include <hamsandwich>
#include <engine>

#define PLUGIN "Player Soul"
#define VERSION "1.3"
#define AUTHOR "mlibre"

new g_soulSpr, g_iCvarScreenFade, g_iCvarFloatHeight

public plugin_precache() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_iCvarScreenFade = register_cvar("amx_psoul_screenfade", "1")
	g_iCvarFloatHeight = register_cvar("amx_psoul_floatheight", "180")
	
	g_soulSpr = precache_model("sprites/iplayerdead.spr")
	
	RegisterHam(Ham_Killed, "player", "Ham_KilledPlayer_Post", 1)
}

public Ham_KilledPlayer_Post(id, attacker)
{
	//green effects
	if(get_pcvar_num(g_iCvarScreenFade))
	{
		set_ScreenFade(attacker)
	}
	
	//generate the soul
	new Float:fOrigin[3]; entity_get_vector(id, EV_VEC_origin, fOrigin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BUBBLES)
	#if !defined write_coord_f
	write_coord(floatround(fOrigin[0]))
	write_coord(floatround(fOrigin[1]))
	write_coord(floatround(fOrigin[2]))	//min start position
	write_coord(floatround(fOrigin[0]))
	write_coord(floatround(fOrigin[1]))
	write_coord(floatround(fOrigin[2])+10)	//max start position
	#else
	write_coord_f(fOrigin[0])
	write_coord_f(fOrigin[1])
	write_coord_f(fOrigin[2])		//min start position
	write_coord_f(fOrigin[0])
	write_coord_f(fOrigin[1])
	write_coord_f(fOrigin[2]+10)		//max start position
	#endif
	write_coord(get_pcvar_num(g_iCvarFloatHeight))	//float height
	write_short(g_soulSpr)
	write_byte(1)		//count
	write_coord(1)		//speed
	message_end()
}

stock set_ScreenFade(id)
{
	static maxplayers
	
	if( !maxplayers )
		maxplayers = get_maxplayers()
		
	#define isPlayer(%1)	(1 <= %1 <= maxplayers)
	
	if( !isPlayer(id) )
		return
	
	static msgid_ScreenFade
	
	if( !msgid_ScreenFade )
		msgid_ScreenFade = get_user_msgid("ScreenFade")
	
	message_begin(MSG_ONE_UNRELIABLE, msgid_ScreenFade, {0,0,0}, id)
	write_short(1<<10)	// Duration
	write_short(1<<10)	// Hold time
	write_short(0x0000)	// Fade type
	write_byte(120)	// Red
	write_byte(255)	// Green
	write_byte(120)	// Blue
	write_byte(100)	// Alpha
	message_end()
}
