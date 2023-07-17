#include <amxmodx>
#include <cstrike>
#include <fun>

new pfrags[33], aCvar[26], mCvar[26], dCvar[26], fCvar[26]

public plugin_init() {
    register_plugin("Dar Dinero por Frags/Armas", "1.1", "mlibre")
    
    register_event("ResetHUD","playerSpawn","b")
    
    //--> armas primarias
    aCvar[0] = register_cvar("arma_ak74","1")        // activar = 1 / desactivar = 0
    mCvar[0] = register_cvar("monto_ak74","16000")  // monto maximo total del jugador
    dCvar[0] = register_cvar("dinero_ak74","501")   // dinero a dar por matar
    fCvar[0] = register_cvar("frags_ak74","1")      // cuantos frags/muertes antes de dar dinero
    //-->
    aCvar[1] = register_cvar("arma_m4a1","1")
    mCvar[1] = register_cvar("monto_m4a1","16000")
    dCvar[1] = register_cvar("dinero_m4a1","502")
    fCvar[1] = register_cvar("frags_m4a1","1")
    //-->
    aCvar[2] = register_cvar("arma_scout","1")
    mCvar[2] = register_cvar("monto_scout","16000")
    dCvar[2] = register_cvar("dinero_scout","503")
    fCvar[2] = register_cvar("frags_scout","1")
    //-->
    aCvar[3] = register_cvar("arma_xm1014","1")
    mCvar[3] = register_cvar("monto_xm1014","16000")
    dCvar[3] = register_cvar("dinero_xm1014","504")
    fCvar[3] = register_cvar("frags_xm1014","1")
    //-->
    aCvar[4] = register_cvar("arma_mac10","1")
    mCvar[4] = register_cvar("monto_mac10","16000")
    dCvar[4] = register_cvar("dinero_mac10","505")
    fCvar[4] = register_cvar("frags_mac10","1")
    //-->
    aCvar[5] = register_cvar("arma_aug","1")
    mCvar[5] = register_cvar("monto_aug","16000")
    dCvar[5] = register_cvar("dinero_aug","506")
    fCvar[5] = register_cvar("frags_aug","1")
    //-->
    aCvar[6] = register_cvar("arma_ump45","1")
    mCvar[6] = register_cvar("monto_ump45","16000")
    dCvar[6] = register_cvar("dinero_ump45","507")
    fCvar[6] = register_cvar("frags_ump45","1")
    //-->
    aCvar[7] = register_cvar("arma_sg550","1")
    mCvar[7] = register_cvar("monto_sg550","16000")
    dCvar[7] = register_cvar("dinero_sg550","508")
    fCvar[7] = register_cvar("frags_sg550","1")
    //-->
    aCvar[8] = register_cvar("arma_galil","1")
    mCvar[8] = register_cvar("monto_galil","16000")
    dCvar[8] = register_cvar("dinero_galil","509")
    fCvar[8] = register_cvar("frags_galil","1")
    //-->
    aCvar[9] = register_cvar("arma_famas","1")
    mCvar[9] = register_cvar("monto_famas","16000")
    dCvar[9] = register_cvar("dinero_famas","510")
    fCvar[9] = register_cvar("frags_famas","1")
    //-->
    aCvar[10] = register_cvar("arma_awp","1")
    mCvar[10] = register_cvar("monto_awp","16000")
    dCvar[10] = register_cvar("dinero_awp","511")
    fCvar[10] = register_cvar("frags_awp","1")
    //-->
    aCvar[11] = register_cvar("arma_mp5navy","1")
    mCvar[11] = register_cvar("monto_mp5navy","16000")
    dCvar[11] = register_cvar("dinero_mp5navy","512")
    fCvar[11] = register_cvar("frags_mp5navy","1")
    //-->
    aCvar[12] = register_cvar("arma_m249","1")
    mCvar[12] = register_cvar("monto_m249","16000")
    dCvar[12] = register_cvar("dinero_m249","513")
    fCvar[12] = register_cvar("frags_m249","1")
    //-->
    aCvar[13] = register_cvar("arma_m3","1")
    mCvar[13] = register_cvar("monto_m3","16000")
    dCvar[13] = register_cvar("dinero_m3","514")
    fCvar[13] = register_cvar("frags_m3","1")
    //-->
    aCvar[14] = register_cvar("arma_tmp","1")
    mCvar[14] = register_cvar("monto_tmp","16000")
    dCvar[14] = register_cvar("dinero_tmp","515")
    fCvar[14] = register_cvar("frags_tmp","1")
    //-->
    aCvar[15] = register_cvar("arma_g3sg1","1")
    mCvar[15] = register_cvar("monto_g3sg1","16000")
    dCvar[15] = register_cvar("dinero_g3sg1","516")
    fCvar[15] = register_cvar("frags_g3sg1","1")
    //-->
    aCvar[16] = register_cvar("arma_sg552","1")
    mCvar[16] = register_cvar("monto_sg552","16000")
    dCvar[16] = register_cvar("dinero_sg552","517")
    fCvar[16] = register_cvar("frags_sg552","1")
    //-->
    aCvar[17] = register_cvar("arma_p90","1")
    mCvar[17] = register_cvar("monto_p90","16000")
    dCvar[17] = register_cvar("dinero_p90","518")
    fCvar[17] = register_cvar("frags_p90","1")
    //--> armas segundarias
    aCvar[18] = register_cvar("arma_p228","1")
    mCvar[18] = register_cvar("monto_p228","16000")
    dCvar[18] = register_cvar("dinero_p228","519")
    fCvar[18] = register_cvar("frags_p228","1")
    //-->
    aCvar[19] = register_cvar("arma_elite","1")
    mCvar[19] = register_cvar("monto_elite","16000")
    dCvar[19] = register_cvar("dinero_elite","520")
    fCvar[19] = register_cvar("frags_elite","1")
    //-->
    aCvar[20] = register_cvar("arma_fiveseven","1")
    mCvar[20] = register_cvar("monto_fiveseven","16000")
    dCvar[20] = register_cvar("dinero_fiveseven","521")
    fCvar[20] = register_cvar("frags_fiveseven","1")
    //-->
    aCvar[21] = register_cvar("arma_usp","1")
    mCvar[21] = register_cvar("monto_usp","16000")
    dCvar[21] = register_cvar("dinero_usp","522")
    fCvar[21] = register_cvar("frags_usp","1")
    //-->
    aCvar[22] = register_cvar("arma_glock18","1")
    mCvar[22] = register_cvar("monto_glock18","16000")
    dCvar[22] = register_cvar("dinero_glock18","523")
    fCvar[22] = register_cvar("frags_glock18","1")
    //-->
    aCvar[23] = register_cvar("arma_deagle","1")
    mCvar[23] = register_cvar("monto_deagle","16000")
    dCvar[23] = register_cvar("dinero_deagle","524")
    fCvar[23] = register_cvar("frags_deagle","1")
    //--> granada he
    aCvar[24] = register_cvar("arma_hegrenade","1")
    mCvar[24] = register_cvar("monto_hegrenade","16000")
    dCvar[24] = register_cvar("dinero_hegrenade","525")
    fCvar[24] = register_cvar("frags_hegrenade","1")
    //--> cuchillo
    aCvar[25] = register_cvar("arma_knife","1")
    mCvar[25] = register_cvar("monto_knife","16000")
    dCvar[25] = register_cvar("dinero_knife","526")
    fCvar[25] = register_cvar("frags_knife","1")
}

