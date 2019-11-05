/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Generates a random integer between two specified values.
 *
 * Parameter(s):
 *     0: INTEGER - the first value.
 *     1: INTEGER - the second value.
 *     2: BOOLEAN - if true, the generated integer can be either positive or
 *                  negative, otherwise, only positive.
 *
 * Returns:
 *     INTEGER - the generated random integer.
 */

params ["_min", "_max", "_signed"];

_diff = (_max + 1) - _min; 
_rand = floor((random _diff) + _min);

if (_signed && (floor(random 2) != 1)) then {
    _rand = _rand * -1
};

_rand