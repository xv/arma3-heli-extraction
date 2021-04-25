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

if (_isRHS) then {
    _vehicle animateDoor ["doorLB", _state];
    _vehicle animate ["doorHandler_L", _state];
    _vehicle animateDoor ["doorRB", _state];
    _vehicle animate ["doorHandler_R", _state];
} else {
    _vehicle animateDoor ["door_L", _state];
    _vehicle animateDoor ["door_R", _state];
};