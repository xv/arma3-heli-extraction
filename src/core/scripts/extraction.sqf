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

// For developing/testing, enable this switch if you want to see some feedback
// messages while the script is running
feedbackMode = false;

denyFaction = false;

// No transport for the following excluded factions
excludedFactions = [
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
{ 
    if (_x == faction player) exitWith
    {
        denyFaction = true;
    };
} forEach excludedFactions;

if (denyFaction || playerSide == civilian) exitWith
{
    hint parseText "<t align='left' color='#F98A02' size='1'>Helicopter extraction is not available for your faction.</t>";
    denyFaction = nil;
};

// This variable is defined in init.sqf
trig_execScript setTriggerText "NULL";

isMarkerDetected = false;

sleep 0.1;

extractMarker = createMarkerLocal ["extraction_marker", [0, 0]];
gridPos = mapGridPosition getPos player;

sleep 0.3;

player sideRadio "radio_beep_from";
player sideChat format ["VALOR-20 this is %1, requesting immediate extraction. Location is at grid %2, over.", name player, gridPos];

sleep 10;

[playerSide,"HQ"] sideRadio "radio_beep_to";
[playerSide,"HQ"] sideChat format["%1 this is VALOR-20, affirmative on the extraction. Mark the LZ, over.", name player];

private ["_grenadeToThrow", "_isSmokeGrenade"];
throwableMag = [];

if (sunOrMoon >= 1) then
{
    _isSmokeGrenade = true;

    throwableMag = [
        "SmokeShellRed",
        "SmokeShellGreen",
        "SmokeShellYellow",
        "SmokeShellPurple",
        "SmokeShellBlue",
        "SmokeShellOrange",
        "rhs_mag_nspd",
        "rhs_mag_m18_red",
        "rhs_mag_m18_green",
        "rhs_mag_m18_yellow",
        "rhs_mag_m18_purple",
        "rhssaf_mag_brd_m83_red",
        "rhssaf_mag_brd_m83_green",
        "rhssaf_mag_brd_m83_yellow",
        "rhssaf_mag_brd_m83_blue",
        "rhssaf_mag_brd_m83_orange"
    ];
}
else
{
    _isSmokeGrenade = false;

    throwableMag = [
        "B_IR_Grenade", // NATO (BLUFOR)
        "O_IR_Grenade", // CSAT (OPFOR)
        "I_IR_Grenade"  // AAF (GUER)
    ];
};

{ 
    if (_x in (magazines player)) exitWith 
    { 
        if (_isSmokeGrenade) then {
            hint parseText "<t align='left'>Use one of the <t underline='1'>colored</t> smoke grenades in your inventory to mark the LZ.</t>";
        } else {
            hint parseText "<t align='left'>Use the <t underline='1'>infrared (IR)</t> grenade in your inventory to mark the LZ.</t>";
        };

        _grenadeToThrow = _x;
    };
} forEach throwableMag;

sleep 0.1;

if (isNil "_grenadeToThrow") then
{

    if (_isSmokeGrenade) then
    {
        _grenadeToThrow = throwableMag select 3;
    }
    else
    {
        _grenadeToThrow = switch (playerSide) do
        {
            case west:       { throwableMag select 0 };
            case east:       { throwableMag select 1 };
            case resistance: { throwableMag select 2 };
        };
    };

    if (player canAdd _grenadeToThrow) then
    {
        player addMagazine _grenadeToThrow;
    }
    else
    {
        hint "Free up some inventory space in order to receive an item to mark the LZ.";

        waitUntil { (player canAdd _grenadeToThrow) };
        sleep 1;

        player addMagazine _grenadeToThrow;
    };

    if (_isSmokeGrenade) then {
        hint parseText "<t align='left'>A <t color='#BA55D3'>purple smoke</t> grenade has been added to your inventory. Use it to mark the LZ.</t>";
    } else {
        hint parseText "<t align='left'>An <t color='#DB7093'>infrared (IR)</t> grenade has been added to your inventory. Use it to mark the LZ.</t>";
    };
};

fn_findLandingPos =
{
    params ["_object", "_minDist", "_maxDist", "_vehicle"];

    _returnPos = (getPos _object) findEmptyPosition [_minDist, _maxDist, _vehicle];

    if (_returnPos isEqualTo []) then
    {
        if (feedbackMode) then {
            systemChat "Failed to find an empty position. Using the default one...";
        };

        _returnPos = getPos _object;
    };

    _returnPos
};

// Create a marker where the smoke grenade lands
eh_detectSmoke = player addEventHandler ["Fired",
{
    if !((_this select 5) in throwableMag) exitWith
    {
        if (feedbackMode) then
        {
            systemChat format ["Fired or thrown the wrong object (%1).", _this select 5];
        };
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
        waitUntil { vectorMagnitude velocity _projectile < 0.02 };

        // Create a marker icon on the map to identify the extraction point
        extractMarker setMarkerPosLocal _projectile;
        extractMarker setMarkerShapelocal "ICON";
        extractMarker setMarkerTypelocal "MIL_PICKUP";
        extractMarker setMarkerColorlocal "ColorBlack";
        extractMarker setMarkerText "Extraction";

        throwablePos = [_projectile, 15, 100, "I_Heli_Transport_02_F"] call fn_findLandingPos;
        isMarkerDetected = true;

        throwableMag = nil;
        player removeEventHandler ["Fired", 0];
    };
}];

waitUntil { isMarkerDetected };

private "_helipadClass";

if (feedbackMode) then { 
    _helipadClass = "Land_HelipadCircle_F";
} else {
    _helipadClass = "Land_HelipadEmpty_F";
};

hiddenHelipad = createVehicle [_helipadClass, throwablePos, [], 0, "NONE"];

isMarkerDetected = false;

targetPos = getPosASL hiddenHelipad;

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
    (targetPos select 0) + (spawnRange * sin(spawnDir)), 
    (targetPos select 1) + (spawnRange * cos(spawnDir)), 
    (targetPos select 2) + 40
];

