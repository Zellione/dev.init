local mp = require 'mp'
local utils = require 'mp.utils'

local state_dir = (os.getenv("XDG_STATE_HOME")
    or (os.getenv("HOME") .. "/.local/state")) .. "/mpv"

local state_file = state_dir .. "/volume"
local loading = false

local function ensure_state_dir()
    utils.subprocess({
        args = {"mkdir", "-p", state_dir},
        cancellable = false
    })
end

local function load_volume()
    local f = io.open(state_file, "r")
    if not f then
        return
    end

    local volume = tonumber(f:read("*l"))
    f:close()

    if volume then
        loading = true
        mp.set_property_number("volume", volume)
        loading = false
    end
end

local function save_volume(_, volume)
    if loading or volume == nil then
        return
    end

    ensure_state_dir()

    local f = io.open(state_file, "w")
    if not f then
        return
    end

    f:write(string.format("%.2f\n", volume))
    f:close()
end

mp.register_event("file-loaded", load_volume)
mp.observe_property("volume", "number", save_volume)
