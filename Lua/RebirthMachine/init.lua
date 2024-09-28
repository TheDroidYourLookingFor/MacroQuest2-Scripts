local mq = require('mq')

--
-- Dont edit these settings
--
local RB = {
    version = '1.0.3',
    script_ShortName = 'RebirthMachine',
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
}

--
-- Edit these settings
--
RB.Settings = {
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
    -- corpse_Phrase = '/hidecorpse all',           -- The commands we should use to hide corpses.
    castSpells = false,                   -- Should we cast spells?
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
    spawnSearch = 'npc radius 60 los targetable noalert 1'
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
RB.UseClassAA = {
    Bard = true,
    Beastlord = true,
    Berserker = true,
    Cleric = true,
    Druid = true,
    Enchanter = true,
    Magician = true,
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

RB.RebirthType = {
    DPS = { 'Bard', 'Beastlord', 'Berserker', 'Cleric', 'Druid', 'Enchanter', 'Magician', 'Monk', 'Necromancer', 'Ranger', 'Rogue', 'Shaman', 'Wizard' },
    TANK = { 'Paladin', 'Shadowknight', 'Warrior' }
}

RB.Classes = {
    Bard = true,
    Beastlord = true,
    Berserker = true,
    Cleric = true,
    Druid = true,
    Enchanter = true,
    Magician = true,
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

mq.TLO.EverQuest.LoginName()
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
            if RB.Settings.swapClasses and not RB.Settings.farmClassAugs and RB.CurrentRebirths >= RB.Settings.rebirthStopAt and RB.AllClassesDone then
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
    elseif RB.nextClass == 'Magician' then
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
            RB.Messages.Normal(
                'Your build is too old to run this script. Please get a newer version of MacroQuest from https://www.mq2emu.com')
            mq.cmdf('/lua stop %s', RB.script_ShortName)
            return
        elseif currentVersion[i] > requiredVersion[i] then
            return
        end
    end
end

function RB.Main()
    RB.VersionCheck()
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Setting up Ignore List ++')
    mq.cmdf('/squelch /alert clear %s', 1)
    for _, name in ipairs(RB.IgnoreList) do
        mq.cmdf('/squelch /alert add 1 "%s"', name)
        mq.delay(25)
    end
    PRINTMETHOD('++ Sequence: Unlimted Grind Initiated ++')
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
