/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Creates a marker that indicates where the drop off zone is located.
 *
 * Parameter(s):
 *     0: The position where the marker is created.
 *
 * Returns:
 *     Nothing.
 */

params ["_zone"];

_dropOffMarker = createMarkerLocal ["dropoff_marker", _zone];
_dropOffMarker setMarkerShapeLocal "ICON";
_dropOffMarker setMarkerTypeLocal "MIL_END";
_dropOffMarker setMarkerColorLocal "ColorBlack";
_dropOffMarker setMarkerTextLocal "Drop Off";