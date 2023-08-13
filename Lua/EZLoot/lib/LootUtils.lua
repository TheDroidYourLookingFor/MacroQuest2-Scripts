--[[
lootnscoot.lua v1.0 - aquietone

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
                lootutils.logger = Write
            Several other settings can be found in the "loot" table defined in the code.

    2. Run as a standalone script:
        /lua run lootnscoot standalone
            Will keep the script running, checking for corpses once per second.
        /lua run lootnscoot once
            Will run one iteration of LootUtils.lootMobs().
        /lua run lootnscoot sell
            Will run one iteration of LootUtils.sellStuff().

The script will setup a bind for "/lootutils":
    /lootutils <action> "${Cursor.Name}"
        Set the loot rule for an item. "action" may be one of:
            - Keep
            - Bank
            - Sell
            - Tribute (Not Implemented)
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
    /lootutils sell
        Runs lootutils.sellStuff() one time

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

-- Public default settings, also read in from LootUtils.ini [Settings] section
LootUtils = {
    logger = Write,
    Version = "1.0",
    LootFile = mq.configDir .. '/LootUtils.ini',
    AddNewSales = true,
    LootForage = true,
    LootTradeSkill = true,
    DoLoot = true,
    EquipUsable = true,
    CorpseRadius = 100,
    MobsTooClose = 40,
    ReportLoot = true,
    LootChannel = "dgt",
    SpamLootInfo = false,
    LootForageSpam = false,
    GlobalLootOn = true,
    CombatLooting = true,
    GMLSelect = true,
    ExcludeBag1 = "Extraplanar Trade Satchel",
    QuestKeep = 10,
    StackPlatValue = 0,
    NoDropDefaults = "Quest|Keep|Ignore",
    LootLagDelay = 0,
    SaveBagSlots = 3,
    MinSellPrice = -1,
    StackableOnly = false,
    CorpseRotTime = "440s",
    Terminate = true,
    useZoneLootFile = false,
}

LootUtils.logger.prefix = 'LOOT'
local my_Class = mq.TLO.Me.Class() or ''
if LootUtils.useZoneLootFile then
    LootUtils.LootFile = mq.configDir .. '/EZLoot/EZLoot.' .. mq.TLO.Zone.ShortName() .. '.' .. my_Class .. '.ini'
else
    LootUtils.LootFile = mq.configDir .. '/EZLoot/EZLoot.' .. my_Class .. '.ini'
end

-- Internal settings
local lootData = {}
local doSell = false
local cantLootList = {}
local cantLootID = 0

-- Constants
local spawnSearch = '%s radius %d zradius 50'
-- If you want destroy to actually loot and destroy items, change Destroy=false to Destroy=true.
-- Otherwise, destroy behaves the same as ignore.
local shouldLootActions = { Keep = true, Bank = true, Sell = true, Destroy = false, Ignore = false, Quest = true }
local validActions = {
    keep = 'Keep',
    bank = 'Bank',
    sell = 'Sell',
    ignore = 'Ignore',
    destroy = 'Destroy',
    quest = 'Quest'
}
local saveOptionTypes = { string = 1, number = 1, boolean = 1 }

-- FORWARD DECLARATIONS

local eventForage, eventSell, eventCantLoot

-- UTILITIES

function LootUtils.writeSettings()
    for option, value in pairs(LootUtils) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.LootFile, 'Settings', option, value)
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
    local iniSettings = mq.TLO.Ini.File(LootUtils.LootFile).Section('Settings')
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
end

local function checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        -- can't do anything if there's nowhere to put the item, either due to no free inventory space
        -- or no slot of appropriate size
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if LootUtils.SpamLootInfo then LootUtils.logger.Debug('Inventory full, item stuck on cursor') end
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
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.LootFile, section, itemName, rule)
end

local function lookupIniLootRule(section, key)
    return mq.TLO.Ini.File(LootUtils.LootFile).Section(section).Key(key).Value()
end

