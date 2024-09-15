local mq             = require('mq')
local ImGui          = require('ImGui')
local lootutils      = require 'Xorbbs.lib.LootUtils'
local BossFarmConfig = require('Xorbbs.lib.config')
BossFarmConfig:LoadSettings()

local GUI = require('Xorbbs.lib.GUI')

function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = 'Xorbbs'
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
end

local function PRINTMETHOD(printMessage, ...)
    printf(BossFarmConfig.Colors.u .. "[Xorbbs]" .. BossFarmConfig.Colors.w .. printMessage .. "\aC\n", ...)
end

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

local function Setup(iniFile, settingsList)
    -- CONSOLEMETHOD(false, 'function Setup() Entry')
    local conf
    local configData, err = loadfile(iniFile)
    if err then
        SaveSettings(iniFile, settingsList)
    elseif configData then
        conf = configData()
        if conf.version ~= BossFarmConfig._version then
            SaveSettings(iniFile, settingsList)
            Setup(iniFile, settingsList)
        else
            return conf
        end
    end
end

BossFarmConfig.Globals = Setup(IniPathGlobals, BossFarmConfig.Globals)
BossFarmConfig.XorbbZones = Setup(IniPathBosses, BossFarmConfig.XorbbZones)

local function LootBoss(BossName)
    PRINTMETHOD('Looting %s%s%s.', BossFarmConfig.Colors.g, BossName, BossFarmConfig.Colors.x)
    lootutils.lootMobs()
end

local function NavToBoss(navTarget)
    if not mq.TLO.Target() or not mq.TLO.Target.ID() then return end
    PRINTMETHOD('Navigating to %s%s%s.', BossFarmConfig.Colors.g, navTarget, BossFarmConfig.Colors.x)
    mq.cmdf('/nav target distance=%s', BossFarmConfig.Globals.NavStopDistance)
    while mq.TLO.Navigation.Active() do
        local spawn = mq.TLO.Spawn(navTarget)
        if spawn and spawn.ID() ~= 0 and spawn.Distance3D() <= BossFarmConfig.Globals.NavStopDistance then
            mq.cmd('/nav stop')
        end
        mq.delay(50)
    end
    mq.delay(250)
    mq.cmdf('/useitem %s', BossFarmConfig.Globals.Summon_Item)
    mq.delay(1000)
    mq.cmd('/face fast')
    mq.delay(2500)
    if BossFarmConfig.Globals.Use_Bots then
        mq.cmd('/say ^summon all')
        mq.delay(1500)
    end
end

local function EngageBoss(BossName)
    if not mq.TLO.Target() or not mq.TLO.Target.ID() then return end
    PRINTMETHOD('Engaging to %s%s%s.', BossFarmConfig.Colors.g, BossName, BossFarmConfig.Colors.x)
    mq.delay(1000)
    if BossFarmConfig.Globals.Engage_Command2 ~= nil then mq.cmdf('%s', BossFarmConfig.Globals.Engage_Command) end
    mq.delay(1500)
    if BossFarmConfig.Globals.Engage_Command2 ~= nil then mq.cmdf('%s', BossFarmConfig.Globals.Engage_Command2) end
    mq.delay(1500)
    local spawn = mq.TLO.Spawn(BossName)
    while spawn and spawn.ID() ~= 0 and mq.TLO.SpawnCount('npc ' .. BossName)() > 0 do
        if mq.TLO.Target() and not mq.TLO.Me.Combat() and mq.TLO.Target.Distance3D() <= BossFarmConfig.Globals.NavStopDistance then
            mq.cmd('/attack on')
        end
        mq.delay(50)
    end
    mq.delay(50)
    LootBoss(BossName)
    mq.delay(5000, function() return not mq.TLO.Me.Casting() end)
end

