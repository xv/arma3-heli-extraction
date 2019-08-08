Synopsis
========
This is my neat little helicopter extraction script for Arma III. What makes this script different than any other extraction script ever released for the Arma series is that it applies a bit more realism and complexity. Extraction requests are called via smoke grenade after triggering the script from the radio menu. The spawned helicopter is also dependent on the player's side and faction. Once the helicopter lands at the marked grid position, you can board it and select a drop off location by clicking on the map. After exiting the helicopter at the designated drop off location, the helicopter will take off and return to the point where it was spawned by the script. Then it will be deleted along with its crew.

The helicopter spawn position is random. It can arrive from any direction.

Helicopter + crew invincibility is also optional (enabled by default; can be changed by modifying the script). However, disabling invincibility can put the helicopter at risk of getting shot down. If that happens, the player will be notified that it has been destroyed. You will not be able to request another one, however.

Porting to Arma II/OA
---------------------
Well, actually, this script was written for Arma II, but it had been moved to Arma III as Arma II's community started fading away due to the release of a new Arma game. The syntax of this script is no logner compatible with Arma II since it uses commands that were introduced in Arma III. However, if you can get around the new commands, it can be ported easily. All you would need to do is uncomment the legacy `BIS_fnc_init` function, edit the class names to the ones used by Arma II and the script should run without any problems.

For class names, see:

[/wiki/faction](https://community.bistudio.com/wiki/faction)<br>
[/wiki/ArmA_2:_Vehicles](https://community.bistudio.com/wiki/ArmA_2:_Vehicles)<br>
[/wiki/ArmA_2_OA:_Vehicles](https://community.bistudio.com/wiki/ArmA_2_OA:_Vehicles)

Here are commands used in the script that were introduced in Arma III:

| Command      | Community Wiki Page                                                |
|:------------:|--------------------------------------------------------------------|
| `canAdd`     | [/wiki/canAdd](https://community.bistudio.com/wiki/canAdd)         |
| `findIf`     | [/wiki/findIf](https://community.bistudio.com/wiki/findIf)         |
| `distance2D` | [/wiki/distance2D](https://community.bistudio.com/wiki/distance2D) |

Multiplayer Support
-------------------
The script has never been tested in an online environment and will most likely not work on as-is basis since it uses a lot of local commands. Will I ever bother with trying to make it work online? No. If you run a server, go ahead and tinker with it all you want.

CUP & RHS Support
-----------------
Support for Community Upgrade Project and Red Hammer Studios mods is included. If the script detects that your player unit belongs to a CUP or RHS faction, the extraction helicopter will be part of the said faction.

RHS support goes beyond non-vanilla helicopters. Since RHS units carry custom magazines, support for mod's-exclusive grenades is also included. The script will let you use your RHS smoke grenades to mark the landing zone.

ACE Compatibility
-----------------
The compatibility status with Advanced Combat Environment 3 (ACE 3) mod is unknown as of 27/7/2019. This script may or may not fucntion properly when ACE is active.

Usage
-----
This should be fairly easy for anyone to do.

1. Copy the content of `\src\` to your missions folder at `\Documents\Arma 3\missions\<missionName>`
2. Launch your mission and dial 0-0-1. The script will execute. Follow its given on-screen instructions. Voila!

Note: `init.sqf` creates the Trigger object that is used to execute the script via radio slot 1 (ALPHA). If you need the slot for something else, you can change it to whatever you wish. See [/wiki/setTriggerActivation](https://community.bistudio.com/wiki/setTriggerActivation) for other slot choices.

Legal
-----
This project is distributed under the terms of the [MIT License](https://opensource.org/licenses/MIT).
