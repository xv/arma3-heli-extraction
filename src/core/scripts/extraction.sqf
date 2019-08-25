/*
 * Copyright (c) 2019 Jad Altahan (http://github.com/xv)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "..\component.hpp"

// No transport for the following excluded factions
_excludedFactions = [
    "Gendarmerie",                 // Gendarmerie
    "IND_G_F",                     // GUER FIA
    "OPF_G_F",                     // OPFOR FIA
    "IND_L_F",                     // GUER Looters
    "rhs_faction_usn",             // RHS USA Navy
    "rhs_faction_usaf",            // RHS USAF
    "rhs_faction_msv",             // RHS Russia (MSV)
    "rhs_faction_rva",             // RHS Russia (RVA)
    "rhs_faction_tv",              // RHS Russia (TV)
    "rhs_faction_vmf",             // RHS Russia (VMF)
    "rhs_faction_vpvo",            // RHS Russia (VPVO)
    "rhsgref_faction_cdf_ng",      // RHS GUER Chernarus (National Guard)
    "rhsgref_faction_nationalist", // RHS GUER Nationalist Troops
    "rhssaf_faction_un",           // RHS SAF (UN)
    "CUP_O_TK_MILITIA"             // CUP OPFOR Takistani Militia
];

// For-each looping is not used here since this is much faster!
_denyFaction = _excludedFactions findIf { _x isEqualTo faction player };

if (_denyFaction != -1 || playerSide == civilian) exitWith
{
    hint parseText localize "STR_HT_EXTRACT_UNAVAILABLE";
};

// This variable is defined in init.sqf
trig_execScript setTriggerText "NULL";

isMarkerDetected = false;

sleep 0.3;

player sideRadio "RadioBeepFrom";
player sideChat format [localize "STR_RC_REQUEST_EXTRACT", name player, mapGridPosition player];

sleep 10;

[playerSide, "HQ"] sideRadio "RadioBeepTo";
[playerSide, "HQ"] sideChat format [localize "STR_RC_AFFIRM_EXTRACT", name player];

markerMags = call xv_fnc_getMarkerMags;
isMarkerDetected = false;

player addEventHandler ["Take",
{
    params ["_unit", "_container", "_item"];

    _isMag = isClass (configFile >> "CfgMagazines" >> _item);
    _canUseMag = _isMag && ([_item] call xv_fnc_canUseGLMag);

    if (_canUseMag) then
    {
        markerMags pushBackUnique _item;

        #ifdef FEEDBACK_MODE
            systemChat format [localize "STR_FB_TAKEN_ITEM_PUSHED", _item];
        #endif
    };
}];

// Create a marker where the smoke grenade lands
player addEventHandler ["Fired",
{
    if !((_this select 5) in markerMags) exitWith
    {
        #ifdef FEEDBACK_MODE
            systemChat format [localize "STR_FB_FIRED_WRONG_OBJECT", _this select 5];
        #endif
    };
    
    _null = _this spawn
    {
        params [
            "_unit",
            "_weapon",
            "_muzzle",
            "_mode",
            "_ammo",
            "_magazine",
            "_projectile",
            "_vehicle"
        ];

        _projectile = _this select 6;

        // Proceed only when the grenade has come to a stop
        waitUntil { (vectorMagnitude velocity _projectile < 0.02) };

        // Create a marker icon on the map to identify the extraction point
        [getPos _projectile] call xv_fnc_markExtractionZone;

        throwablePos = [_projectile, 15, 100, "I_Heli_Transport_02_F"] call xv_fnc_findLandingPos;
        isMarkerDetected = true;

        markerMags = nil;
        player removeEventHandler ["Fired", 0];
        player removeEventHandler ["Take", 0];
    };
}];

waitUntil { isMarkerDetected };

private "_helipadClass";

#ifndef FEEDBACK_MODE
    _helipadClass = "Land_HelipadEmpty_F";
#else
    _helipadClass = "Land_HelipadCircle_F";
#endif

hiddenHelipad = createVehicle [_helipadClass, throwablePos, [], 0, "NONE"];

isMarkerDetected = false;

extractPos = getPosASL hiddenHelipad;

sleep 1;

/* LEGACY ARMA II CODE. NOT REQUIRED IN ARMA 3
 * ===========================================
 * FNC_Spawn=[] spawn
 * {
 *     if (isNil "BIS_fnc_init") then
 *     {
 *         _side  = createCenter sideLogic;
 *         _group = createGroup _side;
 *         _logic = _group createUnit ["FunctionsManager", [0, 0, 0], [], 0, "NONE"];
 *     };
 * };
 * waitUntil { BIS_fnc_init };
 */

spawnDir = random 360; // Spawn the helicopter at a random direction
spawnRange = 2500;     // Time it will take until the helicopter arrives at the marked location
spawnPos =
[
    (extractPos select 0) + (spawnRange * sin(spawnDir)), 
    (extractPos select 1) + (spawnRange * cos(spawnDir)), 
    (extractPos select 2) + 80
];

azimuth = spawnPos getDir extractPos;

