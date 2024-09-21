local mq = require('mq')

local CoinMachine = {
    debug = true,
    Terminate = false,
    script_ShortName = 'CoinMachine'
}

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

local function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = CoinMachine.script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    if CoinMachine.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function PRINTMETHOD(printMessage, ...)
    printf(Colors.u .. "[CoinMachine]" .. Colors.w .. printMessage .. "\aC\n", ...)
end

function CoinMachine.Main()
    PRINTMETHOD('++ Initialized ++')
    CONSOLEMETHOD('Main Loop Entry')
    while not CoinMachine.Terminate do
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then MainLoop = false end
        if mq.TLO.Me.ItemReady('Bemvaras\' Coin Sack')() then mq.cmdf('/useitem %s', 'Bemvaras\' Coin Sack') end
        mq.delay(1000)
    end
    CONSOLEMETHOD('Main Loop Exit')
end

CoinMachine.Main()

return CoinMachine