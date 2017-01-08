/* GENERAL INFORMATION
** Game........: ArmA II
** Script Type.: Helicopter Extraction 
** Developer...: 0x141
** Website.....: Http://github.com/ei
** Release Date: September 2, 2014
** Update Date.: Jan 8, 2017
**  
** -- File must be saved as .sqf --
*/

/* HELP URLS
** setRadioMsg: https://community.bistudio.com/wiki/setRadioMsg
** Vehicle class names ArmA II: https://community.bistudio.com/wiki/ArmA_2:_Vehicles
** Vehicle class names ArmA IIOA: https://community.bistudio.com/wiki/ArmA_2_OA:_Vehicles
** Faction class names: https://community.bistudio.com/wiki/faction
*/

if (faction player == "GUE" || faction player == "BIS_TK_CIV") exitWith
{
    hint parsetext format ["<t align='left' color='#F98A02' size='1'>Helicopter extraction is not available for this faction.</t>"];
};

virtual_target = false;

sleep 0.1;

_Marker = createMarkerLocal ["extraction_marker", [0,0]];
_gridPos = mapGridPosition getPos player;

sleep 0.3;

player sideRadio "radio_beep_from";
player sideChat format["Valor-20 this is %1, requesting immediate extraction. Location is at grid %2, over.", name player, _gridPos];

sleep 10;

[PlayerSide,"HQ"] sideRadio "radio_beep_to";
[PlayerSide,"HQ"] sideChat format["%1 this is VALOR-20, affirmative on the extraction. Mark LZ with red smoke, over.", name player];

hint parsetext format ["<t align='left' color='#FFFFFF' size='1'>A </t><t align='left' color='#D63D48' size='1.2'>red smoke </t><t align='left' color='#FFFFFF' size='1'>grenade has been added to your inventory.</t>"];
player addMagazine "SmokeShellRed";

// create a marker where the smoke grenade lands
CheckForSmoke = player addEventHandler ["Fired",
{
    if ((_this select 5) != "SmokeShellRed") exitWith {};
    _null = (_this select 6) spawn
    {
        _SmokePos = getPos _this;
        sleep 1;
        while {(_SmokePos distance (getPos _this)) > 0} do {
            _SmokePos = getPos _this;
            virtual_target = true;
            "extraction_marker" setMarkerPosLocal _SmokePos;
            sleep 1;
        };
    };
}];

1 setRadioMsg "NULL"; // "1" depends on your chosen radio slot. Check: setRadioMsg help URL

waitUntil {virtual_target};

// create a marker icon on the map to identify the extraction point
_Marker setMarkerShapelocal "ICON";
"extraction_marker" setMarkerTypelocal "MIL_PICKUP";
"extraction_marker" setMarkerColorlocal "ColorBlack";
"extraction_marker" setMarkerText "Extraction";

sleep 0.05;

pos_x = getMarkerPos "extraction_marker" select 0;
publicVariable "pos_x";
pos_y = getMarkerPos "extraction_marker" select 1;
publicVariable "pos_y";

SVT = "HeliHEmpty" createVehicle [0,0];
SVT setPos [pos_x,pos_y];

virtual_target = false;
_TargetPos = getPosASL SVT;

sleep 1;

private
[
    "_SpawnDirection",
    "_SpawnRange",
    "_SpawnPos",
    "_VectorDirection",
    "_VehicleArray",
    "_Vehicle",
    "_Pilot",
    "_Dir",
    "_WP1",
    "_WP2"
];

FNC_Spawn=[] spawn
{
    if (isNil "BIS_fnc_init") then
    {
        _side = createCenter sideLogic;
        _group = createGroup _side;
        _logic = _group createUnit ["FunctionsManager", [0,0,0], [], 0, "NONE"];
    };
};
waitUntil {BIS_fnc_init};

_SpawnDirection = random 360; // spawn the helicopter at a random direction
_SpawnRange = 2500;            // time it will take until the helicopter arrives at the marked location
_SpawnPos = [
    (_TargetPos select 0) + (_SpawnRange * sin(_SpawnDirection)), 
    (_TargetPos select 1) + (_SpawnRange * cos(_SpawnDirection)), 
    (_TargetPos select 2) + 40];

_VectorDirection = [_SpawnPos, _TargetPos] call BIS_fnc_dirTo;