local function getRule(item)
    local itemName = item.Name()
    local lootDecision = 'Ignore'
    local tradeskill = item.Tradeskills()
    local sellPrice = item.Value() and item.Value() / 1000 or 0
    local stackable = item.Stackable()
    local firstLetter = itemName:sub(1, 1):upper()
    local stackSize = item.StackSize()
    local noDrop = item.NoDrop()
    local wornSlot = item.WornSlot(1)
    local canUse = item.CanUse()

    if canUse and LootUtils.EquipUsable then
        if wornSlot == 1 and mq.TLO.Me.Inventory(wornSlot)() == nil then
            print('Looting missing worn item!')
            return 'Keep'
        elseif wornSlot == 1 and mq.TLO.Me.Inventory(4)() == nil then
            print('Looting missing worn item!')
            return 'Keep'
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(wornSlot)() == nil then
            print('Looting missing worn item!')
            return 'Keep'
        elseif wornSlot == 15 and mq.TLO.Me.Inventory(16)() == nil then
            print('Looting missing worn item!')
            return 'Keep'
        elseif mq.TLO.Me.Inventory(wornSlot)() == nil then
            print('Looting missing worn item!')
            return 'Keep'
        end
    end

    lootData[firstLetter] = lootData[firstLetter] or {}
    lootData[firstLetter][itemName] = lootData[firstLetter][itemName] or lookupIniLootRule(firstLetter, itemName)
    if lootData[firstLetter][itemName] == 'NULL' then
        if noDrop and not canUse then lootDecision = 'Ignore' end
        if LootUtils.LootTradeSkill and tradeskill then lootDecision = 'Bank' end
        if sellPrice ~= 0 and sellPrice >= LootUtils.MinSellPrice then lootDecision = 'Sell' end
        if not stackable and LootUtils.StackableOnly then lootDecision = 'Ignore' end
        if LootUtils.StackPlatValue > 0 and sellPrice * stackSize >= LootUtils.StackPlatValue then lootDecision = 'Sell' end
        addRule(itemName, firstLetter, lootDecision)
    end
    return lootData[firstLetter][itemName]
end

-- EVENTS

local itemNoValue = nil
local function eventNovalue(line, item)
    itemNoValue = item
end

local function setupEvents()
    mq.event("CantLoot", "#*#may not loot this corpse#*#", eventCantLoot)
    mq.event("Sell", "#*#You receive#*# for the #1#(s)#*#", eventSell)
    if LootUtils.LootForage then
        mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", eventForage)
        mq.event("Forage", "You have scrounged up #*#", eventForage)
    end
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", eventNovalue)
end

-- BINDS

local function commandHandler(...)
    local args = { ... }
    if #args == 1 then
        if args[1] == 'sell' and not LootUtils.Terminate then
            doSell = true
        elseif args[1] == 'reload' then
            lootData = {}
            LootUtils.logger.Info("Reloaded Loot File")
        elseif args[1] == 'bank' then
            LootUtils.bankStuff()
        elseif args[1] == 'tsbank' then
            LootUtils.markTradeSkillAsBank()
        end
    elseif #args == 2 then
        if validActions[args[1]] and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1, 1), validActions[args[1]])
            LootUtils.logger.Info(string.format("Setting \ay%s\ax to \ay%s\ax", args[2], validActions[args[1]]))
        end
    elseif #args == 3 then
        if args[1] == 'quest' and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1, 1), 'Quest|' .. args[3])
            LootUtils.logger.Info(string.format("Setting \ay%s\ax to \ayQuest|%s\ax", args[2], args[3]))
        end
    end
end

local function setupBinds()
    mq.bind('/lootutils', commandHandler)
end

local reportPrefix = '/%s \a-t]\ax\aylootutils\ax\a-t]\ax '
local function report(message, ...)
    if LootUtils.ReportLoot then
        local prefixWithChannel = reportPrefix:format(LootUtils.LootChannel)
        mq.cmdf(prefixWithChannel .. message, ...)
    end
end

-- LOOTING

function eventCantLoot()
    cantLootID = mq.TLO.Target.ID()
end

---@param index number @The current index we are looking at in loot window, 1-based.
---@param doWhat string @The action to take for the item.
---@param button string @The mouse button to use to loot the item. Currently only leftmouseup implemented.
local function lootItem(index, doWhat, button)
    LootUtils.logger.Debug('Enter lootItem')
    local corpseItemID = mq.TLO.Corpse.Item(index).ID()
    local itemName = mq.TLO.Corpse.Item(index).Name()
    local ruleAction = doWhat

    if string.find(doWhat, "Quest|") == 1 then
        local lootRule = split(doWhat)
        ruleAction = lootRule[1]       -- what to do with the item
        local ruleAmount = lootRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('=' .. itemName)()
        printf('Quest Item: %s / Action: %s / Amount: %s / DoWhat: %s', itemName, ruleAction, ruleAmount, doWhat)

        --if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= tonumber(ruleAmount)) then return end
        if ruleAction == 'Quest' and currentItemAmount >= tonumber(ruleAmount) then return end
    else
        if not shouldLootActions[ruleAction] then return end
    end

    mq.cmdf('/nomodkey /shift /itemnotify loot%s %s', index, button)
    -- Looting of no drop items is currently disabled with no flag to enable anyways
    mq.delay(5000,
        function() return mq.TLO.Window('ConfirmationDialogBox').Open() or not mq.TLO.Corpse.Item(index).NoDrop() end)
    if mq.TLO.Window('ConfirmationDialogBox').Open() then
        mq.cmd(
            '/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup')
    end
    mq.delay(5000, function() return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open() end)
    mq.delay(1) -- force next frame
    -- The loot window closes if attempting to loot a lore item you already have, but lore should have already been checked for
    if not mq.TLO.Window('LootWnd').Open() then return end
    report('%sing \ay%s\ax', ruleAction, itemName)
    if ruleAction == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then mq.cmd('/destroy') end
    if mq.TLO.Cursor() then checkCursor() end
