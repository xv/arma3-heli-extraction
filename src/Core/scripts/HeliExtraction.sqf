/*
 * Copyright (c) 2018 Jad Altahan (http://github.com/xv)
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

denyFaction = false;

// No transport for the following excluded factions
excludedFactions = [
    "Gendarmerie",                 // Gendarmerie
    "IND_G_F",                     // GUER FIA
    "OPF_G_F",                     // OPFOR FIA
    "CIV_F",                       // Civilian
    "IND_L_F",                     // GUER Looters
    "rhsgref_faction_hidf",        // RHS Horizon Islands Defence Force
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

if (denyFaction) exitWith
{
    hint parsetext format ["<t align='left' color='#F98A02' size='1'>Helicopter extraction is not available for this faction.</t>"];
    denyFaction = nil;
};

isSmokeDetected = false;

sleep 0.1;

extractMarker = createMarkerLocal ["extraction_marker", [0, 0]];
gridPos = mapGridPosition getPos player;

sleep 0.3;

player sideRadio "radio_beep_from";
player sideChat format ["VALOR-20 this is %1, requesting immediate extraction. Location is at grid %2, over.", name player, gridPos];

sleep 10;

[playerSide,"HQ"] sideRadio "radio_beep_to";
[playerSide,"HQ"] sideChat format["%1 this is VALOR-20, affirmative on the extraction. Mark LZ with colored smoke, over.", name player];

private "_smokeNadeToThrow";

/* Note: Some RHS units carry smoke grenades, but they are not vanilla
 * grenades. Their class name is 'rhs_magazine_rhs_mag_m18_*'. But for whatever
 * reason, RHS smoke grenades are part of the CfgVehicles class rather rhan
 * CfgMagazines. That means I cannot check if it exists in the player's
 * inventory since it's technically not a magazine.
 */
smokeMags = [
    "SmokeShellRed",
    "SmokeShellGreen",
    "SmokeShellYellow",
    "SmokeShellPurple",
    "SmokeShellBlue",
    "SmokeShellOrange"
];
{ 
    if (_x in (magazines player)) exitWith 
    { 
        hint parsetext format ["<t align='left' color='#FFF'>Use one of the smoke grenades in your inventory to mark the LZ.</t>"];
        _smokeNadeToThrow = _x;
    };
} forEach smokeMags;

sleep 0.1;

if (isNil "_smokeNadeToThrow") then
{
    hint parsetext format ["<t align='left' color='#FFF'>A <t color='#BA55D3'>purple smoke</t> grenade has been added to your inventory. Use it to mark the LZ.</t>"];
    _smokeNadeToThrow = "SmokeShellPurple";
    player addMagazine _smokeNadeToThrow;
};

// Create a marker where the smoke grenade lands
CheckForSmoke = player addEventHandler ["Fired",
{
    if ((_this select 5) != _smokeNadeToThrow) exitWith {};
    _null = (_this select 6) spawn
    {
        smokePos = getPos _this;
        sleep 1;
        while { (smokePos distance (getPos _this)) > 0 } do
        {
            smokePos = getPos _this;
            isSmokeDetected = true;
            extractMarker setMarkerPosLocal smokePos;
            sleep 1;
        };
    };
}];

// "1" depends on your chosen radio slot. Check: setRadioMsg help URL
1 setRadioMsg "NULL";

waitUntil { isSmokeDetected };

// Create a marker icon on the map to identify the extraction point
extractMarker setMarkerShapelocal "ICON";
extractMarker setMarkerTypelocal "MIL_PICKUP";
extractMarker setMarkerColorlocal "ColorBlack";
extractMarker setMarkerText "Extraction";

// Sleeping is rquired to correctly place the hidden helipad on the smoke pos
sleep 4;

