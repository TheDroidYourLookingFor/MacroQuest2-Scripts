--[[ LootUtils.lua - TheDroidUrLookingFor
This is a port of the RedGuides copy of ninjadvLootUtils.inc with some updates as well.
This is script is a converted NinjaAdvLoot.inc from the early macro days. With many added features. It can be
 added to any project with a simple require.

Example Require:
 DroidLoot.LootUtils = require('DroidLoot.lib.LootUtils')

Examples:
 DroidLoot.LootUtils.lootMobs()
 DroidLoot.LootUtils.sellStuff()
 DroidLoot.LootUtils.bankStuff()
 DroidLoot.LootUtils.navToID(mq.TLO.Target.ID())

]] ---@type Mq
local mq = require 'mq'

local LootUtils = {
    Version = "1.0.23",
    -- _Macro = DroidLoot,
    UseWarp = false,
    AddNewSales = true,
    AddIgnoredItems = true,
    LootForage = true,
    LootTradeSkill = false,
    DoLoot = true,
    EquipUsable = false,     -- Buggy at best
    LootGearUpgrades = true, -- WIP
    CorpseRadius = 5000,
    MobsTooClose = 40,
    AnnounceLoot = false,
    ReportLoot = true,
    ReportSkipped = true,
    LootChannel = "dgt",
    AnnounceChannel = 'dgt',
    SpamLootInfo = false,
    LootForageSpam = false,
    CombatLooting = true,
    LootEvolvingItems = false, -- Buggy on Emulator
    LootPlatinumBags = false,
    LootWildCardItems = true,
    wildCardTerms = { 'Rk. I', 'Empowered', 'Prize: ', 'Transcendent ' },
    LootTokensOfAdvancement = false,
    LootEmpoweredFabled = false,
    LootAllFabledAugs = false,
    EmpoweredFabledName = 'Empowered',
    EmpoweredFabledMinHP = 0,
    StackPlatValue = 0,
    LootByMinHP = 0,
    SaveBagSlots = 3,
    MinSellPrice = 100,
    StackableOnly = false,
    UseSingleFileForAllCharacters = true,
    useZoneLootFile = false,
    useClassLootFile = false,
    useArmorTypeLootFile = false,
    bankDeposit = true,
    sellVendor = true,
    bankAtFreeSlots = 5,
    bankZone = 202,
    bankNPC = 'Banker Granger',
    vendorNPC = 'Jocelyn Forgerson'
}

LootUtils.Messages = require('DroidLoot.lib.Messages')

local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
LootUtils.Settings = {
    Defaults = "Quest|Keep|Ignore|Announce|Destroy|Sell|Fabled|Cash",
    Terminate = true,
    logger = Write,
    LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.ini'
}
function LootUtils.SetINIType()
    if LootUtils.UseSingleFileForAllCharacters then
        LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.ini'
        printf('LootFile: %s', LootUtils.Settings.LootFile)
        return
    end
    local my_ArmorType
    if LootUtils.useArmorTypeLootFile then
        if my_Class == 'Bard' or my_Class == 'Cleric' or my_Class == 'Paladin' or my_Class == 'Shadow Knight' or my_Class == 'Warrior' then
            my_ArmorType = 'Plate'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_ArmorType .. '.ini'
            end
        elseif my_Class == 'Berserker' or my_Class == 'Rogue' or my_Class == 'Shaman' then
            my_ArmorType = 'Chain'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_ArmorType .. '.ini'
            end
        elseif my_Class == 'Enchanter' or my_Class == 'Magician' or my_Class == 'Necromancer' or my_Class == 'Wizard' then
            my_ArmorType = 'Cloth'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_ArmorType .. '.ini'
            end
        elseif my_Class == 'Beastlord' or my_Class == 'Druid' or my_Class == 'Monk' then
            my_ArmorType = 'Leather'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_ArmorType .. '.ini'
            end
        end
    else
        if LootUtils.useZoneLootFile then
            if LootUtils.useClassLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_Class .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_Name .. '.ini'
            end
        else
            if LootUtils.useClassLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_Class .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_Name .. '.ini'
            end
        end
    end
    printf('LootFile: %s', LootUtils.Settings.LootFile)
end

LootUtils.SetINIType()
-- Internal settings
local lootData = {}
local doSell = false
local doCashSell = false
local cantLootList = {}
local cantLootID = 0

-- Constants
local spawnSearch = '%s radius %d zradius 50'
-- If you want destroy to actually loot and destroy items, change Destroy=false to Destroy=true.
-- Otherwise, destroy behaves the same as ignore.
local shouldLootActions = {
    Keep = true,
    Bank = true,
    Sell = true,
    Cash = true,
    Fabled = true,
    Destroy = false,
    Ignore = false,
    Quest = false,
    Announce = true,
    Wildcard = true
}
function LootUtils.CheckLootActions()
    if not LootUtils.LootEmpoweredFabled then
        shouldLootActions['Fabled'] = false
    else
        shouldLootActions['Fabled'] = true
    end
end

local validActions = {
    keep = 'Keep',
    bank = 'Bank',
    sell = 'Sell',
    fabled = 'Fabled',
    cash = 'Cash',
    ignore = 'Ignore',
    destroy = 'Destroy',
    quest = 'Quest',
    announce = 'Announce',
    wildcard = 'Wildcard'
}
local saveOptionTypes = {
    string = 1,
    number = 1,
    boolean = 1
}

-- FORWARD DECLARATIONS

local eventForage, eventSell, eventCantLoot

