local mq = require('mq')
---@type ImGui
local ImGui = require 'ImGui'

CampFarmer = {
    _version = '1.0.1',
    _author = 'TheDroidUrLookingFor'
}
CampFarmer.script_ShortName = 'CampFarmer'
CampFarmer.command_ShortName = 'cf'
CampFarmer.command_LongName = 'CampFarmer'
CampFarmer.loop = true
CampFarmer.NewDisconnectHandler = true
CampFarmer.needToBank = false
CampFarmer.needToCashSell = false
CampFarmer.needToVendorSell = false
CampFarmer.needToFabledSell = false
CampFarmer.startX = mq.TLO.Me.X()
CampFarmer.startY = mq.TLO.Me.Y()
CampFarmer.startZ = mq.TLO.Me.Z()
CampFarmer.startZone = mq.TLO.Zone.ID()
CampFarmer.startZoneName = mq.TLO.Zone.ShortName()
CampFarmer.settingsFile = '\\CampFarmer.' .. mq.TLO.EverQuest.Server() .. '_' .. mq.TLO.Me.CleanName() .. '.ini'
CampFarmer.AAReuseDelay = 500
CampFarmer.ItemReuseDelay = 500
CampFarmer.FastDelay = 50
CampFarmer.RepopDelay = 1500
CampFarmer.AggroDelay = 1500
CampFarmer.StartDoubloons = 0
CampFarmer.StartPapers = 0
CampFarmer.StartCash = 0
CampFarmer.StartAA = 0
CampFarmer.StartTime = os.time()
CampFarmer.LastReportTime = os.time()
CampFarmer.reset_Instance_At = 5
CampFarmer.zone_Wait = 50000
CampFarmer.rebirth_Wait = 2500
CampFarmer.wait_One = 250
CampFarmer.wait_Two = 500
CampFarmer.wait_Three = 750
CampFarmer.wait_Four = 1000

CampFarmer.Settings = {}
CampFarmer.Settings.Version = CampFarmer._version
CampFarmer.Settings.debug = false
CampFarmer.Settings.spawnSearch = 'npc radius 60 los targetable noalert 1'
CampFarmer.Settings.mobsSearch = 'npc targetable noalert 1'
CampFarmer.Settings.corpseSearch = 'npccorpse treasure goblin noalert 25'
CampFarmer.Settings.aggroItem = 'Charm of Hate'
CampFarmer.Settings.aggroUberItem = 'Derekthomx\'s Horrorkrunk Hook'
CampFarmer.Settings.respawnItem = 'Uber Charm of Refreshing'
CampFarmer.Settings.fabledCheck = 'Empowered'
CampFarmer.Settings.DoUberPull = true
CampFarmer.Settings.usePaladinAA = true
CampFarmer.Settings.useClericAA = true
CampFarmer.Settings.useBemChest = true
CampFarmer.Settings.useBemLegs = true
CampFarmer.Settings.useBemGloves = true
CampFarmer.Settings.useBuffCharm = true
CampFarmer.Settings.UseExpPotions = true
CampFarmer.Settings.KeepMaxLevel = true
CampFarmer.Settings.useCoinSack = true
CampFarmer.Settings.useErtzStone = true
CampFarmer.Settings.useCurrencyCharm = true
CampFarmer.Settings.DoLoot = true
CampFarmer.Settings.LootGroundSpawns = false
CampFarmer.Settings.ClickAATokens = true
CampFarmer.Settings.GroupAlt = false
CampFarmer.Settings.buffCharmName = 'Amulet of Ultimate Buffing'
CampFarmer.Settings.buffCharmBuffName = 'Talisman of the Panther Rk. III'
CampFarmer.Settings.AltLooterName = 'Binli'
CampFarmer.Settings.lootINIFile = '\\EZLoot\\EZLoot-MINLI.ini'
CampFarmer.Settings.MinMobsInZone = 10
CampFarmer.Settings.UberPullMobsInZone = 50

CampFarmer.Settings.ReturnToHomeDistance = 60
CampFarmer.Settings.returnHomeAfterLoot = false
CampFarmer.Settings.potionName = 'Potion of Adventure II'
CampFarmer.Settings.potionBuff = 'Potion of Adventure II'
CampFarmer.Settings.bankDeposit = true
CampFarmer.Settings.sellVendor = false
CampFarmer.Settings.sellFabled = true
CampFarmer.Settings.sellCash = true
CampFarmer.Settings.staticHunt = true
CampFarmer.Settings.bankAtFreeSlots = 5
CampFarmer.Settings.bankZone = 183
CampFarmer.Settings.bankNPC = 'Griphook'
CampFarmer.Settings.cashNPC = 'Silent Bob'
CampFarmer.Settings.vendorNPC = 'Kirito'
CampFarmer.Settings.fabledNPC = 'The Fabled Jim Carrey'
CampFarmer.Settings.SellFabledFor = 'Cash' -- Doublons, Papers, Cash
CampFarmer.Settings.SellFabledFor_idx = 3
CampFarmer.Settings.staticZoneID = '173'
CampFarmer.Settings.staticZoneName = 'maiden'
CampFarmer.Settings.staticX = '1426.87'
CampFarmer.Settings.staticY = '955.12'
CampFarmer.Settings.staticZ = '-152.25'
CampFarmer.Settings.targetName = 'treasure'
CampFarmer.Settings.spawnWildcardSearch = '%s radius %d zradius %d'
CampFarmer.Settings.scan_Radius = 10000
CampFarmer.Settings.scan_zRadius = 250
CampFarmer.Settings.corpseCleanup = true
CampFarmer.Settings.corpseCleanupCommand = '/hidecorpse all'
CampFarmer.Settings.corpseLimit = 200
CampFarmer.Settings.doStand = true
CampFarmer.Settings.lootAll = false
CampFarmer.Settings.ReportGain = false
CampFarmer.Settings.ReportAATime = 300
CampFarmer.Settings.RangerStickRange = 140

