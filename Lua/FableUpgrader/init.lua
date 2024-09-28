local mq = require('mq')
local FableUpgrader = {
    _version = '1.0.11',
    _author = 'TheDroidUrLookingFor'
}
FableUpgrader.MainLoop = true
FableUpgrader.debug = false
FableUpgrader.script_ShortName = 'FableUpgrader'
FableUpgrader.command_ShortName = 'FU'
FableUpgrader.command_LongName = 'FableUpgrader'
FableUpgrader.StopAt = 'L'
FableUpgrader.delayClickLink = 250

local Colors = {
    b = "\ab", -- black
    B = "\a-b", -- black (dark)

    g = "\ag", -- green
    G = "\a-g", -- green (dark)

    m = "\am", -- magenta
    M = "\a-m", -- magenta (dark)

    o = "\ao", -- orange
    O = "\a-o", -- orange (dark)

    p = "\ap", -- purple
    P = "\a-p", -- purple (dark)

    r = "\ar", -- red
    R = "\a-r", -- red (dark)

    t = "\at", -- cyan
    T = "\a-t", -- cyan (dark)

    u = "\au", -- blue
    U = "\a-u", -- blue (dark)

    w = "\aw", -- white
    W = "\a-w", -- white (dark)

    y = "\ay", -- yellow
    Y = "\a-y", -- yellow (dark)

    x = "\ax" -- previous color
}

function FableUpgrader.ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then
            break
        end -- a Lua function
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

function FableUpgrader.VersionCheck()
    local requiredVersion = {
        3,
        1,
        1,
        0
    } -- Required version as {major, minor, patch, build}
    local currentVersionStr = mq.TLO.MacroQuest.Version() -- Get the current version as string
    local currentVersion = {}

    -- Split the current version into components
    for v in string.gmatch(currentVersionStr, '([0-9]+)') do
        table.insert(currentVersion, tonumber(v))
    end

    -- Compare version components
    for i = 1, #requiredVersion do
        if currentVersion[i] == nil or currentVersion[i] < requiredVersion[i] then
            PRINTMETHOD('Your build is too old to run this script. Please get a newer version of MacroQuest from https://www.mq2emu.com')
            mq.cmdf('/lua stop %s', FableUpgrader.script_ShortName)
            return
        elseif currentVersion[i] > requiredVersion[i] then
            -- Version is higher, allow the script to continue
            return
        end
    end

    -- If all version numbers match, it's the required version
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
    local cursorItemName = mq.TLO.Cursor.Name()
    if string.find(cursorItemName, FableUpgrader.StopAt .. '$') then
        return
    end
    if string.find(currencyType, 'Doubloons') then
        mq.ExecuteTextLink(upgradeExtract)
        mq.delay(FableUpgrader.delayClickLink)
    elseif string.find(currencyType, 'Papers') then
        mq.ExecuteTextLink(upgradeExtract)
        mq.delay(FableUpgrader.delayClickLink)
    elseif string.find(currencyType, 'Cash') then
        mq.ExecuteTextLink(upgradeExtract)
        mq.delay(FableUpgrader.delayClickLink)
    end
    FableUpgrader.CONSOLEMETHOD(false, 'Upgrade cost: \ag%s %s\ax', currencyAmount, currencyType)
end

mq.event('UpgadeFabledItems', "#*#whispers, 'The cost for the next upgrade is #1# #2#.#*#?'", event_upgradeFabled_handler, {
    keepLinks = true
})
local function event_OutOfCurrency_handler(line, currencyAmount, currencyType)
    FableUpgrader.CONSOLEMETHOD(false, 'Missing currency: \ar%s %s\ax', currencyAmount, currencyType)
end
mq.event('OutOfCurrency', "You do not have enough alternate currency for this upgrade. You need #1# #2#.", event_OutOfCurrency_handler)

local function binds(...)
    local args = {
        ...
    }
    if args ~= nil then
        if args[1] == 'stopat' then
            if args[2] ~= nil then
                FableUpgrader.StopAt = args[2]
                FableUpgrader.CONSOLEMETHOD(false, 'StopAt: %s', FableUpgrader.StopAt)
            else
                FableUpgrader.CONSOLEMETHOD(false, 'Please specify a value: /%s stopat XL', FableUpgrader.command_ShortName)
            end
        elseif args[1] == 'quit' then
            FableUpgrader.MainLoop = false
            mq.cmdf('/lua stop %s', FableUpgrader.script_ShortName)
        else
            FableUpgrader.CONSOLEMETHOD(false, 'Valid Commands:')
            FableUpgrader.CONSOLEMETHOD(false, '/%s \agstopat\aw - Stops upgrading items based on string given.', FableUpgrader.command_ShortName)
            FableUpgrader.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', FableUpgrader.command_ShortName)
        end
    else
        FableUpgrader.CONSOLEMETHOD(false, 'Valid Commands:')
        FableUpgrader.CONSOLEMETHOD(false, '/%s \agstopat\aw - Stops upgrading items based on string given.', FableUpgrader.command_ShortName)
        FableUpgrader.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', FableUpgrader.command_ShortName)
    end
end

local function setupBinds()
    mq.bind('/' .. FableUpgrader.command_ShortName, binds)
    mq.bind('/' .. FableUpgrader.command_LongName, binds)
end

function FableUpgrader.Main()
    setupBinds()
    FableUpgrader.VersionCheck()
    while FableUpgrader.MainLoop do
        mq.doevents()
        mq.delay(100)
    end
end

FableUpgrader.Main()

return FableUpgrader
