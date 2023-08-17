namespace eval zboe {
	namespace eval settings {
		variable version "0.1-dev"
		variable build "001"
		variable release "r0"
		variable debug "1"
		namespace eval gen {
			variable pubtrig "@"
			variable controller "~z"
			variable nick "zboe"
			variable homechan "#fuknz"
		}
		namespace eval hunt {
			# hunt trigger, higher means more often, max of 15
			variable trigger "15"
			variable accuracy "7"
			variable time "5"
			variable multiz "no"
			variable roast "yes"
		}
		namespace eval flags {
			setudef flag zbot
			setudef flag zr1
			setudef flag zr2
			setudef flag zr3
			setudef flag zr4
			setudef flag zr5
			setudef flag zrc
		}
	}
}
putlog "zboe Zombie Hunting Game - settings loaded";