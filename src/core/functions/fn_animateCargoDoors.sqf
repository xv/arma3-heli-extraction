/* 
 * Author(s):
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Attempts to open the cargo doors of the specified vehicle.
 *
 * Parameter(s):
 *     0: Reference to the vehicle to animate its cargo doors.
 *     1: Set to true if animating doors for a RHS mod vehicle.
 *     2: Set to 1 to open the door, 0 to close it.
 *
 * Returns:
 *     Nothing.
 */

params ["_vehicle", "_isRHS", "_state"];

private _cargoDoorLeft = "door_L";
private _cargoDoorRight = "door_R";

if (_isRHS) then
{
    _cargoDoorLeft = "doorLB";
    _cargoDoorRight = "doorRB";
};

_vehicle animateDoor [_cargoDoorLeft, _state];
_vehicle animateDoor [_cargoDoorRight, _state];