CampFarmer.IgnoreList = {
    "Gillamina Garstobidokis",
    "an ornate chest",
    "${Me.CleanName}'s Pet",
    "${Me.CleanName}",
    "Cruel Illusion",
    "lockout ikkinz",
    "Kilidna",
    "Pixtt Grand Summoner",
    "Kevren Nalavat",
    "Kenra Kalekkio",
    "Pixtt Nemis",
    "Undari Perunea",
    "Sentinel of the Altar",
    "Retharg",
    "Siska the Spumed",
    "a shark",
    "The ground"
}

CampFarmer.PriorityList = {
    "Cash Treasure Goblin",
    "Platinum Treasure Goblin",
    "Augment Treasure Goblin",
    "Paper Treasure Goblin",
    "Raging Treasure Goblin",
    "Treasure Goblin"
}

CampFarmer.ClassAAs = {
    Bard = 39908,
    Beastlord = 39915,
    Berserker = 39916,
    Cleric = 39902,
    Druid = 39906,
    Enchanter = 39914,
    Magician = 39913,
    Monk = 39907,
    Necromancer = 39911,
    Paladin = 39903,
    Ranger = 39904,
    Rogue = 39909,
    Shadowknight = 39905,
    Shaman = 39910,
    Warrior = 39901,
    Wizard = 39912
}

CampFarmer.Messages = require('CampFarmer.lib.Messages')

