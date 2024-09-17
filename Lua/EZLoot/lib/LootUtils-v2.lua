--[[
lootnscoot.lua v1.7 - aquietone, grimmier

This is a port of the RedGuides copy of ninjadvLootUtils.inc with some updates as well.
I may have glossed over some of the events or edge cases so it may have some issues
around things like:
- lore items
- full inventory
- not full inventory but no slot large enough for an item
- ...
Or those things might just work, I just haven't tested it very much using lvl 1 toons
on project lazarus.

This script can be used in two ways:
    1. Included within a larger script using require, for example if you have some KissAssist-like lua script:
        To loot mobs, call lootutils.lootMobs():

            local mq = require 'mq'
            local lootutils = require 'lootnscoot'
            while true do
                lootutils.lootMobs()
                mq.delay(1000)
            end

        lootUtils.lootMobs() will run until it has attempted to loot all corpses within the defined radius.

        To sell to a vendor, call lootutils.sellStuff():

            local mq = require 'mq'
            local lootutils = require 'lootnscoot'
            local doSell = false
            local function binds(...)
                local args = {...}
                if args[1] == 'sell' then doSell = true end
            end
            mq.bind('/myscript', binds)
            while true do
                lootutils.lootMobs()
                if doSell then lootutils.sellStuff() doSell = false end
                mq.delay(1000)
            end

        lootutils.sellStuff() will run until it has attempted to sell all items marked as sell to the targeted vendor.

        Note that in the above example, LootUtils.sellStuff() isn't being called directly from the bind callback.
        Selling may take some time and includes delays, so it is best to be called from your main loop.

        Optionally, configure settings using:
            Set the radius within which corpses should be looted (radius from you, not a camp location)
                lootutils.CorpseRadius = number
            Set whether LootUtils.ini should be updated based off of sell item events to add manually sold items.
                lootutils.AddNewSales = boolean
            Set your own instance of Write.lua to configure a different prefix, log level, etc.
                LootUtils.Settings.logger = Write
            Several other settings can be found in the "loot" table defined in the code.

    2. Run as a standalone script:
        /lua run lootnscoot standalone
            Will keep the script running, checking for corpses once per second.
        /lua run lootnscoot once
            Will run one iteration of LootUtils.lootMobs().
        /lua run lootnscoot sell
            Will run one iteration of LootUtils.sellStuff().
        /lua run lootnscoot cleanup
            Will run one iteration of LootUtils.cleanupBags().

The script will setup a bind for "/lootutils":
    /lootutils <action> "${Cursor.Name}"
        Set the loot rule for an item. "action" may be one of:
            - Keep
            - Bank
            - Sell
            - Tribute
            - Ignore
            - Destroy
            - Quest|#

    /lootutils reload
        Reload the contents of LootUtils.ini
    /lootutils bank
        Put all items from inventory marked as Bank into the bank
    /lootutils tsbank
        Mark all tradeskill items in inventory as Bank

If running in standalone mode, the bind also supports:
    /lootutils sellstuff
        Runs lootutils.sellStuff() one time
    /lootutils tributestuff
        Runs lootutils.tributeStuff() one time
    /lootutils cleanup
        Runs lootutils.cleanupBags() one time

The following events are used:
    - eventCantLoot - #*#may not loot this corpse#*#
        Add corpse to list of corpses to avoid for a few minutes if someone is already looting it.
    - eventSell - #*#You receive#*# for the #1#(s)#*#
        Set item rule to Sell when an item is manually sold to a vendor
    - eventInventoryFull - #*#Your inventory appears full!#*#
        Stop attempting to loot once inventory is full. Note that currently this never gets set back to false
        even if inventory space is made available.
    - eventNovalue - #*#give you absolutely nothing for the #1#.#*#
        Warn and move on when attempting to sell an item which the merchant will not buy.

This script depends on having Write.lua in your lua/lib folder.
    https://gitlab.com/Knightly1/knightlinc/-/blob/master/Write.lua

This does not include the buy routines from ninjadvLootUtils. It does include the sell routines
but lootly sell routines seem more robust than the code that was in ninjadvLootUtils.inc.
The forage event handling also does not handle fishing events like ninjadvloot did.
There is also no flag for combat looting. It will only loot if no mobs are within the radius.

]]

---@type Mq
local mq = require 'mq'
local success, Write = pcall(require, 'lib.Write')
if not success then
    printf('\arERROR: Write.lua could not be loaded\n%s\ax', Write)
    return
end

local eqServer = string.gsub(mq.TLO.EverQuest.Server(), ' ', '_')
-- Check for looted module, if found use that. else fall back on our copy, which may be outdated.
local req, guiLoot = pcall(require, string.format('../looted/init'))
if not req then
    req, guiLoot = pcall(require, 'loot_hist')
    print('Looted Not Found! Using Local Copy!')
else print('Looted Loaded!') end
if not req then
    guiLoot = nil
    print('NO LOOTED Found, Disabling Looted Features.')
end
local eqChar = mq.TLO.Me.Name()
local actors = require('actors')
local version = 1.7

