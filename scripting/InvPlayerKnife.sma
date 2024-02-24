//#define METHOD_ENGINE

#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <fun>

#if !defined METHOD_ENGINE
	#include <cstrike>
#endif

#if AMXX_VERSION_NUM < 183
	#define MAX_PLAYERS 32
#endif

#define PLUGIN "Inv. Player with Knife"
#define VERSION "1.2"
#define AUTHOR "mlibre"

new bool:isKnife[MAX_PLAYERS + 1]

new const ent_names[][] =
{
	"p228",
	"shield",
	"scout",
	"hegrenade",
	"xm1014",
	"c4",
	"mac10",
	"aug",
	"smokegrenade",
	"elite",
	"fiveseven",
	"ump45",
	"sg550",
	"galil",
	"famas",
	"usp",
	"glock18",
	"awp",
	"mp5navy",
	"m249",
	"m3",
	"m4a1",
	"tmp",
	"g3sg1",
	"flashbang",
	"deagle",
	"sg552",
	"ak47",
	"knife",
	"p90"
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY)
	
	for(new i, wn[20]; i < sizeof ent_names; i++)
	{
		formatex(wn, charsmax(wn), "weapon_%s", ent_names[i])
		
		RegisterHam(Ham_Item_Deploy, wn, "Ham_Item_Deploy_Post", true)
	}
}

public Ham_Item_Deploy_Post(iEnt)
{
	if( !is_valid_ent(iEnt) )
		return HAM_IGNORED
		
	new iPlayer = get_pdata_cbase(iEnt, 41, 4)
	
	if( !is_user_connected(iPlayer) )
		return HAM_IGNORED
		
	#if !defined METHOD_ENGINE
		
	if( !isKnife[iPlayer] )
	{
		if(cs_get_weapon_id(iEnt) == CSW_KNIFE)
		{
			set_user_rendering(iPlayer, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
			
			isKnife[iPlayer] = true
		}
	}
	else
	{
		set_user_rendering(iPlayer)
		
		isKnife[iPlayer] = false
	}
	
	#else
		
	new szWeapon[13]; entity_get_string(iEnt, EV_SZ_classname, szWeapon, charsmax(szWeapon))
	
	if(contain(szWeapon, ent_names[28]) != -1) 
	{
		set_user_rendering(iPlayer, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
		
		isKnife[iPlayer] = true
	}
	else
	{
		if(isKnife[iPlayer])
		{
			set_user_rendering(iPlayer)
		
			isKnife[iPlayer] = false
		}
	}
	
	#endif
	
	return HAM_IGNORED
}