function CampFarmer.SaveSettings(iniFile, settingsList)
    CampFarmer.Messages.Debug('function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function CampFarmer.Setup()
    CampFarmer.Messages.Debug('function Setup() Entry')
    local conf
    local configData, err = loadfile(CampFarmer.settingsFile)
    if err then
        CampFarmer.SaveSettings(mq.configDir .. CampFarmer.settingsFile, CampFarmer.Settings)
    elseif configData then
        conf = configData()
        if conf.Version ~= CampFarmer.Settings.Version then
            CampFarmer.SaveSettings(mq.configDir .. CampFarmer.settingsFile, CampFarmer.Settings)
            CampFarmer.Setup()
        else
            CampFarmer.Settings = conf
        end
    end
end

CampFarmer.LootUtils = require('CampFarmer.lib.LootUtils')
CampFarmer.GUI = require('CampFarmer.lib.Gui')
CampFarmer.Storage = require('CampFarmer.lib.Storage')

function CampFarmer.SetupAlertLists()
    mq.cmd('/squelch /alert clear 1')
    for _, name in ipairs(CampFarmer.IgnoreList) do
        mq.cmdf('/squelch /alert add 1 "%s"', name)
        mq.delay(25)
    end
    mq.cmd('/squelch /alert clear 2')
    for _, name in ipairs(CampFarmer.PriorityList) do
        mq.cmdf('/squelch /alert add 2 "%s"', name)
        mq.delay(25)
    end
    mq.cmd('/squelch /alert clear 25')
end

function CampFarmer.CheckCampInfo()
    if CampFarmer.Settings.staticHunt then
        CampFarmer.startZoneName = CampFarmer.Settings.staticZoneName
        CampFarmer.startZone = tonumber(CampFarmer.Settings.staticZoneID)
        CampFarmer.startX = tonumber(CampFarmer.Settings.staticX)
        CampFarmer.startY = tonumber(CampFarmer.Settings.staticY)
        CampFarmer.startZ = tonumber(CampFarmer.Settings.staticZ)
    end
end

function CampFarmer.CheckXTargAggro()
    local y = 0
    for x = 1, 13 do
        local xTarget = mq.TLO.Me.XTarget(x)
        local spawnID = xTarget.ID()
        local spawnTOT = mq.TLO.Spawn(spawnID).TargetOfTarget()
        local spawnType = mq.TLO.Spawn(spawnID).Type()
        if spawnID > 0 then
            if spawnTOT == mq.TLO.Me.ID() and spawnType ~= 'Untargetable' and spawnType == 'NPC' then
                y = y + 1
            end
        end
    end
    return y
end

function CampFarmer.HandleDisconnect()
    if CampFarmer.NewDisconnectHandler then
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' and not mq.TLO.AutoLogin.Active() then
            mq.TLO.AutoLogin.Profile.ReRun()
            mq.delay(50)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(50)
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
        end
    end
end

function CampFarmer.CheckCorpseCount()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if CampFarmer.Settings.DoLoot and mq.TLO.SpawnCount(CampFarmer.Settings.spawnWildcardSearch:format('corpse ' .. CampFarmer.Settings.targetName, CampFarmer.Settings.scan_Radius, CampFarmer.Settings.scan_zRadius))() > 0 then
        return
    end
    if mq.TLO.SpawnCount('npccorpse')() > CampFarmer.Settings.corpseLimit then
        mq.cmdf('%s', CampFarmer.Settings.corpseCleanupCommand)
        mq.delay(50)
        mq.cmd('/hidecorpse looted')
        mq.delay(250)
    end
end

function CampFarmer.KillThis()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if mq.TLO.Me.Class() ~= 'Ranger' then
        mq.cmd('/squelch /stick moveback 10')
        mq.cmd('/squelch /attack on')
    else
        if not mq.TLO.Me.AutoFire() then
            if mq.TLO.Target() and mq.TLO.Target.MaxRangeTo() > mq.TLO.Me.MaxRange() and mq.TLO.Target.LineOfSight() then
                mq.cmdf('/squelch /stick moveback %s', CampFarmer.Settings.RangerStickRange)
            end
            mq.cmd('/squelch /autofire')
        end
    end
    mq.cmd('/squelch /face fast')
    if mq.TLO.Pet() and not mq.TLO.Pet.Combat() then
        mq.cmd('/squelch /pet attack')
    end
end

function CampFarmer.CheckDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function CampFarmer.CheckBuffs()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if CampFarmer.Settings.useCoinSack and mq.TLO.Me.ItemReady('Bemvaras\' Coin Sack')() then
        mq.cmdf('/useitem %s', 'Bemvaras\' Coin Sack')
        mq.delay(5000, function()
            return mq.TLO.Me.Casting.ID() == 0
        end)
        mq.delay(CampFarmer.ItemReuseDelay)
    end
    if CampFarmer.Settings.useCurrencyCharm and mq.TLO.FindItem('Soulriever\'s Charm of Currency')() and mq.TLO.Me.ItemReady('Soulriever\'s Charm of Currency')() and not mq.TLO.Me.Buff('Soulriever\'s Currency Doubler')() then
        mq.cmdf('/useitem %s', 'Soulriever\'s Charm of Currency')
        mq.delay(CampFarmer.ItemReuseDelay)
    end
    if CampFarmer.Settings.usePaladinAA and (mq.TLO.Me.Diseased() or mq.TLO.Me.Cursed()) and mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Paladin'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Paladin'])
        mq.delay(CampFarmer.ItemReuseDelay)
    end
    if CampFarmer.Settings.useBemChest and (mq.TLO.Me.Diseased() or mq.TLO.Me.Cursed()) and mq.TLO.FindItem('Bemvaras\'s Golden Breastplate Rk. I')() and mq.TLO.Me.ItemReady('Bemvaras\'s Golden Breastplate Rk. I')() then
        mq.cmdf('/useitem %s', 'Bemvaras\'s Golden Breastplate Rk. I')
        mq.delay(CampFarmer.ItemReuseDelay)
    end
    if CampFarmer.Settings.useClericAA and not mq.TLO.Me.Buff('Cleric Mastery - Divine Health')() and mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Cleric'])() and mq.TLO.SpawnCount(CampFarmer.Settings.spawnSearch)() == 0 then
        if not mq.TLO.Me.Casting() and not mq.TLO.Me.Combat() then
            mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Cleric'])
            mq.delay(2500, function()
                return mq.TLO.Me.Buff('Cleric Mastery - Divine Health').ID() > 0
            end)
            mq.delay(CampFarmer.AAReuseDelay)
        end
    end
    if CampFarmer.Settings.useBemLegs and mq.TLO.FindItem('Bemvaras\'s Holy Greaves')() and mq.TLO.Me.ItemReady('Bemvaras\'s Holy Greaves')() and not mq.TLO.Me.Buff('Bemvaras\'s Enhanced Learning')() then
        if CampFarmer.Settings.UseExpPotions and mq.TLO.FindItem('Bemvaras\'s Holy Greaves')() and not mq.TLO.Me.Buff('Bemvaras\'s Enhanced Learning')() then
            mq.cmdf('/useitem %s', 'Bemvaras\'s Holy Greaves')
            mq.delay(CampFarmer.ItemReuseDelay)
        end
    else
        if CampFarmer.Settings.UseExpPotions and mq.TLO.FindItem(CampFarmer.Settings.potionName)() and not mq.TLO.Me.Buff('Bemvaras\'s Enhanced Learning')() and not mq.TLO.Me.Buff(CampFarmer.Settings.potionBuff)() then
            mq.cmdf('/useitem %s', CampFarmer.Settings.potionName)
            mq.delay(CampFarmer.ItemReuseDelay)
        end
    end
    if CampFarmer.Settings.useBemGloves and mq.TLO.FindItem('Bemvaras\'s Holy Gauntlets')() and mq.TLO.Me.ItemReady('Bemvaras\'s Holy Gauntlets')() and not mq.TLO.Me.Buff('Talisman of Guenhwyvar')() then
        mq.cmdf('/useitem %s', 'Bemvaras\'s Holy Gauntlets')
        mq.delay(CampFarmer.ItemReuseDelay)
    end
    if CampFarmer.Settings.useBemGloves and mq.TLO.FindItem('Bemvaras\'s Holy Gauntlets')() then
        if CampFarmer.Settings.useBuffCharm and mq.TLO.FindItem(CampFarmer.Settings.buffCharmName)() and mq.TLO.Me.ItemReady(CampFarmer.Settings.buffCharmName)() and not mq.TLO.Me.Buff('Circle of Fireskin')() then
            mq.cmdf('/useitem %s', CampFarmer.Settings.buffCharmName)
            mq.delay(CampFarmer.ItemReuseDelay)
        end
    else
        if not CampFarmer.Settings.useBemGloves and CampFarmer.Settings.useBuffCharm and mq.TLO.FindItem(CampFarmer.Settings.buffCharmName)() and mq.TLO.Me.ItemReady(CampFarmer.Settings.buffCharmName)() and not mq.TLO.Me.Buff(CampFarmer.Settings.buffCharmBuffName)() then
            mq.cmdf('/useitem %s', CampFarmer.Settings.buffCharmName)
            mq.delay(CampFarmer.ItemReuseDelay)
        end
    end
