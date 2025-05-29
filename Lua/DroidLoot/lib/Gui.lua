---@type Mq
local mq = require('mq')
local gui = {}

gui.version = '1.0.2'
gui.versionOrder = { "1.0.0", "1.0.1", "1.0.2" }
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
gui.LOOTEVOLVINGITEMS = true
gui.MOBSTOOCLOSE = 40
gui.CORPSERADIUS = 100
gui.ADDNEWSALES = false
gui.ADDIGNOREDITEMS = false
gui.USECLASSLOOTFILE = false
gui.USEARMORTYPELOOTFILE = false
gui.USEMACROLOOTFILE = false
gui.USEZONELOOTFILE = false
gui.USESINGLEFILEFORALLCHARACTERS = true
gui.LOOTFORAGE = false
gui.REPORTLOOT = false
gui.LOOTCHANNEL = 'dgt'
gui.SPAMLOOTINFO = false
gui.GLOBALLOOTON = true
gui.COMBATLOOTING = true
gui.LOOTGEARUPGRADES = false
gui.LOOTWILDCARDITEMS = false
gui.MINSELLPRICE = -1
gui.STACKABLEONLY = false
gui.LOOTBYHPMIN = 0
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
function gui.DroidLootGUI()
    if gui.Open then
        gui.Open, gui.ShowUI = ImGui.Begin('TheDroid Droid Loot Bot v' .. gui.version, gui.Open)
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
            if DroidLoot.doPause then
                if ImGui.Button('Resume', buttonImVec2) then
                    DroidLoot.doPause = false
                end
            else
                if ImGui.Button('Pause', buttonImVec2) then
                    DroidLoot.doPause = true
                end
            end
            ImGui.SameLine(185)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Bank', buttonImVec2) then
                DroidLoot.needToBank = true
            end
            ImGui.SameLine(315)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Plat Sell', buttonImVec2) then
                DroidLoot.needToVendorSell = true
            end
            ImGui.SameLine(485)
            ImGui.Spacing()
            ImGui.SameLine()
            ImGui.SameLine()
            if ImGui.Button('Quit DroidLoot', buttonImVec2) then
                DroidLoot.terminate = true
            end
            ImGui.Spacing()

            if ImGui.CollapsingHeader("Droid Loot Bot") then
                ImGui.Indent()
                ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                    "It will loot anything set in the DroidLoot.ini,\n")
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' bank');
                ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' cash');
                ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' fabled');
                ImGui.BulletText('/' .. DroidLoot.command_ShortName .. ' quit');
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
                ImGui.Separator();
                if ImGui.CollapsingHeader("Change Log") then
                    gui.ChangeLog()
                end
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
                                        DroidLoot.LootUtils.Settings.LootFile, section, itemName, newText)
                                end
                                ImGui.NextColumn()
                            end
                            ImGui.Columns(1)
                        end
                    end
                end

                ImGui.Unindent()
            end
            if ImGui.CollapsingHeader('DroidLoot Options') then
                ImGui.Indent()
                if ImGui.CollapsingHeader("Hub Operations") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    DroidLoot.LootUtils.bankDeposit = ImGui.Checkbox('Enable Bank Deposit', DroidLoot.LootUtils.bankDeposit)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                    if gui.BANKDEPOSIT ~= DroidLoot.LootUtils.bankDeposit then
                        gui.BANKDEPOSIT = DroidLoot.LootUtils.bankDeposit
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.NextColumn();

                    DroidLoot.LootUtils.sellVendor = ImGui.Checkbox('Enable Vendor Selling',
                        DroidLoot.LootUtils.sellVendor)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items for Platinum when enabled.')
                    if gui.SELLVENDOR ~= DroidLoot.LootUtils.sellVendor then
                        gui.SELLVENDOR = DroidLoot.LootUtils.sellVendor
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Columns(1)

                    DroidLoot.LootUtils.bankZone = ImGui.InputInt('Bank Zone', DroidLoot.LootUtils.bankZone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Zone where we can access banking services.')
                    if gui.BANKZONE ~= DroidLoot.LootUtils.bankZone then
                        gui.BANKZONE = DroidLoot.LootUtils.bankZone
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.bankNPC = ImGui.InputText('Bank NPC', DroidLoot.LootUtils.bankNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for banking.')
                    if gui.BANKNPC ~= DroidLoot.LootUtils.bankNPC then
                        gui.BANKNPC = DroidLoot.LootUtils.bankNPC
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.vendorNPC = ImGui.InputText('Vendor NPC', DroidLoot.LootUtils.vendorNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for vendoring.')
                    if gui.VENDORNPC ~= DroidLoot.LootUtils.vendorNPC then
                        gui.VENDORNPC = DroidLoot.LootUtils.vendorNPC
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.bankAtFreeSlots = ImGui.SliderInt("Inventory Free Slots",
                        DroidLoot.LootUtils.bankAtFreeSlots, 1, 20)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of free slots before we should bank.')
                    if gui.BANKATFREESLOTS ~= DroidLoot.LootUtils.bankAtFreeSlots then
                        gui.BANKATFREESLOTS = DroidLoot.LootUtils.bankAtFreeSlots
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("WastingTime Options") then
                    ImGui.Indent()
                    DroidLoot.LootUtils.LootPlatinumBags = ImGui.Checkbox('Enable Loot Platinum Bags',
                        DroidLoot.LootUtils.LootPlatinumBags)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots platinum bags.')
                    if gui.LOOTPLATINUMBAGS ~= DroidLoot.LootUtils.LootPlatinumBags then
                        gui.LOOTPLATINUMBAGS = DroidLoot.LootUtils.LootPlatinumBags
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.LootTokensOfAdvancement = ImGui.Checkbox('Enable Loot Tokens of Advancement',
                        DroidLoot.LootUtils.LootTokensOfAdvancement)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots tokens of advancement.')
                    if gui.LOOTTOKENSOFADVANCEMENT ~= DroidLoot.LootUtils.LootTokensOfAdvancement then
                        gui.LOOTTOKENSOFADVANCEMENT = DroidLoot.LootUtils.LootTokensOfAdvancement
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.LootEmpoweredFabled = ImGui.Checkbox('Enable Loot Empowered Fabled',
                        DroidLoot.LootUtils.LootEmpoweredFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots empowered fabled items.')
                    if gui.LOOTEMPOWEREDFABLED ~= DroidLoot.LootUtils.LootEmpoweredFabled then
                        gui.LOOTEMPOWEREDFABLED = DroidLoot.LootUtils.LootEmpoweredFabled
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.LootAllFabledAugs = ImGui.Checkbox('Enable Loot All Fabled Augments',
                        DroidLoot.LootUtils.LootAllFabledAugs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots all fabled augments.')
                    if gui.LOOTALLFABLEDAUGS ~= DroidLoot.LootUtils.LootAllFabledAugs then
                        gui.LOOTALLFABLEDAUGS = DroidLoot.LootUtils.LootAllFabledAugs
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.EmpoweredFabledMinHP = ImGui.SliderInt("Empowered Fabled Min HP",
                        DroidLoot.LootUtils.EmpoweredFabledMinHP, 0, 1000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                    if gui.EMPOWEREDFABLEDMINHP ~= DroidLoot.LootUtils.EmpoweredFabledMinHP then
                        gui.EMPOWEREDFABLEDMINHP = DroidLoot.LootUtils.EmpoweredFabledMinHP
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name',
                        DroidLoot.LootUtils.EmpoweredFabledName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Name of the empowered fabled item.')
                    if gui.EMPOWEREDFABLEDNAME ~= DroidLoot.LootUtils.EmpoweredFabledName then
                        gui.EMPOWEREDFABLEDNAME = DroidLoot.LootUtils.EmpoweredFabledName
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                ImGui.Columns(2)
                local start_y = ImGui.GetCursorPosY()
                DroidLoot.LootUtils.UseWarp = ImGui.Checkbox('Enable Warp', DroidLoot.LootUtils.UseWarp)
                ImGui.SameLine()
                ImGui.HelpMarker('Uses warp when enabled.')
                if gui.USEWARP ~= DroidLoot.LootUtils.UseWarp then
                    gui.USEWARP = DroidLoot.LootUtils.UseWarp
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.AddNewSales = ImGui.Checkbox('Enable New Sales', DroidLoot.LootUtils.AddNewSales)
                ImGui.SameLine()
                ImGui.HelpMarker('Add new sales when enabled.')
                if gui.ADDNEWSALES ~= DroidLoot.LootUtils.AddNewSales then
                    gui.ADDNEWSALES = DroidLoot.LootUtils.AddNewSales
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.AddIgnoredItems = ImGui.Checkbox('Enable Add Ignored Items', DroidLoot.LootUtils.AddIgnoredItems)
                ImGui.SameLine()
                ImGui.HelpMarker('Add ignored items to ini when enabled.')
                if gui.ADDIGNOREDITEMS ~= DroidLoot.LootUtils.AddIgnoredItems then
                    gui.ADDIGNOREDITEMS = DroidLoot.LootUtils.AddIgnoredItems
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootForage = ImGui.Checkbox('Enable Loot Forage', DroidLoot.LootUtils.LootForage)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot forage when enabled.')
                if gui.LOOTFORAGE ~= DroidLoot.LootUtils.LootForage then
                    gui.LOOTFORAGE = DroidLoot.LootUtils.LootForage
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootTradeSkill = ImGui.Checkbox('Enable Loot TradeSkill', DroidLoot.LootUtils.LootTradeSkill)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot trade skill items when enabled.')
                if gui.LOOTTRADESKILL ~= DroidLoot.LootUtils.LootTradeSkill then
                    gui.LOOTTRADESKILL = DroidLoot.LootUtils.LootTradeSkill
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.DoLoot = ImGui.Checkbox('Enable Looting', DroidLoot.LootUtils.DoLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables looting.')
                if gui.DOLOOT ~= DroidLoot.LootUtils.DoLoot then
                    gui.DOLOOT = DroidLoot.LootUtils.DoLoot
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.EquipUsable = ImGui.Checkbox('Enable Equip Usable', DroidLoot.LootUtils.EquipUsable)
                ImGui.SameLine()
                ImGui.HelpMarker('Equips usable items. Buggy at best.')
                if gui.EQUIPUSABLE ~= DroidLoot.LootUtils.EquipUsable then
                    gui.EQUIPUSABLE = DroidLoot.LootUtils.EquipUsable
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootEvolvingItems = ImGui.Checkbox('Enable Loot Evolving', DroidLoot.LootUtils.LootEvolvingItems)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots Evolving Items')
                if gui.LOOTEVOLVINGITEMS ~= DroidLoot.LootUtils.LootEvolvingItems then
                    gui.LOOTEVOLVINGITEMS = DroidLoot.LootUtils.LootEvolvingItems
                    DroidLoot.LootUtils.writeSettings()
                end

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y)
                DroidLoot.LootUtils.AnnounceLoot = ImGui.Checkbox('Enable Announce Loot', DroidLoot.LootUtils.AnnounceLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to announce channel.')
                if gui.ANNOUNCELOOT ~= DroidLoot.LootUtils.AnnounceLoot then
                    gui.ANNOUNCELOOT = DroidLoot.LootUtils.AnnounceLoot
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot', DroidLoot.LootUtils.ReportLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to console.')
                if gui.REPORTLOOT ~= DroidLoot.LootUtils.ReportLoot then
                    gui.REPORTLOOT = DroidLoot.LootUtils.ReportLoot
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.ReportSkipped = ImGui.Checkbox('Enable Report Skipped', DroidLoot.LootUtils.ReportSkipped)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports skipped loots.')
                if gui.REPORTSKIPPED ~= DroidLoot.LootUtils.ReportSkipped then
                    gui.REPORTSKIPPED = DroidLoot.LootUtils.ReportSkipped
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spam Loot Info', DroidLoot.LootUtils.SpamLootInfo)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot info.')
                if gui.SPAMLOOTINFO ~= DroidLoot.LootUtils.SpamLootInfo then
                    gui.SPAMLOOTINFO = DroidLoot.LootUtils.SpamLootInfo
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootForageSpam = ImGui.Checkbox('Enable Loot Forage Spam',
                    DroidLoot.LootUtils.LootForageSpam)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot forage info.')
                if gui.LOOTFORAGESPAM ~= DroidLoot.LootUtils.LootForageSpam then
                    gui.LOOTFORAGESPAM = DroidLoot.LootUtils.LootForageSpam
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.CombatLooting = ImGui.Checkbox('Enable Combat Looting', DroidLoot.LootUtils.CombatLooting)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots during combat.')
                if gui.COMBATLOOTING ~= DroidLoot.LootUtils.CombatLooting then
                    gui.COMBATLOOTING = DroidLoot.LootUtils.CombatLooting
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootGearUpgrades = ImGui.Checkbox('Enable Upgrade Looting', DroidLoot.LootUtils.LootGearUpgrades)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots items with more HP than currently worn items.')
                if gui.LOOTGEARUPGRADES ~= DroidLoot.LootUtils.LootGearUpgrades then
                    gui.LOOTGEARUPGRADES = DroidLoot.LootUtils.LootGearUpgrades
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Columns(1)

                if ImGui.CollapsingHeader("Wild Card Looting Options") then
                    ImGui.Indent()
                    DroidLoot.LootUtils.LootWildCardItems = ImGui.Checkbox('Enable Wildcard Looting', DroidLoot.LootUtils.LootWildCardItems)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots items matching wildcard names.')
                    if gui.LOOTWILDCARDITEMS ~= DroidLoot.LootUtils.LootWildCardItems then
                        gui.LOOTWILDCARDITEMS = DroidLoot.LootUtils.LootWildCardItems
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    -- Ensure DroidLoot.LootUtils.wildCardTerms is initialized
                    DroidLoot.LootUtils.wildCardTerms = DroidLoot.LootUtils.wildCardTerms or {}

                    -- Start ImGui UI block (inside your existing ImGui window code)
                    if ImGui.CollapsingHeader("Wildcard Terms") then
                        ImGui.Indent()
                        -- Show each term with a text input and delete button
                        local removeIndex = nil
                        for i, term in ipairs(DroidLoot.LootUtils.wildCardTerms) do
                            ImGui.PushID(i) -- Prevent ImGui ID conflicts
                            local newTerm, changed = ImGui.InputText("##Term" .. i, term, 256)
                            if changed then
                                DroidLoot.LootUtils.wildCardTerms[i] = newTerm
                            end
                            ImGui.SameLine()
                            if ImGui.Button("Delete") then
                                removeIndex = i
                            end
                            ImGui.PopID()
                        end

                        -- Remove term if requested
                        if removeIndex then
                            table.remove(DroidLoot.LootUtils.wildCardTerms, removeIndex)
                        end

                        ImGui.Separator()

                        -- Add new term
                        DroidLoot.LootUtils.newWildCardTerm = DroidLoot.LootUtils.newWildCardTerm or ""
                        local changed, newTerm = ImGui.InputText("New Term", DroidLoot.LootUtils.newWildCardTerm, 256)
                        if changed then
                            DroidLoot.LootUtils.newWildCardTerm = newTerm
                            DroidLoot.LootUtils.writeSettings()
                        end
                        if ImGui.Button("Add Term") then
                            if DroidLoot.LootUtils.newWildCardTerm ~= "" then
                                table.insert(DroidLoot.LootUtils.wildCardTerms, DroidLoot.LootUtils.newWildCardTerm)
                                DroidLoot.LootUtils.newWildCardTerm = ""
                                DroidLoot.LootUtils.writeSettings()
                            end
                        end
                        ImGui.Unindent()
                    end

                    ImGui.Unindent()
                end

                DroidLoot.LootUtils.CorpseRadius = ImGui.SliderInt("Corpse Radius", DroidLoot.LootUtils.CorpseRadius, 1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should scan for corpses.')
                if gui.CORPSERADIUS ~= DroidLoot.LootUtils.CorpseRadius then
                    gui.CORPSERADIUS = DroidLoot.LootUtils.CorpseRadius
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.MobsTooClose = ImGui.SliderInt("Mobs Too Close", DroidLoot.LootUtils.MobsTooClose, 1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The range to check for nearby mobs.')
                if gui.MOBSTOOCLOSE ~= DroidLoot.LootUtils.MobsTooClose then
                    gui.MOBSTOOCLOSE = DroidLoot.LootUtils.MobsTooClose
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootByMinHP = ImGui.SliderInt("Loot By HP Min Health", DroidLoot.LootUtils.LootByMinHP, 0, 50000)
                ImGui.SameLine()
                ImGui.HelpMarker('Minimum HP for item to be considered and set to Keep. Any value greater than 0 activates this.')
                if gui.LOOTBYHPMIN ~= DroidLoot.LootUtils.LootByMinHP then
                    gui.LOOTBYHPMIN = DroidLoot.LootUtils.LootByMinHP
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.StackPlatValue = ImGui.SliderInt("Stack Platinum Value", DroidLoot.LootUtils.StackPlatValue, 0, 10000)
                ImGui.SameLine()
                ImGui.HelpMarker('The value of platinum stacks.')
                if gui.STACKPLATVALUE ~= DroidLoot.LootUtils.StackPlatValue then
                    gui.STACKPLATVALUE = DroidLoot.LootUtils.StackPlatValue
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.SaveBagSlots = ImGui.SliderInt("Save Bag Slots", DroidLoot.LootUtils.SaveBagSlots, 0, 100)
                ImGui.SameLine()
                ImGui.HelpMarker('The number of bag slots to save.')
                if gui.SAVEBAGSLOTS ~= DroidLoot.LootUtils.SaveBagSlots then
                    gui.SAVEBAGSLOTS = DroidLoot.LootUtils.SaveBagSlots
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.MinSellPrice = ImGui.SliderInt("Min Sell Price", DroidLoot.LootUtils.MinSellPrice, 1, 100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum price at which items will be sold.')
                if gui.MINSELLPRICE ~= DroidLoot.LootUtils.MinSellPrice then
                    gui.MINSELLPRICE = DroidLoot.LootUtils.MinSellPrice
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.LootChannel = ImGui.InputText('Loot Channel', DroidLoot.LootUtils.LootChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to report loot to.')
                if gui.LOOTCHANNEL ~= DroidLoot.LootUtils.LootChannel then
                    gui.LOOTCHANNEL = DroidLoot.LootUtils.LootChannel
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                DroidLoot.LootUtils.AnnounceChannel = ImGui.InputText('Announce Channel',
                    DroidLoot.LootUtils.AnnounceChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to announce events.')
                if gui.ANNOUNCECHANNEL ~= DroidLoot.LootUtils.AnnounceChannel then
                    gui.ANNOUNCECHANNEL = DroidLoot.LootUtils.AnnounceChannel
                    DroidLoot.LootUtils.writeSettings()
                end
                ImGui.Separator();

                if ImGui.CollapsingHeader("INI") then
                    ImGui.Indent()
                    DroidLoot.LootUtils.Settings.LootFile = ImGui.InputText('Loot file', DroidLoot.LootUtils.Settings.LootFile)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loot file to use.')
                    if gui.LOOTINIFILE ~= DroidLoot.LootUtils.Settings.LootFile then
                        gui.LOOTINIFILE = DroidLoot.LootUtils.Settings.LootFile
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    ImGui.Columns(2)
                    local start_y_INI = ImGui.GetCursorPosY()

                    DroidLoot.LootUtils.UseSingleFileForAllCharacters = ImGui.Checkbox('Enable Single INI', DroidLoot.LootUtils.UseSingleFileForAllCharacters)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Reads from a single INI file for all characters when enabled.')
                    if gui.USESINGLEFILEFORALLCHARACTERS ~= DroidLoot.LootUtils.UseSingleFileForAllCharacters then
                        gui.USESINGLEFILEFORALLCHARACTERS = DroidLoot.LootUtils.UseSingleFileForAllCharacters
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.useZoneLootFile = ImGui.Checkbox('Enable Zone INI', DroidLoot.LootUtils.useZoneLootFile)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Reads from a zone based INI file for all characters when enabled.')
                    if gui.USEZONELOOTFILE ~= DroidLoot.LootUtils.useZoneLootFile then
                        gui.USEZONELOOTFILE = DroidLoot.LootUtils.useZoneLootFile
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.useClassLootFile = ImGui.Checkbox('Enable Class INI', DroidLoot.LootUtils.useClassLootFile)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Reads from a class based INI file for all characters when enabled.')
                    if gui.USECLASSLOOTFILE ~= DroidLoot.LootUtils.useClassLootFile then
                        gui.USECLASSLOOTFILE = DroidLoot.LootUtils.useClassLootFile
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_INI)

                    DroidLoot.LootUtils.useArmorTypeLootFile = ImGui.Checkbox('Enable Armor Type INI', DroidLoot.LootUtils.useArmorTypeLootFile)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Reads from an armor type based INI file for all characters when enabled.')
                    if gui.USEARMORTYPELOOTFILE ~= DroidLoot.LootUtils.useArmorTypeLootFile then
                        gui.USEARMORTYPELOOTFILE = DroidLoot.LootUtils.useArmorTypeLootFile
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    DroidLoot.LootUtils.useMacroLootFile = ImGui.Checkbox('Enable Macro INI', DroidLoot.LootUtils.useMacroLootFile)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Reads from an INI file provided by the macro for all characters when enabled.')
                    if gui.USEMACROLOOTFILE ~= DroidLoot.LootUtils.useMacroLootFile then
                        gui.USEMACROLOOTFILE = DroidLoot.LootUtils.useMacroLootFile
                        DroidLoot.LootUtils.writeSettings()
                    end
                    ImGui.Columns(1)
                    ImGui.Unindent();
                end
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
    mq.imgui.init('DroidLoot', gui.DroidLootGUI)
    gui.Open = true
end

return gui
