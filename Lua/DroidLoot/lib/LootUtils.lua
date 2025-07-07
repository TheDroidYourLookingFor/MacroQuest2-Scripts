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
    Version = "1.0.28",
    -- _Macro = DroidLoot,
    UseWarp = false,
    AddNewSales = true,
    AddIgnoredItems = true,
    LootForage = true,
    LootTradeSkill = false,
    DoLoot = true,
    LootByAugSlots = true,
    LootByAugSlotsAmount = 3,
    LootByAugSlotsTypeIndex = 1,
    LootByAugSlotsType = 'Weapon', -- Any, Armor, Weapon, NonVis
    LootByDamage = true,
    LootByDamageAmount = 240,
    EquipUsable = false,     -- Buggy at best
    LootGearUpgrades = true, -- WIP
    CorpseRadius = 250,
    MobsTooClose = 40,
    AnnounceLoot = false,
    AnnounceUpgrades = true,
    ReportLoot = false,
    ReportSkipped = true,
    LootChannel = "dgt",
    AnnounceChannel = 'dgt',
    SpamLootInfo = false,
    LootForageSpam = false,
    CombatLooting = true,
    LootEvolvingItems = false, -- Buggy on Emulator
    LootPlatinumBags = false,
    LootWildCardItems = false,
    wildCardTerms = { 'Rk. I', 'Empowered', 'Transcendent', 'Rough Consigned' },
    LootTokensOfAdvancement = false,
    LootEmpoweredFabled = false,
    LootAllFabledAugs = false,
    EmpoweredFabledName = 'Empowered',
    EmpoweredFabledMinHP = 0,
    StackPlatValue = 0,
    LootByMinHP = 0,
    LootByMinHPNoDrop = false,
    SaveBagSlots = 3,
    MinSellPrice = 100000,
    StackableOnly = false,
    UseSingleFileForAllCharacters = false,
    UseServerLootFile = true,
    useZoneLootFile = false,
    useClassLootFile = false,
    useArmorTypeLootFile = false,
    bankDeposit = true,
    sellVendor = true,
    bankAtFreeSlots = 5,
    bankZone = 202,
    bankNPC = 'Banker Granger',
    vendorNPC = 'Jocelyn Forgerson',
    returnToCampDistance = 200,
    camp_Check = false,
    zone_Check = true,
    lootGroundSpawns = false,
    returnHomeAfterLoot = true,
    staticHunt = false,
    staticZoneID = '173',
    staticZoneName = 'maiden',
    staticX = '1905',
    staticY = '940',
    staticZ = '-151.74',
    health_Check = true,
    heal_Spell = 'Daria\'s Mending Rk. III',
    heal_Gem = 1,
    heal_At = 50,
}
LootUtils.Messages = require('DroidLoot.lib.Messages')
LootUtils.Storage = require('DroidLoot.lib.Storage')

local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
LootUtils.Settings = {
    Defaults = "Quest|Keep|Ignore|Announce|Destroy|Sell|Fabled|Cash",
    Terminate = true,
    logger = Write,
    LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.ini',
    command_ShortName = 'dlu',
    command_LongName = 'droidlootutils',
    Debug = false,
}

LootUtils.Settings.optionsShowGUI = false
LootUtils.Settings.optionsOpenGUI = true
LootUtils.Settings.lootShowGUI = false
LootUtils.Settings.lootOpenGUI = true
LootUtils.Settings.logTypes = {
    "full", "keep", "bank", "sell", "fabled", "cash", "ignore",
    "destroy", "quest", "announce", "wildcard", "skipped",
    "upgrade", "debug", "warn", "info"
}

LootUtils.Settings.logShowGUI = false
LootUtils.Settings.logOpenGUI = true
LootUtils.Settings.logAutoScroll = true
LootUtils.Settings.logFilterText = ''

LootUtils.console = nil
LootUtils.Settings.logShow2GUI = false
LootUtils.Settings.logOpen2GUI = true
LootUtils.Settings.log2AutoScroll = true
LootUtils.ConsoleByType = LootUtils.ConsoleByType or {}
LootUtils.MessageLogs = LootUtils.MessageLogs or {}

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
local function setupConsoles()
    if LootUtils.console == nil then
        LootUtils.console = ImGui.ConsoleWidget.new("Loot_imported##Imported_Console")
    end

    for _, logType in ipairs(LootUtils.Settings.logTypes) do
        local key = "console" .. logType
        if LootUtils[key] == nil then
            LootUtils[key] = ImGui.ConsoleWidget.new(logType .. "##Imported_Console")
        end
    end
end
setupConsoles()

LootUtils.MessageLogs = {
    full = {},
    keep = {},
    bank = {},
    sell = {},
    fabled = {},
    cash = {},
    ignore = {},
    destroy = {},
    quest = {},
    announce = {},
    wildcard = {},
    skipped = {},
    upgrade = {},
    debug = {},
    warn = {},
    info = {}
}

function LootUtils.getMessagesByType(messageType)
    return LootUtils.MessageLogs[string.lower(messageType)] or {}
end

function LootUtils.report(message, ...)
    local timestamp = os.date("[%H:%M:%S]")
    local reportPrefixAnnounce = '/%s \a-t[\ax\ayDroidLoot\ax\a-t]\a-w' .. timestamp .. '\ax '
    local reportPrefixAnnounceGeneric = '/%s ' .. timestamp .. '[DroidLoot] '
    local consolePrefix = '\a-t[\ax\ayDroidLoot\ax\a-t]\a-w' .. timestamp .. '\ax '
    local lootChannelCheck = string.lower(LootUtils.LootChannel)
    if lootChannelCheck == 'g' or lootChannelCheck == 'rs' or lootChannelCheck == 'say' then
        local prefixWithChannel = reportPrefixAnnounceGeneric:format(LootUtils.LootChannel)
        mq.cmdf(prefixWithChannel .. message, ...)
    else
        local prefixWithChannel = reportPrefixAnnounce:format(LootUtils.LootChannel)
        mq.cmdf(prefixWithChannel .. message, ...)
    end
end

function LootUtils.logReport(messageType, message, ...)
    local timestamp = os.date("[%H:%M:%S]")
    local consolePrefix = '\a-t[\ax\ayDroidLoot\ax\a-t]\a-w' .. timestamp .. '\ax '
    local cleanMsg = string.format(consolePrefix .. message, ...)
    local msgType = string.lower(messageType)

    if LootUtils.ReportLoot then
        LootUtils.Messages.Normal(message, ...)
    end

    -- Always send to full console unless the type is explicitly 'full'
    if msgType ~= 'full' then
        LootUtils.consolefull:AppendText(cleanMsg)
    else
        LootUtils.consolefull:AppendText(cleanMsg)
    end

    -- Mapping message types to their consoles and optional report flags
    local consoleMap = {
        keep     = { console = LootUtils.consolekeep, reportFlag = "AnnounceLoot" },
        bank     = { console = LootUtils.consolebank },
        sell     = { console = LootUtils.consolesell },
        fabled   = { console = LootUtils.consolefabled },
        cash     = { console = LootUtils.consolecash },
        ignore   = { console = LootUtils.consoleignore },
        destroy  = { console = LootUtils.consoledestroy },
        quest    = { console = LootUtils.consolequest },
        announce = { console = LootUtils.consoleannounce },
        wildcard = { console = LootUtils.consolewildcard },
        skipped  = { console = LootUtils.consoleskipped, reportFlag = "ReportSkipped" },
        upgrade  = { console = LootUtils.consoleupgrade, reportFlag = "AnnounceUpgrades" },
        debug    = { console = LootUtils.consoledebug },
        info     = { console = LootUtils.consoleinfo },
        warn     = { console = LootUtils.consolewarn },
    }

    local entry = consoleMap[msgType]
    if entry then
        entry.console:AppendText(cleanMsg)
        if entry.reportFlag and LootUtils[entry.reportFlag] then
            LootUtils.report(message, ...)
        end
    end
end

function LootUtils.ConsoleMessage(messageType, message, ...)
    local timestamp = os.date("[%H:%M:%S]")
    local consolePrefix = '\a-t[\ax\ayDroidLoot\ax\a-t]\a-w' .. timestamp .. '\ax '
    local cleanMsg = string.format(consolePrefix .. message, ...)
    if messageType == 'Debug' then
        LootUtils.Messages.Debug(message, ...)
        LootUtils.consoledebug:AppendText(cleanMsg)
    elseif messageType == 'Info' then
        LootUtils.Messages.Info(message, ...)
        LootUtils.consoleinfo:AppendText(cleanMsg)
    elseif messageType == 'Warn' then
        LootUtils.Messages.Warn(message, ...)
        LootUtils.consolewarn:AppendText(cleanMsg)
    elseif messageType == 'Normal' then
        LootUtils.Messages.Normal(message, ...)
        LootUtils.consolefull:AppendText(cleanMsg)
    else
        LootUtils.Messages.Normal(message, ...)
        LootUtils.consolefull:AppendText(cleanMsg)
    end
end

function LootUtils.SetINIType()
    if LootUtils.UseSingleFileForAllCharacters then
        LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.ini'
        LootUtils.ConsoleMessage('Debug', 'LootFile: %s', LootUtils.Settings.LootFile)
        LootUtils.ConsoleMessage('Normal', '++ \agDROID LOOT UTILS STARTED\aw ++')
        LootUtils.ConsoleMessage('Normal', '++ \ag %s \aw ++', LootUtils.Settings.LootFile)
        return
    end
    if LootUtils.UseServerLootFile then
        local my_Server = mq.TLO.EverQuest.Server() or ''
        LootUtils.Settings.LootFile = mq.configDir .. '\\DroidLoot\\DroidLoot.' .. my_Server .. '.ini'
        LootUtils.ConsoleMessage('Debug', 'LootFile: %s', LootUtils.Settings.LootFile)
        LootUtils.ConsoleMessage('Normal', '++ \agDROID LOOT UTILS STARTED\aw ++')
        LootUtils.ConsoleMessage('Normal', '++ \ag %s \aw ++', LootUtils.Settings.LootFile)
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
    LootUtils.ConsoleMessage('Debug', 'LootFile: %s', LootUtils.Settings.LootFile)
    LootUtils.ConsoleMessage('Normal', '++ \agDROID LOOT UTILS STARTED\aw ++')
    LootUtils.ConsoleMessage('Normal', '++ \agINI: %s \aw ++', LootUtils.Settings.LootFile)
end

LootUtils.SetINIType()

