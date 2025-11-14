return
{
    none = function (...) return end,
    info = function (...) return end,
    debug = function (...) return end,
    warn = function (...) return end,
    error = function (...) return end,
    get_log_level = function () return { num_val = math.huge } end
}