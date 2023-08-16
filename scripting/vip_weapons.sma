#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <cstrike>

#define PLUGIN "vip_weapons"
#define VERSION "1.x"
#define AUTHOR "mlibre"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

#define	VipFlag	ADMIN_LEVEL_C

enum _:xData
{
	weapon_name[32], 		csw_name, 	model_path[256]
}

new const xWeapon[][xData] =
{
	{
		"weapon_m4a1", 		CSW_M4A1, 	"models/vip_weapons/v_m4a1.mdl"
	},
	{
		"weapon_ak47", 		CSW_AK47, 	"models/vip_weapons/v_ak47.mdl"
	},
	{
		"weapon_deagle", 	CSW_DEAGLE, 	"models/vip_weapons/v_deagle.mdl"
	},
	{
		"weapon_usp", 		CSW_USP, 	"models/vip_weapons/v_deagle.mdl"
	},
	{
		"weapon_famas",		CSW_FAMAS, 	"models/vip_weapons/v_famas.mdl"
	},
	{
		"weapon_sg550", 	CSW_SG550, 	"models/vip_weapons/v_sg550.mdl"
	},
	{
		"weapon_awp", 		CSW_AWP, 	"models/vip_weapons/v_awp.mdl"
	},
	{
		"weapon_xm1014", 	CSW_XM1014, 	"models/vip_weapons/v_xm1014.mdl"
	}
}

public plugin_precache()
{
	for(new i; i < sizeof xWeapon; i++)
	{
		if(file_exists(xWeapon[i][model_path]))
		{
			precache_model(xWeapon[i][model_path])
		}
		else 
		{
			#if AMXX_VERSION_NUM <= 182
			new sfs[256]; formatex(sfs, charsmax(sfs), "No exist: ^"%s^"", xWeapon[i][model_path])
			
			set_fail_state(sfs)
			#else
			set_fail_state("No exist: ^"%s^"", xWeapon[i][model_path])
			#endif
		}
		
		RegisterHam(Ham_Item_Deploy, xWeapon[i][weapon_name], "Ham_Item_Deploy_post", 1)
	}
}

public Ham_Item_Deploy_post(iEnt)
{
	new id = get_weapon_ent_owner(iEnt)
	
	if( !is_valid_ent(id) || !is_user_alive(id) || ~get_user_flags(id) & VipFlag )
		return HAM_IGNORED
	
	if(cs_get_user_team(id) & CS_TEAM_CT)
	{
		new iWeapon = cs_get_weapon_id(iEnt)
		
		for(new i; i < sizeof xWeapon; i++)
		{
			if(iWeapon == xWeapon[i][csw_name])
			{
				entity_set_string(id, EV_SZ_viewmodel, xWeapon[i][model_path])
				
				break
			}
		}
	}
	
	return HAM_IGNORED
}

stock get_weapon_ent_owner(iEnt)
{
	if( ~pev_valid(iEnt) & 2 )
		return -1
	
	const OFFSET_WEAPONOWNER = 41
	const OFFSET_LINUX_WEAPONS = 4
	
	return get_pdata_cbase(iEnt, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}