local function CleanZone(BossList)
    for bossName, bossData in pairs(BossList) do
        BossFarmConfig.Globals.Last_Boss_Name = bossData.Name
        if bossData.Enabled then
            PRINTMETHOD('Looking for boss %s%s%s to navigate to!', BossFarmConfig.Colors.g, bossData.Name,
                BossFarmConfig.Colors.x)
            if mq.TLO.Spawn(bossData.Name)() and mq.TLO.Spawn(bossData.Name).ID() then
                mq.cmdf('/target npc %s', bossData.Name)
                mq.delay(BossFarmConfig.Globals.Target_Wait_Time, function() return mq.TLO.Target() ~= nil end)
                if mq.TLO.Target.PctHPs() == 100 and not mq.TLO.Target.TargetOfTarget() then
                    if mq.TLO.Target() and mq.TLO.Target.ID() then
                        BossFarmConfig.Globals.lastTargID = mq.TLO.Target.ID()
                        NavToBoss(bossData.Name)
                        mq.delay(1000)
                        while not mq.TLO.Me.CombatAbilityReady(BossFarmConfig.Globals.Combat_Stance)() and bossData.WaitForStance and mq.TLO.Me.ActiveDisc() ~= BossFarmConfig.Globals.Combat_Stance do
                            mq.delay(1000)
                        end
                        EngageBoss(bossData.Name)
                        mq.delay(250)
                    else
                        PRINTMETHOD('Couldn\'t find %s%s%s!', BossFarmConfig.Colors.r, bossData.Name,
                            BossFarmConfig.Colors.x)
                    end
                else
                    PRINTMETHOD('Boss %s%s%s already engaged!', BossFarmConfig.Colors.r, bossData.Name,
                        BossFarmConfig.Colors.x)
                end
            else
                PRINTMETHOD('Couldn\'t find %s%s%s!', BossFarmConfig.Colors.r, bossData.Name, BossFarmConfig.Colors.x)
            end
        end
    end
end

local function FarmXorbbs()
    for zone, info in pairs(BossFarmConfig.BossZones) do
        if info.Enabled then
            if mq.TLO.Zone.ShortName() ~= info.Name then
                mq.cmdf('/dgra /say #peqzone %s', info.Name)
                mq.delay('1m', function() return mq.TLO.Zone.ShortName() == info.Name end)
                mq.delay(BossFarmConfig.Globals.ZoneWaitTime)
            end
            CleanZone(info.BossList)
            mq.delay(1000)
        end
    end
end

local versionOrder = { "1.0.0" }
local change_Log = {
    ['1.0.0'] = { 'Initial Release' }
}

function ChangeLog()
    ImGui.Text("Change Log:")
    local logText = ""
    -- Iterate over the versionOrder table
    for _, version in ipairs(versionOrder) do
        local changes = change_Log[version]
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

