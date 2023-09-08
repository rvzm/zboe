# ##################################################
# ### zboe  - zombie hunting game ##################
# ### Coded by rvzm               ##################
# ##################################################
if {[catch {source scripts/zboe/zboe-settings.tcl} err]} {
	putlog "Error: Could not load 'scripts/zboe/zboe-settings.tcl' file.";
}

namespace eval zboe {
	namespace eval binds {
		# Main Commands
		bind pub - ${zboe::settings::gen::pubtrig}zboe zboe::procs::zboe:main
		bind pub - ${zboe::settings::gen::pubtrig}version zboe::procs::version
		bind pub - ${zboe::settings::gen::pubtrig}shoot zboe::procs::zhunt::shoot
		bind pub - ${zboe::settings::gen::pubtrig}shop zboe::procs::zhunt::shop
		bind pub - ${zboe::settings::gen::pubtrig}reload zboe::procs::zhunt::reload
		bind pub - ${zboe::settings::gen::pubtrig}zstats zboe::procs::zhunt::stats
		bind pub - ${zboe::settings::gen::pubtrig}stats zboe::procs::zhunt::stats
		# Owner Commands
		bind pub m ${zboe::settings::gen::controller} zboe::procs::control
		# Autos
		bind join - * zboe::procs::zcheck
	}
	namespace eval procs {
		# Main Command Procs
		proc zboe:main {nick uhost hand chan text} {
			if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "(level2) main command sent $nick $chan - $text"; }
			set v1 [lindex [split $text] 0]
			if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "main command var 1 set"; }
			set v2 [lindex [split $text] 1]
			if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) main command var 2 set"; }
			set v3 [lindex [split $text] 2]
			if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) main command var 3 set"; }
			if {$v1 == ""} {
				if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) main command recieved no input, informing chan and halting"; }
				putserv "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: ${zboe::settings::gen::pubtrig}zboe help"; return
			}
			if {$v1 == "hunt"} {
				if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) main command recieved control for hunt - $v2"; }
				if {[file exists "scripts/zboe/zhunt.activehunt"] == 0} { zboe::util::init.zboe; }
				if {$v2 == "start"} {
					set zha "[zboe::util::read_db zhunt.activehunt]"
					if {$zha == "no"} {
					zboe::procs::zhunt::starthunting;
					putserv "PRIVMSG $chan :o.0.O.0.o Zombie hunt started! Keep an eye out for zombies!! o.0.O.0.o";
					return
					}
					if {$zha == "yes"} {
						putserv "PRIVMSG $chan ::o.0.O.0.O There is already an active hunt o.0.O.0.o";
						return
					}
				}
				if {$v2 == "stop"} {
					set zha "[zboe::util::read_db zhunt.activehunt]"
					if {$zha == "yes"} {
						zboe::procs::zhunt::stophunting;
						putserv "PRIVMSG $chan :o.0.O.0.o Stopping the hunt... o.0.O.0.o";
						return;
					}
					if {$zha == "no"} {
						putserv "PRIVMSG $chan :o.0.O.0.O There is no active hunt o.0.O.0.o";
						return;
					}
				}
				if {$v2 == "restart"} {
					zboe::procs::zhunt::stophunting;
					putserv "PRIVMSG $chan :o.0.O.0.o Restarting the hunt... o.0.O.0.o";
					zboe::procs::zhunt::starthunting;
					return
				}
				if {$v2 == "check"} {
					set zha "[zboe::util::read_db zhunt.activehunt]"
					if {$zha == "yes"} {
						putserv "PRIVMSG $chan :o.0.O.0.o Zombies about. Putting them away.";
						zboe::util::write_db "zhunt.activehunt" "no";
						zboe::util::write_db "zhunt.zombies" "0";
						zboe::procs::zhunt::stophunting;
						return
					}
					putserv "PRIVMSG $chan :o.0.O.0.o No stray zombies";
					return
				}
				if {$v2 == "zgo"} {
					if {[file exists "zhunt.$nick.xp"] == 0} { zboe::util::write_db "zhunt.$nick.xp" "0"; }
					if {[file exists "zhunt.$nick.ammo"] == 0} { zboe::util::write_db "zhunt.$nick.ammo" "6"; }
					if {[file exists "zhunt.$nick.clips.a1"] == 0} { zboe::util::write_db "zhunt.$nick.clips.a1" "3"; }
					if {[file exists "zhunt.$nick.jam"] == 0} { zboe::util::write_db "zhunt.$nick.jam" "no"; }
					putserv "PRIVMSG $chan :o.0.O.0.o. All set to hunt!";
					return
				}
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
				if {$v2 == "z"} { putserv "NOTICE $nick :zboe command 'z' - rolls zombie encounter."; return }
				if {$v2 == "zc"} { putserv "NOTICE $nick :zboe command 'zc' - gives you the current stands for both you and the hunt."; return }
				if {$v2 == "zs"} { putserv "NOTICE $nick :zboe command 'zr' - resets all hunt options/players."; return }
				if {$v2 == ""} {
					putserv "NOTICE $nick :zboe controll commands - rehash restart die info z zc zr"
					return
					}
				}
			if {$v1 == "rehash"} {
				putserv "PRIVMSG $chan :Reloading configuration..."; 
				rehash;
				putserv "PRIVMSG $chan :Configuration file reloaded";
				return
				}
			if {$v1 == "restart"} { restart; return }
			if {$v1 == "die"} { die; return }
			if {$v1 == "info"} { putserv "PRIVMSG $chan :zboe.tcl running version [zboe::util::getVersion]"; return }
			if {$v1 == "z"} { putserv "PRIVMSG $chan :o.0.O.0.o Rolling Encounter..."; zboe::procs::zhunt::zspawn; return }
			if {$v1 == "zc"} {
				set zcz "[zboe::util::read_db zhunt.zombies]";
				set zcah "[zboe::util::read_db zhunt.activehunt]";
				set zcam "[zboe::util::read_db zhunt.$nick.ammo]";
				set zcxp "[zboe::util::read_db zhunt.$nick.xp]";
				set zccl "[zboe::util::read_db zhunt.$nick.clips.a1]";
				set zcht "[zboe::util::read_db zhunt.$nick.htok]";
				set zcxl "[zboe::util::read_db zhunt.$nick.level]";
				putserv "PRIVMSG $chan :o.0.O.0.o Zombie Hunt Check|| Active: $zcah | Zombies: $zcz | Your Level: $zcxl| Your Ammo/Clips: $zcam/zccl | Your XP: $zcxp | Horde Tokens: $zcht";
				return
			}
			if {$v1 == "zr"} {
				putserv "NOTICE $nick :zboe||control /!\\ RESETTING ZHUNT /!\\ "
				zboe::procs::zhunt::stophunting;
				zboe::util::write_db "zhunt.activehunt" "no"
				zboe::util::write_db "zhunt.zombies" "0"
				zboe::util::write_db "zhunt.horde" "no"
				file delete -force -- {*}[glob scripts/zboe/zhunt.*]
				putserv "PRIVMSG $chan :o.0.O.0.o /!\\ ZHUNT HAS BEEN RESET. All player data erased.";
				return
			}
			putcmdlog "*** zboe controller $nick - help command error - no if statement triggered"
			putserv "NOTICE $nick :Error- No control command given. use '${zboe::settings::gen::controller} help' to see commands."
		}
		proc version {nick uhost hand chan text} {
			putserv "PRIVMSG $chan :zboe -> version-[zboe::util::getVersion] build [zboe::util::getBuild]"
			putserv "PRIVMSG $chan :zboe -> release: [zboe::util::getRelease]"
			return
		}
		proc register {nick uhost hand chan text} {
			if {[validuser $hand] == "1"} { putserv "PRIVMSG $chan :Sorry $nick, but you're already registered. :)"; return }
			if {[adduser $hand $uhost] == "1"} {
				putserv "PRIVMSG [zboe::util::homechan] :*** Introduced user - $nick / $uhost"
				putlog "*** Introduced to user - $nick / $uhost"
				putserv "PRIVMSG $chan :Congradulations, $nick! you are now in my system! yay :)"
				} else { putserv "PRIVMSG $chan :Addition failed." }
			return
		}
		proc zcheck {nick uhost hand chan} {
			if {$nick == "zboe"} {
				if {${zboe::settings::debug} >= "1"} { putcmdlog "*** zboe|log| Joined $chan"; }
				if {$chan == ${zboe::settings::gen::homechan}} {
					if {${zboe::settings::hunt::startonjoin} == "yes"} { 
						zboe::util::write_db "zhunt.activehunt" "yes";
						zboe::util::write_db "zhunt.zombies" "0";
						zboe::procs::zhunt::starthunting;
						if {[file exists "scripts/zboe/zhunt.horde"] == 0} { zboe::util::write_db "zhunt.horde" "no"; }
						putserv "PRIVMSG $chan :o.0.O.0.o Zombie Hunt Starting... o.0.O.0.o";
						zboe::procs::zhunt::zspawn;
						return
					}
				}
				return
			}
			if {$chan == ${zboe::settings::gen::homechan}} {
				if {[file exists "zhunt.$nick.xp"] == 0} { zboe::util::init.nick $nick; }
				if {[zboe::util::read_db "zhunt.activehunt"] == "yes"} { putserv "PRIVMSG $chan :o.0.O.0.o. There is currently an active hunt! there are [zboe::util::read_db "zhunt.zombies"] zombies around currently. || use ${zboe::settings::gen::pubtrig}shoot and ${zboe::settings::gen::pubtrig}reload"; }
				if {[zboe::util::read_db "zhunt.horde"] == "yes"} {
					if {[zboe::util::read_db "zhunt.zombies"] == ${zboe::settings::hunt::maxhorde}} { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! The horde is currently at MAX STRENGTH!!"; return }
					putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! Help clear up the horde!";
				}
			}
		}
		namespace eval zhunt {
			proc starthunting {} {
				set chan ${zboe::settings::gen::homechan}
				zboe::util::write_db "zhunt.activehunt" "yes"
				zboe::util::write_db "zhunt.zombies" "0"
				timer ${zboe::settings::hunt::time} zboe::procs::zhunt::zspawn 0 zhunttimer
			}
			proc stophunting {} {
				set chan ${zboe::settings::gen::homechan}
				zboe::util::write_db "zhunt.activehunt" "no"
				zboe::util::write_db "zhunt.zombies" "0"
				killtimer zhunttimer
			}
			proc zspawn {} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "zombie check - rolling encounter"; }
				set chan ${zboe::settings::gen::homechan}
				set tchk "[rand 15]"
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "zcheck $tchk"; }
				set zha "[zboe::util::read_db zhunt.activehunt]"
				set znum "[zboe::util::read_db zhunt.zombies]"
				set zsph "[zboe::util::read_db zhunt.horde]"
				if {$tchk <= ${zboe::settings::hunt::trigger}} {
					incr znum
					if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "DER BE ZOMBIES"; }
					if {$zsph == "no"} { putserv "PRIVMSG $chan :o.0.O.0.o Zombie Spotted! Shoot that fucker!"; }
					if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "zcheck active: $zha | zombies: $znum"; }
					if {$znum >= "2"} {
						if {${zboe::settings::hunt::horde} == "no"} { 
							if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "zcheck - halting, zombie still loose" }
							if {${zboe::settings::hunt::roast} == "yes"} { putserv "PRIVMSG $chan :o.0.O.0.o There would've been another zombie, but y'all havent hit this one yet."; }
							incr znum -1
							return
						}
						if {$znum > ${zboe::settings::hunt::maxhorde}} {
							if {${zboe::settings::hunt::roast} == "yes"} { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * New zombie trying to join the horde, but the max horde size has been reached!"; }
							if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "Zombie horde max reached"; }
							set znum ${zboe::settings::hunt::maxhorde};
							return
						}
						if {$znum == ${zboe::settings::hunt::maxhorde}} { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * Horde now at MAX STRENGTH!!"; } else { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * Multiple zombies now infesting the area. | Zombies: $znum "}
						if {[file exists "scripts/zboe/zhunt.horde"] == 0} { zboe::util::write_db "zhunt.horde" "no"; }
						zboe::util::write_db "zhunt.horde" "yes";
					}
					if {[file exists "zhunt.zombies"] == 0} { zboe::util::write_db "zhunt.zombies" "1"; }
					zboe::util::write_db "zhunt.zombies" $znum;
					return
				}
				if {${zboe::settings::hunt::roast} == "yes"} { putserv "PRIVMSG $chan :o.0.O.0.o You lucky fucks, a zombie almost entered, but wandered away"; }
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "no zombie"; }
			}
			proc stats {nick uhost hand chan text} {
				set v1 [lindex [split $text] 0]
				if {$v1 != ""} {
					set zsxfg "scripts/zboe/zhunt.$v1.xp";
					set zget "$v1";
					set zcol "$v1's";
				}
				if {$v1 == ""} { set zget $nick; set zcol "Your"; }
				if {[file exists "scripts/zboe/zhunt.$nick.xp"] == 0} { zboe::util::init.nick $nick; }
				if {[file exists "scripts/zboe/zhunt.zombies"] == 0} { zboe::util::init.zboe; }
				set zcz "[zboe::util::read_db zhunt.zombies]";
				set zcah "[zboe::util::read_db zhunt.activehunt]";
				set zcam "[zboe::util::read_db zhunt.$zget.ammo]";
				set zcxp "[zboe::util::read_db zhunt.$zget.xp]";
				set zccl "[zboe::util::read_db zhunt.$zget.clips.a1]";
				set zcht "[zboe::util::read_db zhunt.$zget.htok]";
				set zcxl "[zboe::util::read_db zhunt.$zget.level]";
				set zcpj "[zboe::util::read_db zhunt.$zget.jam]";
				set zcma "[zboe::util::read_db zhunt.$zget.maxammo]";
				set zcmc "[zboe::util::read_db zhunt.$zget.maxclip.a1]";
				set zcmac "[zboe::util::read_db zhunt.$zget.maxacc]";
				putserv "PRIVMSG $chan :||Zombie Hunt || $zget | $zcol Level: $zcxl | $zcol XP: $zcxp | $zcol Ammo/Clips: $zcam/$zccl";
				putserv "PRIVMSG $chan :||Stats o.0.o || Horde Tokens: $zcht | Max Accuracy: $zcmac | Clip Size: $zcma | Max Clips: $zcmc | Gun Jam: $zcpj";
				return
			}
			proc reload {nick uhost hand chan text} {
				if {[file exists "scripts/zboe/zhunt.$nick.xp"] == 0} { zboe::util::init.nick $nick; }
				set zpam "[zboe::util::read_db zhunt.$nick.ammo]"
				set zrl "[zboe::util::read_db zhunt.$nick.clips.a1]";
				set zrma "[zboe::util::read_db zhunt.$nick.maxammo]";
				if {$zpam >= 1} { putserv "PRIVMSG $chan :errr! your clip isnt empty!"; return }
				if {$zrl == 0} { putserv "PRIVMSG $chan :errr! You have no clips!"; return }
				zboe::util::write_db "zhunt.$nick.ammo" "$zrma"
				incr zrl -1
				zboe::util::write_db "zhunt.$nick.clips.a1" "$zrl"
				putserv "PRIVMSG $chan :o.0.O.0.o Reloaded bitch! (Clips left: $zrl)";
				return;
			}
			proc shoot {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot command sent $nick $chan"; }
				if {[file exists "scripts/zboe/zhunt.activehunt"] == 0} { zboe::util::init.zboe; }
				set zschk "[zboe::util::read_db zhunt.activehunt]"
				set zaz "[zboe::util::read_db zhunt.zombies]"
				if {$zschk == "yes"} {
					if {[file exists "scripts/zboe/zhunt.$nick.xp"] == 0} { zboe::util::init.nick $nick; }
					set zpam "[zboe::util::read_db zhunt.$nick.ammo]"
					if {$zaz >= "1"} {
						if {$zpam == "0"} {
							putserv "PRIVMSG $chan :o.0.O.0.o errr! you need to reload dipshit!";
							return
						}
						incr zpam -1
						set zpacc "[zboe::util::read_db zhunt.$nick.maxacc]"
						set zpchk "[rand 99]"
						set zpf zhunt.$nick.xp
						set zpx "[zboe::util::read_db $zpf]"
						if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot $nick / ammo $zpam / xp $zpx "; }
						zboe::util::write_db "zhunt.$nick.ammo" $zpam
						if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot acc: $zpacc check: $zpchk "; }
						if {$zpchk <= $zpacc} {
							putserv "PRIVMSG $chan :o.0.O.0.o ayyy $nick hit the zombie!! They get 5xp |$zpam/6|"
							incr zpx 5
							incr zaz -1
							zboe::util::write_db "zhunt.$nick.xp" $zpx
							zboe::util::write_db "zhunt.zombies" $zaz
							if {${zboe::settings::hunt::horde} == "yes"} {
								if {$zaz == "0"} {
									if {[zboe::util::read_db zhunt.horde] == "yes"} {
										putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * * * HORDE ELIMINATED (+35 XP | +1 Horde Token) * * *";
										set zsht "[zboe::util::read_db zhunt.$nick.htok]"
										incr zpx "35"
										incr zsht
										zboe::util::write_db "zhunt.$nick.htok" $zsht
										zboe::util::write_db "zhunt.$nick.xp" $zpx
										zboe::util::write_db "zhunt.horde" "no"
									}
									return; 
								}
								if {$zaz == "1"} { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * * * LAST ZOMBIE * * *"; return; }
								putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * Zombies Remaining: $zaz";
							}
							return
						}
						putserv "PRIVMSG $chan :o.0.O.0.o oops, you fuckin missed gaylord |$zpam/6|";
						return
					}
					putserv "PRIVMSG $chan :o.0.O.0.o there isnt a fuckin zombie gaylord";
					return;
				}
				putserv "PRIVMSG $chan :o.0.O.0.o there isnt an active hunt gaylord";
				return;
			}
			proc shop {nick uhost hand chan text} {
				set v1 [lindex [split $text] 0]
				set v2 [lindex [split $text] 1]
				if {$v1 == ""} {
					putserv "PRIVMSG $chan :o.0.O.0.o zboe Shop - use ${zboe::settings::gen::pubtrig}shop <item number>"
					putserv "PRIVMSG $chan :Current Items: (1) Clip (${zboe::settings::shop::clips}xp) | (2) LevelUp! (${zboe::settings::shop::lvlup} horde tokens) | (3) Accuracy Up! (${zboe::settings::shop::accuracyupgrade} horde tokens) | (4) Horde Token (${zboe::settings::shop::hordetokens}xp) | (5) Clip Storage Upgrade (${zboe::settings::shop::clipupgrade} Horde Tokens) | (arsenal) display the Arsenal Shop"; return }
				if {[file exists "scripts/zboe/zhunt.$nick.xp"] == 0} { zboe::util::init.nick $nick; }
				set zshop "[zboe::util::read_db zhunt.$nick.clips.a1]"
				set zspx "[zboe::util::read_db zhunt.$nick.xp]"
				set zsmc "[zboe::util::read_db zhunt.$nick.maxclip.a1]"
				set zspl "[zboe::util::read_db zhunt.$nick.level]"
				set zsac "[zboe::util::read_db zhunt.$nick.maxacc]"
				if {$v1 == "1"} {
					set zshop "[zboe::util::read_db zhunt.$nick.clips.a1]"
					set zspx "[zboe::util::read_db zhunt.$nick.xp]"
					set zsmc "[zboe::util::read_db zhunt.$nick.maxclip.a1]"
					if {$zspx >= ${zboe::settings::shop::clips}} {
						if {$zshop < $zsmc} {
							incr zshop
							incr zspx "-${zboe::settings::shop::clips}"
							zboe::util::write_db "zhunt.$nick.clips.a1" "$zshop";
							zboe::util::write_db "zhunt.$nick.xp" "$zspx";
							putserv "NOTICE $nick :o.0.O.0.o You purchased a clip, you now have $zshop/$zsmc clips";
							return
						} else { putserv "NOTICE $nick :o.0.O.0.o errr, you are at your max clips!"; return }
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "2"} {
					set zsht "[zboe::util::read_db zhunt.$nick.htok]"
					if {$zsht >= ${zboe::settings::shop::lvlup}} {
						set zspl "[zboe::util::read_db zhunt.$nick.level]"
						set zsac "[zboe::util::read_db zhunt.$nick.maxacc]"
						set zsmc "[zboe::util::read_db zhunt.$nick.maxclip.a1]"
						incr zsht "-${zboe::settings::shop::lvlup}"
						incr zspl
						incr zsac 5
						incr zsmc 
						zboe::util::write_db "zhunt.$nick.level" "$zspl"
						zboe::util::write_db "zhunt.$nick.htok" "$zsht"
						zboe::util::write_db "zhunt.$nick.maxacc" "$zsac"
						zboe::util::write_db "zhunt.$nick.maxclip.a1" "$zsmc";
						putserv "NOTICE $nick :o.0.O.0.o You leveled up to Level $zspl!";
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "3"} {
					set zsht "[zboe::util::read_db zhunt.$nick.htok]"
					if {$zsht >= ${zboe::settings::shop::accuracyupgrade}} {
						set zsacc "[zboe::util::read_db zhunt.$nick.maxacc]"
						incr zsht "-${zboe::settings::shop::accuracyupgrade}"
						incr zsacc 5
						zboe::util::write_db "zhunt.$nick.htok" "$zsht"
						zboe::util::write_db "zhunt.$nick.maxacc" "$zsacc"
						putserv "NOTICE $nick :o.0.O.0.o Max Accuracy inreased to $zsacc";
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "4"} {
					set zspx "[zboe::util::read_db zhunt.$nick.xp]"
					set zsht "[zboe::util::read_db zhunt.$nick.htok]"
					if {$zspx >= ${zboe::settings::shop::hordetokens}} {
						incr zspx "-${zboe::settings::shop::hordetokens}"
						incr zsht
						zboe::util::write_db "zhunt.$nick.htok" "$zsht"
						zboe::util::write_db "zhunt.$nick.xp" "$zspx"
						putserv "NOTICE $nick :o.0.O.0.o You purchased a Horde Token. You now have $zsht tokens.";
						return
						}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "5"} {
					set zsmc "[zboe::util::read_db zhunt.$nick.maxclip.a1]"
					set zsht "[zboe::util::read_db zhunt.$nick.htok]"
					if {$zspx >= ${zboe::settings::shop::clipupgrade}} {
						incr zsht "-${zboe::settings::shop::clipupgrade}"
						incr zsmc
						putserv "NOTICE $nick :o.0.O.0.o Max Clips inreased to $zsmc";
						zboe::util::write_db "zhunt.$nick.htok" "$zsht"
						zboe::util::write_db "zhunt.$nick.maxclip.a1" "$zsmc"
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "arsenal"} {
					if {$v2 == "rifle"} {
						putcmdlog "***zboe|debug| arsenal - rifle - $nick";
						putserv "PRIVMSG $chan :zboe||arsenal| the rifle will offer high accurary and clip size, but will suffer in endurence, and is prone to jamming.";
						return
					}
					if {$v2 == "shotgun"} {
						putcmdlog "***zboe|debug| arsenal - shotgun - $nick";
						putserv "PRIVMSG $chan :zboe||arsenal| the shotgun will offer a small accuracy buff from the standard pistol, but also allowed users to hit multiple zombies at once in horde mode. .";
						return
					}
					if {$v2 == "gzdw"} {
						putcmdlog "***zboe|debug| arsenal - gzdm - $nick";
						putserv "PRIVMSG $chan :zboe||arsenal| You attempted to buy a Guided Zombie Devestation Warhead, good for you.";
						return
					}
				putserv "PRIVMSG $chan :zboe||arsenal|| Shop Options: Rifle, Shotgun, gzdw"
				putserv "PRIVMSG $chan :zboe||arsenal|| use each option in addition to the arsenal shop to view its information. The arsenal shop is currently information only, and carries no current prices"
				return
				}
			}
		}
	}
	namespace eval util {
		# write to *.db files
		proc write_db {w_db w_info} {
			set dbf "scripts/zboe/$w_db"
			if {[file exists $dbf] == 0} {
				set crtdb [open $dbf a+]
				puts $crtdb "$w_info"
				close $crtdb
			}
			set fs_write [open $dbf w]
			puts $fs_write "$w_info"
			close $fs_write
		}
		# read from *.db files
		proc read_db {r_db} {
			set dbr "scripts/zboe/$r_db"
			set fs_open [open $dbr r]
			gets $fs_open db_out
			close $fs_open
			return $db_out
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
		proc init.nick {nick} {
		putcmdlog "*** zboe|users| initializing $nick";
		zboe::util::write_db "zhunt.$nick.xp" "0";
		zboe::util::write_db "zhunt.$nick.ammo" "6";
		zboe::util::write_db "zhunt.$nick.clips.a1" "3";
		zboe::util::write_db "zhunt.$nick.clips.a2" "3";
		zboe::util::write_db "zhunt.$nick.clips.a3" "3";
		zboe::util::write_db "zhunt.$nick.jam" "no";
		zboe::util::write_db "zhunt.$nick.htok" "0";
		zboe::util::write_db "zhunt.$nick.level" "1";
		zboe::util::write_db "zhunt.$nick.maxammo" "6";
		zboe::util::write_db "zhunt.$nick.maxclip.a1" "3";
		zboe::util::write_db "zhunt.$nick.maxclip.a2" "3";
		zboe::util::write_db "zhunt.$nick.maxclip.a3" "3";
		zboe::util::write_db "zhunt.$nick.maxacc" "55";
		putcmdlog "*** zboe|users| zjoin: $nick | initialized";
		}
		proc init.zboe {} {
			zboe::util::write_db "zhunt.activehunt" "no";
			zboe::util::write_db "zhunt.zombies" "0";
			zboe::util::write_db "zhunt.horde" "no";
		}
		proc zboedbg {text} { putcmdlog "** zboe\[debug\] $text"; }
		proc act {chan text} { putserv "PRIVMSG $chan \01ACTION $text\01"; }
	}
}