vecDir = [spawnPos, targetPos] call BIS_fnc_dirTo;

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
            case "OPF_F":                 { "O_Heli_Light_02_F"                }; // CSAT (Default)
            case "rhsgref_faction_chdkz": { "rhsgref_ins_Mi8amt"               }; // ChDKZ Insurgents
            case "rhs_faction_vdv":       { "rhs_Mi24V_vdv"                    }; // RHS Russia (VDV)
            case "rhs_faction_vv":        { "rhs_Mi8mt_vv"                     }; // RHS Russia (VV)
            case "CUP_O_SLA":             { "CUP_O_UH1H_SLA"                   }; // CUP Sahrani Liberation Army
            case "CUP_O_TK":              { "CUP_O_Mi17_TK"                    }; // CUP Takistani Army
            default                       { "O_Heli_Light_02_F"                }; // CSAT (Default)
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

fn_animateHeliDoors =
{
    params ["_isRHS", "_state"];

    _doorLeftClass = "door_L";
    _doorRightClass = "door_R";

    if (_isRHS) then
    {
        _doorLeftClass = "doorLB";
        _doorRightClass = "doorRB";
    };

    heli animateDoor [_doorLeftClass, _state];
    heli animateDoor [_doorRightClass, _state];
};

// Spawn the helicopter
fncSpawnVehicle = [spawnPos, vecDir, heliClass, side player] call BIS_fnc_spawnVehicle;
heli = fncSpawnVehicle select 0;
heliPilot = (fncSpawnVehicle select 1) select 0;

if (typeOf heli find "RHS_UH60M" >= 0) then
{
    [true, 1] call fn_animateHeliDoors;
};

sleep 4;

[playerSide,"HQ"] sideRadio "radio_beep_to";
[playerSide,"HQ"] sideChat format["%1 this is VALOR-20, coordinates received. ETA is 1 minute. Standby.", name player];

heli setBehaviour  "CARELESS";
heli setSpeedMode  "NORMAL";
heli setCombatMode "GREEN";

heli enableCopilot false;
heli lockDriver true;