end

function CampFarmer.CombatSpells()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if mq.TLO.SpawnCount('npc alert 2')() >= 3 then
        if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Necromancer'])() then
            mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Necromancer'])
            mq.delay(CampFarmer.AAReuseDelay)
        end
        if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Enchanter'])() then
            mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Enchanter'])
            mq.delay(CampFarmer.AAReuseDelay)
        end
    end
    if mq.TLO.FindItem('Ertz\'s Mage Stone')() and mq.TLO.Me.ItemReady('Ertz\'s Mage Stone')() then
        mq.cmdf('/useitem %s', 'Ertz\'s Mage Stone')
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if not mq.TLO.Me.Buff('Shad\'s Warts').ID() and mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Shadowknight'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Shadowknight'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if not mq.TLO.Me.Buff('Mystereon\'s Prismatic Rune').ID() and mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Wizard'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Wizard'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if not mq.TLO.Me.Buff('Monk Mastery of A Thousand Fists').ID() and mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Monk'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Monk'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Shaman'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Shaman'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Necromancer'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Necromancer'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Rogue'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Rogue'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Berserker'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Berserker'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Bard'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Bard'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Ranger'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Ranger'])
        mq.delay(CampFarmer.AAReuseDelay)
    end
    CampFarmer.CheckBuffs()
end

function CampFarmer.CheckPetAoE()
    CampFarmer.HandleDisconnect()
    function CheckPetButton(numButton, buttonText, stateWanted)
        local buttonName = string.format("Pet%d_Button", numButton)
        -- Check if the button text matches the expected buttonText
        if mq.TLO.Window("PetInfoWindow").Child(buttonName).Text() == buttonText then
            -- Check if the button state does not match the desired state
            if mq.TLO.Window("PetInfoWindow").Child(buttonName).Checked() ~= stateWanted then
                -- Trigger a left mouse click on the button
                mq.cmdf("/notify PetInfoWindow %s leftmouseup", buttonName)
            end
        end
    end

    -- Check if the Pet Info window is open
    if mq.TLO.Window("PetInfoWindow").Open() then
        for x = 0, 10 do
            CheckPetButton(x, "hold", 0)
            CheckPetButton(x, "focus", 1)
            -- CheckPetButton(x, "taunt", 0) -- Uncomment if needed
        end
    end
end

function CampFarmer.CheckZone()
    CampFarmer.HandleDisconnect()
    if mq.TLO.Zone.ID() ~= CampFarmer.startZone and mq.TLO.DynamicZone() ~= nil then
        if not CampFarmer.needToBank and not CampFarmer.needToCashSell and not CampFarmer.needToFabledSell then
            mq.cmd('/say #enter')
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == CampFarmer.startZone
            end)
            mq.delay(1000)
        end
    elseif mq.TLO.Zone.ID() ~= CampFarmer.startZone and mq.TLO.DynamicZone() == nil then
        mq.cmdf('/say #create solo %s', CampFarmer.startZoneName)
        mq.delay(50000, function()
            return mq.TLO.Zone.ID()() == CampFarmer.startZone
        end)
        mq.delay(1000)
    end
end

function CampFarmer.CheckLevel()
    CampFarmer.HandleDisconnect()
    if mq.TLO.Me.Level() <= 79 or (mq.TLO.Me.Level() >= 80 and mq.TLO.Me.PctExp() < 50) then
        mq.cmdf('/alt on %s', 50)
    elseif mq.TLO.Me.Level() >= 80 then
        mq.cmdf('/alt on %s', 100)
    end
end

function CampFarmer.CheckGroup()
    CampFarmer.HandleDisconnect()
    if CampFarmer.Settings.GroupAlt and not mq.TLO.Me.Grouped() then
        if mq.TLO.Spawn(CampFarmer.Settings.AltLooterName).ID() > 0 then
            mq.cmdf('/invite %s', CampFarmer.Settings.AltLooterName)
            mq.delay(CampFarmer.FastDelay)
        end
    end
end

function CampFarmer.CheckAATokens()
    CampFarmer.HandleDisconnect()
    if CampFarmer.Settings.ClickAATokens and mq.TLO.FindItem('Token of Advancement') then
        mq.cmdf('/useitem %s', mq.TLO.FindItem('Token of Advancement').Name())
    end
end

local allowUberPull = false
function CampFarmer.RespawnZone()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() > CampFarmer.Settings.MinMobsInZone then
        return
    end
    if not mq.TLO.FindItem(CampFarmer.Settings.respawnItem)() then
        return
    end
    if not mq.TLO.Me.ItemReady(CampFarmer.Settings.respawnItem)() then
        return
    end
    CampFarmer.Messages.Normal('Attempting to respawn the zone!')
    CampFarmer.CheckCorpseCount()
    mq.cmdf('/useitem %s', CampFarmer.Settings.respawnItem)
    mq.delay(CampFarmer.RepopDelay)
    allowUberPull = true
    CampFarmer.CheckPet()
end

function CampFarmer.Aggro(aggroCharm)
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if CampFarmer.CheckXTargAggro() > 0 then
        return
    end
    mq.cmdf('/target id %s', mq.TLO.Me.ID())
    mq.delay(1000, function()
        return mq.TLO.Target.ID() == mq.TLO.Me.ID()
    end)
    mq.delay(CampFarmer.FastDelay)
    mq.cmdf('/useitem %s', aggroCharm)
    mq.delay(CampFarmer.AggroDelay)