function LootUtils.saveSetting(fileName, categoryName, itemName, itemValue)
    LootUtils.Storage.SetINIValue(fileName, categoryName, itemName, itemValue)
end

function LootUtils.writeSettings()
    for option, value in pairs(LootUtils) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', option, value)
        end
    end
    for asciiValue = 65, 90 do
        local character = string.char(asciiValue)
        LootUtils.saveSetting(LootUtils.Settings.LootFile, character, 'Defaults', LootUtils.Settings.Defaults)
    end
    LootUtils.saveWildCardTerms()
end

function LootUtils.saveWildCardTerms()
    if #LootUtils.wildCardTerms then
        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'wildCardTerms', 'Count', #LootUtils.wildCardTerms)
        for index, term in ipairs(LootUtils.wildCardTerms) do
            LootUtils.saveSetting(LootUtils.Settings.LootFile, 'wildCardTerms', 'Term' .. index, term)
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
    local iniSettings = LootUtils.Storage.ReadINISection(LootUtils.Settings.LootFile, 'Settings')
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
    LootUtils.Storage.ReadINIValue(LootUtils.Settings.LootFile, 'wildCardTerms', 'Count')
    local count = tonumber(LootUtils.Storage.ReadINIValue(LootUtils.Settings.LootFile, 'wildCardTerms', 'Count') or 0)
    if count > 0 then
        for i = 1, count do
            local term = LootUtils.Storage.ReadINIValue(LootUtils.Settings.LootFile, 'wildCardTerms', 'Term' .. i)
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
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    local playerLoopDelay = 100 + playerPing
    if LootUtils.UseWarp then
        mq.cmdf('/target id %s', spawnID)
        mq.delay(playerDelay, function() return mq.TLO.Target() ~= nil end)
        mq.cmd('/squelch /warp t')
    else
        mq.cmdf('/nav id %d log=off', spawnID)
        mq.delay(50)
        if mq.TLO.Navigation.Active() then
            local startTime = os.time()
            while mq.TLO.Navigation.Active() do
                mq.delay(playerLoopDelay)
                if os.difftime(os.time(), startTime) > 5 then
                    break
                end
            end
        end
    end
end

local function navToXYZ(navX, navY, navZ)
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    local playerLoopDelay = 100 + playerPing
    if LootUtils.UseWarp then
        mq.cmdf('/squelch /warp loc %s %s %s', navY, navX, navZ)
    else
        mq.cmdf('/nav locxyz %s %s %s log=off', navX, navY, navZ)
        mq.delay(50)
        if mq.TLO.Navigation.Active() then
            local startTime = os.time()
            while mq.TLO.Navigation.Active() do
                mq.delay(playerLoopDelay)
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

function LootUtils.navToXYZ(navX, navY, navZ)
    navToXYZ(navX, navY, navZ)
end

local function addRule(itemName, section, rule)
    if rule == 'Ignore' and not LootUtils.AddIgnoredItems or (not LootUtils.LootEmpoweredFabled and rule == 'Fabled') then
        return
    end
    if not lootData[section] then
        lootData[section] = {}
    end
    lootData[section][itemName] = rule
    LootUtils.Storage.SetINIValue(LootUtils.Settings.LootFile, section, itemName, rule)
end

local function lookupIniLootRule(section, key)
    return mq.TLO.Ini.File(LootUtils.Settings.LootFile).Section(section).Key(key).Value()
end

local function getRule(item)
    local itemName = item.Name()
    local itemHP = item.HP()
    local itemDMG = item.Damage()
    local itemAugSlot1 = item.AugSlot1()
    local itemAugSlot2 = item.AugSlot2()
    local itemAugSlot3 = item.AugSlot3()
    local itemAugSlot4 = item.AugSlot4()
    local itemAugSlot5 = item.AugSlot5()
    local itemAugSlot6 = item.AugSlot6()
    local itemLink = item.ItemLink('CLICKABLE')()
    local lootDecision = 'Ignore'
    local tradeskill = item.Tradeskills()
    local sellPrice = item.Value() or 0
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

    -- Define category lookup tables
    local weaponSlots = {
        ["Main Hand"] = true,
        ["Off Hand"] = true,
        ["Ranged"] = true,
    }

    local armorSlots = {
        ["Head"] = true,
        ["Arms"] = true,
        ["Left Wrist"] = true,
        ["Right Wrist"] = true,
        ["Hands"] = true,
        ["Chest"] = true,
        ["Legs"] = true,
        ["Feet"] = true,
    }

    -- Use slotNames[wornSlot] to determine category
    local function getItemSlotCategory(slot)
        local slotName = slotNames[slot]
        if weaponSlots[slotName] then
            return "Weapon"
        elseif armorSlots[slotName] then
            return "Armor"
        elseif slotName then
            return "NonVis"
        end
        return nil
    end

    local function AnnounceUpgrade(slotNumber, slotName)
        local hpDiff
        if mq.TLO.Me.Inventory(wornSlot)() ~= nil then
            hpDiff = math.floor(itemHP - mq.TLO.Me.Inventory(slotNumber).HP())
        else
            hpDiff = itemHP
        end
        LootUtils.logReport('Upgrade', 'Found Upgrade: %s (+%s hp - %s)', itemLink, hpDiff, slotName)
    end

    if LootUtils.LootByAugSlots then
        local slotCategory = getItemSlotCategory(wornSlot)
        if LootUtils.LootByAugSlotsType == 'Any' or LootUtils.LootByAugSlotsType == slotCategory then
            if LootUtils.LootByAugSlotsAmount == 6 and itemAugSlot6 ~= 0 then
                LootUtils.logReport('Keep', 'Found Augmented Item: %s (%s(%s))', itemLink, itemAugSlot6, LootUtils.LootByAugSlotsAmount)
                return 'Keep'
            elseif LootUtils.LootByAugSlotsAmount >= 5 and itemAugSlot5 ~= 0 then
                LootUtils.logReport('Keep', 'Found Augmented Item: %s (%s(%s))', itemLink, itemAugSlot6, LootUtils.LootByAugSlotsAmount)
                return 'Keep'
            elseif LootUtils.LootByAugSlotsAmount >= 4 and itemAugSlot4 ~= 0 then
                LootUtils.logReport('Keep', 'Found Augmented Item: %s (%s(%s))', itemLink, itemAugSlot6, LootUtils.LootByAugSlotsAmount)
                return 'Keep'
            elseif LootUtils.LootByAugSlotsAmount >= 3 and itemAugSlot3 ~= 0 then
                LootUtils.logReport('Keep', 'Found Augmented Item: %s (%s(%s))', itemLink, itemAugSlot6, LootUtils.LootByAugSlotsAmount)
                return 'Keep'
            elseif LootUtils.LootByAugSlotsAmount >= 2 and itemAugSlot2 ~= 0 then
                LootUtils.logReport('Keep', 'Found Augmented Item: %s (%s(%s))', itemLink, itemAugSlot6, LootUtils.LootByAugSlotsAmount)
                return 'Keep'
            elseif LootUtils.LootByAugSlotsAmount == 1 and itemAugSlot1 ~= 0 then
                LootUtils.logReport('Keep', 'Found Augmented Item: %s (%s(%s))', itemLink, itemAugSlot6, LootUtils.LootByAugSlotsAmount)
                return 'Keep'
            end
        end
    end

    if LootUtils.EquipUsable and canUse then
        if wornSlot == 1 and mq.TLO.Me.Inventory(wornSlot)() == nil then
            AnnounceUpgrade(wornSlot, 'Left Ear')
            return 'Keep'
        elseif wornSlot == 1 and mq.TLO.Me.Inventory(4)() == nil then
            AnnounceUpgrade(4, 'Right Ear')
            return 'Keep'
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(wornSlot)() == nil then
            AnnounceUpgrade(15, 'Left Finger')
            return 'Keep'
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(16)() == nil then
            AnnounceUpgrade(16, 'Right Finger')
            return 'Keep'
        elseif mq.TLO.Me.Inventory(wornSlot)() == nil then
            local slotName = slotNames[wornSlot] or "Unknown"
            AnnounceUpgrade(wornSlot, slotName)
            return 'Keep'
        end
    end

    if LootUtils.LootByDamage and itemDMG >= LootUtils.LootByDamageAmount then
        LootUtils.logReport('Keep', 'Found Weapon Damge Item: %s (%s(%s))', itemLink, itemDMG, LootUtils.LootByDamageAmount)
        return 'Keep'
    end

    if LootUtils.LootGearUpgrades and canUse and itemHP ~= nil and itemHP > 0 then
        if mq.TLO.Me.Inventory(wornSlot)() ~= nil then
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
        else
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
            LootUtils.logReport('Ignore', 'Ignore Item: %s (%s)', itemLink, 'noDrop and not canUse')
            lootDecision = 'Ignore'
        end
        if LootUtils.LootTradeSkill and tradeskill then
            LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'LootTradeSkill')
            LootUtils.logReport('Bank', 'Bank Item: %s (%s)', itemLink, 'LootTradeSkill')
            lootDecision = 'Bank'
        end
        if sellPrice ~= 0 and sellPrice >= LootUtils.MinSellPrice and not noDrop and not noRent then
            LootUtils.ConsoleMessage('Debug', 'Sell because: %s', 'MinSellPrice')
            LootUtils.logReport('Sell', 'Sell Item: %s (%s)', itemLink, 'MinSellPrice')
            lootDecision = 'Sell'
        end
        if not stackable and LootUtils.StackableOnly then
            LootUtils.ConsoleMessage('Debug', 'Ignore because: %s', 'StackableOnly')
            LootUtils.logReport('Ignore', 'Ignore Item: %s (%s)', itemLink, 'StackableOnly')
            lootDecision = 'Ignore'
        end
        if LootUtils.StackPlatValue > 0 and sellPrice * stackSize >= LootUtils.StackPlatValue and not noDrop and not noRent then
            LootUtils.ConsoleMessage('Debug', 'Sell because: %s', 'StackPlatValue')
            LootUtils.logReport('Sell', 'Ignore Item: %s (%s)', itemLink, 'StackPlatValue')
            lootDecision = 'Sell'
        end
        if LootUtils.LootEmpoweredFabled and string.find(itemName, LootUtils.EmpoweredFabledName) then
            if LootUtils.EmpoweredFabledMinHP == 0 then
                LootUtils.ConsoleMessage('Debug', 'Fabled because: %s', 'EmpoweredFabledMinHP')
                LootUtils.logReport('Fabled', 'Fabled Item: %s (%s)', itemLink, 'EmpoweredFabledMinHP')
                lootDecision = 'Fabled'
            end
            if LootUtils.EmpoweredFabledMinHP >= 1 and itemHP >= LootUtils.EmpoweredFabledMinHP then
                LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'EmpoweredFabledMinHP')
                LootUtils.logReport('Bank', 'Bank Item: %s (%s)', itemLink, 'EmpoweredFabledMinHP')
                lootDecision = 'Bank'
            end
            if LootUtils.EmpoweredFabledMinHP >= 1 and itemHP <= LootUtils.EmpoweredFabledMinHP then
                LootUtils.ConsoleMessage('Debug', 'Fabled because: %s', 'EmpoweredFabledMinHP')
                LootUtils.logReport('Fabled', 'Fabled Item: %s (%s)', itemLink, 'EmpoweredFabledMinHP')
                lootDecision = 'Fabled'
            end
        end
        if LootUtils.LootByMinHP >= 1 and itemHP >= LootUtils.LootByMinHP then
            if LootUtils.LootByMinHPNoDrop and noDrop and canUse then
                LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'LootByMinHPNoDrop')
                LootUtils.logReport('Keep', 'Keep Item: %s (%s)', itemLink, 'LootByMinHPNoDrop')
                lootDecision = 'Keep'
            elseif not LootUtils.LootByMinHPNoDrop and noDrop then
                LootUtils.ConsoleMessage('Debug', 'Skipping because: %s', 'LootByMinHPNoDrop')
                LootUtils.logReport('Ignore', 'Ignore Item: %s (%s)', itemLink, 'LootByMinHPNoDrop')
                lootDecision = 'Ignore'
            elseif not noDrop then
                LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'LootByMinHP')
                LootUtils.logReport('Keep', 'Keep Item: %s (%s)', itemLink, 'LootByMinHP')
                lootDecision = 'Keep'
            end
        end
        if LootUtils.LootAllFabledAugs and string.find(itemName, LootUtils.EmpoweredFabledName) and item.AugType() ~= nil and item.AugType() > 0 then
            LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'LootAllFabledAugs')
            LootUtils.logReport('Bank', 'Bank Item: %s (%s)', itemLink, 'LootAllFabledAugs')
            lootDecision = 'Bank'
        end
        if LootUtils.LootPlatinumBags and string.find(itemName, 'of Platinum') then
            LootUtils.ConsoleMessage('Debug', 'Sell because: %s', 'LootPlatinumBags')
            LootUtils.logReport('Sell', 'Sell Item: %s (%s)', itemLink, 'LootPlatinumBags')
            lootDecision = 'Sell'
        end
        if LootUtils.LootTokensOfAdvancement and string.find(itemName, 'Token of Advancement') then
            LootUtils.ConsoleMessage('Debug', 'Bank because: %s', 'LootTokensOfAdvancement')
            LootUtils.logReport('Bank', 'Bank Item: %s (%s)', itemLink, 'LootTokensOfAdvancement')
            lootDecision = 'Bank'
        end
        if evolvingItem and LootUtils.LootEvolvingItems then
            LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'LootEvolvingItems')
            LootUtils.logReport('Keep', 'Keep Item: %s (%s)', itemLink, 'LootEvolvingItems')
            lootDecision = 'Keep'
        end
        if LootUtils.LootWildCardItems then
            for _, term in ipairs(LootUtils.wildCardTerms) do
                if string.find(itemName, term) then
                    lootDecision = 'Keep'
                    LootUtils.ConsoleMessage('Debug', 'Keeping because: %s', 'wildCardTerms')
                    LootUtils.logReport('Keep', 'Keep Item: %s (%s)', itemLink, 'wildCardTerms')
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