/* Comment line below to disable invincibility.
 *
 * Note that when you request the helicopter in a hot zone, the enemy AI will
 * shoot at it. If the helicopter gets fired at with AA missiles, it will deploy
 * countermeasures; however, it's impossible to evade all the missiles with
 * flares/chaffs. In case the helicopter gets destroyed, you will not be able to
 * request another. This is NOT a bug. The script was written to function this
 * way. Use at your own risk!
 */
{ _x allowDamage false; } foreach [heli] + crew heli;

/* Uncomment the line below to make enemy AI ignore the helicopter.
 * 
 * if setCaptive is set to true, enemy AI will not fire anything at the helicopter
 * as if it is one of their own. However, they may still fire at the player if
 * spotted.
 */
// heli setCaptive true;

heli setPosATL
[
    (getPosATL heli select 0), 
    (getPosATL heli select 1),
    (getPosATL heli select 2) + 40
];

heliDir = direction heli;
heli setVelocity
[
    sin ((heliDir) * 30),
    cos ((heliDir) * 30), 0
];

// Orders the helicopter to move to the extraction zone
fn_heliMoveToLZ =
{
    _wpExtractZone = (group heli) addWaypoint [targetPos, 0];
    _wpExtractZone setWaypointType "MOVE";
    _wpExtractZone setWaypointSpeed "NORMAL";
    _wpExtractZone setWaypointDescription "Extraction zone";
    _wpExtractZone setWaypointStatements ["true", "heli land 'GET IN';"];
};

// Orders the helicopter to move to the drop off (insertion) zone
fn_heliMoveToDropOffZone =
{
    _wpDropZone = (group heli) addWaypoint [dropOffPos, 1];
    _wpDropZone setWaypointType "MOVE";
    _wpDropZone setWaypointSpeed "NORMAL";
    _wpDropZone setWaypointDescription "Drop off zone";
    _wpDropZone setWaypointStatements ["true", "heli land 'GET OUT';"];
};

// Orders the helicopter fly back to the original spawn location
fn_heliReturnHome =
{
    _wpRtb = (group heli) addWaypoint [spawnPos, 2];
    _wpRtb setWaypointType "MOVE";

    // Delete the helicopter + crew and clean up the script for usage again
    _wpRtb setWaypointStatements
    [
        "true",
        "{deletevehicle _x} foreach (crew vehicle this + [vehicle this]);
         trig_execScript setTriggerText 'Request Extraction';
         deleteVehicle hiddenHelipad;
         _grenadeToThrow = nil;"
    ];
};

call fn_heliMoveToLZ;
sleep 1;

boardingDetected = false;