-- UTILITIES
function LootUtils.ConsoleMessage(messageType, message, ...)
    if messageType == 'Debug' then
        LootUtils.Messages.Debug(message, ...)
    elseif messageType == 'Info' then
        LootUtils.Messages.Info(message, ...)
    elseif messageType == 'Warn' then
        LootUtils.Messages.Warn(message, ...)
    elseif messageType == 'Normal' then
        LootUtils.Messages.Normal(message, ...)
    else
        LootUtils.Messages.Normal(message, ...)
    end
end

function LootUtils.writeSettings()
    for option, value in pairs(LootUtils) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, 'Settings', option, value)
        end
    end
    for asciiValue = 65, 90 do
        local character = string.char(asciiValue)
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, character, 'Defaults', LootUtils.Settings.Defaults)
    end
    if #LootUtils.wildCardTerms then
        mq.cmdf('/ini "%s" "%s" "%s" "%d"', LootUtils.Settings.LootFile, 'wildCardTerms', 'Count', #LootUtils.wildCardTerms)
        for index, term in ipairs(LootUtils.wildCardTerms) do
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, 'wildCardTerms', 'Term' .. index, term)
        end
    end
end

local function split(input, sep)
    if sep == nil then
        sep = "|"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function LootUtils.loadSettings()
    local iniSettings = mq.TLO.Ini.File(LootUtils.Settings.LootFile).Section('Settings')
    local keyCount = iniSettings.Key.Count()
    for i = 1, keyCount do
        local key = iniSettings.Key.KeyAtIndex(i)()
        local value = iniSettings.Key(key).Value()
        if key == 'Version' then
            LootUtils[key] = value
        elseif value == 'true' or value == 'false' then
            LootUtils[key] = value == 'true' and true or false
        elseif tonumber(value) then
            LootUtils[key] = tonumber(value)
        else
            LootUtils[key] = value
        end
    end
    LootUtils.wildCardTerms = {}
    local count = tonumber(mq.TLO.Ini(LootUtils.Settings.LootFile, 'wildCardTerms', 'Count')() or 0)
    if count > 0 then
        for i = 1, count do
            local term = mq.TLO.Ini(LootUtils.Settings.LootFile, 'wildCardTerms', 'Term' .. i)()
            if term then
                table.insert(LootUtils.wildCardTerms, term)
            end
        end
    end
end

local function checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if LootUtils.SpamLootInfo then
                LootUtils.ConsoleMessage('Debug', 'Inventory full, item stuck on cursor')
            end
            mq.cmd('/autoinv')
            return
        end
        currentItem = mq.TLO.Cursor()
        mq.cmd('/autoinv')
        mq.delay(100)
    end
end

local function navToID(spawnID)
    if LootUtils.UseWarp then
        mq.cmdf('/target id %s', spawnID)
        mq.delay(250)
        mq.cmd('/squelch /warp t')
    else
        mq.cmdf('/nav id %d log=off', spawnID)
        mq.delay(50)
        if mq.TLO.Navigation.Active() then
            local startTime = os.time()
            while mq.TLO.Navigation.Active() do
                mq.delay(100)
                if os.difftime(os.time(), startTime) > 5 then
                    break
                end
            end
        end
    end
end

function LootUtils.navToID(spawnID)
    navToID(spawnID)
end

local function addRule(itemName, section, rule)
    if rule == 'Ignore' and not LootUtils.AddIgnoredItems or (not LootUtils.LootEmpoweredFabled and rule == 'Fabled') then
        return
    end
    if not lootData[section] then
        lootData[section] = {}
    end
    lootData[section][itemName] = rule
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, section, itemName, rule)
end

local function lookupIniLootRule(section, key)
    return mq.TLO.Ini.File(LootUtils.Settings.LootFile).Section(section).Key(key).Value()
end

