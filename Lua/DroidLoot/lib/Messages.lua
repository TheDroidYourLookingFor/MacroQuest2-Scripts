local mq = require('mq')
local messages = { _version = '1.0', _author = 'TheDroidUrLookingFor' }
messages.script_ShortName = 'DroidLoot'
messages.debug = false

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

messages.outputLog = {}
-- Function to add output to the log with a timestamp
local function stripColors(str)
    -- ASCII 7 (bell) char is \a in Lua, but it is a single char with code 7
    -- We want to remove any sequence like: \a followed by optional '-' then a letter
    -- Pattern explanation:
    -- %a = letter, %- = literal dash
    -- So pattern: \a%-?%a
    -- But \a is ASCII 7, which in pattern is \a literally (the bell char)

    -- We'll remove all sequences of: <bell><optional dash><letter>
    -- So pattern is: "\a%-?%a"

    -- Use gsub to replace with empty string
    return str:gsub("\a%-?%a", "")
end

function messages.addToConsole(text, ...)
    local timestamp = os.date("[%H:%M:%S]")
    local formattedText = string.format(text, ...)

    -- Strip color codes from formattedText
    local cleanText = stripColors(formattedText)

    local logEntry = string.format("%s %s", timestamp, cleanText)
    table.insert(messages.outputLog, logEntry)
end

function messages.CONSOLEMETHOD(isDebugMessage, consoleMessage, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")
    if isDebugMessage then
        if messages.debug then
            printf("%s" .. Colors.g .. "[%s]" .. Colors.r .. consoleMessage .. Colors.x, timestamp, messages.ScriptInfo(), ...)
            messages.addToConsole("%s" .. consoleMessage, timestamp, messages.ScriptInfo(), ...)
        end
    else
        printf(Colors.W .. timestamp .. Colors.w .. consoleMessage .. Colors.x, ...)
        messages.addToConsole(consoleMessage, ...)
    end
end

function messages.POPUPMETHOD(popupMessage, ...)
    mq.cmdf('/popup %s', popupMessage, ...)
end

function messages.Normal(consoleMessage, ...)
    messages.CONSOLEMETHOD(false, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. '] ' .. Colors.w .. consoleMessage, ...)
end

function messages.Info(consoleMessage, ...)
    messages.CONSOLEMETHOD(false, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. ']' .. Colors.p .. '[INFO] ' .. Colors.w .. consoleMessage, ...)
end

function messages.Warn(consoleMessage, ...)
    messages.CONSOLEMETHOD(false, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. ']' .. Colors.y .. '[WARN] ' .. Colors.w .. consoleMessage, ...)
end

function messages.Debug(consoleMessage, ...)
    messages.CONSOLEMETHOD(true, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. ']' .. Colors.p .. '[DEBUG] ' .. Colors.w .. consoleMessage, ...)
end

function messages.Error(consoleMessage, ...)
    messages.CONSOLEMETHOD(false, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. ']' .. Colors.Y .. '[ERROR] ' .. Colors.w .. consoleMessage, ...)
end

function messages.Fatal(consoleMessage, ...)
    messages.CONSOLEMETHOD(true, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. ']' .. Colors.R .. '[FATAL] ' .. Colors.w .. consoleMessage, ...)
end

function messages.Trace(consoleMessage, ...)
    messages.CONSOLEMETHOD(false, Colors.T .. '[' .. Colors.y .. messages.script_ShortName .. Colors.T .. ']' .. Colors.P .. '[TRACE] ' .. Colors.w .. consoleMessage, ...)
end

return messages
