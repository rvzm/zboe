#  zboe 0.1 by rvzm
 zombie  hunting game for eggdrop

# INSTALL
 clone into eggdrop scripts/ folder
 
 add "source scripts/zboe/main.tcl" to your conf

 edit scripts/zboe/zboe-settings.tcl to your liking

# SETTINGS 
 pugtrig - public trigger character. EXAMPLE: set to @ to use @shoot, or ^ to use ^shoot, etc

 controller - owner control command, whole command goes here, not just trigger character

 homechan - The channel you want the script to run on.

# HUNT SETTINGS
 trigger - trigger sensitivity, max of 15. higher means more encounters

 accuracy - difficulty, lower means more misses. max of 100

 time - how often, in minutes, the system should "roll for an enounter"

 multiz - have more than one zombie at a time? [NOT DONE]

 roast - roast players for not hitting the zombie, when mutliz is disabled and a new encounter would spawn a zombie

startonjoin - start an active hunt session when zboe joins the homechan 