trig_execScript = createTrigger ["EmptyDetector", getPos player];
trig_execScript setTriggerActivation ["ALPHA", "PRESENT", true];
trig_execScript setTriggerStatements ["this", "script = [] execVM 'core\scripts\extraction.sqf'", ""];

1 setRadioMsg "Request Extraction";