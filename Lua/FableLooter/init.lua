local mq = require('mq')
local LootUtils = require('FableLooter.lib.LootUtils')

local FableLooter = {
    script_ShortName = 'FableLooter',
    debug = false,
    Terminate = false,
    needToBank = false,
    mob_Wait = 50000
}
mq.TLO.Me.FreeInventory()
FableLooter.Settings = {
    bankDeposit = true,
    bankAtFreeSlots = 5,
    bankZone = 451,
    bankNPC = 'Griphook',
    scan_Radius = 10000,
    scan_zRadius = 250,
    returnToCampDistance = 200,
    camp_Check = false,
    zone_Check = true,
    lootGroundSpawns = true,
    returnHomeAfterLoot = true,
    doStand = true,
    lootAll = false,
    targetName = 'treasure',
    spawnSearch = '%s radius %d zradius %d',
    huntZoneID = mq.TLO.Zone.ID(),
    huntZoneName = mq.TLO.Zone.ShortName(),
    camp_X = mq.TLO.Me.X(),
    camp_Y = mq.TLO.Me.Y(),
    camp_Z = mq.TLO.Me.Z()
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
        if not FableLooter.needToBank then
            mq.delay(1000)
            mq.cmd('/say #enter')
            mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.Settings.huntZoneID end)
            mq.delay(1000)
        end
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
            mq.cmdf('/squelch /warp loc %s %s %s', FableLooter.Settings.camp_Y, FableLooter.Settings.camp_X,
                FableLooter.Settings.camp_Z)
            mq.delay(500)
        end
    end
end

function FableLooter.GroundSpawns()
    if mq.TLO.GroundItemCount('Generic')() > 0 then
        mq.cmdf('/squelch /warp loc %s %s %s', mq.TLO.ItemTarget.Y(), mq.TLO.ItemTarget.X(), mq.TLO.ItemTarget.Z())
        mq.delay(250)
        mq.cmd('/click left item')
        mq.delay(250)
        if mq.TLO.Cursor() then
            LootUtils.report('Picked Up: %s', mq.TLO.Cursor.ItemLink('CLICKABLE')())
            mq.cmd('/autoinv')
            mq.delay(5000, function() return mq.TLO.Cursor()() == nil end)
            mq.delay(250)
        end
        if FableLooter.Settings.returnHomeAfterLoot then
            mq.cmdf('/squelch /warp loc %s %s %s', FableLooter.Settings.camp_Y, FableLooter.Settings.camp_X,
                FableLooter.Settings.camp_Z)
            mq.delay(250)
        end
    end
end

function FableLooter.BankDropOff()
    if mq.TLO.Me.FreeInventory() <= FableLooter.Settings.bankAtFreeSlots or FableLooter.needToBank then
        if mq.TLO.Zone.ID() ~= FableLooter.Settings.bankZone then
            mq.cmdf('/say #zone %s', FableLooter.Settings.bankZone)
            mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.Settings.bankZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == FableLooter.Settings.bankZone then
            mq.cmdf('/target npc %s', FableLooter.Settings.bankNPC)
            mq.delay(250)
            mq.delay(5000, function() return mq.TLO.Target()() ~= nil end)
            mq.cmd('/squelch /warp t')
            mq.delay(500)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function() return mq.TLO.Window('MerchantWnd').Open() end)
            LootUtils.bankStuff()
            FableLooter.needToBank = false
        end
    end
end

local function commandHandler(...)
    local args = { ... }
    if #args == 1 then
        if args[1] == 'bank' then
            FableLooter.needToBank = true
            FableLooter.BankDropOff()
        end
    end
end

local function setupBinds()
    mq.bind('/fableloot', commandHandler)
end

local function event_CantLoot_handler(line)
    CONSOLEMETHOD('function event_CantLoot_handler(line)')
    mq.cmdf('%s', '/say #corpsefix')
end
mq.event('OutOfRange1', "#*#You are too far away to loot that corpse#*#", event_CantLoot_handler)
mq.event('OutOfRange2', "#*#Corpse too far away.#*#", event_CantLoot_handler)

function FableLooter.Main()
    setupBinds()
    mq.cmd('/hidecorpse looted')
    PRINTMETHOD('++ Initialized ++')
    CONSOLEMETHOD('Main Loop Entry')
    while not FableLooter.Terminate do
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then MainLoop = false end
        if mq.TLO.Me.ItemReady('Bemvaras\' Coin Sack')() then mq.cmdf('/useitem %s', 'Bemvaras\' Coin Sack') end
        if FableLooter.Settings.bankDeposit and mq.TLO.Me.FreeInventory() <= FableLooter.Settings.bankAtFreeSlots then
            FableLooter.needToBank = true
            FableLooter.BankDropOff()
        end
        if FableLooter.Settings.zone_Check then FableLooter.CheckZone() end
        if FableLooter.Settings.camp_Check then FableLooter.MoveToCamp() end
        if FableLooter.doStand and not mq.TLO.Me.Standing() then mq.cmd('/stand') end
        if mq.TLO.SpawnCount(FableLooter.Settings.spawnSearch:format('corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))() > 0 or (FableLooter.Settings.lootAll and mq.TLO.SpawnCount(FableLooter.Settings.spawnSearch:format('corpse', FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))() > 0) then
            if FableLooter.Settings.lootAll then
                mq.cmdf('/target %s',mq.TLO.NearestSpawn(FableLooter.Settings.spawnSearch:format('corpse', FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))())
            else
                mq.cmdf('/target %s',mq.TLO.NearestSpawn(FableLooter.Settings.spawnSearch:format('corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))())
            end
            if mq.TLO.Target() and mq.TLO.Target.Type() == 'Corpse' then
                mq.cmd('/squelch /warp t')
                mq.delay(100)
                if FableLooter.doStand and not mq.TLO.Me.Standing() then
                    mq.cmd('/stand')
                    mq.delay(250)
                end
                LootUtils.lootCorpse(mq.TLO.Target.ID())
                mq.delay(100)
                mq.doevents()
                mq.delay(100)
                if FableLooter.Settings.returnHomeAfterLoot then
                    mq.cmdf('/squelch /warp loc %s %s %s', FableLooter.Settings.camp_Y, FableLooter.Settings.camp_X,
                        FableLooter.Settings.camp_Z)
                    mq.delay(100)
                end
            end
        end
        FableLooter.GroundSpawns()
        mq.delay(100)
    end
    CONSOLEMETHOD('Main Loop Exit')
end

FableLooter.Main()

mq.unbind('/fableloot')

return FableLooter
