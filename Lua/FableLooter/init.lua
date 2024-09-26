local mq = require('mq')

FableLooter = { _version = '1.0.13', _author = 'TheDroidUrLookingFor' }
FableLooter.LootUtils = require('FableLooter.lib.LootUtils')
FableLooter.Messages = require('FableLooter.lib.Messages')
FableLooter.GUI = require('FableLooter.lib.Gui')
FableLooter.Storage = require('FableLooter.lib.Storage')
FableLooter.script_ShortName = 'FableLooter'
FableLooter.command_ShortName = 'flb'
FableLooter.command_LongName = 'fableloot'
FableLooter.Terminate = false
FableLooter.needToBank = false
FableLooter.needToCashSell = false
FableLooter.needToVendorSell = false
FableLooter.needToFabledSell = false
FableLooter.mob_Wait = 50000
FableLooter.settingsFile = mq.configDir .. '\\FableLooter.' .. mq.TLO.EverQuest.Server() .. '_' .. mq.TLO.Me.CleanName() .. '.ini'
FableLooter.huntZoneID = mq.TLO.Zone.ID()
FableLooter.huntZoneName = mq.TLO.Zone.ShortName()
FableLooter.camp_X = mq.TLO.Me.X()
FableLooter.camp_Y = mq.TLO.Me.Y()
FableLooter.camp_Z = mq.TLO.Me.Z()

FableLooter.Settings = {
    version = FableLooter._version,
    debug = false,
    pauseMacro = false,
    bankDeposit = true,
    sellVendor = false,
    sellFabled = true,
    sellCash = true,
    bankAtFreeSlots = 5,
    bankZone = 451,
    bankNPC = 'Griphook',
    cashNPC = 'Silent Bob',
    vendorNPC = 'Kirito',
    fabledNPC = 'The Fabled Jim Carrey',
    SellFabledFor = 'Cash', -- Doublons, Papers, Cash
    SellFabledFor_idx = 3,
    corpseCleanup = true,
    corpseCleanupCommand = '/say #deletecorpse',
    corpseLimit = 500,
    scan_Radius = 10000,
    scan_zRadius = 250,
    returnToCampDistance = 200,
    camp_Check = false,
    zone_Check = true,
    lootGroundSpawns = true,
    returnHomeAfterLoot = true,
    doStand = true,
    lootAll = false,
    useExpPotions = false,
    potionName = 'Potion of Adventure II',
    potionBuff = 'Potion of Adventure II',
    staticHunt = false,
    staticZoneID = '173',
    staticZoneName = 'maiden',
    staticX = '1905',
    staticY = '940',
    staticZ = '-151.74',
    targetName = 'treasure',
    spawnSearch = '%s radius %d zradius %d',
}

function FableLooter.SaveSettings(iniFile, settingsList)
    FableLooter.Messages.Debug('function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function FableLooter.Setup()
    FableLooter.Messages.Debug('function Setup() Entry')
    local conf
    local configData, err = loadfile(FableLooter.settingsFile)
    if err then
        FableLooter.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
    elseif configData then
        conf = configData()
        if conf.version ~= FableLooter.Settings.version then
            FableLooter.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
            FableLooter.Setup()
        else
            FableLooter.Settings = conf
        end
    end
end

FableLooter.Setup()

function FableLooter.CheckZone()
    FableLooter.HandleDisconnect()
    if mq.TLO.Zone.ID() ~= FableLooter.huntZoneID and mq.TLO.DynamicZone() ~= nil then
        if not FableLooter.needToBank and not FableLooter.needToCashSell and not FableLooter.needToFabledSell then
            mq.delay(1000)
            mq.cmd('/say #enter')
            mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.huntZoneID end)
            mq.delay(1000)
        end
    end
end

function FableLooter.CheckDistanceToXYZ()
    local deltaX = FableLooter.camp_X - mq.TLO.Me.X()
    local deltaY = FableLooter.camp_Y - mq.TLO.Me.Y()
    local deltaZ = FableLooter.camp_Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function FableLooter.MoveToCamp()
    FableLooter.HandleDisconnect()
    if mq.TLO.Zone.ID() == FableLooter.huntZoneID then
        if FableLooter.CheckDistanceToXYZ() > FableLooter.Settings.returnToCampDistance then
            mq.cmdf('/squelch /warp loc %s %s %s', FableLooter.camp_Y, FableLooter.camp_X, FableLooter.camp_Z)
            mq.delay(50)
        end
    end
end