local flags = {
    { name = "Quest",    color = { 1.0, 0.5, 0.0, 1.0 } },
    { name = "Keep",     color = { 0.0, 1.0, 0.0, 1.0 } },
    { name = "Ignore",   color = { 1.0, 0.0, 0.0, 1.0 } },
    { name = "Announce", color = { 0.0, 1.0, 1.0, 1.0 } },
    { name = "Destroy",  color = { 0.5, 0.0, 0.0, 1.0 } },
    { name = "Sell",     color = { 0.0, 0.5, 1.0, 1.0 } },
    { name = "Fabled",   color = { 0.6, 0.2, 0.8, 1.0 } },
    { name = "Cash",     color = { 1.0, 0.84, 0.0, 1.0 } },
}

local function truncateText(text, maxLength)
    if #text > maxLength then
        return text:sub(1, maxLength - 2) .. ".."
    end
    return text
end

local flagsVisible = {
    Quest = true,
    Keep = true,
    Ignore = true,
    Announce = true,
    Destroy = true,
    Sell = true,
    Fabled = false, -- hide by default
    Cash = false,   -- hide by default
}

local showQuest = flagsVisible.Quest
local showKeep = flagsVisible.Keep
local showIgnore = flagsVisible.Ignore
local showAnnounce = flagsVisible.Announce
local showDestroy = flagsVisible.Destroy
local showSell = flagsVisible.Sell
local showFabled = flagsVisible.Fabled
local showCash = flagsVisible.Cash

local function LoadLootListFromINI()
    local iniFile = LootUtils.Settings.LootFile
    local list, ini = {}, mq.TLO.Ini.File(iniFile)
    if not ini() then return list end

    for i = 65, 90 do
        local section = ini.Section(string.char(i))
        if section() then
            for idx = 1, section.Key.Count() do
                local key = section.Key.KeyAtIndex(idx)()
                if key and key ~= "Defaults" then
                    local val = section.Key(key).Value() or "Ignore"
                    table.insert(list, { name = key, flag = val })
                end
            end
        end
    end
    return list
end

local function SaveItemFlagToINI(itemName, flag)
    local iniFile = LootUtils.Settings.LootFile
    local section = string.upper(itemName:sub(1, 1))
    LootUtils.Storage.SetINIValue(iniFile, section, itemName, flag)
end

local lootList = LoadLootListFromINI()
local function getTextColorForBackground(r, g, b)
    local luminance = 0.299 * r + 0.587 * g + 0.114 * b
    -- Light backgrounds -> dark text, dark backgrounds -> light text
    return luminance > 0.5 and { 0, 0, 0, 1 } or { 1, 1, 1, 1 }
end

local function DrawFlagButton(item, flagInfo)
    local isActive = item.flag == flagInfo.name
    local r, g, b = flagInfo.color[1], flagInfo.color[2], flagInfo.color[3]
    local blendFactor = 0.7 -- 70% blend toward white to lighten inactive buttons
    if not isActive then
        r = r * (1 - blendFactor) + blendFactor
        g = g * (1 - blendFactor) + blendFactor
        b = b * (1 - blendFactor) + blendFactor
    end

    local color = { r, g, b, 1.0 }
    local label = truncateText(flagInfo.name, 6)
    local id = flagInfo.name .. "##" .. item.name

    local size = ImVec2(45, 24)
    local cursorX, cursorY = ImGui.GetCursorScreenPos()

    -- local pressed = ImGui.ColorButton(id, color, 0, size)
    local ImGuiColorEditFlags_NoPicker = 2 ^ 6   -- 64
    local ImGuiColorEditFlags_NoTooltip = 2 ^ 10 -- 1024
    local cbflags = ImGuiColorEditFlags_NoPicker + ImGuiColorEditFlags_NoTooltip
    local pressed = ImGui.ColorButton(id, color, cbflags, size)
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip(flagInfo.name) -- Show full name on hover
    end

    local textSizeX, textSizeY = ImGui.CalcTextSize(label)
    local textX = cursorX + (size.x - textSizeX) / 2
    local textY = cursorY + (size.y - textSizeY) / 2

    -- Text color:
    local textColorBase
    if not isActive then
        textColorBase = { 0, 0, 0, 1 } -- black text for faded buttons
    elseif flagInfo.name == "Ignore" then
        textColorBase = { 0, 0, 0, 1 }
    else
        textColorBase = getTextColorForBackground(flagInfo.color[1], flagInfo.color[2], flagInfo.color[3])
    end
    if isActive then
        local drawList = ImGui.GetWindowDrawList()
        local minX, minY = ImGui.GetItemRectMin()
        local maxX, maxY = ImGui.GetItemRectMax()

        local minPos = ImVec2(minX, minY)
        local maxPos = ImVec2(maxX, maxY)

        drawList:AddRect(minPos, maxPos, ImGui.GetColorU32(1, 1, 1, 1), 1.0)
    end

    local textAlpha = isActive and 1.0 or 0.7
    local textColor = { textColorBase[1], textColorBase[2], textColorBase[3], textAlpha }

    ImGui.GetWindowDrawList():AddText(
        ImVec2(textX, textY),
        ImGui.GetColorU32(textColor[1], textColor[2], textColor[3], textColor[4]),
        label
    )

    if pressed then
        item.flag = isActive and "Ignore" or flagInfo.name
        SaveItemFlagToINI(item.name, item.flag)
    end

    return pressed
end

local function DrawDeleteButton(item)
    local id = "Delete##" .. item.name
    local size = ImVec2(30, 22)
    local cursorX, cursorY = ImGui.GetCursorScreenPos()

    -- red color for the button
    local color = { 1.0, 0.0, 0.0, 1.0 }

    local pressed = ImGui.ColorButton(id, color, 0, size)

    -- Draw white "X" centered inside button
    local text = "X"
    local textSizeX, textSizeY = ImGui.CalcTextSize(text)
    local textX = cursorX + (size.x - textSizeX) / 2
    local textY = cursorY + (size.y - textSizeY) / 2

    ImGui.GetWindowDrawList():AddText(
        ImVec2(textX, textY),
        ImGui.GetColorU32(1, 1, 1, 1),
        text
    )

    if pressed then
        -- Remove item from lootList
        for i, it in ipairs(lootList) do
            if it == item then
                table.remove(lootList, i)
                SaveItemFlagToINI(item.name, "Ignore")
                break
            end
        end
    end

    return pressed
end

