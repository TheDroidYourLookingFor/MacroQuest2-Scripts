local mq = require('mq')

--
-- Dont edit these settings
--
local RB = {
    version = '1.0.5',
    script_ShortName = 'RebirthMachine',
    command_ShortName = 'rbm',
    command_LongName = 'RebirthMachine',
    debug = false,
    Terminate = false,
    NewDisconnectHandler = true,
    CurrentRebirths = 0,
    CurrentAugAmount = 0,
    mob_Wait = 50000,
    zone_Wait = 50000,
    rebirth_Wait = 2500,
    wait_One = 500,
    wait_Two = 750,
    wait_Three = 1000,
    wait_Four = 250,
    wait_CharChange = 25000,
    wait_AtCharSelect = 15000,
    reset_Instance_At = 5,
    spawnSearch = '%s targetable radius %d zradius %d noalert 1',
    nextClass = '',
    AllClassesDone = false,
    AAReuseDelay = 500,
    ItemReuseDelay = 500,
    FastDelay = 50,
    RepopDelay = 1500,
    AggroDelay = 1500,
    settingsFile = mq.configDir ..
        '\\RebirthMachine.' .. mq.TLO.EverQuest.Server() .. '_' .. mq.TLO.Me.CleanName() .. '.ini',
}

--
-- Edit these settings
--
RB.Settings = {
    Version = RB.version,
    swapClasses = true,                   -- Swap classes when we hit rebirth cap?
    classType = 'TANK',                    -- Type of classes to rebirth. DPS/TANK
    farmClassAugs = false,                -- DOESNT WORK CURRENTLY
    farmClassAugsAmount = 2,              -- How many of the class augments should we farm?
    rebirthStopAt = 10,                   -- After how many Rebirths should we stop?
    staticHuntMode = true,                -- Should we camp a spot and kill or move around?
    huntZoneName = 'pofire',              -- Where should we kill?
    reset_At_Mob_Count = 65,              -- How few mobs in the zone should cause a repop?
    aggro_Radius = 75,                    -- How far around our camp should we look for mobs
    aggro_zRadius = 25,                   -- Same but Z axis
    returnHomeDistance = 50,              -- How far away from camp should we get before returning
    warpToMobDistance = 25,               -- How close to warp to a mob?
    hideCorpses = true,                   -- Should we hide corpses?
    corpse_Phrase = '/say #deletecorpse', -- The commands we should use to hide corpses.
    corpseLimit = 200,
    -- corpse_Phrase = '/hidecorpse all',           -- The commands we should use to hide corpses.
    castSpells = false, -- Should we cast spells?
    spells = {
        'Cool Spell 01',
        'Cool Spell 02'
    },                                           -- Which spells should we cast? Put as many as you want
    UseExpPotions = false,                       -- Should we consume XP potions?
    potionName = 'Potion of Adventure II',       -- What is the name of the XP Potion?
    potionBuff = 'Potion of Adventure II',       -- What is the name of the XP Potion Buff?
    zoneRefresh = 'Uber Charm of Refreshing',    -- Name of the item we use to refresh the zone
    moveOnPull = true,                           -- Should we move automatically when we pull away from the mob stack?
    zonePull = 'Derekthomx\'s Horrorkrunk Hook', -- Name of the item we use to mass aggro
    -- zonePull = 'Charm of Hate',                                                        -- Name of the item we use to mass aggro
    hubZoneID = 183,                             -- Zone ID of our hub zone
    equip_Macro = '/ma equip',                   -- Line to restore all our gear
    unequip_Macro = '/ma unequipall',            -- Line to remove all our gear
    usePaladinAA = true,
    useClericAA = true,
    useBemChest = true,
    useBemLegs = true,
    useBemGloves = true,
    useBuffCharm = true,
    useCoinSack = true,
    useErtzStone = true,
    useCurrencyCharm = false,
    buffCharmName = 'Amulet of Ultimate Buffing',
    buffCharmBuffName = 'Talisman of the Panther Rk. III',
    spawnSearch = 'npc radius 60 los targetable noalert 1',
    bankZone = 183,
    bankNPC = 'Griphook',
    classType_idx = 1,
}

RB.huntZone = {
    paw = {
        ID = 18,
        X = 42.53,
        Y = 718.35,
        Y_Pull = 700,
        Z = 4.12,
        ignoreTarget = 'an imprisoned gnoll'
    },
    pofire = {
        ID = 217,
        X = 612.22,
        Y = 657.17,
        Y_Pull = 627.17,
        Z = -166.87,
        ignoreTarget = 'Essence of Fire'
    },
    maiden = {
        ID = 173,
        X = 1426,
        Y = 955,
        Y_Pull = 925,
        Z = -152,
        ignoreTarget = ''
    }
}

RB.IgnoreList = {
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
    "The ground",
    'Essence of Fire',
    'an imprisoned gnoll'
}