function FableLooter.GroundSpawns()
    FableLooter.HandleDisconnect()
    if mq.TLO.GroundItemCount('Generic')() > 0 and FableLooter.Settings.lootGroundSpawns then
        if FableLooter.Settings.pauseMacro then
            if mq.TLO.Macro() then
                mq.cmd('/mqpause on')
                mq.delay(50)
            end
        end
        mq.cmdf('/squelch /warp loc %s %s %s', mq.TLO.ItemTarget.Y(), mq.TLO.ItemTarget.X(), mq.TLO.ItemTarget.Z())
        mq.delay(250)
        mq.cmd('/click left item')
        mq.delay(500)
        if mq.TLO.Cursor() then
            FableLooter.GUI.addToConsole('Picked Up: %s', mq.TLO.Cursor.Name())
            FableLooter.LootUtils.report('Picked Up: %s', mq.TLO.Cursor.ItemLink('CLICKABLE')())
            mq.cmd('/autoinv')
            mq.delay(5000, function() return mq.TLO.Cursor() == nil end)
        end
        if FableLooter.Settings.returnHomeAfterLoot then
            mq.cmdf('/squelch /warp loc %s %s %s', FableLooter.camp_Y, FableLooter.camp_X, FableLooter.camp_Z)
            mq.delay(50)
        end
        if FableLooter.Settings.pauseMacro then
            if mq.TLO.Macro() then
                mq.cmd('/mqpause off')
                mq.delay(50)
            end
        end
    end
end

function FableLooter.BankDropOff()
    FableLooter.HandleDisconnect()
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
            mq.delay(5000, function() return mq.TLO.Window('BigBankWnd').Open() end)
            mq.delay(50)
            FableLooter.LootUtils.bankStuff()
            mq.delay(500)
            if FableLooter.Settings.sellFabled then
                FableLooter.needToFabledSell = true
                FableLooter.FabledSell()
                mq.delay(500)
            end
            if FableLooter.Settings.sellCash then
                FableLooter.needToCashSell = true
                FableLooter.CashSell()
                mq.delay(500)
            end
            if FableLooter.Settings.sellVendor then
                FableLooter.needToVendorSell = true
                FableLooter.VendorSell()
                mq.delay(500)
            end
            FableLooter.needToBank = false
        end
    end
end

function FableLooter.VendorSell()
    FableLooter.HandleDisconnect()
    if FableLooter.needToVendorSell then
        if mq.TLO.Zone.ID() ~= FableLooter.Settings.bankZone then
            mq.cmdf('/say #zone %s', FableLooter.Settings.bankZone)
            mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.Settings.bankZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == FableLooter.Settings.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', FableLooter.Settings.vendorNPC)
            mq.delay(250)
            mq.delay(5000, function() return mq.TLO.Target()() ~= nil end)
            mq.cmd('/squelch /warp t')
            mq.delay(1000)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function() return mq.TLO.Window('MerchantWnd').Open() end)
            FableLooter.LootUtils.sellStuff()
            FableLooter.needToVendorSell = false
        end
    end
end

function FableLooter.CashSell()
    FableLooter.HandleDisconnect()
    if FableLooter.needToCashSell then
        if mq.TLO.Zone.ID() ~= FableLooter.Settings.bankZone then
            mq.cmdf('/say #zone %s', FableLooter.Settings.bankZone)
            mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.Settings.bankZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == FableLooter.Settings.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', FableLooter.Settings.cashNPC)
            mq.delay(250)
            mq.delay(5000, function() return mq.TLO.Target()() ~= nil end)
            mq.cmd('/squelch /warp t')
            mq.delay(500)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function() return mq.TLO.Window('NewPointMerchantWnd').Open() end)
            FableLooter.LootUtils.sellCashItems(true)
            FableLooter.needToCashSell = false
        end
    end
end

function FableLooter.FabledSell()
    FableLooter.HandleDisconnect()
    if FableLooter.needToFabledSell then
        if mq.TLO.Zone.ID() ~= FableLooter.Settings.bankZone then
            mq.cmdf('/say #zone %s', FableLooter.Settings.bankZone)
            mq.delay(50000, function() return mq.TLO.Zone.ID()() == FableLooter.Settings.bankZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == FableLooter.Settings.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', FableLooter.Settings.fabledNPC)
            mq.delay(250)
            mq.delay(5000, function() return mq.TLO.Target()() ~= nil end)
            mq.cmd('/squelch /warp t')
            mq.delay(1000)
            mq.cmd('/say I understand')
            mq.delay(1000)
            mq.doevents('SellFabledItems')
            mq.delay(1000)
            FableLooter.needToFabledSell = false
        end
    end
end

local function event_fabledSell_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, FableLooter.Settings.SellFabledFor) then
            mq.ExecuteTextLink(link)
        end
    end
