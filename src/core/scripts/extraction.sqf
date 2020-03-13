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

if (!(isNull objectParent player) && 
     (objectParent player isKindOf "air")) exitWith
{
    hint parseText localize "STR_HT_PLAYER_BAD_VEHICLE";
};

// This variable is defined in init.sqf
trig_execScript setTriggerText "NULL";

sleep 0.3;

player sideRadio "RadioBeepFrom";
player sideChat format [localize "STR_RC_REQUEST_EXTRACT", name player, mapGridPosition player];

sleep 10;

[playerSide, "HQ"] sideRadio "RadioBeepTo";
[playerSide, "HQ"] sideChat format [localize "STR_RC_AFFIRM_EXTRACT", name player];

markerMags = call xv_fnc_getMarkerMags;

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
        waitUntil
        {
            sleep 0.6;
            (vectorMagnitude velocity _projectile < 0.02)
        };

        // Create a marker icon on the map to identify the extraction point
        [getPos _projectile] call xv_fnc_markExtractionZone;

        throwablePos = [_projectile, 15, 100, "I_Heli_Transport_02_F"] call xv_fnc_findLandingPos;

        markerMags = nil;
        player removeEventHandler ["Fired", 0];
        player removeEventHandler ["Take", 0];
    };
}];

waitUntil
{ 
    sleep 1;
    !(markerType "extraction_marker" isEqualTo "")
};

private "_helipadClass";

#ifndef FEEDBACK_MODE
    _helipadClass = "Land_HelipadEmpty_F";
#else
    _helipadClass = "Land_HelipadCircle_F";
#endif

hiddenHelipad = createVehicle [_helipadClass, throwablePos, [], 0, "NONE"];

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
_spawnHeli = [extractPos, EXTRACT_HELI_SPAWN_DISTANCE, random 360, 80] call xv_fnc_spawnHelicopter;

sleep 0.1;

_heli = _spawnHeli select 0;
_heli call fn_monitorVehicleStatus;

_heliVelocity = velocity _heli;
_heliDir = direction _heli;
_heli setVelocity
[
    (_heliVelocity select 0) + (sin _heliDir * 30), 
    (_heliVelocity select 1) + (cos _heliDir * 30), 
    (_heliVelocity select 2)
];

// heliPilot = (_spawnHeli select 1) select 0;
// heliCopilot = (_spawnHeli select 1) select 1;

_heli setBehaviour "CARELESS";
_heli setSpeedMode "NORMAL";
_heli setCombatMode "GREEN";

_heli enableCopilot false;
_heli lockDriver true;

/* If the helicopter gets damaged to a point where it becomes inoperable
 * or even destroyed, the script will detect that and will let you know that it
 * has been destroyed. In that case, you will no longer be able to request
 * another ride.
 */
#ifdef EXTRACT_HELI_INVINCIBLE
    { _x allowDamage false; } foreach [_heli] + crew _heli;
#endif

/* Uncomment the line of code below to make enemy AI ignore the helicopter.
 * 
 * if setCaptive is set to true, enemy AI will not fire at the helicopter as if
 * it is one of their own. However, they may still fire at the player if spotted.
 */
// _heli setCaptive true;

/* For a touch of realism, open the Black Hawk doors.
 *
 * TODO: RHS automatically closes the cargo doors after getting in. Find way
 * (if there's any?) to keep the cargo doors open.
 */
if (typeOf _heli find "RHS_UH60M" >= 0) then
{
    [_heli, true, 1] call xv_fnc_animateCargoDoors;
};

sleep 4;

[playerSide, "HQ"] sideRadio "RadioBeepTo";
[playerSide, "HQ"] sideChat format[localize "STR_RC_COORDINATES_RECEIVED", name player];

// Move to LZ
[_heli, extractPos] call xv_fnc_wpMoveToExtractionZone;
sleep 1;

while { ((canMove _heli) && !(unitReady _heli)) } do
{
    sleep 1;
};

