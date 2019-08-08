/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Creates a marker that indicates where the landing zone is located.
 *
 * Parameter(s):
 *     0: The position where the marker is created.
 *
 * Returns:
 *     Nothing.
 */

params ["_zone"];

_extractionMarker = createMarkerLocal ["extraction_marker", _zone];
_extractionMarker setMarkerShapeLocal "ICON";
_extractionMarker setMarkerTypeLocal "MIL_PICKUP";
_extractionMarker setMarkerColorLocal "ColorBlack";
_extractionMarker setMarkerTextLocal "Extraction Zone";