/* Spawn a different helicopter depending on the player's faction.
 *
 * You can modify the helicopter class names to any helicopter model you want,
 * whether it's vanilla or user-made.
 */
heliClass = switch (playerSide) do
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

boardingDetected = false;
heliDestroyed = false;

fn_monitorVehicleStatus =
{
    params ["_veh"];

    #ifdef FEEDBACK_MODE
        systemChat format [localize "STR_FB_MONITOR_VEHICLE_STATUS", _veh];
    #endif

    // In case the helicopter is immobalized but not destroyed
    _veh addEventHandler ["Dammaged",
    {
        _obj = _this select 0;

        if (!canMove _obj) then
        {
            _obj removeEventHandler ["Dammaged", 0];

            /* If we just mark the helicopter destroyed via <heliDestroyed = true>
             * but don't actually destroy it, the crew will exit the vehicle and
             * do nothing for eternity. The script will end, however.
             *
             * Maybe one day we can revisit this code and write a more complex
             * scenario where a rescue helicopter gets dispatched to get the
             * stranded crew if they are not dead?
             */
            // heliDestroyed = true;
            _obj setDamage 1;

            #ifdef FEEDBACK_MODE
                systemChat localize "STR_FB_EVENT_HELI_IMMOBALIZED";
            #endif
        };
    }];

    // Helicopter is blown up
    _veh addEventHandler ["Killed",
    {
        heliDestroyed = true;

        #ifdef FEEDBACK_MODE
            systemChat localize "STR_FB_EVENT_HELI_DESTROYED";
        #endif
    }];

    _veh addEventHandler ["GetIn",
    {
        boardingDetected = true;
    }];

    // Deploy countermeasures in case the helicopter gets fired at with AA missiles
    // Note: The AI in Arma 3 seems to be smart enough to do it themselves
    _veh addEventHandler ["IncomingMissile",
    {
        fn_dropFlares =
        {
            flares = 0;
            while { alive _veh && flares < 6 } do
            {
                if ((_veh ammo "CMFlareLauncher") == 0) then
                {
                    _veh addMagazineTurret ["120Rnd_CMFlare_Chaff_Magazine", [-1], 20];
                    reload _veh;
                };
                
                _veh action ["useWeapon", _veh, driver _veh, 0];
                flares = flares + 1;
            };
        };
        call fn_dropFlares;
    }];
};

// Spawn the helicopter
fncSpawnVehicle = [spawnPos, azimuth, heliClass, side player] call BIS_fnc_spawnVehicle;
sleep 0.1;

heli = fncSpawnVehicle select 0;
heli call fn_monitorVehicleStatus;

_heliVelocity = velocity heli;
_heliDir = direction heli;
heli setVelocity
[
    (_heliVelocity select 0) + (sin _heliDir * 30), 
    (_heliVelocity select 1) + (cos _heliDir * 30), 
    (_heliVelocity select 2)
];

// heliPilot = (fncSpawnVehicle select 1) select 0;
// heliCopilot = (fncSpawnVehicle select 1) select 1;

heli setBehaviour "CARELESS";
heli setSpeedMode "NORMAL";
heli setCombatMode "GREEN";

heli enableCopilot false;
heli lockDriver true;

/* Comment out the line of code below to disable invincibility.
 *
 * Note: if the helicopter gets damaged to a point where it becomes inoperable
 * or even destroyed, the script will detect that and will let you know that it
 * has been destroyed. In that case, you will no longer be able to request
 * another ride.
 */
{ _x allowDamage false; } foreach [heli] + crew heli;

/* Uncomment the line of code below to make enemy AI ignore the helicopter.
 * 
 * if setCaptive is set to true, enemy AI will not fire at the helicopter as if
 * it is one of their own. However, they may still fire at the player if spotted.
 */
// heli setCaptive true;

/* For a touch of realism, open the Black Hawk doors.
 *
 * TODO: RHS automatically closes the cargo doors after getting in. Find way
 * (if there's any?) to keep the cargo doors open.
 */
if (typeOf heli find "RHS_UH60M" >= 0) then
{
    [heli, true, 1] call xv_fnc_animateCargoDoors;
};

sleep 4;

[playerSide, "HQ"] sideRadio "RadioBeepTo";
[playerSide, "HQ"] sideChat format[localize "STR_RC_COORDINATES_RECEIVED", name player];

// Move to LZ
[heli, extractPos] call xv_fnc_wpMoveToExtractionZone;
sleep 1;

while { ((canMove heli) && !(unitReady heli)) } do
{
    sleep 1;
};