-- Public default settings, also read in from LootUtils.ini [Settings] section
LootUtils = {
    logger = Write,
    Version = '"' .. tostring(version) .. '"',
    GlobalLootOn = true,                           -- Enable Global Loot Items. not implimented yet
    CombatLooting = false,                         -- Enables looting during combat. Not recommended on the MT
    CorpseRadius = 100,                            -- Radius to activly loot corpses
    MobsTooClose = 40,                             -- Don't loot if mobs are in this range.
    SaveBagSlots = 3,                              -- Number of bag slots you would like to keep empty at all times. Stop looting if we hit this number
    TributeKeep = false,                           -- Keep items flagged Tribute
    MinTributeValue = 100,                         -- Minimun Tribute points to keep item if TributeKeep is enabled.
    MinSellPrice = -1,                             -- Minimum Sell price to keep item. -1 = any
    StackPlatValue = 0,                            -- Minimum sell value for full stack
    StackableOnly = false,                         -- Only loot stackable items
    AlwaysEval = false,                            -- Re-Evaluate all *Non Quest* items. useful to update LootUtils.ini after changing min sell values.
    BankTradeskills = true,                        -- Toggle flagging Tradeskill items as Bank or not.
    DoLoot = true,                                 -- Enable auto looting in standalone mode
    LootForage = true,                             -- Enable Looting of Foraged Items
    LootNoDrop = false,                            -- Enable Looting of NoDrop items.
    LootNoDropNew = false,                         -- Enable looting of new NoDrop items.
    LootQuest = false,                             -- Enable Looting of Items Marked 'Quest', requires LootNoDrop on to loot NoDrop quest items
    DoDestroy = false,                             -- Enable Destroy functionality. Otherwise 'Destroy' acts as 'Ignore'
    AlwaysDestroy = false,                         -- Always Destroy items to clean corpese Will Destroy Non-Quest items marked 'Ignore' items REQUIRES DoDestroy set to true
    QuestKeep = 10,                                -- Default number to keep if item not set using Quest|# format.
    LootChannel = "dgt",                           -- Channel we report loot to.
    GroupChannel = "dgae",                         -- Channel we use for Group Commands
    ReportLoot = true,                             -- Report loot items to group or not.
    SpamLootInfo = false,                          -- Echo Spam for Looting
    LootForageSpam = false,                        -- Echo spam for Foraged Items
    AddNewSales = true,                            -- Adds 'Sell' Flag to items automatically if you sell them while the script is running.
    AddNewTributes = true,                         -- Adds 'Tribute' Flag to items automatically if you Tribute them while the script is running.
    GMLSelect = true,                              -- not implimented yet
    ExcludeBag1 = "Extraplanar Trade Satchel",     -- Name of Bag to ignore items in when selling
    NoDropDefaults = "Quest|Keep|Ignore|Announce", -- not implimented yet
    LootLagDelay = 0,                              -- not implimented yet
    CorpseRotTime = "440s",                        -- not implimented yet
    HideNames = false,                             -- Hides names and uses class shortname in looted window
    LookupLinks = false,                           -- Enables Looking up Links for items not on that character. *recommend only running on one charcter that is monitoring.
    RecordData = false,                            -- Enables recording data to report later.
    Terminate = true,
    LootTradeSkill = true,
    ReportSkipped = true,
    AnnounceChannel = 'rsay',
    useZoneLootFile = false,
    useClassLootFile = true,
    useArmorTypeLootFile = true,
}

if guiLoot ~= nil then
    LootUtils.guiLootUtils.imported = true
    LootUtils.UseActors = true
end

local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
LootUtils.Settings = {
    Terminate = true,
    logger = Write,
    LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_Name .. '.ini'
    -- LootLagDelay = 0,
    -- GlobalLootOn = true,
    -- CorpseRotTime = "440s",
    -- GMLSelect = true,
    -- ExcludeBag1 = "Extraplanar Trade Satchel",
    -- QuestKeep = 10,
}

LootUtils.Settings.logger.prefix = 'EZLoot'
local function SetINIType()
    local my_ArmorType
    if LootUtils.useArmorTypeLootFile then
        if my_Class == 'Bard' or my_Class == 'Cleric' or my_Class == 'Paladin' or my_Class == 'Shadow Knight' or my_Class == 'Warrior' then
            my_ArmorType = 'Plate'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir ..
                    '\\EZLoot\\EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_ArmorType .. '.ini'
            end
        elseif my_Class == 'Berserker' or my_Class == 'Rogue' or my_Class == 'Shaman' then
            my_ArmorType = 'Chain'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir ..
                    '\\EZLoot\\EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_ArmorType .. '.ini'
            end
        elseif my_Class == 'Enchanter' or my_Class == 'Magician' or my_Class == 'Necromancer' or my_Class == 'Wizard' then
            my_ArmorType = 'Cloth'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir ..
                    '\\EZLoot\\EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_ArmorType .. '.ini'
            end
        elseif my_Class == 'Beastlord' or my_Class == 'Druid' or my_Class == 'Monk' then
            my_ArmorType = 'Leather'
            if LootUtils.useZoneLootFile then
                LootUtils.Settings.LootFile = mq.configDir ..
                    '\\EZLoot\\EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_ArmorType .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_ArmorType .. '.ini'
            end
        end
    else
        if LootUtils.useZoneLootFile then
            if LootUtils.useClassLootFile then
                LootUtils.Settings.LootFile = mq.configDir ..
                    '\\EZLoot\\EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_Class .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir ..
                    '\\EZLoot\\EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_Name .. '.ini'
            end
        else
            if LootUtils.useClassLootFile then
                LootUtils.Settings.LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_Class .. '.ini'
            else
                LootUtils.Settings.LootFile = mq.configDir .. '\\EZLoot\\EZLoot.' .. my_Name .. '.ini'
            end
        end
    end
    printf('LootFile: %s', LootUtils.Settings.LootFile)
end
SetINIType()
-- Internal settings
local lootData, cantLootList = {}, {}
local doSell, doTribute, areFull = false, false, false
local cantLootID = 0

-- Constants
local spawnSearch = '%s radius %d zradius 50'
-- If you want destroy to actually loot and destroy items, change DoDestroy=false to DoDestroy=true in the Settings Ini.
-- Otherwise, destroy behaves the same as ignore.
local shouldLootActions = {
    Keep = true,
    Bank = true,
    Sell = true,
    Destroy = false,
    Ignore = false,
    Quest = true,
    Announce = true,
    Tribute = false
}
local validActions = {
    keep = 'Keep',
    bank = 'Bank',
    sell = 'Sell',
    ignore = 'Ignore',
    destroy = 'Destroy',
    quest = 'Quest',
    announce = 'Announce',
    tribute = 'Tribute'
}
local saveOptionTypes = { string = 1, number = 1, boolean = 1 }
local NEVER_SELL = { ['Diamond Coin'] = true, ['Celestial Crest'] = true, ['Gold Coin'] = true, ['Taelosian Symbols'] = true,
    ['Planar Symbols'] = true }
local tmpCmd = LootUtils.GroupChannel or 'dgae'
-- FORWARD DECLARATIONS

local eventForage, eventSell, eventCantLoot, eventTribute, eventNoSlot

-- UTILITIES

