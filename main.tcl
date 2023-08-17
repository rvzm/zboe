# ##################################################
# ### zboe  - zombie hunting game ##################
# ### with web assisted stats     ##################
# ### Coded by rvzm               ##################
# ### --------------------------- ##################
# ### Version: 0.5                ##################
# ##################################################
if {[catch {source scripts/zboe/zboe-settings.tcl} err]} {
	putlog "Error: Could not load 'scripts/zboe/zboe-settings.tcl' file.";
}

namespace eval zboe {
	namespace eval binds {
		# Main Commands
		bind pub - ${zboe::settings::gen::pubtrig}zboe zboe::procs::zboe:main
		bind pub - ${zboe::settings::gen::pubtrig}regme zboe::procs::register
		bind pub - ${zboe::settings::gen::pubtrig}version zboe::procs::version
		bind pub - ${zboe::settings::gen::pubtrig}shoot zboe::procs::zhunt::shoot
		bind pub - ${zboe::settings::gen::pubtrig}shop zboe::procs::zhunt::shop
		bind pub - ${zboe::settings::gen::pubtrig}reload zboe::procs::zhunt::reload
		bind pub - ${zboe::settings::gen::pubtrig}zstats zboe::procs::zhunt::stats
		# Owner Commands
		bind pub m ${zboe::settings::gen::controller} zboe::procs::control
		# Autos
		bind join - * zboe::procs::zchampcheck
	}
	namespace eval procs {
		# Main Command Procs
		proc zboe:main {nick uhost hand chan text} {
			if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| main command sent $nick $chan - $text"; }
			set v1 [lindex [split $text] 0]
			if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| main command var 1 set"; }
			set v2 [lindex [split $text] 1]
			if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| main command var 1 set"; }
			set v3 [lindex [split $text] 2]
			if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| main command var 1 set"; }
			if {$v1 == ""} {
				if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| main command recieved no input, informing chan and halting"; }
				puthelp "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [zboe::procs::util::getTrigger]zboe help"; return
			}
			if {$v1 == "hunt"} {
				if {${zboe::settings::debug} == "1"} { putcmdlog "*** zboe|debug| main command recieved control for hunt - $v2"; }
				if {$v2 == "start"} {
					set zha "[zboe::procs::util::read_db zhunt.activehunt]"
					if {$zha == "no"} {
					zboe::procs::zhunt::starthunting;
					puthelp "PRIVMSG $chan :o.0.O.0.o Zombie hunt started! Keep an eye out for zombies!! o.0.O.0.o";
					return
					}
					if {$zha == "yes"} {
						puthelp "PRIVMSG $chan ::o.0.O.0.O There is already an active hunt o.0.O.0.o";
						return
					}
				}
				if {$v2 == "stop"} {
					if {[catch {[zboe::procs::util::read_db "zhunt.activehunt"]} err]} { zboe::procs::util::write_db "zhunt.activehunt" "no"; }
					set zha "[zboe::procs::util::read_db zhunt.activehunt]"
					if {$zha == "yes"} {
						zboe::procs::zhunt::stophunting;
						puthelp "PRIVMSG $chan :o.0.O.0.o Stopping the hunt... o.0.O.0.o";'
						return;
					}
					if {$zha == "no"} {
						puthelp "PRIVMSG $chan :o.0.O.0.O There is no active hunt o.0.O.0.o";
						return;
					}
				}
				if {$v2 == "restart"} {
					zboe::procs::zhunt::stophunting;
					puthelp "PRIVMSG $chan :o.0.O.0.o Restarting the hunt... o.0.O.0.o";
					zboe::procs::zhunt::starthunting;
					return
				}
				if {$v2 == "check"} {
					set zha "[zboe::procs::util::read_db zhunt.activehunt]"
					if {$zha == "yes"} {
						puthelp "PRIVMSG $chan :o.0.O.0.o Zombies about. Putting them away.";
						zboe::procs::util::write_db "zhunt.activehunt" "no";
						zboe::procs::zhunt::stophunting;
						return
					}
				}
			}
		}
		proc zcontrol {nick uhost hand chan text} {
			if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| zombie interact command sent $nick $chan - $text"; }
			set v1 [lindex [split $text] 0]
			if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| zombie interact command var 1 set"; }
			set v2 [lindex [split $text] 1]
			if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| zombie interact command var 1 set"; }
			set v3 [lindex [split $text] 2]
			if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| zombie interact command var 1 set"; }
			if {$v1 == ""} {
				if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| zombie interact command recieved no input, informing chan and halting"; }
				puthelp "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [zboe::procs::util::getTrigger]zboe help"; return
			}
			if {$v1 == ""} {
				if {${zboe::settings::debug} == "2"} { putcmdlog "*** zboe|debug| zombie interact command recieved command for "; }
			}
		}
		# Controller command
		proc control {nick uhost hand chan text} {
			set v1 [lindex [split $text] 0]
			set v2 [lindex [split $text] 1]
			putcmdlog "*** zboe controller $nick - $text"
			if {$v1 == "help"} {
				if {$v2 == "rehash"} { putserv "NOTICE $nick :zboe command 'rehash' - rehashes zboe conf and script files"; return }
				if {$v2 == "restart"} { putserv "NOTICE $nick :zboe command 'restart' - restarts zboe bot"; return }
				if {$v2 == "die"} { putserv "NOTICE $nick :zboe command 'die' - forces zboe bot to shut down"; return }
				if {$v2 == "info"} { putserv "NOTICE $nick :zboe command 'info' - displays current version information to channel"; return }
				if {$v2 == "register"} { putserv "NOTICE $nick :zboe command 'register' - registers zboe with the 'npass' and 'email' settings to nickserv"; return }
				if {$v2 == "group"} { putserv "NOTICE $nick :zboe command 'group' - uses nickserv to group zboe with the nick provided in the 'gnick' setting"; return }
				if {$v2 == "nsauth"} { putserv "NOTICE $nick :zboe command 'nsauth' - forces zboe to identify with nickserv using the 'npass' setting"; return }
				if {$v2 == ""} {
					putserv "NOTICE $nick :zboe controll commands - rehash restart die"
					putserv "NOTICE $nick :zboe nickserv commands - nsauth group register"
					return
					}
				putcmdlog "*** zboe controller $nick - help command error - no if statement triggered"
				}
			if {$v1 == "rehash"} {
				putserv "PRIVMSG $chan :Reloading configuration..."; 
				rehash;
				putserv "PRIVMSG $chan :Configuration file reloaded";
				return
				}
			if {$v1 == "restart"} { restart; return }
			if {$v1 == "die"} { die; return }
			if {$v1 == "info"} { putserv "PRIVMSG $chan :zboe.tcl running version [zboe::procs::util::getVersion]"; return }
			if {$v1 == "register"} { putserv "PRIVMSG NickServ :REGISTER [zboe::procs::util::getPass] [zboe::procs::util::getEmail]"; return }
			if {$v1 == "group"} { putserv "PRIVMSG NickServ :GROUP [zboe::procs::util::getGroupNick] [zboe::procs::util::getPass]"; return }
			if {$v1 == "nsauth"} {
				putserv "PRIVMSG NickServ :ID [zboe::procs::util::getPass]";
				putserv "PRIVMSG $chan :Authed to NickServ";
				return;
			}
		}
		proc version {nick uhost hand chan text} {
			putserv "PRIVMSG $chan :zboe -> version-[zboe::procs::util::getVersion] build [zboe::procs::util::getBuild]"
			putserv "PRIVMSG $chan :zboe -> release: [zboe::procs::util::getRelease]"
			return
		}
		proc register {nick uhost hand chan text} {
			if {[validuser $hand] == "1"} { putserv "PRIVMSG $chan :Sorry $nick, but you're already registered. :)"; return }
			if {[adduser $hand $uhost] == "1"} {
				putserv "PRIVMSG [zboe::procs::util::homechan] :*** Introduced user - $nick / $uhost"
				putlog "*** Introduced to user - $nick / $uhost"
				putserv "PRIVMSG $chan :Congradulations, $nick! you are now in my system! yay :)"
				} else { putserv "PRIVMSG $chan :Addition failed." }
			return
		}
		# Utility procs
		namespace eval zhunt {
			proc starthunting {} {
				set chan ${zboe::settings::gen::homechan}
				timer ${zboe::settings::hunt::time} zboe::procs::zhunt::zcheck 0 zhunttimer
			}
			proc stophunting {} {
				set chan ${zboe::settings::gen::homechan}
				killtimer zhunttimer
			}
			proc zcheck {} {
				if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| zombie check - rolling encounter"; }
				set chan ${zboe::settings::gen::homechan}
				set tchk "[rand 15]"
				if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| zcheck $tchk"; }
				set zha "[zboe::procs::util::read_db zhunt.activehunt]"
				if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| zcheck active $zha"; }
				if {$zha == "yes"} {
					putcmdlog "*** zboe|debug| zcheck - halting, zombie still loose"
					if {${zboe::settings::hunt::multiz} == "yes"} { 
						
					}
					if {${zboe::settings::hunt::roast} == "yes"} { puthelp "PRIVMSG $chan :o.0.O.0.o There would've been another zombie, but y'all havent hit this one yet."; }
					return
					}

				if {$tchk <= ${zboe::settings::hunt::trigger}} {
					if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| DER BE ZOMBIES"; }
					puthelp "PRIVMSG $chan :o.0.O.0.o Zombie Spotted! Shoot that fucker!";
					zboe::procs::util::write_db "zhunt.activehunt" "yes";
					return
				}
				if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| no zombie"; }
			}
			proc stats {nick uhost hand chan text} {
				set v1 [lindex [split $text] 0]
				if {$v1 == ""} {
					set zpf zhunt.$nick.xp
					#if {[catch {[zboe::procs::util::read_db "$zpf"]} err]} { zboe::procs::util::write_db $zpf "0"; }
					set zpsx "[zboe::procs::util::read_db $zpf]"
					puthelp "PRIVMSG $chan :o.0.O.0.o You have $zpsx xp!";
					return
				}
			}
			proc reload {nick uhost hand chan text} {
				
			}
			proc shoot {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| shoot command sent $nick $chan"; }
				set zschk "[zboe::procs::util::read_db zhunt.activehunt]"
				if {$zschk == "yes"} {
					set zpacc ${zboe::settings::hunt::accuracy}
					set zpchk "[rand 99]"
					if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|debug| shoot acc: $zpacc check: $zpchk "; }
					if {$zpchk <= $zpacc} {
						puthelp "PRIVMSG $chan :o.0.O.0.o ayyy $nick hit the zombie!! They get 1xp"
						set zpf zhunt.$nick.xp
						set zpx "[zboe::procs::util::read_db $zpf]"
						incr zpx
						zboe::procs::util::write_db "zhunt.$nick.xp" $zpx
						zboe::procs::util::write_db "zhunt.activehunt" "no";
						return
					}
					puthelp "PRIVMSG $chan :o.0.O.0.o oops, you fuckin missed gaylord";
					return
				}
				puthelp "PRIVMSG $chan :o.0.O.0.o there isnt a fuckin zombie gaylord";
				return;
			}
			proc shop {nick uhost hand chan text} {
				set v1 [lindex [split $text] 0]
				set v2 [lindex [split $text] 1]
			}
		}
		namespace eval util {
			# write to *.db files
			proc write_db { w_db w_info } {
				set fs_write [open $w_db w]
				puts $fs_write "$w_info"
				close $fs_write
			}
			# read from *.db files
			proc read_db { r_db } {
				set fs_open [open $r_db r]
				gets $fs_open db_out
				close $fs_open
				return $db_out
			}
			# create *.db files, servers names files
			proc create_db { bdb db_info } {
				if {[file exists $bdb] == 0} {
					set crtdb [open $bdb a+]
					puts $crtdb "$db_info"
					close $crtdb
				}
			}
			proc getVersion {} {
				global zboe::settings::version
				return $zboe::settings::version
			}
			proc getBuild {} {
				global zboe::settings::build
				return $zboe::settings::build
			}
			proc getRelease {} {
				global zboe::settings::release
				return $zboe::settings::release
			}
			proc getTrigger {} {
				global zboe::settings::gen::pubtrig
				return $zboe::settings::gen::pubtrig
			}
			proc getPass {} {
				global zboe::settings::gen::npass
				return $zboe::settings::gen::npass
			}
			proc getEmail {} {
				global zboe::settings::gen::email
				return $zboe::settings::gen::email
			}
			proc getGroupNick {} {
				global zboe::settings::gen:gnick
				return $zboe::settings::gen::gnick
			}
			proc getGroupPass {} {
				global zboe::settings::gen::npass
				return $zboe::settings::gen::npass
			}
			proc homechan {} {
				global zboe::settings::gen::homechan
				return $zboe::settings::gen::homechan
			}
			proc greetdir {} {
				global zboe::settings::greet::dir
				return $zboe::settings::greet::dir
			}
			proc act {chan text} { putserv "PRIVMSG $chan \01ACTION $text\01"; }
		}
	}
}