/*
** Game........: ArmA III
** Script Type.: Helicopter Extraction 
** Developer...: Jad Altahan (0x141)
** Website.....: Http://github.com/xv
** License.....: MIT
*/

// No transport for Gendarmerie, Horizon Islands Defence Force (RHS), 
// USA Navy (RHS), USAF (RHS)
if (faction player == "BLU_GEN_F"            ||
    faction player == "rhsgref_faction_hidf" ||
    faction player == "rhs_faction_usn"      ||
    faction player == "rhs_faction_usaf") exitWith
{
    hint parsetext format ["<t align='left' color='#F98A02' size='1'>Helicopter extraction is not available for this faction.</t>"];
};

virtual_target_state = false;

sleep 0.1;

_Marker = createMarkerLocal ["extraction_marker", [0, 0]];
gridPos = mapGridPosition getPos player;

sleep 0.3;

player sideRadio "radio_beep_from";
player sideChat format ["Valor-20 this is %1, requesting immediate extraction. Location is at grid %2, over.", name player, gridPos];

sleep 10;

[playerSide,"HQ"] sideRadio "radio_beep_to";
[playerSide,"HQ"] sideChat format["%1 this is VALOR-20, affirmative on the extraction. Mark LZ with red smoke, over.", name player];

playerMags = magazines player;
if ("SmokeShellRed" in playerMags) then
{
    hint parsetext format ["<t align='left' color='#FFF'>Use the <t color='#DA525C'>red smoke</t> grenade in your inventory to mark the LZ.</t>"];
}
else
{
    hint parsetext format ["<t align='left' color='#FFF'>A <t color='#DA525C'>red smoke</t> grenade has been added to your inventory. Use it to mark the LZ.</t>"];
	player addMagazine "SmokeShellRed";
};

// Create a marker where the smoke grenade lands
CheckForSmoke = player addEventHandler ["Fired",
{
    if ((_this select 5) != "SmokeShellRed") exitWith {};
    _null = (_this select 6) spawn
    {
        smokePos = getPos _this;
        sleep 1;
        while { (smokePos distance (getPos _this)) > 0 } do
        {
            smokePos = getPos _this;
            virtual_target_state = true;
            "extraction_marker" setMarkerPosLocal smokePos;
            sleep 1;
        };
    };
}];

// "1" depends on your chosen radio slot. Check: setRadioMsg help URL
1 setRadioMsg "NULL";

waitUntil { virtual_target_state };

// Create a marker icon on the map to identify the extraction point
_Marker setMarkerShapelocal "ICON";
"extraction_marker" setMarkerTypelocal "MIL_PICKUP";
"extraction_marker" setMarkerColorlocal "ColorBlack";
"extraction_marker" setMarkerText "Extraction";

sleep 0.05;

pos_x = getMarkerPos "extraction_marker" select 0;
pos_y = getMarkerPos "extraction_marker" select 1;

virtual_target = "HeliHEmpty" createVehicle [0, 0];
virtual_target setPos [pos_x, pos_y];
virtual_target_state = false;

targetPos = getPosASL virtual_target;

sleep 1;

/* LEGACY ARMA II CODE. NOT REQUIRED IN ARMA 3
** ===========================================
**
** FNC_Spawn=[] spawn
** {
**     if (isNil "BIS_fnc_init") then
**     {
**         _side  = createCenter sideLogic;
**         _group = createGroup _side;
**         _logic = _group createUnit ["FunctionsManager", [0, 0, 0], [], 0, "NONE"];
**     };
** };
** waitUntil { BIS_fnc_init };
*/

spawnDir = random 360; // Spawn the helicopter at a random direction
spawnRange = 500;      // Time it will take until the helicopter arrives at the marked location
spawnPos =
[
	(targetPos select 0) + (spawnRange * sin(spawnDir)), 
    (targetPos select 1) + (spawnRange * cos(spawnDir)), 
    (targetPos select 2) + 40
];

vecDir = [spawnPos, targetPos] call BIS_fnc_dirTo;