function LootUtils.writeSettings()
    for option, value in pairs(LootUtils) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, 'Settings', option, value)
        end
    end
    for asciiValue = 65, 90 do
        local character = string.char(asciiValue)
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, character, 'Defaults', LootUtils.NoDropDefaults)
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
            LootUtils[key] = tostring(value)
        elseif value == 'true' or value == 'false' then
            LootUtils[key] = value == 'true' and true or false
        elseif tonumber(value) then
            LootUtils[key] = tonumber(value)
        else
            LootUtils[key] = value
        end
    end
    if tonumber(LootUtils.Version) < tonumber(version) then
        LootUtils.Version = tostring(version)
        print('Updating Settings File to Version ' .. tostring(version))
        LootUtils.writeSettings()
    end
    tmpCmd = LootUtils.GroupChannel or 'dgae'
    if tmpCmd == string.find(tmpCmd, 'dg') then
        tmpCmd = '/' .. tmpCmd
    elseif tmpCmd == string.find(tmpCmd, 'bc') then
        tmpCmd = '/' .. tmpCmd .. ' /'
    end
    shouldLootActions.Destroy = LootUtils.DoDestroy
    shouldLootActions.Tribute = LootUtils.TributeKeep
end

local function checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        -- can't do anything if there's nowhere to put the item, either due to no free inventory space
        -- or no slot of appropriate size
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if LootUtils.SpamLootInfo then LootUtils.Settings.logger.Debug('Inventory full, item stuck on cursor') end
            mq.cmd('/autoinv')
            return
        end
        currentItem = mq.TLO.Cursor()
        mq.cmd('/autoinv')
        mq.delay(100)
    end
end

local function navToID(spawnID)
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

local function addRule(itemName, section, rule)
    if not lootData[section] then
        lootData[section] = {}
    end
    lootData[section][itemName] = rule
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, section, itemName, rule)
end

local function lookupIniLootRule(section, key)
    return mq.TLO.Ini.File(LootUtils.Settings.LootFile).Section(section).Key(key).Value()
end

-- moved this function up so we can report Quest Items.
local reportPrefix = '/%s \a-t[\at%s\a-t][\ax\ayLootUtils\ax\a-t]\ax '
local function report(message, ...)
    if LootUtils.ReportLoot then
        local prefixWithChannel = reportPrefix:format(LootUtils.LootChannel, mq.TLO.Time())
        mq.cmdf(prefixWithChannel .. message, ...)
    end
end

local function AreBagsOpen()
    local total = {
        bags = 0,
        open = 0,
    }
    for i = 23, 32 do
        local slot = mq.TLO.Me.Inventory(i)
        if slot and slot.Container() and slot.Container() > 0 then
            total.bags = total.bags + 1
            if slot.Open() then
                total.open = total.open + 1
            end
        end
    end
    if total.bags == total.open then
        return true
    else
        return false
    end
end

---@return string,number,boolean
local function getRule(item)
    local itemName = item.Name()
    local lootDecision = 'Ignore'
    local tradeskill = item.Tradeskills()
    local sellPrice = item.Value() and item.Value() / 1000 or 0
    local stackable = item.Stackable()
    local tributeValue = item.Tribute()
    local firstLetter = itemName:sub(1, 1):upper()
    local stackSize = item.StackSize()
    local countHave = mq.TLO.FindItemCount(string.format("%s", itemName))() +
    mq.TLO.FindItemBankCount(string.format("%s", itemName))()
    local qKeep = '0'
    local globalItem = lookupIniLootRule('GlobalItems', itemName)
    local newRule = false

    lootData[firstLetter] = lootData[firstLetter] or {}
    lootData[firstLetter][itemName] = lootData[firstLetter][itemName] or lookupIniLootRule(firstLetter, itemName)

    -- Re-Evaluate the settings if AlwaysEval is on. Items that do not meet the Characters settings are reset to NUll and re-evaluated as if they were new items.
    if LootUtils.AlwaysEval then
        local oldDecision = lootData[firstLetter][itemName] -- whats on file
        local resetDecision = 'NULL'
        if string.find(oldDecision, 'Quest') or oldDecision == 'Keep' or oldDecision == 'Destroy' then resetDecision =
            oldDecision end
        -- If sell price changed and item doesn't meet the new value re-evalute it otherwise keep it set to sell
        if oldDecision == 'Sell' and not stackable and sellPrice >= LootUtils.MinSellPrice then resetDecision =
            oldDecision end
        -- -- Do the same for stackable items.
        if (oldDecision == 'Sell' and stackable) and (sellPrice * stackSize >= LootUtils.StackPlatValue) then resetDecision =
            oldDecision end
        -- if banking tradeskills settings changed re-evaluate
        if oldDecision == 'Bank' and tradeskill and LootUtils.BankTradeskills then resetDecision = oldDecision end
        lootData[firstLetter][itemName] =
        resetDecision                                   -- pass value on to next check. Items marked 'NULL' will be treated as new and evaluated properly.
    end
    if lootData[firstLetter][itemName] == 'NULL' then
        if noDrop and not canUse then lootDecision = 'Ignore' end
        if LootUtils.LootTradeSkill and tradeskill then lootDecision = 'Bank' end
        if sellPrice ~= 0 and sellPrice >= LootUtils.MinSellPrice then lootDecision = 'Sell' end
        if not stackable and LootUtils.StackableOnly then lootDecision = 'Ignore' end
        if (stackable and LootUtils.StackPlatValue > 0) and (sellPrice * stackSize < LootUtils.StackPlatValue) then lootDecision =
            'Sell' end
        -- set Tribute flag if tribute value is greater than minTributeValue and the sell price is less than min sell price or has no value
        if tributeValue >= LootUtils.MinTributeValue and (sellPrice < LootUtils.MinSellPrice or sellPrice == 0) then lootDecision =
            'Tribute' end
        addRule(itemName, firstLetter, lootDecision)
        newRule = true
    end
    -- check this before quest item checks. so we have the proper rule to compare.
    -- Check if item is on global Items list, ignore everything else and use those rules insdead.
    if LootUtils.GlobalLootOn and globalItem ~= 'NULL' then
        lootData[firstLetter][itemName] = globalItem or lootData[firstLetter][itemName]
    end
    -- Check if item marked Quest
    if string.find(lootData[firstLetter][itemName], 'Quest') then
        local qVal = 'Ignore'
        -- do we want to loot quest items?
        if LootUtils.LootQuest then
            --look to see if Quantity attached to Quest|qty
            local _, position = string.find(lootData[firstLetter][itemName], '|')
            if position then qKeep = string.sub(lootData[firstLetter][itemName], position + 1) else qKeep = '0' end
            -- if Quantity is tied to the entry then use that otherwise use default Quest Keep Qty.
            if qKeep == '0' then
                qKeep = tostring(LootUtils.QuestKeep)
            end
            -- If we have less than we want to keep loot it.
            if countHave < tonumber(qKeep) then
                qVal = 'Keep'
            end
            if LootUtils.AlwaysDestroy and qVal == 'Ignore' then qVal = 'Destroy' end
        end
        return qVal, tonumber(qKeep) or 0
    end
    if LootUtils.AlwaysDestroy and lootData[firstLetter][itemName] == 'Ignore' then return 'Destroy', 0 end
    return lootData[firstLetter][itemName], 0, newRule
