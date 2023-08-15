--|------------------------------------------------------------|
--|          EZ
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')
local args = { ... }
local script_ShortName = 'EZC'
local WaitTime = 750

function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(isDebugMessage, consoleMessage, ...)
    if isDebugMessage then
        printf("\ar[%s] \aw" .. consoleMessage .. '\ax', ScriptInfo(), ...)
    else
        printf("\ag[%s] \aw" .. consoleMessage .. '\ax', script_ShortName, ...)
    end
end

function POPUPMETHOD(popupMessage, ...)
    mq.cmdf('/popup %s', popupMessage, ...)
end

local function GetArmorType()
    local my_Class = mq.TLO.Me.Class() or ''
    local my_ArmorType
    if my_Class == 'Bard' or my_Class == 'Cleric' or my_Class == 'Paladin' or my_Class == 'Shadow Knight' or my_Class == 'Warrior' then
        my_ArmorType = 'Plate'
    elseif my_Class == 'Berserker' or my_Class == 'Rogue' or my_Class == 'Shaman' then
        my_ArmorType = 'Chain'
    elseif my_Class == 'Enchanter' or my_Class == 'Magician' or my_Class == 'Necromancer' or my_Class == 'wizard' then
        my_ArmorType = 'Cloth'
    elseif my_Class == 'Beastlord' or my_Class == 'Druid' or my_Class == 'Monk' then
        my_ArmorType = 'Leather'
    end
    return my_ArmorType
end

local function InventoryOpen()
    if mq.TLO.Window('InventoryWindow').Open() then return true else return false end
end
local function BagOpen(packNum)
    if mq.TLO.Window(packNum).Open() then return true else return false end
end
local function CheckCursor()
    if mq.TLO.Cursor.ID() == 0 then return false else return true end
end
local function CursorEmpty()
    if mq.TLO.Cursor.ID() == 0 then return true else return false end
end

local function FindMagicBox()
    local magicBox
    for i = 1, 10 do
        if mq.TLO.InvSlot('pack' .. i).Item.Name() == 'A Magic Box' then
            magicBox = 'pack' .. i
            return magicBox
        end
    end
    return nil
end

local function FindIncompleteEpicBook(epicLvl)
    local incompleteBook
    for i = 1, 10 do
        if mq.TLO.InvSlot('pack' .. i).Item.Name() == 'Incomplete Weapon Book ' .. epicLvl then
            incompleteBook = 'pack' .. i
            return incompleteBook
        end
    end
    return nil
end

-- 	| Stone of Heroic Resistance
--	| 130501 - 130520
local function CombineResistAugs()
    local magicBox = FindMagicBox() or ''
    CONSOLEMETHOD(false, 'Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
    if not BagOpen(magicBox) then
        mq.cmdf('/itemnotify %s rightmouseup', magicBox)
    end
    mq.delay(1500, function() return BagOpen(magicBox) == true end)

    for i = 130501, 130509 do
        CONSOLEMETHOD(false, 'Aug Type ID: ' .. i)
        for j = 1, 10 do
            if mq.TLO.InvSlot('pack' .. j).Item.Container() > 0 then
                for k = 1, 10 do
                    if mq.TLO.InvSlot('pack' .. j).Item.Item(k).ID() == i then
                        mq.cmd('/itemnotify in pack' .. j .. ' ' .. k .. ' leftmouseup')
                        mq.delay(WaitTime, CheckCursor)
                        if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == nil then
                            CONSOLEMETHOD(false, 'Found Aug moving to slot 1')
                            mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 1)
                        elseif mq.TLO.InvSlot(magicBox).Item.Item(2).ID() == nil then
                            CONSOLEMETHOD(false, 'Found Aug moving to slot 2')
                            mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 2)
                        end
                        if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == i and mq.TLO.InvSlot(magicBox).Item.Item(2).ID() == i then
                            mq.cmdf('/combine %s', magicBox)
                            mq.delay(WaitTime)
                            mq.cmd('/autoinventory')
                            mq.delay(WaitTime, CursorEmpty)
                        end
                        mq.delay(10)
                    end
                    mq.delay(10)
                end
                mq.delay(10)
            end
            mq.delay(10)
        end
        if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == i or mq.TLO.InvSlot(magicBox).Item.Item(2).ID() == i then
            if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == i then
                mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 1)
            elseif mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == i then
                mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 2)
            end
            mq.delay(WaitTime)
            mq.cmd('/autoinventory')
            mq.delay(WaitTime, CursorEmpty)
        end
    end