local function getRule(item)
    local itemName = item.Name()
    local itemHP = item.HP()
    local itemLink = item.ItemLink('CLICKABLE')()
    local lootDecision = 'Ignore'
    local tradeskill = item.Tradeskills()
    local sellPrice = item.Value() and item.Value() / 1000 or 0
    local stackable = item.Stackable()
    local firstLetter = itemName:sub(1, 1):upper()
    local stackSize = item.StackSize()
    local noDrop = item.NoDrop()
    local wornSlot = item.WornSlot(1)
    local canUse = item.CanUse()
    local noRent = item.NoRent()
    local evolvingItem = item.Evolving()
    local haveItem = mq.TLO.FindItem(('=%s'):format(itemName))()
    local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(itemName))()
    local itemLore = item.Lore()
    mq.delay(1)

    local slotNames = {
        [0] = "Charm",
        [1] = "Left Ear",
        [2] = "Head",
        [3] = "Face",
        [4] = "Right Ear",
        [5] = "Neck",
        [6] = "Shoulder",
        [7] = "Arms",
        [8] = "Back",
        [9] = "Left Wrist",
        [10] = "Right Wrist",
        [11] = "Ranged",
        [12] = "Hands",
        [13] = "Main Hand",
        [14] = "Off Hand",
        [15] = "Left Finger",
        [16] = "Right Finger",
        [17] = "Chest",
        [18] = "Legs",
        [19] = "Feet",
        [20] = "Waist",
        [21] = "Power Source",
        [22] = "Ammo"
    }

    if LootUtils.EquipUsable and canUse then
        if wornSlot == 1 and mq.TLO.Me.Inventory(wornSlot)() == nil then
            return 'Keep'
        elseif wornSlot == 1 and mq.TLO.Me.Inventory(4)() == nil then
            return 'Keep'
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(wornSlot)() == nil then
            return 'Keep'
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(16)() == nil then
            return 'Keep'
        elseif mq.TLO.Me.Inventory(wornSlot)() == nil then
            return 'Keep'
        end
    end

    local function AnnounceUpgrade(slotNumber, slotName)
        local hpDiff = math.floor(itemHP - mq.TLO.Me.Inventory(slotNumber).HP())
        mq.cmdf('/%s Found: %s (+%s hp - %s)', LootUtils.AnnounceChannel, itemLink, hpDiff, slotName)
        LootUtils.Messages.Warn('Found: %s (+%s hp - %s)', itemLink, hpDiff, slotName)
    end

    if LootUtils.LootGearUpgrades and canUse and itemHP ~= nil and itemHP > 0 then
        if wornSlot == 1 and mq.TLO.Me.Inventory(wornSlot)() ~= nil and mq.TLO.Me.Inventory(wornSlot).HP() > 1 and mq.TLO.Me.Inventory(wornSlot).HP() < itemHP then
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(wornSlot, 'Left Ear')
                    return 'Keep'
                end
            else
                AnnounceUpgrade(wornSlot, 'Left Ear')
                return 'Keep'
            end
        elseif wornSlot == 1 and mq.TLO.Me.Inventory(4)() ~= nil and mq.TLO.Me.Inventory(4).HP() > 1 and mq.TLO.Me.Inventory(4).HP() < itemHP then
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(4, 'Right Ear')
                    return 'Keep'
                end
            else
                AnnounceUpgrade(4, 'Right Ear')
                return 'Keep'
            end
        elseif wornSlot == 9 and mq.TLO.Me.Inventory(wornSlot)() ~= nil and mq.TLO.Me.Inventory(wornSlot).HP() > 1 and mq.TLO.Me.Inventory(wornSlot).HP() < itemHP then
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(wornSlot, 'Left Wrist')
                    return 'Keep'
                end
            else
                AnnounceUpgrade(wornSlot, 'Left Wrist')
                return 'Keep'
            end
        elseif wornSlot == 9 and mq.TLO.Me.Inventory(10)() ~= nil and mq.TLO.Me.Inventory(10).HP() > 1 and mq.TLO.Me.Inventory(10).HP() < itemHP then
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(10, 'Right Wrist')
                    return 'Keep'
                end
            else
                AnnounceUpgrade(10, 'Right Wrist')
                return 'Keep'
            end
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(wornSlot)() ~= nil and mq.TLO.Me.Inventory(wornSlot).HP() > 1 and mq.TLO.Me.Inventory(wornSlot).HP() < itemHP then
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(wornSlot, 'Left Finger')
                    return 'Keep'
                end
            else
                AnnounceUpgrade(wornSlot, 'Left Finger')
                return 'Keep'
            end
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(16)() ~= nil and mq.TLO.Me.Inventory(16).HP() > 1 and mq.TLO.Me.Inventory(16).HP() < itemHP then
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(16, 'Right Finger')
                    return 'Keep'
                end
            else
                AnnounceUpgrade(16, 'Right Finger')
                return 'Keep'
            end
        elseif mq.TLO.Me.Inventory(wornSlot)() ~= nil and mq.TLO.Me.Inventory(wornSlot).HP() > 1 and mq.TLO.Me.Inventory(wornSlot).HP() < itemHP then
            local slotName = slotNames[wornSlot] or "Unknown"
            if itemLore then
                if not haveItem and not haveItemBank then
                    AnnounceUpgrade(wornSlot, slotName)
                    return 'Keep'
                end
            else
                AnnounceUpgrade(wornSlot, slotName)
                return 'Keep'
            end
        end
    end

    lootData[firstLetter] = lootData[firstLetter] or {}
    lootData[firstLetter][itemName] = lootData[firstLetter][itemName] or lookupIniLootRule(firstLetter, itemName)
    if lootData[firstLetter][itemName] == 'NULL' then
        if noDrop and not canUse then
            LootUtils.ConsoleMessage('Debug', 'Ignore because: %s', 'noDrop and not canUse')
            lootDecision = 'Ignore'
        end
        if LootUtils.LootTradeSkill and tradeskill then
            LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'LootTradeSkill')
            lootDecision = 'Bank'
        end
        if sellPrice ~= 0 and sellPrice >= LootUtils.MinSellPrice and not noDrop and not noRent then
            LootUtils.ConsoleMessage('Debug', 'Sell because: %s', 'MinSellPrice')
            lootDecision = 'Sell'
        end
        if not stackable and LootUtils.StackableOnly then
            LootUtils.ConsoleMessage('Debug', 'Ignore because: %s', 'StackableOnly')
            lootDecision = 'Ignore'
        end
        if LootUtils.StackPlatValue > 0 and sellPrice * stackSize >= LootUtils.StackPlatValue and not noDrop and not noRent then
            LootUtils.ConsoleMessage('Debug', 'Sell because: %s', 'StackPlatValue')
            lootDecision = 'Sell'
        end
        if LootUtils.LootEmpoweredFabled and string.find(itemName, LootUtils.EmpoweredFabledName) then
            if LootUtils.EmpoweredFabledMinHP == 0 then
                LootUtils.ConsoleMessage('Debug', 'Fabled because: %s', 'EmpoweredFabledMinHP')
                lootDecision = 'Fabled'
            end
            if LootUtils.EmpoweredFabledMinHP >= 1 and itemHP >= LootUtils.EmpoweredFabledMinHP then
                LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'EmpoweredFabledMinHP')
                lootDecision = 'Bank'
            end
            if LootUtils.EmpoweredFabledMinHP >= 1 and itemHP <= LootUtils.EmpoweredFabledMinHP then
                LootUtils.ConsoleMessage('Debug', 'Fabled because: %s', 'EmpoweredFabledMinHP')
                lootDecision = 'Fabled'
            end
        end
        if LootUtils.LootByMinHP >= 1 and itemHP >= LootUtils.LootByMinHP then
            LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'LootByMinHP')
            lootDecision = 'Keep'
        end
        if LootUtils.LootAllFabledAugs and string.find(itemName, LootUtils.EmpoweredFabledName) and item.AugType() ~= nil and item.AugType() > 0 then
            LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'LootAllFabledAugs')
            lootDecision = 'Bank'
        end
        if LootUtils.LootPlatinumBags and string.find(itemName, 'of Platinum') then
            LootUtils.ConsoleMessage('Debug', 'Sell because: %s', 'LootPlatinumBags')
            lootDecision = 'Sell'
        end
        if LootUtils.LootTokensOfAdvancement and string.find(itemName, 'Token of Advancement') then
            LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'LootTokensOfAdvancement')
            lootDecision = 'Bank'
        end
        if evolvingItem and LootUtils.LootEvolvingItems then
            LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'LootEvolvingItems')
            lootDecision = 'Keep'
        end
        if LootUtils.LootWildCardItems then
            for _, term in ipairs(LootUtils.wildCardTerms) do
                if string.find(itemName, term) then
                    lootDecision = 'Keep'
                    LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'wildCardTerms')
                    break
                end
            end
        end
        addRule(itemName, firstLetter, lootDecision)
    end
    return lootData[firstLetter][itemName]
