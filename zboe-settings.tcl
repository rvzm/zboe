namespace eval zboe {
	namespace eval settings {
		variable version "0.1"
		variable build "081800"
		variable release "r1"
		variable debug "1"
		namespace eval gen {
			variable pubtrig "@"
			variable controller "~z"
			variable homechan "#bots"
		}
		namespace eval hunt {
			variable trigger "12"
			variable accuracy "70"
			variable time "3"
			variable multiz "no"
			variable maxhorde "5"
			variable roast "no"
			variable startonjoin "yes"
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