end

function CampFarmer.AggroZone()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if allowUberPull and CampFarmer.Settings.DoUberPull and mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() > CampFarmer.Settings.MinMobsInZone and mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() <= CampFarmer.Settings.UberPullMobsInZone then
        CampFarmer.Aggro(CampFarmer.Settings.aggroUberItem)
        allowUberPull = false
        return
    end
    if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() < CampFarmer.Settings.MinMobsInZone then
        return
    end
    if not mq.TLO.FindItem(CampFarmer.Settings.aggroItem)() then
        return
    end
    if not mq.TLO.Me.ItemReady(CampFarmer.Settings.aggroItem)() then
        return
    end
    if mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch)() then
        return
    end
    if CampFarmer.CheckXTargAggro() > 0 then
        return
    end
    CampFarmer.CheckPet()
    CampFarmer.Aggro(CampFarmer.Settings.aggroItem)
end

function CampFarmer.LootMobs()
    CampFarmer.HandleDisconnect()
    CampFarmer.CheckZone()
    if mq.TLO.SpawnCount(CampFarmer.Settings.spawnWildcardSearch:format('corpse ' .. CampFarmer.Settings.targetName, CampFarmer.Settings.scan_Radius, CampFarmer.Settings.scan_zRadius))() > 0 or (CampFarmer.Settings.lootAll and mq.TLO.SpawnCount(CampFarmer.Settings.spawnWildcardSearch:format('corpse', CampFarmer.Settings.scan_Radius, CampFarmer.Settings.scan_zRadius))() > 0) then
        if CampFarmer.Settings.lootAll then
            mq.cmdf('/target %s',
                mq.TLO.NearestSpawn(CampFarmer.Settings.spawnWildcardSearch:format('corpse',
                    CampFarmer.Settings.scan_Radius, CampFarmer.Settings.scan_zRadius))())
        else
            mq.cmdf('/target %s',
                mq.TLO.NearestSpawn(CampFarmer.Settings.spawnWildcardSearch:format(
                    'corpse ' .. CampFarmer.Settings.targetName, CampFarmer.Settings.scan_Radius,
                    CampFarmer.Settings.scan_zRadius))())
        end
        if mq.TLO.Target() and mq.TLO.Target.Type() == 'Corpse' then
            mq.cmd('/squelch /warp t')
            mq.delay(100)
            if CampFarmer.Settings.doStand and not mq.TLO.Me.Standing() then
                mq.cmd('/stand')
                mq.delay(50)
            end
            CampFarmer.LootUtils.lootCorpse(mq.TLO.Target.ID())
            mq.delay(100)
            mq.doevents()
            mq.delay(100)
            if CampFarmer.Settings.returnHomeAfterLoot then
                mq.cmdf('/squelch /warp loc %s %s %s', CampFarmer.startY, CampFarmer.startX, CampFarmer.startZ)
                mq.delay(50)
            end
        end
    end
end

function CampFarmer.CheckTarget()
    CampFarmer.HandleDisconnect()
    CampFarmer.Checks()
    if not mq.TLO.Me.Standing() then
        mq.TLO.Me.Stand()
    end
    -- print(CampFarmer.CheckDistance(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z()))
    if CampFarmer.CheckDistance(CampFarmer.startX, CampFarmer.startY, CampFarmer.startZ) > CampFarmer.Settings.ReturnToHomeDistance then
        if (mq.TLO.Target() and not string.find(mq.TLO.Target.CleanName(), 'Treasure Goblin')) or not mq.TLO.Target() then
            mq.cmdf('/squelch /warp loc %s %s %s', CampFarmer.startY, CampFarmer.startX, CampFarmer.startZ)
            mq.delay(100)
        end
    end
    if mq.TLO.Target() and mq.TLO.Target.Type() == 'Pet' or mq.TLO.Target.Type() == 'Corpse' or mq.TLO.Target.Type() == 'Pc' or mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.CleanName() == mq.TLO.Pet.CleanName() then
        mq.cmd('/squelch /target clear')
    end
    if mq.TLO.SpawnCount('npc alert 2')() > 0 then
        if mq.TLO.Target() and not string.find(mq.TLO.Target.CleanName(), 'Treasure Goblin') then
            mq.cmdf('/squelch /target id %s', mq.TLO.Spawn('npc alert 2').ID())
            mq.delay(CampFarmer.FastDelay)
        end
        if mq.TLO.Target() and mq.TLO.Target.Distance() > 10 and mq.TLO.Me.Class() ~= 'Ranger' then
            mq.cmd('/squelch /warp t')
            mq.cmd('/squelch /stick moveback 10')
            mq.delay(CampFarmer.FastDelay)
        elseif mq.TLO.Target() and mq.TLO.Target.Distance() > 20 and mq.TLO.Me.Class() == 'Ranger' then
            mq.cmd('/squelch /warp t')
            mq.cmd('/squelch /stick moveback 10')
            mq.delay(CampFarmer.FastDelay)
        end
        CampFarmer.KillThis()
    end
    if not mq.TLO.Me.Combat() and mq.TLO.Target() then
        CampFarmer.KillThis()
    end
    CampFarmer.CombatSpells()
    if CampFarmer.Settings.DoLoot and mq.TLO.SpawnCount(CampFarmer.Settings.corpseSearch)() and mq.TLO.Me.FreeInventory() then
        CampFarmer.LootMobs()
    end
    if not mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch)() and CampFarmer.CheckXTargAggro() == 0 then
        if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() < CampFarmer.Settings.MinMobsInZone then
            CampFarmer.RespawnZone()
            CampFarmer.AggroZone()
            CampFarmer.CheckTarget()
        else
            CampFarmer.AggroZone()
            CampFarmer.CheckTarget()
        end
    end
    if CampFarmer.CheckXTargAggro() == 0 and mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() > CampFarmer.Settings.MinMobsInZone then
        CampFarmer.AggroZone()
    end
    if not mq.TLO.Target() and mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch)() then
        mq.cmdf('/target id %s', mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch).ID())
        CampFarmer.KillThis()
    end
    if mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch)() and CampFarmer.CheckXTargAggro() > 0 then
        CampFarmer.CheckTarget()
    end
    if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() > CampFarmer.Settings.MinMobsInZone then
        CampFarmer.CheckTarget()
    end
