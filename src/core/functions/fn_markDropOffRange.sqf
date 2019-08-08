/* 
 * Author:
 *     Jad Altahan (https://github.com/xv)
 *
 * Description:
 *     Creates a "range" marker that indicates the minimum position allowed to
 *     mark the drop off zone.
 *
 * Parameter(s):
 *     0: The position where the marker is created.
 *     1: The radius of the marker circle.
 *
 * Returns:
 *     Nothing.
 */

params ["_startingPos", "_range"];

_rangeMarker = createMarkerLocal ["range_marker", _startingPos];
_rangeMarker setMarkerSizeLocal [_range, _range];
_rangeMarker setMarkerShapeLocal "ELLIPSE";
_rangeMarker setMarkerColorLocal "colorRed";
_rangeMarker setMarkerBrushLocal "SolidBorder";
_rangeMarker setMarkerAlphaLocal 0.12;