if (canMove heli) then
{
    // Precisely check if the helicopter landed and came to a complete stop    
    waitUntil
    {
        heliDestroyed || ((velocity  heli select 2) > -0.2 &&
                          (getPosATL heli select 2) <  0.5)
    };

    if (heliDestroyed) exitWith { };

    "extraction_marker" setMarkerPosLocal heli;
    
    sleep 0.7;
    
    if (typeOf heli == "B_Heli_Transport_01_F" ||
        typeOf heli == "B_CTRG_Heli_Transport_01_sand_F") then
    {
        [heli, false, 1] call xv_fnc_animateCargoDoors;
    };

    _timeTillRtb = 85; // 1m:25s
    while { !heliDestroyed && (_timeTillRtb > 0) } do
    {
        hintSilent parseText format
        [
            localize "STR_HT_DUSTOFF_TIMER",
            [_timeTillRtb / 60 + 0.01, "HH:MM"] call BIS_fnc_timeToString
        ];
        
        _timeTillRtb = _timeTillRtb - 1;

        if (((getPosATL vehicle player) select 2 <= 1) && 
            (player distance2D heli <= 25) && (isNull objectParent player)) exitWith
        {
            #ifdef FEEDBACK_MODE
                systemChat localize "STR_FB_PLAYER_LZ_DISTANCE";
            #endif

            hint localize "STR_HT_BOARD_HELI";
        };

        // Abort timer if a squad mate enters the helicopter before the player
        if (boardingDetected && !(player in heli)) exitWith
        {
            #ifdef FEEDBACK_MODE
                systemChat localize "STR_FB_BOARDING_DETECTED"; 
            #endif

            if (count units (group player) > 1) then {
                hint localize "STR_HT_UNITS_BOARDING";
            };
        };

        sleep 1;

        if (_timeTillRtb < 1) exitWith
        {
            heli lock true;

            hint parseText localize "STR_HT_MISSED_EXTRACT";

            sleep 1.5;

            [playerSide, "HQ"] sideRadio "RadioBeepTo";
            [playerSide, "HQ"] sideChat format [localize "STR_RC_MISSED_EXTRACT", name player];

            deleteMarkerLocal "extraction_marker";
            [heli, spawnPos] call xv_fnc_wpReturnToBase;
        };
    };

    // If the extraction is missed, exit the current scope immediately
    if (waypointName [group heli, 2] isEqualTo "wpRtb") exitWith { };
    
    // Make sure that the player and all associated units have boarded the helicopter
    waitUntil
    {
        heliDestroyed ||
        { _x in heli } count (units group player) == count (units group player);
    };

    if (heliDestroyed) exitWith { };

    // Lock the doors to prevent the player from ejecting and going off the script scenario
    heli lock true;
    
    sleep 0.5;
    
    deleteMarkerLocal "extraction_marker";
    [playerSide, "HQ"] sideRadio "RadioBeepTo";
    [playerSide, "HQ"] sideChat localize "STR_RC_BOARDING_WELCOME";

    hintSilent localize "STR_HT_MARK_DROPOFF";

    [getPos heli, 1000] call xv_fnc_markDropOffRange;

    sleep 1.7;
    
    // Open the map to mark a drop off location
    openMap true;

    sleep 0.1;

    isMapPosValid = false;

    sleep 0.3;

    player onMapSingleClick
    {
        if (heli distance _pos < 1000) then {
            hint localize "STR_HT_DROPOFF_RANGE";
        } else {
            [_pos] call xv_fnc_markDropOffZone;
            isMapPosValid = true;

            deleteMarkerLocal "range_marker";
        };
    };

    waitUntil { heliDestroyed || isMapPosValid };

    if (heliDestroyed) exitWith { };

    sleep 0.05;

    player onMapSingleClick "nil";

    hintSilent localize "STR_HT_DROPOFF_MARKED";

    hiddenHelipad setVehiclePosition [getMarkerPos "dropoff_marker", [], 0, "NONE"];

    dropOffPos = getPosASL hiddenHelipad;

    sleep 1;

    // Close the map after the drop off location has been marked
    openMap false;

    sleep 3;

    // Move to the drop off (insertion) zone
    [heli, dropOffPos] call xv_fnc_wpMoveToDropOffZone;
};

sleep 1;

// Check if the helicopter has reached the drop off location
while { ((canMove heli) && !(unitReady heli)) } do
{
    sleep 1;
};

// Order the helicopter to land
if (canMove heli) then
{
    waitUntil
    {
        heliDestroyed || ((velocity  heli select 2) > -0.2 && 
                          (getPosATL heli select 2) <  0.5)
    };

    if (heliDestroyed) exitWith { };
    
    [playerSide,"HQ"] sideRadio "RadioBeepTo";
    [playerSide,"HQ"] sideChat "Touchdown!";
    
    // Unlock the helicopter doors
    heli lock false;
    
    // Make sure that the player and all associated units have left the helicopter
    waitUntil
    {
        heliDestroyed ||
        ({ _x in heli } count (units group player) == 0 && (player distance2D heli >= 5))
    };
    
    if (heliDestroyed) exitWith { };

    // TODO: maybe continue allowing destruction? That'll require constant checking
    { _x allowDamage false } foreach [heli] + crew heli;

    // Lock the doors
    heli lock true;
    
    sleep 0.5;

    deleteMarkerLocal "dropoff_marker";

    sleep 3;

    // Make the helicopter return to where it came form and delete it
    [heli, spawnPos] call xv_fnc_wpReturnToBase;
};

if (heliDestroyed) exitWith {
    hint parsetext localize "STR_HT_HELI_DESTROYED";
    
    // Ensure the map markers are deleted
    deleteMarkerLocal "extraction_marker";
    deleteMarkerLocal "dropoff_marker";
};