end

function CampFarmer.Checks()
    if not mq.TLO.Me.Standing() or mq.TLO.Me.Ducking() then
        mq.TLO.Me.Stand()
    end
    CampFarmer.CheckZone()
    CampFarmer.CheckLevel()
    CampFarmer.CheckGroup()
    CampFarmer.CheckCorpseCount()
    CampFarmer.CheckAATokens()
    if CampFarmer.Settings.DoLoot and mq.TLO.SpawnCount(CampFarmer.Settings.corpseSearch)() and mq.TLO.Me.FreeInventory() then
        CampFarmer.LootMobs()
    end
    CampFarmer.CheckPet()
end

function CampFarmer.BankDropOff()
    CampFarmer.HandleDisconnect()
    if mq.TLO.Me.FreeInventory() <= CampFarmer.Settings.bankAtFreeSlots or CampFarmer.needToBank then
        if mq.TLO.Zone.ID() ~= CampFarmer.Settings.bankZone then
            mq.cmdf('/say #zone %s', CampFarmer.Settings.bankZone)
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == CampFarmer.Settings.bankZone
            end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == CampFarmer.Settings.bankZone then
            mq.cmdf('/target npc %s', CampFarmer.Settings.bankNPC)
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
            CampFarmer.LootUtils.bankStuff()
            mq.delay(500)
            if CampFarmer.Settings.sellFabled then
                CampFarmer.needToFabledSell = true
                CampFarmer.FabledSell()
                mq.delay(500)
            end
            if CampFarmer.Settings.sellCash then
                CampFarmer.needToCashSell = true
                CampFarmer.CashSell()
                mq.delay(500)
            end
            if CampFarmer.Settings.sellVendor then
                CampFarmer.needToVendorSell = true
                CampFarmer.VendorSell()
                mq.delay(500)
            end
            CampFarmer.needToBank = false
        end
    end
end

function CampFarmer.VendorSell()
    CampFarmer.HandleDisconnect()
    if CampFarmer.needToVendorSell then
        if mq.TLO.Zone.ID() ~= CampFarmer.Settings.bankZone then
            mq.cmdf('/say #zone %s', CampFarmer.Settings.bankZone)
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == CampFarmer.Settings.bankZone
            end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == CampFarmer.Settings.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', CampFarmer.Settings.vendorNPC)
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
            CampFarmer.LootUtils.sellStuff()
            CampFarmer.needToVendorSell = false
        end
    end
end

function CampFarmer.CashSell()
    CampFarmer.HandleDisconnect()
    if CampFarmer.needToCashSell then
        if mq.TLO.Zone.ID() ~= CampFarmer.Settings.bankZone then
            mq.cmdf('/say #zone %s', CampFarmer.Settings.bankZone)
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == CampFarmer.Settings.bankZone
            end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == CampFarmer.Settings.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', CampFarmer.Settings.cashNPC)
            mq.delay(250)
            mq.delay(5000, function()
                return mq.TLO.Target()() ~= nil
            end)
            mq.cmd('/squelch /warp t')
            mq.delay(500)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000, function()
                return mq.TLO.Window('NewPointMerchantWnd').Open()
            end)
            CampFarmer.LootUtils.sellCashItems(true)
            CampFarmer.needToCashSell = false
        end
    end
end

function CampFarmer.FabledSell()
    CampFarmer.HandleDisconnect()
    if CampFarmer.needToFabledSell then
        if mq.TLO.Zone.ID() ~= CampFarmer.Settings.bankZone then
            mq.cmdf('/say #zone %s', CampFarmer.Settings.bankZone)
            mq.delay(50000, function()
                return mq.TLO.Zone.ID()() == CampFarmer.Settings.bankZone
            end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == CampFarmer.Settings.bankZone then
            mq.delay(500)
            mq.cmdf('/target npc %s', CampFarmer.Settings.fabledNPC)
            mq.delay(250)
            mq.delay(5000, function()
                return mq.TLO.Target()() ~= nil
            end)
            mq.cmd('/squelch /warp t')
            mq.delay(1000)
            mq.cmd('/say I understand')
            mq.delay(1000)
            mq.doevents('SellFabledItems')
            mq.delay(1000)
            CampFarmer.needToFabledSell = false
        end
    end
end

function CampFarmer.CheckPet()
    if mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch)() ~= 0 then
        return
    end
    if not mq.TLO.Pet.ID() and not mq.TLO.Me.Combat() and mq.TLO.Me.AltAbilityReady(CampFarmer.ClassAAs['Beastlord'])() then
        mq.cmdf('/alt act %s', CampFarmer.ClassAAs['Beastlord'])
        mq.delay(2500, function()
            return mq.TLO.Pet.ID() > 0 or mq.TLO.NearestSpawn(CampFarmer.Settings.spawnSearch)()
        end)
        CampFarmer.CheckPetAoE()
    end