LOOTEVOLVINGITEMS = LootUtils.LootEvolvingItems
MOBSTOOCLOSE = LootUtils.MobsTooClose
CORPSERADIUS = LootUtils.CorpseRadius
ADDNEWSALES = LootUtils.AddNewSales
ADDIGNOREDITEMS = LootUtils.AddIgnoredItems
USECLASSLOOTFILE = LootUtils.useClassLootFile
USEARMORTYPELOOTFILE = LootUtils.useArmorTypeLootFile
USEMACROLOOTFILE = LootUtils.useMacroLootFile
USEZONELOOTFILE = LootUtils.useZoneLootFile
USESINGLEFILEFORALLCHARACTERS = LootUtils.UseSingleFileForAllCharacters
LOOTFORAGE = LootUtils.LootForage
REPORTLOOT = LootUtils.ReportLoot
ANNOUNCEUPGRADES = LootUtils.AnnounceUpgrades
LOOTCHANNEL = LootUtils.LootChannel
SPAMLOOTINFO = LootUtils.SpamLootInfo
COMBATLOOTING = LootUtils.CombatLooting
LOOTGEARUPGRADES = LootUtils.LootGearUpgrades
LOOTWILDCARDITEMS = LootUtils.LootWildCardItems
MINSELLPRICE = LootUtils.MinSellPrice
STACKABLEONLY = LootUtils.StackableOnly
LOOTBYHPMIN = LootUtils.LootByMinHP
LOOTBYHPMINNODROP = LootUtils.LootByMinHPNoDrop
STACKPLATVALUE = LootUtils.StackPlatValue

RETURNHOMEAFTERLOOT = LootUtils.returnHomeAfterLoot
CAMPCHECK = LootUtils.camp_Check
ZONECHECK = LootUtils.zone_Check
RETURNTOCAMPDISTANCE = LootUtils.returnToCampDistance
STATICHUNT = LootUtils.staticHunt
STATICZONEID = LootUtils.staticZoneID
STATICZONENAME = LootUtils.staticZoneName
STATICX = LootUtils.staticX
STATICY = LootUtils.staticY
STATICZ = LootUtils.staticZ
HEALTHCHECK = LootUtils.health_Check
HEALAT = LootUtils.heal_At
HEALSPELL = LootUtils.heal_Spell
HEALGEM = LootUtils.heal_Gem

LOOTBYAUGSLOTS = LootUtils.LootByAugSlots
LOOTBYAUGSLOTSAMOUNT = LootUtils.LootByAugSlotsAmount
LOOTBYAUGSLOTSTYPE = LootUtils.LootByAugSlotsType
LOOTBYDAMAGE = LootUtils.LootByDamage
LOOTBYDAMAGEAMOUNT = LootUtils.LootByDamageAmount

