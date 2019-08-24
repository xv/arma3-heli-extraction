/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Creates a waypoint for the target helicopter to land on (pick up).
 *
 * Parameter(s):
 *     0: The vehicle to set a waypoint for.
 *     1: The position of the waypoint.
 *
 * Returns:
 *     Nothing.
 */

params ["_vehicle", "_wpPos"];

_wpExtractionZone = (group _vehicle) addWaypoint [_wpPos, 0];
_wpExtractionZone setWaypointType "MOVE";
_wpExtractionZone setWaypointSpeed "NORMAL";
_wpExtractionZone setWaypointDescription "Extraction zone";
_wpExtractionZone setWaypointStatements ["true", "vehicle this land 'GET IN';"];