hiddenHelipad = createVehicle ["Land_HelipadEmpty_F", smokePos, [], 0, "NONE"];
isSmokeDetected = false;

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
            case "BLU_F":                 { "B_Heli_Transport_01_F" };           // NATO (Default)
            case "BLU_T_F":               { "B_Heli_Transport_01_F" };           // NATO (Pacific)
            case "BLU_CTRG_F":            { "B_CTRG_Heli_Transport_01_sand_F" }; // NATO (CTRG)
            case "BLU_G_F":               { "B_Heli_Light_01_F" };               // FIA
            case "ACR_A3":                { "ACR_A3_Mi17_base_CZ_EP1" };         // ACR
            case "ACR_A3_Des":            { "ACR_A3_Mi17_base_CZ_EP1_Des" };     // ACR (Desert)
            case "rhs_faction_usarmy_d":  { "RHS_UH60M_d" };                     // RHS USA (Army - D)
            case "rhs_faction_usarmy_wd": { "RHS_UH60M" };                       // RHS USA (Army - W)
            case "rhs_faction_socom":     { "RHS_MELB_MH6M" };                   // RHS USA (SOCOM)
            case "rhs_faction_usmc_d":    { "RHS_UH1Y_d" };                      // RHS USA (USMC - D)
            case "rhs_faction_usmc_wd":   { "RHS_UH1Y" };                        // RHS USA (USMC - W)
            case "CUP_B_CZ":              { "CUP_B_Mi171Sh_Unarmed_ACR" };       // CUP CZ (ACR)
            case "CUP_B_GB":              { "CUP_B_SA330_Puma_HC1_BAF" };        // CUP GB (BAF)
            case "CUP_B_GER":             { "CUP_B_UH1D_GER_KSK" };              // CUP GER (Bundeswehr)
            case "CUP_B_CDF":             { "CUP_B_Mi17_CDF" };                  // CUP CDF
            case "CUP_B_US_Army":         { "CUP_B_UH60M_FFV_US" };              // CUP USA (Army - D)
            case "CUP_B_USMC":            { "CUP_B_UH1Y_UNA_USMC" };             // CUP USA (USMC)
            default                       { "B_Heli_Transport_01_F" };           // NATO (Default)
        };
    };

    case east:
    {
        switch (faction player) do
        {
            case "OPF_F":                 { "O_Heli_Light_02_F" };  // CSAT (Default)
            case "rhsgref_faction_chdkz": { "rhsgref_ins_Mi8amt" }; // ChDKZ Insurgents
            case "rhs_faction_vdv":       { "rhs_Mi24V_vdv" };      // RHS Russia (VDV)
            case "rhs_faction_vv":        { "rhs_Mi8mt_vv" };       // RHS Russia (VV)
            case "CUP_O_SLA":             { "CUP_O_UH1H_SLA" };     // CUP Sahrani Liberation Army
            case "CUP_O_TK":              { "CUP_O_Mi17_TK" };      // CUP Takistani Army
            default                       { "O_Heli_Light_02_F" };  // CSAT (Default)
        };
    };

    case resistance:
    {
        switch (faction player) do
        {
            case "IND_F":                      { "I_Heli_light_03_F" };           // AAF (Default)
            case "IND_C_F":                    { "I_C_Heli_Light_01_civil_F" };   // Syndikat
            case "IND_E_F":                    { "I_E_Heli_light_03_unarmed_F" }; // LDF (Livonian Defense Force)
            case "rhsgref_faction_chdkz_g":    { "rhsgref_ins_Mi8amt" };          // RHS ChDKZ Insurgents
            case "rhsgref_faction_cdf_air":    { "rhsgref_cdf_Mi35" };            // RHS Chernarus (Air Force)
            case "rhsgref_faction_cdf_ground": { "rhsgref_cdf_reg_Mi17Sh" };      // RHS Chernarus (Ground Forces)
            case "rhsgref_faction_un":         { "rhsgref_un_Mi8amt" };           // RHS Chernarus (UN)
            case "rhssaf_faction_army":        { "rhssaf_airforce_ht48" };        // RHS SAF (KOV)
            case "rhssaf_faction_airforce":    { "rhssaf_airforce_ht48" };        // RHS SAF (RVIPVO)
            case "CUP_I_PMC_ION":              { "CUP_I_MH6M_ION" };              // CUP ION PMC
            case "CUP_I_RACS":                 { "CUP_I_UH60L_FFV_RACS" };        // CUP RACS
            case "CUP_I_TK_GUE":               { "CUP_I_UH1H_TK_GUE" };           // CUP Takistani Locals
            case "CUP_I_UN":                   { "CUP_I_Mi17_UN" };               // CUP United Nations
            default                            { "I_Heli_light_03_F" };           // AAF (Default)
        };
    };

    case civilian:
    {
        switch (faction player) do
        {
            case "CIV_IDAP_F": { "C_IDAP_Heli_Transport_02_F" }; // Civilian (IDAP)
        };
    };
};

// Spawn the helicopter
fncSpawnVehicle = [spawnPos, vecDir, heliClass, side player] call BIS_fnc_spawnVehicle;
heli = fncSpawnVehicle select 0;
heliPilot = (fncSpawnVehicle select 1) select 0;

sleep 4;

[playerSide,"HQ"] sideRadio "radio_beep_to";
[playerSide,"HQ"] sideChat format["%1 this is VALOR-20, coordinates received. ETA is 1 minute. Standby.", name player];