end

-- EVENTS

local lootActor = actors.register('lootnscoot', function(message) end)

local itemNoValue = nil
local function eventNovalue(line, item)
    itemNoValue = item
end

local function setupEvents()
    mq.event("CantLoot", "#*#may not loot this corpse#*#", eventCantLoot)
    mq.event("NoSlot", "#*#There are no open slots for the held item in your inventory#*#", eventNoSlot)
    mq.event("Sell", "#*#You receive#*# for the #1#(s)#*#", eventSell)
    if LootUtils.LootForage then
        mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", eventForage)
        mq.event("Forage", "You have scrounged up #*#", eventForage)
    end
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", eventNovalue)
    mq.event("Tribute", "#*#We graciously accept your #1# as tribute, thank you!#*#", eventTribute)
end

-- BINDS

local function commandHandler(...)
    local args = { ... }
    if #args == 1 then
        if args[1] == 'sellstuff' and not LootUtils.Settings.Terminate then
            doSell = true
        elseif args[1] == 'reload' then
            lootData = {}
            LootUtils.loadSettings()
            LootUtils.guiLootUtils.GetSettings(LootUtils.HideNames, LootUtils.LookupLinks, LootUtils.RecordData)
            LootUtils.Terminate = false
            LootUtils.Settings.logger.Info("\ayReloaded Settings \axAnd \atLoot Files")
        elseif args[1] == 'bank' then
            LootUtils.processItems('Bank')
        elseif args[1] == 'cleanup' then
            LootUtils.processItems('Cleanup')
        elseif args[1] == 'gui' then
            LootUtils.guiLootUtils.openGUI = not LootUtils.guiLootUtils.openGUI
        elseif args[1] == 'report' then
            LootUtils.guiLootUtils.ReportLoot()
        elseif args[1] == 'hidenames' then
            LootUtils.guiLootUtils.hideNames = not LootUtils.guiLootUtils.hideNames
        elseif args[1] == 'config' then
            local confReport = string.format("\ayLoot N Scoot Settings\ax")
            for key, value in pairs(LootUtils) do
                if type(value) ~= "function" and type(value) ~= "table" then
                    confReport = confReport .. string.format("\n\at%s\ax = \ag%s\ax", key, tostring(value))
                end
            end
            LootUtils.Settings.logger.Info(confReport)
        elseif args[1] == 'tributestuff' then
            doTribute = true
        elseif args[1] == 'loot' then
            LootUtils.lootMobs()
        elseif args[1] == 'tsbank' then
            LootUtils.markTradeSkillAsBank()
        elseif validActions[args[1]] and mq.TLO.Cursor() then
            addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1), validActions[args[1]])
            LootUtils.Settings.llogger.Info(string.format("Setting \ay%s\ax to \ay%s\ax", mq.TLO.Cursor(),
                validActions[args[1]]))
        end
    elseif #args == 2 then
        if args[1] == 'quest' and mq.TLO.Cursor() then
            addRule(mq.TLO.Cursor(), mq.TLO.Cursor():sub(1, 1), 'Quest|' .. args[2])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ayQuest|%s\ax", mq.TLO.Cursor(), args[2]))
        elseif args[1] == 'globalitem' and validActions[args[2]] and mq.TLO.Cursor() then
            addRule(mq.TLO.Cursor(), 'GlobalItems', validActions[args[2]])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ay%s\ax", mq.TLO.Cursor(),
                validActions[args[2]]))
        elseif validActions[args[1]] and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1, 1), validActions[args[1]])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ay%s\ax", args[2], validActions[args[1]]))
        end
    elseif #args == 3 then
        if args[1] == 'globalitem' and args[2] == 'quest' and mq.TLO.Cursor() then
            addRule(mq.TLO.Cursor(), 'GlobalItems', 'Quest|' .. args[3])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ayQuest|%s\ax", mq.TLO.Cursor(), args[3]))
        elseif args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= 'NULL' then
            addRule(args[3], 'GlobalItems', validActions[args[2]])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ay%s\ax", args[3], validActions[args[2]]))
        elseif validActions[args[1]] and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1, 1), validActions[args[1]] .. '|' .. args[3])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ay%s|%s\ax", args[2],
                validActions[args[1]], args[3]))
        end
    elseif #args == 4 then
        if args[1] == 'globalitem' and validActions[args[2]] and args[3] ~= 'NULL' then
            addRule(args[3], 'GlobalItems', validActions[args[2]] .. '|' .. args[4])
            LootUtils.Settings.logger.Info(string.format("Setting \ay%s\ax to \ay%s|%s\ax", args[3],
                validActions[args[2]], args[4]))
        end
    end
end

local function setupBinds()
    mq.bind('/lootutils', commandHandler)
end

local reportPrefix = '/%s \a-t]\ax\ayEZLoot\ax\a-t]\ax '
local function report(message, ...)
    if LootUtils.ReportLoot then
        local prefixWithChannel = reportPrefix:format(LootUtils.LootChannel)
        mq.cmdf(prefixWithChannel .. message, ...)
    end
end

-- LOOTING

local function CheckBags()
    areFull = mq.TLO.Me.FreeInventory() <= LootUtils.SaveBagSlots
end

function eventCantLoot()
    cantLootID = mq.TLO.Target.ID()
end

function eventNoSlot()
    -- we don't have a slot big enough for the item on cursor. Dropping it to the ground.
    local cantLootItemName = mq.TLO.Cursor()
    mq.cmd('/drop')
    mq.delay(1)
    report("\ay[WARN]\arI can't loot %s, dropping it on the ground!\ax", cantLootItemName)
end

