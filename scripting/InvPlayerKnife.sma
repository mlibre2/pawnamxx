#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <fun>
#include <cstrike>

#define PLUGIN "Inv. Player with Knife"
#define VERSION "1.0"
#define AUTHOR "mlibre"

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
			
	if(cs_get_weapon_id(iEnt) == CSW_KNIFE)
	{
		set_user_rendering(iPlayer, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
	}
	else
	{
		set_user_rendering(iPlayer)
	}
	
	return HAM_IGNORED
}
