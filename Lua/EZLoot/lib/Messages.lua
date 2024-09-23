local mq = require('mq')
local messages = {}
messages.script_ShortName = 'FableLooter'

local Colors = {
    b = "\ab",  -- black
    B = "\a-b", -- black (dark)

    g = "\ag",  -- green
    G = "\a-g", -- green (dark)

    m = "\am",  -- magenta
    M = "\a-m", -- magenta (dark)

    o = "\ao",  -- orange
    O = "\a-o", -- orange (dark)

    p = "\ap",  -- purple
    P = "\a-p", -- purple (dark)

    r = "\ar",  -- red
    R = "\a-r", -- red (dark)

    t = "\at",  -- cyan
    T = "\a-t", -- cyan (dark)

    u = "\au",  -- blue
    U = "\a-u", -- blue (dark)

    w = "\aw",  -- white
    W = "\a-w", -- white (dark)

    y = "\ay",  -- yellow
    Y = "\a-y", -- yellow (dark)

    x = "\ax"   -- previous color
}

function messages.ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = messages.script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function messages.CONSOLEMETHOD(isDebugMessage, consoleMessage, ...)
    if isDebugMessage then
        if FableLooter.debug then
            printf(Colors.g .. "[%s] " .. Colors.r .. consoleMessage .. Colors.x, ScriptInfo(), ...)
        end
    else
        printf(Colors.g .. "[%s] " .. Colors.w .. consoleMessage .. Colors.x, messages.script_ShortName, ...)
    end
end

function messages.POPUPMETHOD(popupMessage, ...)
    mq.cmdf('/popup %s', popupMessage, ...)
end

return messages
