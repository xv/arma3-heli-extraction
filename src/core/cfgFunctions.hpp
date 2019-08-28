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

        // call getMarkerMags
        class getMarkerMags;

        // [_startingPos, _range] call markDropOffRange
        class markDropOffRange;

        // [_zone] call markDropOffRange
        class markDropOffZone;

        // [_zone] call markExtractionZone
        class markExtractionZone;

        // [_spawnRefPos, _spawnRange, _spawnDir, _spawnHeight] call spawnHelicopter;
        class spawnHelicopter;

        // [_vehicle, _wpPos] call wpMoveToDropOffZone
        class wpMoveToDropOffZone;

        // [_vehicle, _wpPos] call wpMoveToExtractionZone
        class wpMoveToExtractionZone;

        // [_vehicle, _wpPos] call wpReturnToBase
        class wpReturnToBase;
    };
};