end

local function event_instance_handler(line, minutes)
    CampFarmer.Messages.Debug('function event_instance_handler(line, minutes)')
    local minutesLeft = tonumber(minutes)
    if minutesLeft >= CampFarmer.reset_Instance_At then
        if mq.TLO.DynamicZone() ~= nil then
            if mq.TLO.Plugin('MQ2DanNet').IsLoaded() and mq.TLO.DynamicZone.Members() > 1 then
                mq.cmd('/dgga /dzq')
            else
                mq.cmd('/dzq')
            end
            mq.delay(CampFarmer.wait_Two)
            mq.cmdf('/say #create solo %s', CampFarmer.startZoneName)
            mq.delay(CampFarmer.wait_Three)
            mq.delay(CampFarmer.zone_Wait, function()
                return mq.TLO.Zone.ID()() == CampFarmer.startZone
            end)
        else
            mq.cmdf('/say #create solo %s', CampFarmer.startZoneName)
            mq.delay(CampFarmer.wait_Three)
            mq.delay(CampFarmer.zone_Wait, function()
                return mq.TLO.Zone.ID()() == CampFarmer.startZone
            end)
        end
    end
end
mq.event('InstanceCheck', "You only have #1# minutes remaining before this expedition comes to an end.",
    event_instance_handler)

local function event_fabledSell_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, CampFarmer.Settings.SellFabledFor) then
            mq.ExecuteTextLink(link)
        end
    end
end
mq.event('SellFabledItems',
    "#*#The Fabled Jim Carrey whispers, 'Which currency would you like to receive for your rank 1 fabled items? #1#?'",
    event_fabledSell_handler, {
        keepLinks = true
    })

function CampFarmer.VersionCheck()
    local requiredVersion = {
        3,
        1,
        1,
        0
    }
    local currentVersionStr = mq.TLO.MacroQuest.Version() -- Get the current version as string
    local currentVersion = {}

    for v in string.gmatch(currentVersionStr, '([0-9]+)') do
        table.insert(currentVersion, tonumber(v))
    end

    for i = 1, #requiredVersion do
        if currentVersion[i] == nil or currentVersion[i] < requiredVersion[i] then
            CampFarmer.Messages.Normal(
                'Your build is too old to run this script. Please get a newer version of MacroQuest from https://www.mq2emu.com')
            mq.cmdf('/lua stop %s', CampFarmer.script_ShortName)
            return
        elseif currentVersion[i] > requiredVersion[i] then
            return
        end
    end
end

local function binds(...)
    local args = {
        ...
    }
    if args ~= nil then
        if args[1] == 'gui' then
            CampFarmer.GUI.Open = not CampFarmer.GUI.Open
        elseif args[1] == 'bank' then
            CampFarmer.needToBank = true
            CampFarmer.BankDropOff()
        elseif args[1] == 'vendor' then
            CampFarmer.needToVendorSell = true
        elseif args[1] == 'cash' then
            CampFarmer.needToCashSell = true
            CampFarmer.CashSell()
        elseif args[1] == 'fabled' then
            CampFarmer.needToFabledSell = true
            CampFarmer.FabledSell()
        elseif args[1] == 'report' then
            local totalAA, aaPerHour = CampFarmer.AAStatus()
            CampFarmer.Messages.Normal('Total AA gained: %d', totalAA)
            CampFarmer.Messages.Normal('Current AA per hour: %.2f', aaPerHour)
        elseif args[1] == 'quit' then
            CampFarmer.terminate = true
            mq.cmdf('/lua stop %s', CampFarmer.script_ShortName)
        else
            CampFarmer.Messages.Normal('Valid Commands:')
            CampFarmer.Messages.Normal('/%s \aggui\aw - Toggles the Control Panel GUI', CampFarmer.command_ShortName)
            CampFarmer.Messages.Normal('/%s \agbank\aw - Send your character to bank items', CampFarmer
                .command_ShortName)
            CampFarmer.Messages.Normal('/%s \agfabled\aw - Send your character to sell fabled items',
                CampFarmer.command_ShortName)
            CampFarmer.Messages.Normal('/%s \agcash\aw - Send your character to sell cash items',
                CampFarmer.command_ShortName)
            CampFarmer.Messages.Normal('/%s \agquit\aw - Quits the lua script.', CampFarmer.command_ShortName)
        end
    else
        CampFarmer.Messages.Normal('Valid Commands:')
        CampFarmer.Messages.Normal('/%s \aggui\aw - Toggles the Control Panel GUI', CampFarmer.command_ShortName)
        CampFarmer.Messages.Normal('/%s \agbank\aw - Send your character to bank items', CampFarmer.command_ShortName)
        CampFarmer.Messages.Normal('/%s \agfabled\aw - Send your character to sell fabled items',
            CampFarmer.command_ShortName)
        CampFarmer.Messages.Normal('/%s \agcash\aw - Send your character to sell cash items',
            CampFarmer.command_ShortName)
        CampFarmer.Messages.Normal('/%s \agquit\aw - Quits the lua script.', CampFarmer.command_ShortName)
    end
end

CampFarmer.GUI.initGUI()

local function setupBinds()
    mq.bind('/' .. CampFarmer.command_ShortName, binds)
    mq.bind('/' .. CampFarmer.command_LongName, binds)
end

