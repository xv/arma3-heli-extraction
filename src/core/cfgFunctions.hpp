class Hunnu
{
    tag = "xv";

    class Extraction
    {
        file = "core\functions";

        // [_vehicle, _isRHS, _state] call animateCargoDoors
        class animateCargoDoors;

        // [_magClass] call canUseGLMag
        class canUseGLMag;

        // [_object, _minDist, _maxDist, _vehicle] call findLandingPos
        class findLandingPos;

        // call getCompatGLMags
        class getCompatGLMags;

        // [_startingPos, _range] call fn_markDropOffRange
        class markDropOffRange;

        // [_zone] call fn_markDropOffRange
        class markDropOffZone;

        // [_zone] call markExtractionZone
        class markExtractionZone;

        // [_vehicle, _wpPos] call moveToDropOffZone
        class moveToDropOffZone;

        // [_vehicle, _wpPos] call moveToExtractionZone
        class moveToExtractionZone;

        // [_vehicle, _wpPos] call returnToBase
        class returnToBase;
    };
};