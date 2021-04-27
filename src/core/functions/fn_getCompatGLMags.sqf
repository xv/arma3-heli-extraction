/* 
 * Author(s):
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Iterates through hardcoded vanilla, CUP and RHS 40mm smoke magazines that
 *     are compatible with the player's current primary weapon and returns them.
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

_result = [];
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

_launcherTypes =
[
    "UGL",               // Vanilla
    "EGLM",              // Vanilla
    "GL_3GL_F",          // Vanilla
    "M203_GL",           // RHS
    "M320_GL",           // RHS
    "VHS_BG",            // RHS
    "GP25Muzzle",        // RHS, CUP
    "PBG40Muzzle",       // RHS
    "AG36Muzzle",        // RHS, CUP
    "EGLMMuzzle",        // CUP
    "M203",              // CUP
    "AG36",              // CUP
    "L85_UGL",           // CUP
    "XM320Muzzle",       // CUP
    "CUP_CZ_805_G1",     // CUP
    "CUP_CZ_805_G1_SA58" // CUP
];

if (_launcher in _launcherTypes) then
{
    _vanillaMags =
    [
        "1Rnd_SmokeRed_Grenade_shell",
        "1Rnd_SmokeGreen_Grenade_shell",
        "1Rnd_SmokeYellow_Grenade_shell",
        "1Rnd_SmokePurple_Grenade_shell",
        "1Rnd_SmokeBlue_Grenade_shell",
        "1Rnd_SmokeOrange_Grenade_shell"
    ];

    // 3GL mags exclusive to the vanilla MX rifle (arifle_MX_GL_*)
    _vanilla3RndMags =
    [
        "3Rnd_SmokeRed_Grenade_shell",
        "3Rnd_SmokeGreen_Grenade_shell",
        "3Rnd_SmokeYellow_Grenade_shell",
        "3Rnd_SmokePurple_Grenade_shell",
        "3Rnd_SmokeBlue_Grenade_shell",
        "3Rnd_SmokeOrange_Grenade_shell"
    ];
    
    _rhsM7xxMags =
    [
        "rhs_mag_m713_Red",
        "rhs_mag_m715_Green",
        "rhs_mag_m716_yellow"
    ];
    
    _cupM203Mags =
    [
        "CUP_1Rnd_SmokeRed_M203",
        "CUP_1Rnd_SmokeGreen_M203",
        "CUP_1Rnd_SmokeYellow_M203"
    ];
    
    _rhsOpforMags =
    [
        "rhs_GRD40_Green",
        "rhs_GRD40_Red",
        "rhs_VG40MD_Green",
        "rhs_VG40MD_Red"
    ]; 

    _cupOpforMags =
    [
        "CUP_1Rnd_SmokeRed_GP25_M",
        "CUP_1Rnd_SmokeGreen_GP25_M",
        "CUP_1Rnd_SmokeYellow_GP25_M"
    ];

    switch (_launcher) do
    {
        case "UGL";
        case "EGLM";
        case "EGLMMuzzle";
        case "M320_GL";
        case "M203";
        case "M203_GL";
        case "VHS_BG";
        case "AG36";
        case "AG36Muzzle";
        case "L85_UGL";
        case "XM320Muzzle";
        case "CUP_CZ_805_G1";
        case "CUP_CZ_805_G1_SA58":
        {
            
            _vanillaMags append _rhsM7xxMags;
            _vanillaMags append _cupM203Mags;
        };
        
        case "GL_3GL_F":
        {
            _vanillaMags append _vanilla3RndMags;
            _vanillaMags append _rhsM7xxMags;
            _vanillaMags append _cupM203Mags;
        };

        case "GP25Muzzle";
        case "PBG40Muzzle":
        {
            _vanillaMags = _rhsOpforMags;
            _vanillaMags append _cupOpforMags;
        };
    };

    _result = [_launcher, _vanillaMags];
};

_result
