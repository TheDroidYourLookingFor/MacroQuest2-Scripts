local mq = require('mq')
local messages = {}
messages.script_ShortName = 'SlurpyStone'

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
        printf("\ar[%s] \aw" .. consoleMessage..'\ax', ScriptInfo(), ...)
    else
        printf("\ag[%s] \aw" .. consoleMessage..'\ax', messages.script_ShortName, ...)
    end
end

function messages.POPUPMETHOD(popupMessage, ...)
    mq.cmdf('/popup %s', popupMessage, ...)
end

return messages