end

-- EVENTS

local itemNoValue = nil
local function eventNovalue(line, item)
    itemNoValue = item
end
local cashItemNoValue = nil
local function eventCashNovalue(line, item)
    cashItemNoValue = item
end

LootUtils.CorpseFixCounter = 0
LootUtils.LastCorpseFixID = 0
local function event_CantLoot_handler(line)
    LootUtils.Messages.CONSOLEMETHOD(true, 'function event_CantLoot_handler(line)')
    if not mq.TLO.Target() then
        return
    end
    LootUtils.CorpseFixCounter = LootUtils.CorpseFixCounter + 1
    if LootUtils.CorpseFixCounter >= 3 then
        LootUtils.CorpseFixCounter = 0
        mq.cmdf('%s', '/say #corpsefix')
        mq.delay(50)
        LootUtils.Messages.Info('Can\'t loot %s(%s) right now', mq.TLO.Target.CleanName(), mq.TLO.Target.ID())
        if LootUtils.LastCorpseFixID == mq.TLO.Target.ID() then
            cantLootList[mq.TLO.Target.ID()] = os.time()
        end
        LootUtils.LastCorpseFixID = mq.TLO.Target.ID()
    end
end

local function setupEvents()
    mq.event('OutOfRange1', "#*#You are too far away to loot that corpse#*#", event_CantLoot_handler)
    mq.event('OutOfRange2', "#*#Corpse too far away.#*#", event_CantLoot_handler)
    mq.event("CantLoot", "#*#may not loot this corpse#*#", eventCantLoot)
    mq.event("CantLoot2", "#*#You may not loot this corpse at this time.", eventCantLoot)
    mq.event("Sell", "#*#You receive#*# for the #1##*#", eventSell)
    if LootUtils.LootForage then
        mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", eventForage)
        mq.event("Forage", "You have scrounged up #*#", eventForage)
    end
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", eventNovalue)
    mq.event("CashNovalue", "#*#I will not give you any #*# for the #1#.", eventCashNovalue)
end

-- BINDS

local function commandHandler(...)
    local args = { ... }
    if #args == 1 then
        if args[1] == 'sell' and not LootUtils.Settings.Terminate then
            doSell = true
        elseif args[1] == 'cash' and not LootUtils.Settings.Terminate then
            doCashSell = true
        elseif args[1] == 'reload' then
            lootData = {}
            LootUtils.ConsoleMessage('Info', 'Reloaded Loot File')
        elseif args[1] == 'bank' then
            LootUtils.bankStuff()
        elseif args[1] == 'tsbank' then
            LootUtils.markTradeSkillAsBank()
        end
    elseif #args == 2 then
        if validActions[args[1]] and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1, 1), validActions[args[1]])
            LootUtils.ConsoleMessage('Info', "Setting \ay%s\ax to \ay%s\ax", args[2], validActions[args[1]])
        end
    elseif #args == 3 then
        if args[1] == 'quest' and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1, 1), 'Quest|' .. args[3])
            LootUtils.ConsoleMessage('Info', "Setting \ay%s\ax to \ayQuest|%s\ax", args[2], args[3])
        end
    end
end

local function setupBinds()
    mq.bind('/DroidLootUtils', commandHandler)
end

function LootUtils.report(message, ...)
    local timestamp = os.date("[%H:%M:%S]")
    local reportPrefixAnnounce = '/%s \a-t[\ax\ayDroidLoot\ax\a-t]\a-w' .. timestamp .. '\ax '
    local reportPrefixAnnounceGeneric = '/%s ' .. timestamp .. '[DroidLoot] '
    if LootUtils.AnnounceLoot then
        local lootChannelCheck = string.lower(LootUtils.LootChannel)
        if lootChannelCheck == '/g' or lootChannelCheck == '/rs' or lootChannelCheck == '/say' then
            local prefixWithChannel = reportPrefixAnnounceGeneric:format(LootUtils.LootChannel)
            mq.cmdf(prefixWithChannel .. message, ...)
        else
            local prefixWithChannel = reportPrefixAnnounce:format(LootUtils.LootChannel)
            mq.cmdf(prefixWithChannel .. message, ...)
        end
    end
    if LootUtils.ReportLoot then
        LootUtils.Messages.Normal(message, ...)
    end