end

local function CombineEpic1_5()
    local epicBook = FindIncompleteEpicBook('1.5') or 'pack1'
    CONSOLEMETHOD(false, 'Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
    if not BagOpen(epicBook) then
        mq.cmdf('/itemnotify %s rightmouseup', epicBook)
    end
    mq.delay(1500, function() return BagOpen(epicBook) == true end)

    for i = 99701, 99710 do
        for j = 1, 10 do
            if mq.TLO.InvSlot('pack' .. j).Item.Container() > 0 then
                for k = 1, 10 do
                    if mq.TLO.InvSlot('pack' .. j).Item.Item(k).ID() == i and epicBook ~= 'pack' .. j then
                        mq.cmd('/itemnotify in pack' .. j .. ' ' .. k .. ' leftmouseup')
                        mq.delay(WaitTime, CheckCursor)
                        for l = 1, 10 do
                            if mq.TLO.InvSlot(epicBook).Item.Item(l).ID() == nil then
                                CONSOLEMETHOD(false, 'Found epic page moving to slot %s', l)
                                mq.cmdf('/itemnotify in %s %s leftmouseup', epicBook, l)
                                break
                            end
                            mq.delay(10)
                        end
                    end
                    mq.delay(10)
                end
                mq.delay(10)
            end
            mq.delay(10)
        end
    end
    if not mq.TLO.Window(epicBook).Open() then mq.cmdf('/nomodkey /itemnotify %s rightmouseup', epicBook) end
    mq.delay(WaitTime, function() return mq.TLO.Window(epicBook).Open() == true end)
    mq.cmdf('/combine %s', epicBook)
    mq.delay(WaitTime)
    mq.cmd('/autoinventory')
    mq.delay(WaitTime, CursorEmpty)
end

local function CombineEpic2_0()
    local epicBook = FindIncompleteEpicBook('2.0') or 'pack1'
    CONSOLEMETHOD(false, 'Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
    if not BagOpen(epicBook) then
        mq.cmdf('/itemnotify %s rightmouseup', epicBook)
    end
    mq.delay(1500, function() return BagOpen(epicBook) == true end)

    for i = 99721, 99730 do
        for j = 1, 10 do
            if mq.TLO.InvSlot('pack' .. j).Item.Container() > 0 then
                for k = 1, 10 do
                    if mq.TLO.InvSlot('pack' .. j).Item.Item(k).ID() == i and epicBook ~= 'pack' .. j then
                        mq.cmd('/itemnotify in pack' .. j .. ' ' .. k .. ' leftmouseup')
                        mq.delay(WaitTime, CheckCursor)
                        for l = 1, 10 do
                            if mq.TLO.InvSlot(epicBook).Item.Item(l).ID() == nil then
                                CONSOLEMETHOD(false, 'Found epic page moving to slot %s', l)
                                mq.cmdf('/itemnotify in %s %s leftmouseup', epicBook, l)
                                break
                            end
                            mq.delay(10)
                        end
                    end
                    mq.delay(10)
                end
                mq.delay(10)
            end
            mq.delay(10)
        end
    end
    if not mq.TLO.Window(epicBook).Open() then mq.cmdf('/nomodkey /itemnotify %s rightmouseup', epicBook) end
    mq.delay(WaitTime, function() return mq.TLO.Window(epicBook).Open() == true end)
    mq.cmdf('/combine %s', epicBook)
    mq.delay(WaitTime)
    mq.cmd('/autoinventory')
    mq.delay(WaitTime, CursorEmpty)
end

local armor_Tiers = {
    QVIC = {
        chain = {
            [1] = { 'Vampire Hunter Sleeves Pattern', 'Flawless Black Sapphire (Quest Item)' },
            [2] = { 'Vampire Hunter Tunic Pattern', 'Flawless Blue Diamond (Quest Item)' },
            [3] = { 'Vampire Hunter Boots Pattern', 'FFlawless Ruby (Quest Item)' },
            [4] = { 'Vampire Hunter Gauntlets Pattern', 'Flawless Sapphire (Quest Item)' },
            [5] = { 'Vampire Hunter Coif Pattern', 'Flawless Jacinth (Quest Item)' },
            [6] = { 'Vampire Hunter Leggings Pattern', 'Flawless Diamond (Quest Item)' },
            [7] = { 'Vampire Hunter Bracer Pattern', 'Flawless Fire Emerald (Quest Item)' }
        },
        cloth = {
            [1] = { 'Azure Sleeves Pattern', 'Flawless Black Sapphire (Quest Item)' },
            [2] = { 'Azure Robe Pattern', 'Flawless Blue Diamond (Quest Item)' },
            [3] = { 'Azure Boots Pattern', 'Flawless Ruby (Quest Item)' },
            [4] = { 'Azure Gloves Pattern', 'Flawless Sapphire (Quest Item)' },
            [5] = { 'Azure Turban Pattern', 'Flawless Jacinth (Quest Item)' },
            [6] = { 'Azure Pantaloons Pattern', 'Flawless Sapphire (Quest Item)' },
            [7] = { 'Azure Wristband Pattern', 'Flawless Fire Emerald (Quest Item)' }
        },
        leather = {
            [1] = { 'Forgotten Artist\'s Sleeves Pattern', 'Flawless Black Sapphire (Quest Item)' },
            [2] = { 'Forgotten Artist\'s Tunic Pattern', 'Flawless Blue Diamond (Quest Item)' },
            [3] = { 'Forgotten Artist\'s Boots Pattern', 'Flawless Ruby (Quest Item)' },
            [4] = { 'Forgotten Artist\'s Gloves Pattern', 'Flawless Sapphire (Quest Item)' },
            [5] = { 'Forgotten Artist\'s Cap Pattern', 'Flawless Jacinth (Quest Item)' },
            [6] = { 'Forgotten Artist\'s Leggings Pattern', 'Flawless Diamond (Quest Item)' },
            [7] = { 'Forgotten Artist\'s Bracelet Pattern', 'Flawless Fire Emerald (Quest Item)' }
        },
        plate = {
            [1] = { 'Fallen Saint Vambraces Mold', 'Flawless Black Sapphire (Quest Item)' },
            [2] = { 'Fallen Saint Breastplate Mold', 'Flawless Blue Diamond (Quest Item)' },
            [3] = { 'Fallen Saint Boots Mold', 'Flawless Ruby (Quest Item)' },
            [4] = { 'Fallen Saint Gauntlets Mold', 'Flawless Sapphire (Quest Item)' },
            [5] = { 'Fallen Saint Helmet Mold', 'Flawless Jacinth (Quest Item)' },
            [6] = { 'Fallen Saint Greaves Mold', 'Flawless Diamond (Quest Item)' },
            [7] = { 'Fallen Saint Bracer Mold', 'Flawless Fire Emerald (Quest Item)' }
        },
    },
    CAZIC = {
        chain = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        cloth = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        leather = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        plate = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
    },
    POD = {
        chain = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        cloth = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        leather = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        plate = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
    },
    AIRPLANE = {
        chain = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        cloth = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        leather = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
        plate = {
            [1] = { '', '' },
            [2] = { '', '' },
            [3] = { '', '' },
            [4] = { '', '' },
            [5] = { '', '' },
            [6] = { '', '' },
            [7] = { '', '' }
        },
    },
    ABYSS = {},
    ANGUISH = {},
    TOV = {},
}

local function doArmorCombine(magicBox, itemOne, itemTwo)
    local itemOneID = mq.TLO.FindItem(itemOne).ID()
    local itemTwoID = mq.TLO.FindItem(itemTwo).ID()
    if itemOneID == nil or itemTwoID == nil then return end

    for j = 1, 10 do
        if mq.TLO.InvSlot('pack' .. j).Item.Container() > 0 then
            for k = 1, 10 do
                if mq.TLO.InvSlot('pack' .. j).Item.Item(k).ID() == itemOneID then
                    mq.cmd('/itemnotify in pack' .. j .. ' ' .. k .. ' leftmouseup')
                    mq.delay(WaitTime, CheckCursor)
                    if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == nil then
                        CONSOLEMETHOD(false, 'Found Armor moving to slot 1')
                        mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 1)
                    end
                    mq.delay(10)
                elseif mq.TLO.InvSlot('pack' .. j).Item.Item(k).ID() == itemTwoID then
                    mq.cmd('/itemnotify in pack' .. j .. ' ' .. k .. ' leftmouseup')
                    mq.delay(WaitTime, CheckCursor)
                    if mq.TLO.InvSlot(magicBox).Item.Item(2).ID() == nil then
                        CONSOLEMETHOD(false, 'Found Upgrade moving to slot 2')
                        mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 2)
                    end
                    mq.delay(10)
                end
                if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == itemOneID and mq.TLO.InvSlot(magicBox).Item.Item(2).ID() == itemTwoID then
                    mq.cmdf('/combine %s', magicBox)
                    mq.delay(WaitTime)
                    mq.cmd('/autoinventory')
                    mq.delay(WaitTime, CursorEmpty)
                    return
                end
                mq.delay(10)
            end
            mq.delay(10)
        end
        mq.delay(10)
    end
    if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == itemOneID or mq.TLO.InvSlot(magicBox).Item.Item(2).ID() == itemTwoID then
        if mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == itemOneID then
            mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 1)
        elseif mq.TLO.InvSlot(magicBox).Item.Item(1).ID() == itemTwoID then
            mq.cmdf('/itemnotify in %s %s leftmouseup', magicBox, 2)
        end
        mq.delay(WaitTime)
        mq.cmd('/autoinventory')
        mq.delay(WaitTime, CursorEmpty)
    end
