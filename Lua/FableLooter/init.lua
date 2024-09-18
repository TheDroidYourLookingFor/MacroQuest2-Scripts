local mq = require('mq')
local LootUtils = require('FableLooter.lib.LootUtils')

local FableLooter = {
    script_ShortName = 'FableLooter',
    debug = false,
    Terminate = false,
    mob_Wait = 50000,
}

FableLooter.Settings = {
    camp_Check = false,
    zone_Check = true,
    huntZoneID = mq.TLO.Zone.ID(),
    huntZoneName = mq.TLO.Zone.ShortName(),
    camp_X = mq.TLO.Me.X(),
    camp_Y = mq.TLO.Me.Y(),
    camp_Z = mq.TLO.Me.Z(),
    returnToCampDistance = 200,
    doStand = true,
    targetName = 'treasure',
    spawnSearch = '%s radius %d zradius %d',
    corpse_Radius = 200,
    corpse_zRadius = 25,
    aggro_Radius = 2000,
    aggro_zRadius = 250
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
        sName = FableLooter.script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    if FableLooter.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function PRINTMETHOD(printMessage, ...)
    printf(Colors.u .. "[Fable Looter]" .. Colors.w .. printMessage .. "\aC\n", ...)
end

function FableLooter.CheckZone()
    if mq.TLO.Zone.ID() ~= FableLooter.Settings.huntZoneID and mq.TLO.DynamicZone() ~= nil then
        mq.delay(1000)
        mq.cmd('/say #enter')
        mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.Settings.huntZoneID end)
        mq.delay(1000)
    end
end

function FableLooter.CheckDistanceToXYZ()
    local deltaX = FableLooter.Settings.camp_X - mq.TLO.Me.X()
    local deltaY = FableLooter.Settings.camp_Y - mq.TLO.Me.Y()
    local deltaZ = FableLooter.Settings.camp_Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function FableLooter.MoveToCamp()
    if mq.TLO.Zone.ID() == FableLooter.Settings.huntZoneID then
        if FableLooter.CheckDistanceToXYZ() > FableLooter.Settings.returnToCampDistance then
            mq.cmdf('/warp loc %s %s %s', FableLooter.Settings.camp_Y, FableLooter.Settings.camp_X, FableLooter.Settings.camp_Z)
            mq.delay(500)
        end
    end
end

function FableLooter.Main()
    mq.cmd('/hidecorpse looted')
    PRINTMETHOD('++ Initialized ++')
    CONSOLEMETHOD('Main Loop Entry')
    while not FableLooter.Terminate do
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then MainLoop = false end
        if FableLooter.Settings.camp_Check then FableLooter.MoveToCamp() end
        if FableLooter.Settings.zone_Check then FableLooter.CheckZone() end
        if FableLooter.doStand and not mq.TLO.Me.Standing() then mq.cmd('/stand') end
        if mq.TLO.SpawnCount(FableLooter.Settings.spawnSearch:format('corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.aggro_Radius, FableLooter.Settings.aggro_zRadius))() > 0 then
            mq.cmdf('/target %s', mq.TLO.NearestSpawn(FableLooter.Settings.spawnSearch:format('corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.aggro_Radius, FableLooter.Settings.aggro_zRadius))())
            if mq.TLO.Target() and mq.TLO.Target.Type() == 'Corpse' then
                mq.cmd('/warp t')
                mq.delay(250)
                LootUtils.lootCorpse(mq.TLO.Target.ID())
                mq.delay(250)
            end
        end
        mq.delay(100)
    end
    CONSOLEMETHOD('Main Loop Exit')
end

FableLooter.Main()

return FableLooter