CurrentStatus = ' '
local function OptionsGUI()
    if not LootUtils.Settings.optionsShowGUI then return end
    if LootUtils.Settings.optionsShowGUI and LootUtils.Settings.optionsOpenGUI then
        ImGui.SetNextWindowCollapsed(false, ImGuiCond.Always)
    end
    LootUtils.Settings.optionsShowGUI, LootUtils.Settings.optionsOpenGUI = ImGui.Begin("DroidLoot Options Window", LootUtils.Settings.optionsOpenGUI)
    if LootUtils.Settings.optionsShowGUI then
        local x_size = 665
        local y_size = 680
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.Once)
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)

        local optionsBarOpen = ImGui.BeginTabBar("LootUtilsOptions")
        if optionsBarOpen then
            local lootByAugSlotsOpen = ImGui.BeginTabItem("Loot By Aug Slots")
            if lootByAugSlotsOpen then
                local lootByAugSlotTypes = { "Any", "Armor", "Weapon", "NonVis" }
                LootUtils.LootByAugSlots = ImGui.Checkbox('Enable## Loot By Aug Slot', LootUtils.LootByAugSlots)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots items by their amount of aug slots when enabled.')
                if LOOTBYAUGSLOTS ~= LootUtils.LootByAugSlots then
                    LOOTBYAUGSLOTS = LootUtils.LootByAugSlots
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByAugSlots', LootUtils.LootByAugSlots)
                end
                ImGui.Separator();

                LootUtils.LootByAugSlotsAmount = ImGui.SliderInt("Min Slots", LootUtils.LootByAugSlotsAmount, 1, 6)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum amount of aug slots an item needs to be kept.')
                if LOOTBYAUGSLOTSAMOUNT ~= LootUtils.LootByAugSlotsAmount then
                    LOOTBYAUGSLOTSAMOUNT = LootUtils.LootByAugSlotsAmount
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByAugSlotsAmount', LootUtils.LootByAugSlotsAmount)
                end
                ImGui.Separator();

                -- Add Combo Box here for Types
                LootUtils.LootByAugSlotsTypeIndex = LootUtils.LootByAugSlotsTypeIndex or 1
                local lootTypeLabel = lootByAugSlotTypes[LootUtils.LootByAugSlotsTypeIndex] or lootByAugSlotTypes[1]

                if ImGui.BeginCombo("Slot Type", lootTypeLabel) then
                    for i = 1, #lootByAugSlotTypes do
                        local is_selected = (LootUtils.LootByAugSlotsTypeIndex == i)
                        if ImGui.Selectable(lootByAugSlotTypes[i], is_selected) then
                            LootUtils.LootByAugSlotsTypeIndex = i
                            LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByAugSlotsTypeIndex', i)
                        end
                        if is_selected then
                            ImGui.SetItemDefaultFocus()
                        end
                    end
                    ImGui.EndCombo()
                end

                ImGui.EndTabItem()
            end
            local lootByDamageOpen = ImGui.BeginTabItem("Loot By Damage")
            if lootByDamageOpen then
                LootUtils.LootByDamage = ImGui.Checkbox('Enable## Loot by Damage', LootUtils.LootByDamage)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots items by their damage when enabled.')
                if LOOTBYDAMAGE ~= LootUtils.LootByDamage then
                    LOOTBYDAMAGE = LootUtils.LootByDamage
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByDamage', LootUtils.LootByDamage)
                end
                ImGui.Separator();

                LootUtils.LootByDamageAmount = ImGui.SliderInt("Min Damage", LootUtils.LootByDamageAmount, 1, 1000)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum amount of damage an item needs to be kept.')
                if LOOTBYDAMAGEAMOUNT ~= LootUtils.LootByDamageAmount then
                    LOOTBYDAMAGEAMOUNT = LootUtils.LootByDamageAmount
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByDamageAmount', LootUtils.LootByDamageAmount)
                end
                ImGui.Separator();

                ImGui.EndTabItem()
            end
            local hubOperationsOpen = ImGui.BeginTabItem("Hub Operations")
            if hubOperationsOpen then
                ImGui.Columns(2)
                LootUtils.bankDeposit = ImGui.Checkbox('Enable Bank Deposit', LootUtils.bankDeposit)
                ImGui.SameLine()
                ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                if BANKDEPOSIT ~= LootUtils.bankDeposit then
                    BANKDEPOSIT = LootUtils.bankDeposit
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'bankDeposit', LootUtils.bankDeposit)
                end
                ImGui.NextColumn();

                LootUtils.sellVendor = ImGui.Checkbox('Enable Vendor Selling', LootUtils.sellVendor)
                ImGui.SameLine()
                ImGui.HelpMarker('Sells items for Platinum when enabled.')
                if SELLVENDOR ~= LootUtils.sellVendor then
                    SELLVENDOR = LootUtils.sellVendor
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'sellVendor', LootUtils.sellVendor)
                end
                ImGui.Separator();
                ImGui.Columns(1)

                LootUtils.bankZone = ImGui.InputInt('Bank Zone', LootUtils.bankZone)
                ImGui.SameLine()
                ImGui.HelpMarker('Zone where we can access banking services.')
                if BANKZONE ~= LootUtils.bankZone then
                    BANKZONE = LootUtils.bankZone
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'bankZone', LootUtils.bankZone)
                end
                ImGui.Separator();

                LootUtils.bankNPC = ImGui.InputText('Bank NPC', LootUtils.bankNPC)
                ImGui.SameLine()
                ImGui.HelpMarker('The name of the npc to warp to for banking.')
                if BANKNPC ~= LootUtils.bankNPC then
                    BANKNPC = LootUtils.bankNPC
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'bankNPC', LootUtils.bankNPC)
                end
                ImGui.Separator();

                LootUtils.vendorNPC = ImGui.InputText('Vendor NPC', LootUtils.vendorNPC)
                ImGui.SameLine()
                ImGui.HelpMarker('The name of the npc to warp to for vendoring.')
                if VENDORNPC ~= LootUtils.vendorNPC then
                    VENDORNPC = LootUtils.vendorNPC
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'vendorNPC', LootUtils.vendorNPC)
                end
                ImGui.Separator();

                LootUtils.bankAtFreeSlots = ImGui.SliderInt("Inventory Free Slots", LootUtils.bankAtFreeSlots, 1, 20)
                ImGui.SameLine()
                ImGui.HelpMarker('The amount of free slots before we should bank.')
                if BANKATFREESLOTS ~= LootUtils.bankAtFreeSlots then
                    BANKATFREESLOTS = LootUtils.bankAtFreeSlots
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'bankAtFreeSlots', LootUtils.bankAtFreeSlots)
                end
                ImGui.Separator();
                ImGui.EndTabItem()
            end
            local healthOperationsOpen = ImGui.BeginTabItem("Health Operations")
            if healthOperationsOpen then
                LootUtils.health_Check = ImGui.Checkbox('Enable Healing', LootUtils.health_Check)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables healing with our heal spell when below our heal at limit.')
                if HEALTHCHECK ~= LootUtils.health_Check then
                    HEALTHCHECK = LootUtils.health_Check
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'health_Check', LootUtils.health_Check)
                end
                ImGui.Separator();

                LootUtils.heal_Spell = ImGui.InputText('Heal Spell', LootUtils.heal_Spell)
                ImGui.SameLine()
                ImGui.HelpMarker('The name of the spell to cast to heal.')
                if HEALSPELL ~= LootUtils.heal_Spell then
                    HEALSPELL = LootUtils.heal_Spell
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'heal_Spell', LootUtils.heal_Spell)
                end
                ImGui.Separator();

                LootUtils.heal_Gem = ImGui.SliderInt("Heal Gem", LootUtils.heal_Gem, 1, 12)
                ImGui.SameLine()
                ImGui.HelpMarker('The gem number our heal spell is on.')
                if HEALAT ~= LootUtils.heal_Gem then
                    HEALAT = LootUtils.heal_Gem
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'heal_Gem', LootUtils.heal_Gem)
                end
                ImGui.Separator();

                LootUtils.heal_At = ImGui.SliderInt("Heal At", LootUtils.heal_At, 1, 99)
                ImGui.SameLine()
                ImGui.HelpMarker('The amount of health we cast our heal spell at.')
                if HEALAT ~= LootUtils.heal_At then
                    HEALAT = LootUtils.heal_At
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'heal_At', LootUtils.heal_At)
                end
                ImGui.Separator();
                ImGui.EndTabItem();
            end
            local movementOperationsOpen = ImGui.BeginTabItem("Movement Operations")
            if movementOperationsOpen then
                ImGui.Columns(2)
                local start_y_Options = ImGui.GetCursorPosY()
                LootUtils.camp_Check = ImGui.Checkbox('Enable Camp Check', LootUtils.camp_Check)
                ImGui.SameLine()
                ImGui.HelpMarker('Return home if we get too far away?')
                if CAMPCHECK ~= LootUtils.camp_Check then
                    CAMPCHECK = LootUtils.camp_Check
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'camp_Check', LootUtils.camp_Check)
                end
                ImGui.Separator();

                LootUtils.zone_Check = ImGui.Checkbox('Enable Zone Check', LootUtils.zone_Check)
                ImGui.SameLine()
                ImGui.HelpMarker('Return to start zone if we leave it?')
                if ZONECHECK ~= LootUtils.zone_Check then
                    ZONECHECK = LootUtils.zone_Check
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'zone_Check', LootUtils.zone_Check)
                end
                ImGui.Separator();

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y_Options)
                LootUtils.returnHomeAfterLoot = ImGui.Checkbox('Enable Return Home After Loot', LootUtils.returnHomeAfterLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Return to start X/Y/Z after looting?')
                if RETURNHOMEAFTERLOOT ~= LootUtils.returnHomeAfterLoot then
                    RETURNHOMEAFTERLOOT = LootUtils.returnHomeAfterLoot
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'returnHomeAfterLoot', LootUtils.returnHomeAfterLoot)
                end
                ImGui.Separator();
                ImGui.Columns(1)

                LootUtils.returnToCampDistance = ImGui.SliderInt("Return To Camp Distance", LootUtils.returnToCampDistance, 1, 100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The distance we can get before we trigger return to camp.')
                if RETURNTOCAMPDISTANCE ~= LootUtils.returnToCampDistance then
                    RETURNTOCAMPDISTANCE = LootUtils.returnToCampDistance
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'returnToCampDistance', LootUtils.returnToCampDistance)
                end
                ImGui.Separator();
                ImGui.EndTabItem();
            end
            local campSettingsOpen = ImGui.BeginTabItem("Camp Settings")
            if campSettingsOpen then
                LootUtils.staticHunt = ImGui.Checkbox('Enable Static Hunt', LootUtils.staticHunt)
                ImGui.SameLine()
                ImGui.HelpMarker('Always use the same Hunting Zone.')
                if STATICHUNT ~= LootUtils.staticHunt then
                    STATICHUNT = LootUtils.staticHunt
                    DroidLoot.CheckCampInfo()
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'staticHunt', LootUtils.staticHunt)
                end
                ImGui.Separator();

                LootUtils.staticZoneName = ImGui.InputText('Zone Name', LootUtils.staticZoneName)
                ImGui.SameLine()
                ImGui.HelpMarker('The short name of the Static Hunt Zone.')
                if STATICZONENAME ~= LootUtils.staticZoneName then
                    STATICZONENAME = LootUtils.staticZoneName
                    DroidLoot.CheckCampInfo()
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'staticZoneName', LootUtils.staticZoneName)
                end
                ImGui.Separator();

                LootUtils.staticZoneID = ImGui.InputText('Zone ID', LootUtils.staticZoneID)
                ImGui.SameLine()
                ImGui.HelpMarker('The ID of the static Hunting Zone.')
                if STATICZONEID ~= LootUtils.staticZoneID then
                    STATICZONEID = LootUtils.staticZoneID
                    DroidLoot.CheckCampInfo()
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'staticZoneID', LootUtils.staticZoneID)
                end
                ImGui.Separator();

                local start_y_Options = ImGui.GetCursorPosY()
                ImGui.SetCursorPosY(start_y_Options + 3)
                ImGui.Text('X')
                ImGui.SameLine()
                ImGui.SetNextItemWidth(120)
                ImGui.SetCursorPosY(start_y_Options)
                LootUtils.staticX = ImGui.InputText('##Zone X', LootUtils.staticX)
                ImGui.SameLine()
                ImGui.HelpMarker('The X loc in the static Hunting Zone to camp.')
                if STATICX ~= LootUtils.staticX then
                    STATICX = LootUtils.staticX
                    DroidLoot.CheckCampInfo()
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'staticX', LootUtils.staticX)
                end
                ImGui.SameLine();

                ImGui.SetCursorPosY(start_y_Options + 1)
                ImGui.Text('Y')
                ImGui.SameLine()
                ImGui.SetNextItemWidth(120)
                ImGui.SetCursorPosY(start_y_Options)
                LootUtils.staticY = ImGui.InputText('##Zone Y', LootUtils.staticY)
                ImGui.SameLine()
                ImGui.HelpMarker('The Y loc in the static Hunting Zone to camp.')
                if STATICY ~= LootUtils.staticY then
                    STATICY = LootUtils.staticY
                    DroidLoot.CheckCampInfo()
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'staticY', LootUtils.staticY)
                end
                ImGui.SameLine();

                ImGui.SetCursorPosY(start_y_Options + 1)
                ImGui.Text('Z')
                ImGui.SameLine()
                ImGui.SetNextItemWidth(120)
                ImGui.SetCursorPosY(start_y_Options)
                LootUtils.staticZ = ImGui.InputText('##Zone Z', LootUtils.staticZ)
                ImGui.SameLine()
                ImGui.HelpMarker('The Z loc in the static Hunting Zone to camp.')
                if STATICZ ~= LootUtils.staticZ then
                    STATICZ = LootUtils.staticZ
                    DroidLoot.CheckCampInfo()
                    LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'staticZ', LootUtils.staticZ)
                end
                ImGui.EndTabItem();
            end
            local wildcardOptionsOpen = ImGui.BeginTabItem("Wild Card Looting Options")
            if wildcardOptionsOpen then
                local settingsChanged = false -- Track if any settings changed

                -- Checkbox for enabling wildcard looting
                local lootWildCardItems = LootUtils.LootWildCardItems
                local changed
                lootWildCardItems, changed = ImGui.Checkbox('Enable Wildcard Looting', lootWildCardItems)
                if changed then
                    LootUtils.LootWildCardItems = lootWildCardItems
                    LOOTWILDCARDITEMS = lootWildCardItems
                    settingsChanged = true
                end
                ImGui.SameLine()
                ImGui.HelpMarker('Loots items matching wildcard names.')
                ImGui.Separator()

                -- Wildcard Terms Management
                LootUtils.wildCardTerms = LootUtils.wildCardTerms or {}
                if ImGui.CollapsingHeader("Wildcard Terms") then
                    ImGui.Indent()
                    local removeIndex = nil

                    for i, term in ipairs(LootUtils.wildCardTerms) do
                        ImGui.PushID(i)
                        local newTerm, termChanged = ImGui.InputText("##Term" .. i, term, 256)
                        if termChanged then
                            LootUtils.wildCardTerms[i] = newTerm
                            settingsChanged = true
                        end
                        ImGui.SameLine()
                        if ImGui.Button("Delete") then
                            removeIndex = i
                        end
                        ImGui.PopID()
                    end

                    if removeIndex then
                        table.remove(LootUtils.wildCardTerms, removeIndex)
                        settingsChanged = true
                    end

                    ImGui.Separator()

                    -- Add new term
                    LootUtils.newWildCardTerm = LootUtils.newWildCardTerm or ""
                    local newTermInput
                    newTermInput, changed = ImGui.InputText("New Term", LootUtils.newWildCardTerm, 256)
                    if changed then
                        LootUtils.newWildCardTerm = newTermInput
                    end
                    if ImGui.Button("Add Term") then
                        if LootUtils.newWildCardTerm ~= "" then
                            table.insert(LootUtils.wildCardTerms, LootUtils.newWildCardTerm)
                            LootUtils.newWildCardTerm = ""
                            settingsChanged = true
                        end
                    end

                    ImGui.Unindent()
                end

                -- If any settings changed, write them once
                if settingsChanged then
                    LootUtils.saveWildCardTerms()
                end
                ImGui.EndTabItem();
            end
            local booleanOptionsOpen = ImGui.BeginTabItem("Booleans")
            if booleanOptionsOpen then
                ImGui.Columns(2)
                local start_y = ImGui.GetCursorPosY()
                LootUtils.UseWarp = ImGui.Checkbox('Enable Warp', LootUtils.UseWarp)
                ImGui.SameLine()
                ImGui.HelpMarker('Uses warp when enabled.')
                if USEWARP ~= LootUtils.UseWarp then
                    USEWARP = LootUtils.UseWarp
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'UseWarp', LootUtils.UseWarp)
                end
                ImGui.Separator();

                LootUtils.AddNewSales = ImGui.Checkbox('Enable New Sales', LootUtils.AddNewSales)
                ImGui.SameLine()
                ImGui.HelpMarker('Add new sales when enabled.')
                if ADDNEWSALES ~= LootUtils.AddNewSales then
                    ADDNEWSALES = LootUtils.AddNewSales
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'AddNewSales', LootUtils.AddNewSales)
                end
                ImGui.Separator();

                LootUtils.AddIgnoredItems = ImGui.Checkbox('Enable Add Ignored Items', LootUtils.AddIgnoredItems)
                ImGui.SameLine()
                ImGui.HelpMarker('Add ignored items to ini when enabled.')
                if ADDIGNOREDITEMS ~= LootUtils.AddIgnoredItems then
                    ADDIGNOREDITEMS = LootUtils.AddIgnoredItems
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'AddIgnoredItems', LootUtils.AddIgnoredItems)
                end
                ImGui.Separator();

                LootUtils.LootForage = ImGui.Checkbox('Enable Loot Forage', LootUtils.LootForage)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot forage when enabled.')
                if LOOTFORAGE ~= LootUtils.LootForage then
                    LOOTFORAGE = LootUtils.LootForage
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootForage', LootUtils.LootForage)
                end
                ImGui.Separator();

                LootUtils.LootTradeSkill = ImGui.Checkbox('Enable Loot TradeSkill', LootUtils.LootTradeSkill)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot trade skill items when enabled.')
                if LOOTTRADESKILL ~= LootUtils.LootTradeSkill then
                    LOOTTRADESKILL = LootUtils.LootTradeSkill
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootTradeSkill', LootUtils.LootTradeSkill)
                end
                ImGui.Separator();

                LootUtils.DoLoot = ImGui.Checkbox('Enable Looting', LootUtils.DoLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables looting.')
                if DOLOOT ~= LootUtils.DoLoot then
                    DOLOOT = LootUtils.DoLoot
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'DoLoot', LootUtils.DoLoot)
                end
                ImGui.Separator();

                LootUtils.EquipUsable = ImGui.Checkbox('Enable Equip Usable', LootUtils.EquipUsable)
                ImGui.SameLine()
                ImGui.HelpMarker('Equips usable items. Buggy at best.')
                if EQUIPUSABLE ~= LootUtils.EquipUsable then
                    EQUIPUSABLE = LootUtils.EquipUsable
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'EquipUsable', LootUtils.EquipUsable)
                end
                ImGui.Separator();

                LootUtils.LootEvolvingItems = ImGui.Checkbox('Enable Loot Evolving', LootUtils.LootEvolvingItems)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots Evolving Items')
                if LOOTEVOLVINGITEMS ~= LootUtils.LootEvolvingItems then
                    LOOTEVOLVINGITEMS = LootUtils.LootEvolvingItems
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootEvolvingItems', LootUtils.LootEvolvingItems)
                end

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y)
                LootUtils.AnnounceLoot = ImGui.Checkbox('Enable Announce Loot', LootUtils.AnnounceLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to announce channel.')
                if ANNOUNCELOOT ~= LootUtils.AnnounceLoot then
                    ANNOUNCELOOT = LootUtils.AnnounceLoot
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'AnnounceLoot', LootUtils.AnnounceLoot)
                end
                ImGui.Separator();

                LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot to Console', LootUtils.ReportLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to console.')
                if REPORTLOOT ~= LootUtils.ReportLoot then
                    REPORTLOOT = LootUtils.ReportLoot
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'ReportLoot', LootUtils.ReportLoot)
                end
                ImGui.Separator();

                LootUtils.ReportSkipped = ImGui.Checkbox('Enable Report Skipped', LootUtils.ReportSkipped)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports skipped loots.')
                if REPORTSKIPPED ~= LootUtils.ReportSkipped then
                    REPORTSKIPPED = LootUtils.ReportSkipped
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'ReportSkipped', LootUtils.ReportSkipped)
                end
                ImGui.Separator();

                LootUtils.AnnounceUpgrades = ImGui.Checkbox('Enable Report Upgrade', LootUtils.AnnounceUpgrades)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports skipped loots.')
                if ANNOUNCEUPGRADES ~= LootUtils.AnnounceUpgrades then
                    ANNOUNCEUPGRADES = LootUtils.AnnounceUpgrades
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'AnnounceUpgrades', LootUtils.AnnounceUpgrades)
                end
                ImGui.Separator();

                LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spam Loot Info', LootUtils.SpamLootInfo)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot info.')
                if SPAMLOOTINFO ~= LootUtils.SpamLootInfo then
                    SPAMLOOTINFO = LootUtils.SpamLootInfo
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'SpamLootInfo', LootUtils.SpamLootInfo)
                end
                ImGui.Separator();

                LootUtils.LootForageSpam = ImGui.Checkbox('Enable Loot Forage Spam', LootUtils.LootForageSpam)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot forage info.')
                if LOOTFORAGESPAM ~= LootUtils.LootForageSpam then
                    LOOTFORAGESPAM = LootUtils.LootForageSpam
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootForageSpam', LootUtils.LootForageSpam)
                end
                ImGui.Separator();

                LootUtils.CombatLooting = ImGui.Checkbox('Enable Combat Looting', LootUtils.CombatLooting)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots during combat.')
                if COMBATLOOTING ~= LootUtils.CombatLooting then
                    COMBATLOOTING = LootUtils.CombatLooting
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'CombatLooting', LootUtils.CombatLooting)
                end
                ImGui.Separator();

                LootUtils.LootGearUpgrades = ImGui.Checkbox('Enable Upgrade Looting', LootUtils.LootGearUpgrades)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots items with more HP than currently worn items.')
                if LOOTGEARUPGRADES ~= LootUtils.LootGearUpgrades then
                    LOOTGEARUPGRADES = LootUtils.LootGearUpgrades
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootGearUpgrades', LootUtils.LootGearUpgrades)
                end
                ImGui.Separator();

                LootUtils.LootByMinHPNoDrop = ImGui.Checkbox('Enable Loot MinHP No Drop', LootUtils.LootByMinHPNoDrop)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots No Drop items you can use when looting by MinHP.')
                if LOOTBYHPMINNODROP ~= LootUtils.LootByMinHPNoDrop then
                    LOOTBYHPMINNODROP = LootUtils.LootByMinHPNoDrop
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByMinHPNoDrop', LootUtils.LootByMinHPNoDrop)
                end
                ImGui.Columns(1)
                ImGui.EndTabItem();
            end
            local stringsOptionsOpen = ImGui.BeginTabItem("Strings")
            if stringsOptionsOpen then
                LootUtils.CorpseRadius = ImGui.SliderInt("Corpse Radius", LootUtils.CorpseRadius, 1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should scan for corpses.')
                if CORPSERADIUS ~= LootUtils.CorpseRadius then
                    CORPSERADIUS = LootUtils.CorpseRadius
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'CorpseRadius', LootUtils.CorpseRadius)
                end
                ImGui.Separator();

                LootUtils.MobsTooClose = ImGui.SliderInt("Mobs Too Close", LootUtils.MobsTooClose, 1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The range to check for nearby mobs.')
                if MOBSTOOCLOSE ~= LootUtils.MobsTooClose then
                    MOBSTOOCLOSE = LootUtils.MobsTooClose
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'MobsTooClose', LootUtils.MobsTooClose)
                end
                ImGui.Separator();

                LootUtils.LootByMinHP = ImGui.SliderInt("Loot By HP Min Health", LootUtils.LootByMinHP, 0, 50000)
                ImGui.SameLine()
                ImGui.HelpMarker('Minimum HP for item to be considered and set to Keep. Any value greater than 0 activates this.')
                if LOOTBYHPMIN ~= LootUtils.LootByMinHP then
                    LOOTBYHPMIN = LootUtils.LootByMinHP
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootByMinHP', LootUtils.LootByMinHP)
                end
                ImGui.Separator();

                LootUtils.StackPlatValue = ImGui.SliderInt("Stack Platinum Value", LootUtils.StackPlatValue, 0, 10000)
                ImGui.SameLine()
                ImGui.HelpMarker('The value of platinum stacks.')
                if STACKPLATVALUE ~= LootUtils.StackPlatValue then
                    STACKPLATVALUE = LootUtils.StackPlatValue
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'StackPlatValue', LootUtils.StackPlatValue)
                end
                ImGui.Separator();

                LootUtils.SaveBagSlots = ImGui.SliderInt("Save Bag Slots", LootUtils.SaveBagSlots, 0, 100)
                ImGui.SameLine()
                ImGui.HelpMarker('The number of bag slots to save.')
                if SAVEBAGSLOTS ~= LootUtils.SaveBagSlots then
                    SAVEBAGSLOTS = LootUtils.SaveBagSlots
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'SaveBagSlots', LootUtils.SaveBagSlots)
                end
                ImGui.Separator();

                LootUtils.MinSellPrice = ImGui.SliderInt("Min Sell Price", LootUtils.MinSellPrice, 1, 1000000000)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum price at which items will be sold.')
                if MINSELLPRICE ~= LootUtils.MinSellPrice then
                    MINSELLPRICE = LootUtils.MinSellPrice
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'MinSellPrice', LootUtils.MinSellPrice)
                end
                ImGui.Separator();

                LootUtils.LootChannel = ImGui.InputText('Loot Channel', LootUtils.LootChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to report loot to.')
                if LOOTCHANNEL ~= LootUtils.LootChannel then
                    LOOTCHANNEL = LootUtils.LootChannel
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootChannel', LootUtils.LootChannel)
                end
                ImGui.Separator();

                LootUtils.AnnounceChannel = ImGui.InputText('Announce Channel', LootUtils.AnnounceChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to announce events.')
                if ANNOUNCECHANNEL ~= LootUtils.AnnounceChannel then
                    ANNOUNCECHANNEL = LootUtils.AnnounceChannel
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'AnnounceChannel', LootUtils.AnnounceChannel)
                end
                ImGui.Separator();
                ImGui.EndTabItem();
            end
            local iniOptionsOpen = ImGui.BeginTabItem("INI")
            if iniOptionsOpen then
                LootUtils.Settings.LootFile = ImGui.InputText('Loot file', LootUtils.Settings.LootFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot file to use.')
                if LOOTINIFILE ~= LootUtils.Settings.LootFile then
                    LOOTINIFILE = LootUtils.Settings.LootFile
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootFile', LootUtils.Settings.LootFile)
                end
                ImGui.Separator();

                ImGui.Columns(2)
                local start_y_INI = ImGui.GetCursorPosY()

                LootUtils.UseSingleFileForAllCharacters = ImGui.Checkbox('Enable Single INI', LootUtils.UseSingleFileForAllCharacters)
                ImGui.SameLine()
                ImGui.HelpMarker('Reads from a single INI file for all characters when enabled.')
                if USESINGLEFILEFORALLCHARACTERS ~= LootUtils.UseSingleFileForAllCharacters then
                    USESINGLEFILEFORALLCHARACTERS = LootUtils.UseSingleFileForAllCharacters
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'UseSingleFileForAllCharacters', LootUtils.UseSingleFileForAllCharacters)
                end
                ImGui.Separator();

                LootUtils.useZoneLootFile = ImGui.Checkbox('Enable Zone INI', LootUtils.useZoneLootFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Reads from a zone based INI file for all characters when enabled.')
                if USEZONELOOTFILE ~= LootUtils.useZoneLootFile then
                    USEZONELOOTFILE = LootUtils.useZoneLootFile
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'useZoneLootFile', LootUtils.useZoneLootFile)
                end
                ImGui.Separator();

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y_INI)
                LootUtils.useClassLootFile = ImGui.Checkbox('Enable Class INI', LootUtils.useClassLootFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Reads from a class based INI file for all characters when enabled.')
                if USECLASSLOOTFILE ~= LootUtils.useClassLootFile then
                    USECLASSLOOTFILE = LootUtils.useClassLootFile
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'useClassLootFile', LootUtils.useClassLootFile)
                end
                ImGui.Separator();

                LootUtils.useArmorTypeLootFile = ImGui.Checkbox('Enable Armor Type INI', LootUtils.useArmorTypeLootFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Reads from an armor type based INI file for all characters when enabled.')
                if USEARMORTYPELOOTFILE ~= LootUtils.useArmorTypeLootFile then
                    USEARMORTYPELOOTFILE = LootUtils.useArmorTypeLootFile
                    LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'useArmorTypeLootFile', LootUtils.useArmorTypeLootFile)
                end
                ImGui.Columns(1)
                local buttonWidth, buttonHeight = 140, 30
                local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                if ImGui.Button('Save Config', buttonImVec2) then
                    LootUtils.writeSettings()
                end
                ImGui.EndTabItem();
            end
            local serverOptionsOpen = ImGui.BeginTabItem("Server Specific Options")
            if serverOptionsOpen then
                if ImGui.CollapsingHeader("WastingTime Options") then
                    ImGui.Indent()
                    LootUtils.LootPlatinumBags = ImGui.Checkbox('Enable Loot Platinum Bags', LootUtils.LootPlatinumBags)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots platinum bags.')
                    if LOOTPLATINUMBAGS ~= LootUtils.LootPlatinumBags then
                        LOOTPLATINUMBAGS = LootUtils.LootPlatinumBags
                        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootPlatinumBags', LootUtils.LootPlatinumBags)
                    end
                    ImGui.Separator();

                    LootUtils.LootTokensOfAdvancement = ImGui.Checkbox('Enable Loot Tokens of Advancement', LootUtils.LootTokensOfAdvancement)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots tokens of advancement.')
                    if LOOTTOKENSOFADVANCEMENT ~= LootUtils.LootTokensOfAdvancement then
                        LOOTTOKENSOFADVANCEMENT = LootUtils.LootTokensOfAdvancement
                        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootTokensOfAdvancement', LootUtils.LootTokensOfAdvancement)
                    end
                    ImGui.Separator();

                    LootUtils.LootEmpoweredFabled = ImGui.Checkbox('Enable Loot Empowered Fabled', LootUtils.LootEmpoweredFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots empowered fabled items.')
                    if LOOTEMPOWEREDFABLED ~= LootUtils.LootEmpoweredFabled then
                        LOOTEMPOWEREDFABLED = LootUtils.LootEmpoweredFabled
                        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootEmpoweredFabled', LootUtils.LootEmpoweredFabled)
                    end
                    ImGui.Separator();

                    LootUtils.LootAllFabledAugs = ImGui.Checkbox('Enable Loot All Fabled Augments', LootUtils.LootAllFabledAugs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots all fabled augments.')
                    if LOOTALLFABLEDAUGS ~= LootUtils.LootAllFabledAugs then
                        LOOTALLFABLEDAUGS = LootUtils.LootAllFabledAugs
                        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'LootAllFabledAugs', LootUtils.LootAllFabledAugs)
                    end
                    ImGui.Separator();

                    LootUtils.EmpoweredFabledMinHP = ImGui.SliderInt("Empowered Fabled Min HP", LootUtils.EmpoweredFabledMinHP, 0, 1000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                    if EMPOWEREDFABLEDMINHP ~= LootUtils.EmpoweredFabledMinHP then
                        EMPOWEREDFABLEDMINHP = LootUtils.EmpoweredFabledMinHP
                        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'EmpoweredFabledMinHP', LootUtils.EmpoweredFabledMinHP)
                    end
                    ImGui.Separator();

                    LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name', LootUtils.EmpoweredFabledName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Name of the empowered fabled item.')
                    if EMPOWEREDFABLEDNAME ~= LootUtils.EmpoweredFabledName then
                        EMPOWEREDFABLEDNAME = LootUtils.EmpoweredFabledName
                        LootUtils.saveSetting(LootUtils.Settings.LootFile, 'Settings', 'EmpoweredFabledName', LootUtils.EmpoweredFabledName)
                    end
                    ImGui.Separator();
                end
                ImGui.EndTabItem();
            end
        end
        ImGui.EndTabBar()
    end
    ImGui.End()
