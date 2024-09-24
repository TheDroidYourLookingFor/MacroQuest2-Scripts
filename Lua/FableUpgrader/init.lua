local mq = require('mq')

local FableUpgrader = {
    debug = true
}
FableUpgrader.script_ShortName = 'FableUpgrader'

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

function FableUpgrader.ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = FableUpgrader.script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function FableUpgrader.CONSOLEMETHOD(isDebugMessage, consoleMessage, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")
    if isDebugMessage then
        if FableUpgrader.debug then
            printf("%s" .. Colors.g .. "[%s] " .. Colors.r .. consoleMessage .. Colors.x, timestamp, ScriptInfo(), ...)
        end
    else
        printf("%s" .. Colors.g .. "[%s] " .. Colors.w .. consoleMessage .. Colors.x, timestamp, FableUpgrader.script_ShortName, ...)
    end
end

local function event_upgradeFabled_handler(line, currencyAmount, currencyType)
    local links = mq.ExtractLinks(line)
    local upgradeExtract
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'Upgrade Again') then
            upgradeExtract = link
        end
    end
    if string.find(currencyType, 'Doubloons') then
        mq.ExecuteTextLink(upgradeExtract)
        mq.delay(500)
    elseif string.find(currencyType, 'Papers') then
        mq.ExecuteTextLink(upgradeExtract)
        mq.delay(500)
    elseif string.find(currencyType, 'Cash') then
        mq.ExecuteTextLink(upgradeExtract)
        mq.delay(500)
    end
    FableUpgrader.CONSOLEMETHOD(false, 'Upgrade cost: \ag%s %s\ax', currencyAmount, currencyType)
end
mq.event('UpgadeFabledItems', "#*#whispers, 'The cost for the next upgrade is #1# #2#.#*#?'", event_upgradeFabled_handler, { keepLinks = true })
local function event_OutOfCurrency_handler(line, currencyAmount, currencyType)
    FableUpgrader.CONSOLEMETHOD(false, 'Missing currency: \ar%s %s\ax', currencyAmount, currencyType)
end
mq.event('OutOfCurrency', "You do not have enough alternate currency for this upgrade. You need #1# #2#.", event_OutOfCurrency_handler)

function FableUpgrader.Main()
    while true do
        mq.doevents()
        mq.delay(250)
    end
end

FableUpgrader.Main()

return FableUpgrader
