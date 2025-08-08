---@type Mq
local mq = require('mq')
local storage = require('DroidLoot.lib.Storage')
local messages = require('DroidLoot.lib.Messages')
local gui = {}

gui.version = '1.0.9'
gui.versionOrder = { "1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.0.4", "1.0.5", "1.0.6", "1.0.7", "1.0.8", "1.0.9" }
gui.change_Log = {
    ['1.0.0'] = { 'Initial Release',
        '- Added GUI for loot options'
    },
    ['1.0.1'] = { 'Announce Changes',
        '- Changed how the script handles skipped items and ignored items.',
        '- Added Change log to Info page',
        '- Added Loot list to GUI',
        '- Modified default settings (Disabled warp by default)'
    },
    ['1.0.2'] = { 'Loot Gear Upgrades',
        '- Added option to loot items with more HP than currently worn items.',
        '- Fixed a delay issue in the loot corpse function which sometimes caused a hang.',
        '- Added wild card looting',
        '- Added flag for auto looting evolving items.'
    },
    ['1.0.3'] = { 'Bug Fix',
        '- Disabled looting of evolving items by default. It was buggy on emulator.',
        '- Fixed an issue in the script when running newer versions of Macroquest.',
        '- Added Update option to make it easier to get latest files. You still need to install them but it will start the download.'
    },
    ['1.0.4'] = { 'Bug Fix',
        '- Fixed issue with add/remove in Wildcard Terms',
        '- Wildcard Terms now saves its array to INI'
    },
    ['1.0.5'] = { 'Bug Fix',
        '- Added time stamps to all loot messages.',
        '- Added clean messages for announce when using /g and /rsay. Dannet and others will still get unicode characters.',
        '- Cleaned up report loot function to make messaging more consistant throughout the script.',
        '- Deleted some unused and unneeded code form past projects.',
        '- Added debug messages into loot decisions. So youcan turn it on and see whats going on easily.',
        '- Changed the sell function to give item links instead of just item name.'
    },
    ['1.0.6'] = { 'Bug Fix',
        '- Added option to loot no drop items with LootByMinHP.',
        '- Changed items to be combo boxes instead of text boxes to be easier to change.',
        '- Revamped saving.',
        '- Fixed AnnouceUpgrade to use the standard reporting function.',
        '- Changed loot upgrades to loot for empty slots.',
        '- Fixed issue with some Annoucements.',
        '- Added option to announce upgrades when using LootByMinHP.'
    },
    ['1.0.7'] = { 'Bug Fix + Feature',
        '- Changed delays in loot corpse to account for player ping.',
        '- Added minimized mode to save screen space.',
        '- Added Healing options',
        '- Added Camp Options.',
        '- Added option to move back to camp if too far',
        '- Added option to move back to camp after looting',
        '- Moved Wasting Time options under Server Specific Options.'
    },
    ['1.0.8'] = { 'New GUI Loot Window',
        '- Added GUI for modifying loot options.',
        '- This is accessible in droid loot and my lootutils.',
        '- /dlu gui to toggle the gui on/off when calling via lootutils',
        '- Made the console actually do something.'
    },
    ['1.0.9'] = { 'Added new options',
        '- Added options for loot by damage',
        '- Added options for loot by Number of Augment Slots',
        '- Added slot toggles for loot upgrades.'
    },
}

function gui.ChangeLog()
    ImGui.Text("Change Log:")

    local logText = ""
    for _, version in ipairs(gui.versionOrder) do
        local changes = gui.change_Log[version]
        if changes then
            logText = logText .. "[" .. version .. "]\n"
            logText = logText .. changes[1] .. "\n"
            for i = 2, #changes do
                logText = logText .. changes[i] .. "\n"
            end
            logText = logText .. "\n"
        end
    end

    local lineCount = 0
    for _ in string.gmatch(logText, "\n") do
        lineCount = lineCount + 1
    end

    local lineHeight = 18
    local desiredHeight = lineCount * lineHeight

    -- Get available region as two return values (width, height)
    local availWidth, availHeight = ImGui.GetContentRegionAvail()

    local height = math.min(desiredHeight, availHeight)

    ImGui.InputTextMultiline("##changeLog", logText, availWidth, height, ImGuiInputTextFlags.ReadOnly)
end

-- DroidLoot.LootUtils.loadSettings()
gui.DEBUG = DroidLoot.debug
gui.DOSELL = DroidLoot.doSell
gui.DOLOOT = DroidLoot.doLoot
gui.CORPSEFIX = DroidLoot.doCorpseFix
gui.LOOTEVOLVINGITEMS = DroidLoot.LootUtils.LootEvolvingItems
gui.MOBSTOOCLOSE = DroidLoot.LootUtils.MobsTooClose
gui.CORPSERADIUS = DroidLoot.LootUtils.CorpseRadius
gui.ADDNEWSALES = DroidLoot.LootUtils.AddNewSales
gui.ADDIGNOREDITEMS = DroidLoot.LootUtils.AddIgnoredItems
gui.USECLASSLOOTFILE = DroidLoot.LootUtils.useClassLootFile
gui.USEARMORTYPELOOTFILE = DroidLoot.LootUtils.useArmorTypeLootFile
gui.USEMACROLOOTFILE = DroidLoot.LootUtils.useMacroLootFile
gui.USEZONELOOTFILE = DroidLoot.LootUtils.useZoneLootFile
gui.USESINGLEFILEFORALLCHARACTERS = DroidLoot.LootUtils.UseSingleFileForAllCharacters
gui.LOOTFORAGE = DroidLoot.LootUtils.LootForage
gui.REPORTLOOT = DroidLoot.LootUtils.ReportLoot
gui.ANNOUNCEUPGRADES = DroidLoot.LootUtils.AnnounceUpgrades
gui.LOOTCHANNEL = DroidLoot.LootUtils.LootChannel
gui.SPAMLOOTINFO = DroidLoot.LootUtils.SpamLootInfo
gui.COMBATLOOTING = DroidLoot.LootUtils.CombatLooting
gui.LOOTGEARUPGRADES = DroidLoot.LootUtils.LootGearUpgrades
gui.LOOTWILDCARDITEMS = DroidLoot.LootUtils.LootWildCardItems
gui.MINSELLPRICE = DroidLoot.LootUtils.MinSellPrice
gui.STACKABLEONLY = DroidLoot.LootUtils.StackableOnly
gui.LOOTBYHPMIN = DroidLoot.LootUtils.LootByMinHP
gui.LOOTBYHPMINNODROP = DroidLoot.LootUtils.LootByMinHPNoDrop
gui.STACKPLATVALUE = DroidLoot.LootUtils.StackPlatValue

gui.LOOTACTIONANNOUNCE = DroidLoot.LootUtils.shouldLootActions['Announce']
gui.LOOTACTIONBANK = DroidLoot.LootUtils.shouldLootActions['Bank']
gui.LOOTACTIONCASH = DroidLoot.LootUtils.shouldLootActions['Cash']
gui.LOOTACTIONDESTROY = DroidLoot.LootUtils.shouldLootActions['Destroy']
gui.LOOTACTIONIGNORE = DroidLoot.LootUtils.shouldLootActions['Ignore']
gui.LOOTACTIONKEEP = DroidLoot.LootUtils.shouldLootActions['Keep']
gui.LOOTACTIONQUEST = DroidLoot.LootUtils.shouldLootActions['Quest']
gui.LOOTACTIONSELL = DroidLoot.LootUtils.shouldLootActions['Sell']
gui.LOOTACTIONWILDCARD = DroidLoot.LootUtils.shouldLootActions['Wildcard']

gui.RETURNHOMEAFTERLOOT = DroidLoot.LootUtils.returnHomeAfterLoot
gui.CAMPCHECK = DroidLoot.LootUtils.camp_Check
gui.ZONECHECK = DroidLoot.LootUtils.zone_Check
gui.RETURNTOCAMPDISTANCE = DroidLoot.LootUtils.returnToCampDistance
gui.STATICHUNT = DroidLoot.LootUtils.staticHunt
gui.STATICZONEID = DroidLoot.LootUtils.staticZoneID
gui.STATICZONENAME = DroidLoot.LootUtils.staticZoneName
gui.STATICX = DroidLoot.LootUtils.staticX
gui.STATICY = DroidLoot.LootUtils.staticY
gui.STATICZ = DroidLoot.LootUtils.staticZ
gui.HEALTHCHECK = DroidLoot.LootUtils.health_Check
gui.HEALAT = DroidLoot.LootUtils.heal_At
gui.HEALSPELL = DroidLoot.LootUtils.heal_Spell
gui.HEALGEM = DroidLoot.LootUtils.heal_Gem

gui.LOOTBYAUGSLOTS = DroidLoot.LootUtils.LootByAugSlots
gui.LOOTBYAUGSLOTSAMOUNT = DroidLoot.LootUtils.LootByAugSlotsAmount
gui.LOOTBYAUGSLOTSTYPE = DroidLoot.LootUtils.LootByAugSlotsType
gui.LOOTBYDAMAGE = DroidLoot.LootUtils.LootByDamage
gui.LOOTBYDAMAGEAMOUNT = DroidLoot.LootUtils.LootByDamageAmount
gui.LOOTBYDAMAGEEFFICIENCY = DroidLoot.LootUtils.LootByDamageEfficiency
gui.LOOTBYDAMAGEEFFICIENCYAMOUNT = DroidLoot.LootUtils.LootByDamageEfficiencyAmount
gui.LOOTBYAC = DroidLoot.LootUtils.LootByAC
gui.LOOTBYACAMOUNT = DroidLoot.LootUtils.LootByACAmount

