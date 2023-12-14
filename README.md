# when-menlons-attack
A gamemode for Garrysmod - using the fluffy minigames base


**REQUIRES:**
https://github.com/fluffy-servers/minigames_v2


**HOW TO INSTALL**

Put the folder "fluffy_whenmelonsattack" in with the rest of the fluffy_minigames gamemodes.


**ADDING MAPS**

Inside _/fluffy_whenmelonsattack/entities/entities/spawner/init.lua_ there is a set of co-ordinates for the melon spawners location and rotation.

Add your maps here, Vector and rotation can be found using the _getpos_ function using the in game console. (I advise, load the map up in sandbox, fly to where you want the spawner to go, and then run _getpos_, and then use these values in the above lua file, then test by running the gamemode).

The spawner makes no checks to see if its in bounds, so make sure it is!