end
mq.imgui.init("DroidLoot Options Window", OptionsGUI)



local function LootGUI()
    if not LootUtils.Settings.lootShowGUI then return end
    if LootUtils.Settings.lootShowGUI and LootUtils.Settings.lootOpenGUI then
        ImGui.SetNextWindowCollapsed(false, ImGuiCond.Always)
    end
    LootUtils.Settings.lootShowGUI, LootUtils.Settings.lootOpenGUI = ImGui.Begin("DroidLoot Loot Window", LootUtils.Settings.lootOpenGUI)
    if LootUtils.Settings.lootShowGUI then
        local x_size = 665
        local y_size = 680
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.Once)
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        -- put checkboxes here side by side on 1 line to enable/disable flags being shown below.
        -- Checkboxes for showing flags
        local availWidth, _ = ImGui.GetContentRegionAvail()

        -- Calculate total width of all checkboxes and labels on the line
        local totalWidth = 0
        local padding = 10                            -- space between checkbox+label groups

        local checkboxSize = ImGui.CalcTextSize("[]") -- checkbox approx size
        local checkBoxWidth = 20                      -- approximate checkbox width (can be tweaked)
        local maxLabelWidth = 0

        -- For each flag, calculate width of checkbox + label + padding
        local flagNames = { "Quest", "Keep", "Ignore", "Announce", "Destroy", "Sell", "Fabled", "Cash" }
        local widths = {}

        for _, name in ipairs(flagNames) do
            local labelWidth, _ = ImGui.CalcTextSize(name)
            local groupWidth = checkBoxWidth + 5 + labelWidth -- checkbox + small space + label width
            table.insert(widths, groupWidth)
            totalWidth = totalWidth + groupWidth + padding
        end

        totalWidth = totalWidth - padding -- remove last padding

        -- Set cursor to center the entire row
        local cursorPosX = (availWidth - totalWidth) / 2
        if cursorPosX > 0 then ImGui.SetCursorPosX(cursorPosX) end

        -- Draw checkboxes and labels inline, updating flagsVisible variables
        local changed
        showQuest, changed = ImGui.Checkbox("##Quest", showQuest)
        if changed then flagsVisible.Quest = showQuest end
        ImGui.SameLine()
        ImGui.Text("Quest")
        ImGui.SameLine()

        showKeep, changed = ImGui.Checkbox("##Keep", showKeep)
        if changed then flagsVisible.Keep = showKeep end
        ImGui.SameLine()
        ImGui.Text("Keep")
        ImGui.SameLine()

        showIgnore, changed = ImGui.Checkbox("##Ignore", showIgnore)
        if changed then flagsVisible.Ignore = showIgnore end
        ImGui.SameLine()
        ImGui.Text("Ignore")
        ImGui.SameLine()

        showAnnounce, changed = ImGui.Checkbox("##Announce", showAnnounce)
        if changed then flagsVisible.Announce = showAnnounce end
        ImGui.SameLine()
        ImGui.Text("Announce")
        ImGui.SameLine()

        showDestroy, changed = ImGui.Checkbox("##Destroy", showDestroy)
        if changed then flagsVisible.Destroy = showDestroy end
        ImGui.SameLine()
        ImGui.Text("Destroy")
        ImGui.SameLine()

        showSell, changed = ImGui.Checkbox("##Sell", showSell)
        if changed then flagsVisible.Sell = showSell end
        ImGui.SameLine()
        ImGui.Text("Sell")
        ImGui.SameLine()

        showFabled, changed = ImGui.Checkbox("##Fabled", showFabled)
        if changed then flagsVisible.Fabled = showFabled end
        ImGui.SameLine()
        ImGui.Text("Fabled")
        ImGui.SameLine()

        showCash, changed = ImGui.Checkbox("##Cash", showCash)
        if changed then flagsVisible.Cash = showCash end
        ImGui.SameLine()
        ImGui.Text("Cash")

        ImGui.Separator()
        local availWidth2, _ = ImGui.GetContentRegionAvail()
        local text2 = "Loot Items"
        local textWidth2, _ = ImGui.CalcTextSize(text2)
        local cursorPosX2 = (availWidth2 - textWidth2) / 2
        if cursorPosX2 > 0 then ImGui.SetCursorPosX(cursorPosX2) end
        ImGui.Text(text2)
        ImGui.Separator()
        ImGui.Columns(3, "loot_columns", true)
        ImGui.Text("Item")
        ImGui.NextColumn()
        ImGui.Text("Flags")
        ImGui.NextColumn()
        ImGui.Text("Delete")
        ImGui.NextColumn()
        ImGui.Separator()

        for _, item in ipairs(lootList) do
            ImGui.Text(item.name)
            ImGui.NextColumn()

            local first = true
            for _, flagInfo in ipairs(flags) do
                if flagsVisible[flagInfo.name] then
                    if not first then ImGui.SameLine() end
                    DrawFlagButton(item, flagInfo)
                    first = false
                end
            end

            ImGui.NextColumn()
            DrawDeleteButton(item)
            ImGui.NextColumn()
        end

        ImGui.Columns(1)
    end
    ImGui.End()
