local mq = require('mq')
local imgui = require('ImGui')
local storage = {}

function storage.ReadINIValue(filename, section, option)
    return mq.TLO.Ini.File(filename).Section(section).Key(option).Value()
end

function storage.ReadINISection(filename, section)
    return mq.TLO.Ini.File(filename).Section(section)
end

function storage.SetINIValue(filename, section, option, value)
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', filename, section, option, value)
end

storage.dir_exists = function(path)
    printf('function dir_exists(%s) Entry', path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

storage.make_dir = function(path)
    printf('function make_dir(%s) Entry', path)
    local success, errorMsg = os.execute("mkdir \"" .. path .. "\"")
    if success then
        return true
    else
        return false, errorMsg
    end
end

function storage.SaveSettings(iniFile, settingsList)
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

local settingsFile = mq.configDir .. '\\Feed-Chomps.ini'
local Chomps = {
    Version = "1.0.0",
    minSellHP = 100,
    name = 'Chomps',
    chompsZone = 344,
    UseWarp = false,
    bagStates = {},
    bagTexture = mq.FindTextureAnimation("A_DragItem"),
    feedDelay = 500
}
local open = true
local showSettingsWindow = false
local feedChompers = false
local function saveSetting(fileName, categoryName, itemName, itemValue)
    storage.SetINIValue(fileName, categoryName, itemName, itemValue)
end
local saveOptionTypes = {
    string = 1,
    number = 1,
    boolean = 1
}
local function writeSettings()
    for option, value in pairs(Chomps) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            saveSetting(settingsFile, 'Settings', option, value)
        end
    end

    -- Save bagStates separately as a comma-separated list of skipped slots
    local disabledSlots = {}
    for slot, state in pairs(Chomps.bagStates) do
        if state then
            table.insert(disabledSlots, slot)
        end
    end
    local bagStateString = table.concat(disabledSlots, ",")
    saveSetting(settingsFile, 'Settings', 'bagStates', bagStateString)
end

local function loadSettings()
    local iniSettings = storage.ReadINISection(settingsFile, 'Settings')
    local keyCount = iniSettings.Key.Count()
    for i = 1, keyCount do
        local key = iniSettings.Key.KeyAtIndex(i)()
        local value = iniSettings.Key(key).Value()
        if key == 'Version' then
            Chomps[key] = value
        elseif key == 'bagStates' then
            -- Parse the comma-separated list into the table
            Chomps.bagStates = {}
            for slotStr in value:gmatch("([^,]+)") do
                local slotNum = tonumber(slotStr)
                if slotNum then
                    Chomps.bagStates[slotNum] = true
                end
            end
        elseif value == 'true' or value == 'false' then
            Chomps[key] = value == 'true'
        elseif tonumber(value) then
            Chomps[key] = tonumber(value)
        else
            Chomps[key] = value
        end
    end
end

local function navToID(spawnID)
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    local playerLoopDelay = 100 + playerPing
    if Chomps.UseWarp then
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
local function goToChomps()
    if mq.TLO.Zone.ID() ~= Chomps.chompsZone then return end
    if not mq.TLO.Target() then
        mq.cmdf('/target npc %s', Chomps.name)
        mq.delay(2000, function() return mq.TLO.Target() ~= nil end)
    end
    local vendorName = mq.TLO.Target.CleanName()
    if vendorName ~= Chomps.name then goToChomps() end
    if mq.TLO.Target.Distance() > 15 then
        if Chomps.UseWarp then
            mq.cmdf('%s', '/warp t')
            local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
            local playerDelay = 500 + playerPing
            mq.delay(playerDelay)
        else
            navToID(mq.TLO.Target.ID())
        end
    end
    printf('Doing business with %s', vendorName)
    mq.cmd('/keypress OPEN_INV_BAGS')
    return true
end
local function feedChomps(itemToFeed)
    local itemLink = itemToFeed.ItemLink('CLICKABLE')()
    printf('Feeding %s: %s', Chomps.name, itemLink)
    mq.cmdf('/nomodkey /itemnotify "%s" leftmouseup', itemToFeed)
    mq.delay(2000, function() return mq.TLO.Cursor.ID() ~= nil end)
    mq.cmd('/nomodkey /click left target')
    mq.delay(2000, function() return mq.TLO.Cursor.ID() == nil end)
    mq.delay(Chomps.feedDelay)
end
local function feedChompsBagItem(itemToFeed, itemBag, itemBagSlot)
    local itemLink = itemToFeed.ItemLink('CLICKABLE')()
    printf('Feeding %s: %s', Chomps.name, itemLink)
    mq.cmdf('/nomodkey /itemnotify in pack%s %s leftmouseup', itemBag, itemBagSlot)
    mq.delay(2000, function() return mq.TLO.Cursor.ID() ~= nil end)
    -- Drop it onto the target
    mq.cmd('/nomodkey /click left target')
    mq.delay(2000, function() return mq.TLO.Cursor.ID() == nil end)
    mq.delay(Chomps.feedDelay)
end
local function processChompsFeeding()
    goToChomps()

    local itemsHanded = 0

    -- Feed from top-level inventory
    for i = 1, 10 do
        local shouldSkip = Chomps.bagStates[22 + i] -- Inventory slots 23 to 32
        if not shouldSkip then
            local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
            if bagSlot() and bagSlot.Container() == 0 and bagSlot.ID() then
                feedChomps(bagSlot)
                itemsHanded = itemsHanded + 1

                if itemsHanded >= 4 then
                    mq.delay(200)
                    mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
                    mq.delay(1000)
                    itemsHanded = 0
                end
            end
        end
    end

    -- Feed from inside containers
    for i = 1, 10 do
        local shouldSkip = Chomps.bagStates[22 + i]
        if not shouldSkip then
            local bagSlot = mq.TLO.InvSlot('pack' .. i).Item
            local containerSize = bagSlot.Container()

            if containerSize and containerSize > 0 then
                for j = 1, containerSize do
                    local itemToSell = bagSlot.Item(j)
                    if itemToSell() and itemToSell.Name() and itemToSell.HP() > Chomps.minSellHP then
                        feedChompsBagItem(itemToSell, i, j)
                        itemsHanded = itemsHanded + 1

                        if itemsHanded >= 4 then
                            mq.delay(200)
                            mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
                            mq.delay(1000)
                            itemsHanded = 0
                        end
                    end
                end
            end
        end
    end

    -- Final trade if any items remain
    if itemsHanded > 0 then
        mq.delay(200)
        mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
        mq.delay(1000)
    end
end

local function getBagSlots()
    local slots = {}
    for slot = 23, 32 do
        local item = mq.TLO.InvSlot(slot).Item
        table.insert(slots, {
            name = item() and item.Name() or "Empty",
            slot = slot,
            iconID = item() and item.Icon() or nil,
            hasBag = item() and item.Container() > 0
        })
    end
    return slots
end

local function drawWindow()
    if not open then return end

    local success
    open, success = imgui.Begin("Feed Chompers", open)
    if not success then
        imgui.End()
        return
    end

    local bags = getBagSlots()
    for i, bag in ipairs(bags) do
        local state = Chomps.bagStates[bag.slot] or false

        imgui.PushID(bag.slot)

        if imgui.InvisibleButton("bag" .. bag.slot, 40, 40) then
            if bag.hasBag then
                Chomps.bagStates[bag.slot] = not state
                writeSettings()
            end
        end

        local x, y = imgui.GetItemRectMin()
        local x2, y2 = imgui.GetItemRectMax()
        local drawList = imgui.GetWindowDrawList()
        local col = (bag.hasBag and (Chomps.bagStates[bag.slot] and 0xFF0000FF or 0xFF00FF00)) or 0xFF555555 -- red, green, or gray
        drawList:AddRectFilled(ImVec2(x, y), ImVec2(x2, y2), col)

        local cx, cy = imgui.GetCursorPos()
        imgui.SetCursorScreenPos(x, y)

        if bag.hasBag and Chomps.bagTexture and bag.iconID then
            Chomps.bagTexture:SetTextureCell(bag.iconID - 500)
            imgui.DrawTextureAnimation(Chomps.bagTexture, 40, 40)
        else
            -- Optionally draw a fallback rectangle or symbol here
            -- Or just let the background gray box show
        end

        imgui.SetCursorPos(cx, cy)

        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(bag.name or "Empty")
            imgui.EndTooltip()
        end

        imgui.PopID()

        if i % 2 == 1 then
            imgui.SameLine(0, 5)
        else
            imgui.Dummy(0, 5)
        end
    end
    if imgui.Button('Feed Chomps') then
        feedChompers = true
    end
    if imgui.Button('Settings') then
        showSettingsWindow = not showSettingsWindow
    end
    imgui.End()

    if showSettingsWindow then
        local success
        showSettingsWindow, success = imgui.Begin("Chomps Settings", showSettingsWindow)
        if not success then
            imgui.End()
            return
        end
        if success then
            -- Editable fields
            local minSellHP = Chomps.minSellHP
            local feedDelay = Chomps.feedDelay
            local useWarp = Chomps.UseWarp
            local chompsName = Chomps.name
            local chompsZone = Chomps.chompsZone

            -- Checkbox for warp option
            useWarp, changed = imgui.Checkbox("Use Warp", useWarp)
            if changed then
                Chomps.UseWarp = useWarp
                writeSettings()
            end

            -- Input for chomps name
            chompsName, changed = imgui.InputText("Name of NPC", chompsName)
            if changed then
                Chomps.name = chompsName
                writeSettings()
            end

            -- Input for chomps Zone
            chompsZone, changed = imgui.InputInt("Zone of NPC", chompsZone)
            if changed then
                Chomps.chompsZone = chompsZone
                writeSettings()
            end

            -- Input for minimum HP
            minSellHP, changed = imgui.InputInt("Min HP to Feed", minSellHP)
            if changed then
                Chomps.minSellHP = minSellHP
                writeSettings()
            end

            -- Input for feed delay
            feedDelay, changed = imgui.InputInt("Feed Delay (ms)", feedDelay)
            if changed then
                Chomps.feedDelay = feedDelay
                writeSettings()
            end

            imgui.End()
        end
    end
end

mq.imgui.init("Feed Chompers", drawWindow)
loadSettings()

mq.cmdf('/target npc %s', Chomps.name)
mq.delay(2000, function() return mq.TLO.Target() ~= nil end)
processChompsFeeding()
feedChompers = false