---@param index number @The current index we are looking at in loot window, 1-based.
---@param doWhat string @The action to take for the item.
---@param button string @The mouse button to use to loot the item. Currently only leftmouseup implemented.
---@param qKeep number @The count to keep, for quest items.
---@param allItems table @Table of all items seen so far on the corpse, left or looted.
local function lootItem(index, doWhat, button, qKeep, allItems)
    LootUtils.Settings.logger.Debug('Enter lootItem')
    local corpseName = mq.TLO.Corpse.Name()
    local corpseItemID = mq.TLO.Corpse.Item(index).ID()
    local corpseItem = mq.TLO.Corpse.Item(index)
    local itemLink = corpseItem.ItemLink('CLICKABLE')()
    local itemName = mq.TLO.Corpse.Item(index).Name()

    local ruleAction = doWhat
    if doWhat == 'Announce' then
        mq.cmdf('/%s Found: %s (%s)', EZLoot.AnnounceChannel, itemLink, corpseName)
        return
    end
    if string.find(doWhat, "Quest|") == 1 then
        local lootRule = split(doWhat)
        ruleAction = lootRule[1]       -- what to do with the item
        local ruleAmount = lootRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('=' .. itemName)()

        --if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= tonumber(ruleAmount)) then return end
        if EZLoot.debug then printf('DoWhat: %s / ruleAction: %s / ruleAmount: %s / currentItemAmount: %s', doWhat,
                ruleAction, ruleAmount, currentItemAmount) end
        if ruleAction == 'Quest' and currentItemAmount >= tonumber(ruleAmount) then return end
    else
        if not shouldLootActions[ruleAction] then return end
    end

    mq.cmdf('/nomodkey /shift /itemnotify loot%s %s', index, button)
    -- Looting of no drop items is currently disabled with no flag to enable anyways
    -- added check to make sure the cursor isn't empty so we can exit the pause early.-- or not mq.TLO.Corpse.Item(index).NoDrop()
    mq.delay(1) -- for good measure.
    mq.delay(5000, function() return mq.TLO.Window('ConfirmationDialogBox').Open() or mq.TLO.Cursor() == nil end)
    if mq.TLO.Window('ConfirmationDialogBox').Open() then mq.cmd(
        '/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup') end
    mq.delay(5000, function() return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open() end)
    mq.delay(1) -- force next frame
    -- The loot window closes if attempting to loot a lore item you already have, but lore should have already been checked for
    if not mq.TLO.Window('LootWnd').Open() then return end
    if doWhat == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then
        mq.cmd('/destroy')
        table.insert(allItems, { Name = itemName, Action = 'Destroyed', Link = itemLink })
    end
    checkCursor()
    if qKeep > 0 and doWhat == 'Keep' then
        local countHave = mq.TLO.FindItemCount(string.format("%s", itemName))() +
        mq.TLO.FindItemBankCount(string.format("%s", itemName))()
        report("\awQuest Item:\ag %s \awCount:\ao %s \awof\ag %s", itemLink, tostring(countHave), qKeep)
    else
        report('%sing \ay%s\ax', doWhat, itemLink)
    end
    if doWhat ~= 'Destroy' then
        table.insert(allItems, { Name = itemName, Action = 'Looted', Link = itemLink })
    end
    CheckBags()
    if areFull then report('My bags are full, I can\'t loot anymore! Turning OFF Looting until we sell.') end
end