end
mq.imgui.init("DroidLoot Loot Window", LootGUI)


local function LogWindowGUI()
    if not LootUtils.Settings.logShowGUI then return end

    if LootUtils.Settings.logOpenGUI then
        ImGui.SetNextWindowCollapsed(false, ImGuiCond.Always)
        local x_size, y_size = 665, 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetNextWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetNextWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
    end

    LootUtils.Settings.logShowGUI, LootUtils.Settings.logOpenGUI = ImGui.Begin("DroidLoot Logs Window", LootUtils.Settings.logOpenGUI)
    if LootUtils.Settings.logShowGUI then
        if ImGui.BeginPopup("Options") then
            ImGui.Checkbox('Auto-Scroll', LootUtils.Settings.logAutoScroll)
            if ImGui.Button('Clear Logs') then
                for _, logType in ipairs(LootUtils.Settings.logTypes) do
                    LootUtils.MessageLogs[logType] = {}
                end
            end
            ImGui.EndPopup()
        end
        if ImGui.Button('Options') then
            ImGui.OpenPopup("Options")
        end
        ImGui.SameLine()

        LootUtils.Settings.logFilterText = ImGui.InputText('Filter', LootUtils.Settings.logFilterText, 256)
        ImGui.SameLine()
        if ImGui.Button('Clear') then
            LootUtils.Settings.logFilterText = ''
        end
        ImGui.Separator()
        if ImGui.BeginTabBar("LogWindows") then
            for _, logType in ipairs(LootUtils.Settings.logTypes) do
                local tabName = string.format("%s", string.upper(logType))
                if ImGui.BeginTabItem(tabName) then
                    ImGui.BeginChild(logType .. "_scroll", 0, 0, true)
                    local messages = LootUtils.MessageLogs[logType]
                    if messages and #messages > 0 then
                        for i, msg in ipairs(messages) do
                            if LootUtils.Settings.logFilterText == '' or string.find(string.lower(msg), string.lower(LootUtils.Settings.logFilterText), 1, true) then
                                ImGui.TextUnformatted(msg)
                            end
                        end
                        if LootUtils.Settings.logAutoScroll then
                            ImGui.SetScrollHereY(1.0)
                        end
                    else
                        ImGui.TextDisabled("No messages logged yet.")
                    end
                    ImGui.EndChild()
                    ImGui.EndTabItem()
                end
            end
            ImGui.EndTabBar()
        end
    end
    ImGui.End()