gui.USEWARP = DroidLoot.LootUtils.UseWarp
gui.USEWARPINSTANCEONLY = DroidLoot.LootUtils.UseWarpInstanceOnly

gui.CurrentStatus = ' '
gui.Open = false
gui.ShowUI = false

local iniData = {}
local itemActions = { "Keep", "Ignore", "Announce", "Destroy", "Sell", "Fabled", "Cash" }

function LoadINI(path)
    local data = {}
    local section = nil

    for line in io.lines(path) do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^;") then
            local new_section = line:match("^%[(.-)%]$")
            if new_section then
                section = new_section
                data[section] = {}
            elseif section and line:find("=") then
                local key, value = line:match("^(.-)=(.*)$")
                if key and value and key:lower() ~= "defaults" then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")
                    data[section][key] = value
                end
            end
        end
    end

    return data
end

iniData = LoadINI(DroidLoot.LootUtils.Settings.LootFile)

local actionBuffers = {}

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function addItemToSection(section, itemName, action)
    printf('%s / %s / %s', section, itemName, action)
    iniData[section] = iniData[section] or {}
    iniData[section][itemName] = action or ""
    -- Saving to ini file right away if you want:
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', DroidLoot.LootUtils.Settings.LootFile, section, itemName, action)
end

gui.ACTION = ''
local newItemName
local newItemAction
local current_idx
-- Global state variable
local show_main = true -- Main form is visible by default
local dlIconImg = mq.CreateTexture(mq.luaDir .. "/DroidLoot/Resources/DroidLoot.png")
local dlFullImg = mq.CreateTexture(mq.luaDir .. "/DroidLoot/Resources/icon.png")
local iniFile = DroidLoot.LootUtils.Settings.LootFile

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
-- Add this near the top, after your flags definition
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
-- Individual flag visibility states
local showQuest = flagsVisible.Quest
local showKeep = flagsVisible.Keep
local showIgnore = flagsVisible.Ignore
local showAnnounce = flagsVisible.Announce
local showDestroy = flagsVisible.Destroy
local showSell = flagsVisible.Sell
local showFabled = flagsVisible.Fabled
local showCash = flagsVisible.Cash

local function LoadLootListFromINI()
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
    local section = string.upper(itemName:sub(1, 1))
    storage.SetINIValue(iniFile, section, itemName, flag)
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

local layout = {
    { "Ear1",    "Head",      "Face",  "Ear2" },
    { "Chest",   "",          "",      "Neck" },
    { "Arms",    "",          "",      "Back" },
    { "Waist",   "",          "",      "Shoulder" },
    { "Wrist1",  "",          "",      "Wrist2" },
    { "Legs",    "Hands",     "Charm", "Feet" },
    { "",        "Ring1",     "Ring2", "" },
    { "Primary", "Secondary", "Range", "Ammo" },
}

local equipmentSlots = {
    Charm = 0,
    Ear1 = 1,
    Head = 2,
    Face = 3,
    Ear2 = 4,
    Neck = 5,
    Shoulder = 6,
    Arms = 7,
    Back = 8,
    Wrist1 = 9,
    Wrist2 = 10,
    Range = 11,
    Hands = 12,
    Primary = 13,
    Secondary = 14,
    Ring1 = 15,
    Ring2 = 16,
    Chest = 17,
    Legs = 18,
    Feet = 19,
    Waist = 20,
    Powersource = 21,
    Ammo = 22,
}

-- Define toggle groups
local slotGroups = {
    Ear1 = "Ears",
    Ear2 = "Ears",
    Ring1 = "Rings",
    Ring2 = "Rings"
}

-- Track toggle states for each slot group
local slotStates = {}
-- Dummy texture you should load properly, or replace with your actual slot texture (similar to Chomps.bagTexture)
local slotTexture = mq.FindTextureAnimation("A_DragItem")
local function slotButton(name)
    if name ~= "" then
        local group = slotGroups[name] or name

        if slotStates[group] == nil then
            slotStates[group] = DroidLoot.LootUtils.LootUpgrades[name] ~= nil and DroidLoot.LootUtils.LootUpgrades[name] or false
        end

        ImGui.PushID(name)

        if ImGui.InvisibleButton("btn_" .. name, 48, 48) then
            local newState = not slotStates[group]
            slotStates[group] = newState

            -- Save state to all slot names in the group
            for slotName, slotGroup in pairs(slotGroups) do
                if slotGroup == group then
                    slotStates[slotName] = newState
                    DroidLoot.LootUtils.LootUpgrades[slotName] = newState
                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'LootUpgrades', slotName, newState)
                end
            end

            -- Also handle individually clicked slot if not in slotGroups
            if not slotGroups[name] then
                slotStates[name] = newState
                DroidLoot.LootUtils.LootUpgrades[name] = newState
                DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'LootUpgrades', name, newState)
            end
        end

        local x, y = ImGui.GetItemRectMin()
        local x2, y2 = ImGui.GetItemRectMax()
        local drawList = ImGui.GetWindowDrawList()

        local iconID = mq.TLO.Me.Inventory(equipmentSlots[name]).Icon()
        local hasIcon = iconID ~= nil

        -- Always show toggle color (green/red)
        local col = slotStates[group] and 0xFF00FF00 or 0xFF0000FF
        drawList:AddRectFilled(ImVec2(x, y), ImVec2(x2, y2), col)

        local cx, cy = ImGui.GetCursorPos()
        ImGui.SetCursorScreenPos(x, y)

        if hasIcon and slotTexture then
            slotTexture:SetTextureCell(iconID - 500)
            ImGui.DrawTextureAnimation(slotTexture, 48, 48)
        else
            local textSizeX, textSizeY = ImGui.CalcTextSize(name)
            local textX = x + (48 - textSizeX) / 2
            local textY = y + (48 - textSizeY) / 2
            drawList:AddText(ImVec2(textX, textY), 0xFFFFFFFF, name)
        end

        ImGui.SetCursorPos(cx, cy)

        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text('Click toggle auto looting of upgrade for ' .. name .. '.')
            ImGui.EndTooltip()
        end

        ImGui.PopID()
    else
        ImGui.Dummy(ImVec2(48, 48))
    end
end

