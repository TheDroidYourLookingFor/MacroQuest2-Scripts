---@type Mq
local mq = require('mq')
local gui = {}

gui.version = '1.0.7'
gui.versionOrder = { "1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.0.4", "1.0.5", "1.0.6", "1.0.7" }
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
function gui.DroidLootGUI()
    if show_main then
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
                local buttonWidth4, buttonHeight4 = 90, 30
                local buttonImVec4 = ImVec2(buttonWidth4, buttonHeight4)
                if DroidLoot.doPause then
                    if ImGui.Button('Resume', buttonImVec2) then
                        DroidLoot.doPause = false
                    end
                else
                    if ImGui.Button('Pause', buttonImVec2) then
                        DroidLoot.doPause = true
                    end
                end
                ImGui.SameLine(150)
                ImGui.Spacing()
                ImGui.SameLine()
                if ImGui.Button('Bank', buttonImVec4) then
                    DroidLoot.needToBank = true
                end
                ImGui.SameLine(250)
                ImGui.Spacing()
                ImGui.SameLine()
                if ImGui.Button('Sell', buttonImVec4) then
                    DroidLoot.needToVendorSell = true
                end
                ImGui.SameLine(350)
                ImGui.Spacing()
                ImGui.SameLine()
                if ImGui.Button("Minimize", buttonImVec4) then
                    show_main = false
                end
                ImGui.SameLine(485)
                ImGui.Spacing()
                ImGui.SameLine()
                ImGui.SameLine()
                if ImGui.Button('Quit DroidLoot', buttonImVec2) then
                    DroidLoot.terminate = true
                    mq.cmdf('/lua stop %s', 'DroidLoot')
                end
                ImGui.Spacing()

                if ImGui.CollapsingHeader("Droid Loot Bot") then
                    ImGui.Indent()
                    ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                        "It will loot anything set in the DroidLoot.ini.\n")
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
                    ImGui.Separator();
                    if ImGui.CollapsingHeader("Update") then
                        local buttonWidth3, buttonHeight3 = 160, 30
                        local buttonImVec3 = ImVec2(buttonWidth3, buttonHeight3)
                        ImGui.Indent()
                        ImGui.Text("Visit GitHub for the latest version.")
                        if ImGui.Button('Open Github', buttonImVec3) then
                            os.execute('start https://github.com/TheDroidYourLookingFor/MacroQuest2-Scripts/tree/main/Lua/DroidLoot')
                        end
                        ImGui.SameLine()
                        ImGui.HelpMarker('Opens the Github page for this project.')
                        ImGui.Separator();

                        ImGui.Text("Download latest from GitHub.")
                        if ImGui.Button('Download DroidLoot', buttonImVec3) then
                            os.execute('start https://github.com/TheDroidYourLookingFor/MacroQuest2-Scripts/raw/refs/heads/main/Lua/DroidLoot/DroidLoot.7z')
                        end
                        ImGui.SameLine()
                        ImGui.HelpMarker('Downloads the latest 7zip from github. You will need to extract it and update yourself.')
                        ImGui.Unindent()
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
                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("Health Operations") then
                        ImGui.Indent();
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
                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("Movement Operations") then
                        ImGui.Indent()
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
                        ImGui.Unindent()
                    end
                    if ImGui.CollapsingHeader("Camp Settings") then
                        ImGui.Indent()
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
                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("Wild Card Looting Options") then
                        ImGui.Indent()
                        local settingsChanged = false -- Track if any settings changed

                        -- Checkbox for enabling wildcard looting
                        local lootWildCardItems = DroidLoot.LootUtils.LootWildCardItems
                        local changed
                        lootWildCardItems, changed = ImGui.Checkbox('Enable Wildcard Looting', lootWildCardItems)
                        if changed then
                            DroidLoot.LootUtils.LootWildCardItems = lootWildCardItems
                            gui.LOOTWILDCARDITEMS = lootWildCardItems
                            settingsChanged = true
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
                            local newTermInput
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

                        ImGui.Unindent()
                    end
                    if ImGui.CollapsingHeader("Booleans") then
                        ImGui.Indent()
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
                        ImGui.Columns(1)
                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("Strings") then
                        ImGui.Indent()
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
                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("INI") then
                        ImGui.Indent()
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
                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("Server Specific Options") then
                        ImGui.Indent();
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
                            ImGui.Unindent()
                        end
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
