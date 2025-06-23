local mq = require 'mq'

DroidLoot = {
    debug = true,
    announce = true,
    say = 'rsay',
    returnToHome = false,
    home_Dist = 10,
    home_X = mq.TLO.Me.X(),
    home_Y = mq.TLO.Me.Y(),
    home_Z = mq.TLO.Me.Z(),
    command_ShortName = 'dl',
    command_LongName = 'droidloot',
    terminate = false,
    spawnSearch = '%s radius %d zradius 50',
    doSell = false,
    doSellAll = false,
    closeSellWindow = false,
    doLoot = true,
    doLootMessages = false,
    doPause = false,
    doCorpseFix = false,
}
DroidLoot.needToBank = false
DroidLoot.needToVendorSell = false
DroidLoot.huntZoneID = mq.TLO.Zone.ID()
DroidLoot.huntZoneName = mq.TLO.Zone.ShortName()
DroidLoot.camp_X = mq.TLO.Me.X()
DroidLoot.camp_Y = mq.TLO.Me.Y()
DroidLoot.camp_Z = mq.TLO.Me.Z()

DroidLoot.Messages = require('DroidLoot.lib.Messages')
DroidLoot.LootUtils = require('DroidLoot.lib.LootUtils')
DroidLoot.GUI = require('DroidLoot.lib.Gui')
DroidLoot.Storage = require('DroidLoot.lib.Storage')
if not DroidLoot.Storage.dir_exists(mq.configDir .. '\\DroidLoot') then DroidLoot.Storage.make_dir(mq.configDir .. '\\DroidLoot') end

local function GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function DroidLoot.HandleDisconnect()
    if DroidLoot.NewDisconnectHandler then
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' and not mq.TLO.AutoLogin.Active() then
            mq.TLO.AutoLogin.Profile.ReRun()
            mq.delay(50)
            mq.delay(25000, function() return mq.TLO.EverQuest.GameState() == 'INGAME' end)
            mq.delay(50)
            mq.cmd('/hidecorpse looted')
        end
    else
        if mq.TLO.EverQuest.GameState() == 'PRECHARSELECT' then
            mq.cmd("/notify serverselect SERVERSELECT_PlayLastServerButton leftmouseup")
            mq.delay(50)
            mq.delay(25000, function() return mq.TLO.EverQuest.GameState() == 'CHARSELECT' end)
            mq.delay(50)
        end
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
            mq.cmd("/notify CharacterListWnd CLW_Play_Button leftmouseup")
            mq.delay(50)
            mq.delay(25000, function() return mq.TLO.EverQuest.GameState() == 'INGAME' end)
            mq.delay(50)
            mq.cmd('/hidecorpse looted')
        end
    end
end

function DroidLoot.CheckDistanceToXYZ(checkX, checkY, checkZ)
    local deltaX = checkX - mq.TLO.Me.X()
    local deltaY = checkY - mq.TLO.Me.Y()
    local deltaZ = checkZ - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function DroidLoot.MoveToCamp()
    DroidLoot.HandleDisconnect()
    if mq.TLO.Zone.ID() == DroidLoot.huntZoneID then
        if DroidLoot.CheckDistanceToXYZ(DroidLoot.camp_X, DroidLoot.camp_Y, DroidLoot.camp_Z) > DroidLoot.LootUtils.returnToCampDistance then
            DroidLoot.LootUtils.navToXYZ(DroidLoot.camp_X, DroidLoot.camp_Y, DroidLoot.camp_Z)
            mq.delay(50)
        end
    end
end

function DroidLoot.BankDropOff()
    DroidLoot.HandleDisconnect()
    if mq.TLO.Me.FreeInventory() <= DroidLoot.LootUtils.bankAtFreeSlots or DroidLoot.needToBank then
        if mq.TLO.Zone.ID() ~= DroidLoot.LootUtils.bankZone then
            mq.cmdf('/say #zone %s', DroidLoot.LootUtils.bankZone)
            mq.delay(50000, function() return mq.TLO.Zone.ID() == DroidLoot.LootUtils.bankZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == DroidLoot.LootUtils.bankZone then
            mq.cmdf('/target npc %s', DroidLoot.LootUtils.bankNPC)
            mq.delay(250)
            mq.delay(5000, function() return mq.TLO.Target() ~= nil end)
            DroidLoot.LootUtils.navToID(mq.TLO.Target.ID())
            mq.delay(250)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function() return mq.TLO.Window('BigBankWnd').Open() end)
            mq.delay(50)
            DroidLoot.LootUtils.bankStuff()
            mq.delay(500)
            if DroidLoot.LootUtils.sellVendor then
                DroidLoot.needToVendorSell = true
                DroidLoot.VendorSell()
                mq.delay(500)
            end
            DroidLoot.needToBank = false
        end
    end