RB.ClassAAs = {
    Bard = 39908,
    Beastlord = 39915,
    Berserker = 39916,
    Cleric = 39902,
    Druid = 39906,
    Enchanter = 39914,
    Mage = 39913,
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

RB.UseClassAA = {
    Bard = true,
    Beastlord = true,
    Berserker = true,
    Cleric = true,
    Druid = true,
    Enchanter = true,
    Mage = true,
    Monk = true,
    Necromancer = true,
    Paladin = true,
    Ranger = true,
    Rogue = true,
    Shadowknight = true,
    Shaman = true,
    Warrior = true,
    Wizard = true
}
--
-- Stop editing! :D You know unless you really want to and know what you're doing
--
RB.classType = {
    'DPS',
    'TANK',
    'ALL'
}
RB.RebirthType = {
    DPS = { 'Bard', 'Beastlord', 'Berserker', 'Cleric', 'Druid', 'Enchanter', 'Mage', 'Monk', 'Necromancer', 'Ranger', 'Rogue', 'Shaman', 'Wizard' },
    TANK = { 'Paladin', 'Shadowknight', 'Warrior' },
    ALL = { 'Bard', 'Beastlord', 'Berserker', 'Cleric', 'Druid', 'Enchanter', 'Mage', 'Monk', 'Necromancer', 'Paladin', 'Ranger', 'Rogue', 'Shadowknight', 'Shaman', 'Wizard', 'Warrior' },
}

RB.Classes = {
    Bard = true,
    Beastlord = true,
    Berserker = true,
    Cleric = true,
    Druid = true,
    Enchanter = true,
    Mage = true,
    Monk = true,
    Necromancer = true,
    Paladin = true,
    Ranger = true,
    Rogue = true,
    Shadowknight = true,
    Shaman = true,
    Warrior = true,
    Wizard = true
}

RB.Messages = require('RebirthMachine.lib.Messages')
RB.Storage = require('RebirthMachine.lib.Storage')

function RB.ValidateSettings()
    if RB.Settings.useCoinSack and not mq.TLO.FindItem('Bemvaras\' Coin Sack')() then
        RB.Messages.Normal('You have enabled auto clicking %s but you do not have it!', 'Bemvaras\' Coin Sack')
        RB.Settings.useCoinSack = false
    end
    if RB.Settings.useCurrencyCharm and not mq.TLO.FindItem('Soulriever\'s Charm of Currency')() then
        RB.Messages.Normal('You have enabled auto clicking %s but you do not have it!',
            'Soulriever\'s Charm of Currency')
        RB.Settings.useCurrencyCharm = false
    end
    if RB.Settings.usePaladinAA and not mq.TLO.Me.AltAbility(RB.ClassAAs['Paladin'])() then
        RB.Messages.Normal('You have enabled using alt ability #%s but you do not have it!',
            RB.ClassAAs['Paladin'])
        RB.Settings.usePaladinAA = false
    end
    if RB.Settings.useBemChest and not mq.TLO.FindItem('Bemvaras\'s Golden Breastplate Rk. I')() then
        RB.Messages.Normal('You have enabled auto clicking %s but you do not have it!',
            'Bemvaras\'s Golden Breastplate Rk. I')
        RB.Settings.useBemChest = false
    end
    if RB.Settings.useClericAA and not mq.TLO.Me.AltAbility(RB.ClassAAs['Cleric'])() then
        RB.Messages.Normal('You have enabled using alt ability #%s but you do not have it!',
            RB.ClassAAs['Cleric'])
        RB.Settings.useClericAA = false
    end
    if RB.Settings.useBemLegs and not mq.TLO.FindItem('Bemvaras\'s Holy Greaves')() then
        RB.Messages.Normal('You have enabled auto clicking %s but you do not have it!',
            'Bemvaras\'s Holy Greaves')
        RB.Settings.useBemLegs = false
    end
    if RB.Settings.useBemGloves and not mq.TLO.FindItem('Bemvaras\'s Holy Gauntlets')() then
        RB.Messages.Normal('You have enabled auto clicking %s but you do not have it!',
            'Bemvaras\'s Holy Gauntlets')
        RB.Settings.useBemGloves = false
    end
    if not mq.TLO.FindItem(RB.Settings.buffCharmName)() then
        RB.Messages.Normal('You have enabled auto buffing with %s but do not have it.',
            RB.Settings.buffCharmName)
        if mq.TLO.FindItem('Amulet of Ultimate Buffing')() then
            RB.Settings.buffCharmName = 'Amulet of Ultimate Buffing'
            RB.Settings.buffCharmBuffName = 'Talisman of the Panther Rk. III'
        elseif mq.TLO.FindItem('Amulet of Elite Buffing')() then
            RB.Settings.buffCharmName = 'Amulet of Elite Buffing'
            RB.Settings.buffCharmBuffName = 'Spirit of Minato'
        elseif mq.TLO.FindItem('Amulet of Strong Buffing')() then
            RB.Settings.buffCharmName = 'Amulet of Strong Buffing'
            RB.Settings.buffCharmBuffName = 'Spirit of Ox'
        else
            RB.Messages.Normal('No buff item found!')
        end
    end
    if RB.Settings.buffCharmName == 'Amulet of Ultimate Buffing' and not mq.TLO.FindItem('Amulet of Ultimate Buffing')() then
        RB.Messages.Normal('You have enabled auto buffing with %s but do not have it.',
            'Amulet of Ultimate Buffing')
        if mq.TLO.FindItem('Amulet of Elite Buffing')() then
            RB.Settings.buffCharmName = 'Amulet of Elite Buffing'
            RB.Settings.buffCharmBuffName = 'Spirit of Minato'
        elseif mq.TLO.FindItem('Amulet of Strong Buffing')() then
            RB.Settings.buffCharmName = 'Amulet of Strong Buffing'
            RB.Settings.buffCharmBuffName = 'Spirit of Ox'
        else
            RB.Messages.Normal('No buff item found!')
        end
    end
    if not mq.TLO.FindItem(RB.Settings.zonePull)() then
        RB.Messages.Normal('You are missing your zone wide aggro item! You tried to use %s.',
            RB.Settings.zonePull)
        mq.cmd('/lua stop RB')
    end
    if not mq.TLO.FindItem(RB.Settings.zoneRefresh)() then
        RB.Messages.Normal('You are missing your zone wide respawn item! You tried to use %s.',
            RB.Settings.zoneRefresh)
        mq.cmd('/lua stop RB')
    end
    if RB.Settings.DoUberPull and not mq.TLO.FindItem(RB.Settings.aggroUberItem)() then
        RB.Settings.DoUberPull = false
    end
    if RB.Settings.useErtzStone and not mq.TLO.FindItem('Ertz\'s Mage Stone')() then
        RB.Settings.useErtzStone = false
    end
end

function RB.SaveSettings(iniFile, settingsList)
    RB.Messages.Debug('function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function RB.Setup()
    RB.Messages.Debug('function Setup() Entry')
    local conf
    local configData, err = loadfile(RB.settingsFile)
    if err then
        RB.SaveSettings(RB.settingsFile, RB.Settings)
    elseif configData then
        conf = configData()
        if conf.Version ~= RB.Settings.Version then
            RB.SaveSettings(RB.settingsFile, RB.Settings)
            RB.ValidateSettings()
            RB.Setup()
        else
            RB.Settings = conf
            RB.ValidateSettings()
        end
    end
end

RB.Setup()

function RB.CheckRebirthType()
    local classType = RB.Settings.classType
    local classesToSet = RB.RebirthType[classType]

    if classesToSet then
        for className in pairs(RB.Classes) do
            RB.Classes[className] = true
        end
        for _, className in ipairs(classesToSet) do
            RB.Classes[className] = false
        end
    end
end

RB.CheckRebirthType()

function RB.FindItemInBags(itemName)
    for slot = 23, 32 do
        local item = mq.TLO.Me.Inventory(slot)
        if item() and item.ID() then
            if item.Container() then
                for itemSlot = 1, item.Container() do
                    local containerItem = item.Item(itemSlot)
                    if containerItem() and containerItem.ID() and containerItem.Name() == itemName then
                        return true
                    end
                end
            elseif item.Name() == itemName then
                return true
            end
        end
    end
    return false
end

function RB.CheckCurrentClassAugs()
    for className, isEnabled in pairs(RB.Classes) do
        if className ~= 'Shadowknight' and RB.FindItemInBags(className .. ' Mastery Augmentation') then
            if not isEnabled then
                RB.Classes[className] = true
            end
        elseif className == 'Shadowknight' and RB.FindItemInBags('Shadow Knight Mastery Augmentation') then
            if not isEnabled then
                RB.Classes[className] = true
            end
        end
    end
end

RB.CheckCurrentClassAugs()

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

function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then
            break
        end -- a Lua function
        sName = RB.script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    if RB.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function PRINTMETHOD(printMessage, ...)
    printf(Colors.u .. "[Rebirth Machine]" .. Colors.w .. printMessage .. "\aC\n", ...)
end

function RB.UpdateCurrentClass()
    local currentClass = mq.TLO.Me.Class() -- Get the current class
    if RB.Classes[currentClass] ~= nil then
        RB.Classes[currentClass] = true    -- Mark the class as completed
    end
end

function RB.GetNextClass()
    local availableClasses = {}
    -- Collect all classes that are still false (not completed)
    for class, completed in pairs(RB.Classes) do
        if not completed then
            table.insert(availableClasses, class)
        end
    end

    -- Pick a random class from the remaining available classes
    if #availableClasses > 0 then
        local randomIndex = math.random(1, #availableClasses)
        return availableClasses[randomIndex]
    else
        RB.AllClassesDone = true
        return nil -- No classes left
    end
end

function RB.CheckClass()
    if RB.CurrentRebirths >= RB.Settings.rebirthStopAt then
        if mq.TLO.Zone.ID() ~= RB.Settings.hubZoneID then
            mq.cmdf('/say #zone %s', RB.Settings.hubZoneID)
            mq.delay(RB.zone_Wait, function()
                return mq.TLO.Zone.ID()() == RB.Settings.hubZoneID
            end)
            mq.delay(10000)
        end
        if mq.TLO.Zone.ID() == RB.Settings.hubZoneID then
            if RB.Settings.farmClassAugs and RB.CurrentAugAmount <= RB.Settings.farmClassAugsAmount then
                mq.delay(RB.wait_Three)
                mq.cmdf('/target npc %s', 'Rebirther')
                mq.delay(RB.wait_Three)
                mq.cmd('/squelch /warp t')
                mq.delay(RB.wait_Three)
                mq.cmd('/say confirm reset')
                mq.delay(RB.wait_Three)
                RB.BankDropOff()
                mq.delay(RB.wait_Three)
                RB.Settings.CurrentAugAmount = RB.Settings.CurrentAugAmount + 1
            end
            if RB.Settings.swapClasses then
                if mq.TLO.Zone.ID() ~= RB.Settings.hubZoneID then
                    mq.cmdf('/say #zone %s', RB.Settings.hubZoneID)
                    mq.delay(RB.zone_Wait, function()
                        return mq.TLO.Zone.ID()() == RB.Settings.hubZoneID
                    end)
                    mq.delay(RB.wait_One)
                end

                mq.cmdf('/target npc %s', 'Caitlyn Jenner')
                mq.delay(RB.wait_Three)
                mq.cmd('/warp t')
                mq.delay(RB.wait_Three)
                mq.cmd('/say Yes, I will return to level 1.')
                mq.delay(RB.wait_Three)
                -- Update the current class in the table
                RB.UpdateCurrentClass()

                -- Get the next class to switch to
                RB.nextClass = RB.GetNextClass()
                if RB.nextClass then
                    mq.cmdf('%s', RB.Settings.unequip_Macro)
                    mq.delay(RB.wait_Three)
                    -- Add logic to swap to the next class
                    mq.cmd('/say change class')
                    mq.delay(1000)
                    mq.doevents('ClassSwap')
                    mq.delay(1500)
                    mq.doevents('ClassSwap2')
                    mq.delay(1500)
                    mq.flushevents()
                    mq.delay(RB.wait_CharChange, function()
                        return mq.TLO.EverQuest.GameState()() == 'CHARSELECT'
                    end)
                    mq.delay(RB.wait_AtCharSelect)
                    mq.cmd("/notify CharacterListWnd CLW_Play_Button leftmouseup")
                    mq.delay(RB.zone_Wait, function()
                        return mq.TLO.Zone.ID()() == RB.Settings.hubZoneID
                    end)
                    mq.delay(RB.wait_One)
                    mq.cmdf('%s', RB.Settings.equip_Macro)
                    mq.delay(RB.wait_Three)
                    RB.CurrentRebirths = 0
                end
            end
            if RB.Settings.farmClassAugs and RB.CurrentAugAmount >= RB.Settings.farmClassAugsAmount and not RB.Settings.swapClasses then
                mq.cmdf('/lua stop %s', RB.script_ShortName)
            end
            if RB.Settings.swapClasses and not RB.Settings.farmClassAugs and RB.AllClassesDone then
                mq.cmdf('/lua stop %s', RB.script_ShortName)
            end
            if not RB.Settings.swapClasses and not RB.Settings.farmClassAugs and RB.CurrentRebirths >= RB.Settings.rebirthStopAt then
                mq.cmdf('/lua stop %s', RB.script_ShortName)
            end
        end
    end
end

local function event_classSwap_handler(line, warriorLink, clericLink, paladinLink, rangerLink, shadowknightLink,
                                       druidLink, monkLink, bardLink, rogueLink, shamanLink, necroLink, wizLink, mageLink,
                                       enchanterLink, beastlordLink, berserkerLink)
    if RB.nextClass == 'Warrior' then
        local links = mq.ExtractLinks(warriorLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Cleric' then
        local links = mq.ExtractLinks(clericLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Paladin' then
        local links = mq.ExtractLinks(paladinLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Ranger' then
        local links = mq.ExtractLinks(rangerLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Shadowknight' then
        local links = mq.ExtractLinks(shadowknightLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Druid' then
        local links = mq.ExtractLinks(druidLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Monk' then
        local links = mq.ExtractLinks(monkLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Bard' then
        local links = mq.ExtractLinks(bardLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Rogue' then
        local links = mq.ExtractLinks(rogueLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Shaman' then
        local links = mq.ExtractLinks(shamanLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Necromancer' then
        local links = mq.ExtractLinks(necroLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Wizard' then
        local links = mq.ExtractLinks(wizLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Mage' then
        local links = mq.ExtractLinks(mageLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Enchanter' then
        local links = mq.ExtractLinks(enchanterLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Beastlord' then
        local links = mq.ExtractLinks(beastlordLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    elseif RB.nextClass == 'Berserker' then
        local links = mq.ExtractLinks(berserkerLink)
        for _, link in ipairs(links) do
            mq.ExecuteTextLink(link)
        end
    end
end
mq.event('ClassSwap',
    "Caitlyn Jenner whispers, '#1# || #2# || #3# || #4# || #5# || #6# || #7# || #8# || #9# || #10# || #11# || #12# || #13# || #14# || #15# || #16#'",
    event_classSwap_handler, {
        keepLinks = true
    })
local function event_classSwap2_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        mq.ExecuteTextLink(link)
    end
end
mq.event('ClassSwap2',
    "Caitlyn Jenner whispers, 'You have enough AAs (#*#) to learn all AAs for #*#. Do you wish to proceed?#*#'",
    event_classSwap2_handler, {
        keepLinks = true
    })

local function event_rebirth_handler(line, rebirths)
    CONSOLEMETHOD('function event_rebirth_handler(line, rebirths)')
    RB.CurrentRebirths = tonumber(rebirths)
end
mq.event('RebirthLevel', "#*# whispers, 'You have rebirthed #1# times!'", event_rebirth_handler)
mq.event('RebirthLevel2', "You have rebirthed #1# times!'", event_rebirth_handler)
mq.event('RebirthLevelExp', "Rebirth Penalty: #1# rebirths = #*#", event_rebirth_handler)

local function event_instance_handler(line, minutes)
    CONSOLEMETHOD('function event_instance_handler(line, minutes)')
    local minutesLeft = tonumber(minutes)
    if minutesLeft >= RB.reset_Instance_At then
        if mq.TLO.Zone.ID() ~= RB.Settings.hubZoneID then
            mq.cmdf('/say #zone %s', RB.Settings.hubZoneID)
        end
        mq.delay(RB.zone_Wait, function()
            return mq.TLO.Zone.ID()() == RB.Settings.hubZoneID
        end)
        mq.delay(RB.wait_One)
        mq.cmd('/dzq')
        if mq.TLO.DynamicZone() ~= nil then
            mq.cmd('/dzq')
            mq.delay(RB.wait_One)
            mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
            mq.delay(RB.wait_Two)
            mq.delay(RB.zone_Wait, function()
                return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID
            end)
        else
            mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
            mq.delay(RB.wait_Two)
            mq.delay(RB.zone_Wait, function()
                return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID
            end)
        end
    end
end
mq.event('InstanceCheck', "You only have #1# minutes remaining before this expedition comes to an end.",
    event_instance_handler)

function RB.HandleDisconnect()
    if RB.NewDisconnectHandler then
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

function RB.CheckBuffs()
    RB.HandleDisconnect()
    RB.CheckZone()
    RB.CheckLevel()
    if RB.Settings.useCoinSack and mq.TLO.Me.ItemReady('Bemvaras\' Coin Sack')() then
        mq.cmdf('/useitem %s', 'Bemvaras\' Coin Sack')
        mq.delay(5000, function()
            return mq.TLO.Me.Casting.ID() == 0
        end)
        mq.delay(RB.ItemReuseDelay)
    end
    if RB.Settings.useCurrencyCharm and mq.TLO.FindItem('Soulriever\'s Charm of Currency')() and mq.TLO.Me.ItemReady('Soulriever\'s Charm of Currency')() and not mq.TLO.Me.Buff('Soulriever\'s Currency Doubler')() then
        mq.cmdf('/useitem %s', 'Soulriever\'s Charm of Currency')
        mq.delay(RB.ItemReuseDelay)
    end
    if RB.Settings.usePaladinAA and (mq.TLO.Me.Diseased() or mq.TLO.Me.Cursed()) and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Paladin'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Paladin'])
        mq.delay(RB.ItemReuseDelay)
    end
    if RB.Settings.useBemChest and (mq.TLO.Me.Diseased() or mq.TLO.Me.Cursed()) and mq.TLO.FindItem('Bemvaras\'s Golden Breastplate Rk. I')() and mq.TLO.Me.ItemReady('Bemvaras\'s Golden Breastplate Rk. I')() then
        mq.cmdf('/useitem %s', 'Bemvaras\'s Golden Breastplate Rk. I')
        mq.delay(RB.ItemReuseDelay)
    end
    if RB.Settings.useClericAA and not mq.TLO.Me.Buff('Cleric Mastery - Divine Health')() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Cleric'])() and mq.TLO.SpawnCount(RB.Settings.spawnSearch)() == 0 then
        if not mq.TLO.Me.Casting() and not mq.TLO.Me.Combat() then
            mq.cmdf('/alt act %s', RB.ClassAAs['Cleric'])
            mq.delay(2500, function()
                return mq.TLO.Me.Buff('Cleric Mastery - Divine Health').ID() > 0
            end)
            mq.delay(RB.AAReuseDelay)
        end
    end
    if RB.Settings.useBemLegs and mq.TLO.FindItem('Bemvaras\'s Holy Greaves')() and mq.TLO.Me.ItemReady('Bemvaras\'s Holy Greaves')() and not mq.TLO.Me.Buff('Bemvaras\'s Enhanced Learning')() then
        if mq.TLO.FindItem('Bemvaras\'s Holy Greaves')() and not mq.TLO.Me.Buff('Bemvaras\'s Enhanced Learning')() then
            mq.cmdf('/useitem %s', 'Bemvaras\'s Holy Greaves')
            mq.delay(RB.ItemReuseDelay)
        end
    else
        if RB.Settings.UseExpPotions and mq.TLO.FindItem(RB.Settings.potionName)() and not mq.TLO.Me.Buff('Bemvaras\'s Enhanced Learning')() and not mq.TLO.Me.Buff(RB.Settings.potionBuff)() then
            mq.cmdf('/useitem %s', RB.Settings.potionName)
            mq.delay(RB.ItemReuseDelay)
        end
    end
    if RB.Settings.useBemGloves and mq.TLO.FindItem('Bemvaras\'s Holy Gauntlets')() and mq.TLO.Me.ItemReady('Bemvaras\'s Holy Gauntlets')() and not mq.TLO.Me.Buff('Talisman of Guenhwyvar')() then
        mq.cmdf('/useitem %s', 'Bemvaras\'s Holy Gauntlets')
        mq.delay(RB.ItemReuseDelay)
    end
    if RB.Settings.useBemGloves and mq.TLO.FindItem('Bemvaras\'s Holy Gauntlets')() then
        if RB.Settings.useBuffCharm and mq.TLO.FindItem(RB.Settings.buffCharmName)() and mq.TLO.Me.ItemReady(RB.Settings.buffCharmName)() and not mq.TLO.Me.Buff('Circle of Fireskin')() then
            mq.cmdf('/useitem %s', RB.Settings.buffCharmName)
            mq.delay(RB.ItemReuseDelay)
        end
    else
        if not RB.Settings.useBemGloves and RB.Settings.useBuffCharm and mq.TLO.FindItem(RB.Settings.buffCharmName)() and mq.TLO.Me.ItemReady(RB.Settings.buffCharmName)() and not mq.TLO.Me.Buff(RB.Settings.buffCharmBuffName)() then
            mq.cmdf('/useitem %s', RB.Settings.buffCharmName)
            mq.delay(RB.ItemReuseDelay)
        end
    end
end

function RB.UseClassCombatAAs()
    RB.HandleDisconnect()
    RB.CheckZone()
    RB.CheckLevel()
    if mq.TLO.SpawnCount('npc alert 2')() >= 3 then
        if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Necromancer'])() then
            mq.cmdf('/alt act %s', RB.ClassAAs['Necromancer'])
            mq.delay(RB.AAReuseDelay)
        end
        if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Enchanter'])() then
            mq.cmdf('/alt act %s', RB.ClassAAs['Enchanter'])
            mq.delay(RB.AAReuseDelay)
        end
    end
    if mq.TLO.FindItem('Ertz\'s Mage Stone')() and mq.TLO.Me.ItemReady('Ertz\'s Mage Stone')() then
        mq.cmdf('/useitem %s', 'Ertz\'s Mage Stone')
        mq.delay(RB.AAReuseDelay)
    end
    if not mq.TLO.Me.Buff('Shad\'s Warts').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Shadowknight'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Shadowknight'])
        mq.delay(RB.AAReuseDelay)
    end
    if not mq.TLO.Me.Buff('Mystereon\'s Prismatic Rune').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Wizard'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Wizard'])
        mq.delay(RB.AAReuseDelay)
    end
    if not mq.TLO.Me.Buff('Monk Mastery of A Thousand Fists').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Monk'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Monk'])
        mq.delay(RB.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Shaman'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Shaman'])
        mq.delay(RB.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Necromancer'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Necromancer'])
        mq.delay(RB.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Rogue'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Rogue'])
        mq.delay(RB.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Berserker'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Berserker'])
        mq.delay(RB.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Bard'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Bard'])
        mq.delay(RB.AAReuseDelay)
    end
    if mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Ranger'])() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Ranger'])
        mq.delay(RB.AAReuseDelay)
    end
    RB.CheckBuffs()
end

function RB.CheckLevel()
    RB.HandleDisconnect()
    if mq.TLO.Me.Level() >= 80 then
        mq.delay(RB.wait_Four)
        mq.cmd('/say #rebirth')
        mq.delay(RB.wait_Three)
        mq.doevents()
        mq.delay(RB.wait_Four)
        if mq.TLO.Cursor() then
            mq.cmd('/autoinv')
            mq.delay(RB.wait_Two)
        end
        if RB.Settings.hideCorpses and mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
            mq.cmdf('%s', RB.Settings.corpse_Phrase)
            mq.delay(RB.wait_Four)
        end
        mq.delay(RB.rebirth_Wait)
        mq.cmd('/target npc')
        mq.delay(RB.wait_Four)
        mq.cmd('/squelch /face fast')
        mq.delay(RB.wait_Four)
        if not mq.TLO.Me.Combat() then
            if mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.ID() ~= nil then
                mq.cmd('/target npc')
                mq.delay(RB.wait_One)
            end
            mq.cmd('/squelch /attack on')
            mq.delay(RB.wait_Four)
        end
        mq.delay(RB.wait_Four)
        RB.CheckBuffs()
    end
end

function RB.CheckLocation()
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID and RB.Settings.staticHuntMode then
        pcall(RB.MoveToStaticSpot)
    end
end

function RB.MoveToStaticSpot()
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
        if RB.CheckDistanceToXYZ() > RB.Settings.returnHomeDistance then
            mq.cmdf('/squelch /warp loc %s %s %s', RB.huntZone[RB.Settings.huntZoneName].Y,
                RB.huntZone[RB.Settings.huntZoneName].X, RB.huntZone[RB.Settings.huntZoneName].Z)
            mq.delay(RB.wait_One)
        end
    end
end

function RB.CheckDistanceToXYZ()
    local deltaX = RB.huntZone[RB.Settings.huntZoneName].X - mq.TLO.Me.X()
    local deltaY = RB.huntZone[RB.Settings.huntZoneName].Y - mq.TLO.Me.Y()
    local deltaZ = RB.huntZone[RB.Settings.huntZoneName].Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function RB.CheckZone()
    if RB.CurrentRebirths < RB.Settings.rebirthStopAt then
        local instanceName = string.format('%s_%s_%s', string.upper(mq.TLO.Me.Name()), 'SOLO',
            string.upper(RB.Settings.huntZoneName))
        if mq.TLO.Zone.ID() ~= RB.huntZone[RB.Settings.huntZoneName].ID then
            if mq.TLO.DynamicZone() ~= nil and mq.TLO.DynamicZone() == instanceName then
                mq.cmdf('/say #enter')
                mq.delay(RB.zone_Wait, function()
                    return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID
                end)
                mq.delay(RB.wait_Four)
                if RB.Settings.hideCorpses and mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
                    mq.cmdf('%s', RB.Settings.corpse_Phrase)
                    mq.delay(RB.wait_Four)
                end
                pcall(RB.CheckLocation)
            elseif mq.TLO.DynamicZone() ~= nil and mq.TLO.DynamicZone() ~= instanceName then
                mq.cmd('/dzq')
                mq.delay(RB.wait_One)
                mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
                mq.delay(RB.wait_One)
                mq.delay(RB.zone_Wait, function()
                    return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID
                end)
                mq.delay(RB.wait_Four)
                pcall(RB.CheckLocation)
            elseif mq.TLO.DynamicZone() == nil then
                mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
                mq.delay(RB.wait_One)
                mq.delay(RB.zone_Wait, function()
                    return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID
                end)
                mq.delay(RB.wait_Four)
                pcall(RB.CheckLocation)
            else
                if mq.TLO.Zone.ID() ~= RB.Settings.hubZoneID then
                    mq.cmdf('/say #zone %s', RB.Settings.hubZoneID)
                    mq.delay(RB.zone_Wait, function()
                        return mq.TLO.Zone.ID()() == RB.Settings.hubZoneID
                    end)
                    mq.delay(10000)
                end
            end
        end
    else
        RB.CheckClass()
    end
end

function RB.AggroAllMobs()
    RB.HandleDisconnect()
    RB.CheckLevel()
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
        if mq.TLO.SpawnCount(RB.Settings.spawnSearch)() > 0 then return end
        PRINTMETHOD('++ Attempting to Aggro the Zone ++')
        if RB.Settings.hideCorpses and mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
            mq.cmdf('%s', RB.Settings.corpse_Phrase)
            mq.delay(RB.wait_Four)
        end
        if RB.Settings.moveOnPull and RB.Settings.staticHuntMode then
            mq.cmdf('/squelch /warp loc %s %s %s', RB.huntZone[RB.Settings.huntZoneName].Y,
                RB.huntZone[RB.Settings.huntZoneName].X, RB.huntZone[RB.Settings.huntZoneName].Z)
            mq.delay(RB.wait_One)
        end
        mq.cmd('/target myself')
        mq.delay(RB.wait_Three)
        mq.cmdf('/useitem %s', RB.Settings.zonePull)
        mq.delay(RB.AggroDelay)
        if RB.Settings.moveOnPull and RB.Settings.staticHuntMode then
            mq.cmdf('/squelch /warp loc %s %s %s', RB.huntZone[RB.Settings.huntZoneName].Y_Pull,
                RB.huntZone[RB.Settings.huntZoneName].X, RB.huntZone[RB.Settings.huntZoneName].Z)
            mq.delay(RB.wait_One)
            mq.cmdf('/squelch /face fast %s,%s', RB.huntZone[RB.Settings.huntZoneName].Y,
                RB.huntZone[RB.Settings.huntZoneName].X)
            mq.delay(RB.wait_One)
            mq.cmd('/target npc')
            mq.delay(RB.wait_One)
            if not mq.TLO.Me.Combat() then
                if mq.TLO.Target.ID() == nil or mq.TLO.Target.ID() == mq.TLO.Me.ID() then
                    mq.cmd('/target npc')
                    mq.delay(RB.wait_One)
                end
                mq.cmd('/squelch /attack on')
                mq.delay(RB.wait_One)
            end
        end
    end
end

function RB.RespawnAllMobs()
    RB.HandleDisconnect()
    RB.CheckLevel()
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID and mq.TLO.Me.ItemReady(RB.Settings.zoneRefresh)() and mq.TLO.SpawnCount('npc noalert 1')() < RB.Settings.reset_At_Mob_Count then
        PRINTMETHOD('++ Attempting to Respawn the Zone ++')
        mq.delay(RB.wait_Four)
        mq.cmdf('/useitem %s', RB.Settings.zoneRefresh)
        mq.delay(RB.RepopDelay)
        RB.AggroAllMobs()
        mq.delay(RB.RepopDelay)
        if RB.Settings.hideCorpses and mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
            mq.cmdf('%s', RB.Settings.corpse_Phrase)
            mq.delay(RB.wait_Four)
        end
    end
end

function RB.KillAllMobs()
    RB.HandleDisconnect()
    RB.CheckLevel()
    pcall(RB.RespawnAllMobs)
    if mq.TLO.Me.XTarget() <= RB.Settings.reset_At_Mob_Count and mq.TLO.SpawnCount('npc noalert 1')() >= RB.Settings.reset_At_Mob_Count then
        RB.AggroAllMobs()
    end
    while mq.TLO.SpawnCount(RB.spawnSearch:format('npc ', RB.Settings.aggro_Radius, RB.Settings.aggro_zRadius))() > 0 do
        RB.Checks()
        mq.cmd('/squelch /attack on')
        mq.cmd('/squelch /stick')
        RB.UseClassCombatAAs()
        if mq.TLO.Me.XTarget() <= RB.Settings.reset_At_Mob_Count then
            RB.AggroAllMobs()
            return
        end
        if not mq.TLO.Target.ID() or mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.Distance() > RB.Settings.returnHomeDistance then
            mq.cmd('/target npc')
            mq.delay(RB.wait_Four)
            if mq.TLO.Target.Name() == RB.huntZone[RB.Settings.huntZoneName].ignoreTarget then
                return
            end
            mq.cmd('/squelch /attack on')
            mq.cmd('/squelch /stick')
            RB.UseClassCombatAAs()
        end
        if mq.TLO.Target.Distance() >= RB.Settings.returnHomeDistance then
            mq.cmd('/target clear')
            return
        end
        while mq.TLO.Target.ID() and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() and mq.TLO.Target.Distance() <= RB.Settings.returnHomeDistance and not mq.TLO.Spawn(mq.TLO.Target.ID()).Dead() do
            RB.Checks()
            mq.cmd('/squelch /attack on')
            mq.cmd('/squelch /stick')
            mq.delay(RB.wait_Four)
            mq.cmd('/squelch /face fast')
            mq.delay(RB.wait_Four)
            if not RB.Settings.staticHuntMode then
                RB.MoveTarg()
            end
            RB.UseClassCombatAAs()
            if RB.Settings.castSpells then
                for i, spell in ipairs(RB.Settings.spells) do
                    if mq.TLO.Spell(spell).Name() then
                        mq.cmdf('/casting "%s"', spell)
                        mq.delay(RB.wait_Four)
                    end
                end
                mq.delay(RB.wait_Four)
            end
            mq.delay(RB.wait_Four)
        end
        mq.delay(RB.wait_Four)
    end
end

function RB.Checks()
    pcall(RB.CheckLevel)
    if mq.TLO.Cursor() then
        mq.cmd('/autoinv')
        mq.delay(RB.wait_Two)
    end
    pcall(RB.CheckZone)
    pcall(RB.CheckBuffs)
    mq.doevents()
end

function RB.VersionCheck()
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
            PRINTMETHOD(
                'Your build is too old to run this script. Please get a newer version of MacroQuest from https://www.mq2emu.com')
            mq.cmdf('/lua stop %s', RB.script_ShortName)
            return
        elseif currentVersion[i] > requiredVersion[i] then
            return
        end
    end
end

RB.Open = false
RB.ShowUI = false

RB.outputLog = {}
-- Function to add output to the log with a timestamp
function RB.addToConsole(text, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")

    -- Handle item links correctly by passing through string.format
    local formattedText = string.format(text, ...)

    -- Add the timestamp to the message
    local logEntry = string.format("%s %s", timestamp, formattedText)

    -- Add the combined message with timestamp to the log
    table.insert(RB.outputLog, logEntry)
end

RB.CreateComboBox = {
    flags = 0
}

function RB.CreateComboBox:draw(cb_label, buffs, current_idx, width)
    local combo_buffs = buffs[current_idx] -- Get current selected value

    ImGui.PushItemWidth(width)             -- Limit the width of the combo box
    if ImGui.BeginCombo(cb_label, combo_buffs, ImGuiComboFlags.None) then
        for n = 1, #buffs do
            local is_selected = (current_idx == n)
            if ImGui.Selectable(buffs[n], is_selected) then
                current_idx = n -- Update selected index
            end

            -- Set focus on the selected item when opening the combo box
            if is_selected then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end
    ImGui.PopItemWidth() -- Reset the width
    return current_idx   -- Return the updated index
end

local SWAPCLASSES
local FARMCLASSAUGS
local STATICHUNTMODE
local STATICZONENAME
local STATICZONEID
local STATICX
local STATICY
local STATICZ
local USECOINSACK
local AGGROITEM
local RESPAWNITEM
local MINMOBSINZONE
local BUFFCHARMNAME
local BUFFCHARMBUFFNAME
local CORPSECLEANUP
local CORPSECLEANUPCOMMAND
local CORPSELIMIT
local MOVEONPULL
local classType_idx
function RB.InitGUI()
    if RB.Open then
        RB.Open, RB.ShowUI = ImGui.Begin('TheDroid Rebirth Machine v' .. RB.version, RB.Open)
        local x_size = 427
        local y_size = 280
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.Once)
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 4
        local center_y = io.DisplaySize.y / 4
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 4, center_y - y_size / 4, ImGuiCond.FirstUseEver)
        if RB.ShowUI then
            if ImGui.CollapsingHeader("Rebirth Machine") then
                ImGui.Indent();
                ImGui.Text("This is a simple script I threw together to help out a few friends.")
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText('/' .. RB.command_ShortName .. ' quit');
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
                ImGui.Unindent();
            end
            if ImGui.CollapsingHeader("Rebirth Settings") then
                ImGui.Indent();
                if ImGui.Button('REBUILD##Save File') then
                    RB.SaveSettings(RB.settingsFile, RB.Settings);
                end
                ImGui.SameLine()
                ImGui.Text('Settings File')
                ImGui.SameLine()
                ImGui.HelpMarker('Overwrites the current ' .. RB.settingsFile)
                ImGui.Separator();

                RB.Settings.moveOnPull = ImGui.Checkbox('Enable Move On Pull', RB.Settings.moveOnPull);
                ImGui.SameLine();
                ImGui.HelpMarker('Should we move automatically when we pull away from the mob stack?');
                if MOVEONPULL ~= RB.Settings.moveOnPull then
                    MOVEONPULL = RB.Settings.moveOnPull
                    RB.SaveSettings(RB.settingsFile, RB.Settings);
                end
                ImGui.Separator();

                RB.Settings.swapClasses = ImGui.Checkbox('Enable Swap Classes', RB.Settings.swapClasses);
                ImGui.SameLine();
                ImGui.HelpMarker('Swap classes when we hit rebirth cap?');
                if SWAPCLASSES ~= RB.Settings.swapClasses then
                    SWAPCLASSES = RB.Settings.swapClasses
                    RB.SaveSettings(RB.settingsFile, RB.Settings);
                end
                ImGui.Separator();

                RB.Settings.farmClassAugs = ImGui.Checkbox('Enable Farm Class Augs', RB.Settings.farmClassAugs);
                ImGui.SameLine();
                ImGui.HelpMarker('Should we farm class augs?');
                if FARMCLASSAUGS ~= RB.Settings.farmClassAugs then
                    FARMCLASSAUGS = RB.Settings.farmClassAugs
                    RB.SaveSettings(RB.settingsFile, RB.Settings);
                end
                ImGui.Separator();

                if ImGui.CollapsingHeader("Zone Settings") then
                    ImGui.Indent();
                    RB.Settings.staticHuntMode = ImGui.Checkbox('Enable Static Hunt Mode', RB.Settings.staticHuntMode);
                    ImGui.SameLine();
                    ImGui.HelpMarker('Should we camp a spot and kill or move around?');
                    if STATICHUNTMODE ~= RB.Settings.staticHuntMode then
                        STATICHUNTMODE = RB.Settings.staticHuntMode
                        RB.SaveSettings(RB.settingsFile, RB.Settings);
                    end
                    ImGui.Separator();

                    RB.Settings.huntZoneName = ImGui.InputText('Zone Name', RB.Settings.huntZoneName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The short name of the Static Hunt Zone.')
                    if STATICZONENAME ~= RB.Settings.huntZoneName then
                        STATICZONENAME = RB.Settings.huntZoneName
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.huntZone[RB.Settings.huntZoneName].ID = ImGui.InputInt('Zone ID',
                        RB.huntZone[RB.Settings.huntZoneName].ID)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The ID of the static Hunting Zone.')
                    if STATICZONEID ~= RB.huntZone[RB.Settings.huntZoneName].ID then
                        STATICZONEID = RB.huntZone[RB.Settings.huntZoneName].ID
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    local start_y_Options = ImGui.GetCursorPosY()
                    ImGui.SetCursorPosY(start_y_Options + 3)
                    ImGui.Text('X')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    RB.huntZone[RB.Settings.huntZoneName].X = ImGui.InputInt('##Zone X',
                        RB.huntZone[RB.Settings.huntZoneName].X)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The X loc in the static Hunting Zone to camp.')
                    if STATICX ~= RB.huntZone[RB.Settings.huntZoneName].X then
                        STATICX = RB.huntZone[RB.Settings.huntZoneName].X
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.SameLine();

                    ImGui.SetCursorPosY(start_y_Options + 1)
                    ImGui.Text('Y')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    RB.huntZone[RB.Settings.huntZoneName].Y = ImGui.InputInt('##Zone Y',
                        RB.huntZone[RB.Settings.huntZoneName].Y)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The Y loc in the static Hunting Zone to camp.')
                    if STATICY ~= RB.huntZone[RB.Settings.huntZoneName].Y then
                        STATICY = RB.huntZone[RB.Settings.huntZoneName].Y
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.SameLine();

                    ImGui.SetCursorPosY(start_y_Options + 1)
                    ImGui.Text('Z')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    RB.huntZone[RB.Settings.huntZoneName].Z = ImGui.InputInt('##Zone Z',
                        RB.huntZone[RB.Settings.huntZoneName].Z)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The Z loc in the static Hunting Zone to camp.')
                    if STATICZ ~= RB.huntZone[RB.Settings.huntZoneName].Z then
                        STATICZ = RB.huntZone[RB.Settings.huntZoneName].Z
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Corpse Cleanup") then
                    ImGui.Indent()
                    RB.Settings.hideCorpses = ImGui.Checkbox('Enable Corpse Cleanup',
                        RB.Settings.hideCorpses)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we hide the amount of corpses the client sees?')
                    if CORPSECLEANUP ~= RB.Settings.hideCorpses then
                        CORPSECLEANUP = RB.Settings.hideCorpses
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.corpse_Phrase = ImGui.InputText('Corpse Cleanup Command',
                        RB.Settings.corpse_Phrase)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The phrase we say to hide/remove corpses.')
                    if CORPSECLEANUPCOMMAND ~= RB.Settings.corpse_Phrase then
                        CORPSECLEANUPCOMMAND = RB.Settings.corpse_Phrase
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.corpseLimit = ImGui.InputInt("Corpse Limit", RB.Settings.corpseLimit)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of corpses allowed before we clean them for performance.')
                    if CORPSELIMIT ~= RB.Settings.corpseLimit then
                        CORPSELIMIT = RB.Settings.corpseLimit
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Items") then
                    ImGui.Indent()
                    RB.Settings.useCoinSack = ImGui.Checkbox('Enable Coin Sack', RB.Settings.useCoinSack)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use coin sack for free donator coins??')
                    if USECOINSACK ~= RB.Settings.useCoinSack then
                        USECOINSACK = RB.Settings.useCoinSack
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.zonePull = ImGui.InputText('Aggro Item', RB.Settings.zonePull)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your zone wide aggro item.')
                    if AGGROITEM ~= RB.Settings.zonePull then
                        AGGROITEM = RB.Settings.zonePull
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.zoneRefresh = ImGui.InputText('Respawn Item', RB.Settings.zoneRefresh)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your zone respawn item.')
                    if RESPAWNITEM ~= RB.Settings.zoneRefresh then
                        RESPAWNITEM = RB.Settings.zoneRefresh
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.reset_At_Mob_Count = ImGui.InputInt("Respawn Mobs Limit",
                        RB.Settings.reset_At_Mob_Count)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of mobs allowed before we respawn the zone.')
                    if MINMOBSINZONE ~= RB.Settings.reset_At_Mob_Count then
                        MINMOBSINZONE = RB.Settings.reset_At_Mob_Count
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.buffCharmName = ImGui.InputText('Buff Item', RB.Settings.buffCharmName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your buff item.')
                    if BUFFCHARMNAME ~= RB.Settings.buffCharmName then
                        BUFFCHARMNAME = RB.Settings.buffCharmName
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.buffCharmBuffName = ImGui.InputText('Buff Name',
                        RB.Settings.buffCharmBuffName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name the buff to check if buff item worked.')
                    if BUFFCHARMBUFFNAME ~= RB.Settings.buffCharmBuffName then
                        BUFFCHARMBUFFNAME = RB.Settings.buffCharmBuffName
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Donor Items") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    RB.Settings.useBemChest = ImGui.Checkbox('Enable Bems Chest', RB.Settings
                        .useBemChest)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Bemevaras Breastplate?')
                    if USEBEMCHEST ~= RB.Settings.useBemChest then
                        USEBEMCHEST = RB.Settings.useBemChest
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.useBemGloves = ImGui.Checkbox('Enable Bems Gloves',
                        RB.Settings.useBemGloves)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Bemevaras Gloves?')
                    if USEBEMGLOVES ~= RB.Settings.useBemGloves then
                        USEBEMGLOVES = RB.Settings.useBemGloves
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.useBemLegs = ImGui.Checkbox('Enable Bems Legs', RB.Settings.useBemLegs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Bemevaras Leggings?')
                    if USEBEMLEGS ~= RB.Settings.useBemLegs then
                        USEBEMLEGS = RB.Settings.useBemLegs
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    RB.Settings.useErtzStone = ImGui.Checkbox('Enable Ertz\'s Stone',
                        RB.Settings.useErtzStone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Ertz\'s Mage Stone in combat?')
                    if USEERTZSTONE ~= RB.Settings.useErtzStone then
                        USEERTZSTONE = RB.Settings.useErtzStone
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.useCurrencyCharm = ImGui.Checkbox('Enable Currency Stone',
                        RB.Settings.useCurrencyCharm)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use currency doubler?')
                    if USECURRENCYCHARM ~= RB.Settings.useCurrencyCharm then
                        USECURRENCYCHARM = RB.Settings.useCurrencyCharm
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    ImGui.Columns(1);
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("AAs") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    RB.Settings.useClericAA = ImGui.Checkbox('Enable Cleric AA', RB.Settings.useClericAA)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Enable the use of the Cleric Class AA.')
                    if USECLERICAA ~= RB.Settings.useClericAA then
                        USECLERICAA = RB.Settings.useClericAA
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    RB.Settings.usePaladinAA = ImGui.Checkbox('Enable Paladin AA',
                        RB.Settings.usePaladinAA)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Enable the use of the Paladin Class AA.')
                    if USEPALADINAA ~= RB.Settings.usePaladinAA then
                        USEPALADINAA = RB.Settings.usePaladinAA
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Columns(1);
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Experience Potions") then
                    ImGui.Indent()
                    RB.Settings.useExpPotions = ImGui.Checkbox('Enable Exp Potions',
                        RB.Settings.useExpPotions)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                    if USEEXPPOTIONS ~= RB.Settings.useExpPotions then
                        USEEXPPOTIONS = RB.Settings.useExpPotions
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.potionName = ImGui.InputText('Potion Name', RB.Settings.potionName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the experience potion.')
                    if POTIONNAME ~= RB.Settings.potionName then
                        POTIONNAME = RB.Settings.potionName
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Separator();

                    RB.Settings.potionBuff = ImGui.InputText('Potion Buff', RB.Settings.potionBuff)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the experience buff.')
                    if POTIONBUFF ~= RB.Settings.potionBuff then
                        POTIONBUFF = RB.Settings.potionBuff
                        RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
                    end
                    ImGui.Unindent();
                end
                ImGui.Unindent();
            end
        end
        ImGui.Text("Current Type: " .. RB.Settings.classType);
        ImGui.SameLine(center_y - y_size / 4);
        RB.Settings.classType_idx = RB.CreateComboBox:draw("##Class Type", RB.classType, RB.Settings.classType_idx, 150);
        if classType_idx ~= RB.Settings.classType_idx then
            classType_idx = RB.Settings.classType_idx
            if classType_idx == 1 then
                RB.Settings.classType = 'DPS'
            elseif classType_idx == 2 then
                RB.Settings.classType = 'TANK'
            elseif classType_idx == 3 then
                RB.Settings.classType = 'ALL'
            end
            RB.CheckRebirthType()
            RB.CheckCurrentClassAugs()
            RB.Storage.SaveSettings(RB.settingsFile, RB.Settings)
        end
        ImGui.Separator();
        local textCount = 0
        ImGui.Columns(2)
        local start_y_Options = ImGui.GetCursorPosY()

        -- Collect class names into a list
        local classNames = {}
        for className in pairs(RB.Classes) do
            table.insert(classNames, className)
        end

        -- Sort the class names alphabetically
        table.sort(classNames)

        -- Iterate over the sorted list
        for _, className in ipairs(classNames) do
            local isDone = RB.Classes[className]
            local checkMark = isDone and "Complete" or "Incomplete"
            local color = isDone and { 0, 1, 0, 1 } or { 1, 0, 0, 1 } -- Green for done, red for not
            ImGui.TextColored(color[1], color[2], color[3], color[4], className .. ": " .. checkMark)
            textCount = (textCount or 0) + 1
            if textCount >= 8 then
                ImGui.NextColumn()
                ImGui.SetCursorPosY(start_y_Options)
                textCount = 0
            end
        end

        ImGui.Columns(1)
        ImGui.End()
    end
end

function RB.bankClassAugs()
    if not mq.TLO.Window('BigBankWnd').Open() then
        PRINTMETHOD('Bank window must be open!')
        return
    end
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToBank = bagSlot.Name()
                if string.find(itemToBank, 'Mastery Augmentation') then
                    mq.cmdf('/nomodkey /shiftkey /itemnotify pack%s leftmouseup', i)
                    mq.delay(500, function() return mq.TLO.Cursor() end)
                    mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
                    mq.delay(500, function() return not mq.TLO.Cursor() end)
                end
            end
        end
    end
    -- sell any items in bags which are marked as sell
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j = 1, containerSize do
                local itemToBank = bagSlot.Item(j).Name()
                if itemToBank then
                    if string.find(itemToBank, 'Mastery Augmentation') then
                        mq.cmdf('/nomodkey /shiftkey /itemnotify in pack%s %s leftmouseup', i, j)
                        mq.delay(100, function() return mq.TLO.Cursor() end)
                        mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
                        mq.delay(100, function() return not mq.TLO.Cursor() end)
                    end
                end
            end
        end
    end
end

function RB.BankDropOff()
    RB.HandleDisconnect()
    if mq.TLO.Zone.ID() ~= RB.Settings.bankZone then
        mq.cmdf('/say #zone %s', RB.Settings.bankZone)
        mq.delay(50000, function() return mq.TLO.Zone.ID()() == RB.Settings.bankZone end)
        mq.delay(1000)
    end
    if mq.TLO.Zone.ID() == RB.Settings.bankZone then
        mq.cmdf('/target npc %s', RB.Settings.bankNPC)
        mq.delay(250)
        mq.delay(5000, function() return mq.TLO.Target()() ~= nil end)
        mq.cmd('/squelch /warp t')
        mq.delay(750)
        mq.cmdf('/nomodkey /click right target')
        mq.delay(5000, function() return mq.TLO.Window('BigBankWnd').Open() end)
        mq.delay(50)
        RB.bankClassAugs()
    end
end

function RB.Main()
    RB.VersionCheck()
    mq.imgui.init('RebirthMachine', RB.InitGUI)
    RB.Open = true
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Setting up Ignore List ++')
    mq.cmdf('/squelch /alert clear %s', 1)
    for _, name in ipairs(RB.IgnoreList) do
        mq.cmdf('/squelch /alert add 1 "%s"', name)
        mq.delay(25)
    end
    PRINTMETHOD('++ Sequence: Rebirth Grind Initiated ++')
    CONSOLEMETHOD('Main Loop Entry')
    PRINTMETHOD('Putting MQ2Melee into basic melee mode.')
    mq.cmd('/melee melee=on stickmode=off stickrange=75 save')
    mq.doevents()
    while not RB.Terminate do
        RB.HandleDisconnect()
        RB.Checks()
        pcall(RB.KillAllMobs)
        mq.doevents()
    end
    CONSOLEMETHOD('Main Loop Exit')
end

RB.Main()

return RB