end

-- LOOTING

function eventCantLoot()
    cantLootList[mq.TLO.Target.ID()] = os.time()
end

---@param index number @The current index we are looking at in loot window, 1-based.
---@param doWhat string @The action to take for the item.
---@param button string @The mouse button to use to loot the item. Currently only leftmouseup implemented.
local function lootItem(index, doWhat, button)
    LootUtils.ConsoleMessage('Debug', 'Enter lootItem')
    local corpseItemID = mq.TLO.Corpse.Item(index).ID()
    local corpseItem = mq.TLO.Corpse.Item(index)
    local itemName = mq.TLO.Corpse.Item(index).Name()
    local ruleAction = doWhat

    if string.find(doWhat, "Quest|") == 1 then
        local lootRule = split(doWhat)
        ruleAction = lootRule[1]       -- what to do with the item
        local ruleAmount = lootRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('=' .. itemName)()

        -- if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= tonumber(ruleAmount)) then return end
        if DroidLoot.debug then
            printf('DoWhat: %s / ruleAction: %s / ruleAmount: %s / currentItemAmount: %s', doWhat, ruleAction, ruleAmount, currentItemAmount)
        end
        if ruleAction == 'Quest' and currentItemAmount >= tonumber(ruleAmount) then
            return
        end
    elseif ruleAction == 'Wildcard' then

    else
        if not shouldLootActions[ruleAction] then
            return
        end
    end

    mq.cmdf('/nomodkey /shift /itemnotify loot%s %s', index, button)
    -- Looting of no drop items is currently disabled with no flag to enable anyways
    mq.delay(5000, function() return mq.TLO.Window('ConfirmationDialogBox').Open() or not mq.TLO.Corpse.Item(index).NoDrop() end)
    if mq.TLO.Window('ConfirmationDialogBox').Open() then
        mq.cmd('/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup')
    end
    mq.delay(5000, function() return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open() end)
    mq.delay(1) -- force next frame
    -- The loot window closes if attempting to loot a lore item you already have, but lore should have already been checked for
    if not mq.TLO.Window('LootWnd').Open() then
        return
    end
    LootUtils.report('Looted: %s[%s]', corpseItem.ItemLink('CLICKABLE')(), doWhat)

    if ruleAction == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then
        mq.cmd('/destroy')
    end
    if mq.TLO.Cursor() then
        checkCursor()
    end
end

