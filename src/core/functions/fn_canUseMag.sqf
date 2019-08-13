/* 
 * Author(s):
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Checks if the magazine belongs to a 40mm smoke grenade that can be
 *     fired from the player's underbarrel grenade launcher.
 *
 * Parameter(s):
 *     0: STRING - represents a magazine class name.
 *
 * Returns:
 *     BOOL - true if the given magazine can be fired from the player's
 *     underbarrel grenade launcher, false otherwise.
 */

_magClass = _this param [0, "", [""]];

_smokeMags = call xv_fnc_getCompatGLMags;

if (count _smokeMags == 0) exitWith { false };

_launcher = _smokeMags select 0;
_compatMags = _smokeMags select 1;

_result = (_magClass in _compatMags);

_result