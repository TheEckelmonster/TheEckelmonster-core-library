local log_constants = {}

log_constants.levels = {}

-- {{ INFO }} --
log_constants.INFO = {
    name = "INFO",
    string_val = "Info",
    num_val = 1
}

log_constants.levels[log_constants.INFO.num_val] = {
    num_val = log_constants.INFO.num_val,
    string_val = log_constants.INFO.string_val,
    valid = true
}

-- {{ DEBUG }} --
log_constants.DEBUG = {
    name = "DEBUG",
    string_val = "Debug",
    num_val = log_constants.INFO.num_val + 1
}

log_constants.levels[log_constants.DEBUG.num_val] = {
    num_val = log_constants.DEBUG.num_val,
    string_val = log_constants.DEBUG.string_val,
    valid = true
}

-- {{ WARN }} --
log_constants.WARN = {
    name = "WARN",
    string_val = "Warn",
    num_val = log_constants.DEBUG.num_val + 1
}

log_constants.levels[log_constants.WARN.num_val] = {
    num_val = log_constants.WARN.num_val,
    string_val = log_constants.WARN.string_val,
    valid = true
}

-- {{ ERROR }} --
log_constants.ERROR = {
    name = "ERROR",
    string_val = "Error",
    num_val = log_constants.WARN.num_val + 1
}

log_constants.levels[log_constants.ERROR.num_val] = {
    num_val = log_constants.ERROR.num_val,
    string_val = log_constants.ERROR.string_val,
    valid = true
}

-- {{ NONE }} --
log_constants.NONE = {
    name = "NONE",
    string_val = "None",
    num_val = log_constants.ERROR.num_val + 1
}

log_constants.levels[log_constants.NONE.num_val] = {
    num_val = log_constants.NONE.num_val,
    string_val = log_constants.NONE.string_val,
    valid = true
}

log_constants.settings = {}

log_constants.constants = {}
log_constants.constants.EMPTY_STRING = ""

log_constants.settings.DEBUG_LEVEL = {
    value = "None",
    name = "debug-level",
}

log_constants.settings.DO_NOT_PRINT = {
    type = "bool-setting",
    name = "do-not-print",
    setting_type = "runtime-global",
    order = "abb",
    default_value = true,
}

log_constants.settings.DO_TRACEBACK = {
    type = "bool-setting",
    name = "do-traceback",
    setting_type = "runtime-global",
    order = "abc",
    default_value = false
}

return log_constants