/* spawn a different helicopter depending on the player's faction. A civilian
** playerSide can be added as well; however, the script will not function
** correctly. This seems to be a problem with ArmA itself, not the script.
**
** you can modify "B_Heli_Transport_01_F", "O_Heli_Light_02_unarmed_F",
** "I_Heli_light_03_unarmed_F" to any helicopter model you want, whether it's
** official or user-made.
*/
_VehicleArray = switch (playerSide) do
{
    case west:
    {
        switch (faction player) do
        {
            case "USMC"   : { [_SpawnPos, _VectorDirection, "UH1Y",                   WEST] call BIS_fnc_spawnVehicle; };
            case "CDF"    : { [_SpawnPos, _VectorDirection, "Mi17_CDF",               WEST] call BIS_fnc_spawnVehicle; };
            case "BIS_US" : { [_SpawnPos, _VectorDirection, "UH60M_EP1",              WEST] call BIS_fnc_spawnVehicle; };
            case "BIS_CZ" : { [_SpawnPos, _VectorDirection, "Mi171Sh_rockets_CZ_EP1", WEST] call BIS_fnc_spawnVehicle; };
            case "BIS_GER": { [_SpawnPos, _VectorDirection, "MH6J_EP1",               WEST] call BIS_fnc_spawnVehicle; };
            case "BIS_BAF": { [_SpawnPos, _VectorDirection, "AW159_Lynx_BAF",         WEST] call BIS_fnc_spawnVehicle; };
            default
            {
                [_SpawnPos, _VectorDirection, "UH60M_EP1", WEST] call BIS_fnc_spawnVehicle;
            };
        };
    };
    
    case east:
    {
        switch (faction player) do
        {
            case "RU"        : { [_SpawnPos, _VectorDirection, "Mi17_rockets_RU", EAST] call BIS_fnc_spawnVehicle; };
            case "INS"       : { [_SpawnPos, _VectorDirection, "Mi17_INS",        EAST] call BIS_fnc_spawnVehicle; };
            case "BIS_TK"    : { [_SpawnPos, _VectorDirection, "Mi17_TK_EP1",     EAST] call BIS_fnc_spawnVehicle; };
            case "BIS_TK_INS": { [_SpawnPos, _VectorDirection, "UH1H_TK_EP1",     EAST] call BIS_fnc_spawnVehicle; };
            case "BIS_GER"   : { [_SpawnPos, _VectorDirection, "MH6J_EP1",        EAST] call BIS_fnc_spawnVehicle; };
            case "BIS_BAF"   : { [_SpawnPos, _VectorDirection, "AW159_Lynx_BAF",  EAST] call BIS_fnc_spawnVehicle; };
        };
    };
    
    case resistance:
    {
        switch (faction player) do
        {
            case "BIS_TK_GUE": { [_SpawnPos, _VectorDirection, "UH1H_TK_GUE_EP1", RESISTANCE] call BIS_fnc_spawnVehicle; };
            case "BIS_UN"    : { [_SpawnPos, _VectorDirection, "Mi17_UN_CDF_EP1", RESISTANCE] call BIS_fnc_spawnVehicle; };
            case "PMC_BAF"   : { [_SpawnPos, _VectorDirection, "Ka60_PMC",        RESISTANCE] call BIS_fnc_spawnVehicle; };
        };
    };
    
    case civilian:
    {
        switch (faction player) do
        {
            case "CIV"            : { [_SpawnPos, _VectorDirection, "Mi17_Civilian", CIVILIAN] call BIS_fnc_spawnVehicle; };
            case "CIV_RU"         : { [_SpawnPos, _VectorDirection, "Mi17_Civilian", CIVILIAN] call BIS_fnc_spawnVehicle; };
            case "BIS_CIV_special": { [_SpawnPos, _VectorDirection, "Mi17_Civilian", CIVILIAN] call BIS_fnc_spawnVehicle; };
        };
    };
};

_Vehicle = _VehicleArray select 0;
_Pilot = (_VehicleArray select 1) select 0;

sleep 4;

[PlayerSide,"HQ"] sideRadio "radio_beep_to";
[PlayerSide,"HQ"] sideChat format["%1 this is VALOR-20, coordinates received. ETA is 1 minute. Standby.", name player];

_Vehicle setBehaviour "CARELESS";
_Vehicle setSpeedMode "NORMAL";
_Vehicle setCombatMode "BLUE";

/* comment line below to disable invincibility. Note that when you request the
** helicopter in a hot zone, the enemy AI will shoot at it. If the helicopter
** gets fired at with AA missiles, it will deploy countermeasures; however, it's
** impossible to evade all the missiles with flares/chaffs. In case the
** helicopter gets destroyed, you will not be able to request another. This is
** NOT a bug. The script was written to function this way. Use at your own risk!
*/

// { _x allowDamage false; } foreach [_Vehicle] + crew _Vehicle;
//_Vehicle setCaptive true; // uncomment to make enemy AI ignore the helicopter and not shoot at it

