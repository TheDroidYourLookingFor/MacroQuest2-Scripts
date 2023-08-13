---@type Mq
local mq = require('mq')
---@type ImGui
local ImGui = require 'ImGui'
local Storage = require('EZLoot.lib.Storage')
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
            local buttonWidth, buttonHeight = 150, 30
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
            ImGui.SameLine(250)
            ImGui.Spacing()
            ImGui.SameLine()
            ImGui.Text(gui.CurrentStatus);
            ImGui.SameLine(450)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Quit EZLoot', buttonImVec2) then
                EZLoot.terminate = true
            end
            ImGui.Spacing()

            EZLoot.debug = ImGui.Checkbox('Enable Debug Messages', EZLoot.debug)
            ImGui.SameLine()
            ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
            if gui.DEBUG ~= EZLoot.debug then
                gui.DEBUG = EZLoot.debug
                Storage.SaveSettings(IniPath, Settings)
            end
            ImGui.Separator();

            EZLoot.returnToHome = ImGui.Checkbox('Enable Return To Home', EZLoot.returnToHome)
            ImGui.SameLine()
            ImGui.HelpMarker('Returns to home after looting when enabled.')
            if gui.RETURNTOHOME ~= EZLoot.returnToHome then
                gui.RETURNTOHOME = EZLoot.returnToHome
                Storage.SaveSettings(IniPath, Settings)
            end
            ImGui.Separator();

            EZLoot.home_Dist = ImGui.SliderInt('Return To Home Distance', EZLoot.home_Dist, 1, 1000)
            ImGui.SameLine()
            ImGui.HelpMarker('Returns to home after looting when enabled.')
            if gui.RETURNTOHOME ~= EZLoot.returnToHome then
                gui.RETURNTOHOME = EZLoot.returnToHome
                Storage.SaveSettings(IniPath, Settings)
            end
            ImGui.Separator();

            EZLoot.doSell = ImGui.Checkbox('Enable Sell', EZLoot.doSell)
            ImGui.SameLine()
            ImGui.HelpMarker('Sells to vendor when enabled.')
            if gui.DOSELL ~= EZLoot.doSell then
                gui.DOSELL = EZLoot.doSell
                Storage.SaveSettings(IniPath, Settings)
            end
            ImGui.Separator();

            EZLoot.doLoot = ImGui.Checkbox('Enable Looting', EZLoot.doLoot)
            ImGui.SameLine()
            ImGui.HelpMarker('Loots corpse when enabled.')
            if gui.DOLOOT ~= EZLoot.doLoot then
                gui.DOLOOT = EZLoot.doLoot
                Storage.SaveSettings(IniPath, Settings)
            end
            ImGui.Separator();

            EZLoot.doCorpseFix = ImGui.Checkbox('Enable CorpseFix', EZLoot.doCorpseFix)
            ImGui.SameLine()
            ImGui.HelpMarker('Uses corpsefix command before looting when enabled.')
            if gui.CORPSEFIX ~= EZLoot.doCorpseFix then
                gui.CORPSEFIX = EZLoot.doCorpseFix
                Storage.SaveSettings(IniPath, Settings)
            end
            ImGui.Separator();

            LootUtils.AddNewSales = ImGui.Checkbox('Enable adding new sales', LootUtils.AddNewSales)
            ImGui.SameLine()
            ImGui.HelpMarker('Adds new sales when enabled.')
            if gui.ADDNEWSALES ~= LootUtils.AddNewSales then
                gui.ADDNEWSALES = LootUtils.AddNewSales
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.LootForage = ImGui.Checkbox('Enable foraging', LootUtils.LootForage)
            ImGui.SameLine()
            ImGui.HelpMarker('Uses forage skill when enabled.')
            if gui.LOOTFORAGE ~= LootUtils.LootForage then
                gui.LOOTFORAGE = LootUtils.LootForage
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.CorpseRadius = ImGui.SliderInt('Radius to loot corpses', LootUtils.CorpseRadius, 1, 2500)
            ImGui.SameLine()
            ImGui.HelpMarker('How far away we should loot corpses.')
            if gui.CORPSERADIUS ~= LootUtils.CorpseRadius then
                gui.CORPSERADIUS = LootUtils.CorpseRadius
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.MobsTooClose = ImGui.SliderInt('Distance from mobs to stop looting', LootUtils.MobsTooClose, 1, 250)
            ImGui.SameLine()
            ImGui.HelpMarker('Distance from mobs to stop looting.')
            if gui.MOBSTOOCLOSE ~= LootUtils.MobsTooClose then
                gui.MOBSTOOCLOSE = LootUtils.MobsTooClose
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot', LootUtils.ReportLoot)
            ImGui.SameLine()
            ImGui.HelpMarker('Reports loot when enabled.')
            if gui.REPORTLOOT ~= LootUtils.ReportLoot then
                gui.REPORTLOOT = LootUtils.ReportLoot
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.LootChannel = ImGui.InputText('Loot Channel', LootUtils.LootChannel)
            ImGui.SameLine()
            ImGui.HelpMarker('The channel to use when announcing loot.')
            if LOOTCHANNEL ~= LootUtils.LootChannel then
                LOOTCHANNEL = LootUtils.LootChannel
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spamming Report Loot', LootUtils.SpamLootInfo)
            ImGui.SameLine()
            ImGui.HelpMarker('Allowings spamming loot report when enabled.')
            if gui.SPAMLOOTINFO ~= LootUtils.SpamLootInfo then
                gui.SPAMLOOTINFO = LootUtils.SpamLootInfo
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.GlobalLootOn = ImGui.Checkbox('Enable Global Loot', LootUtils.GlobalLootOn)
            ImGui.SameLine()
            ImGui.HelpMarker('Global loot when enabled.')
            if gui.GLOBALLOOTON ~= LootUtils.GlobalLootOn then
                gui.GLOBALLOOTON = LootUtils.GlobalLootOn
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.CombatLooting = ImGui.Checkbox('Enable Combat Loot', LootUtils.CombatLooting)
            ImGui.SameLine()
            ImGui.HelpMarker('Loot during combat when enabled.')
            if gui.COMBATLOOTING ~= LootUtils.CombatLooting then
                gui.COMBATLOOTING = LootUtils.CombatLooting
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.MinSellPrice = ImGui.SliderInt('Minimum sell price of an item', LootUtils.MinSellPrice, -1, 10000000)
            ImGui.SameLine()
            ImGui.HelpMarker('Minimum sell price of an item.')
            if gui.MINSELLPRICE ~= LootUtils.MinSellPrice then
                gui.MINSELLPRICE = LootUtils.MinSellPrice
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.StackableOnly = ImGui.Checkbox('Enable Looting only stackable value items', LootUtils.StackableOnly)
            ImGui.SameLine()
            ImGui.HelpMarker('Loot only stackable items of value when enabled.')
            if gui.STACKABLEONLY ~= LootUtils.StackableOnly then
                gui.STACKABLEONLY = LootUtils.StackableOnly
                LootUtils.writeSettings()
            end
            ImGui.Separator();

            LootUtils.StackPlatValue = ImGui.SliderInt('Value of stacked items to loot', LootUtils.StackPlatValue, -1, 10000000)
            ImGui.SameLine()
            ImGui.HelpMarker('Value of stacked items to loot')
            if gui.STACKPLATVALUE ~= LootUtils.StackPlatValue then
                gui.STACKPLATVALUE = LootUtils.StackPlatValue
                LootUtils.writeSettings()
            end
            ImGui.Separator();
        end
        ImGui.End()
    end
end

function gui.initGUI()
    mq.imgui.init('EZLoot', gui.EZLootGUI)
    gui.Open = true
end

return gui