end

local function lootCorpse(corpseID)
    LootUtils.logger.Debug('Enter lootCorpse')
    if mq.TLO.Cursor() then checkCursor() end
    if mq.TLO.Me.FreeInventory() <= LootUtils.SaveBagSlots then
        report('My bags are full, I can\'t loot anymore!')
    end
    for i = 1, 3 do
        mq.cmd('/loot')
        mq.delay(1000, function() return mq.TLO.Window('LootWnd').Open() end)
        if mq.TLO.Window('LootWnd').Open() then break end
    end
    mq.doevents('CantLoot')
    mq.delay(3000, function() return cantLootID > 0 or mq.TLO.Window('LootWnd').Open() end)
    if not mq.TLO.Window('LootWnd').Open() then
        LootUtils.logger.Warn(('Can\'t loot %s right now'):format(mq.TLO.Target.CleanName()))
        cantLootList[corpseID] = os.time()
        return
    end
    mq.delay(1000, function() return (mq.TLO.Corpse.Items() or 0) > 0 end)
    local items = mq.TLO.Corpse.Items() or 0
    LootUtils.logger.Debug(('Loot window open. Items: %s'):format(items))
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
                -- if corpseItem.NoDrop() then
                --     --table.insert(noDropItems, corpseItem.ItemLink('CLICKABLE')())
                -- else
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
            end
            if not mq.TLO.Window('LootWnd').Open() then break end
        end
        if LootUtils.ReportLoot and #noDropItems > 0 or #loreItems > 0 then
            local skippedItems = '/%s Skipped loots (%s - %s) '
            for _, noDropItem in ipairs(noDropItems) do
                skippedItems = skippedItems .. ' ' .. noDropItem .. ' (nodrop) '
            end
            for _, loreItem in ipairs(loreItems) do
                skippedItems = skippedItems .. ' ' .. loreItem .. ' (lore) '
            end
            mq.cmdf(skippedItems, LootUtils.LootChannel, corpseName, corpseID)
        end
    end
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
    LootUtils.logger.Debug('Enter lootMobs')
    local deadCount = mq.TLO.SpawnCount(spawnSearch:format('npccorpse', LootUtils.CorpseRadius))()
    LootUtils.logger.Debug(string.format('There are %s corpses in range.', deadCount))
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
    LootUtils.logger.Debug(string.format('Trying to loot %d corpses.', #corpseList))
    for i = 1, #corpseList do
        local corpse = corpseList[i]
        local corpseID = corpse.ID()
        if corpseID and corpseID > 0 and not corpseLocked(corpseID) and (mq.TLO.Navigation.PathLength('spawn id ' .. tostring(corpseID))() or 100) < 60 then
            LootUtils.logger.Debug('Moving to corpse ID=' .. tostring(corpseID))
            navToID(corpseID)
            corpse.DoTarget()
            lootCorpse(corpseID)
            didLoot = true
            mq.doevents('InventoryFull')
        end
    end
    LootUtils.logger.Debug('Done with corpse list.')
    return didLoot
end

-- SELLING

function eventSell(line, itemName)
    local firstLetter = itemName:sub(1, 1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Sell' then return end
    if lookupIniLootRule(firstLetter, itemName) == 'Sell' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Sell'
        return
    end
    if LootUtils.AddNewSales then
        LootUtils.logger.Info(string.format('Setting %s to Sell', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        lootData[firstLetter][itemName] = 'Sell'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', LootUtils.LootFile, firstLetter, itemName, 'Sell')
    end
end

local function goToVendor()
    if not mq.TLO.Target() then
        LootUtils.logger.Warn('Please target a vendor')
        return false
    end
    local vendorName = mq.TLO.Target.CleanName()

    LootUtils.logger.Info('Doing business with ' .. vendorName)
    if mq.TLO.Target.Distance() > 15 then
        navToID(mq.TLO.Target.ID())
    end
    return true
end

local function openVendor()
    LootUtils.logger.Debug('Opening merchant window')
    mq.cmd('/nomodkey /click right target')
    LootUtils.logger.Debug('Waiting for merchant window to populate')
    mq.delay(1000, function() return mq.TLO.Window('MerchantWnd').Open() end)
    if not mq.TLO.Window('MerchantWnd').Open() then return false end
    mq.delay(5000, function() return mq.TLO.Merchant.ItemsReceived() end)
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
    if NEVER_SELL[itemToSell] then return end
    while mq.TLO.FindItemCount('=' .. itemToSell)() > 0 do
        if mq.TLO.Window('MerchantWnd').Open() then
            LootUtils.logger.Info('Selling ' .. itemToSell)
            mq.cmdf('/nomodkey /itemnotify "%s" leftmouseup', itemToSell)
            mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
            mq.cmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
            mq.doevents('eventNovalue')
            if itemNoValue == itemToSell then
                addRule(itemToSell, itemToSell:sub(1, 1), 'Ignore')
                itemNoValue = nil
                break
            end
            -- TODO: handle vendor not wanting item / item can't be sold
            mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
        end
    end
end

function LootUtils.sellStuff()
    if not mq.TLO.Window('MerchantWnd').Open() then
        if not goToVendor() then return end
        if not openVendor() then return end
    end

    local totalPlat = mq.TLO.Me.Platinum()
    -- sell any top level inventory items that are marked as well, which aren't bags
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToSell = bagSlot.Name()
                local sellRule = getRule(bagSlot)
                if sellRule == 'Sell' then sellToVendor(itemToSell) end
            end
        end
    end
    -- sell any items in bags which are marked as sell
    for i = 1, 10 do
        local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j = 1, containerSize do
                local itemToSell = bagSlot.Item(j).Name()
                if itemToSell then
                    local sellRule = getRule(bagSlot.Item(j))
                    if sellRule == 'Sell' then
                        local sellPrice = bagSlot.Item(j).Value() and bagSlot.Item(j).Value() / 1000 or 0
                        if sellPrice == 0 then
                            LootUtils.logger.Warn(string.format('Item \ay%s\ax is set to Sell but has no sell value!',
                                itemToSell))
                        else
                            sellToVendor(itemToSell)
                        end
                    end
                end
            end
        end
    end
    mq.flushevents('Sell')
    if mq.TLO.Window('MerchantWnd').Open() then mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup') end
    local newTotalPlat = mq.TLO.Me.Platinum() - totalPlat
    LootUtils.logger.Info(string.format('Total plat value sold: \ag%s\ax', newTotalPlat))
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

local function bankItem(itemName)
    mq.cmdf('/nomodkey /shiftkey /itemnotify "%s" leftmouseup', itemName)
    mq.delay(100, function() return mq.TLO.Cursor() end)
    mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
    mq.delay(100, function() return not mq.TLO.Cursor() end)
end

function LootUtils.bankStuff()
    if not mq.TLO.Window('BigBankWnd').Open() then
        LootUtils.logger.Warn('Bank window must be open!')
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
    LootUtils.logger.Debug('Enter eventForage')
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
                if LootUtils.LootForageSpam then LootUtils.logger.Info('Destroying foraged item ' .. foragedItem) end
                mq.cmd('/destroy')
                mq.delay(500)
            end
            -- will a lore item we already have even show up on cursor?
            -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if LootUtils.LootForageSpam then LootUtils.logger.Info('Keeping foraged item ' .. foragedItem) end
            mq.cmd('/autoinv')
        else
            if LootUtils.LootForageSpam then LootUtils.logger.Warn('Unable to process item ' .. foragedItem) end
            break
        end
        mq.delay(50)
    end
end

--

local function processArgs(args)
    if #args == 1 then
        if args[1] == 'sell' then
            LootUtils.sellStuff()
        elseif args[1] == 'once' then
            LootUtils.lootMobs()
        elseif args[1] == 'standalone' then
            LootUtils.Terminate = false
        end
    end
end

local function init(args)
    local iniFile = mq.TLO.Ini.File(LootUtils.LootFile)
    if not (iniFile.Exists() and iniFile.Section('Settings').Exists()) then
        LootUtils.writeSettings()
    else
        LootUtils.loadSettings()
    end

    setupEvents()
    setupBinds()
    processArgs(args)
end

init({ ... })

while not LootUtils.Terminate do
    if LootUtils.DoLoot then LootUtils.lootMobs() end
    if doSell then
        LootUtils.sellStuff()
        doSell = false
    end
    mq.delay(1000)
end

return LootUtils
