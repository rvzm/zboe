namespace eval zboe {
	namespace eval settings {
		variable version "0.2"
		variable build "081805"
		variable release "r0"
		variable debug "1"
		namespace eval gen {
			variable pubtrig "@"
			variable controller "~z"
			variable homechan "#bots"
		}
		namespace eval hunt {
			variable trigger "14"
			variable time "3"
			variable horde "no"
			variable maxhorde "5"
			variable roast "no"
			variable startonjoin "yes"
		}
		namespace eval shop {
			variable clips "2"
			variable lvlup "2"
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