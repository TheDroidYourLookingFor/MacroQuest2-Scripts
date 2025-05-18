---@type Mq
local mq = require('mq')
local gui = {}

gui.version = '1.0.0'
gui.versionOrder = { "1.0.0" }
gui.change_Log = {
    ['1.0.0'] = { 'Initial Release',
        '- Added GUI for loot options'
    },
}

function gui.ChangeLog()
    ImGui.Text("Change Log:")
    local logText = ""
    -- Iterate over the versionOrder table
    for _, version in ipairs(gui.versionOrder) do
        local changes = gui.change_Log[version]
        if changes then
            logText = logText .. "[" .. version .. "]\n"

            -- Get the update title from the first element
            local updateTitle = changes[1]
            logText = logText .. updateTitle .. "\n"

            -- Concatenate the updates for each version
            for i = 2, #changes do
                local change = changes[i]
                logText = logText .. change .. "\n"
            end

            logText = logText .. "\n"
        end
    end

    -- Create an ImGui textbox and display the parsed change log
    ImGui.InputTextMultiline("##changeLog", logText, ImGui.GetWindowSize(), 300, ImGuiInputTextFlags.ReadOnly)
end

gui.outputLog = {}
-- Function to add output to the log with a timestamp
function gui.addToConsole(text, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")

    -- Handle item links correctly by passing through string.format
    local formattedText = string.format(text, ...)

    -- Add the timestamp to the message
    local logEntry = string.format("%s %s", timestamp, formattedText)

    -- Add the combined message with timestamp to the log
    table.insert(gui.outputLog, logEntry)
end

gui.DEBUG = false
gui.RETURNTOHOME = false
gui.DOSELL = false
gui.DOLOOT = false
gui.CORPSEFIX = false

gui.MOBSTOOCLOSE = 40
gui.CORPSERADIUS = 100
gui.ADDNEWSALES = false
gui.LOOTFORAGE = false
gui.REPORTLOOT = false
gui.LOOTCHANNEL = 'dgt'
gui.SPAMLOOTINFO = false
gui.GLOBALLOOTON = true
gui.COMBATLOOTING = true
gui.MINSELLPRICE = -1
gui.STACKABLEONLY = false
gui.STACKPLATVALUE = 0
gui.CORPSEROTTIME = '440s'

gui.CurrentStatus = ' '
gui.Open = false
gui.ShowUI = false

local openSections = {}
local iniData = {}
local itemActions = { "Keep", "Ignore", "Announce", "Destroy", "Sell", "Fabled", "Cash" }
local comboIndexCache = {}

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

iniData = LoadINI(EZLoot.LootUtils.Settings.LootFile)

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
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', EZLoot.LootUtils.Settings.LootFile, section, itemName, action)
end

gui.ACTION = ''
local newItemName
local newItemAction
local current_idx
function gui.EZLootGUI()
    if gui.Open then
        gui.Open, gui.ShowUI = ImGui.Begin('TheDroid EZ Loot Bot v' .. gui.version, gui.Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        if gui.ShowUI then
            local buttonWidth, buttonHeight = 120, 30
            local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
            if EZLoot.doPause then
                if ImGui.Button('Resume', buttonImVec2) then
                    EZLoot.doPause = false
                end
            else
                if ImGui.Button('Pause', buttonImVec2) then
                    EZLoot.doPause = true
                end
            end
            ImGui.SameLine(185)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Bank', buttonImVec2) then
                EZLoot.needToBank = true
            end
            ImGui.SameLine(315)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Plat Sell', buttonImVec2) then
                EZLoot.needToVendorSell = true
            end
            ImGui.SameLine(485)
            ImGui.Spacing()
            ImGui.SameLine()
            ImGui.SameLine()
            if ImGui.Button('Quit EZLoot', buttonImVec2) then
                EZLoot.terminate = true
            end
            ImGui.Spacing()

            if ImGui.CollapsingHeader("EZ Loot Bot") then
                ImGui.Indent()
                ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                    "It will loot anything set in the EZLoot.ini,\n")
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText('/' .. EZLoot.command_ShortName .. ' bank');
                ImGui.BulletText('/' .. EZLoot.command_ShortName .. ' cash');
                ImGui.BulletText('/' .. EZLoot.command_ShortName .. ' fabled');
                ImGui.BulletText('/' .. EZLoot.command_ShortName .. ' quit');
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
                ImGui.Unindent()
            end

            if ImGui.CollapsingHeader('Loot List') then
                newItemName = newItemName or ""
                newItemAction = newItemAction or ""
                current_idx = current_idx or 1
                ImGui.Indent()

                if ImGui.CollapsingHeader('Add New Item') then
                    -- Input: Name
                    newItemName = ImGui.InputText("Item Name", newItemName)

                    -- Combo Box for Action
                    if ImGui.BeginCombo("Action", itemActions[current_idx]) then
                        for n = 1, #itemActions do
                            local is_selected = (current_idx == n)
                            if ImGui.Selectable(itemActions[n], is_selected) then
                                current_idx = n
                                newItemAction = itemActions[n]     -- Set newItemAction
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
                    if section ~= "Settings" then
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
                                actionBuffers[key] = actionBuffers[key] or action or ""

                                local newText, changed = ImGui.InputText("##" .. key, actionBuffers[key])
                                if changed then
                                    actionBuffers[key] = newText
                                    iniData[section][itemName] = newText
                                    mq.cmdf('/ini "%s" "%s" "%s" "%s"',
                                        EZLoot.LootUtils.Settings.LootFile, section, itemName, newText)
                                end
                                ImGui.NextColumn()
                            end
                            ImGui.Columns(1)
                        end
                    end
                end

                ImGui.Unindent()
            end
            if ImGui.CollapsingHeader('EZLoot Options') then
                ImGui.Indent()
                if ImGui.CollapsingHeader("Hub Operations") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    EZLoot.LootUtils.bankDeposit = ImGui.Checkbox('Enable Bank Deposit', EZLoot.LootUtils.bankDeposit)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                    if gui.BANKDEPOSIT ~= EZLoot.LootUtils.bankDeposit then
                        gui.BANKDEPOSIT = EZLoot.LootUtils.bankDeposit
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.NextColumn();

                    EZLoot.LootUtils.sellVendor = ImGui.Checkbox('Enable Vendor Selling',
                        EZLoot.LootUtils.sellVendor)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items for Platinum when enabled.')
                    if gui.SELLVENDOR ~= EZLoot.LootUtils.sellVendor then
                        gui.SELLVENDOR = EZLoot.LootUtils.sellVendor
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Columns(1)

                    EZLoot.LootUtils.bankZone = ImGui.InputInt('Bank Zone', EZLoot.LootUtils.bankZone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Zone where we can access banking services.')
                    if gui.BANKZONE ~= EZLoot.LootUtils.bankZone then
                        gui.BANKZONE = EZLoot.LootUtils.bankZone
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.bankNPC = ImGui.InputText('Bank NPC', EZLoot.LootUtils.bankNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for banking.')
                    if gui.BANKNPC ~= EZLoot.LootUtils.bankNPC then
                        gui.BANKNPC = EZLoot.LootUtils.bankNPC
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.vendorNPC = ImGui.InputText('Vendor NPC', EZLoot.LootUtils.vendorNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for vendoring.')
                    if gui.VENDORNPC ~= EZLoot.LootUtils.vendorNPC then
                        gui.VENDORNPC = EZLoot.LootUtils.vendorNPC
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.bankAtFreeSlots = ImGui.SliderInt("Inventory Free Slots",
                        EZLoot.LootUtils.bankAtFreeSlots, 1, 20)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of free slots before we should bank.')
                    if gui.BANKATFREESLOTS ~= EZLoot.LootUtils.bankAtFreeSlots then
                        gui.BANKATFREESLOTS = EZLoot.LootUtils.bankAtFreeSlots
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("WastingTime Options") then
                    ImGui.Indent()
                    EZLoot.LootUtils.LootPlatinumBags = ImGui.Checkbox('Enable Loot Platinum Bags',
                        EZLoot.LootUtils.LootPlatinumBags)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots platinum bags.')
                    if gui.LOOTPLATINUMBAGS ~= EZLoot.LootUtils.LootPlatinumBags then
                        gui.LOOTPLATINUMBAGS = EZLoot.LootUtils.LootPlatinumBags
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.LootTokensOfAdvancement = ImGui.Checkbox('Enable Loot Tokens of Advancement',
                        EZLoot.LootUtils.LootTokensOfAdvancement)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots tokens of advancement.')
                    if gui.LOOTTOKENSOFADVANCEMENT ~= EZLoot.LootUtils.LootTokensOfAdvancement then
                        gui.LOOTTOKENSOFADVANCEMENT = EZLoot.LootUtils.LootTokensOfAdvancement
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.LootEmpoweredFabled = ImGui.Checkbox('Enable Loot Empowered Fabled',
                        EZLoot.LootUtils.LootEmpoweredFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots empowered fabled items.')
                    if gui.LOOTEMPOWEREDFABLED ~= EZLoot.LootUtils.LootEmpoweredFabled then
                        gui.LOOTEMPOWEREDFABLED = EZLoot.LootUtils.LootEmpoweredFabled
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.LootAllFabledAugs = ImGui.Checkbox('Enable Loot All Fabled Augments',
                        EZLoot.LootUtils.LootAllFabledAugs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots all fabled augments.')
                    if gui.LOOTALLFABLEDAUGS ~= EZLoot.LootUtils.LootAllFabledAugs then
                        gui.LOOTALLFABLEDAUGS = EZLoot.LootUtils.LootAllFabledAugs
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.EmpoweredFabledMinHP = ImGui.SliderInt("Empowered Fabled Min HP",
                        EZLoot.LootUtils.EmpoweredFabledMinHP, 0, 1000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                    if gui.EMPOWEREDFABLEDMINHP ~= EZLoot.LootUtils.EmpoweredFabledMinHP then
                        gui.EMPOWEREDFABLEDMINHP = EZLoot.LootUtils.EmpoweredFabledMinHP
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    EZLoot.LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name',
                        EZLoot.LootUtils.EmpoweredFabledName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Name of the empowered fabled item.')
                    if gui.EMPOWEREDFABLEDNAME ~= EZLoot.LootUtils.EmpoweredFabledName then
                        gui.EMPOWEREDFABLEDNAME = EZLoot.LootUtils.EmpoweredFabledName
                        EZLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                ImGui.Columns(2)
                local start_y = ImGui.GetCursorPosY()
                EZLoot.LootUtils.UseWarp = ImGui.Checkbox('Enable Warp', EZLoot.LootUtils.UseWarp)
                ImGui.SameLine()
                ImGui.HelpMarker('Uses warp when enabled.')
                if gui.USEWARP ~= EZLoot.LootUtils.UseWarp then
                    gui.USEWARP = EZLoot.LootUtils.UseWarp
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.AddNewSales = ImGui.Checkbox('Enable New Sales', EZLoot.LootUtils.AddNewSales)
                ImGui.SameLine()
                ImGui.HelpMarker('Add new sales when enabled.')
                if gui.ADDNEWSALES ~= EZLoot.LootUtils.AddNewSales then
                    gui.ADDNEWSALES = EZLoot.LootUtils.AddNewSales
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.LootForage = ImGui.Checkbox('Enable Loot Forage', EZLoot.LootUtils.LootForage)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot forage when enabled.')
                if gui.LOOTFORAGE ~= EZLoot.LootUtils.LootForage then
                    gui.LOOTFORAGE = EZLoot.LootUtils.LootForage
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.LootTradeSkill = ImGui.Checkbox('Enable Loot TradeSkill',
                    EZLoot.LootUtils.LootTradeSkill)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot trade skill items when enabled.')
                if gui.LOOTTRADESKILL ~= EZLoot.LootUtils.LootTradeSkill then
                    gui.LOOTTRADESKILL = EZLoot.LootUtils.LootTradeSkill
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.DoLoot = ImGui.Checkbox('Enable Looting', EZLoot.LootUtils.DoLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables looting.')
                if gui.DOLOOT ~= EZLoot.LootUtils.DoLoot then
                    gui.DOLOOT = EZLoot.LootUtils.DoLoot
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.EquipUsable = ImGui.Checkbox('Enable Equip Usable',
                    EZLoot.LootUtils.EquipUsable)
                ImGui.SameLine()
                ImGui.HelpMarker('Equips usable items. Buggy at best.')
                if gui.EQUIPUSABLE ~= EZLoot.LootUtils.EquipUsable then
                    gui.EQUIPUSABLE = EZLoot.LootUtils.EquipUsable
                    EZLoot.LootUtils.writeSettings()
                end

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y)
                EZLoot.LootUtils.AnnounceLoot = ImGui.Checkbox('Enable Announce Loot',
                    EZLoot.LootUtils.AnnounceLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to announce channel.')
                if gui.ANNOUNCELOOT ~= EZLoot.LootUtils.AnnounceLoot then
                    gui.ANNOUNCELOOT = EZLoot.LootUtils.AnnounceLoot
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot', EZLoot.LootUtils.ReportLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to console.')
                if gui.REPORTLOOT ~= EZLoot.LootUtils.ReportLoot then
                    gui.REPORTLOOT = EZLoot.LootUtils.ReportLoot
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.ReportSkipped = ImGui.Checkbox('Enable Report Skipped',
                    EZLoot.LootUtils.ReportSkipped)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports skipped loots.')
                if gui.REPORTSKIPPED ~= EZLoot.LootUtils.ReportSkipped then
                    gui.REPORTSKIPPED = EZLoot.LootUtils.ReportSkipped
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spam Loot Info',
                    EZLoot.LootUtils.SpamLootInfo)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot info.')
                if gui.SPAMLOOTINFO ~= EZLoot.LootUtils.SpamLootInfo then
                    gui.SPAMLOOTINFO = EZLoot.LootUtils.SpamLootInfo
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.LootForageSpam = ImGui.Checkbox('Enable Loot Forage Spam',
                    EZLoot.LootUtils.LootForageSpam)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot forage info.')
                if gui.LOOTFORAGESPAM ~= EZLoot.LootUtils.LootForageSpam then
                    gui.LOOTFORAGESPAM = EZLoot.LootUtils.LootForageSpam
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.CombatLooting = ImGui.Checkbox('Enable Combat Looting',
                    EZLoot.LootUtils.CombatLooting)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots during combat.')
                if gui.COMBATLOOTING ~= EZLoot.LootUtils.CombatLooting then
                    gui.COMBATLOOTING = EZLoot.LootUtils.CombatLooting
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Columns(1)

                EZLoot.LootUtils.CorpseRadius = ImGui.SliderInt("Corpse Radius", EZLoot.LootUtils.CorpseRadius,
                    1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should scan for corpses.')
                if gui.CORPSERADIUS ~= EZLoot.LootUtils.CorpseRadius then
                    gui.CORPSERADIUS = EZLoot.LootUtils.CorpseRadius
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.MobsTooClose = ImGui.SliderInt("Mobs Too Close", EZLoot.LootUtils
                    .MobsTooClose, 1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The range to check for nearby mobs.')
                if gui.MOBSTOOCLOSE ~= EZLoot.LootUtils.MobsTooClose then
                    gui.MOBSTOOCLOSE = EZLoot.LootUtils.MobsTooClose
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.StackPlatValue = ImGui.SliderInt("Stack Platinum Value",
                    EZLoot.LootUtils.StackPlatValue, 0, 10000)
                ImGui.SameLine()
                ImGui.HelpMarker('The value of platinum stacks.')
                if gui.STACKPLATVALUE ~= EZLoot.LootUtils.StackPlatValue then
                    gui.STACKPLATVALUE = EZLoot.LootUtils.StackPlatValue
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.SaveBagSlots = ImGui.SliderInt("Save Bag Slots", EZLoot.LootUtils
                    .SaveBagSlots, 0, 100)
                ImGui.SameLine()
                ImGui.HelpMarker('The number of bag slots to save.')
                if gui.SAVEBAGSLOTS ~= EZLoot.LootUtils.SaveBagSlots then
                    gui.SAVEBAGSLOTS = EZLoot.LootUtils.SaveBagSlots
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.MinSellPrice = ImGui.SliderInt("Min Sell Price", EZLoot.LootUtils
                    .MinSellPrice, 1, 100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum price at which items will be sold.')
                if gui.MINSELLPRICE ~= EZLoot.LootUtils.MinSellPrice then
                    gui.MINSELLPRICE = EZLoot.LootUtils.MinSellPrice
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.LootChannel = ImGui.InputText('Loot Channel', EZLoot.LootUtils.LootChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to report loot to.')
                if gui.LOOTCHANNEL ~= EZLoot.LootUtils.LootChannel then
                    gui.LOOTCHANNEL = EZLoot.LootUtils.LootChannel
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.AnnounceChannel = ImGui.InputText('Announce Channel',
                    EZLoot.LootUtils.AnnounceChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to announce events.')
                if gui.ANNOUNCECHANNEL ~= EZLoot.LootUtils.AnnounceChannel then
                    gui.ANNOUNCECHANNEL = EZLoot.LootUtils.AnnounceChannel
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                EZLoot.LootUtils.Settings.LootFile = ImGui.InputText('Loot file', EZLoot.LootUtils.Settings.LootFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot file to use.')
                if gui.LOOTINIFILE ~= EZLoot.LootUtils.Settings.LootFile then
                    gui.LOOTINIFILE = EZLoot.LootUtils.Settings.LootFile
                    EZLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();
                ImGui.Unindent();
            end
            if ImGui.CollapsingHeader("Console") then
                ImGui.Indent()
                local ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags.AlwaysVerticalScrollbar
                if ImGui.BeginChild("ScrollingRegion", -1, 550, nil, ImGuiWindowFlags_AlwaysVerticalScrollbar) then
                    for _, line in ipairs(gui.outputLog) do
                        ImGui.Text(line)
                    end
                    ImGui.SetScrollHereY(1.0) -- Scroll to the bottom of the log
                end
                ImGui.EndChild()
                ImGui.Unindent()
            end
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
    mq.imgui.init('EZLoot', gui.EZLootGUI)
    gui.Open = true
end

return gui
