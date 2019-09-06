#include "..\component.hpp"

/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Spawns a helicopter used to extract the player.
 *
 * Parameter(s):
 *     0: POSITION - used as a reference point for the vehicle.
 *     1: INTEGER -  distance, in metres, between the vehicle and the player.
 *     2: INTEGER - represents the direction the vehicle will arrive from.
 *     3: INTEGER - represents the height the vehicle spawns at.
 *
 * Returns:
 *     ARRAY - 0: created vehicle (object),
 *             1: vehicle's crew (array of objects),
 *             2: vehicle's group (group).
 */

params ["_spawnRefPos", "_spawnRange", "_spawnDir", "_spawnHeight"];

_spawnPos =
[
    (_spawnRefPos select 0) + (_spawnRange * sin(_spawnDir)), 
    (_spawnRefPos select 1) + (_spawnRange * cos(_spawnDir)), 
    (_spawnRefPos select 2) + _spawnHeight
];

_azimuth = _spawnPos getDir _spawnRefPos;

_heliClass = switch (side player) do
{
    case west:
    {
        switch (faction player) do
        {
            case "BLU_F":                 { "B_Heli_Transport_01_F"            }; // NATO (Default)
            case "BLU_T_F":               { "B_Heli_Transport_01_F"            }; // NATO (Pacific)
            case "BLU_CTRG_F":            { "B_CTRG_Heli_Transport_01_sand_F"  }; // NATO (CTRG)
            case "BLU_G_F":               { "B_Heli_Light_01_F"                }; // FIA
            case "ACR_A3":                { "ACR_A3_Mi17_base_CZ_EP1"          }; // ACR
            case "ACR_A3_Des":            { "ACR_A3_Mi17_base_CZ_EP1_Des"      }; // ACR (Desert)
            case "rhs_faction_usarmy_d":  { "RHS_UH60M_d"                      }; // RHS USA (Army - D)
            case "rhs_faction_usarmy_wd": { "RHS_UH60M"                        }; // RHS USA (Army - W)
            case "rhs_faction_socom":     { "RHS_MELB_MH6M"                    }; // RHS USA (SOCOM)
            case "rhs_faction_usmc_d":    { "RHS_UH1Y_d"                       }; // RHS USA (USMC - D)
            case "rhs_faction_usmc_wd":   { "RHS_UH1Y"                         }; // RHS USA (USMC - W)
            case "rhsgref_faction_hidf":  { "rhs_uh1h_hidf_gunship"            }; // RHS Horizon Islands Defence Force
            case "CUP_B_CZ":              { "CUP_B_Mi171Sh_Unarmed_ACR"        }; // CUP CZ (ACR)
            case "CUP_B_GB":              { "CUP_B_SA330_Puma_HC1_BAF"         }; // CUP GB (BAF)
            case "CUP_B_GER":             { "CUP_B_UH1D_GER_KSK"               }; // CUP GER (Bundeswehr)
            case "CUP_B_CDF":             { "CUP_B_Mi17_CDF"                   }; // CUP CDF
            case "CUP_B_US_Army":         { "CUP_B_UH60M_FFV_US"               }; // CUP USA (Army - D)
            case "CUP_B_USMC":            { "CUP_B_UH1Y_UNA_USMC"              }; // CUP USA (USMC)
            default                       { "B_Heli_Transport_01_F"            }; // NATO (Default)
        };
    };

    case east:
    {
        switch (faction player) do
        {
            case "OPF_F":                         { "O_Heli_Light_02_F"        }; // CSAT (Default)
            case "rhsgref_faction_chdkz":         { "rhsgref_ins_Mi8amt"       }; // ChDKZ Insurgents
            case "rhs_faction_vdv":               { "rhs_Mi24V_vdv"            }; // RHS Russia (VDV)
            case "rhs_faction_vv":                { "rhs_Mi8mt_vv"             }; // RHS Russia (VV)
            case "rhssaf_faction_army_opfor":     { "rhssaf_airforce_ht48"     }; // RHS SAF OPFOR (KOV)
            case "rhssaf_faction_airforce_opfor": { "rhssaf_airforce_ht48"     }; // RHS SAF OPFOR (RVIPVO)
            case "CUP_O_SLA":                     { "CUP_O_UH1H_SLA"           }; // CUP Sahrani Liberation Army
            case "CUP_O_TK":                      { "CUP_O_Mi17_TK"            }; // CUP Takistani Army
            default                               { "O_Heli_Light_02_F"        }; // CSAT (Default)
        };
    };

    case resistance:
    {
        switch (faction player) do
        {
            case "IND_F":                      { "I_Heli_light_03_F"           }; // AAF (Default)
            case "IND_C_F":                    { "I_C_Heli_Light_01_civil_F"   }; // Syndikat
            case "IND_E_F":                    { "I_E_Heli_light_03_unarmed_F" }; // LDF (Livonian Defense Force)
            case "rhsgref_faction_chdkz_g":    { "rhsgref_ins_Mi8amt"          }; // RHS ChDKZ Insurgents
            case "rhsgref_faction_cdf_air":    { "rhsgref_cdf_Mi35"            }; // RHS Chernarus (Air Force)
            case "rhsgref_faction_cdf_ground": { "rhsgref_cdf_reg_Mi17Sh"      }; // RHS Chernarus (Ground Forces)
            case "rhsgref_faction_un":         { "rhsgref_un_Mi8amt"           }; // RHS Chernarus (UN)
            case "rhssaf_faction_army":        { "rhssaf_airforce_ht48"        }; // RHS SAF (KOV)
            case "rhssaf_faction_airforce":    { "rhssaf_airforce_ht48"        }; // RHS SAF (RVIPVO)
            case "CUP_I_PMC_ION":              { "CUP_I_MH6M_ION"              }; // CUP ION PMC
            case "CUP_I_RACS":                 { "CUP_I_UH60L_FFV_RACS"        }; // CUP RACS
            case "CUP_I_TK_GUE":               { "CUP_I_UH1H_TK_GUE"           }; // CUP Takistani Locals
            case "CUP_I_UN":                   { "CUP_I_Mi17_UN"               }; // CUP United Nations
            default                            { "I_Heli_light_03_F"           }; // AAF (Default)
        };
    };
};

_spawnVehicle = [_spawnPos, _azimuth, _heliClass, side player] call BIS_fnc_spawnVehicle;

_baseMarker = createMarkerLocal ["base_marker", _spawnPos];
_baseMarker setMarkerShapeLocal "ICON";

#ifdef FEEDBACK_MODE
    _baseMarker setMarkerTypeLocal "MIL_FLAG";
    _baseMarker setMarkerColorLocal "ColorWEST";
#else
    _baseMarker setMarkerTypeLocal "Empty";
#endif

_baseMarker setMarkerTextLocal localize "STR_FB_MARKER_HELICOPTERBASE";

_spawnVehicle