if (canMove _heli) then
{
    // Precisely check if the helicopter landed and came to a complete stop    
    waitUntil
    {
        heliDestroyed || ((velocity  _heli select 2) > -0.2 &&
                          (getPosATL _heli select 2) <  0.5)
    };

    if (heliDestroyed) exitWith { };

    "extraction_marker" setMarkerPosLocal _heli;
    
    sleep 0.7;
    
    if (typeOf _heli == "B_Heli_Transport_01_F" ||
        typeOf _heli == "B_CTRG_Heli_Transport_01_sand_F") then
    {
        [_heli, false, 1] call xv_fnc_animateCargoDoors;
    };

    _timeTillRtb = EXTRACT_HELI_DUSTOFF_TIMER;
    while { !heliDestroyed && (_timeTillRtb > 0) } do
    {
        hintSilent parseText format
        [
            localize "STR_HT_DUSTOFF_TIMER",
            [_timeTillRtb / 60 + 0.01, "HH:MM"] call BIS_fnc_timeToString
        ];
        
        _timeTillRtb = _timeTillRtb - 1;

        if (((getPosATL vehicle player) select 2 <= 1) && 
            (player distance2D _heli <= 25) && (isNull objectParent player)) exitWith
        {
            #ifdef FEEDBACK_MODE
                systemChat localize "STR_FB_PLAYER_LZ_DISTANCE";
            #endif

            hint localize "STR_HT_BOARD_HELI";
        };

        // Abort timer if a squad mate enters the helicopter before the player
        if (boardingDetected && !(player in _heli)) exitWith
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
            _heli lock true;

            hint parseText localize "STR_HT_MISSED_EXTRACT";

            sleep 1.5;

            [playerSide, "HQ"] sideRadio "RadioBeepTo";
            [playerSide, "HQ"] sideChat format [localize "STR_RC_MISSED_EXTRACT", name player];

            deleteMarkerLocal "extraction_marker";
            [_heli, markerPos "base_marker"] call xv_fnc_wpReturnToBase;
        };
    };

    // If the extraction is missed, exit the current scope immediately
    if (waypointName [group _heli, 2] isEqualTo "wpRtb") exitWith { };
    
    // Make sure that the player and all associated units have boarded the helicopter
    waitUntil
    {
        heliDestroyed ||
        { _x in _heli } count (units group player) == count (units group player);
    };

    if (heliDestroyed) exitWith { };

    // Lock the doors to prevent the player from ejecting and going off the script scenario
    _heli lock true;
    
    sleep 0.5;
    
    deleteMarkerLocal "extraction_marker";
    [playerSide, "HQ"] sideRadio "RadioBeepTo";
    [playerSide, "HQ"] sideChat localize "STR_RC_BOARDING_WELCOME";

    hintSilent localize "STR_HT_MARK_DROPOFF";

    [getPos _heli, DROPOFF_RANGE_MIN_RADIUS] call xv_fnc_markDropOffRange;

    sleep 1.7;
    
    // Open the map to mark a drop off location
    openMap true;

    sleep 0.1;

    isMapPosValid = false;

    sleep 0.3;

    heliPos = position _heli;

    player onMapSingleClick
    {
        if (heliPos distance _pos < DROPOFF_RANGE_MIN_RADIUS) then {
            hint localize "STR_HT_DROPOFF_RANGE";
        } else {
            [_pos] call xv_fnc_markDropOffZone;
            isMapPosValid = true;
            heliPos = nil;

            deleteMarkerLocal "range_marker";

            /* If the player's drop off position, by some chance, happens to be
             * within 500 meters from the helicopter spawn position, move away
             * the its spawn position a little so that the player doesn't see
             * the helicopter getting magically deleted (script end).
             */
            if ((markerPos "dropoff_marker" distance markerPos "base_marker") <= 500) then
            {
                _rand = [1500, 2000, true] call xv_fnc_getRandBetween;
                "base_marker" setMarkerPosLocal
                [
                    ((markerPos "dropoff_marker") select 0) + _rand,
                    ((markerPos "dropoff_marker") select 1) + _rand,
                    0
                ];
            };
        };
    };

    waitUntil { heliDestroyed || isMapPosValid };

    isMapPosValid = nil;

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
    [_heli, dropOffPos] call xv_fnc_wpMoveToDropOffZone;
};

sleep 1;

// Check if the helicopter has reached the drop off location
while { ((canMove _heli) && !(unitReady _heli)) } do
{
    sleep 1;
};

// Order the helicopter to land
if (canMove _heli) then
{
    waitUntil
    {
        heliDestroyed || ((velocity  _heli select 2) > -0.2 && 
                          (getPosATL _heli select 2) <  0.5)
    };

    if (heliDestroyed) exitWith { };
    
    [playerSide,"HQ"] sideRadio "RadioBeepTo";
    [playerSide,"HQ"] sideChat "Touchdown!";
    
    // Unlock the helicopter doors
    _heli lock false;
    
    // Make sure that the player and all associated units have left the helicopter
    waitUntil
    {
        heliDestroyed ||
        ({ _x in _heli } count (units group player) == 0 && (player distance2D _heli >= 5))
    };
    
    if (heliDestroyed) exitWith { };

    // TODO: maybe continue allowing destruction? That'll require constant checking
    { _x allowDamage false } foreach [_heli] + crew _heli;

    // Lock the doors
    _heli lock true;
    
    sleep 0.5;

    deleteMarkerLocal "dropoff_marker";

    sleep 3;

    // Make the helicopter return to where it came form and delete it
    [_heli, markerPos "base_marker"] call xv_fnc_wpReturnToBase;
};

if (heliDestroyed) exitWith
{
    hint parsetext localize "STR_HT_HELI_DESTROYED";
    
    // Ensure the map markers are deleted
    deleteMarkerLocal "extraction_marker";
    deleteMarkerLocal "dropoff_marker";
    deleteMarkerLocal "base_marker";
};