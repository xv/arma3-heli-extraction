// For developing/testing, uncomment this directive if you want to see some
// helpful feedback messages or visual cues while the script is running
// #define FEEDBACK_MODE

// This directive defines, in meters, how far the helicopter spawns from the
// player. The larger the value the longer it takes for the helicopter to arrive
#define EXTRACT_HELI_SPAWN_DISTANCE 2500

// Enables the invincibility of the helicopter and the player + teammates when
// inside the helicopter
//
// Comment out this directive to disable the invincibility behaviour
#define EXTRACT_HELI_INVINCIBLE

// Uncomment this directive to make enemy AI not fire at the helicopter as if
// it is one of their own. They may, however, still fire at you or your
// teammates if spotted
// #define EXTRACT_HELI_CAPTIVE

// Defines the time, in seconds, the extraction helicopter will wait for the
// player to board before it returns to base
#define EXTRACT_HELI_DUSTOFF_TIMER 85

// This directive sets the inaccessible inner radius when marking the drop off
// position on the map
#define DROPOFF_RANGE_MIN_RADIUS 1000