// set the altitude, direction and speed of the helicopter
_Vehicle setPosATL [getPosATL _Vehicle select 0, getPosATL _Vehicle select 1, (getPosATL _Vehicle select 2) + 40];
_Dir = direction _Vehicle;
_Vehicle setVelocity [sin ((_Dir) * 30), cos ((_Dir) * 30), 0];

// set a waypoint to the extraction location and order the helicopter to fly to it
_WP1 = (group _Vehicle) addWaypoint [_TargetPos, 0];
_WP1 setWaypointType "MOVE";
_WP1 setWaypointDescription "Extraction zone";

sleep 1;

// deploy countermeasures in case the helicopter gets fired at with AA missiles
_Vehicle addEventHandler ["IncomingMissile",
{
    cmflare = {
        _dropTime = 0;

        while {alive _Vehicle && _dropTime < 20} do
        {
            sleep 0.4;
            _Vehicle action ["useWeapon", _Vehicle, driver _Vehicle, 0];
            _dropTime = _dropTime + 1;
        };
    };
call cmflare;
}];

while { ((alive _Vehicle) && !(unitReady _Vehicle)) } do
{
    sleep 1;
};

if (alive _Vehicle) then
{
    // order the helicopter to land after reaching its designated coordinates
    _Vehicle land "GET IN";
    
    // precisely check if the helicopter landed and came to a complete stop    
    waitUntil{(velocity _Vehicle select 2) > -0.2 && (getPosATL _Vehicle select 2) < 0.5};
    
    sleep 0.7;
    
    // make sure that the player and all associated units have boarded the helicopter
    waitUntil{{_x in _Vehicle} count units group player == count units group player};
    
    // lock the doors to prevent the player from ejecting and going off the script scenario
    _Vehicle lock true; 
    
    sleep 0.3;
    
    deleteMarkerLocal "extraction_marker";
    [playerSide,"HQ"] sideRadio "radio_beep_to";
    [playerSide,"HQ"] sideChat "Welcome aboard! Mark your drop off location on the map.";
    
    sleep 1.7;
    
    // open the map to mark a drop off location
    openMap true;
};

VT = false;

sleep 0.1;

// if invincibility is disabled and the helicopter gets destroyed, script ends here
if (!alive _Vehicle || (damage _Vehicle) > 0.5) exitWith
{
    player removeEventHandler ['Fired', 0];
    deleteMarkerLocal 'extraction_marker';
    hint parsetext format ["<t align='left' color='#C10005' size='1'>The extraction helicopter has been destroyed.</t>"];
};

_Marker_2 = createMarkerLocal ["dropoff_marker", [0,0]];

sleep 0.3;

ASM = "dropoff_marker";

player onMapSingleClick "ASM setMarkerPosLocal _pos; VT=true";

hintSilent "Click on the map to mark a drop off location";

waitUntil {VT};

// create a marker icon on the map to identify the drop off point
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

SVT_2 = "HeliHEmpty" createVehicle [0,0];
SVT_2 setPos [pos_x_2,pos_y_2];

VT = false;

_DropOffPos = getPosASL SVT_2;

sleep 1;

openMap false; // close the map after the drop off location has been marked

sleep 3;

// set a new waypoint for the helicopter
_WP2 = (group _Vehicle) addWaypoint [_DropOffPos, 1];
_WP2 setWaypointType "MOVE";

sleep 1;

// check if the helicopter has reached the drop off location
while { ( (alive _Vehicle) && !(unitReady _Vehicle) ) } do
{
    sleep 1;
};

// order the helicopter to land
if (alive _Vehicle) then
{
    _Vehicle land "GET OUT";
    
    // waitUntil{(velocity _Vehicle) select 2 > -0.2 && (getPosATL _Vehicle) select 2 < 0.5};
    
    waitUntil{(velocity _Vehicle select 2) > -0.2 && (getPosATL _Vehicle select 2) < 0.5};
    
    [playerSide,"HQ"] sideRadio "radio_beep_to";
    [playerSide,"HQ"] sideChat "Touchdown!";
    
    // unlock the helicopter doors
    _Vehicle lock false;    
    
    // make sure that the player and all associated units have left the helicopter
    waitUntil{{_x in _Vehicle} count units group player == 0};
    
    // lock the doors
    _Vehicle lock true;
    
    sleep 0.5;
};

sleep 3;

// order the helicopter fly back to the original spawn location
_WP3 = (group _Vehicle) addWaypoint [_SpawnPos, 2];
_WP3 setWaypointType "MOVE";

// delete the helicopter crew, the helicopter itself and clean up the script for usage again
_WP3 setWaypointStatements
[
    "true",
    "{deletevehicle _x} foreach (crew vehicle this + [vehicle this]);
     deleteMarkerLocal 'dropoff_marker';
     1 setRadioMsg 'Request Extraction';
     player removeEventHandler ['Fired', 0];"
];
