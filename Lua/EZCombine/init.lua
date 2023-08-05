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
    local magicBox = FindMagicBox()
    CONSOLEMETHOD(false, 'Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)
    mq.cmd('/keypress Shift+B')
    mq.delay(50)

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
    mq.cmd('/keypress Shift+B')
    mq.delay(50)

    for i = 99701, 99710 do
        for j = 1, 10 do
            if mq.TLO.InvSlot('pack' .. j).Item.Container() > 0 then
                for k = 1, 10 do
                    if mq.TLO.InvSlot('pack' .. j).Item.Item(k).ID() == i and epicBook ~= 'pack'..j then
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
    if not mq.TLO.Window(epicBook).Open() then mq.cmdf('/nomodkey /itemnotify %s rightmouseup',epicBook) end
    mq.delay(WaitTime, function () return mq.TLO.Window(epicBook).Open() == true end)
    mq.cmdf('/combine %s', epicBook)
    mq.delay(WaitTime)
    mq.cmd('/autoinventory')
    mq.delay(WaitTime, CursorEmpty)
end

local function Main()
    if args ~= nil then
        if args[1] == 'resist' then
            CombineResistAugs()
        elseif args[1] == 'epic' then
            if args[2] ~= nil then
                if args[2] == '1.5' then
                    CONSOLEMETHOD(true, 'Attempting Epic 1.5 Combine')
                    CombineEpic1_5()
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