end

function DroidLoot.VendorSell()
    DroidLoot.HandleDisconnect()
    if DroidLoot.needToVendorSell then
        if mq.TLO.Zone.ID() ~= DroidLoot.LootUtils.bankZone then
            mq.cmdf('/say #zone %s', DroidLoot.LootUtils.bankZone)
            mq.delay(50000, function() return mq.TLO.Zone.ID() == DroidLoot.LootUtils.bankZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == DroidLoot.LootUtils.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', DroidLoot.LootUtils.vendorNPC)
            mq.delay(250)
            mq.delay(5000, function() return mq.TLO.Target() ~= nil end)
            DroidLoot.LootUtils.navToID(mq.TLO.Target.ID())
            mq.delay(250)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function() return mq.TLO.Window('MerchantWnd').Open() end)
            DroidLoot.LootUtils.sellStuff(DroidLoot.closeSellWindow, false)
            DroidLoot.needToVendorSell = false
        end
    end
end

local function binds(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            DroidLoot.GUI.Open = not DroidLoot.GUI.Open
        elseif args[1] == 'bank' then
            DroidLoot.needToBank = true
            DroidLoot.BankDropOff()
        elseif args[1] == 'vendor' then
            DroidLoot.needToVendorSell = true
        elseif args[1] == 'sellall' then
            DroidLoot.doSellAll = not DroidLoot.doSellAll
        elseif args[1] == 'sell' then
            DroidLoot.doSell = not DroidLoot.doSell
        elseif args[1] == 'loot' then
            DroidLoot.doLoot = not DroidLoot.doLoot
        elseif args[1] == 'radius' then
            if args[2] ~= nil then
                DroidLoot.LootUtils.CorpseRadius = args[2]
            else
                DroidLoot.Messages.CONSOLEMETHOD('Please specify a radius value: /%s radius 100', DroidLoot.command_ShortName)
            end
        elseif args[1] == 'quit' then
            mq.unbind('/' .. DroidLoot.command_ShortName)
            mq.unbind('/' .. DroidLoot.command_LongName)
            mq.unbind('/DroidLootUtils')
            mq.cmdf('/lua stop %s', 'DroidLoot')
            DroidLoot.terminate = true
        else
            DroidLoot.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', DroidLoot.command_ShortName)
            DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', DroidLoot.command_ShortName)
            DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agsellall\aw - Turns selling mode on selling ignored items as well', DroidLoot.command_ShortName)
            DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', DroidLoot.command_ShortName)
            DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', DroidLoot.command_ShortName)
        end
    else
        DroidLoot.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \aggui\aw - Toggles the Control Panel GUI', DroidLoot.command_ShortName)
        DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agsell\aw - Turns selling mode on', DroidLoot.command_ShortName)
        DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agsellall\aw - Turns selling mode on selling ignored items as well', DroidLoot.command_ShortName)
        DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agloot\aw - Toggles looting mobs on/off', DroidLoot.command_ShortName)
        DroidLoot.Messages.CONSOLEMETHOD(false, '/%s \agquit\aw - Quits the lua script.', DroidLoot.command_ShortName)
    end
end
mq.bind('/' .. DroidLoot.command_ShortName, binds)
mq.bind('/' .. DroidLoot.command_LongName, binds)

DroidLoot.GUI.initGUI()

local cast_Mode = 'casting'
function DroidLoot.CheckHP()
    function DoneCasting()
        return not mq.TLO.Me.Casting()
    end

    if DroidLoot.LootUtils.health_Check then
        if mq.TLO.Me.PctHPs() <= DroidLoot.LootUtils.heal_At then
            DroidLoot.Messages.Normal('Casting \ag %s \ax on \ag %s\ax', DroidLoot.LootUtils.heal_Spell, mq.TLO.Me())
            mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(DroidLoot.LootUtils.heal_Spell).RankName() .. '" ' .. DroidLoot.LootUtils.heal_Gem)
            while mq.TLO.Me.Casting() do
                mq.delay(1000, DoneCasting)
            end
        end
    end