function gui.DroidLootGUI()
    if show_main then
        gui.Open, gui.ShowUI = ImGui.Begin('TheDroid Droid Loot Bot v' .. gui.version, gui.Open)
        if gui.Open then
            local x_size = 665
            local y_size = 680
            ImGui.SetWindowSize(x_size, y_size, ImGuiCond.Once)
            local io = ImGui.GetIO()
            local center_x = io.DisplaySize.x / 2
            local center_y = io.DisplaySize.y / 2
            ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
            ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
            if gui.ShowUI then
                local windowWidth = ImGui.GetWindowContentRegionWidth()
                local buttonWidth, buttonHeight = 120, 30
                local buttonWidthSmall = 90

                -- Left button (Pause/Resume) at left edge (x=0)
                ImGui.SetCursorPosX(15)
                if DroidLoot.doPause then
                    if ImGui.Button('Resume', ImVec2(buttonWidth, buttonHeight)) then
                        DroidLoot.doPause = false
                    end
                else
                    if ImGui.Button('Pause', ImVec2(buttonWidth, buttonHeight)) then
                        DroidLoot.doPause = true
                    end
                end
                ImGui.SameLine()

                -- Center 3 buttons: Bank, Sell, Minimize
                -- Calculate total width of center buttons + spacing
                local spacing = 10
                local totalCenterWidth = buttonWidthSmall * 3 + spacing * 2

                -- Position cursor to center start
                local centerStartX = (windowWidth - totalCenterWidth) / 2
                ImGui.SetCursorPosX(centerStartX)

                if ImGui.Button('Bank', ImVec2(buttonWidthSmall, buttonHeight)) then
                    DroidLoot.needToBank = true
                end
                ImGui.SameLine()
                ImGui.Dummy(ImVec2(spacing, 0)) -- spacing
                ImGui.SameLine()
                if ImGui.Button('Sell', ImVec2(buttonWidthSmall, buttonHeight)) then
                    DroidLoot.needToVendorSell = true
                end
                ImGui.SameLine()
                ImGui.Dummy(ImVec2(spacing, 0)) -- spacing
                ImGui.SameLine()
                if ImGui.Button('Minimize', ImVec2(buttonWidthSmall, buttonHeight)) then
                    show_main = false
                end
                ImGui.SameLine()
                -- Right button (Quit DroidLoot) aligned to right edge
                -- Position cursor at right edge minus button width
                local rightStartX = windowWidth - buttonWidth
                ImGui.SetCursorPosX(rightStartX)
                if ImGui.Button('Quit DroidLoot', ImVec2(buttonWidth, buttonHeight)) then
                    DroidLoot.terminate = true
                    mq.cmdf('/lua stop %s', 'DroidLoot')
                end

                -- Spacing if needed
                ImGui.Spacing()

                local tabBarOpen = ImGui.BeginTabBar("MainTabs")
                if tabBarOpen then
                    local mainOpen = ImGui.BeginTabItem("Main")
                    if mainOpen then
                        ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                            "It will loot anything set in the DroidLoot.ini.\n")
                        ImGui.Separator();

                        ImGui.Text("COMMANDS:");
                        ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' sell');
                        ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' sellall');
                        ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' bank');
                        ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' cash');
                        ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' fabled');
                        ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' quit');
                        ImGui.Separator();

                        ImGui.Text("CREDIT:");
                        ImGui.BulletText("TheDroidUrLookingFor");
                        ImGui.EndTabItem()
                    end

                    local lootListOpen = ImGui.BeginTabItem("Loot List")
                    if lootListOpen then
                        newItemName = newItemName or ""
                        newItemAction = newItemAction or ""
                        current_idx = current_idx or 1

                        if ImGui.CollapsingHeader('Add New Item') then
                            -- Input: Name
                            newItemName = ImGui.InputText("Item Name", newItemName)

                            -- Combo Box for Action
                            if ImGui.BeginCombo("Action", itemActions[current_idx]) then
                                for n = 1, #itemActions do
                                    local is_selected = (current_idx == n)
                                    if ImGui.Selectable(itemActions[n], is_selected) then
                                        current_idx = n
                                        newItemAction = itemActions[n] -- Set newItemAction
                                    end
                                    if is_selected then
                                        ImGui.SetItemDefaultFocus()
                                    end
                                end
                                ImGui.EndCombo()
                            end

                            -- Add item manually
                            if ImGui.Button("Add Item") then
                                if newItemName ~= "" then
                                    local section = string.sub(newItemName, 1, 1):upper()
                                    local actionToUse = newItemAction ~= "" and newItemAction or itemActions[current_idx]
                                    addItemToSection(section, newItemName, actionToUse)
                                    -- Clear after adding
                                    newItemName = ""
                                    newItemAction = ""
                                end
                            end

                            -- Add item from cursor
                            ImGui.SameLine(325)
                            if ImGui.Button("Add Cursor Item") then
                                local cursorName = mq.TLO.Cursor.Name()
                                if cursorName and cursorName ~= "" then
                                    local section = cursorName:sub(1, 1):upper()
                                    local actionToUse = newItemAction ~= "" and newItemAction or itemActions[current_idx]
                                    addItemToSection(section, cursorName, actionToUse)
                                    newItemName = ""
                                end
                            end
                        end

                        ImGui.Unindent()
                        ImGui.Indent()

                        -- Sections rendering
                        local sortedSections = sortedKeys(iniData)
                        for _, section in ipairs(sortedSections) do
                            local items = iniData[section]
                            if section ~= "Settings" and section ~= "wildCardTerms" then
                                if ImGui.CollapsingHeader(string.format("[%s] (%d items)", section, tablelength(items))) then
                                    ImGui.Columns(2, "LootColumns", true)
                                    ImGui.Text("Item")
                                    ImGui.NextColumn()
                                    ImGui.Text("Action")
                                    ImGui.NextColumn()
                                    ImGui.Separator()

                                    local sortedItems = sortedKeys(items)
                                    for _, itemName in ipairs(sortedItems) do
                                        local action = items[itemName]
                                        ImGui.Text(itemName)
                                        ImGui.NextColumn()

                                        local key = section .. "_" .. itemName

                                        -- Initialize current index for combo selection if not already done
                                        if not actionBuffers[key] then
                                            actionBuffers[key] = action
                                        end

                                        if not actionIndices then
                                            actionIndices = {}
                                        end

                                        if actionBuffers[key] ~= nil and actionIndices[key] == nil then
                                            -- Find index for the current action value
                                            for i = 1, #itemActions do
                                                if itemActions[i] == actionBuffers[key] then
                                                    actionIndices[key] = i
                                                    break
                                                end
                                            end
                                            -- If not found, default to 1
                                            if not actionIndices[key] then
                                                actionIndices[key] = 1
                                            end
                                        end

                                        -- Combo Box for Action
                                        if ImGui.BeginCombo("##" .. key, itemActions[actionIndices[key]]) then
                                            for n = 1, #itemActions do
                                                local is_selected = (actionIndices[key] == n)
                                                if ImGui.Selectable(itemActions[n], is_selected) then
                                                    actionIndices[key] = n
                                                    actionBuffers[key] = itemActions[n]
                                                    iniData[section][itemName] = itemActions[n]
                                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, section, itemName, itemActions[n])
                                                end
                                                if is_selected then
                                                    ImGui.SetItemDefaultFocus()
                                                end
                                            end
                                            ImGui.EndCombo()
                                        end

                                        ImGui.NextColumn()
                                    end
                                    ImGui.Columns(1)
                                end
                            end
                        end

                        ImGui.EndTabItem()
                    end

                    local newLootListOpen = ImGui.BeginTabItem("New Loot List")
                    if newLootListOpen then
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
                        ImGui.EndTabItem()
                    end

                    local optionsOpen = ImGui.BeginTabItem("Options")
                    if optionsOpen then
                        local optionsBarOpen = ImGui.BeginTabBar("OptionsTabs")
                        if optionsBarOpen then
                            local lootByAugSlotsOpen = ImGui.BeginTabItem("Loot By Aug Slots")
                            if lootByAugSlotsOpen then
                                local lootByAugSlotTypes = { "Any", "Armor", "Weapon", "NonVis" }
                                DroidLoot.LootUtils.LootByAugSlots = ImGui.Checkbox('Enable## Loot By Aug Slot', DroidLoot.LootUtils.LootByAugSlots)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items by their amount of aug slots when enabled.')
                                if gui.LOOTBYAUGSLOTS ~= DroidLoot.LootUtils.LootByAugSlots then
                                    gui.LOOTBYAUGSLOTS = DroidLoot.LootUtils.LootByAugSlots
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByAugSlots', DroidLoot.LootUtils.LootByAugSlots)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootByAugSlotsAmount = ImGui.SliderInt("Min Slots", DroidLoot.LootUtils.LootByAugSlotsAmount, 1, 6)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The minimum amount of aug slots an item needs to be kept.')
                                if gui.LOOTBYAUGSLOTSAMOUNT ~= DroidLoot.LootUtils.LootByAugSlotsAmount then
                                    gui.LOOTBYAUGSLOTSAMOUNT = DroidLoot.LootUtils.LootByAugSlotsAmount
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByAugSlotsAmount', DroidLoot.LootUtils.LootByAugSlotsAmount)
                                end
                                ImGui.Separator();

                                -- Add Combo Box here for Types
                                DroidLoot.LootUtils.LootByAugSlotsTypeIndex = DroidLoot.LootUtils.LootByAugSlotsTypeIndex or 1
                                local lootTypeLabel = lootByAugSlotTypes[DroidLoot.LootUtils.LootByAugSlotsTypeIndex] or lootByAugSlotTypes[1]

                                if ImGui.BeginCombo("Slot Type", lootTypeLabel) then
                                    for i = 1, #lootByAugSlotTypes do
                                        local is_selected = (DroidLoot.LootUtils.LootByAugSlotsTypeIndex == i)
                                        if ImGui.Selectable(lootByAugSlotTypes[i], is_selected) then
                                            DroidLoot.LootUtils.LootByAugSlotsTypeIndex = i
                                            DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByAugSlotsTypeIndex', i)
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
                                DroidLoot.LootUtils.LootByDamage = ImGui.Checkbox('Enable## Loot by Damage', DroidLoot.LootUtils.LootByDamage)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items by their damage when enabled.')
                                if gui.LOOTBYDAMAGE ~= DroidLoot.LootUtils.LootByDamage then
                                    gui.LOOTBYDAMAGE = DroidLoot.LootUtils.LootByDamage
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByDamage', DroidLoot.LootUtils.LootByDamage)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootByDamageAmount = ImGui.SliderInt("Min Damage", DroidLoot.LootUtils.LootByDamageAmount, 1, 1000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The minimum amount of damage an item needs to be kept.')
                                if gui.LOOTBYDAMAGEAMOUNT ~= DroidLoot.LootUtils.LootByDamageAmount then
                                    gui.LOOTBYDAMAGEAMOUNT = DroidLoot.LootUtils.LootByDamageAmount
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByDamageAmount', DroidLoot.LootUtils.LootByDamageAmount)
                                end
                                ImGui.Separator();

                                ImGui.EndTabItem()
                            end
                            local lootByDamageEfficiencyOpen = ImGui.BeginTabItem("Loot By Damage Efficiency")
                            if lootByDamageEfficiencyOpen then
                                DroidLoot.LootUtils.LootByDamageEfficiency = ImGui.Checkbox('Enable## Loot by Damage Efficiency', DroidLoot.LootUtils.LootByDamageEfficiency)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items by their damage efficiency when enabled.')
                                if gui.LOOTBYDAMAGEEFFICIENCY ~= DroidLoot.LootUtils.LootByDamageEfficiency then
                                    gui.LOOTBYDAMAGEEFFICIENCY = DroidLoot.LootUtils.LootByDamageEfficiency
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByDamageEfficiency', DroidLoot.LootUtils.LootByDamageEfficiency)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootByDamageEfficiencyAmount = ImGui.SliderInt("Min Efficiency", DroidLoot.LootUtils.LootByDamageEfficiencyAmount, 1, 1000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The minimum amount of efficiency an item needs to be kept.')
                                if gui.LOOTBYDAMAGEEFFICIENCYAMOUNT ~= DroidLoot.LootUtils.LootByDamageEfficiencyAmount then
                                    gui.LOOTBYDAMAGEEFFICIENCYAMOUNT = DroidLoot.LootUtils.LootByDamageEfficiencyAmount
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByDamageEfficiencyAmount', DroidLoot.LootUtils.LootByDamageEfficiencyAmount)
                                end
                                ImGui.Separator();

                                ImGui.EndTabItem()
                            end

                            local lootUpgradesOpen = ImGui.BeginTabItem("Loot Upgrades")
                            if lootUpgradesOpen then
                                DroidLoot.LootUtils.LootGearUpgrades = ImGui.Checkbox('Enable Upgrade Looting', DroidLoot.LootUtils.LootGearUpgrades)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items with more HP than currently worn items.')
                                if LOOTGEARUPGRADES ~= DroidLoot.LootUtils.LootGearUpgrades then
                                    LOOTGEARUPGRADES = DroidLoot.LootUtils.LootGearUpgrades
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootGearUpgrades', DroidLoot.LootUtils.LootGearUpgrades)
                                end
                                ImGui.Separator();
                                ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, ImVec2(4, 4))

                                for row = 1, #layout do
                                    for col = 1, 4 do
                                        slotButton(layout[row][col])
                                        if col < 4 then
                                            ImGui.SameLine();
                                        end
                                    end
                                end

                                ImGui.PopStyleVar();
                                ImGui.EndTabItem();
                            end

                            local lootByACOpen = ImGui.BeginTabItem("Loot By AC")
                            if lootByACOpen then
                                DroidLoot.LootUtils.LootByAC = ImGui.Checkbox('Enable## Loot by AC', DroidLoot.LootUtils.LootByAC)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items by their armor class when enabled.')
                                if gui.LOOTBYAC ~= DroidLoot.LootUtils.LootByAC then
                                    gui.LOOTBYAC = DroidLoot.LootUtils.LootByAC
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByAC', DroidLoot.LootUtils.LootByAC)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootByACAmount = ImGui.SliderInt("Min AC", DroidLoot.LootUtils.LootByACAmount, 1, 1000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The minimum amount of armor class an item needs to be kept.')
                                if gui.LOOTBYACAMOUNT ~= DroidLoot.LootUtils.LootByACAmount then
                                    gui.LOOTBYACAMOUNT = DroidLoot.LootUtils.LootByACAmount
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByACAmount', DroidLoot.LootUtils.LootByACAmount)
                                end
                                ImGui.Separator();

                                ImGui.EndTabItem();
                            end

                            local hubOperationsOpen = ImGui.BeginTabItem("Hub Operations")
                            if hubOperationsOpen then
                                ImGui.Columns(2)
                                DroidLoot.LootUtils.bankDeposit = ImGui.Checkbox('Enable Bank Deposit', DroidLoot.LootUtils.bankDeposit)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                                if gui.BANKDEPOSIT ~= DroidLoot.LootUtils.bankDeposit then
                                    gui.BANKDEPOSIT = DroidLoot.LootUtils.bankDeposit
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'bankDeposit', DroidLoot.LootUtils.bankDeposit)
                                end
                                ImGui.NextColumn();

                                DroidLoot.LootUtils.sellVendor = ImGui.Checkbox('Enable Vendor Selling', DroidLoot.LootUtils.sellVendor)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Sells items for Platinum when enabled.')
                                if gui.SELLVENDOR ~= DroidLoot.LootUtils.sellVendor then
                                    gui.SELLVENDOR = DroidLoot.LootUtils.sellVendor
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'sellVendor', DroidLoot.LootUtils.sellVendor)
                                end
                                ImGui.Separator();
                                ImGui.Columns(1)

                                DroidLoot.LootUtils.bankZone = ImGui.InputInt('Bank Zone', DroidLoot.LootUtils.bankZone)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Zone where we can access banking services.')
                                if gui.BANKZONE ~= DroidLoot.LootUtils.bankZone then
                                    gui.BANKZONE = DroidLoot.LootUtils.bankZone
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'bankZone', DroidLoot.LootUtils.bankZone)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.bankNPC = ImGui.InputText('Bank NPC', DroidLoot.LootUtils.bankNPC)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The name of the npc to warp to for banking.')
                                if gui.BANKNPC ~= DroidLoot.LootUtils.bankNPC then
                                    gui.BANKNPC = DroidLoot.LootUtils.bankNPC
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'bankNPC', DroidLoot.LootUtils.bankNPC)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.vendorNPC = ImGui.InputText('Vendor NPC', DroidLoot.LootUtils.vendorNPC)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The name of the npc to warp to for vendoring.')
                                if gui.VENDORNPC ~= DroidLoot.LootUtils.vendorNPC then
                                    gui.VENDORNPC = DroidLoot.LootUtils.vendorNPC
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'vendorNPC', DroidLoot.LootUtils.vendorNPC)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.bankAtFreeSlots = ImGui.SliderInt("Inventory Free Slots", DroidLoot.LootUtils.bankAtFreeSlots, 1, 20)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The amount of free slots before we should bank.')
                                if gui.BANKATFREESLOTS ~= DroidLoot.LootUtils.bankAtFreeSlots then
                                    gui.BANKATFREESLOTS = DroidLoot.LootUtils.bankAtFreeSlots
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'bankAtFreeSlots', DroidLoot.LootUtils.bankAtFreeSlots)
                                end
                                ImGui.Separator();
                                ImGui.EndTabItem()
                            end
                            local healthOperationsOpen = ImGui.BeginTabItem("Health Operations")
                            if healthOperationsOpen then
                                DroidLoot.LootUtils.health_Check = ImGui.Checkbox('Enable Healing', DroidLoot.LootUtils.health_Check)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Enables healing with our heal spell when below our heal at limit.')
                                if gui.HEALTHCHECK ~= DroidLoot.LootUtils.health_Check then
                                    gui.HEALTHCHECK = DroidLoot.LootUtils.health_Check
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'health_Check', DroidLoot.LootUtils.health_Check)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.heal_Spell = ImGui.InputText('Heal Spell', DroidLoot.LootUtils.heal_Spell)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The name of the spell to cast to heal.')
                                if gui.HEALSPELL ~= DroidLoot.LootUtils.heal_Spell then
                                    gui.HEALSPELL = DroidLoot.LootUtils.heal_Spell
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'heal_Spell', DroidLoot.LootUtils.heal_Spell)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.heal_Gem = ImGui.SliderInt("Heal Gem", DroidLoot.LootUtils.heal_Gem, 1, 12)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The gem number our heal spell is on.')
                                if gui.HEALAT ~= DroidLoot.LootUtils.heal_Gem then
                                    gui.HEALAT = DroidLoot.LootUtils.heal_Gem
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'heal_Gem', DroidLoot.LootUtils.heal_Gem)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.heal_At = ImGui.SliderInt("Heal At", DroidLoot.LootUtils.heal_At, 1, 99)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The amount of health we cast our heal spell at.')
                                if gui.HEALAT ~= DroidLoot.LootUtils.heal_At then
                                    gui.HEALAT = DroidLoot.LootUtils.heal_At
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'heal_At', DroidLoot.LootUtils.heal_At)
                                end
                                ImGui.Separator();
                                ImGui.EndTabItem();
                            end
                            local movementOperationsOpen = ImGui.BeginTabItem("Movement Operations")
                            if movementOperationsOpen then
                                ImGui.Columns(2)
                                local start_y_Options = ImGui.GetCursorPosY()
                                DroidLoot.LootUtils.camp_Check = ImGui.Checkbox('Enable Camp Check', DroidLoot.LootUtils.camp_Check)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Return home if we get too far away?')
                                if gui.CAMPCHECK ~= DroidLoot.LootUtils.camp_Check then
                                    gui.CAMPCHECK = DroidLoot.LootUtils.camp_Check
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'camp_Check', DroidLoot.LootUtils.camp_Check)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.zone_Check = ImGui.Checkbox('Enable Zone Check', DroidLoot.LootUtils.zone_Check)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Return to start zone if we leave it?')
                                if gui.ZONECHECK ~= DroidLoot.LootUtils.zone_Check then
                                    gui.ZONECHECK = DroidLoot.LootUtils.zone_Check
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'zone_Check', DroidLoot.LootUtils.zone_Check)
                                end
                                ImGui.Separator();

                                ImGui.NextColumn();
                                ImGui.SetCursorPosY(start_y_Options)
                                DroidLoot.LootUtils.returnHomeAfterLoot = ImGui.Checkbox('Enable Return Home After Loot', DroidLoot.LootUtils.returnHomeAfterLoot)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Return to start X/Y/Z after looting?')
                                if gui.RETURNHOMEAFTERLOOT ~= DroidLoot.LootUtils.returnHomeAfterLoot then
                                    gui.RETURNHOMEAFTERLOOT = DroidLoot.LootUtils.returnHomeAfterLoot
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'returnHomeAfterLoot', DroidLoot.LootUtils.returnHomeAfterLoot)
                                end
                                ImGui.Separator();
                                ImGui.Columns(1)

                                DroidLoot.LootUtils.returnToCampDistance = ImGui.SliderInt("Return To Camp Distance", DroidLoot.LootUtils.returnToCampDistance, 1, 100000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The distance we can get before we trigger return to camp.')
                                if gui.RETURNTOCAMPDISTANCE ~= DroidLoot.LootUtils.returnToCampDistance then
                                    gui.RETURNTOCAMPDISTANCE = DroidLoot.LootUtils.returnToCampDistance
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'returnToCampDistance', DroidLoot.LootUtils.returnToCampDistance)
                                end
                                ImGui.Separator();
                                ImGui.EndTabItem();
                            end
                            local campSettingsOpen = ImGui.BeginTabItem("Camp Settings")
                            if campSettingsOpen then
                                DroidLoot.LootUtils.staticHunt = ImGui.Checkbox('Enable Static Hunt', DroidLoot.LootUtils.staticHunt)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Always use the same Hunting Zone.')
                                if gui.STATICHUNT ~= DroidLoot.LootUtils.staticHunt then
                                    gui.STATICHUNT = DroidLoot.LootUtils.staticHunt
                                    DroidLoot.CheckCampInfo()
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'staticHunt', DroidLoot.LootUtils.staticHunt)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.staticZoneName = ImGui.InputText('Zone Name', DroidLoot.LootUtils.staticZoneName)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The short name of the Static Hunt Zone.')
                                if gui.STATICZONENAME ~= DroidLoot.LootUtils.staticZoneName then
                                    gui.STATICZONENAME = DroidLoot.LootUtils.staticZoneName
                                    DroidLoot.CheckCampInfo()
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'staticZoneName', DroidLoot.LootUtils.staticZoneName)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.staticZoneID = ImGui.InputText('Zone ID', DroidLoot.LootUtils.staticZoneID)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The ID of the static Hunting Zone.')
                                if gui.STATICZONEID ~= DroidLoot.LootUtils.staticZoneID then
                                    gui.STATICZONEID = DroidLoot.LootUtils.staticZoneID
                                    DroidLoot.CheckCampInfo()
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'staticZoneID', DroidLoot.LootUtils.staticZoneID)
                                end
                                ImGui.Separator();

                                local start_y_Options = ImGui.GetCursorPosY()
                                ImGui.SetCursorPosY(start_y_Options + 3)
                                ImGui.Text('X')
                                ImGui.SameLine()
                                ImGui.SetNextItemWidth(120)
                                ImGui.SetCursorPosY(start_y_Options)
                                DroidLoot.LootUtils.staticX = ImGui.InputText('##Zone X', DroidLoot.LootUtils.staticX)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The X loc in the static Hunting Zone to camp.')
                                if gui.STATICX ~= DroidLoot.LootUtils.staticX then
                                    gui.STATICX = DroidLoot.LootUtils.staticX
                                    DroidLoot.CheckCampInfo()
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'staticX', DroidLoot.LootUtils.staticX)
                                end
                                ImGui.SameLine();

                                ImGui.SetCursorPosY(start_y_Options + 1)
                                ImGui.Text('Y')
                                ImGui.SameLine()
                                ImGui.SetNextItemWidth(120)
                                ImGui.SetCursorPosY(start_y_Options)
                                DroidLoot.LootUtils.staticY = ImGui.InputText('##Zone Y', DroidLoot.LootUtils.staticY)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The Y loc in the static Hunting Zone to camp.')
                                if gui.STATICY ~= DroidLoot.LootUtils.staticY then
                                    gui.STATICY = DroidLoot.LootUtils.staticY
                                    DroidLoot.CheckCampInfo()
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'staticY', DroidLoot.LootUtils.staticY)
                                end
                                ImGui.SameLine();

                                ImGui.SetCursorPosY(start_y_Options + 1)
                                ImGui.Text('Z')
                                ImGui.SameLine()
                                ImGui.SetNextItemWidth(120)
                                ImGui.SetCursorPosY(start_y_Options)
                                DroidLoot.LootUtils.staticZ = ImGui.InputText('##Zone Z', DroidLoot.LootUtils.staticZ)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The Z loc in the static Hunting Zone to camp.')
                                if gui.STATICZ ~= DroidLoot.LootUtils.staticZ then
                                    gui.STATICZ = DroidLoot.LootUtils.staticZ
                                    DroidLoot.CheckCampInfo()
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'staticZ', DroidLoot.LootUtils.staticZ)
                                end
                                ImGui.EndTabItem();
                            end
                            local wildcardOptionsOpen = ImGui.BeginTabItem("Wild Card Looting Options")
                            if wildcardOptionsOpen then
                                local settingsChanged = false -- Track if any settings changed

                                -- Checkbox for enabling wildcard looting
                                DroidLoot.LootUtils.LootWildCardItems = ImGui.Checkbox('Enable Wildcard Looting', DroidLoot.LootUtils.LootWildCardItems)
                                if gui.LOOTWILDCARDITEMS ~= DroidLoot.LootUtils.LootWildCardItems then
                                    gui.LOOTWILDCARDITEMS = DroidLoot.LootUtils.LootWildCardItems
                                    -- settingsChanged = true
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootWildCardItems', DroidLoot.LootUtils.LootWildCardItems)
                                end
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items matching wildcard names.')
                                ImGui.Separator()

                                -- Wildcard Terms Management
                                DroidLoot.LootUtils.wildCardTerms = DroidLoot.LootUtils.wildCardTerms or {}
                                if ImGui.CollapsingHeader("Wildcard Terms") then
                                    ImGui.Indent()
                                    local removeIndex = nil

                                    for i, term in ipairs(DroidLoot.LootUtils.wildCardTerms) do
                                        ImGui.PushID(i)
                                        local newTerm, termChanged = ImGui.InputText("##Term" .. i, term, 256)
                                        if termChanged then
                                            DroidLoot.LootUtils.wildCardTerms[i] = newTerm
                                            settingsChanged = true
                                        end
                                        ImGui.SameLine()
                                        if ImGui.Button("Delete") then
                                            removeIndex = i
                                        end
                                        ImGui.PopID()
                                    end

                                    if removeIndex then
                                        table.remove(DroidLoot.LootUtils.wildCardTerms, removeIndex)
                                        settingsChanged = true
                                    end

                                    ImGui.Separator()

                                    -- Add new term
                                    DroidLoot.LootUtils.newWildCardTerm = DroidLoot.LootUtils.newWildCardTerm or ""
                                    local newTermInput, changed
                                    newTermInput, changed = ImGui.InputText("New Term", DroidLoot.LootUtils.newWildCardTerm, 256)
                                    if changed then
                                        DroidLoot.LootUtils.newWildCardTerm = newTermInput
                                    end
                                    if ImGui.Button("Add Term") then
                                        if DroidLoot.LootUtils.newWildCardTerm ~= "" then
                                            table.insert(DroidLoot.LootUtils.wildCardTerms, DroidLoot.LootUtils.newWildCardTerm)
                                            DroidLoot.LootUtils.newWildCardTerm = ""
                                            settingsChanged = true
                                        end
                                    end

                                    ImGui.Unindent()
                                end

                                -- If any settings changed, write them once
                                if settingsChanged then
                                    DroidLoot.LootUtils.saveWildCardTerms()
                                end
                                ImGui.EndTabItem();
                            end
                            local booleanOptionsOpen = ImGui.BeginTabItem("Booleans")
                            if booleanOptionsOpen then
                                ImGui.Columns(2)
                                local start_y = ImGui.GetCursorPosY()
                                DroidLoot.LootUtils.UseWarp = ImGui.Checkbox('Enable Warp', DroidLoot.LootUtils.UseWarp)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Uses warp when enabled.')
                                if gui.USEWARP ~= DroidLoot.LootUtils.UseWarp then
                                    gui.USEWARP = DroidLoot.LootUtils.UseWarp
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'UseWarp', DroidLoot.LootUtils.UseWarp)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.UseWarpInstanceOnly = ImGui.Checkbox('Enable Warp Instance Only', DroidLoot.LootUtils.UseWarpInstanceOnly)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Uses warp in instances only when enabled.')
                                if gui.USEWARPINSTANCEONLY ~= DroidLoot.LootUtils.UseWarpInstanceOnly then
                                    gui.USEWARPINSTANCEONLY = DroidLoot.LootUtils.UseWarpInstanceOnly
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'UseWarpInstanceOnly', DroidLoot.LootUtils.UseWarpInstanceOnly)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.AddNewSales = ImGui.Checkbox('Enable New Sales', DroidLoot.LootUtils.AddNewSales)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Add new sales when enabled.')
                                if gui.ADDNEWSALES ~= DroidLoot.LootUtils.AddNewSales then
                                    gui.ADDNEWSALES = DroidLoot.LootUtils.AddNewSales
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'AddNewSales', DroidLoot.LootUtils.AddNewSales)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.AddIgnoredItems = ImGui.Checkbox('Enable Add Ignored Items', DroidLoot.LootUtils.AddIgnoredItems)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Add ignored items to ini when enabled.')
                                if gui.ADDIGNOREDITEMS ~= DroidLoot.LootUtils.AddIgnoredItems then
                                    gui.ADDIGNOREDITEMS = DroidLoot.LootUtils.AddIgnoredItems
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'AddIgnoredItems', DroidLoot.LootUtils.AddIgnoredItems)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootForage = ImGui.Checkbox('Enable Loot Forage', DroidLoot.LootUtils.LootForage)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loot forage when enabled.')
                                if gui.LOOTFORAGE ~= DroidLoot.LootUtils.LootForage then
                                    gui.LOOTFORAGE = DroidLoot.LootUtils.LootForage
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootForage', DroidLoot.LootUtils.LootForage)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootTradeSkill = ImGui.Checkbox('Enable Loot TradeSkill', DroidLoot.LootUtils.LootTradeSkill)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loot trade skill items when enabled.')
                                if gui.LOOTTRADESKILL ~= DroidLoot.LootUtils.LootTradeSkill then
                                    gui.LOOTTRADESKILL = DroidLoot.LootUtils.LootTradeSkill
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootTradeSkill', DroidLoot.LootUtils.LootTradeSkill)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.DoLoot = ImGui.Checkbox('Enable Looting', DroidLoot.LootUtils.DoLoot)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Enables looting.')
                                if gui.DOLOOT ~= DroidLoot.LootUtils.DoLoot then
                                    gui.DOLOOT = DroidLoot.LootUtils.DoLoot
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'DoLoot', DroidLoot.LootUtils.DoLoot)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.EquipUsable = ImGui.Checkbox('Enable Equip Usable', DroidLoot.LootUtils.EquipUsable)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Equips usable items. Buggy at best.')
                                if gui.EQUIPUSABLE ~= DroidLoot.LootUtils.EquipUsable then
                                    gui.EQUIPUSABLE = DroidLoot.LootUtils.EquipUsable
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'EquipUsable', DroidLoot.LootUtils.EquipUsable)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootEvolvingItems = ImGui.Checkbox('Enable Loot Evolving', DroidLoot.LootUtils.LootEvolvingItems)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots Evolving Items')
                                if gui.LOOTEVOLVINGITEMS ~= DroidLoot.LootUtils.LootEvolvingItems then
                                    gui.LOOTEVOLVINGITEMS = DroidLoot.LootUtils.LootEvolvingItems
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootEvolvingItems', DroidLoot.LootUtils.LootEvolvingItems)
                                end

                                ImGui.NextColumn();
                                ImGui.SetCursorPosY(start_y)
                                DroidLoot.LootUtils.AnnounceLoot = ImGui.Checkbox('Enable Announce Loot', DroidLoot.LootUtils.AnnounceLoot)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reports looted items to announce channel.')
                                if gui.ANNOUNCELOOT ~= DroidLoot.LootUtils.AnnounceLoot then
                                    gui.ANNOUNCELOOT = DroidLoot.LootUtils.AnnounceLoot
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'AnnounceLoot', DroidLoot.LootUtils.AnnounceLoot)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot to Console', DroidLoot.LootUtils.ReportLoot)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reports looted items to console.')
                                if gui.REPORTLOOT ~= DroidLoot.LootUtils.ReportLoot then
                                    gui.REPORTLOOT = DroidLoot.LootUtils.ReportLoot
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'ReportLoot', DroidLoot.LootUtils.ReportLoot)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.ReportSkipped = ImGui.Checkbox('Enable Report Skipped', DroidLoot.LootUtils.ReportSkipped)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reports skipped loots.')
                                if gui.REPORTSKIPPED ~= DroidLoot.LootUtils.ReportSkipped then
                                    gui.REPORTSKIPPED = DroidLoot.LootUtils.ReportSkipped
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'ReportSkipped', DroidLoot.LootUtils.ReportSkipped)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.AnnounceUpgrades = ImGui.Checkbox('Enable Report Upgrade', DroidLoot.LootUtils.AnnounceUpgrades)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reports skipped loots.')
                                if gui.ANNOUNCEUPGRADES ~= DroidLoot.LootUtils.AnnounceUpgrades then
                                    gui.ANNOUNCEUPGRADES = DroidLoot.LootUtils.AnnounceUpgrades
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'AnnounceUpgrades', DroidLoot.LootUtils.AnnounceUpgrades)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spam Loot Info', DroidLoot.LootUtils.SpamLootInfo)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Spams loot info.')
                                if gui.SPAMLOOTINFO ~= DroidLoot.LootUtils.SpamLootInfo then
                                    gui.SPAMLOOTINFO = DroidLoot.LootUtils.SpamLootInfo
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'SpamLootInfo', DroidLoot.LootUtils.SpamLootInfo)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootForageSpam = ImGui.Checkbox('Enable Loot Forage Spam', DroidLoot.LootUtils.LootForageSpam)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Spams loot forage info.')
                                if gui.LOOTFORAGESPAM ~= DroidLoot.LootUtils.LootForageSpam then
                                    gui.LOOTFORAGESPAM = DroidLoot.LootUtils.LootForageSpam
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootForageSpam', DroidLoot.LootUtils.LootForageSpam)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.CombatLooting = ImGui.Checkbox('Enable Combat Looting', DroidLoot.LootUtils.CombatLooting)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots during combat.')
                                if gui.COMBATLOOTING ~= DroidLoot.LootUtils.CombatLooting then
                                    gui.COMBATLOOTING = DroidLoot.LootUtils.CombatLooting
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'CombatLooting', DroidLoot.LootUtils.CombatLooting)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootGearUpgrades = ImGui.Checkbox('Enable Upgrade Looting', DroidLoot.LootUtils.LootGearUpgrades)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots items with more HP than currently worn items.')
                                if gui.LOOTGEARUPGRADES ~= DroidLoot.LootUtils.LootGearUpgrades then
                                    gui.LOOTGEARUPGRADES = DroidLoot.LootUtils.LootGearUpgrades
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootGearUpgrades', DroidLoot.LootUtils.LootGearUpgrades)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootByMinHPNoDrop = ImGui.Checkbox('Enable Loot MinHP No Drop', DroidLoot.LootUtils.LootByMinHPNoDrop)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loots No Drop items you can use when looting by MinHP.')
                                if gui.LOOTBYHPMINNODROP ~= DroidLoot.LootUtils.LootByMinHPNoDrop then
                                    gui.LOOTBYHPMINNODROP = DroidLoot.LootUtils.LootByMinHPNoDrop
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByMinHPNoDrop', DroidLoot.LootUtils.LootByMinHPNoDrop)
                                end
                                ImGui.Columns(1);
                                ImGui.Separator();

                                if ImGui.CollapsingHeader("Loot Actions") then
                                    ImGui.Indent();
                                    ImGui.Columns(2, 'second')
                                    start_y = ImGui.GetCursorPosY()

                                    DroidLoot.LootUtils.shouldLootActions['Announce'] = ImGui.Checkbox('Enable Announce Looting', DroidLoot.LootUtils.shouldLootActions['Announce'])
                                    if gui.LOOTACTIONANNOUNCE ~= DroidLoot.LootUtils.shouldLootActions['Announce'] then
                                        gui.LOOTACTIONANNOUNCE = DroidLoot.LootUtils.shouldLootActions['Announce']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Announce'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Announce items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Bank'] = ImGui.Checkbox('Enable Bank Looting', DroidLoot.LootUtils.shouldLootActions['Bank'])
                                    if gui.LOOTACTIONBANK ~= DroidLoot.LootUtils.shouldLootActions['Bank'] then
                                        gui.LOOTACTIONBANK = DroidLoot.LootUtils.shouldLootActions['Bank']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Bank'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Bank items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Cash'] = ImGui.Checkbox('Enable Cash Looting', DroidLoot.LootUtils.shouldLootActions['Cash'])
                                    if gui.LOOTACTIONCASH ~= DroidLoot.LootUtils.shouldLootActions['Cash'] then
                                        gui.LOOTACTIONCASH = DroidLoot.LootUtils.shouldLootActions['Cash']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Cash'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Cash items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Destroy'] = ImGui.Checkbox('Enable Destroy Looting', DroidLoot.LootUtils.shouldLootActions['Destroy'])
                                    if gui.LOOTACTIONDESTROY ~= DroidLoot.LootUtils.shouldLootActions['Destroy'] then
                                        gui.LOOTACTIONDESTROY = DroidLoot.LootUtils.shouldLootActions['Destroy']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Destroy'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Destroy items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Ignore'] = ImGui.Checkbox('Enable Ignore Looting', DroidLoot.LootUtils.shouldLootActions['Ignore'])
                                    if gui.LOOTACTIONIGNORE ~= DroidLoot.LootUtils.shouldLootActions['Ignore'] then
                                        gui.LOOTACTIONIGNORE = DroidLoot.LootUtils.shouldLootActions['Ignore']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Ignore'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Ignore items.')
                                    ImGui.Separator();

                                    ImGui.NextColumn();
                                    ImGui.SetCursorPosY(start_y);

                                    DroidLoot.LootUtils.shouldLootActions['Keep'] = ImGui.Checkbox('Enable Keep Looting', DroidLoot.LootUtils.shouldLootActions['Keep'])
                                    if gui.LOOTACTIONKEEP ~= DroidLoot.LootUtils.shouldLootActions['Keep'] then
                                        gui.LOOTACTIONKEEP = DroidLoot.LootUtils.shouldLootActions['Keep']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Keep'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Keep items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Quest'] = ImGui.Checkbox('Enable Quest Looting', DroidLoot.LootUtils.shouldLootActions['Quest'])
                                    if gui.LOOTACTIONQUEST ~= DroidLoot.LootUtils.shouldLootActions['Quest'] then
                                        gui.LOOTACTIONQUEST = DroidLoot.LootUtils.shouldLootActions['Quest']
                                        DroidLoot.LootUtils.saveSetting(LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Quest'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Quest items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Sell'] = ImGui.Checkbox('Enable Sell Looting', DroidLoot.LootUtils.shouldLootActions['Sell'])
                                    if gui.LOOTACTIONSELL ~= DroidLoot.LootUtils.shouldLootActions['Sell'] then
                                        gui.LOOTACTIONSELL = DroidLoot.LootUtils.shouldLootActions['Sell']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Sell'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Sell items.')
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.shouldLootActions['Wildcard'] = ImGui.Checkbox('Enable Wildcard Looting', DroidLoot.LootUtils.shouldLootActions['Wildcard'])
                                    if gui.LOOTACTIONWILDCARD ~= DroidLoot.LootUtils.shouldLootActions['Wildcard'] then
                                        gui.LOOTACTIONWILDCARD = DroidLoot.LootUtils.shouldLootActions['Wildcard']
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.LootFile, 'Settings', 'LootActions', DroidLoot.LootUtils.shouldLootActions['Wildcard'])
                                    end
                                    ImGui.SameLine();
                                    ImGui.HelpMarker('Loots Wildcard items.')

                                    ImGui.Columns(1);
                                    ImGui.Unindent();
                                end

                                ImGui.EndTabItem();
                            end
                            local stringsOptionsOpen = ImGui.BeginTabItem("Strings")
                            if stringsOptionsOpen then
                                DroidLoot.LootUtils.CorpseRadius = ImGui.SliderInt("Corpse Radius", DroidLoot.LootUtils.CorpseRadius, 1, 5000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The radius we should scan for corpses.')
                                if gui.CORPSERADIUS ~= DroidLoot.LootUtils.CorpseRadius then
                                    gui.CORPSERADIUS = DroidLoot.LootUtils.CorpseRadius
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'CorpseRadius', DroidLoot.LootUtils.CorpseRadius)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.MobsTooClose = ImGui.SliderInt("Mobs Too Close", DroidLoot.LootUtils.MobsTooClose, 1, 5000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The range to check for nearby mobs.')
                                if gui.MOBSTOOCLOSE ~= DroidLoot.LootUtils.MobsTooClose then
                                    gui.MOBSTOOCLOSE = DroidLoot.LootUtils.MobsTooClose
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'MobsTooClose', DroidLoot.LootUtils.MobsTooClose)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootByMinHP = ImGui.SliderInt("Loot By HP Min Health", DroidLoot.LootUtils.LootByMinHP, 0, 50000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Minimum HP for item to be considered and set to Keep. Any value greater than 0 activates this.')
                                if gui.LOOTBYHPMIN ~= DroidLoot.LootUtils.LootByMinHP then
                                    gui.LOOTBYHPMIN = DroidLoot.LootUtils.LootByMinHP
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootByMinHP', DroidLoot.LootUtils.LootByMinHP)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.StackPlatValue = ImGui.SliderInt("Stack Platinum Value", DroidLoot.LootUtils.StackPlatValue, 0, 10000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The value of platinum stacks.')
                                if gui.STACKPLATVALUE ~= DroidLoot.LootUtils.StackPlatValue then
                                    gui.STACKPLATVALUE = DroidLoot.LootUtils.StackPlatValue
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'StackPlatValue', DroidLoot.LootUtils.StackPlatValue)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.SaveBagSlots = ImGui.SliderInt("Save Bag Slots", DroidLoot.LootUtils.SaveBagSlots, 0, 100)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The number of bag slots to save.')
                                if gui.SAVEBAGSLOTS ~= DroidLoot.LootUtils.SaveBagSlots then
                                    gui.SAVEBAGSLOTS = DroidLoot.LootUtils.SaveBagSlots
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'SaveBagSlots', DroidLoot.LootUtils.SaveBagSlots)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.MinSellPrice = ImGui.SliderInt("Min Sell Price", DroidLoot.LootUtils.MinSellPrice, 1, 1000000000)
                                ImGui.SameLine()
                                ImGui.HelpMarker('The minimum price at which items will be sold.')
                                if gui.MINSELLPRICE ~= DroidLoot.LootUtils.MinSellPrice then
                                    gui.MINSELLPRICE = DroidLoot.LootUtils.MinSellPrice
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'MinSellPrice', DroidLoot.LootUtils.MinSellPrice)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.LootChannel = ImGui.InputText('Loot Channel', DroidLoot.LootUtils.LootChannel)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Channel to report loot to.')
                                if gui.LOOTCHANNEL ~= DroidLoot.LootUtils.LootChannel then
                                    gui.LOOTCHANNEL = DroidLoot.LootUtils.LootChannel
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootChannel', DroidLoot.LootUtils.LootChannel)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.AnnounceChannel = ImGui.InputText('Announce Channel', DroidLoot.LootUtils.AnnounceChannel)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Channel to announce events.')
                                if gui.ANNOUNCECHANNEL ~= DroidLoot.LootUtils.AnnounceChannel then
                                    gui.ANNOUNCECHANNEL = DroidLoot.LootUtils.AnnounceChannel
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'AnnounceChannel', DroidLoot.LootUtils.AnnounceChannel)
                                end
                                ImGui.Separator();
                                ImGui.EndTabItem();
                            end
                            local iniOptionsOpen = ImGui.BeginTabItem("INI")
                            if iniOptionsOpen then
                                DroidLoot.LootUtils.Settings.LootFile = ImGui.InputText('Loot file', DroidLoot.LootUtils.Settings.LootFile)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Loot file to use.')
                                if gui.LOOTINIFILE ~= DroidLoot.LootUtils.Settings.LootFile then
                                    gui.LOOTINIFILE = DroidLoot.LootUtils.Settings.LootFile
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootFile', DroidLoot.LootUtils.Settings.LootFile)
                                end
                                ImGui.Separator();

                                ImGui.Columns(2)
                                local start_y_INI = ImGui.GetCursorPosY()

                                DroidLoot.LootUtils.UseSingleFileForAllCharacters = ImGui.Checkbox('Enable Single INI', DroidLoot.LootUtils.UseSingleFileForAllCharacters)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reads from a single INI file for all characters when enabled.')
                                if gui.USESINGLEFILEFORALLCHARACTERS ~= DroidLoot.LootUtils.UseSingleFileForAllCharacters then
                                    gui.USESINGLEFILEFORALLCHARACTERS = DroidLoot.LootUtils.UseSingleFileForAllCharacters
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'UseSingleFileForAllCharacters', DroidLoot.LootUtils.UseSingleFileForAllCharacters)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.useZoneLootFile = ImGui.Checkbox('Enable Zone INI', DroidLoot.LootUtils.useZoneLootFile)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reads from a zone based INI file for all characters when enabled.')
                                if gui.USEZONELOOTFILE ~= DroidLoot.LootUtils.useZoneLootFile then
                                    gui.USEZONELOOTFILE = DroidLoot.LootUtils.useZoneLootFile
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'useZoneLootFile', DroidLoot.LootUtils.useZoneLootFile)
                                end
                                ImGui.Separator();

                                ImGui.NextColumn();
                                ImGui.SetCursorPosY(start_y_INI)
                                DroidLoot.LootUtils.useClassLootFile = ImGui.Checkbox('Enable Class INI', DroidLoot.LootUtils.useClassLootFile)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reads from a class based INI file for all characters when enabled.')
                                if gui.USECLASSLOOTFILE ~= DroidLoot.LootUtils.useClassLootFile then
                                    gui.USECLASSLOOTFILE = DroidLoot.LootUtils.useClassLootFile
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'useClassLootFile', DroidLoot.LootUtils.useClassLootFile)
                                end
                                ImGui.Separator();

                                DroidLoot.LootUtils.useArmorTypeLootFile = ImGui.Checkbox('Enable Armor Type INI', DroidLoot.LootUtils.useArmorTypeLootFile)
                                ImGui.SameLine()
                                ImGui.HelpMarker('Reads from an armor type based INI file for all characters when enabled.')
                                if gui.USEARMORTYPELOOTFILE ~= DroidLoot.LootUtils.useArmorTypeLootFile then
                                    gui.USEARMORTYPELOOTFILE = DroidLoot.LootUtils.useArmorTypeLootFile
                                    DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'useArmorTypeLootFile', DroidLoot.LootUtils.useArmorTypeLootFile)
                                end
                                ImGui.Columns(1)
                                if ImGui.Button('Save Config', buttonImVec2) then
                                    DroidLoot.LootUtils.writeSettings()
                                end
                                ImGui.EndTabItem();
                            end
                            local serverOptionsOpen = ImGui.BeginTabItem("Server Specific Options")
                            if serverOptionsOpen then
                                if ImGui.CollapsingHeader("WastingTime Options") then
                                    ImGui.Indent()
                                    DroidLoot.LootUtils.LootPlatinumBags = ImGui.Checkbox('Enable Loot Platinum Bags', DroidLoot.LootUtils.LootPlatinumBags)
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('Loots platinum bags.')
                                    if gui.LOOTPLATINUMBAGS ~= DroidLoot.LootUtils.LootPlatinumBags then
                                        gui.LOOTPLATINUMBAGS = DroidLoot.LootUtils.LootPlatinumBags
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootPlatinumBags', DroidLoot.LootUtils.LootPlatinumBags)
                                    end
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.LootTokensOfAdvancement = ImGui.Checkbox('Enable Loot Tokens of Advancement', DroidLoot.LootUtils.LootTokensOfAdvancement)
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('Loots tokens of advancement.')
                                    if gui.LOOTTOKENSOFADVANCEMENT ~= DroidLoot.LootUtils.LootTokensOfAdvancement then
                                        gui.LOOTTOKENSOFADVANCEMENT = DroidLoot.LootUtils.LootTokensOfAdvancement
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootTokensOfAdvancement', DroidLoot.LootUtils.LootTokensOfAdvancement)
                                    end
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.LootEmpoweredFabled = ImGui.Checkbox('Enable Loot Empowered Fabled', DroidLoot.LootUtils.LootEmpoweredFabled)
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('Loots empowered fabled items.')
                                    if gui.LOOTEMPOWEREDFABLED ~= DroidLoot.LootUtils.LootEmpoweredFabled then
                                        gui.LOOTEMPOWEREDFABLED = DroidLoot.LootUtils.LootEmpoweredFabled
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootEmpoweredFabled', DroidLoot.LootUtils.LootEmpoweredFabled)
                                    end
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.LootAllFabledAugs = ImGui.Checkbox('Enable Loot All Fabled Augments', DroidLoot.LootUtils.LootAllFabledAugs)
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('Loots all fabled augments.')
                                    if gui.LOOTALLFABLEDAUGS ~= DroidLoot.LootUtils.LootAllFabledAugs then
                                        gui.LOOTALLFABLEDAUGS = DroidLoot.LootUtils.LootAllFabledAugs
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'LootAllFabledAugs', DroidLoot.LootUtils.LootAllFabledAugs)
                                    end
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.EmpoweredFabledMinHP = ImGui.SliderInt("Empowered Fabled Min HP", DroidLoot.LootUtils.EmpoweredFabledMinHP, 0, 1000)
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                                    if gui.EMPOWEREDFABLEDMINHP ~= DroidLoot.LootUtils.EmpoweredFabledMinHP then
                                        gui.EMPOWEREDFABLEDMINHP = DroidLoot.LootUtils.EmpoweredFabledMinHP
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'EmpoweredFabledMinHP', DroidLoot.LootUtils.EmpoweredFabledMinHP)
                                    end
                                    ImGui.Separator();

                                    DroidLoot.LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name', DroidLoot.LootUtils.EmpoweredFabledName)
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('Name of the empowered fabled item.')
                                    if gui.EMPOWEREDFABLEDNAME ~= DroidLoot.LootUtils.EmpoweredFabledName then
                                        gui.EMPOWEREDFABLEDNAME = DroidLoot.LootUtils.EmpoweredFabledName
                                        DroidLoot.LootUtils.saveSetting(DroidLoot.LootUtils.Settings.LootFile, 'Settings', 'EmpoweredFabledName', DroidLoot.LootUtils.EmpoweredFabledName)
                                    end
                                    ImGui.Separator();
                                end
                                ImGui.EndTabItem();
                            end
                            ImGui.EndTabItem()
                        end
                        ImGui.EndTabBar()
                    end
                    local consoleOpen = ImGui.BeginTabItem("Console")
                    if consoleOpen then
                        local ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags.AlwaysVerticalScrollbar
                        if ImGui.BeginChild("ScrollingRegion", -1, 550, nil, ImGuiWindowFlags_AlwaysVerticalScrollbar) then
                            for _, line in ipairs(messages.outputLog) do
                                ImGui.Text(line)
                            end
                            ImGui.SetScrollHereY(1.0) -- Scroll to the bottom of the log
                        end
                        ImGui.EndChild()
                        ImGui.EndTabItem()
                    end

                    local changeLogOpen = ImGui.BeginTabItem("Change Log")
                    if changeLogOpen then
                        gui.ChangeLog()
                        ImGui.EndTabItem()
                    end

                    local updateOpen = ImGui.BeginTabItem("Update")
                    if updateOpen then
                        local buttonWidth3, buttonHeight3 = 160, 30

                        local availWidth, availHeight = ImGui.GetContentRegionAvail()

                        local text1 = "Visit GitHub for the latest version."
                        local textWidth, textHeight = ImGui.CalcTextSize(text1)
                        local cursorPosX = (availWidth - textWidth) / 2
                        if cursorPosX > 0 then ImGui.SetCursorPosX(cursorPosX) end
                        ImGui.Text(text1)

                        cursorPosX = (availWidth - buttonWidth3) / 2
                        if cursorPosX > 0 then ImGui.SetCursorPosX(cursorPosX) end
                        if ImGui.Button('Open Github', ImVec2(buttonWidth3, buttonHeight3)) then
                            os.execute('start https://github.com/TheDroidYourLookingFor/MacroQuest2-Scripts/tree/main/Lua/DroidLoot')
                        end
                        ImGui.SameLine()
                        ImGui.HelpMarker('Opens the Github page for this project.')

                        ImGui.Separator()

                        local text2 = "Download latest from GitHub."
                        local textWidth2, textHeight2 = ImGui.CalcTextSize(text2)
                        cursorPosX = (availWidth - textWidth2) / 2
                        if cursorPosX > 0 then ImGui.SetCursorPosX(cursorPosX) end
                        ImGui.Text(text2)

                        cursorPosX = (availWidth - buttonWidth3) / 2
                        if cursorPosX > 0 then ImGui.SetCursorPosX(cursorPosX) end
                        if ImGui.Button('Download DroidLoot', ImVec2(buttonWidth3, buttonHeight3)) then
                            os.execute('start https://github.com/TheDroidYourLookingFor/MacroQuest2-Scripts/raw/refs/heads/main/Lua/DroidLoot/DroidLoot.7z')
                        end
                        ImGui.SameLine()
                        ImGui.HelpMarker('Downloads the latest 7zip from github. You will need to extract it and update yourself.')

                        ImGui.EndTabItem()
                    end
                    ImGui.EndTabBar()
                end
            end
        end
        ImGui.End()
    else
        -- Position once only, no fixed size
        ImGui.SetNextWindowPos(ImVec2(100, 100), ImGuiCond.Once)

        -- Begin with auto resize flag, no title bar, no resize allowed
        local visible, open = ImGui.Begin("Minimized", true, ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.AlwaysAutoResize)

        if visible then
            local buttonWidth, buttonHeight = 20, 20
            local buttonImVec = ImVec2(buttonWidth, buttonHeight)
            if ImGui.Button('-', buttonImVec) then
                show_main = true
            end
            ImGui.SameLine()
            if ImGui.Button('X', buttonImVec) then
                DroidLoot.terminate = true
                mq.cmdf('/lua stop %s', 'DroidLoot')
            end
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(0, 0)) -- No padding inside button
            local buttonColor
            if DroidLoot.doPause then
                buttonColor = ImVec4(1, 0, 0, 1)
                if ImGui.ImageButton('Resume', dlFullImg:GetTextureID(), ImVec2(44, 44), ImVec2(0.0, 0.0), ImVec2(0.62, 0.62), ImVec4(0, 0, 0, 0), buttonColor) then
                    DroidLoot.doPause = false
                end
            else
                buttonColor = ImVec4(0, 1, 0, 1)
                if ImGui.ImageButton('Pause', dlFullImg:GetTextureID(), ImVec2(44, 44), ImVec2(0.0, 0.0), ImVec2(0.62, 0.62), ImVec4(0, 0, 0, 0), buttonColor) then
                    DroidLoot.doPause = true
                end
            end
            ImGui.PopStyleVar()
        end

        ImGui.End()
    end
end

-- Helper functions
function getActionIndex(action)
    for i, a in ipairs(itemActions) do
        if a == action then return i - 1 end
    end
    return 0 -- default to first
end

function tablelength(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function gui.initGUI()
    mq.imgui.init('DroidLoot', gui.DroidLootGUI)
    gui.Open = true
end

return gui