end
mq.event('SellFabledItems',
    "#*#The Fabled Jim Carrey whispers, 'Which currency would you like to receive for your rank 1 fabled items? #1#?'",
    event_fabledSell_handler, { keepLinks = true })

local function binds(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            FableLooter.GUI.Open = not FableLooter.GUI.Open
        elseif args[1] == 'bank' then
            FableLooter.needToBank = true
            FableLooter.BankDropOff()
        elseif args[1] == 'vendor' then
            FableLooter.needToVendorSell = true
        elseif args[1] == 'cash' then
            FableLooter.needToCashSell = true
            FableLooter.CashSell()
        elseif args[1] == 'fabled' then
            FableLooter.needToFabledSell = true
            FableLooter.FabledSell()
        elseif args[1] == 'quit' then
            FableLooter.terminate = true
            mq.cmdf('/lua stop %s', FableLooter.script_ShortName)
        else
            FableLooter.Messages.Normal('Valid Commands:')
            FableLooter.Messages.Normal('/%s \aggui\aw - Toggles the Control Panel GUI',
                FableLooter.command_ShortName)
            FableLooter.Messages.Normal('/%s \agbank\aw - Send your character to bank items',
                FableLooter.command_ShortName)
            FableLooter.Messages.Normal('/%s \agfabled\aw - Send your character to sell fabled items',
                FableLooter.command_ShortName)
            FableLooter.Messages.Normal('/%s \agcash\aw - Send your character to sell cash items',
                FableLooter.command_ShortName)
            FableLooter.Messages.Normal('/%s \agquit\aw - Quits the lua script.',
                FableLooter.command_ShortName)
        end
    else
        FableLooter.Messages.Normal('Valid Commands:')
        FableLooter.Messages.Normal('/%s \aggui\aw - Toggles the Control Panel GUI',
            FableLooter.command_ShortName)
        FableLooter.Messages.Normal('/%s \agbank\aw - Send your character to bank items',
            FableLooter.command_ShortName)
        FableLooter.Messages.Normal('/%s \agfabled\aw - Send your character to sell fabled items',
            FableLooter.command_ShortName)
        FableLooter.Messages.Normal('/%s \agcash\aw - Send your character to sell cash items',
            FableLooter.command_ShortName)
        FableLooter.Messages.Normal('/%s \agquit\aw - Quits the lua script.', FableLooter
            .command_ShortName)
    end
end

FableLooter.GUI.initGUI()

local function setupBinds()
    mq.bind('/' .. FableLooter.command_ShortName, binds)
    mq.bind('/' .. FableLooter.command_LongName, binds)
end

function FableLooter.CorpseCleanup()
    FableLooter.HandleDisconnect()
    if mq.TLO.SpawnCount(FableLooter.Settings.spawnSearch:format('corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))() > 0 then return end
    if mq.TLO.SpawnCount('npccorpse')() > FableLooter.Settings.corpseLimit then
        mq.cmdf('%s', FableLooter.Settings.corpseCleanupCommand)
        mq.delay(250)
    end
end

function FableLooter.UseExpPotion()
    FableLooter.HandleDisconnect()
    if FableLooter.Settings.useExpPotions then
        if mq.TLO.FindItem('Bemvaras\'s Holy Greaves')() and mq.TLO.Me.ItemReady('Bemvaras\'s Holy Greaves')() then
            if not mq.TLO.Me.Buff('Bemvaras\' s Enhanced Learning').ID() then
                mq.cmdf('/useitem "%s"', 'Bemvaras\'s Holy Greaves')
                mq.delay(50)
            end
        else
            if mq.TLO.FindItemCount(FableLooter.Settings.potionName)() and not mq.TLO.Me.Buff(FableLooter.Settings.potionBuff).ID() and not mq.TLO.Me.Buff('Bemvaras\' s Enhanced Learning').ID() then
                mq.cmdf('/useitem "%s"', FableLooter.Settings.potionName)
                mq.delay(50)
            end
        end
    end
end

function FableLooter.HandleDisconnect()
    -- PRECHARSELECT
    --${Window[serverselect].Child[SERVERSELECT_PlayLastServerButton]}
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
    end
end

function FableLooter.CheckCampInfo()
    if FableLooter.Settings.staticHunt then
        FableLooter.huntZoneName = FableLooter.Settings.staticZoneName
        FableLooter.huntZoneID = tonumber(FableLooter.Settings.staticZoneID)
        FableLooter.camp_X = tonumber(FableLooter.Settings.staticX)
        FableLooter.camp_Y = tonumber(FableLooter.Settings.staticY)
        FableLooter.camp_Z = tonumber(FableLooter.Settings.staticZ)
    end
end

function FableLooter.Main()
    setupBinds()
    mq.cmd('/hidecorpse looted')
    FableLooter.Messages.Normal('++ Initialized ++')
    FableLooter.Messages.Normal('Main Loop Entry')
    FableLooter.CheckCampInfo()
    while not FableLooter.Terminate do
        FableLooter.HandleDisconnect()
        if not mq.TLO.Me.Standing() or mq.TLO.Me.Ducking() then mq.TLO.Me.Stand() end
        if mq.TLO.Me.ItemReady('Bemvaras\' Coin Sack')() then
            if mq.TLO.Me.BardSongPlaying() then
                if mq.TLO.Plugin('MQ2Medley').IsLoaded() then
                    mq.cmdf('/medley %s', 'stop')
                    mq.delay(50)
                elseif mq.TLO.Plugin('MQ2Twist').IsLoaded() then
                    mq.cmdf('/twist %s', 'stop')
                    mq.delay(50)
                end
                mq.cmd('/stopcast')
                mq.delay(50)
                mq.cmdf('/useitem %s', 'Bemvaras\' Coin Sack')
            else
                mq.cmdf('/useitem %s', 'Bemvaras\' Coin Sack')
            end
        end
        if FableLooter.Settings.useExpPotions then FableLooter.UseExpPotion() end
        if FableLooter.Settings.bankDeposit and mq.TLO.Me.FreeInventory() <= FableLooter.Settings.bankAtFreeSlots then
            FableLooter.needToBank = true
        end
        if FableLooter.needToBank then
            FableLooter.BankDropOff()
        end
        if FableLooter.needToCashSell then
            FableLooter.CashSell()
        end
        if FableLooter.needToFabledSell then
            FableLooter.FabledSell()
        end
        if FableLooter.needToVendorSell then
            FableLooter.VendorSell()
        end
        if FableLooter.Settings.zone_Check then FableLooter.CheckZone() end
        if FableLooter.Settings.camp_Check then FableLooter.MoveToCamp() end
        if FableLooter.doStand and not mq.TLO.Me.Standing() then
            mq.cmd('/stand')
            mq.delay(50)
        end
        if FableLooter.Settings.corpseCleanup then FableLooter.CorpseCleanup() end
        if mq.TLO.SpawnCount(FableLooter.Settings.spawnSearch:format('corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))() > 0 or (FableLooter.Settings.lootAll and mq.TLO.SpawnCount(FableLooter.Settings.spawnSearch:format('corpse', FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))() > 0) then
            if FableLooter.Settings.pauseMacro then
                if mq.TLO.Macro() then
                    mq.cmd('/mqpause on')
                    mq.delay(50)
                end
            end
            if FableLooter.Settings.lootAll then
                mq.cmdf('/target %s',
                    mq.TLO.NearestSpawn(FableLooter.Settings.spawnSearch:format('corpse',
                        FableLooter.Settings.scan_Radius, FableLooter.Settings.scan_zRadius))())
            else
                mq.cmdf('/target %s',
                    mq.TLO.NearestSpawn(FableLooter.Settings.spawnSearch:format(
                        'corpse ' .. FableLooter.Settings.targetName, FableLooter.Settings.scan_Radius,
                        FableLooter.Settings.scan_zRadius))())
            end
            if mq.TLO.Target() and mq.TLO.Target.Type() == 'Corpse' then
                mq.cmd('/squelch /warp t')
                mq.delay(100)
                if FableLooter.doStand and not mq.TLO.Me.Standing() then
                    mq.cmd('/stand')
                    mq.delay(50)
                end
                FableLooter.LootUtils.lootCorpse(mq.TLO.Target.ID())
                mq.delay(100)
                mq.doevents()
                mq.delay(100)
                if FableLooter.Settings.returnHomeAfterLoot then
                    mq.cmdf('/squelch /warp loc %s %s %s', FableLooter.camp_Y, FableLooter.camp_X, FableLooter.camp_Z)
                    mq.delay(50)
                end
            end
            if FableLooter.Settings.pauseMacro then
                if mq.TLO.Macro() then
                    mq.cmd('/mqpause off')
                    mq.delay(50)
                end
            end
        end
        FableLooter.GroundSpawns()
        mq.delay(100)
    end
    FableLooter.Messages.Normal('Main Loop Exit')
end

FableLooter.Main()

mq.unbind('/fableloot')

return FableLooter
