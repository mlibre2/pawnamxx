#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

#define PLUGIN "vip_weapons"
#define VERSION "1.1"
#define AUTHOR "mlibre"

#if AMXX_VERSION_NUM < 183
	#define MAX_PLAYERS 32
	#define MAX_RESOURCE_PATH_LENGTH 64
#endif

const ADMIN_VIP_FLAG = ADMIN_LEVEL_C	//<-users.ini ; "o" - custom level C

enum _:xData
{
		csw_name, 	model_path[MAX_RESOURCE_PATH_LENGTH]
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
	
	for(new i, weapon_name[MAX_PLAYERS]; i < sizeof xWeapon; i++)
	{
		if(file_exists(xWeapon[i][model_path]))
		{
			precache_model(xWeapon[i][model_path])
		}
		else 
		{
			#if AMXX_VERSION_NUM <= 182
			new sfs[MAX_RESOURCE_PATH_LENGTH * 2]; formatex(sfs, charsmax(sfs), "No exist: ^"%s^"", xWeapon[i][model_path])
			
			set_fail_state(sfs)
			#else
			set_fail_state("No exist: ^"%s^"", xWeapon[i][model_path])
			#endif
		}
		
		get_weaponname(xWeapon[i][csw_name], weapon_name, charsmax(weapon_name))
		
		RegisterHam(Ham_Item_Deploy, weapon_name, "Ham_Item_Deploy_Post", true)
	}
}

// offsets
#define XO_WEAPON 4
#define m_pPlayer 41
#define m_iId 43

enum
{
	TERRORIST = 1,
	CT
}

public Ham_Item_Deploy_Post(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON)
	
	if(id < 1 || id > MAX_PLAYERS || !is_valid_ent(iEnt) || ~get_user_flags(id) & ADMIN_VIP_FLAG)
		return HAM_IGNORED
			
	if(get_user_team(id) == CT)
	{
		new iWeapon = get_pdata_int(iEnt, m_iId, XO_WEAPON)
		
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
