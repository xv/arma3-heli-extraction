#include "..\component.hpp"

/* 
 * Author(s):
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Checks if the player has any smoke grenades (throwable and launchable),
 *     or IR strobes (for night time marking) that can be used to mark the LZ
 *     and returns them.
 *
 * Parameter(s):
 *     Nothing.
 *
 * Returns:
 *     ARRAY - if the player has magazines that can be used to mark the LZ, they
 *     will be returned. If not, a throwable smoke grenade (or IR strobe) will
 *     be added to the player's inventory.
 */

private ["_markerMag", "_grenadeToThrow", "_isMarkingWithSmoke"];

_found40mmGrenade = false;

if (sunOrMoon >= 1) then
{
    _isMarkingWithSmoke = true;

    // Vanilla and RHS smoke throwables
    // Notice how this is a multidimensional array. It's made this way so that
    // throwable smoke mags would remain independent of 40mm launchable mags
    _markerMag =
    [
        [
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
        ]
    ];

    _get40mmSmokeMags = call xv_fnc_getCompatGLMags;
    if (count _get40mmSmokeMags != 0) then
    {
        _glMags = _get40mmSmokeMags select 1;

        _primaryMags = primaryWeaponMagazine player;
        _mags = magazines player;
        _invGlMags = _glMags select { _x in _primaryMags or _x in _mags };
        
        if (count _invGlMags > 0) then {
            _markerMag pushBack _invGlMags;
            _found40mmGrenade = true;
        };
    };
}
else
{
    _isMarkingWithSmoke = false;

    // Use IR strobes instead of smoke for night time marking
    _markerMag =
    [
        "B_IR_Grenade", // NATO (BLUFOR)
        "O_IR_Grenade", // CSAT (OPFOR)
        "I_IR_Grenade"  // AAF (GUER)
    ];
};

_magsToUse = [_markerMag, (_markerMag select 0)] select _isMarkingWithSmoke;
_playerHasThrowable = (_magsToUse findIf { _x in magazines player } != -1);

switch (true) do
{
    case (_playerHasThrowable && !_found40mmGrenade):
    {
        #ifdef FEEDBACK_MODE
            systemChat "Only a throwable grenade in the inventory can be used.";
        #endif

        _strHint = ["an <t underline='1'>infrared (IR)</t>",
                    "a <t underline='1'>colored smoke</t>"] select _isMarkingWithSmoke;

        hint parseText format ["<t align='left'>Use %1 grenade in your inventory to mark the LZ.</t>", _strHint];
    };

    case (!_playerHasThrowable && _found40mmGrenade):
    {
        #ifdef FEEDBACK_MODE
            systemChat "Only a launchable grenade in the inventory can be used.";
        #endif

        _magsToUse = [_markerMag, (_markerMag select 1)] select _isMarkingWithSmoke;
        
        hint parseText "<t align='left'>Use your weapon's <t underline='1'>grenade launcher</t> to mark the LZ with smoke.</t>";
    };

    case (_playerHasThrowable && _found40mmGrenade):
    {
        #ifdef FEEDBACK_MODE
            systemChat "Both throwable and launchable grenades in the inventory can be used.";
        #endif

        _magsToUse = [_markerMag, (_markerMag select 0) + (_markerMag select 1)] select _isMarkingWithSmoke;
    
        hint parseText "<t align='left'>Use either a <t underline='1'>smoke grenade</t> or your weapon's <t underline='1'>grenade launcher</t> to mark the LZ with smoke.</t>";
    };

    default
    {
        #ifdef FEEDBACK_MODE
            systemChat "No throwable or launchable grenades in the inventory can be used. Attempting to add a usable throwable...";
        #endif

        // Smoke or IR
        if (_isMarkingWithSmoke) then {
            _grenadeToThrow = _magsToUse select 5;
        } else {
            _grenadeToThrow = switch (playerSide) do
            {
                case west:       { _magsToUse select 0 };
                case east:       { _magsToUse select 1 };
                case resistance: { _magsToUse select 2 };
            };
        };

        // Make sure player has inventory space
        if (player canAdd _grenadeToThrow) then {
            player addMagazine _grenadeToThrow;
        } else {
            hint "Free up some inventory space in order to receive an item to mark the LZ.";

            waitUntil { (player canAdd _grenadeToThrow) };
            sleep 0.5;

            player addMagazine _grenadeToThrow;
        };

        _strHint = ["<t color='#DB7093'>infrared (IR)</t>",
                    "<t color='#FF7F50'>orange smoke</t>"] select _isMarkingWithSmoke;
        
        hint parseText format ["<t align='left'>An %1 grenade has been added to your inventory. Use it to mark the LZ.</t>", _strHint];
    };
};

_magsToUse