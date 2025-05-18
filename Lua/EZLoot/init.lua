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
EZLoot.needToBank = false
EZLoot.needToVendorSell = false

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

function EZLoot.HandleDisconnect()
    if EZLoot.NewDisconnectHandler then
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' and not mq.TLO.AutoLogin.Active() then
            mq.TLO.AutoLogin.Profile.ReRun()
            mq.delay(50)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(50)
            mq.cmd('/hidecorpse looted')
        end
    else
        if mq.TLO.EverQuest.GameState() == 'PRECHARSELECT' then
            mq.cmd("/notify serverselect SERVERSELECT_PlayLastServerButton leftmouseup")
            mq.delay(50)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'CHARSELECT'
            end)
            mq.delay(50)
        end
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
            mq.cmd("/notify CharacterListWnd CLW_Play_Button leftmouseup")
            mq.delay(50)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(50)
            mq.cmd('/hidecorpse looted')
        end
    end
end

function EZLoot.CheckZone()
    EZLoot.HandleDisconnect()
    if mq.TLO.Zone.ID() ~= EZLoot.huntZoneID and mq.TLO.DynamicZone() ~= nil then
        if not EZLoot.needToBank and not EZLoot.needToCashSell and not EZLoot.needToFabledSell then
            mq.delay(1000)
            mq.cmd('/say #enter')
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == EZLoot.huntZoneID
            end)
            mq.delay(1000)
        end
    end
end

function EZLoot.BankDropOff()
    EZLoot.HandleDisconnect()
    if mq.TLO.Me.FreeInventory() <= EZLoot.Settings.bankAtFreeSlots or EZLoot.needToBank then
        if mq.TLO.Zone.ID() ~= EZLoot.Settings.bankZone then
            mq.cmdf('/say #zone %s', EZLoot.Settings.bankZone)
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == EZLoot.Settings.bankZone
            end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == EZLoot.Settings.bankZone then
            mq.cmdf('/target npc %s', EZLoot.Settings.bankNPC)
            mq.delay(250)
            mq.delay(5000, function()
                return mq.TLO.Target()() ~= nil
            end)
            mq.cmd('/squelch /warp t')
            mq.delay(500)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function()
                return mq.TLO.Window('BigBankWnd').Open()
            end)
            mq.delay(50)
            EZLoot.LootUtils.bankStuff()
            mq.delay(500)
            if EZLoot.Settings.sellVendor then
                EZLoot.needToVendorSell = true
                EZLoot.VendorSell()
                mq.delay(500)
            end
            EZLoot.needToBank = false
        end
    end
end

function EZLoot.VendorSell()
    EZLoot.HandleDisconnect()
    if EZLoot.needToVendorSell then
        if mq.TLO.Zone.ID() ~= EZLoot.LootUtils.bankZone then
            mq.cmdf('/say #zone %s', EZLoot.LootUtils.bankZone)
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == EZLoot.LootUtils.bankZone
            end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == EZLoot.LootUtils.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', EZLoot.LootUtils.vendorNPC)
            mq.delay(250)
            mq.delay(5000, function()
                return mq.TLO.Target()() ~= nil
            end)
            mq.cmd('/squelch /warp t')
            mq.delay(1000)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function()
                return mq.TLO.Window('MerchantWnd').Open()
            end)
            EZLoot.LootUtils.sellStuff()
            EZLoot.needToVendorSell = false
        end
    end
end

local function binds(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            EZLoot.GUI.Open = not EZLoot.GUI.Open
        elseif args[1] == 'bank' then
            EZLoot.needToBank = true
            EZLoot.BankDropOff()
        elseif args[1] == 'vendor' then
            EZLoot.needToVendorSell = true
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
            mq.cmdf('/lua stop %s', 'EZLoot')
            EZLoot.terminate = true
        else
            EZLoot.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI',
                EZLoot.command_ShortName)
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', EZLoot.command_ShortName)
            EZLoot.Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', EZLoot
                .command_ShortName)
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
            if EZLoot.announce and EZLoot.doLootMessages then mq.cmdf('/%s [%s]Started Looting!',
                    EZLoot.LootUtils.AnnounceChannel, mq.TLO.Time()) end
            if EZLoot.doCorpseFix then mq.cmd('/say #corpsefix') end
            if mq.TLO.Macro() ~= nil and mq.TLO.Macro.Paused() ~= 'TRUE' then
                mq.cmd('/mqpause on')
                mq.delay(500)
            end
            EZLoot.LootUtils.lootMobs()
            if EZLoot.debug then EZLoot.Messages.CONSOLEMETHOD(false, 'Corpse Distance: %s',
                    GetDistance(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z)) end
            if EZLoot.returnToHome and GetDistance(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z) > EZLoot.home_Dist then
                NavToXYZ(EZLoot.home_X, EZLoot.home_Y, EZLoot.home_Z)
                mq.delay(500)
            end
            if mq.TLO.Macro() ~= nil and mq.TLO.Macro.Paused() ~= 'FALSE' then mq.cmd('/mqpause off') end
            if EZLoot.announce and EZLoot.doLootMessages then mq.cmdf('/%s [%s]Done Looting; no more corpses within range!', EZLoot.LootUtils.AnnounceChannel, mq.TLO.Time()) end
        end
        if EZLoot.doSell then
            EZLoot.LootUtils.sellStuff()
            EZLoot.doSell = false
        end
        if EZLoot.LootUtils.bankDeposit and mq.TLO.Me.FreeInventory() <= EZLoot.LootUtils.bankAtFreeSlots then
            EZLoot.needToBank = true
        end
        if EZLoot.needToBank then
            EZLoot.BankDropOff()
        end
        if EZLoot.needToVendorSell then
            EZLoot.VendorSell()
        end
    end
    mq.delay(250)
end

mq.unbind('/' .. EZLoot.command_ShortName)
mq.unbind('/' .. EZLoot.command_LongName)

return EZLoot
