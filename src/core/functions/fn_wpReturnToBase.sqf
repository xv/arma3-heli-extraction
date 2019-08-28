/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Creates a waypoint for the target helicopter fly back to the original
 *     spawn location, from which it will be deleted along with its crew and
 *     prepare the script to be reused again.
 *
 * Parameter(s):
 *     0: The vehicle to set a waypoint for.
 *     1: The position of the waypoint.
 *
 * Returns:
 *     Nothing.
 */

params ["_vehicle", "_wpPos"];

_wpRtb = (group _vehicle) addWaypoint [_wpPos, 2];
_wpRtb setWaypointName "wpRtb";
_wpRtb setWaypointType "MOVE";

// Delete the helicopter + crew and clean up the script for usage again
_wpRtb setWaypointStatements
[
    "true",
    "{deletevehicle _x} foreach (crew vehicle this + [vehicle this]);
     trig_execScript setTriggerText 'Request Extraction';
     deleteVehicle hiddenHelipad;
     deleteMarkerLocal 'base_marker';"
];