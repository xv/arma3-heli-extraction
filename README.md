Synopsis 📜
===========
This is my neat little helicopter extraction script for Arma III. What makes this script different than any other extraction script ever released for the Arma series is that it applies a bit more realism and complexity. Extraction requests are called via smoke grenade after triggering the script from the radio menu. The spawned helicopter is also dependent on the player's side and faction. Once the helicopter lands at the marked grid position, you can board it and select a drop off location by clicking on the map. After exiting the helicopter at the designated drop off location, the helicopter will take off and return to the point where it was spawned by the script. Then it will be deleted along with its crew.

The helicopter spawn position is random. It can arrive from any direction.

Helicopter + crew invincibility is also optional (enabled by default; can be changed by modifying the script). However, disabling invincibility can put the helicopter at risk of getting shot down. If that happens, the player will be notified that it has been destroyed; however, you will not be able to request another one.

Porting to Arma II/OA
---------------------
Well, actually, this script was written for Arma II, but it had been moved to Arma III as Arma II's community started fading away due to the release of a new Arma game. The syntax of this script is fully compatible with Arma II. All you need to do is edit the faction and vehicle class names to the ones used by Arma II and the script should run without any problems.

For class names, see:

[/wiki/faction](https://community.bistudio.com/wiki/faction)<br>
[/wiki/ArmA_2:_Vehicles](https://community.bistudio.com/wiki/ArmA_2:_Vehicles)<br>
[/wiki/ArmA_2_OA:_Vehicles](https://community.bistudio.com/wiki/ArmA_2_OA:_Vehicles)

Support for RHS Mod
-------------------
Support for RHS factions is added. If you execute the script while playing as a RHS unit, the script will spawn a helicopter from the faction of the player character.

Usage
-----
This should be fairly easy for anyone to do.

1. Copy the content of `\src\` folder to your missions folder in `\Documents\Arma 3\missions\<missionName>`
2. Open your mission in Eden Editor and create a new `Trigger`. Set the activation preference to Radio Alpha. You can make the script repeatable if you want to. In the `On Activation` field, add this line:
```SQF
script = [] execVM "Core\scripts\HeliExtraction.sqf"
```
3. Launch your mission and dial 0-0-1. The script will begin. Follow the its given instructions. Voila!

Contact
-------
[Email me your love letters](mailto:xviyy@aol.ca)
<br/>
[Tweet me maybe?](https://twitter.com/xviyy)

Legal
-----
This project is distributed under the terms of the [MIT License](https://opensource.org/licenses/MIT).