local function lootCorpse(corpseID)
    CheckBags()
    if areFull then return end
    LootUtils.Settings.logger.Debug('Enter lootCorpse')
    if mq.TLO.Cursor() then checkCursor() end
    for i = 1, 3 do
        mq.cmd('/loot')
        mq.delay(1000, function() return mq.TLO.Window('LootWnd').Open() end)
        if mq.TLO.Window('LootWnd').Open() then break end
    end
    mq.doevents('CantLoot')
    mq.delay(3000, function() return cantLootID > 0 or mq.TLO.Window('LootWnd').Open() end)
    if not mq.TLO.Window('LootWnd').Open() then
        if mq.TLO.Target.CleanName() ~= nil then
            LootUtils.Settings.logger.Warn(('Can\'t loot %s right now'):format(mq.TLO.Target.CleanName()))
            cantLootList[corpseID] = os.time()
        end
        return
    end
    mq.delay(1000, function() return (mq.TLO.Corpse.Items() or 0) > 0 end)
    local items = mq.TLO.Corpse.Items() or 0
    LootUtils.Settings.logger.Debug(('Loot window open. Items: %s'):format(items))
    local corpseName = mq.TLO.Corpse.Name()
    if mq.TLO.Window('LootWnd').Open() and items > 0 then
        if mq.TLO.Corpse.DisplayName() == mq.TLO.Me.DisplayName() then
            mq.cmd('/lootall')
            return
        end                                                                                          -- if its our own corpse just loot it.
        local noDropItems = {}
        local loreItems = {}
        local allItems = {}
        for i = 1, items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            local itemLink = corpseItem.ItemLink('CLICKABLE')()
            if corpseItem() then
                local itemRule, qKeep, newRule = getRule(corpseItem)
                local stackable = corpseItem.Stackable()
                local freeStack = corpseItem.FreeStack()
                -- if corpseItem.NoDrop() then
                --     --table.insert(noDropItems, corpseItem.ItemLink('CLICKABLE')())
                -- else
                if corpseItem.Lore() then
                    local haveItem = mq.TLO.FindItem(('=%s'):format(corpseItem.Name()))()
                    local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(corpseItem.Name()))()
                    if haveItem or haveItemBank or freeSpace <= LootUtils.SaveBagSlots then
                        table.insert(loreItems, itemLink)
                        lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                    elseif corpseItem.NoDrop() then
                        if LootUtils.LootNoDrop then
                            if not newRule or (newRule and LootUtils.LootNoDropNew) then
                                lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                            end
                        else
                            table.insert(noDropItems, itemLink)
                            lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                        end
                    else
                        lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                    end
                elseif corpseItem.NoDrop() then
                    if LootUtils.LootNoDrop then
                        if not newRule or (newRule and LootUtils.LootNoDropNew) then
                            lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                        end
                    else
                        table.insert(noDropItems, itemLink)
                        lootItem(i, 'Ignore', 'leftmouseup', 0, allItems)
                    end
                elseif freeSpace > LootUtils.SaveBagSlots or (stackable and freeStack > 0) then
                    lootItem(i, itemRule, 'leftmouseup', qKeep, allItems)
                end
            end
            mq.delay(1)
            if mq.TLO.Cursor() then checkCursor() end
            mq.delay(1)
            if not mq.TLO.Window('LootWnd').Open() then break end
        end
        if LootUtils.ReportLoot and LootUtils.ReportSkipped and (#noDropItems > 0 or #loreItems > 0) then
            local skippedItems = '/%s Skipped loots (%s - %s) '
            for _, noDropItem in ipairs(noDropItems) do
                skippedItems = skippedItems .. ' ' .. noDropItem .. ' (nodrop) '
            end
            for _, loreItem in ipairs(loreItems) do
                skippedItems = skippedItems .. ' ' .. loreItem .. ' (lore) '
            end
            mq.cmdf(skippedItems, LootUtils.LootChannel, corpseName, corpseID)
        end
        if #allItems > 0 then
            -- send to self and others running lootnscoot
            lootActor:send({ mailbox = 'looted' }, { ID = corpseID, Items = allItems, LootedAt = mq.TLO.Time(), LootedBy =
            eqChar })
            -- send to standalone looted gui
            lootActor:send({ mailbox = 'looted', script = 'looted' },
                { ID = corpseID, Items = allItems, LootedAt = mq.TLO.Time(), LootedBy = eqChar })
        end
    end
    if mq.TLO.Cursor() then checkCursor() end
    mq.cmd('/nomodkey /notify LootWnd LW_DoneButton leftmouseup')
    mq.delay(3000, function() return not mq.TLO.Window('LootWnd').Open() end)
    -- if the corpse doesn't poof after looting, there may have been something we weren't able to loot or ignored
    -- mark the corpse as not lootable for a bit so we don't keep trying
    if mq.TLO.Spawn(('corpse id %s'):format(corpseID))() then
        cantLootList[corpseID] = os.time()
    end
end

local function corpseLocked(corpseID)
    if not cantLootList[corpseID] then return false end
    if os.difftime(os.time(), cantLootList[corpseID]) > 60 then
        cantLootList[corpseID] = nil
        return false
    end
    return true
end

function LootUtils.lootMobs(limit)
    LootUtils.Settings.logger.Debug('Enter lootMobs')
    local deadCount = mq.TLO.SpawnCount(spawnSearch:format('npccorpse', LootUtils.CorpseRadius))()
    LootUtils.Settings.logger.Debug(string.format('There are %s corpses in range.', deadCount))
    local mobsNearby = mq.TLO.SpawnCount(spawnSearch:format('xtarhater', LootUtils.MobsTooClose))()
    -- options for combat looting or looting disabled
    if deadCount == 0 or ((mobsNearby > 0 or mq.TLO.Me.Combat()) and not LootUtils.CombatLooting) then return false end
    local corpseList = {}
    for i = 1, math.max(deadCount, limit or 0) do
        local corpse = mq.TLO.NearestSpawn(('%d,' .. spawnSearch):format(i, 'npccorpse', LootUtils.CorpseRadius))
        table.insert(corpseList, corpse)
        -- why is there a deity check?
    end
    local didLoot = false
    LootUtils.Settings.logger.Debug(string.format('Trying to loot %d corpses.', #corpseList))
    for i = 1, #corpseList do
        local corpse = corpseList[i]
        local corpseID = corpse.ID()
        if corpseID and corpseID > 0 and not corpseLocked(corpseID) and (mq.TLO.Navigation.PathLength('spawn id ' .. tostring(corpseID))() or 100) < 60 then
            LootUtils.Settings.logger.Debug('Moving to corpse ID=' .. tostring(corpseID))
            navToID(corpseID)
            corpse.DoTarget()
            lootCorpse(corpseID)
            didLoot = true
            mq.doevents('InventoryFull')
        end
    end
    LootUtils.Settings.logger.Debug('Done with corpse list.')
    return didLoot
end

-- SELLING

function eventSell(line, itemName)
    if NEVER_SELL[itemName] then return end
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Sell' then return end
    if lookupIniLootRule(firstLetter, itemName) == 'Sell' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Sell'
        return
    end
    if LootUtils.AddNewSales then
        LootUtils.Settings.logger.Info(string.format('Setting %s to Sell', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        lootData[firstLetter][itemName] = 'Sell'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.Settings.LootFile, firstLetter, itemName, 'Sell')
    end
end

local function goToVendor()
    if not mq.TLO.Target() then
        LootUtils.Settings.logger.Warn('Please target a vendor')
        return false
    end
    local vendorName = mq.TLO.Target.CleanName()

    LootUtils.Settings.logger.Info('Doing business with ' .. vendorName)
    if mq.TLO.Target.Distance() > 15 then
        navToID(mq.TLO.Target.ID())
    end
    return true
end

local function openVendor()
    LootUtils.Settings.logger.Debug('Opening merchant window')
    mq.cmd('/nomodkey /click right target')
    LootUtils.Settings.logger.Debug('Waiting for merchant window to populate')
    mq.delay(1000, function() return mq.TLO.Window('MerchantWnd').Open() end)
    if not mq.TLO.Window('MerchantWnd').Open() then return false end
    mq.delay(5000, function() return mq.TLO.Merchant.ItemsReceived() end)
    return mq.TLO.Merchant.ItemsReceived()
end

local function sellToVendor(itemToSell, bag, slot)
    if NEVER_SELL[itemToSell] then return end
    if mq.TLO.Window('MerchantWnd').Open() then
        LootUtils.Settings.logger.Info('Selling ' .. itemToSell)
        if slot == nil or slot == -1 then
            mq.cmdf('/nomodkey /itemnotify %s leftmouseup', bag)
        else
            mq.cmdf('/nomodkey /itemnotify in pack%s %s leftmouseup', bag, slot)
        end
        mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
        mq.cmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
        mq.doevents('eventNovalue')
        if itemNoValue == itemToSell then
            addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
            itemNoValue = nil
        end
        -- TODO: handle vendor not wanting item / item can't be sold
        mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
    end
end

-- TRIBUTEING

local function openTribMaster()
    LootUtils.Settings.logger.Debug('Opening Tribute Window')
    mq.cmd('/nomodkey /click right target')
    LootUtils.Settings.logger.Debug('Waiting for Tribute Window to populate')
    mq.delay(1000, function() return mq.TLO.Window('TributeMasterWnd').Open() end)
    if not mq.TLO.Window('TributeMasterWnd').Open() then return false end
    return mq.TLO.Window('TributeMasterWnd').Open()
end

function eventTribute(line, itemName)
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Tribute' then return end
    if lookupIniLootRule(firstLetter, itemName) == 'Tribute' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Tribute'
        return
    end
    if LootUtils.AddNewTributes then
        LootUtils.Settings.logger.Info(string.format('Setting %s to Tribute', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        lootData[firstLetter][itemName] = 'Tribute'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.LootFile, firstLetter, itemName, 'Tribute')
    end
    mq.flushevents('Sell')
    if mq.TLO.Window('MerchantWnd').Open() and closeWindowWhenDone then mq.cmd(
        '/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup') end
    local newTotalPlat = mq.TLO.Me.Platinum() - totalPlat
    LootUtils.Settings.logger.Info(string.format('Total plat value sold: \ag%s\ax', newTotalPlat))
end

local function tributeToVendor(itemToTrib, bag, slot)
    if NEVER_SELL[itemToTrib.Name()] then return end
    if mq.TLO.Window('TributeMasterWnd').Open() then
        LootUtils.Settings.logger.Info('Tributeing ' .. itemToTrib.Name())
        report('\ayTributing \at%s \axfor\ag %s \axpoints!', itemToTrib.Name(), itemToTrib.Tribute())
        mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
        mq.delay(1) -- progress frame

        mq.delay(5000,
            function()
                return mq.TLO.Window('TributeMasterWnd').Child('TMW_ValueLabel').Text() == tostring(itemToTrib.Tribute()) and
                    mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').Enabled()
            end)

        mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').LeftMouseUp()
        mq.delay(1)
        mq.delay(5000, function() return not mq.TLO.Window('TributeMasterWnd').Child('TMW_DonateButton').Enabled() end)
        mq.delay(1000) -- This delay is necessary because there is seemingly a delay between donating and selecting the next item.
    end
end

-- CLEANUP

local function destroyItem(itemToDestroy, bag, slot)
    if NEVER_SELL[itemToDestroy.Name()] then return end
    LootUtils.Settings.logger.Info('!!Destroying!! ' .. itemToDestroy.Name())
    mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    mq.delay(1) -- progress frame
    mq.cmdf('/destroy')
    mq.delay(1)
    mq.delay(1000, function() return not mq.TLO.Cursor() end)
    mq.delay(1)
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

local function bankItem(itemName, bag, slot)
    if not slot or slot == -1 then
        mq.cmdf('/shift /itemnotify %s leftmouseup', bag)
    else
        mq.cmdf('/shift /itemnotify in pack%s %s leftmouseup', bag, slot)
    end
    mq.delay(100, function() return mq.TLO.Cursor() end)
    mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
    mq.delay(100, function() return not mq.TLO.Cursor() end)
end

function LootUtils.bankStuff()
    if not mq.TLO.Window('BigBankWnd').Open() then
        LootUtils.Settings.logger.Warn('Bank window must be open!')
        return
    end
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToBank = bagSlot.Name()
                local bankRule = getRule(bagSlot)
                if bankRule == 'Bank' then bankItem(itemToBank) end
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
                    if bankRule == 'Bank' then bankItem(itemToBank) end
                end
            end
        end
    end
end

-- FORAGING

function eventForage()
    LootUtils.Settings.logger.Debug('Enter eventForage')
    -- allow time for item to be on cursor incase message is faster or something?
    mq.delay(1000, function() return mq.TLO.Cursor() end)
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
                if LootUtils.LootForageSpam then LootUtils.Settings.logger.Info('Destroying foraged item ' .. foragedItem) end
                mq.cmd('/destroy')
                mq.delay(500)
            end
            -- will a lore item we already have even show up on cursor?
            -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if LootUtils.LootForageSpam then LootUtils.Settings.logger.Info('Keeping foraged item ' .. foragedItem) end
            mq.cmd('/autoinv')
        else
            if LootUtils.LootForageSpam then LootUtils.Settings.logger.Warn('Unable to process item ' .. foragedItem) end
            break
        end
        mq.delay(50)
    end
end

-- Process Items

function LootUtils.processItems(action)
    local flag = false
    local totalPlat = 0

    local function processItem(item, action, bag, slot)
        local rule = getRule(item)
        if rule == action then
            if action == 'Sell' then
                if not mq.TLO.Window('MerchantWnd').Open() then
                    if not goToVendor() then return end
                    if not openVendor() then return end
                end
                --totalPlat = mq.TLO.Me.Platinum()
                local sellPrice = item.Value() and item.Value() / 1000 or 0
                if sellPrice == 0 then
                    LootUtils.Settings.logger.Warn(string.format('Item \ay%s\ax is set to Sell but has no sell value!',
                        item.Name()))
                else
                    sellToVendor(item.Name(), bag, slot)
                    totalPlat = totalPlat + sellPrice
                    mq.delay(1)
                end
            elseif action == 'Tribute' then
                if not mq.TLO.Window('TributeMasterWnd').Open() then
                    if not goToVendor() then return end
                    if not openTribMaster() then return end
                end
                mq.cmd('/keypress OPEN_INV_BAGS')
                mq.delay(1)
                -- tributes requires the bags to be open
                mq.delay(1000, AreBagsOpen)
                mq.delay(1)
                tributeToVendor(item, bag, slot)
                mq.delay(1)
            elseif action == 'Destroy' then
                destroyItem(item, bag, slot)
                mq.delay(1)
            elseif action == 'Bank' then
                if not mq.TLO.Window('BigBankWnd').Open() then
                    LootUtils.Settings.logger.Warn('Bank window must be open!')
                    return
                end
                bankItem(item.Name(), bag, slot)
                mq.delay(1)
            end
        end
    end

    if LootUtils.AlwaysEval then
        flag, LootUtils.AlwaysEval = true, false
    end

    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()

        if containerSize then
            for j = 1, containerSize do
                local item = bagSlot.Item(j)
                if item.ID() then
                    if action == 'Cleanup' then
                        processItem(item, 'Destroy', i, j)
                    elseif action == 'Sell' then
                        processItem(item, 'Sell', i, j)
                    elseif action == 'Tribute' then
                        processItem(item, 'Tribute', i, j)
                    elseif action == 'Bank' then
                        processItem(item, 'Bank', i, j)
                    end
                end
            end
        end
    end

    if flag then
        flag, LootUtils.AlwaysEval = false, true
    end

    if action == 'Tribute' then
        mq.flushevents('Tribute')
        if mq.TLO.Window('TributeMasterWnd').Open() then
            mq.TLO.Window('TributeMasterWnd').DoClose()
            mq.delay(1)
        end
        mq.cmd('/keypress CLOSE_INV_BAGS')
        mq.delay(1)
    elseif action == 'Sell' then
        if mq.TLO.Window('MerchantWnd').Open() then
            mq.TLO.Window('MerchantWnd').DoClose()
            mq.delay(1)
        end
        mq.delay(1)
        totalPlat = math.floor(totalPlat)
        report('Total plat value sold: \ag%s\ax', totalPlat)
    elseif action == 'Bank' then
        if mq.TLO.Window('BigBankWnd').Open() then
            mq.TLO.Window('BigBankWnd').DoClose()
            mq.delay(1)
        end
    end

    CheckBags()
end

-- Legacy functions for backward compatibility

function LootUtils.sellStuff()
    LootUtils.processItems('Sell')
end

function LootUtils.bankStuff()
    LootUtils.processItems('Bank')
end

function LootUtils.cleanupBags()
    LootUtils.processItems('Cleanup')
end

function LootUtils.tributeStuff()
    LootUtils.processItems('Tribute')
end

--

local function guiExport()
    -- Define a new menu element function
    local function customMenu()
        if ImGui.BeginMenu('Loot N Scoot') then
            -- Add menu items here
            if ImGui.BeginMenu('Toggles') then
                -- Add menu items here
                _, LootUtils.DoLoot = ImGui.MenuItem("DoLoot", nil, LootUtils.DoLoot)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.GlobalLootOn = ImGui.MenuItem("GlobalLootOn", nil, LootUtils.GlobalLootOn)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.CombatLooting = ImGui.MenuItem("CombatLooting", nil, LootUtils.CombatLooting)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.LootNoDrop = ImGui.MenuItem("LootNoDrop", nil, LootUtils.LootNoDrop)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.LootNoDropNew = ImGui.MenuItem("LootNoDropNew", nil, LootUtils.LootNoDropNew)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.LootForage = ImGui.MenuItem("LootForage", nil, LootUtils.LootForage)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.LootQuest = ImGui.MenuItem("LootQuest", nil, LootUtils.LootQuest)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.TributeKeep = ImGui.MenuItem("TributeKeep", nil, LootUtils.TributeKeep)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.BankTradeskills = ImGui.MenuItem("BankTradeskills", nil, LootUtils.BankTradeskills)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.StackableOnly = ImGui.MenuItem("StackableOnly", nil, LootUtils.StackableOnly)
                if _ then LootUtils.writeSettings() end
                ImGui.Separator()
                _, LootUtils.AlwaysEval = ImGui.MenuItem("AlwaysEval", nil, LootUtils.AlwaysEval)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.AddNewSales = ImGui.MenuItem("AddNewSales", nil, LootUtils.AddNewSales)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.AddNewTributes = ImGui.MenuItem("AddNewTributes", nil, LootUtils.AddNewTributes)
                if _ then LootUtils.writeSettings() end
                ImGui.Separator()
                _, LootUtils.DoDestroy = ImGui.MenuItem("DoDestroy", nil, LootUtils.DoDestroy)
                if _ then LootUtils.writeSettings() end
                _, LootUtils.AlwaysDestroy = ImGui.MenuItem("AlwaysDestroy", nil, LootUtils.AlwaysDestroy)
                if _ then LootUtils.writeSettings() end

                ImGui.EndMenu()
            end
            if ImGui.BeginMenu('Group Commands') then
                -- Add menu items here
                if ImGui.MenuItem("Sell Stuff##group") then
                    mq.cmd(string.format('/%s /lootutils sellstuff', tmpCmd))
                end
                if ImGui.MenuItem("Tribute Stuff##group") then
                    mq.cmd(string.format('/%s /lootutils tributestuff', tmpCmd))
                end
                if ImGui.MenuItem("Bank##group") then
                    mq.cmd(string.format('/%s /lootutils bank', tmpCmd))
                end
                if ImGui.MenuItem("Cleanup##group") then
                    mq.cmd(string.format('/%s /lootutils cleanup', tmpCmd))
                end
                ImGui.EndMenu()
            end
            if ImGui.MenuItem('Sell Stuff') then
                mq.cmd('/lootutils sellstuff')
            end

            if ImGui.MenuItem('Tribute Stuff') then
                mq.cmd('/lootutils tributestuff')
            end

            if ImGui.MenuItem('Bank') then
                mq.cmd('/lootutils bank')
            end

            if ImGui.MenuItem('Cleanup') then
                mq.cmd('/lootutils cleanup')
            end

            ImGui.Separator()

            if ImGui.MenuItem('Exit LNS') then
                LootUtils.Terminate = true
            end

            ImGui.EndMenu()
        end
    end
    -- Add the custom menu element function to the importGUIElements table
    if guiLoot ~= nil then table.insert(LootUtils.guiLootUtils.importGUIElements, customMenu) end
end

local function processArgs(args)
    if #args == 1 then
        if args[1] == 'sellstuff' then
            LootUtils.processItems('Sell')
        elseif args[1] == 'tributestuff' then
            LootUtils.processItems('Tribute')
        elseif args[1] == 'cleanup' then
            LootUtils.processItems('Cleanup')
        elseif args[1] == 'once' then
            LootUtils.lootMobs()
        elseif args[1] == 'standalone' then
            if guiLoot ~= nil then
                LootUtils.guiLootUtils.GetSettings(LootUtils.HideNames, LootUtils.LookupLinks,
                    LootUtils.RecordData, LootUtils.UseActors)
            end
            LootUtils.Terminate = false
        end
    end
end

local function init(args)
    local iniFile = mq.TLO.Ini.File(LootUtils.Settings.LootFile)
    if not (iniFile.Exists() and iniFile.Section('Settings').Exists()) then
        LootUtils.LootUtils.writeSettings()
    else
        LootUtils.loadSettings()
    end
    CheckBags()
    setupEvents()
    setupBinds()
    processArgs(args)
    guiExport()
end

init({ ... })

while not LootUtils.Settings.Terminate do
    if mq.TLO.Window('CharacterListWnd').Open() then LootUtils.Terminate = true end -- exit sctipt if at char select.
    if LootUtils.DoLoot and not areFull then LootUtils.lootMobs() end
    if doSell then
        LootUtils.processItems('Sell')
        doSell = false
    end
    if doTribute then
        LootUtils.processItems('Tribute')
        doTribute = false
    end
    mq.doevents()
    mq.delay(1000)
end

return LootUtils
