Synopsis 📜
===========
This is my neat little helicopter extraction script for ArmA II/OA. What makes this script different than any other extraction script ever released for the ArmA series is that it applies a bit more realism and complexity. Extraction requests are called via smoke grenade after triggering the script from the radio menu. The spawned helicopter is also dependent on the player's side and faction. Once the helicopter lands at the requested grid position, you can board it and select a drop off location by clicking on the map.

Helicopter + crew invincibility is also optional. However, disabling invincibility can put the helicopter at risk of getting shot down. If that happens, the player will be notified that it has been destroyed; however, you will not be able to request another one.

Porting to ArmA III
-------------------
Well, actually, this script was originally written for ArmA III, but I decided to ditch it and move it to ArmA II. The syntax is most likely compatible with ArmA III. You would have to do minor edits to the code regarding the faction and vehicle class names to get it to work.

Usage
-----
I have included a sample mission with everything set and ready for usability.<br/>The long way:

1. Copy `description.ext`, `stringtable.csv` and `0x141 folder` to your custom mission folder.
2. Go in-game and create a new `trigger`. Set the activation to Radio Alpha. In the activation field, add this line:
```SQF
script = [] execVM "0x141\Scripts\HeliExtraction.sqf"
```

Contact
-------
Your love letters &nbsp;&nbsp;&nbsp;> hello@exr.be
<br/>
Tweet me maybe?   > [0x141](https://twitter.com/0x141)

Legal
-----
This project is distributed under the [MIT License](https://opensource.org/licenses/MIT)
