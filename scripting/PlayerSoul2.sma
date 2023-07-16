#include <amxmodx>
#include <hamsandwich>
#include <engine>

#define PLUGIN "Player Soul"
#define VERSION "2.2"
#define AUTHOR "mlibre"

new g_iCvarScreenFade, g_fCvarTransparency, g_fCvarVelocity

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_iCvarScreenFade = register_cvar("amx_psoul_screenfade", "1")
	g_fCvarTransparency = register_cvar("amx_psoul_transparency", "50.0")
	g_fCvarVelocity = register_cvar("amx_psoul_velocity", "80.0")
	
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
	new ent = create_entity("info_target")
	
	if( !ent )
		return
		
	entity_set_string(ent, EV_SZ_classname, "s0ul")
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_NOCLIP)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	
	new szInfo[64]; get_user_info(id, "model", szInfo, charsmax(szInfo))
	
	new szModel[256]; formatex(szModel, charsmax(szModel), "models/player/%s/%s.mdl", szInfo, szInfo)
	
	//antiCrash!
	if(containi(szModel, ".mdl") == strlen(szModel) - 4)
	{
		entity_set_model(ent, szModel)
	}
	else {
		log_amx("%s *** overflow!", szModel)
		
		entity_set_model(ent, "models/player.mdl")
	}
	
	entity_set_int(ent, EV_INT_sequence, 64)	// set player body =--()--=
	entity_set_float(ent, EV_FL_frame, 0.0)
	
	new Float:fOrigin[3]; entity_get_vector(id, EV_VEC_origin, fOrigin)
	
	fOrigin[2] += 10.0
	
	entity_set_origin(ent, fOrigin)
	
	// effect soul
	entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell)
	entity_set_int(ent, EV_INT_rendermode, kRenderTransAlpha)
	entity_set_float(ent, EV_FL_renderamt, get_pcvar_float(g_fCvarTransparency))
	
	// apply motion
	new Float:fVelocity[3]
	
	fVelocity[2] = get_pcvar_float(g_fCvarVelocity)
	
	entity_set_vector(ent, EV_VEC_velocity, fVelocity)
	
	set_task(3.0, "remove_s0ul", ent)
}

public remove_s0ul(ent)
{
	if(is_valid_ent(ent))
		entity_set_int(ent, EV_INT_flags, FL_KILLME)
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