public playerSpawn(id) pfrags[id]=0

public client_death(attacker, victim, weapon) {
    if(!is_user_connected(attacker) || victim == attacker) return
    
    pfrags[attacker]=pfrags[attacker]+1

    //--> armas primarias
    if(weapon == CSW_AK47 && pfrags[attacker] >= get_pcvar_num(fCvar[0])) {
        if(get_pcvar_num(aCvar[0])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[0]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[0]))
        }
    }
    if(weapon == CSW_M4A1 && pfrags[attacker] >= get_pcvar_num(fCvar[1])) {
        if(get_pcvar_num(aCvar[1])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[1]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[1]))
        }
    }
    if(weapon == CSW_SCOUT && pfrags[attacker] >= get_pcvar_num(fCvar[2])) {
        if(get_pcvar_num(aCvar[2])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[2]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[2]))
        }
    }
    if(weapon == CSW_XM1014 && pfrags[attacker] >= get_pcvar_num(fCvar[3])) {
        if(get_pcvar_num(aCvar[3])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[3]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[3]))
        }
    }
    if(weapon == CSW_MAC10 && pfrags[attacker] >= get_pcvar_num(fCvar[4])) {
        if(get_pcvar_num(aCvar[4])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[4]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[4]))
        }
    }
    if(weapon == CSW_AUG && pfrags[attacker] >= get_pcvar_num(fCvar[5])) {
        if(get_pcvar_num(aCvar[5])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[5]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[5]))
        }
    }
    if(weapon == CSW_UMP45 && pfrags[attacker] >= get_pcvar_num(fCvar[6])) {
        if(get_pcvar_num(aCvar[6])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[6]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[6]))
        }
    }
    if(weapon == CSW_SG550 && pfrags[attacker] >= get_pcvar_num(fCvar[7])) {
        if(get_pcvar_num(aCvar[7])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[7]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[7]))
        }
    }
    if(weapon == CSW_GALIL && pfrags[attacker] >= get_pcvar_num(fCvar[8])) {
        if(get_pcvar_num(aCvar[8])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[8]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[8]))
        }
    }
    if(weapon == CSW_FAMAS && pfrags[attacker] >= get_pcvar_num(fCvar[9])) {
        if(get_pcvar_num(aCvar[9])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[9]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[9]))
        }
    }
    if(weapon == CSW_AWP && pfrags[attacker] >= get_pcvar_num(fCvar[10])) {
        if(get_pcvar_num(aCvar[10])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[10]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[10]))
        }
    }
    if(weapon == CSW_MP5NAVY && pfrags[attacker] >= get_pcvar_num(fCvar[11])) {
        if(get_pcvar_num(aCvar[11])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[11]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[11]))
        }
    }
    if(weapon == CSW_M249 && pfrags[attacker] >= get_pcvar_num(fCvar[12])) {
        if(get_pcvar_num(aCvar[12])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[12]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[12]))
        }
    }
    if(weapon == CSW_M3 && pfrags[attacker] >= get_pcvar_num(fCvar[13])) {
        if(get_pcvar_num(aCvar[13])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[13]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[13]))
        }
    }
    if(weapon == CSW_TMP && pfrags[attacker] >= get_pcvar_num(fCvar[14])) {
        if(get_pcvar_num(aCvar[14])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[14]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[14]))
        }
    }
    if(weapon == CSW_G3SG1 && pfrags[attacker] >= get_pcvar_num(fCvar[15])) {
        if(get_pcvar_num(aCvar[15])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[15]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[15]))
        }
    }
    if(weapon == CSW_SG552 && pfrags[attacker] >= get_pcvar_num(fCvar[16])) {
        if(get_pcvar_num(aCvar[16])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[16]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[16]))
        }
    }
    if(weapon == CSW_P90 && pfrags[attacker] >= get_pcvar_num(fCvar[17])) {
        if(get_pcvar_num(aCvar[17])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[17]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[17]))
        }
    }
    //--> armas segundarias
    if(weapon == CSW_P228 && pfrags[attacker] >= get_pcvar_num(fCvar[18])) {
        if(get_pcvar_num(aCvar[18])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[18]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[18]))
        }
    }
    if(weapon == CSW_ELITE && pfrags[attacker] >= get_pcvar_num(fCvar[19])) {
        if(get_pcvar_num(aCvar[19])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[19]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[19]))
        }
    }
    if(weapon == CSW_FIVESEVEN && pfrags[attacker] >= get_pcvar_num(fCvar[20])) {
        if(get_pcvar_num(aCvar[20])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[20]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[20]))
        }
    }
    if(weapon == CSW_USP && pfrags[attacker] >= get_pcvar_num(fCvar[21])) {
        if(get_pcvar_num(aCvar[21])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[21]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[21]))
        }
    }
    if(weapon == CSW_GLOCK18 && pfrags[attacker] >= get_pcvar_num(fCvar[22])) {
        if(get_pcvar_num(aCvar[22])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[22]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[22]))
        }
    }
    if(weapon == CSW_DEAGLE && pfrags[attacker] >= get_pcvar_num(fCvar[23])) {
        if(get_pcvar_num(aCvar[23])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[23]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[23]))
        }
    }
    //--> granada he
    if(weapon == CSW_HEGRENADE && pfrags[attacker] >= get_pcvar_num(fCvar[24])) {
        if(get_pcvar_num(aCvar[24])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[24]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[24]))
        }
    }
    //--> cuchillo
    if(weapon == CSW_KNIFE && pfrags[attacker] >= get_pcvar_num(fCvar[25])) {
        if(get_pcvar_num(aCvar[25])) {
            if( cs_get_user_money(attacker) <= get_pcvar_num(mCvar[25]))
            cs_set_user_money(attacker, cs_get_user_money(attacker)+get_pcvar_num(dCvar[25]))
        }
    }
} 
