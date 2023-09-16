# ##################################################
# ### zboe  - zombie hunting game ##################
# ### Coded by rvzm               ##################
# ##################################################
if {[catch {source scripts/zboe/zboe-settings.tcl} err]} {
	putlog "Error: Could not load 'scripts/zboe/zboe-settings.tcl' file.";
}
package require sqlite3;
sqlite3 zdb "${zboe::settings::gen::sqldir}zhunt.sql" -create true -readonly false
zdb cache flush

namespace eval zboe {
	namespace eval binds {
		# Main Commands
		bind pub - ${zboe::settings::gen::pubtrig}zboe zboe::procs::zboe:main
		bind pub - ${zboe::settings::gen::pubtrig}version zboe::procs::version
		bind pub - ${zboe::settings::gen::pubtrig}shoot zboe::procs::zhunt::shoot
		bind pub - ${zboe::settings::gen::pubtrig}jam zboe::procs::zhunt::jam
		bind pub - ${zboe::settings::gen::pubtrig}shop zboe::procs::zhunt::shop
		bind pub - ${zboe::settings::gen::pubtrig}reload zboe::procs::zhunt::reload
		bind pub - ${zboe::settings::gen::pubtrig}zstats zboe::procs::zhunt::zstats
		bind pub - ${zboe::settings::gen::pubtrig}stats zboe::procs::zhunt::stats
		# Owner Commands
		bind pub m ${zboe::settings::gen::controller} zboe::procs::control
		# Autos
		bind join - * zboe::procs::zcheck
	}
	namespace eval procs {
		# Main Command Procs
		proc zboe:main {nick uhost hand chan text} {
			if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "main command sent| $nick $chan - $text"; }
			if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
			set v1 [lindex [split $text] 0]
			set v2 [lindex [split $text] 1]
			set v3 [lindex [split $text] 2]
			if {$v1 == ""} {
				if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) main command recieved no input, informing chan and halting"; }
				putserv "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: ${zboe::settings::gen::pubtrig}zboe help"; return
			}
			if {$v1 == "hunt"} {
				if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) main command recieved control for hunt - $v2"; }
				if {$v2 == "start"} {
					if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) hunt start command given"; }
					set zha "[zboe::sql::util::checksetting hunt]" 
					if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) hunt status check completed: $zha"; }
					if {$zha == "no"} {
						if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) hunt starting"; }
						zboe::procs::zhunt::starthunting;
						putserv "PRIVMSG $chan :o.0.O.0.o Zombie hunt started! Keep an eye out for zombies!! o.0.O.0.o";
						return
					}
					if {$zha == "yes"} {
						if {${zboe::settings::debug} == "2"} { zboe::util::zboedbg "(level2) hunt already going"; }
						putserv "PRIVMSG $chan ::o.0.O.0.O There is already an active hunt o.0.O.0.o";
						return
					}
				}
				if {$v2 == "stop"} {
					set zha "[zboe::sql::util::checksetting hunt]"
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
					set zha "[zboe::sql::util::checksetting hunt]"
					if {$zha == "yes"} {
						putserv "PRIVMSG $chan :o.0.O.0.o Zombies about. Putting them away.";
						zboe::sql::util::changesetting "hunt" "no";
						zboe::sql::util::changesetting "zombiecount" "0";
						zboe::procs::zhunt::stophunting;
						return
					}
					putserv "PRIVMSG $chan :o.0.O.0.o No stray zombies";
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
			if {$v1 == "chanset"} { channel set $chan "$v2"; return }
			if {$v1 == "z"} {
				if {$v2 == ""} {
					putserv "PRIVMSG $chan :o.0.O.0.o Rolling Encounter..."
					zboe::procs::zhunt::zspawn
					return 
				}
				putserv "PRIVMSG $chan :o.0.O.0.o Rolling $v2 Encounters..."
				set zzc "[zboe::sql::util::checksetting zombiecount]"
				incr zzc "$v2"
				zboe::sql::util::changesetting "zombiecount" $zzc
				return
			}
			if {$v1 == "zc"} {
				set zccz "[zboe::sql::util::checksetting zombiecount]";
				set zcah "[zboe::sql::util::checksetting hunt]";
				set zcam "[zboe::sql::util::checkammo $nick]";
				set zcxp "[zboe::sql::util::checkxp $nick]";
				set zccl "[zboe::sql::util::checkclips $nick]";
				set zcht "[zboe::sql::util::checkhordetokens $nick]";
				set zcxl "[zboe::sql::util::checklevel $nick]";
				putserv "PRIVMSG $chan :o.0.O.0.o Zombie Hunt Check|| Active: $zcah | Zombies: $zccz | Your Level: $zcxl| Your Ammo/Clips: $zcam/zccl | Your XP: $zcxp | Horde Tokens: $zcht";
				return
			}
			if {$v1 == "init"} {
				putserv "NOTICE $nick :zboe||control /!\\ INITIALIZING ZHUNT /!\\ "
				zboe::sql::util::initdb
				zboe::sql::util::dbmake "$nick"
				putserv "PRIVMSG $chan :o.0.O.0.o /!\\ zHunt Initialized";
				return
			}
			putcmdlog "*** zboe controller $nick - help command error - no if statement triggered"
			putserv "NOTICE $nick :Error- No control command given. use '${zboe::settings::gen::controller} help' to see commands."
		}
		proc version {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "version command issued"; }
			putserv "PRIVMSG $chan :zboe -> version-[zboe::util::getVersion] build [zboe::util::getBuild]"
			putserv "PRIVMSG $chan :zboe -> release: [zboe::util::getRelease]"
			return
		}
		proc register {nick uhost hand chan text} {
			if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "register command issued"; }
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
						if {[zboe::sql::util::checksetting "hunt"] == "yes"} {
							putserv "PRIVMSG $chan :o.0.O.0.o. There is currently an active hunt! there are [zboe::sql::util::checksetting "zombiecount"] zombies around currently. || use ${zboe::settings::gen::pubtrig}shoot and ${zboe::settings::gen::pubtrig}reload";
							if {[zboe::sql::util::checksetting "fullhorde"] == "yes"} {
								if {[zboe::sql::util::checksetting "zombiecount"] == ${zboe::settings::hunt::maxhorde}} { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! The horde is currently at MAX STRENGTH!!"; return }
								putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! Help clear up the horde!";
							}
							timer ${zboe::settings::hunt::time} zboe::procs::zhunt::zspawn 0 zhunttimer
							return
						}
						zboe::sql::util::changesetting "hunt" "yes";
						zboe::sql::util::changesetting "zombiecount" "0";
						zboe::sql::util::changesetting "fullhorde" "no";
						zboe::procs::zhunt::starthunting;
						putserv "PRIVMSG $chan :o.0.O.0.o Zombie Hunt Starting... o.0.O.0.o";
						zboe::procs::zhunt::zspawn;
						return
					}
				}
				return
			}
			if {$chan == ${zboe::settings::gen::homechan}} {
				if {[zboe::sql::util::checkxp $nick] == 0} { zboe::sql::util::dbmake "$nick"; }
				if {[zboe::sql::util::checksetting "hunt"] == "yes"} { putserv "PRIVMSG $chan :o.0.O.0.o. There is currently an active hunt! there are [zboe::sql::util::checksetting "zombiecount"] zombies around currently. || use ${zboe::settings::gen::pubtrig}shoot and ${zboe::settings::gen::pubtrig}reload"; }
				if {[zboe::sql::util::checksetting "fullhorde"] == "yes"} {
					if {[zboe::sql::util::checksetting "zombiecount"] == ${zboe::settings::hunt::maxhorde}} { putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! The horde is currently at MAX STRENGTH!!"; return }
					putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! Help clear up the horde!";
				}
			}
		}
		namespace eval zhunt {
			proc starthunting {} {
				set chan ${zboe::settings::gen::homechan}
				zboe::sql::util::changesetting "hunt" "yes"
				timer ${zboe::settings::hunt::time} zboe::procs::zhunt::zspawn 0 zhunttimer
			}
			proc stophunting {} {
				set chan ${zboe::settings::gen::homechan}
				zboe::sql::util::changesetting "hunt" "no"
				zboe::sql::util::changesetting "zombiecount" "0"
				zboe::sql::util::changesetting "fullhorde" "no"
				killtimer zhunttimer
			}
			proc zspawn {} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "zombie check - rolling encounter"; }
				set chan ${zboe::settings::gen::homechan}
				set tchk "[rand 15]"
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) zcheck $tchk"; }
				set zha "[zboe::sql::util::checksetting hunt]"
				set znum "[zboe::sql::util::checksetting zombiecount]"
				set zsph "[zboe::sql::util::checksetting fullhorde]"
				if {$tchk <= ${zboe::settings::hunt::trigger}} {
					incr znum
					if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "DER BE ZOMBIES"; }
					if {$zsph == "no"} { putserv "PRIVMSG $chan :o.0.O.0.o Zombie Spotted! Shoot that fucker!"; }
					if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) zcheck active: $zha | zombies: $znum"; }
					if {$znum >= "2"} {
						if {${zboe::settings::hunt::horde} == "no"} { 
							if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "zcheck - halting, zombie still loose" }
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
						zboe::sql::util::changesetting "fullhorde" "yes";
					}
					zboe::sql::util::changesetting "zombiecount" $znum;
					return
				}
				if {${zboe::settings::hunt::roast} == "yes"} { putserv "PRIVMSG $chan :o.0.O.0.o You lucky fucks, a zombie almost entered, but wandered away"; }
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "no zombie"; }
			}
			proc stats {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "stats command issued"; }
				if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
				set v1 [lindex [split $text] 0]
				if {$v1 != ""} {
					set zget "$v1";
					set zcol "$v1's";
				}
				if {$v1 == ""} { set zget $nick; set zcol "Your"; }
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) Grabbing stats for $zget"; }
				zboe::sql::util::dbmake "$zget";
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) Grabbing zombiecount"; }
				set zcz "[zboe::sql::util::checksetting zombiecount]";
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) Grabbing hunt setting"; }
				set zcah "[zboe::sql::util::checksetting hunt]";
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) Grabbing user data"; }
				set zcam "[zboe::sql::util::checkammo $zget]";
				set zcxp "[zboe::sql::util::checkxp $zget]";
				set zccl "[zboe::sql::util::checkclips $zget]";
				set zcht "[zboe::sql::util::checkhordetokens $zget]";
				set zcxl "[zboe::sql::util::checklevel $zget]";
				set zcpj "[zboe::sql::util::checkjam $zget]";
				set zcpk "[zboe::sql::util::checkkills $zget]";
				set zcma "[zboe::sql::util::checkmaxammo $zget]";
				set zcmc "[zboe::sql::util::checkmaxclips $zget]";
				set zcmac "[zboe::sql::util::checkaccuracy $zget]";
				set zcgc "[zboe::sql::util::checkcondition $nick]"
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) Sending Stats"; }
				putserv "PRIVMSG $chan :|| Zombie //// || $zget | $zcol Level: $zcxl | $zcol XP: $zcxp | $zcol Ammo/Clips: $zcam/$zccl | Gun Condition: $zcgc/100";
				putserv "PRIVMSG $chan :||  Hunt Stats || Kills: $zcpk | Horde Tokens: $zcht | Accuracy: $zcmac | Clip Size: $zcma | Max Clips: $zcmc | Gun Jam: $zcpj";
				return
			}
			proc zstats {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "zombiestats command issued"; }
				if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
				set zccz "[zboe::sql::util::checksetting zombiecount]";
				set zcah "[zboe::sql::util::checksetting hunt]";
				set zchs "${zboe::settings::hunt::horde}"
				set zcmh "${zboe::settings::hunt::maxhorde}"
				set zczr "${zboe::settings::hunt::roast}"
				if {$zchs == "yes"} {
					putserv "PRIVMSG $chan :o.0.O.0.o Zombie Hunt Check|| Active: $zcah | Roast: $zczr | Horde Mode Enabled | Max Horde Size: $zcmh | Zombies: $zccz |";
					return
				}
				putserv "PRIVMSG $chan :o.0.O.0.o Zombie Hunt Check|| Active: $zcah | Roast: $zczr | No Horde - Single zombie mode | Max Horde Size: $zcmh |";
				return
			}
			proc reload {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "Reload: DB Check"; }
				if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
				zboe::sql::util::dbmake "$nick"
				set zpam "[zboe::sql::util::checkammo $nick]"
				set zrl "[zboe::sql::util::checkclips $nick]";
				set zrma "[zboe::sql::util::checkmaxammo $nick]";
				if {${zboe::settings::debug} >= "3"} { zboe::util::zboedbg "Reload: Checking Ammo"; }
				if {$zpam >= 1} { putserv "PRIVMSG $chan :errr! your clip isnt empty!"; return }
				if {${zboe::settings::debug} >= "3"} { zboe::util::zboedbg "Reload: Checking Clip Storage"; }
				if {$zrl == 0} { putserv "PRIVMSG $chan :errr! You have no clips!"; return }
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "Reload: Reloading!!"; }
				zboe::sql::util::changeammo "$nick" "$zrma"
				incr zrl -1
				zboe::sql::util::changeclips "$nick" "$zrl"
				putserv "PRIVMSG $chan :o.0.O.0.o Reloaded bitch! (Clips left: $zrl)";
				return;
			}
			proc shoot {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot command sent $nick $chan"; }
				if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
				zboe::sql::util::dbmake "$nick"
				set zschk "[zboe::sql::util::checksetting hunt]"
				set zaz "[zboe::sql::util::checksetting zombiecount]"
				set zakc "[zboe::sql::util::checkkills $nick]"
				set zagc "[zboe::sql::util::checkcondition $nick]"
				if {$zschk == "yes"} {
					if {$zagc == "0"} {
						putserv "PRIVMSG $chan :o.0.O.0.o errr! your gun is broken dipshit, use the shop to buy a new one, or painstakingly grease your current back to life if you're sentimental :P"
						return
					}
					set zpam "[zboe::sql::util::checkammo $nick]"
					if {$zaz >= "1"} {
						if {$zpam == "0"} {
							putserv "PRIVMSG $chan :o.0.O.0.o errr! you need to reload dipshit!";
							return
						}
						incr zpam -1
						set zpacc "[zboe::sql::util::checkaccuracy $nick]"
						set zpx "[zboe::sql::util::checkxp $nick]"
						set zpchk "[rand 99]"
						set zpjc "[rand 65]"
						incr zagc -2
						if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "updating condition $nick $zagc "; }
						zboe::sql::util::changecondition "$nick" "$zagc"
						if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot $nick / ammo $zpam / xp $zpx / condition $zagc / jamchk $zpjc"; }
						if {$zpjc >= $zagc} {
							if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot //JAM $nick"; }
							putserv "PRIVMSG $chan :o.0.O.0.o FUCK!!! You got a jam, use @jam to unjam";
							zboe::sql::util::changejam "$nick" "yes"
							return
						}
						zboe::sql::util::changeammo "$nick" $zpam
						if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shoot acc: $zpacc check: $zpchk "; }
						if {$zpchk <= $zpacc} {
							putserv "PRIVMSG $chan :o.0.O.0.o ayyy $nick hit the zombie!! They get 5xp |$zpam/6|"
							if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "running stat changes| "; }
							incr zpx 5
							incr zaz -1
							incr zakc 1
							if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "updating xp $nick $zpx "; }
							zboe::sql::util::changexp "$nick" "$zpx"
							if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "updating zombiecount $zaz "; }
							zboe::sql::util::changesetting "zombiecount" "$zaz"
							if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "updating kills $nick $zakc "; }
							zboe::sql::util::changekills "$nick" "$zakc"
							if {${zboe::settings::hunt::horde} == "yes"} {
								if {$zaz == "0"} {
									if {[zboe::sql::util::checksetting "fullhorde"] == "yes"} {
										putserv "PRIVMSG $chan :o.0.O.0.o !!! ZOMBIE HORDE !!! * * * HORDE ELIMINATED (+35 XP | +1 Horde Token) * * *";
										set zsht "[zboe::sql::util::checkhordetokens $nick]"
										incr zpx "35"
										incr zsht 1
										if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "updating hordetokens $nick $zsht "; }
										zboe::sql::util::changehordetokens "$nick" "$zsht"
										if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "updating Horde-xp $nick $zpx "; }
										zboe::sql::util::changexp "$nick" "$zpx"
										zboe::sql::util::changesetting "fullhorde" "no"
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
			proc jam {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "jam command issued"; }
				if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
				set zjgj "[zboe::sql::util::checkjam $nick]"
				set zjcl "[zboe::sql::util::checkclips $nick]"
				set zjam "[zboe::sql::util::checkammo $nick]"
				if {$zjgj == "no"} {
					putserv "PRIVMSG $chan :Error - You do not have a jam"
					return
				}
				if {$zjcl == "0"} {
					putserv "PRIVMSG $chan :Error - You dont have a clip to unjam with"
					return
				}
				incr zjam -1
				zboe::sql::util::changejam "$nick" "no"
				zboe::sql::util::changeammo "$nick" "$zjam"
				putserv "PRIVMSG $chan :o.0.O.0.o You have unjammed your gun"
				return
			}
			proc shop {nick uhost hand chan text} {
				if {${zboe::settings::debug} >= "1"} { zboe::util::zboedbg "shop command issued"; }
				if {![channel get $chan hunt]} { putserv "PRIVMSG $chan : :o.0.O.0.o Err - This channel is not participating in the hunt."; return }
				set v1 [lindex [split $text] 0]
				set v2 [lindex [split $text] 1]
				if {$v1 == ""} {
					putserv "PRIVMSG $chan :o.0.O.0.o zboe Shop - use ${zboe::settings::gen::pubtrig}shop <item number>"
					putserv "NOTICE $nick :(1) Clip (${zboe::settings::shop::clips}xp) | (2) LevelUp! (${zboe::settings::shop::lvlup} horde tokens) | (3) Accuracy Up! (${zboe::settings::shop::accuracyupgrade} horde tokens) | (4) Horde Token (${zboe::settings::shop::hordetokens}xp)"
					putserv "NOTICE $nick :(5) Clip Storage Upgrade (${zboe::settings::shop::clipupgrade} Horde Tokens) | (6) Grease \[increase gun condition\] (${zboe::settings::shop::gungrease} XP) | (7) New Gun (${zboe::settings::shop::newgun} XP)"
					putserv "NOTICE $nick :(arsenal) display the Arsenal Shop"
					return 
				}
				if {[zboe::sql::util::checkxp $nick] == 0} { zboe::sql::util::dbmake "$nick" }
				set zscl "[zboe::sql::util::checkclips $nick]"
				set zspx "[zboe::sql::util::checkxp $nick]"
				set zsmc "[zboe::sql::util::checkmaxclips $nick]"
				set zspl "[zboe::sql::util::checklevel $nick]"
				set zsac "[zboe::sql::util::checkaccuracy $nick]"
				set zsht "[zboe::sql::util::checkhordetokens $nick]"
				set zsgc "[zboe::sql::util::checkcondition $nick]"
				if {$v1 == "1"} {
					if {$zspx >= ${zboe::settings::shop::clips}} {
						if {$zscl < $zsmc} {
							incr zscl
							incr zspx "-${zboe::settings::shop::clips}"
							zboe::sql::util::changeclips "$nick" "$zscl";
							zboe::sql::util::changexp "$nick" "$zspx";
							putserv "NOTICE $nick :o.0.O.0.o You purchased a clip, you now have $zscl/$zsmc clips";
							return
						} else { putserv "NOTICE $nick :o.0.O.0.o errr, you are at your max clips!"; return }
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "2"} {
					if {$zsht >= ${zboe::settings::shop::lvlup}} {
						incr zsht "-${zboe::settings::shop::lvlup}"
						incr zspl
						incr zsac 5
						incr zsmc 
						zboe::sql::util::changelevel "$nick" "$zspl"
						zboe::sql::util::changehordetokens "$nick" "$zsht"
						zboe::sql::util::changeaccuracy "$nick" "$zsac"
						zboe::sql::util::changemaxclips "$nick" "$zsmc";
						putserv "NOTICE $nick :o.0.O.0.o You leveled up to Level $zspl!";
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "3"} {
					if {$zsht >= ${zboe::settings::shop::accuracyupgrade}} {
						incr zsht "-${zboe::settings::shop::accuracyupgrade}"
						incr zsac 5
						zboe::sql::util::changehordetokens "$nick" "$zsht"
						zboe::sql::util::changeaccuracy "$nick" "$zsac"
						putserv "NOTICE $nick :o.0.O.0.o Max Accuracy inreased to $zsac";
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "4"} {
					if {$zspx >= ${zboe::settings::shop::hordetokens}} {
						incr zspx "-${zboe::settings::shop::hordetokens}"
						incr zsht
						zboe::sql::util::changehordetokens "$nick" "$zsht"
						zboe::sql::util::changexp "$nick" "$zspx"
						putserv "NOTICE $nick :o.0.O.0.o You purchased a Horde Token. You now have $zsht tokens.";
						return
						}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "5"} {
					if {$zsht >= ${zboe::settings::shop::clipupgrade}} {
						incr zsht "-${zboe::settings::shop::clipupgrade}"
						incr zsmc
						putserv "NOTICE $nick :o.0.O.0.o Max Clips inreased to $zsmc";
						zboe::sql::util::changehordetokens "$nick" "$zsht"
						zboe::sql::util::changemaxclips "$nick" "$zsmc"
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "6"} {
					if {$zspx >= ${zboe::settings::shop::gungrease}} {
						incr zspx "-${zboe::settings::shop::gungrease}"
						incr zsgc "10"
						if {$zsgc > "100"} { set zsgc "100"; }
						putserv "NOTICE $nick :o.0.O.0.o Gun Condition inreased to $zsgc";
						zboe::sql::util::changexp "$nick" "$zspx"
						zboe::sql::util::changecondition "$nick" "$zsgc"
						return
					}
					putserv "NOTICE $nick :o.0.O.0.o Error: You cannot afford that item!";
					return
				}
				if {$v1 == "7"} {
					if {$zspx >= ${zboe::settings::shop::newgun}} {
						if {$zsgc == "0"} {
							incr zspx "-${zboe::settings::shop::newgun}"
							set zsgc "100"
							putserv "NOTICE $nick :o.0.O.0.o You purchased a new gun!";
							zboe::sql::util::changexp "$nick" "$zspx"
							zboe::sql::util::changecondition "$nick" "$zsgc"
							return
						}
						putserv "NOTICE $nick :o.0.O.0.o Error: Your gun isnt broken!!"
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
		proc zboedbg {text} { putcmdlog "** zboe\[debug\] $text"; }
		proc act {chan text} { putserv "PRIVMSG $chan \01ACTION $text\01"; }
	}
	namespace eval sql {
        namespace eval util {
            proc dbmake {user} {
				set zdbc "[zdb eval {SELECT * FROM users WHERE user=$user}]"
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) dbmake: $user | $zdbc"; }
				set zdbc [lindex [split $zdbc] 0]
                if {$zdbc == $user} {
                    putcmdlog "***zboe|debug-sql|Error! Cannot create users row, it already exists."
                    return 
                } else {
                    putcmdlog "***zboe|debug-sql| Creating user $user row"
                    zdb eval {INSERT INTO users VALUES($user, 0, 1, 0, 55, "no", 6, 3, 6, 3, 0, 100)} -parameters [list user $user]
					putcmdlog "***zboe|debug-sql| User row $user Created"
                }
            }

            proc initdb {} {
				putcmdlog "***zboe|debug-sql| initializing sql"
                zdb eval {CREATE TABLE settings(hunt TEXT, zombiecount INTEGER, fullhorde TEXT, id INTEGER)}
                zdb eval {INSERT INTO settings VALUES('no', 0, 'no', 0)}
				#                               0           1            2           3              4                 5        6              7              8                 9                 10                     11    
				zdb eval {CREATE TABLE users(user TEXT, xp INTEGER, level INTEGER, kills INTEGER, accuracy INTEGER, jam TEXT, ammo INTEGER, clips INTEGER, maxammo INTEGER, maxclips INTEGER, hordetokens INTEGER, condition INTEGER)}
				putcmdlog "***zboe|debug-sql| SQL Database initialized"
            }

            proc checksetting {sett} {
                set zhnt "[zdb eval {SELECT * FROM settings}]"
				zboe::util::zboedbg "(level2) SETTINGS-GRAB: $zhnt"
				if {$sett == "hunt"} { set zhntok "0" }
				if {$sett == "zombiecount"} { set zhntok "1" }
				if {$sett == "fullhorde"} { set zhntok "2" }
                return [lindex [split $zhnt] $zhntok]
            }

            proc changesetting {sett v} {
				if {${zboe::settings::debug} >= "2"} { zboe::util::zboedbg "(level2) SETTINGS-CHANGE: $sett - $v" }
                zdb eval "UPDATE settings SET $sett = ('$v')"
            }
			
			proc changeuserdat {user col v} {
				zdb eval "UPDATE users SET $col = ('$v') WHERE user = '$user'"
			}

            proc checkxp {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 1]
            }

			proc checkaccuracy {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 4]
            }

			proc checkjam {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 5]
            }

            proc checklevel {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 2]
            }

            proc checkammo {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 6]
            }

            proc checkclips {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 7]
            }

            proc checkmaxammo {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 8]
            }

            proc checkmaxclips {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 9]
            }

            proc checkhordetokens {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 10]
            }
			proc checkcondition {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 11]
            }
            proc checkkills {user} {
                set zdbrt "[zdb eval {SELECT * FROM users WHERE user=$user}]"
                return [lindex [split $zdbrt] 3]
            }
			proc checkuser {user set} {
				set zdbrt [jdb eval "SELECT $set FROM users WHERE user=$user"]
			}
			proc changeuser {user set v} {
				zdb eval "UPDATE users SET $set = ('$v') WHERE user = '$user'"
			}
            proc changexp {user v} {
				zdb eval "UPDATE users SET xp = ('$v') WHERE user = '$user'"
            }

            proc changelevel {user v} {
                zdb eval "UPDATE users SET level = ('$v') WHERE USER = '$user'"
            }

			proc changeaccuracy {user v} {
                zdb eval "UPDATE users SET accuracy = ('$v') WHERE USER = '$user'"
            }

			proc changejam {user v} {
                zdb eval "UPDATE users SET jam = ('$v') WHERE USER = '$user'"
            }

            proc changeammo {user v} {
                zdb eval "UPDATE users SET ammo = ('$v') WHERE USER = '$user'"
            }

            proc changeclips {user v} {
                zdb eval "UPDATE users SET clips = ('$v') WHERE USER = '$user'"
            }

            proc changemaxammo {user v} {
                zdb eval "UPDATE users SET maxammo = ('$v') WHERE USER = '$user'"
            }

            proc changemaxclips {user v} {
                zdb eval "UPDATE users SET maxclips = ('$v') WHERE USER = '$user'"
            }

            proc changehordetokens {user v} {
                zdb eval "UPDATE users SET hordetokens = ('$v') WHERE USER = '$user'"
            }

            proc changekills {user v} {
                zdb eval "UPDATE users SET kills = ('$v') WHERE USER = '$user'"
            }
			proc changecondition {user v} {
                zdb eval "UPDATE users SET condition = ('$v') WHERE USER = '$user'"
            }
        }   
    }
}
