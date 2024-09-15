local mq     = require('mq')
local Config = require('Xorbbs.lib.config')
Config:LoadSettings()

local GUI = {}

local my_Name = mq.TLO.Me.Name() or ''
local my_Server = mq.TLO.EverQuest.Server() or ''
local GlobalsFileName = '\\' .. my_Name .. '.' .. my_Server .. '.Xorbbs.Globals.ini'
local BossesFileName = '\\' .. my_Name .. '.' .. my_Server .. '.Xorbbs.Bosses.ini'
local IniPathGlobals = mq.configDir .. GlobalsFileName
local IniPathBosses = mq.configDir .. BossesFileName

local function SaveSettings(iniFile, settingsList)
    -- CONSOLEMETHOD('function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function GUI.Display(ImGui)
    -- Buttons Row
    ImGui.Spacing()

    local buttonWidth = 100
    local buttonSpacing = 20
    local windowWidth = ImGui.GetWindowWidth()

    local numButtons = 4
    local totalButtonWidth = (buttonWidth + buttonSpacing) * numButtons - buttonSpacing
    local buttonOffset = 25
    local buttonStartX = (windowWidth - totalButtonWidth) / 2 + buttonOffset
    
    -- Function to create buttons
    local function createButton(label, action)
        if ImGui.Button(label, ImVec2(buttonWidth, 0)) then
            action()
        end
        ImGui.SameLine()
    end

    -- Buttons
    ImGui.SetCursorPosX(buttonStartX)
    createButton('Quit', function() Config.Globals.Terminate = true end)

    -- Groups Section
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()


    if ImGui.CollapsingHeader("General Settings") then
        ImGui.Indent()
        -- Infinite Mode Wait Time
        local infiniteModeTimeChanged
        Config.Globals.IMode_Wait_Time, infiniteModeTimeChanged = ImGui.InputText("IMode Wait Time",
            Config.Globals.IMode_Wait_Time, 50)
        if infiniteModeTimeChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Summon Item
        local summonItemChanged
        Config.Globals.Summon_Item, summonItemChanged = ImGui.InputText("Summon Item",
            Config.Globals.Summon_Item, 255)
        if summonItemChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Engage Command
        local engageCommandChanged
        Config.Globals.Engage_Command, engageCommandChanged = ImGui.InputText("Engage Command",
            Config.Globals.Engage_Command, 255)
        if engageCommandChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Engage Command 2
        local engageCommand2Changed
        Config.Globals.Engage_Command2, engageCommand2Changed = ImGui.InputText("Engage Command 2",
            Config.Globals.Engage_Command2, 255)
        if engageCommand2Changed then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Wait For Stance
        local waitForStanceChanged
        Config.Globals.Wait_For_Stance, waitForStanceChanged = ImGui.Checkbox("Wait For Stance",
            Config.Globals.Wait_For_Stance)
        if waitForStanceChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Combat Stance
        local combatStanceChanged
        Config.Globals.Combat_Stance, combatStanceChanged = ImGui.InputText("Combat Stance",
            Config.Globals.Combat_Stance, 255)
        if combatStanceChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Corpse Radius
        local corpseRadiusChanged
        Config.Globals.CorpseRadius, corpseRadiusChanged = ImGui.InputInt("Corpse Radius",
            Config.Globals.CorpseRadius)
        if corpseRadiusChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Zone Wait Time
        local zoneWaitTimeChanged
        Config.Globals.ZoneWaitTime, zoneWaitTimeChanged = ImGui.InputInt("Zone Wait Time",
            Config.Globals.ZoneWaitTime)
        if zoneWaitTimeChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Spawn Search
        local spawnSearchChanged
        Config.Globals.spawnSearch, spawnSearchChanged = ImGui.InputText("Spawn Search",
            Config.Globals.spawnSearch, 255)
        if spawnSearchChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Nav Stop Distance
        local navStopDistanceChanged
        Config.Globals.NavStopDistance, navStopDistanceChanged = ImGui.InputInt("Nav Stop Distance",
            Config.Globals.NavStopDistance)
        if navStopDistanceChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end

        -- Target Wait Time
        local targetWaitTimeChanged
        Config.Globals.Target_Wait_Time, targetWaitTimeChanged = ImGui.InputInt("Target Wait Time",
            Config.Globals.Target_Wait_Time)
        if targetWaitTimeChanged then
            SaveSettings(IniPathGlobals, Config.Globals)
        end
        ImGui.Unindent()
    end

    local checkBoxWidth = 200 -- Adjust this value as needed for proper alignment
    for zoneName, zoneData in pairs(Config.XorbbZones) do
        if zoneName ~= 'version' then
            if ImGui.CollapsingHeader(zoneName .. " Bosses:") then
                ImGui.Indent()
                for bossKey, bossData in pairs(zoneData.Bosses) do
                    local posX = ImGui.GetCursorPosX() -- Get current X position
                    local bossChanged
                    local stanceChanged
                    bossData.Enabled, bossChanged = ImGui.Checkbox(bossData.Name, bossData.Enabled)
                    ImGui.SameLine()
                    ImGui.SetCursorPosX(posX + checkBoxWidth) -- Adjusted position for "Wait for stance" text
                    ImGui.Text("Wait for stance:")
                    ImGui.SameLine()
                    bossData.WaitForStance, stanceChanged = ImGui.Checkbox(
                        "##waitForStance_" .. zoneName .. "_" .. bossKey,
                        bossData.WaitForStance)
                    if bossChanged then
                        Config.XorbbZones[zoneName].Bosses[bossKey].Enabled = bossData.Enabled
                        SaveSettings(IniPathBosses, Config.XorbbZones)
                        -- Handle change event
                    end
                    if stanceChanged then
                        Config.XorbbZones[zoneName].Bosses[bossKey].WaitForStance = bossData.WaitForStance
                        SaveSettings(IniPathBosses, Config.XorbbZones)
                        -- Handle change event
                    end
                end
                ImGui.Unindent()
            end
        end
    end
end

function GUI:drawUI(imgui)
    -- Call your ImGui functions to draw the interface
    self.Display(imgui)
    -- Add more windows or controls as needed
end

-- Example update loop
function GUI.onUpdate(imgui)
    -- Call your drawUI function in your main update loop
    GUI:drawUI(imgui)
end

return GUI
