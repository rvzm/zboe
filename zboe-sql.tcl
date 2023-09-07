# zboe sqlite3

namespace eval zboe {
    namespace eval sql {
        sqlite3 zdb "scripts/zboe/zhunt.sql"

        namespace eval util {
            proc dbmake {user} {
                if {[catch {zdb eval {SELECT xp FROM users WHERE user=:user} -parameters [list user $user]} err]} {
                    putcmdlog "***zboe|debug-sql|Err! Creating users row, it already exists."
                    return 
                } else {
                    putcmdlog "***zboe|debug-sql| Creating user $user row"
                    zdb eval {INSERT INTO users VALUES("$user", 0, 1, 0, 55, "no", 6, 3, 6, 3, 0)}
                }
            }

            proc initdb {} {
                zdb eval {CREATE TABLE settings(hunt TEXT, zombiecount INTEGER, fullhorde TEXT)}
                zdb eval {INSERT INTO settings VALUES('no', 0, 'no')}
				zdb eval {CREATE TABLE users(user TEXT, xp INTEGER, level INTEGER, kills INTEGER, accuracy INTEGER, jam TEXT, ammo INTEGER, clips INTEGER, maxammo INTEGER, maxclips INTEGER, hordetokens INTEGER)}
            }

            proc checksetting {glob} {
                set zhnt [zdb eval {SELECT $glob FROM settings}]
                return $zhnt
            }

            proc changesetting {glob v} {
                zdb eval {INSERT OR REPLACE INTO settings ($glob) VALUES (:v)} -parameters [list v $v]
            }

            proc checkxp {user} {
                set zdbrt [zdb eval {SELECT xp FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

			proc checkaccuracy {user} {
                set zdbrt [zdb eval {SELECT accuracy FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

			proc checkjam {user} {
                set zdbrt [zdb eval {SELECT jam FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checklevel {user} {
                set zdbrt [zdb eval {SELECT level FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checkammo {user} {
                set zdbrt [zdb eval {SELECT ammo FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checkclips {user} {
                set zdbrt [zdb eval {SELECT clips FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checkmaxammo {user} {
                set zdbrt [zdb eval {SELECT maxammo FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checkmaxclips {user} {
                set zdbrt [zdb eval {SELECT maxclips FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checkhordetokens {user} {
                set zdbrt [zdb eval {SELECT hordetokens FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc checkkills {user} {
                set zdbrt [zdb eval {SELECT kills FROM users WHERE user=:user} -parameters [list user $user]]
                return $zdbrt
            }

            proc changexp {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, xp) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changelevel {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, level) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

			proc changeaccuracy {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, accuracy) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

			proc changejam {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, jam) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changeammo {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, ammo) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changeclips {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, clips) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changemaxammo {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, maxammo) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changemaxclips {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, maxclips) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changehordetokens {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, hordetokens) VALUES (:user, :v)} -parameters [list user $user v $v]
            }

            proc changekills {user v} {
                zdb eval {INSERT OR REPLACE INTO users (user, kills) VALUES (:user, :v)} -parameters [list user $user v $v]
            }
        }   
    }
}
