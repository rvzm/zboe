#  zboe 0.1 by rvzm
 zombie  hunting game for eggdrop

# INSTALL
 clone into eggdrop scripts/ folder
 
 add "source scripts/zboe/main.tcl" to your conf

 edit scripts/zboe/zboe-settings.tcl to your liking
 
# USAGE
 zboe can be started several ways. Firsty, if "start on join" is enabled, it will start an active hunt upon joining the "home channel"
 
 Otherwise, use "[pubtrig]zboe hunt start"
 
 -
 
 zboe will track XP, ammo, clips, and Horde Tokens. It features a reloading system, and soon a fully featured shop, but currently the shop is free and only offers clips.
 
 Horde Tokens will be used to make "player upgrades" for things like better accuracy, clip capacity and storage space, and boosts for things like xp, tracker ammo, etc.
 
 XP will be used to purchase level-ups, which will improve accuracy, clip capacity, and clip storage. These upgrades are permenant, however XP is used to purchase these and other items.
 

# SETTINGS 
 pugtrig - public trigger character. EXAMPLE: set to @ to use @shoot, or ^ to use ^shoot, etc

 controller - owner control command, whole command goes here, not just trigger character

 homechan - The channel you want the script to run on.

# HUNT SETTINGS
 trigger - trigger sensitivity, max of 15. higher means more encounters

 accuracy - difficulty, lower means more misses. max of 100

 time - how often, in minutes, the system should "roll for an enounter"

 multiz - have more than one zombie at a time? [added in build 081800]

 roast - roast players for not hitting the zombie, when mutliz is disabled and a new encounter would spawn a zombie

 startonjoin - start an active hunt session when zboe joins the homechan 
 
 maxhorde - maximum horde size for multi-zombie mode