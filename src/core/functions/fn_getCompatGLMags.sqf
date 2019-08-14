/* 
 * Author(s):
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Iterates through hardcoded vanilla and RHS 40mm smoke magazines that are
 *     compatible with the player's current primary weapon and returns them.
 *
 * Parameter(s):
 *     Nothing.
 *
 * Returns:
 *     ARRAY - if the player's primary weapon has an underbarrel grenade
 *     launcher, the function will return an array containing the muzzle class
 *     name for the launcher along with its compatible magazines. If there are
 *     no compatible magazines or the weapon does not have a launcher or the
 *     player does not have a primary weapon equipped, an empty array will be
 *     returned.
 */

private ["_result"];

_primaryWeapon = primaryWeapon player;

if (_primaryWeapon == "") exitWith { [] };

/* - The "muzzles" array is always in the format of ["this","blah","blah","etc"].
 *
 * - Vanilla weapons with grenade launchers will return ["this", "gl_classname"].
 *   Otherwise, just ["this"].
 *
 * - RHS weapons with grenade launchers will return ["this", "gl_classname", "SAFE"].
 *   Otherwise, just ["this", "SAFE"]. "SAFE" is the weapon's safety switch.
 *
 * - RHS M32 and RHS M79 don't have muzzles (returns only ["this"]) because
 *   they are primary GLs to begin with.
 */
_primaryMuzz = getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "muzzles");
_launcher = _primaryMuzz select 1;

// Player isn't using a rifle with a grenade launcher
if (isNil "_launcher") exitWith { [] };
if (_launcher isEqualTo "SAFE") exitWith { [] };

// Vanilla and RHS GL muzzles that are returned by _launcher
_launcherTypes =
[
    "UGL",
    "EGLM",
    "GL_3GL_F",
    "M203_GL",
    "M320_GL",
    "VHS_BG",
    "GP25Muzzle",
    "PBG40Muzzle",
    "AG36Muzzle"
];

if (_launcher in _launcherTypes) then
{
    // Standard mags that all vanilla GLs can use
    _smokeMags =
    [
        "1Rnd_SmokeRed_Grenade_shell",
        "1Rnd_SmokeGreen_Grenade_shell",
        "1Rnd_SmokeYellow_Grenade_shell",
        "1Rnd_SmokePurple_Grenade_shell",
        "1Rnd_SmokeBlue_Grenade_shell",
        "1Rnd_SmokeOrange_Grenade_shell"
    ];

    // These ones are exclusive to the vanilla MX rifle (arifle_MX_GL_*)
    // and RHS M320
    _3RndMags =
    [
        "3Rnd_SmokeRed_Grenade_shell",
        "3Rnd_SmokeGreen_Grenade_shell",
        "3Rnd_SmokeYellow_Grenade_shell",
        "3Rnd_SmokePurple_Grenade_shell",
        "3Rnd_SmokeBlue_Grenade_shell",
        "3Rnd_SmokeOrange_Grenade_shell"
    ];

    // Mags used in EGLM, UGL, RHS M203, RHS M320, RHS AG36, RHS M79
    _rhsMags =
    [
        "rhs_mag_m713_Red",
        "rhs_mag_m715_Green",
        "rhs_mag_m716_yellow"
    ];

    // Special mags only used with RHS GP25 and RHS PBG40 launchers. Their
    // corresponding muzzles only accept these as well
    _rhsMagsSpec =
    [
        "rhs_GRD40_Red",
        "rhs_GRD40_Green",
        "rhs_VG40MD_Red",
        "rhs_VG40MD_Green"
    ];

    switch (_launcher) do
    {
        case "GL_3GL_F";
        case "M320_GL":
        { _smokeMags append (_3RndMags + _rhsMags) };

        case "UGL";
        case "EGLM";
        case "M203_GL";
        case "VHS_BG";
        case "AG36Muzzle":
        { _smokeMags append _rhsMags };

        case "PBG40Muzzle";
        case "GP25Muzzle":
        { _smokeMags = _rhsMagsSpec };
    };

    _result = [_launcher, _smokeMags];
};

_result