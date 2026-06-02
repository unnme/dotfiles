th.git = th.git or {}
th.git.modified_sign  = "M "
th.git.added_sign     = "+ "
th.git.untracked_sign = "? "
th.git.deleted_sign   = "D "
th.git.ignored_sign   = "I "
th.git.updated_sign   = "U "
th.git.clean_sign     = ""

require("git"):setup { order = 1500 }