end
mq.imgui.init("DroidLoot Logs Window", LogWindowGUI)



local function ConsoleWidgetTest()
    if not LootUtils.Settings.logShow2GUI then return end

    if LootUtils.Settings.logOpen2GUI then
        ImGui.SetNextWindowCollapsed(false, ImGuiCond.Always)
        local x_size, y_size = 665, 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetNextWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetNextWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
    end

    LootUtils.Settings.logShow2GUI, LootUtils.Settings.logOpen2GUI =
        ImGui.Begin("DroidLoot Logs Window Test", LootUtils.Settings.logOpen2GUI)

    if LootUtils.Settings.logShow2GUI then
        if ImGui.BeginPopup("Options") then
            LootUtils.Settings.Debug = ImGui.Checkbox('Debug', LootUtils.Settings.Debug)
            LootUtils.Settings.log2AutoScroll = ImGui.Checkbox('Auto-Scroll', LootUtils.Settings.log2AutoScroll)
            if ImGui.Button('Clear Logs') then
                for _, logType in ipairs(LootUtils.Settings.logTypes) do
                    local console = LootUtils.ConsoleByType[logType]
                    if console then console:Clear() end
                    LootUtils.MessageLogs[logType] = {}
                end
            end
            ImGui.EndPopup()
        end

        if ImGui.Button('Options') then
            ImGui.OpenPopup("Options")
        end

        ImGui.SameLine()

        LootUtils.Settings.logFilterText = ImGui.InputText('Filter', LootUtils.Settings.logFilterText, 256)
        ImGui.SameLine()
        if ImGui.Button('Clear') then
            LootUtils.Settings.logFilterText = ''
        end
        ImGui.Separator()
        local consoles = {}

        for _, logType in ipairs(LootUtils.Settings.logTypes) do
            consoles[#consoles + 1] = {
                name = logType:upper(),
                console = LootUtils["console" .. logType]
            }
        end

        if ImGui.BeginTabBar("LogWindows") then
            for _, entry in ipairs(consoles) do
                if not LootUtils.Settings.Debug and (entry.name == 'DEBUG' or entry.name == 'INFO' or entry.name == 'WARN') then
                    goto continue
                else
                    if mq.TLO.EverQuest.Server() ~= 'Wasting Time' and (entry.name == 'FABLED' or entry.name == 'CASH') then
                        goto continue
                    end
                    if ImGui.BeginTabItem(entry.name) then
                        entry.console.autoScroll = LootUtils.Settings.log2AutoScroll or false
                        entry.console:Render()
                        ImGui.EndTabItem()
                    end
                    -- if ImGui.BeginTabItem(entry.name) then
                    --     local originalBuffer = entry.console.buffer
                    --     if LootUtils.Settings.logFilterText ~= '' then
                    --         local filtered = {}
                    --         for _, line in ipairs(originalBuffer) do
                    --             if string.find(string.lower(line), string.lower(LootUtils.Settings.logFilterText), 1, true) then
                    --                 table.insert(filtered, line)
                    --             end
                    --         end
                    --         entry.console.buffer = filtered
                    --     end

                    --     entry.console.autoScroll = LootUtils.Settings.log2AutoScroll or false
                    --     entry.console:Render()
                    --     entry.console.buffer = originalBuffer

                    --     ImGui.EndTabItem()
                    -- end
                end
                ::continue::
            end
            ImGui.EndTabBar()
        end
    end

    ImGui.End()
end
mq.imgui.init("DroidLoot Logs Window Test", ConsoleWidgetTest)

local function commandHandler(...)
    local args = { ... }
    if #args == 1 then
        if args[1] == 'sell' and not LootUtils.Settings.Terminate then
            doSell = true
        elseif args[1] == 'cash' and not LootUtils.Settings.Terminate then
            doCashSell = true
        elseif args[1] == 'reload' then
            LootUtils.loadSettings()
            lootData = {}
            LootUtils.ConsoleMessage('Info', 'Reloaded Loot File')
        elseif args[1] == 'bank' then
            LootUtils.bankStuff()
        elseif args[1] == 'tsbank' then
            LootUtils.markTradeSkillAsBank()
        elseif args[1] == 'gui' then
            LootUtils.Settings.lootShowGUI = true
            if not LootUtils.Settings.lootOpenGUI then LootUtils.Settings.lootOpenGUI = true end
        elseif args[1] == 'options' then
            LootUtils.Settings.optionsShowGUI = true
            if not LootUtils.Settings.optionsOpenGUI then LootUtils.Settings.optionsOpenGUI = true end
        elseif args[1] == 'logs' then
            LootUtils.Settings.logShowGUI = true
            if not LootUtils.Settings.logOpenGUI then LootUtils.Settings.logOpenGUI = true end
        elseif args[1] == 'logs2' then
            LootUtils.Settings.logShow2GUI = true
            if not LootUtils.Settings.logOpen2GUI then LootUtils.Settings.logOpen2GUI = true end
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
    mq.bind('/' .. LootUtils.Settings.command_ShortName, commandHandler)
    mq.bind('/' .. LootUtils.Settings.command_LongName, commandHandler)
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
    local corpseName = mq.TLO.Corpse.Name()
    local corpseID = mq.TLO.Corpse.ID()
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
    LootUtils.logReport('Keep', 'Keep Item: %s (%s-%s)[\ag%s\ax]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, 'Ignore')

    if ruleAction == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then
        mq.cmd('/destroy')
    end
    if mq.TLO.Cursor() then
        checkCursor()
    end
end

function LootUtils.lootCorpse(corpseID)
    LootUtils.ConsoleMessage('Debug', 'Enter lootCorpse')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    mq.cmdf('/target id %s', corpseID)
    mq.delay(playerDelay, function() return mq.TLO.Target() ~= nil end)
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
    if LootUtils.useWarp then navToID(corpseID) end
    if mq.TLO.Me.FreeInventory() <= LootUtils.SaveBagSlots then
        LootUtils.ConsoleMessage('Warn', 'My bags are full, I can\'t loot anymore!')
        return
    end
    for i = 1, 3 do
        if not mq.TLO.Target() then
            LootUtils.ConsoleMessage('Debug', 'Can\'t loot no target was selected.')
            return
        end
        mq.cmd('/loot')
        mq.delay(playerDelay, function() return mq.TLO.Window('LootWnd').Open() end)
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
        for i = 1, items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            if corpseItem() then
                local lootAction = getRule(corpseItem)
                local stackable = corpseItem.Stackable()
                local freeStack = corpseItem.FreeStack()
                local itemName = corpseItem.Name()
                local haveItem = mq.TLO.FindItem(('=%s'):format(corpseItem.Name()))()
                local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(corpseItem.Name()))()
                mq.delay(1)
                LootUtils.ConsoleMessage('Debug', 'itemName: %s / lootAction: %s / stackable: %s / freeStack: %s / haveItem: %s / haveItemBank: %s', itemName, lootAction, stackable, freeStack, haveItem, haveItemBank)
                if freeSpace < LootUtils.SaveBagSlots then
                    LootUtils.logReport('Skipped', 'Skipped Item(\arLow Bag Space\ax): %s (%s-%s)[\ar%s\ax]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, 'Ignore')
                    goto continue
                end
                if corpseItem.Lore() then
                    if haveItem or haveItemBank then
                        LootUtils.logReport('Skipped', 'Skipped Item(\arLore\ax): %s (%s-%s)[\ar%s\ax]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, 'Ignore')
                        goto continue
                    else
                        lootItem(i, getRule(corpseItem), 'leftmouseup')
                    end
                else
                    if freeSpace > LootUtils.SaveBagSlots or (stackable and freeStack > 0) then
                        lootItem(i, getRule(corpseItem), 'leftmouseup')
                    end
                end

                if lootAction == 'Ignore' or lootAction == 'NULL' then
                    LootUtils.logReport('Ignore', 'Ignore Item: %s (%s-%s)[\ar%s\ax]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, 'Ignore')
                end
                if lootAction == 'Announce' then
                    LootUtils.logReport('Announce', 'Found: %s (%s-%s)[\ag%s\ax]', corpseItem.ItemLink('CLICKABLE')(), corpseName, corpseID, getRule(corpseItem))
                end
            end
            ::continue::
            mq.delay(25)
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
        if corpseID and corpseID > 0 and not corpseLocked(corpseID) then
            if LootUtils.useWarp then
                navToID(corpseID)
            end
            if (mq.TLO.Navigation.PathLength('spawn id ' .. tostring(corpseID))() or 100) < 60 then
                LootUtils.ConsoleMessage('Debug', 'Moving to corpse ID=%s', tostring(corpseID))
                navToID(corpseID)
            end
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
        LootUtils.Storage.SetINIValue(LootUtils.Settings.LootFile, firstLetter, itemName, 'Sell')
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

function LootUtils.sellStuff(closeWindowWhenDone, requireRuleToSell)
    if closeWindowWhenDone == nil then closeWindowWhenDone = false end
    if requireRuleToSell == nil then requireRuleToSell = true end
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
                    if (requireRuleToSell and (sellRule == 'Sell' or sellRule == 'NULL')) or (not requireRuleToSell and (sellRule == 'Sell' or sellRule == 'NULL' or sellRule == 'Ignore')) then
                        local sellPrice = bagSlot.Item(j).Value() and bagSlot.Item(j).Value() / 1000 or 0
                        if sellPrice == 0 then
                            LootUtils.ConsoleMessage('Info', 'Item \ay%s\ax is set to Sell but has no sell value!', itemToSell.Name())
                            -- addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
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
