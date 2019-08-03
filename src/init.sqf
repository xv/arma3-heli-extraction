trig_execScript = createTrigger ["EmptyDetector", getPos player];
trig_execScript setTriggerActivation ["ALPHA", "PRESENT", true];
trig_execScript setTriggerStatements ["this", "script = [] execVM 'core\scripts\extraction.sqf'", ""];
trig_execScript setTriggerText "Request Extraction";