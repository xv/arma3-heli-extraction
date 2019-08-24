/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Creates a waypoint for the target helicopter to land on (drop off).
 *
 * Parameter(s):
 *     0: The vehicle to set a waypoint for.
 *     1: The position of the waypoint.
 *
 * Returns:
 *     Nothing.
 */

params ["_vehicle", "_wpPos"];

_wpDropOffZone = (group _vehicle) addWaypoint [_wpPos, 1];
_wpDropOffZone setWaypointName "wpMoveDropOff";
_wpDropOffZone setWaypointType "MOVE";
_wpDropOffZone setWaypointSpeed "NORMAL";
_wpDropOffZone setWaypointDescription "Drop off zone";
_wpDropOffZone setWaypointStatements ["true", "vehicle this land 'GET OUT';"];