fn_monitorVehicleStatus =
{
    params ["_veh"];

    if (feedbackMode) then {
        systemChat format ["Monitoring vehicle status for '%1'...", _veh];
    };

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
heli call fn_monitorVehicleStatus;

fn_markDropOffRange =
{
    params ["_range"];

    rangeMarker = createMarkerLocal ["range_marker", getPos heli];
    rangeMarker setMarkerSize [_range, _range];
    rangeMarker setMarkerShape "ELLIPSE";
    rangeMarker setMarkerColor "colorRed";
    rangeMarker setMarkerBrush "SolidBorder";
    rangeMarker setMarkerAlpha 0.12;
};

while { ((alive heli) && !(unitReady heli)) } do
{
    sleep 1;
};

if (alive heli) then
{
    // Precisely check if the helicopter landed and came to a complete stop    
    waitUntil
    {
        (velocity  heli select 2) > -0.2 &&
        (getPosATL heli select 2) <  0.5
    };

    extractMarker setMarkerPosLocal heli;
    
    sleep 0.7;
    
    if (typeOf heli == "B_Heli_Transport_01_F" ||
        typeOf heli == "B_CTRG_Heli_Transport_01_sand_F") then
    {
        [false, 1] call fn_animateHeliDoors;
    };

    _timeTillRtb = 85; // 1m:25s
    while { (_timeTillRtb > 0) } do
    {
        hintSilent parseText format ["Time until dust off: <t color='#CD5C5C'>%1</t>", [_timeTillRtb / 60 + 0.01, "HH:MM"] call BIS_fnc_timeToString];
        _timeTillRtb = _timeTillRtb - 1;

        if (((getPosATL vehicle player) select 2 <= 1) && 
            (player distance2D heli <= 25) && (isNull objectParent player)) exitWith
        {
            if (feedbackMode) then {
                systemChat "Your are within 25 metres from the extraction zone. Aborting countdown...";
            };

            hint "Board the helocopter.";
        };

        // Abort timer if a squad mate enters the helicopter before the player
        if (boardingDetected && !(player in heli)) exitWith
        {
            if (feedbackMode) then {
                systemChat "Boarding has been detected. Aborting countdown..."; 
            };

            if (count units (group player) > 1) then {
                hint "All units must board the helicopter before extraction!";
            };
        };

        sleep 1;

        if (_timeTillRtb < 1) exitWith
        {
            heli lock true;

            hint parseText "<t color='#DC143C'>You missed the extraction helicopter!</t>";

            sleep 1.5;

            [playerSide,"HQ"] sideRadio "radio_beep_to";
            [playerSide,"HQ"] sideChat format["%1 this is VALOR-20, we cannot hold the extraction any longer. We are RTB, out.", name player];

            deleteMarkerLocal extractMarker;
            call fn_heliReturnHome;
        };
    };
    
    // Make sure that the player and all associated units have boarded the helicopter
    waitUntil
    {
        { _x in heli } count units group player == count units group player
    };
    
    // Lock the doors to prevent the player from ejecting and going off the script scenario
    heli lock true;
    
    sleep 0.5;
    
    deleteMarkerLocal extractMarker;
    [playerSide,"HQ"] sideRadio "radio_beep_to";
    [playerSide,"HQ"] sideChat "Welcome aboard! Mark your drop off location on the map.";

    hintSilent "Mark your drop off location by clicking on the map.";

    [1000] call fn_markDropOffRange;

    sleep 1.7;
    
    // Open the map to mark a drop off location
    openMap true;

    sleep 0.1;

    dropOffMarker = createMarkerLocal ["dropoff_marker", [0, 0]];
    isMapPosValid = false;

    sleep 0.3;

    player onMapSingleClick
    {
        if (heli distance _pos < 1000) then {
            hint "The drop off location needs to be at least 1 kilometre from your current position.";
        } else {
            dropOffMarker setMarkerPosLocal _pos;
            isMapPosValid = true;
        };
    };

    waitUntil { isMapPosValid };

    // Create a marker icon on the map to identify the drop off point
    dropOffMarker setMarkerShapelocal "ICON";
    dropOffMarker setMarkerTypelocal "MIL_END";
    dropOffMarker setMarkerColorlocal "ColorBlack";
    dropOffMarker setMarkerText "Drop Off";

    sleep 0.05;

    player onMapSingleClick "nil";

    hintSilent "Drop off location has been marked.";

    hiddenHelipad setVehiclePosition [getMarkerPos dropOffMarker, [], 0, "NONE"];

    dropOffPos = getPosASL hiddenHelipad;

    sleep 1;

    // Close the map after the drop off location has been marked
    openMap false;

    deleteMarkerLocal rangeMarker;

    sleep 3;

    call fn_heliMoveToDropOffZone;
};

sleep 1;

// Check if the helicopter has reached the drop off location
while { ((alive heli) && !(unitReady heli)) } do
{
    sleep 1;
};

// Order the helicopter to land
if (alive heli) then
{
    waitUntil
    {
        (velocity  heli select 2) > -0.2 && 
        (getPosATL heli select 2) <  0.5
    };
    
    [playerSide,"HQ"] sideRadio "radio_beep_to";
    [playerSide,"HQ"] sideChat "Touchdown!";
    
    // Unlock the helicopter doors
    heli lock false;    
    
    // Make sure that the player and all associated units have left the helicopter
    waitUntil
    {
        { _x in heli } count units group player == 0 &&
        player distance2D heli >= 5
    };
    
    // Lock the doors
    heli lock true;
    
    sleep 0.5;

    deleteMarkerLocal dropOffMarker;
};

sleep 3;
call fn_heliReturnHome;
