#define USE_CSTRIKE
//#define USE_FUN

#include <amxmodx>
#include <hamsandwich>
#include <engine>

#if AMXX_VERSION_NUM < 183
	const MAX_PLAYERS = 32
#endif

#if defined USE_CSTRIKE
	native cs_get_weapon_id(index)
#endif

#if defined USE_FUN
	native set_user_rendering(index, fx = kRenderFxNone, r = 0, g = 0, b = 0, render = kRenderNormal, amount = 0)
#endif

#define PLUGIN "InvisiblePlayerKnife"
#define VERSION "1.4"
#define AUTHOR "mlibre"

new bool:isKnife[MAX_PLAYERS + 1]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	for(new i = CSW_P228, weapon_name[20]; i <= CSW_P90; i++)
	{
		if(get_weaponname(i, weapon_name, charsmax(weapon_name)))
		{
			RegisterHam(Ham_Item_Deploy, weapon_name, "Ham_Item_Deploy_Post", true)
		}
	}
}

public Ham_Item_Deploy_Post(iWeapon)
{
	if( !is_valid_ent(iWeapon) )
		return HAM_IGNORED
		
	const OFFSET_WEAPONOWNER = 41
	const OFFSET_LINUX_WEAPONS = 4
		
	new iPlayer = get_pdata_cbase(iWeapon, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
	
	if( !is_user_connected(iPlayer) )
		return HAM_IGNORED
		
	if(isKnife[iPlayer])
	{
		set_render(iPlayer, false)
	}
	
	#if defined USE_CSTRIKE
	
	else if(cs_get_weapon_id(iWeapon) == CSW_KNIFE)
	{
		set_render(iPlayer, true)
	}
	
	#else
	
	else
	{
		new szWeapon[9]; entity_get_string(iWeapon, EV_SZ_classname, szWeapon, charsmax(szWeapon))
		
		if(szWeapon[7] == 'k')
		{
			set_render(iPlayer, true)
		}
	}
	
	#endif
	
	return HAM_IGNORED
}

stock set_render(iPlayer, x)
{
	#if !defined USE_FUN
	
	entity_set_int(iPlayer, EV_INT_rendermode, x ? kRenderTransAlpha : kRenderNormal)
	entity_set_float(iPlayer, EV_FL_renderamt, x ? 0.0 : 255.0)
	
	#else
	
	set_user_rendering(x ? iPlayer, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 : iPlayer)
	
	#endif
	
	isKnife[iPlayer] = (x ? true : false)
}