function LootUtils.lootCorpse(corpseID)
    LootUtils.ConsoleMessage('Debug', 'Enter lootCorpse')
    mq.cmdf('/target id %s', corpseID)
    mq.delay(100)
    if not mq.TLO.Target() then
        LootUtils.ConsoleMessage('Debug', 'Can\'t loot no target was selected.')
        return
    end
    if not mq.TLO.Target.ID() == corpseID then
        return
    end
    if mq.TLO.Cursor() then
        checkCursor()
    end
    if mq.TLO.Me.FreeInventory() <= LootUtils.SaveBagSlots then
        LootUtils.ConsoleMessage('Warn', 'My bags are full, I can\'t loot anymore!')
    end
    for i = 1, 3 do
        if not mq.TLO.Target() then
            LootUtils.ConsoleMessage('Debug', 'Can\'t loot no target was selected.')
            return
        end
        mq.cmd('/loot')
        mq.delay(1000, function() return mq.TLO.Window('LootWnd').Open() end)
        if mq.TLO.Window('LootWnd').Open() then
            break
        end
    end
    mq.doevents('CantLoot')
    mq.doevents('CantLoot2')
    mq.doevents('OutOfRange1')
    mq.doevents('OutOfRange2')
    if not mq.TLO.Target.ID() == corpseID then
        return
    end
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    mq.delay(playerDelay, function() return mq.TLO.Window('LootWnd').Open() end)
    if not mq.TLO.Window('LootWnd').Open() then
        LootUtils.ConsoleMessage('Debug', 'Can\'t loot %s(%s) right now', mq.TLO.Target.CleanName(), mq.TLO.Target.ID())
        cantLootList[corpseID] = os.time()
        return
    end
    mq.delay(playerDelay, function() return mq.TLO.Corpse.Items() ~= nil end)
    local items = mq.TLO.Corpse.Items() or 0
    LootUtils.ConsoleMessage('Debug', 'Loot window open. Items: %s', items)
    local corpseName = mq.TLO.Corpse.Name()
    if mq.TLO.Window('LootWnd').Open() and items > 0 then
        local noDropItems = {}
        local loreItems = {}
        for i = 1, items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            if corpseItem() then
                local stackable = corpseItem.Stackable()
                local freeStack = corpseItem.FreeStack()
                if freeSpace < LootUtils.SaveBagSlots then
                    if LootUtils.ReportSkipped then
                        LootUtils.report('Skipped Item(Low Bag Space): %s (%s-%s)[%s]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, getRule(corpseItem))
                    end
                end
                if corpseItem.Lore() then
                    local haveItem = mq.TLO.FindItem(('=%s'):format(corpseItem.Name()))()
                    local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(corpseItem.Name()))()
                    if haveItem or haveItemBank or freeSpace <= LootUtils.SaveBagSlots then
                        table.insert(loreItems, corpseItem.ItemLink('CLICKABLE')())
                    else
                        lootItem(i, getRule(corpseItem), 'leftmouseup')
                    end
                elseif freeSpace > LootUtils.SaveBagSlots or (stackable and freeStack > 0) then
                    lootItem(i, getRule(corpseItem), 'leftmouseup')
                end

                local lootAction = getRule(corpseItem)
                if lootAction == 'Ignore' or lootAction == 'NULL' then
                    LootUtils.report('Skipped Item: %s (%s-%s)[%s]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, getRule(corpseItem))
                end
                if lootAction == 'Announce' then
                    LootUtils.report('Found: %s (%s-%s)[%s]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, getRule(corpseItem))
                end
            end
            if not mq.TLO.Window('LootWnd').Open() then
                break
            end
        end
    end
    mq.cmd('/nomodkey /notify LootWnd LW_DoneButton leftmouseup')
    mq.delay(playerDelay, function() return not mq.TLO.Window('LootWnd').Open() end)
    -- if the corpse doesn't poof after looting, there may have been something we weren't able to loot or ignored
    -- mark the corpse as not lootable for a bit so we don't keep trying
    if mq.TLO.Spawn(('corpse id %s'):format(corpseID))() then
        cantLootList[corpseID] = os.time()
    end
end

local function corpseLocked(corpseID)
    if not cantLootList[corpseID] then
        return false
    end
    if os.difftime(os.time(), cantLootList[corpseID]) > 60 then
        cantLootList[corpseID] = nil
        return false
    end
    return true
end

function LootUtils.lootMobs(limit)
    LootUtils.ConsoleMessage('Debug', 'Enter lootMobs')
    local deadCount = mq.TLO.SpawnCount(spawnSearch:format('npccorpse', LootUtils.CorpseRadius))()
    LootUtils.ConsoleMessage('Debug', 'There are %s corpses in range.', deadCount)
    local mobsNearby = mq.TLO.SpawnCount(spawnSearch:format('xtarhater', LootUtils.MobsTooClose))()
    -- options for combat looting or looting disabled
    if deadCount == 0 or ((mobsNearby > 0 or mq.TLO.Me.Combat()) and not LootUtils.CombatLooting) then
        return false
    end
    local corpseList = {}
    for i = 1, math.max(deadCount, limit or 0) do
        local corpse = mq.TLO.NearestSpawn(('%d,' .. spawnSearch):format(i, 'npccorpse', LootUtils.CorpseRadius))
        table.insert(corpseList, corpse)
    end
    local didLoot = false
    LootUtils.ConsoleMessage('Debug', 'Trying to loot %d corpses.', #corpseList)
    for i = 1, #corpseList do
        local corpse = corpseList[i]
        local corpseID = corpse.ID()
        if corpseID and corpseID > 0 and not corpseLocked(corpseID) and (mq.TLO.Navigation.PathLength('spawn id ' .. tostring(corpseID))() or 100) < 60 then
            LootUtils.ConsoleMessage('Debug', 'Moving to corpse ID=%s', tostring(corpseID))
            navToID(corpseID)
            corpse.DoTarget()
            mq.delay(100)
            LootUtils.lootCorpse(corpseID)
            didLoot = true
            mq.doevents('InventoryFull')
        end
    end
    LootUtils.ConsoleMessage('Debug', 'Done with corpse list.')
    return didLoot
end

-- SELLING

function eventSell(line, itemName)
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Sell' then
        return
    end
    if lookupIniLootRule(firstLetter, itemName) == 'Sell' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Sell'
        return
    end
    if LootUtils.AddNewSales then
        LootUtils.ConsoleMessage('Info', 'Setting %s to Sell', itemName)
        if not lootData[firstLetter] then
            lootData[firstLetter] = {}
        end
        lootData[firstLetter][itemName] = 'Sell'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, firstLetter, itemName, 'Sell')
    end
end

local function goToVendor()
    if not mq.TLO.Target() then
        LootUtils.ConsoleMessage('Warn', 'Please target a vendor')
        return false
    end
    local vendorName = mq.TLO.Target.CleanName()

    LootUtils.ConsoleMessage('Info', 'Doing business with %s', vendorName)
    if mq.TLO.Target.Distance() > 15 then
        if LootUtils.UseWarp then
            mq.cmdf('%s', '/warp t')
            local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
            local playerDelay = 500 + playerPing
            mq.delay(playerDelay)
        else
            navToID(mq.TLO.Target.ID())
        end
    end
    return true
end

local function openVendor(vendorType)
    LootUtils.ConsoleMessage('Debug', 'Opening merchant window')
    mq.cmd('/nomodkey /click right target')
    LootUtils.ConsoleMessage('Debug', 'Waiting for merchant window to populate')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    mq.delay(playerDelay, function() return mq.TLO.Window(vendorType).Open() end)
    if not mq.TLO.Window(vendorType).Open() then
        return false
    end
    playerDelay = 5000 + playerPing
    mq.delay(playerDelay, function() return mq.TLO.Merchant.ItemsReceived() end)
    return mq.TLO.Merchant.ItemsReceived()
end

local NEVER_SELL = {
    ['Diamond Coin'] = true,
    ['Celestial Crest'] = true,
    ['Gold Coin'] = true,
    ['Taelosian Symbols'] = true,
    ['Planar Symbols'] = true,
    ['Gemstone of the Ages'] = true,
    ['Lesser Rainbow Crystal'] = true,
    ['Flawless Rainbow Crystal'] = true,
    ['Greater Rainbow Crystal'] = true,
    ['Minor Rainbow Crystal'] = true,
    ['Major Rainbow Crystal'] = true,
    ['Supreme Rainbow Crystal'] = true
}
local function sellToVendor(itemToSell)
    if NEVER_SELL[itemToSell] then
        return
    end
    local itemLink = itemToSell.ItemLink('CLICKABLE')()
    while mq.TLO.FindItemCount('=' .. itemToSell)() > 0 do
        if mq.TLO.Window('MerchantWnd').Open() then
            LootUtils.ConsoleMessage('Info', 'Selling %s', itemLink)
            mq.cmdf('/nomodkey /itemnotify "%s" leftmouseup', itemToSell)
            local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
            local playerDelay = 1000 + playerPing
            mq.delay(playerDelay, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
            mq.cmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
            mq.doevents('eventNovalue')
            if itemNoValue == itemToSell then
                addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
                itemNoValue = nil
                break
            end
            -- TODO: handle vendor not wanting item / item can't be sold
            mq.delay(playerDelay, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
        end
    end
end
local function sellBagItemToVendor(itemToSell, itemBag, itemBagSlot)
    if NEVER_SELL[itemToSell] then
        return
    end
    local sellItem = mq.TLO.FindItem('=' .. itemToSell)
    local itemLink = sellItem.ItemLink('CLICKABLE')()
    if mq.TLO.Window('MerchantWnd').Open() then
        LootUtils.ConsoleMessage('Info', 'Selling %s', itemLink)
        mq.cmdf('/nomodkey /itemnotify in pack%s %s leftmouseup', itemBag, itemBagSlot)
        local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
        local playerDelay = 1000 + playerPing
        mq.delay(playerDelay, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
        mq.cmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
        mq.doevents('eventNovalue')
        if itemNoValue == itemToSell then
            addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
            itemNoValue = nil
            return
        end
        -- TODO: handle vendor not wanting item / item can't be sold
        mq.delay(playerDelay, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
    end
end

function LootUtils.sellStuff(closeWindowWhenDone)
    if not mq.TLO.Window('MerchantWnd').Open() then
        if not goToVendor() then
            return
        end
        if not openVendor('MerchantWnd') then
            return
        end
    end

    local totalPlat = mq.TLO.Me.Platinum()
    -- sell any top level inventory items that are marked as well, which aren't bags
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToSell = bagSlot.Name()
                local sellRule = getRule(bagSlot)
                if sellRule == 'Sell' then
                    sellToVendor(itemToSell)
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
                local itemToSell = bagSlot.Item(j)
                if itemToSell.Name() then
                    local sellRule = getRule(bagSlot.Item(j))
                    if sellRule == 'Sell' or sellRule == 'NULL' then
                        local sellPrice = bagSlot.Item(j).Value() and bagSlot.Item(j).Value() / 1000 or 0
                        if sellPrice == 0 then
                            LootUtils.ConsoleMessage('Info', 'Item \ay%s\ax is set to Sell but has no sell value!', itemToSell.Name())
                        else
                            sellBagItemToVendor(itemToSell.Name(), i, j)
                        end
                    end
                end
            end
        end
    end
    mq.flushevents('Sell')
    if mq.TLO.Window('MerchantWnd').Open() and closeWindowWhenDone then
        mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
    end
    local newTotalPlat = mq.TLO.Me.Platinum() - totalPlat
    LootUtils.ConsoleMessage('Info', 'Total plat value sold: \ag%s\ax', newTotalPlat)
end

local function sellCashItemsToVendor(itemToSell)
    if NEVER_SELL[itemToSell] then
        return
    end
    if mq.TLO.Window('NewPointMerchantWnd').Open() then
        if mq.TLO.SelectedItem() ~= nil and mq.TLO.SelectedItem.Name() == itemToSell then
            LootUtils.ConsoleMessage('Info', 'Selling %s', mq.TLO.SelectedItem.ItemLink('CLICKABLE')())
            local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
            local playerDelay = 100 + playerPing
            mq.delay(playerDelay)
            mq.cmd('/nomodkey /shiftkey /notify NewPointMerchantWnd NewPointMerchant_SellButton leftmouseup')
            mq.doevents('eventNovalue')
            if cashItemNoValue == itemToSell then
                -- addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
                cashItemNoValue = nil
            end
            -- TODO: handle vendor not wanting item / item can't be sold
            playerDelay = 1000 + playerPing
            mq.delay(playerDelay, function() return not mq.TLO.SelectedItem.Name() end)
        end
    end
end

function LootUtils.sellCashItems(closeWindowWhenDone)
    if not mq.TLO.Window('NewPointMerchantWnd').Open() then
        if not goToVendor() then
            return
        end
        if not openVendor('NewPointMerchantWnd') then
            return
        end
    end

    local totalCash = mq.TLO.Me.AltCurrency('Cash')()
    -- sell any top level inventory items that are marked as well, which aren't bags
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToSell = bagSlot.Name()
                local sellRule = getRule(bagSlot)
                if sellRule == 'Cash' then
                    sellCashItemsToVendor(itemToSell)
                end
            end
        end
    end

    mq.cmd('/keypress OPEN_INV_BAGS')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 250 + playerPing
    mq.delay(playerDelay)
    -- sell any items in bags which are marked as sell
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j = 1, containerSize do
                local itemToSell = bagSlot.Item(j).Name()
                if itemToSell then
                    local sellRule = getRule(bagSlot.Item(j))
                    if sellRule == 'Cash' then
                        mq.cmdf('/nomodkey /itemnotify in pack%s %s leftmouseup', i, j)
                        playerDelay = 500 + playerPing
                        mq.delay(playerDelay, function() return mq.TLO.SelectedItem.Name() ~= nil end)
                        sellCashItemsToVendor(itemToSell)
                    end
                end
            end
        end
    end
    mq.cmd('/keypress CLOSE_INV_BAGS')
    mq.delay(playerDelay)

    mq.flushevents('Sell')
    if mq.TLO.Window('NewPointMerchantWnd').Open() and closeWindowWhenDone then
        mq.cmd('/nomodkey /notify NewPointMerchantWnd NewPointMerchant_DoneButton leftmouseup')
    end
    local newTotalCash = mq.TLO.Me.AltCurrency('Cash')() - totalCash
    LootUtils.ConsoleMessage('Info', 'Total cash value sold: \ag%s\ax', newTotalCash)
end

-- BANKING

function LootUtils.markTradeSkillAsBank()
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                if bagSlot.Tradeskills() then
                    local itemToMark = bagSlot.Name()
                    addRule(itemToMark, itemToMark:sub(1, 1), 'Bank')
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
                local item = bagSlot.Item(j)
                if item.ID() and item.Tradeskills() then
                    local itemToMark = bagSlot.Item(j).Name()
                    addRule(itemToMark, itemToMark:sub(1, 1), 'Bank')
                end
            end
        end
    end
end

function LootUtils.bankStuff()
    if not mq.TLO.Window('BigBankWnd').Open() then
        LootUtils.ConsoleMessage('Warn', 'Bank window must be open!')
        return
    end
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 100 + playerPing
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local bankRule = getRule(bagSlot)
                if bankRule == 'Bank' then
                    mq.cmdf('/nomodkey /shiftkey /itemnotify pack%s leftmouseup', i)
                    mq.delay(playerDelay, function() return mq.TLO.Cursor() end)
                    mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
                    mq.delay(playerDelay, function() return not mq.TLO.Cursor() end)
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
                    local bankRule = getRule(bagSlot.Item(j))
                    if bankRule == 'Bank' then
                        mq.cmdf('/nomodkey /shiftkey /itemnotify in pack%s %s leftmouseup', i, j)
                        mq.delay(playerDelay, function() return mq.TLO.Cursor() end)
                        mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
                        mq.delay(playerDelay, function() return not mq.TLO.Cursor() end)
                    end
                end
            end
        end
    end
end

-- FORAGING

function eventForage()
    LootUtils.ConsoleMessage('Debug', 'Enter eventForage')
    -- allow time for item to be on cursor incase message is faster or something?
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    mq.delay(playerDelay, function()
        return mq.TLO.Cursor()
    end)
    -- there may be more than one item on cursor so go until its cleared
    while mq.TLO.Cursor() do
        local cursorItem = mq.TLO.Cursor
        local foragedItem = cursorItem.Name()
        local forageRule = split(getRule(cursorItem))
        local ruleAction = forageRule[1] -- what to do with the item
        local ruleAmount = forageRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('=' .. foragedItem)()
        -- >= because .. does finditemcount not count the item on the cursor?
        if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= ruleAmount) then
            if mq.TLO.Cursor.Name() == foragedItem then
                if LootUtils.LootForageSpam then
                    LootUtils.ConsoleMessage('Info', 'Destroying foraged item %s', foragedItem)
                end
                mq.cmd('/destroy')
                playerDelay = 500 + playerPing
                mq.delay(playerDelay)
            end
            -- will a lore item we already have even show up on cursor?
            -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if LootUtils.LootForageSpam then
                LootUtils.ConsoleMessage('Info', 'Keeping foraged item %s', foragedItem)
            end
            mq.cmd('/autoinv')
        else
            if LootUtils.LootForageSpam then
                LootUtils.ConsoleMessage('Info', 'Unable to process item %s', foragedItem)
            end
            break
        end
        mq.delay(50)
    end
end

--

local function processArgs(args)
    if #args == 1 then
        if args[1] == 'Sell' then
            LootUtils.sellStuff(false)
        elseif args[1] == 'fabled' then
            -- LootUtils.sellCashItems(false)
        elseif args[1] == 'cash' then
            LootUtils.sellCashItems(false)
        elseif args[1] == 'once' then
            LootUtils.lootMobs()
        elseif args[1] == 'standalone' then
            LootUtils.Settings.Terminate = false
        end
    end
end

local function init(args)
    local iniFile = mq.TLO.Ini.File(LootUtils.Settings.LootFile)
    if not iniFile.Exists() then
        LootUtils.writeSettings()
    elseif iniFile.Exists() and not iniFile.Section('Settings').Exists() then
        LootUtils.writeSettings()
    elseif iniFile.Exists() and iniFile.Section('Settings').Key('Version').Value() ~= LootUtils.Version then
        LootUtils.writeSettings()
    else
        LootUtils.loadSettings()
    end

    setupEvents()
    setupBinds()
    processArgs(args)
end

init({ ... })

while not LootUtils.Settings.Terminate do
    if LootUtils.DoLoot then
        LootUtils.lootMobs()
    end
    if doSell then
        LootUtils.sellStuff(false)
        doSell = false
    end
    if doCashSell then
        LootUtils.sellCashItems(false)
        doCashSell = false
    end
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    mq.delay(playerDelay)
end

return LootUtils
