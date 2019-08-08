#include "..\component.hpp"

/* 
 * Author(s):
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Attempts to find a suitable position for the helicopter to land on.
 *
 * Parameter(s):
 *     0: Object to use as a reference point.
 *     1: The minimum distance from the object to perform the search after.
 *     2: The maximum search area.
 *     3: Class name for a vehicle to accommodate its size.
 *
 * Returns:
 *     A suitable position in the format of Position3D or the position of the
 *     referenced object if <findEmptyPosition> failed to find an empty spot.
 */

params ["_object", "_minDist", "_maxDist", "_vehicle"];

private _landingPos = (getPos _object) findEmptyPosition [_minDist, _maxDist, _vehicle];

if (_landingPos isEqualTo []) then
{
    #ifdef FEEDBACK_MODE
        systemChat "Failed to find an empty position. Using the default one...";
    #endif
    
    _landingPos = getPos _object;
};

_landingPos