local function DisplayGUI()
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
    -- createButton('Quit', function() BossFarmConfig.Globals.Terminate = true end)
    createButton('Quit', function() mq.cmd('/lua stop xorbbs') end)

    -- Groups Section
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()


    if ImGui.CollapsingHeader("General Settings") then
        ImGui.Indent()
        -- Infinite Mode Wait Time
        local infiniteModeTimeChanged
        BossFarmConfig.Globals.IMode_Wait_Time, infiniteModeTimeChanged = ImGui.InputText("IMode Wait Time",
            BossFarmConfig.Globals.IMode_Wait_Time, 50)
        if infiniteModeTimeChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Summon Item
        local summonItemChanged
        BossFarmConfig.Globals.Summon_Item, summonItemChanged = ImGui.InputText("Summon Item",
            BossFarmConfig.Globals.Summon_Item, 255)
        if summonItemChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Engage Command
        local engageCommandChanged
        BossFarmConfig.Globals.Engage_Command, engageCommandChanged = ImGui.InputText("Engage Command",
            BossFarmConfig.Globals.Engage_Command, 255)
        if engageCommandChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Engage Command 2
        local engageCommand2Changed
        BossFarmConfig.Globals.Engage_Command2, engageCommand2Changed = ImGui.InputText("Engage Command 2",
            BossFarmConfig.Globals.Engage_Command2, 255)
        if engageCommand2Changed then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Wait For Stance
        local waitForStanceChanged
        BossFarmConfig.Globals.Wait_For_Stance, waitForStanceChanged = ImGui.Checkbox("Wait For Stance",
            BossFarmConfig.Globals.Wait_For_Stance)
        if waitForStanceChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Combat Stance
        local combatStanceChanged
        BossFarmConfig.Globals.Combat_Stance, combatStanceChanged = ImGui.InputText("Combat Stance",
            BossFarmConfig.Globals.Combat_Stance, 255)
        if combatStanceChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Corpse Radius
        local corpseRadiusChanged
        BossFarmConfig.Globals.CorpseRadius, corpseRadiusChanged = ImGui.InputInt("Corpse Radius",
            BossFarmConfig.Globals.CorpseRadius)
        if corpseRadiusChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Zone Wait Time
        local zoneWaitTimeChanged
        BossFarmConfig.Globals.ZoneWaitTime, zoneWaitTimeChanged = ImGui.InputInt("Zone Wait Time",
            BossFarmConfig.Globals.ZoneWaitTime)
        if zoneWaitTimeChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Spawn Search
        local spawnSearchChanged
        BossFarmConfig.Globals.spawnSearch, spawnSearchChanged = ImGui.InputText("Spawn Search",
            BossFarmConfig.Globals.spawnSearch, 255)
        if spawnSearchChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Nav Stop Distance
        local navStopDistanceChanged
        BossFarmConfig.Globals.NavStopDistance, navStopDistanceChanged = ImGui.InputInt("Nav Stop Distance",
            BossFarmConfig.Globals.NavStopDistance)
        if navStopDistanceChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end

        -- Target Wait Time
        local targetWaitTimeChanged
        BossFarmConfig.Globals.Target_Wait_Time, targetWaitTimeChanged = ImGui.InputInt("Target Wait Time",
            BossFarmConfig.Globals.Target_Wait_Time)
        if targetWaitTimeChanged then
            SaveSettings(IniPathGlobals, BossFarmConfig.Globals)
        end
        ImGui.Unindent()
    end

    local checkBoxWidth = 200 -- Adjust this value as needed for proper alignment
    for zoneName, zoneData in pairs(BossFarmConfig.XorbbZones) do
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
                        BossFarmConfig.XorbbZones[zoneName].Bosses[bossKey].Enabled = bossData.Enabled
                        SaveSettings(IniPathBosses, BossFarmConfig.XorbbZones)
                        -- Handle change event
                    end
                    if stanceChanged then
                        BossFarmConfig.XorbbZones[zoneName].Bosses[bossKey].WaitForStance = bossData.WaitForStance
                        SaveSettings(IniPathBosses, BossFarmConfig.XorbbZones)
                        -- Handle change event
                    end
                end
                ImGui.Unindent()
            end
        end
    end
end

CurrentStatus = ' '
local Open = false
local function XorbbsGUI()
    if Open then
        Open, BossFarmConfig.Globals.ShowUI = ImGui.Begin('TheDroid Xorbb Boss Hunter Bot v' .. BossFarmConfig._version, Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        if BossFarmConfig.Globals.ShowUI then
            DisplayGUI()
        end
        ImGui.End()
    end
end
mq.imgui.init('Xorbb Hunter', XorbbsGUI)
Open = true

local function xh_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            if Open then
                PRINTMETHOD('Hiding Xorbbs Boss Hunter GUI')
                Open = false
            else
                PRINTMETHOD('Restoring Xorbbs Boss Hunter GUI')
                Open = true
            end
            return
        elseif args[1] == 'quit' then
            BossFarmConfig.Globals.Terminate = true
            return
        else
            PRINTMETHOD('Valid Commands:')
            PRINTMETHOD('/xh gui - Toggles the Xorbbs Boss Hunter GUI')
            PRINTMETHOD('/xh quit - Quits the Xorbbs Boss Hunter lua script.')
        end
    else
        PRINTMETHOD('Valid Commands:')
        PRINTMETHOD('/xh gui - Toggles the Xorbbs Boss Hunter GUI')
        PRINTMETHOD('/xh quit - Quits the Xorbbs Boss Hunter lua script.')
    end
end
mq.bind('/xh', xh_command)

local function Main()
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Xorbbs Boss Hunter Started ++')

    if BossFarmConfig.Globals.Infinite_Mode then
        PRINTMETHOD('++ Xorbbs Infinite Farm Mode Started ++')
        while not BossFarmConfig.Globals.Terminate do
            PRINTMETHOD('Boss cycle started')
            FarmXorbbs()
            PRINTMETHOD('Time to wait %s%s%s for the next Boss cycle.', BossFarmConfig.Colors.g,
                BossFarmConfig.Globals.IMode_Wait_Time, BossFarmConfig.Colors.x)
            mq.delay(BossFarmConfig.Globals.IMode_Wait_Time)
            --if not BossFarmConfig.Globals.ShowUI then return end
            mq.delay(100)
        end
    else
        FarmXorbbs()
    end
end
Main()