/* Spawn a different helicopter depending on the player's faction. A civilian
** playerSide can be added as well; however, the script will not function
** correctly. This seems to be a problem with ArmA itself, not the script.
**
** You can modify the helicopter class names to any helicopter model you want,
** whether it's official or user-made.
*/
heliClass = switch (playerSide) do
{
    case west:
    {
        switch (faction player) do
        {
            case "BLU_F"                : { [spawnPos, vecDir, "B_Heli_Transport_01_F",           WEST] call BIS_fnc_spawnVehicle; }; // NATO (Default)
            case "BLU_T_F"              : { [spawnPos, vecDir, "B_Heli_Transport_01_F",           WEST] call BIS_fnc_spawnVehicle; }; // NATO (Pacific)
            case "BLU_CTRG_F"           : { [spawnPos, vecDir, "B_CTRG_Heli_Transport_01_sand_F", WEST] call BIS_fnc_spawnVehicle; }; // NATO (CTRG)
            case "BLU_G_F"              : { [spawnPos, vecDir, "B_Heli_Light_01_F",               WEST] call BIS_fnc_spawnVehicle; }; // FIA
            case "ACR_A3"               : { [spawnPos, vecDir, "ACR_A3_Mi17_base_CZ_EP1",         WEST] call BIS_fnc_spawnVehicle; }; // ACR
			case "ACR_A3_Des"           : { [spawnPos, vecDir, "ACR_A3_Mi17_base_CZ_EP1_Des",     WEST] call BIS_fnc_spawnVehicle; }; // ACR (Desert)
            case "rhs_faction_usarmy_d" : { [spawnPos, vecDir, "RHS_UH60M_d",                     WEST] call BIS_fnc_spawnVehicle; }; // USA (Army - D)
			case "rhs_faction_usarmy_wd": { [spawnPos, vecDir, "RHS_UH60M",                       WEST] call BIS_fnc_spawnVehicle; }; // USA (Army - W)
			case "rhs_faction_socom"    : { [spawnPos, vecDir, "RHS_MELB_MH6M",                   WEST] call BIS_fnc_spawnVehicle; }; // USA (SOCOM)
			case "rhs_faction_usmc_d"   : { [spawnPos, vecDir, "RHS_UH1Y_d",                      WEST] call BIS_fnc_spawnVehicle; }; // USA (USMC - D)
			case "rhs_faction_usmc_wd"  : { [spawnPos, vecDir, "RHS_UH1Y",                        WEST] call BIS_fnc_spawnVehicle; }; // USA (USMC - W)
            default
            {
                [spawnPos, vecDir, "B_Heli_Transport_01_F", WEST] call BIS_fnc_spawnVehicle;
            };
        };
    };
    
    case east:
    {
        switch (faction player) do
        {
            case "RU"        : { [spawnPos, vecDir, "Mi17_rockets_RU", EAST] call BIS_fnc_spawnVehicle; };
            case "INS"       : { [spawnPos, vecDir, "Mi17_INS",        EAST] call BIS_fnc_spawnVehicle; };
            case "BIS_TK"    : { [spawnPos, vecDir, "Mi17_TK_EP1",     EAST] call BIS_fnc_spawnVehicle; };
            case "BIS_TK_INS": { [spawnPos, vecDir, "UH1H_TK_EP1",     EAST] call BIS_fnc_spawnVehicle; };
        };
    };
    
    case resistance:
    {
        switch (faction player) do
        {
            case "BIS_TK_GUE": { [spawnPos, vecDir, "UH1H_TK_GUE_EP1", RESISTANCE] call BIS_fnc_spawnVehicle; };
            case "BIS_UN"    : { [spawnPos, vecDir, "Mi17_UN_CDF_EP1", RESISTANCE] call BIS_fnc_spawnVehicle; };
            case "PMC_BAF"   : { [spawnPos, vecDir, "Ka60_PMC",        RESISTANCE] call BIS_fnc_spawnVehicle; };
        };
    };
    
    case civilian:
    {
        switch (faction player) do
        {
            case "CIV"            : { [spawnPos, vecDir, "Mi17_Civilian", CIVILIAN] call BIS_fnc_spawnVehicle; };
            case "CIV_RU"         : { [spawnPos, vecDir, "Mi17_Civilian", CIVILIAN] call BIS_fnc_spawnVehicle; };
            case "BIS_CIV_special": { [spawnPos, vecDir, "Mi17_Civilian", CIVILIAN] call BIS_fnc_spawnVehicle; };
        };
    };
};

heli = heliClass select 0;
heliPilot = (heliClass select 1) select 0;

sleep 4;

[playerSide,"HQ"] sideRadio "radio_beep_to";
[playerSide,"HQ"] sideChat format["%1 this is VALOR-20, coordinates received. ETA is 1 minute. Standby.", name player];

heli setBehaviour  "CARELESS";
heli setSpeedMode  "NORMAL";
heli setCombatMode "GREEN";

/* Comment line below to disable invincibility. Note that when you request the
** helicopter in a hot zone, the enemy AI will shoot at it. If the helicopter
** gets fired at with AA missiles, it will deploy countermeasures; however, it's
** impossible to evade all the missiles with flares/chaffs. In case the
** helicopter gets destroyed, you will not be able to request another. This is
** NOT a bug. The script was written to function this way. Use at your own risk!
*/
{ _x allowDamage false; } foreach [heli] + crew heli;
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
	     player removeEventHandler ['Fired', 0];"
	];
};

call fn_heliMoveToLZ;
sleep 1;

// Deploy countermeasures in case the helicopter gets fired at with AA missiles
heli addEventHandler ["IncomingMissile",
{
    hint "incoming!";
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
            sleep 0.5;
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
    
    deleteMarkerLocal "extraction_marker";
    [playerSide,"HQ"] sideRadio "radio_beep_to";
    [playerSide,"HQ"] sideChat "Welcome aboard! Mark your drop off location on the map.";
    
    sleep 1.7;
    
    // Open the map to mark a drop off location
    openMap true;
};

VT = false;

sleep 0.1;

// If invincibility is disabled and the helicopter gets destroyed, script ends here
if (!alive heli || (damage heli) > 0.5) exitWith
{
    player removeEventHandler ['Fired', 0];
    deleteMarkerLocal 'extraction_marker';
    hint parsetext format ["<t align='left' color='#C10005' size='1'>The extraction helicopter has been destroyed.</t>"];
};

_Marker_2 = createMarkerLocal ["dropoff_marker", [0, 0]];

sleep 0.3;

ASM = "dropoff_marker";

player onMapSingleClick "ASM setMarkerPosLocal _pos; VT = true";

hintSilent "Click on the map to mark a drop off location";

waitUntil { VT };

// Create a marker icon on the map to identify the drop off point
_Marker_2 setMarkerShapelocal "ICON";
"dropoff_marker" setMarkerTypelocal "MIL_END";
"dropoff_marker" setMarkerColorlocal "ColorBlack";
"dropoff_marker" setMarkerText "Drop Off";

sleep 0.05;

player onMapSingleClick "nil";

hintSilent "Drop off location has been marked.";
pos_x_2 = getMarkerPos "dropoff_marker" select 0;
publicVariable "pos_x_2";
pos_y_2 = getMarkerPos "dropoff_marker" select 1;
publicVariable "pos_y_2";

SVT_2 = "HeliHEmpty" createVehicle [0, 0];
SVT_2 setPos [pos_x_2, pos_y_2];

VT = false;

dropOffPos = getPosASL SVT_2;

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