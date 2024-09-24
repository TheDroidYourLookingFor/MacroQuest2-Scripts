local mq = require 'mq'
---@type ImGui
local ImGui = require 'ImGui'

EZLoot = {
    debug = false,
    announce = true,
    say = 'rsay',
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
    doLootMessages = false,
    doPause = false,
    doCorpseFix = false,
}

EZLoot.LootUtils = require('EZLoot.lib.LootUtils')
EZLoot.Messages = require('EZLoot.lib.Messages')
EZLoot.GUI = require('EZLoot.lib.Gui')
EZLoot.Storage = require('EZLoot.lib.Storage')
if not EZLoot.Storage.dir_exists(mq.configDir .. '\\EZLoot') then EZLoot.Storage.make_dir(mq.configDir, 'EZLoot') end
local function GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

local function NavToXYZ(X, Y, Z)
    EZLoot.Messages.CONSOLEMETHOD(false, 'Moving to %s %s %s.', X, Y, Z)
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
            EZLoot.GUI.Open = not EZLoot.GUI.Open
        elseif args[1] == 'sell' then
            EZLoot.doSell = not EZLoot.doSell
        elseif args[1] == 'loot' then
            EZLoot.doLoot = not EZLoot.doLoot
        elseif args[1] == 'radius' then
            if args[2] ~= nil then
                EZLoot.LootUtils.CorpseRadius = args[2]
            else
                EZLoot.Messages.CONSOLEMETHOD('Please specify a radius value: /%s radius 100', EZLoot.command_ShortName)
            end
        elseif args[1] == 'quit' then
            EZLoot.terminate = true
        else
            EZLoot.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', EZLoot.command_ShortName)
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', EZLoot.command_ShortName)
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', EZLoot.command_ShortName)
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', EZLoot.command_ShortName)
        end
    else
        EZLoot.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        EZLoot.Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', EZLoot.command_ShortName)
        EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', EZLoot.command_ShortName)
        EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', EZLoot.command_ShortName)
        EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', EZLoot.command_ShortName)
    end
end
mq.bind('/' .. EZLoot.command_ShortName, binds)
mq.bind('/' .. EZLoot.command_LongName, binds)

EZLoot.GUI.initGUI()

EZLoot.Messages.CONSOLEMETHOD(false, '++ \agDROID LOOT BOT STARTED\aw ++')
mq.cmd('/hidecorpse looted')
if EZLoot.returnToHome then
    EZLoot.home_X = mq.TLO.Me.X()
    EZLoot.home_Y = mq.TLO.Me.Y()
    EZLoot.home_Z = mq.TLO.Me.Z()
    EZLoot.Messages.CONSOLEMETHOD(false, '++ Home X: \ag%s\aw Y: \ag%s\aw Z: \ag%s\aw ++', EZLoot.home_X, EZLoot.home_Y,
        EZLoot.home_Z)
end
while not EZLoot.terminate do
    if not EZLoot.doPause then
        local deadCount = mq.TLO.SpawnCount(EZLoot.spawnSearch:format('npccorpse', EZLoot.LootUtils.CorpseRadius))()
        if EZLoot.doLoot and deadCount ~= 0 then
            if EZLoot.announce and EZLoot.doLootMessages then mq.cmdf('/%s [%s]Started Looting!',EZLoot.LootUtils.AnnounceChannel,mq.TLO.Time()) end
            if EZLoot.doCorpseFix then mq.cmd('/say #corpsefix') end
            if mq.TLO.Macro() ~= nil and mq.TLO.Macro.Paused() ~= 'TRUE' then mq.cmd('/mqpause on') end
            mq.delay(500)
            EZLoot.LootUtils.lootMobs()
            if EZLoot.debug then EZLoot.Messages.CONSOLEMETHOD(false, 'Corpse Distance: %s',
                GetDistance(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z)) end
            if EZLoot.returnToHome and GetDistance(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z) > EZLoot.home_Dist then
                NavToXYZ(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z)
            end
            mq.delay(500)
            if mq.TLO.Macro() ~= nil and mq.TLO.Macro.Paused() ~= 'FALSE' then mq.cmd('/mqpause off') end
            if EZLoot.announce and EZLoot.doLootMessages then mq.cmdf('/%s [%s]Done Looting; no more corpses within range!',EZLoot.LootUtils.AnnounceChannel,mq.TLO.Time()) end
        end
        if EZLoot.doSell then
            EZLoot.LootUtils.sellStuff()
            EZLoot.doSell = false
        end
    end
    mq.delay(1000)
end

mq.unbind('/' .. EZLoot.command_ShortName)
mq.unbind('/' .. EZLoot.command_LongName)

return EZLoot