heli setBehaviour  "CARELESS";
heli setSpeedMode  "NORMAL";
heli setCombatMode "GREEN";

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
    wp_extrZone = (group heli) addWaypoint [targetPos, 0];
    wp_extrZone setWaypointType "MOVE";
    wp_extrZone setWaypointDescription "Extraction zone";
};

// Orders the helicopter fly back to the original spawn location
fn_heliReturnHome =
{
    wp_rtb = (group heli) addWaypoint [spawnPos, 2];
    wp_rtb setWaypointType "MOVE";

    // Delete the helicopter + crew and clean up the script for usage again
    wp_rtb setWaypointStatements
    [
        "true",
        "{deletevehicle _x} foreach (crew vehicle this + [vehicle this]);
         deleteMarkerLocal 'dropoff_marker';
         1 setRadioMsg 'Request Extraction';
         player removeEventHandler ['Fired', 0];
         deleteVehicle hiddenHelipad;
         _smokeNadeToThrow = nil;"
    ];
};

call fn_heliMoveToLZ;
sleep 1;

// Deploy countermeasures in case the helicopter gets fired at with AA missiles
heli addEventHandler ["IncomingMissile",
{
    // hint "incoming!";
    fn_dropFlares =
    {
        flares = 0;
        while { alive heli && flares < 6 } do
        {
            if ((heli ammo "CMFlareLauncher") == 0) then
            {
                heli addMagazineTurret ["120Rnd_CMFlare_Chaff_Magazine", [-1], 20];
                reload heli;
            };
            
            heli action ["useWeapon", heli, driver heli, 0];
            flares = flares + 1;
        };
    };
    call fn_dropFlares;
}];

while { ((alive heli) && !(unitReady heli)) } do
{
    sleep 1;
};

if (alive heli) then
{
    // Order the helicopter to land after reaching its designated coordinates
    heli land "GET IN";
    
    // Precisely check if the helicopter landed and came to a complete stop    
    waitUntil
    {
        (velocity  heli select 2) > -0.2 &&
        (getPosATL heli select 2) <  0.5
    };
    
    sleep 0.7;
    
    if (typeOf heli == "B_Heli_Transport_01_F" ||
        typeOf heli == "B_CTRG_Heli_Transport_01_sand_F") then
    {
        heli animateDoor ['door_R', 1]; 
        heli animateDoor ['door_L', 1];
    };
    
    // Make sure that the player and all associated units have boarded the helicopter
    waitUntil
    {
        { _x in heli } count units group player == count units group player
    };
    
    // Lock the doors to prevent the player from ejecting and going off the script scenario
    heli lock true; 
    
    sleep 0.3;
    
    deleteMarkerLocal extractMarker;
    [playerSide,"HQ"] sideRadio "radio_beep_to";
    [playerSide,"HQ"] sideChat "Welcome aboard! Mark your drop off location on the map.";
    
    sleep 1.7;
    
    // Open the map to mark a drop off location
    openMap true;
};

getMapClick = true;

sleep 0.1;

// If invincibility is disabled and the helicopter gets destroyed, script ends here
if (!alive heli || (damage heli) > 0.5) exitWith
{
    player removeEventHandler ['Fired', 0];
    deleteMarkerLocal extractMarker;
    hint parsetext format ["<t align='left' color='#DC143C' size='1'>The extraction helicopter has been destroyed.</t>"];
};

dropOffMarker = createMarkerLocal ["dropoff_marker", [0, 0]];

sleep 0.3;

hintSilent "Mark your drop off location by clicking on the map.";

onMapSingleClick
{
    dropOffMarker setMarkerPosLocal _pos;
    getMapClick = false;
};

waitUntil { !getMapClick };

hint "Are you drunk or something? The drop off location needs to be farther away from your current position.";

waitUntil { ((heli distance getMarkerPos dropOffMarker) > 1000) };

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

sleep 3;

// Set a new waypoint for the helicopter
wp_dropZone = (group heli) addWaypoint [dropOffPos, 1];
wp_dropZone setWaypointType "MOVE";

sleep 1;

// Check if the helicopter has reached the drop off location
while { ((alive heli) && !(unitReady heli)) } do
{
    sleep 1;
};

// Order the helicopter to land
if (alive heli) then
{
    heli land "GET OUT";
    
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
        { _x in heli } count units group player == 0
    };
    
    // Lock the doors
    heli lock true;
    
    sleep 0.5;
};

sleep 3;
call fn_heliReturnHome;