end
local function Combine_Armor(armorTier)
    local magicBox = FindMagicBox() or ''
    CONSOLEMETHOD(false, 'Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
    if not BagOpen(magicBox) then
        mq.cmdf('/itemnotify %s rightmouseup', magicBox)
    end
    mq.delay(1500, function() return BagOpen(magicBox) == true end)

    local armorType = GetArmorType():lower() -- Convert to lowercase
    local armorTierTable = armor_Tiers[armorTier]

    if armorTierTable then
        local armorArray = armorTierTable[armorType]
        if armorArray then
            for i, patternInfo in ipairs(armorArray) do
                -- print("Piece " .. i .. ": " .. patternInfo[1] .. " - Quest item: " .. patternInfo[2])
                doArmorCombine(magicBox, patternInfo[1], patternInfo[2])
            end
        end
    end
end



local function Main()
    if args ~= nil then
        if args[1] == 'resist' then
            CombineResistAugs()
        elseif args[1] == 'armor' then
            Combine_Armor('QVIC')
        elseif args[1] == 'epic' then
            if args[2] ~= nil then
                if args[2] == '1.5' then
                    CONSOLEMETHOD(true, 'Attempting Epic 1.5 Combine')
                    CombineEpic1_5()
                elseif args[2] == '2.0' then
                    CONSOLEMETHOD(true, 'Attempting Epic 2.0 Combine')
                    CombineEpic2_0()
                end
            else
                CONSOLEMETHOD(true, 'Please provide the epic level to combine.')
            end
        end
    else
        print('Please tell the script what to combine!')
    end
end
Main()
POPUPMETHOD('All done!')
