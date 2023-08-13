local mq = require 'mq'
local lootutils = require 'EZLoot.lib.LootUtils'
local Messages = require('EZLoot.lib.Messages')
local GUI = require('EZLoot.lib.Gui')
local Storage = require('EZLoot.lib.Storage')
if not Storage.dir_exists(mq.configDir .. '\\EZLoot') then Storage.make_dir(mq.configDir, 'EZLoot') end

EZLoot = {
    debug = false,
    returnToHome = false,
    home_Dist = 10,
    home_X = mq.TLO.Me.X(),
    home_Y = mq.TLO.Me.Y(),
    home_Z = mq.TLO.Me.Z(),
    command_ShortName = 'ezl',
    command_LongName = 'ezloot',
    terminate = false,
    spawnSearch = '%s radius %d zradius 50',
    doSell = false,
    doLoot = true,
    doPause = false,
    doCorpseFix = false,
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
        if GetDistance(X, Y, Z) < EZLoot.home_Dist then
            mq.cmd('/nav stop')
        end
        mq.delay(50)
    end
    mq.delay(250)
end

local function binds(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            GUI.Open = not GUI.Open
        elseif args[1] == 'sell' then
            EZLoot.doSell = not EZLoot.doSell
        elseif args[1] == 'loot' then
            EZLoot.doLoot = not EZLoot.doLoot
        elseif args[1] == 'radius' then
            if args[2] ~= nil then
                lootutils.CorpseRadius = args[2]
            else
                Messages.CONSOLEMETHOD('Please specify a radius value: /%s radius 100', EZLoot.command_ShortName)
            end
        elseif args[1] == 'quit' then
            EZLoot.terminate = true
        else
            Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', EZLoot.command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', EZLoot.command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', EZLoot.command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', EZLoot.command_ShortName)
        end
    else
        Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', EZLoot.command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', EZLoot.command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', EZLoot.command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', EZLoot.command_ShortName)
    end
end
mq.bind('/' .. EZLoot.command_ShortName, binds)
mq.bind('/' .. EZLoot.command_LongName, binds)

GUI.initGUI()

Messages.CONSOLEMETHOD(false, '++ \agDROID LOOT BOT STARTED\aw ++')
mq.cmd('/hidecorpse looted')
if EZLoot.returnToHome then
    EZLoot.home_X = mq.TLO.Me.X()
    EZLoot.home_Y = mq.TLO.Me.Y()
    EZLoot.home_Z = mq.TLO.Me.Z()
    Messages.CONSOLEMETHOD(false, '++ Home X: \ag%s\aw Y: \ag%s\aw Z: \ag%s\aw ++', EZLoot.home_X, EZLoot.home_Y,
        EZLoot.home_Z)
end
while not EZLoot.terminate do
    if not EZLoot.doPause then
        local deadCount = mq.TLO.SpawnCount(EZLoot.spawnSearch:format('npccorpse', lootutils.CorpseRadius))()
        if EZLoot.doLoot and deadCount ~= 0 then
            if mq.TLO.Macro.Paused() ~= 'TRUE' and mq.TLO.Macro.Paused() ~= 'NULL' then mq.cmd('/mqpause on') end
            mq.delay(500)
            lootutils.lootMobs()
            Messages.CONSOLEMETHOD(false, 'Distance: %s',
                GetDistance(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z))
            if EZLoot.returnToHome and GetDistance(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z) > EZLoot.home_Dist then
                NavToXYZ(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z)
            end
            mq.delay(500)
            if mq.TLO.Macro.Paused() ~= 'FALSE' and mq.TLO.Macro.Paused() ~= 'NULL' then mq.cmd('/mqpause off') end
        end
        if EZLoot.doSell then
            lootutils.sellStuff()
            EZLoot.doSell = false
        end
    end
    mq.delay(1000)
end

mq.unbind('/' .. EZLoot.command_ShortName)
mq.unbind('/' .. EZLoot.command_LongName)

return EZLoot
