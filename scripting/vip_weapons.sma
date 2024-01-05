#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <cstrike>

#define PLUGIN "vip_weapons"
#define VERSION "1.x"
#define AUTHOR "mlibre"

#define	VipFlag	ADMIN_LEVEL_C

enum _:xData
{
		csw_name, 	model_path[256]
}

new const xWeapon[][xData] =
{
	{
		CSW_M4A1, 	"models/vip_weapons/v_m4a1.mdl"
	},
	{
		CSW_AK47, 	"models/vip_weapons/v_ak47.mdl"
	},
	{
		CSW_DEAGLE, 	"models/vip_weapons/v_deagle.mdl"
	},
	{
		CSW_USP, 	"models/vip_weapons/v_usp.mdl"
	},
	{
		CSW_FAMAS, 	"models/vip_weapons/v_famas.mdl"
	},
	{
		CSW_SG550, 	"models/vip_weapons/v_sg550.mdl"
	},
	{
		CSW_AWP, 	"models/vip_weapons/v_awp.mdl"
	},
	{
		CSW_XM1014, 	"models/vip_weapons/v_xm1014.mdl"
	}
}

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	new weapon_name[32]
	
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
		
		get_weaponname(xWeapon[i][csw_name], weapon_name, charsmax(weapon_name))
		
		RegisterHam(Ham_Item_Deploy, weapon_name, "Ham_Item_Deploy_Post", true)
	}
}

public Ham_Item_Deploy_Post(iEnt)
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