function CampFarmer.getElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTimeInSeconds = os.difftime(currentTime, startTime)

    -- Calculate hours, minutes, and seconds
    local hours = math.floor(elapsedTimeInSeconds / 3600)
    local minutes = math.floor((elapsedTimeInSeconds % 3600) / 60)
    local seconds = elapsedTimeInSeconds % 60

    -- Format as HH:MM:SS
    return string.format('%02d:%02d:%02d', hours, minutes, seconds)
end

function CampFarmer.formatNumberWithCommas(number)
    local formatted = tostring(number)
    -- Use pattern to insert commas
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function CampFarmer.AAStatus()
    -- Get current AA points and current time
    local currentAA = mq.TLO.Me.AAPoints()
    local currentTime = os.time()

    -- Calculate total AA gained
    local aaGained = currentAA - CampFarmer.StartAA

    -- Calculate elapsed time in seconds and convert to hours
    local elapsedTimeInSeconds = os.difftime(currentTime, CampFarmer.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    -- Prevent division by zero if somehow elapsedTimeInHours is too small
    local aaPerHour = 0
    if elapsedTimeInHours > 0 then
        aaPerHour = aaGained / elapsedTimeInHours
    end

    -- Return both total AA gained and AA per hour
    return aaGained, aaPerHour
end

function CampFarmer.CurrencyStatus()
    -- Get current AA points and current time
    local currentDoubloons = mq.TLO.Me.AltCurrency('Doubloons')()
    local currentPapers = mq.TLO.Me.AltCurrency('31')()
    local currentCash = mq.TLO.Me.AltCurrency('Cash')()
    local currentTime = os.time()

    local doubloonsGained = currentDoubloons - CampFarmer.StartDoubloons
    local papersGained = currentPapers - CampFarmer.StartPapers
    local cashGained = currentCash - CampFarmer.StartCash

    -- Calculate elapsed time in seconds and convert to hours
    local elapsedTimeInSeconds = os.difftime(currentTime, CampFarmer.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    -- Prevent division by zero if somehow elapsedTimeInHours is too small
    local doubloonsPerHour = 0
    local papersPerHour = 0
    local cashPerHour = 0
    if elapsedTimeInHours > 0 then
        doubloonsPerHour = doubloonsGained / elapsedTimeInHours
        papersPerHour = papersGained / elapsedTimeInHours
        cashPerHour = cashGained / elapsedTimeInHours
    end

    -- Return both total AA gained and AA per hour
    return doubloonsGained, doubloonsPerHour, papersGained, papersPerHour, cashGained, cashPerHour
end

function CampFarmer.Main()
    setupBinds()
    CampFarmer.Setup()
    CampFarmer.StartAA = mq.TLO.Me.AAPoints()
    CampFarmer.StartDoubloons = mq.TLO.Me.AltCurrency('Doubloons')()
    CampFarmer.StartPapers = mq.TLO.Me.AltCurrency('31')()
    CampFarmer.StartCash = mq.TLO.Me.AltCurrency('Cash')()
    CampFarmer.StartTime = os.time()
    CampFarmer.Messages.Normal('Setting up Alert Lists')
    CampFarmer.SetupAlertLists()
    CampFarmer.CheckCampInfo()
    CampFarmer.LootUtils.CheckLootActions()
    mq.cmd('/hidecorpse looted')
    CampFarmer.Messages.Normal('Initialized')
    CampFarmer.Messages.Normal('Static Mode: %s', CampFarmer.Settings.staticHunt)
    CampFarmer.Messages.Normal('Camp Zone: %s', CampFarmer.startZoneName)
    CampFarmer.Messages.Normal('Location: X(%s) Y(%s) Z(%s)', CampFarmer.startX, CampFarmer.startY, CampFarmer.startZ)
    CampFarmer.Messages.Normal('Looting: %s', CampFarmer.Settings.DoLoot)
    CampFarmer.Messages.Normal('Loot INI File: %s', CampFarmer.Settings.lootINIFile)
    if mq.TLO.Pet.ID() then
        CampFarmer.CheckPetAoE()
    else
        CampFarmer.CheckPet()
    end
    CampFarmer.CheckBuffs()
    CampFarmer.Messages.Normal('Starting the slaughter!')
    while CampFarmer.loop do
        CampFarmer.HandleDisconnect()
        CampFarmer.Checks()
        pcall(CampFarmer.CheckTarget)
        if CampFarmer.Settings.bankDeposit and mq.TLO.Me.FreeInventory() <= CampFarmer.Settings.bankAtFreeSlots then
            CampFarmer.needToBank = true
        end
        if CampFarmer.needToBank then
            CampFarmer.BankDropOff()
        end
        if CampFarmer.needToCashSell then
            CampFarmer.CashSell()
        end
        if CampFarmer.needToFabledSell then
            CampFarmer.FabledSell()
        end
        if CampFarmer.needToVendorSell then
            CampFarmer.VendorSell()
        end
        -- Check if 5 minutes (300 seconds) have passed since the last report
        if CampFarmer.Settings.ReportGain then
            local currentTime = os.time()
            if os.difftime(currentTime, CampFarmer.LastReportTime) >= CampFarmer.Settings.ReportAATime then
                local totalAA, aaPerHour = CampFarmer.AAStatus()
                CampFarmer.Messages.Normal('Total AA gained: %d', totalAA)
                CampFarmer.Messages.Normal('Current AA per hour: %.2f', aaPerHour)
                CampFarmer.LastReportTime = currentTime -- Update the last report time
            end
        end
        mq.delay(CampFarmer.FastDelay)
    end
end

CampFarmer.Main()

return CampFarmer
