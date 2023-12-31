namespace eval zboe {
	namespace eval settings {
		variable version "0.2d"
		variable build "090803"
		variable release "dev"
		variable debug "0"
		namespace eval gen {
			variable pubtrig "@"
			variable controller "~z"
			variable homechan "#bots"
			variable sqldir "~/public_html/huntsite/"
		}
		namespace eval hunt {
			variable trigger "8"
			variable time "5"
			variable horde "yes"
			variable maxhorde "3"
			variable roast "no"
			variable startonjoin "yes"
		}
		namespace eval shop {
			variable clips "2"
			variable lvlup "5"
			variable accuracyupgrade "2"
			variable clipupgrade "10"
			variable hordetokens "35"
			variable gungrease "45"
			variable newgun "105"
		}
		namespace eval flags {
			setudef flag zboe
			setudef flag hunt
		}
	}
}
putlog "zboe Zombie Hunting Game - settings loaded";