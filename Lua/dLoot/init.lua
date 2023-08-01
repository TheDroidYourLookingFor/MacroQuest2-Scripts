local mq = require 'mq'
local lootutils = require 'dLoot.lib.LootUtils'
local Messages = require('dLoot.lib.Messages')

local TheDroidLoot = {
    returnToHome = true,
    home_Dist = 10,
    home_X = mq.TLO.Me.X(),
    home_Y = mq.TLO.Me.Y(),
    home_Z = mq.TLO.Me.Z(),
    command_ShortName = 'dloot',
    terminate = false,
    spawnSearch = '%s radius %d zradius 50',
    doSell = false,
    doLoot = true
}

local test = {
    logger = Write,
    Version = "1.0",
    LootFile = mq.configDir .. '/Loot.ini',
    AddNewSales = true,
    LootForage = true,
    DoLoot = true,
    CorpseRadius = 100,
    MobsTooClose = 40,
    ReportLoot = true,
    LootChannel = "dgt",
    SpamLootInfo = false,
    LootForageSpam = false,
    GlobalLootOn = true,
    CombatLooting = true,
    GMLSelect = true,
    ExcludeBag1 = "Extraplanar Trade Satchel",
    QuestKeep = 10,
    StackPlatValue = 0,
    NoDropDefaults = "Quest|Keep|Ignore",
    LootLagDelay = 0,
    SaveBagSlots = 3,
    MinSellPrice = -1,
    StackableOnly = false,
    CorpseRotTime = "440s",
    Terminate = true,
}

local function GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

local function NavToXYZ(X, Y, Z)
    Messages.CONSOLEMETHOD(false, 'Moving to %s %s %s.', X, Y, Z)
    mq.cmdf('/nav locxyz %s %s %s', X, Y, Z)
    while mq.TLO.Navigation.Active() do
        if GetDistance(X, Y, Z) < TheDroidLoot.home_Dist then
            mq.cmd('/nav stop')
        end
        mq.delay(50)
    end
    mq.delay(250)
end

local function binds(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'sell' then
            TheDroidLoot.doSell = not TheDroidLoot.doSell
        elseif args[1] == 'loot' then
            TheDroidLoot.doLoot = not TheDroidLoot.doLoot
        elseif args[1] == 'radius' then
            if args[2] ~= nil then
                lootutils.CorpseRadius = args[2]
            else
                Messages.CONSOLEMETHOD('Please specify a radius value: /%s radius 100', TheDroidLoot.command_ShortName)
            end
        elseif args[1] == 'quit' then
            TheDroidLoot.terminate = true
        else
            Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', TheDroidLoot.command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', TheDroidLoot.command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', TheDroidLoot.command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', TheDroidLoot.command_ShortName)
        end
    else
        Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', TheDroidLoot.command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', TheDroidLoot.command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', TheDroidLoot.command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', TheDroidLoot.command_ShortName)
    end
end
mq.bind('/' .. TheDroidLoot.command_ShortName, binds)

Messages.CONSOLEMETHOD(false, '++ \agDROID LOOT BOT STARTED\aw ++')
mq.cmd('/hidecorpse looted')
if TheDroidLoot.returnToHome then
    TheDroidLoot.home_X = mq.TLO.Me.X()
    TheDroidLoot.home_Y = mq.TLO.Me.Y()
    TheDroidLoot.home_Z = mq.TLO.Me.Z()
    Messages.CONSOLEMETHOD(false, '++ Home X: \ag%s\aw Y: \ag%s\aw Z: \ag%s\aw ++', TheDroidLoot.home_X, TheDroidLoot.home_Y, TheDroidLoot.home_Z)
end
while not TheDroidLoot.terminate do
    local deadCount = mq.TLO.SpawnCount(TheDroidLoot.spawnSearch:format('npccorpse', lootutils.CorpseRadius))()
    if TheDroidLoot.doLoot and deadCount ~= 0 then
        if mq.TLO.Macro.Paused() ~= 'TRUE' and mq.TLO.Macro.Paused() ~= 'NULL' then mq.cmd('/mqpause on') end
        mq.delay(500)
        lootutils.lootMobs()
        Messages.CONSOLEMETHOD(false, 'Distance: %s',
            GetDistance(TheDroidLoot.home_X, TheDroidLoot.home_Y, TheDroidLoot.home_Z))
        if TheDroidLoot.returnToHome and GetDistance(TheDroidLoot.home_X, TheDroidLoot.home_Y, TheDroidLoot.home_Z) > TheDroidLoot.home_Dist then
            NavToXYZ(TheDroidLoot.home_X, TheDroidLoot.home_Y, TheDroidLoot.home_Z)
        end
        mq.delay(500)
        if mq.TLO.Macro.Paused() ~= 'FALSE' and mq.TLO.Macro.Paused() ~= 'NULL' then mq.cmd('/mqpause off') end
    end
    if TheDroidLoot.doSell then
        lootutils.sellStuff()
        TheDroidLoot.doSell = false
    end
    mq.delay(1000)
end

mq.unbind('/' .. TheDroidLoot.command_ShortName)

return TheDroidLoot