end

function DroidLoot.CheckCampInfo()
    if DroidLoot.LootUtils.staticHunt then
        DroidLoot.huntZoneName = DroidLoot.LootUtils.staticZoneName
        DroidLoot.huntZoneID = tonumber(DroidLoot.LootUtils.staticZoneID)
        DroidLoot.camp_X = tonumber(DroidLoot.LootUtils.staticX)
        DroidLoot.camp_Y = tonumber(DroidLoot.LootUtils.staticY)
        DroidLoot.camp_Z = tonumber(DroidLoot.LootUtils.staticZ)
    end
end

mq.cmd('/hidecorpse looted')
DroidLoot.CheckCampInfo()

DroidLoot.Messages.CONSOLEMETHOD(false, '++ \agDROID LOOT BOT STARTED\aw ++')
if DroidLoot.returnToHome then
    DroidLoot.home_X = mq.TLO.Me.X()
    DroidLoot.home_Y = mq.TLO.Me.Y()
    DroidLoot.home_Z = mq.TLO.Me.Z()
    DroidLoot.Messages.CONSOLEMETHOD(false, '++ Home X: \ag%s\aw Y: \ag%s\aw Z: \ag%s\aw ++', DroidLoot.home_X, DroidLoot.home_Y, DroidLoot.home_Z)
end
while not DroidLoot.terminate do
    if not DroidLoot.doPause then
        if not mq.TLO.Me.Standing() or mq.TLO.Me.Ducking() then
            mq.TLO.Me.Stand()
        end
        if DroidLoot.LootUtils.camp_Check then
            DroidLoot.MoveToCamp()
        end
        local deadCount = mq.TLO.SpawnCount(DroidLoot.spawnSearch:format('npccorpse', DroidLoot.LootUtils.CorpseRadius))()
        if DroidLoot.doLoot and deadCount ~= 0 then
            if DroidLoot.announce and DroidLoot.doLootMessages then mq.cmdf('/%s [%s]Started Looting!', DroidLoot.LootUtils.AnnounceChannel, mq.TLO.Time()) end
            if DroidLoot.doCorpseFix then mq.cmd('/say #corpsefix') end
            if mq.TLO.Macro() ~= nil and mq.TLO.Macro.Paused() ~= 'TRUE' then
                mq.cmd('/mqpause on')
                mq.delay(500)
            end
            DroidLoot.LootUtils.lootMobs()
            if DroidLoot.LootUtils.returnHomeAfterLoot or (DroidLoot.returnToHome and GetDistance(DroidLoot.home_X, DroidLoot.home_Y, DroidLoot.home_Z) > DroidLoot.home_Dist) then
                DroidLoot.MoveToCamp()
                mq.delay(500)
            end
            if DroidLoot.LootUtils.health_Check then
                DroidLoot.CheckHP()
            end
            if mq.TLO.Macro() ~= nil and mq.TLO.Macro.Paused() ~= 'FALSE' then mq.cmd('/mqpause off') end
            if DroidLoot.announce and DroidLoot.doLootMessages then mq.cmdf('/%s [%s]Done Looting; no more corpses within range!', DroidLoot.LootUtils.AnnounceChannel, mq.TLO.Time()) end
        end
        if DroidLoot.doSell then
            DroidLoot.LootUtils.sellStuff(DroidLoot.closeSellWindow, true)
            DroidLoot.doSell = false
        end
        if DroidLoot.doSellAll then
            DroidLoot.LootUtils.sellStuff(DroidLoot.closeSellWindow, false)
            DroidLoot.doSellAll = false
        end
        if DroidLoot.LootUtils.bankDeposit and mq.TLO.Me.FreeInventory() <= DroidLoot.LootUtils.bankAtFreeSlots then
            DroidLoot.needToBank = true
        end
        if DroidLoot.needToBank then
            DroidLoot.BankDropOff()
        end
        if DroidLoot.needToVendorSell then
            DroidLoot.VendorSell()
        end
    end
    mq.delay(250)
end

mq.unbind('/' .. DroidLoot.command_ShortName)
mq.unbind('/' .. DroidLoot.command_LongName)
mq.unbind('/DroidLootUtils')

return DroidLoot
