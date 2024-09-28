local version = '1.0.2'
--|------------------------------------------------------------|
--|          EmuHelper
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local ScriptName = 'EmuHelper'
local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
local my_Server = mq.TLO.EverQuest.Server() or ''
local ConfigDir = mq.configDir .. '\\EmuHelper'
local FileName = '\\' .. my_Name .. '.' .. my_Server .. '.ini'
local ClickFileName = '\\' .. my_Name .. '.' .. my_Server .. '.ClickItems.ini'
local HealthFileName = '\\' .. my_Name .. '.' .. my_Server .. '.HealthItems.ini'
local BotsFileName = '\\' .. my_Name .. '.' .. my_Server .. '.Bots.ini'
local RaidFileName = '\\' .. my_Name .. '.' .. my_Server .. '.Raid.ini'
local IniPath = ConfigDir .. FileName
local IniPathItemClicks = ConfigDir .. ClickFileName
local IniPathHealthClicks = ConfigDir .. HealthFileName
local IniPathBots = ConfigDir .. BotsFileName
local IniPathRaid = ConfigDir .. RaidFileName

local EmuHelper = {
    Terminate = false,
    BotRunning = true,
    GroupBots = false,
    SummonBots = false,
    SpawnBots = false,
    SetBotStance = false,
    SetBotRange = false,
    FormRaid = false,
    StartRaid = false,
    RaidLoot = false,
    RaidGive = false,
    Command_ShortName = 'EH',
    Command_LongName = 'EmuHelper',
    DEBUG = false,
    ChatDelay = 500,
    Loop_Wait = 1000,
    directMessage = '/dex',
    Raid_Mode = true,
}
-- local Casting = require('EmuHelper.Lib.Casting')
-- local Events = require('EmuHelper.Lib.Events')
-- local Gui = require('EmuHelper.Lib.Gui')
EmuHelper.GTM = require('EmuHelper.Lib.GivetoMain')
EmuHelper.Messages = require('EmuHelper.Lib.Messages')
-- local Navigation = require('EmuHelper.lib.Movement')
-- local SpellRoutines = require('EmuHelper.lib.spell_routines')
EmuHelper.Storage = require('EmuHelper.lib.Storage')

EmuHelper.Raid_Members = 18
EmuHelper.Raid_Groups = {
    version = version,
    {
        name = "Group1",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group2",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group3",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group4",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group5",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group6",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group7",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group8",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group9",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group10",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group11",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    },
    {
        name = "Group12",
        enabled = false,
        members = {
            "None", "None", "None", "None", "None", "None"
        }
    }
}

EmuHelper.Bot = {}
EmuHelper.Bot.Stances = {
    "Passive",
    "Balanced",
    "Efficient",
    "Reactive",
    "Aggressive",
    "Assist",
    "Burn",
    "Efficient2",
    "BurnAE"
}

EmuHelper.Bot.CastRange_Options = {
    "target",
    "byname",
    "ownergroup",
    "ownerraid",
    "targetgroup",
    "namesgroup",
    "healrotationtargets",
    "byclass",
    "byrace",
    "spawned"
}

EmuHelper.Bots = {
    version = version,
}

local function InitializeArrays()
    -- Initialize Bots with default values
    for i = 1, 11 do
        EmuHelper.Bots[i] = {
            UseBot = false,
            Name = 'None'
        }
    end

    EmuHelper.ItemClicks = {
        version = version,
    }
    -- Initialize ItemClicks with default values
    for i = 1, 10 do
        EmuHelper.ItemClicks[i] = {
            UseItem = false,
            Name = 'None',
            AttackRange = 20,
            PctHP = 100,
            CombatOnly = false
        }
    end

    EmuHelper.HealthItems = {
        version = version,
    }
    -- Initialize HealthItems with default values
    for i = 1, 10 do
        EmuHelper.HealthItems[i] = {
            UseItem = false,
            Name = 'None',
            PctHP = 95,
            CombatOnly = false
        }
    end
end
InitializeArrays()

function EmuHelper.GenerateSettings()
    local settings = {
        version = version,
        Debug = false,
        ChatDelay = EmuHelper.ChatDelay,
        SelectedBotStance = 5,
        selectedActionableOption = 1,
        casterRange = 150,
    }

    for key, value in pairs(EmuHelper.ItemClicks) do
        if type(key) == "number" then
            local clickIndex = string.format("%02d", key)
            settings["ClickItem" .. clickIndex] = value.Name
            settings["CombatOnly" .. clickIndex] = value.CombatOnly
            settings["UseItemClicks" .. clickIndex] = value.UseItem
            settings["clickAtPct" .. clickIndex] = value.PctHP
            settings["ItemClicksRange" .. clickIndex] = value.AttackRange
        end
    end

    for key, value in pairs(EmuHelper.HealthItems) do
        if type(key) == "number" then
            local hpIndex = string.format("%02d", key)
            settings["UseHealClicks" .. hpIndex] = value.UseItem
            settings["HpItemCombatOnly" .. hpIndex] = value.CombatOnly
            settings["HpItem" .. hpIndex] = value.Name
            settings["HpItemclickAtPct" .. hpIndex] = value.PctHP
        end
    end

    for key, value in ipairs(EmuHelper.Bots) do
        local botIndex = key
        settings["BotName" .. botIndex] = value.Name
        settings["UseBot" .. botIndex] = value.UseBot
    end

    for groupkey, group in ipairs(EmuHelper.Raid_Groups) do
        settings["EnableGroup" .. groupkey] = group.enabled
        for memberkey, name in ipairs(group.members) do
            --local botIndex = string.format("%02d", groupkey)
            local botIndex = string.format("%02d%02d", groupkey, memberkey)
            settings["RaidMember" .. botIndex] = name
        end
    end

    return settings
end

EmuHelper.Settings = {
    version = version,
    Debug = false,
    ChatDelay = EmuHelper.ChatDelay,
    SelectedBotStance = 5,
    selectedActionableOption = 1,
    casterRange = 150,
}
EmuHelper.Settings = EmuHelper.GenerateSettings()

local versionOrder = { "1.0.0" }
local change_Log = {
    ['1.0.0'] = { 'Initial Release',
        '- Each Character will get a \\Config\\EmuHelper\\EmuHelper.CharacterName.ini',
        '- Modules will create each character will get a \\Config\\EmuHelper\\EmuHelper.CharacterName.CLASS.ini' }
}

function ChangeLog()
    imgui.Text("Change Log:")
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
    imgui.InputTextMultiline("##changeLog", logText, ImGui.GetWindowSize(), 300, ImGuiInputTextFlags.ReadOnly)
end

function SaveSettings(iniFile, settingsList)
    --EmuHelper.Messages.CONSOLEMETHOD(false, 'function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function Setup(iniFile, settingsList)
    if EmuHelper.DEBUG then EmuHelper.Messages.CONSOLEMETHOD(false, 'function Setup() Entry') end
    CurrentStatus = 'Loading Settings'
    if not EmuHelper.Storage.dir_exists(ConfigDir) then EmuHelper.Storage.make_dir(mq.configDir, 'EmuHelper') end

    local conf
    local configData, err = loadfile(iniFile)
    if err then
        SaveSettings(iniFile, settingsList)
    elseif configData then
        conf = configData()
        if conf.version ~= version then
            SaveSettings(iniFile, settingsList)
            Setup(iniFile, settingsList)
        else
            return conf
        end
    end
end

EmuHelper.Settings = Setup(IniPath, EmuHelper.Settings)
EmuHelper.ItemClicks = Setup(IniPathItemClicks, EmuHelper.ItemClicks)
EmuHelper.HealthItems = Setup(IniPathHealthClicks, EmuHelper.HealthItems)
EmuHelper.Bots = Setup(IniPathBots, EmuHelper.Bots)
EmuHelper.Raid_Groups = Setup(IniPathRaid, EmuHelper.Raid_Groups)

CurrentStatus = ' '
local Open = false
local ShowUI = false

local text_Colors = {
    Red = 0xFF0000FF,        -- Red
    Black = 0xFF000000,      -- Black
    Blue = 0xFFFF0000,       -- Blue
    Green = 0xFF00FF00,      -- Green
    Light_Gray = 0xFF888888, -- Light Gray
    Purple = 0xFF800080,     -- Purple
    Yellow = 0xFF00FFFF,     -- Yellow
    Orange = 0xFFFFA500,     -- Orange
    Cyan = 0xFFFFFF00,       -- Cyan
    Magenta = 0xFFFF00FF,    -- Magenta
    White = 0xFFFFFFFF,      -- White
    Dark_Red = 0xFF8B0000,   -- Dark Red
    Dark_Blue = 0xFF00008B,  -- Dark Blue
    Dark_Green = 0xFF006400, -- Dark Green
    Dark_Gray = 0xFF444444,  -- Dark Gray
}

local function EmuHelperGUI()
    if Open then
        Open, ShowUI = ImGui.Begin('TheDroid Emu Helper v' .. version, Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        ImGui.PushStyleColor(ImGuiCol.Text, text_Colors.White)

        if ShowUI then
            --
            -- Buff Bot
            --
            local buttonWidth, buttonHeight = 150, 30
            local raidbuttonWidth, raidbuttonHeight = 100, 30
            local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
            local buttonRaid = ImVec2(raidbuttonWidth, raidbuttonHeight)

            if EmuHelper.BotRunning then
                if ImGui.Button('Pause', buttonImVec2) then
                    EmuHelper.BotRunning = false
                end
            else
                if ImGui.Button('Resume', buttonImVec2) then
                    EmuHelper.BotRunning = true
                end
            end

            ImGui.SameLine() -- Ensure subsequent items are placed on the same line
            ImGui.Text(CurrentStatus)
            ImGui.SameLine()
            local windowWidth = ImGui.GetWindowWidth() -- Get the width of the window

            -- Calculate the X position for the Quit button
            local buttonPosX = windowWidth - buttonWidth - ImGui.GetStyle().ItemSpacing.x

            -- Check if the calculated position is valid before setting the cursor position
            if buttonPosX > 0 then
                ImGui.SetCursorPosX(buttonPosX)
            end

            if ImGui.Button('Quit EmuHelper', buttonImVec2) then
                mq.cmdf('/lua stop %s', ScriptName)
            end
            ImGui.Spacing()

            if ImGui.CollapsingHeader("Raid") then
                ImGui.Indent()

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
                createButton('Form', function() EmuHelper.FormRaid = true end)
                createButton('Start', function() EmuHelper.StartRaid = true end)
                createButton('Loot', function() EmuHelper.RaidLoot = true end)
                createButton('Give', function() EmuHelper.RaidGive = true end)

                -- Groups Section
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()

                -- Function to render group members
                local function renderGroupMembers(groupIndex)
                    local group = EmuHelper.Raid_Groups[groupIndex]
                    if group then -- Check if the group exists
                        local groupCollapsed = ImGui.TreeNodeEx(group.name, ImGuiTreeNodeFlags.DefaultOpen)
                        if groupCollapsed then
                            ImGui.Indent()

                            -- Checkbox for enabling/disabling the group
                            local checkboxLabel = "Enabled##GroupEnabled" .. groupIndex
                            EmuHelper.Raid_Groups[groupIndex].enabled = ImGui.Checkbox(checkboxLabel,
                                EmuHelper.Raid_Groups[groupIndex].enabled)
                            if EmuHelper.Settings['EnableGroup' .. groupIndex] ~= EmuHelper.Raid_Groups[groupIndex].enabled then
                                EmuHelper.Settings['EnableGroup' .. groupIndex] = EmuHelper.Raid_Groups[groupIndex]
                                    .enabled
                                SaveSettings(IniPathRaid, EmuHelper.Raid_Groups)
                            end

                            for memberIndex, name in ipairs(group.members) do
                                ImGui.PushID('##RaidMemberName' .. memberIndex)
                                if name and name ~= '' then
                                    if name == 'None' then
                                        ImGui.PushStyleColor(ImGuiCol.Text, text_Colors.Yellow)
                                    else
                                        ImGui.PushStyleColor(ImGuiCol.Text, text_Colors.Light_Gray)
                                    end
                                    if EmuHelper.Raid_Groups[groupIndex].members[memberIndex] == '' then
                                        EmuHelper.Raid_Groups[groupIndex].members[memberIndex] = 'None'
                                    end
                                    EmuHelper.Raid_Groups[groupIndex].members[memberIndex] = ImGui.InputText(
                                        '##RaidMemberName' .. memberIndex,
                                        EmuHelper.Raid_Groups[groupIndex].members[memberIndex]
                                    )
                                    ImGui.PopStyleColor()
                                    ImGui.SameLine()
                                    ImGui.HelpMarker('The name of your bot.')

                                    local settingKey = 'RaidMember' .. string.format("%02d%02d", groupIndex, memberIndex)
                                    local currentValue = EmuHelper.Raid_Groups[groupIndex].members[memberIndex]
                                    if EmuHelper.Settings[settingKey] ~= currentValue then
                                        EmuHelper.Settings[settingKey] = currentValue
                                        SaveSettings(IniPathRaid, EmuHelper.Raid_Groups)
                                    end
                                elseif name and name == '' then
                                    ImGui.PushStyleColor(ImGuiCol.Text, 0xFFFF0000)
                                    name = 'None'
                                    if EmuHelper.Raid_Groups[groupIndex].members[memberIndex] == '' then
                                        EmuHelper.Raid_Groups[groupIndex].members[memberIndex] = 'None'
                                        SaveSettings(IniPathRaid, EmuHelper.Raid_Groups)
                                    end
                                end
                                ImGui.PopID()
                            end
                            ImGui.Unindent()
                            ImGui.TreePop()
                        end
                    end
                end

                -- Render groups in columns
                ImGui.Columns(2)
                local numGroups = #EmuHelper.Raid_Groups
                local numGroupsPerColumn = math.ceil(numGroups / 2)
                for groupIndex = 1, numGroupsPerColumn do
                    ImGui.PushID("Group" .. groupIndex)
                    renderGroupMembers(groupIndex)
                    ImGui.PopID()
                end
                ImGui.NextColumn()
                for groupIndex = numGroupsPerColumn + 1, numGroups do
                    local adjustedIndex = groupIndex - numGroupsPerColumn
                    ImGui.PushID("Group" .. adjustedIndex)
                    renderGroupMembers(groupIndex)
                    ImGui.PopID()
                end
                ImGui.Columns(1)

                ImGui.Unindent()
            end

            if ImGui.CollapsingHeader("Bots") then
                ImGui.Indent()
                -- Floating Buttons
                local buttonWidth, buttonHeight = 100, 25
                local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                local buttonSpacing = 20
                local windowWidth = ImGui.GetWindowWidth()
                local numButtons = 3
                local totalButtonWidth = (buttonWidth + buttonSpacing) * numButtons - buttonSpacing
                local buttonStartX = (windowWidth - totalButtonWidth) / 2

                -- Function to create buttons
                local function createButton(label, action)
                    if ImGui.Button(label, buttonImVec2) then
                        action()
                    end
                    ImGui.SameLine()
                end

                ImGui.SetCursorPosX(buttonStartX)

                -- Spawn Bots button
                createButton('Spawn Bots', function() EmuHelper.SpawnBots = true end)

                -- Group Bots button
                createButton('Group Bots', function() EmuHelper.GroupBots = true end)

                -- Summon Bots button
                createButton('Summon Bots', function() EmuHelper.SummonBots = true end)

                -- Calculate number of bots per column
                local numBots = #EmuHelper.Bots
                local numBotsPerColumn = math.ceil(numBots / 2)

                -- Groups Section
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()

                ImGui.SetCursorPosX(buttonStartX + 20)

                -- Spawn Bots button
                createButton('Set##Stance', function() EmuHelper.SetBotStance = true end)
                ImGui.SameLine()
                ImGui.SetNextItemWidth(150)
                local index, changed = ImGui.Combo("Select Stance", EmuHelper.Settings.SelectedBotStance,
                    EmuHelper.Bot.Stances)
                if changed then
                    EmuHelper.Settings.SelectedBotStance = index
                    SaveSettings(IniPath, EmuHelper.Settings)
                end
                -- Groups Section
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()

                ImGui.SetCursorPosX(buttonStartX - 50)

                -- Spawn Bots button
                createButton('Set##Range', function() EmuHelper.SetBotRange = true end)

                ImGui.SameLine()
                ImGui.Text('Caster Range')
                ImGui.SameLine()
                ImGui.SetNextItemWidth(150)
                -- Slider for CasterRange
                local newCasterRange, rangeChanged = ImGui.SliderInt("##CasterRange", EmuHelper.Settings.casterRange, 1,
                    300)
                if rangeChanged then
                    EmuHelper.Settings.casterRange = newCasterRange
                    SaveSettings(IniPath, EmuHelper.Settings)
                end

                ImGui.SameLine()
                ImGui.SetNextItemWidth(150)
                -- Combo box for actionable_name
                local newActionableOption, comboChanged = ImGui.Combo("##actionable_name",
                    EmuHelper.Settings.selectedActionableOption, EmuHelper.Bot.CastRange_Options)
                if comboChanged then
                    EmuHelper.Settings.selectedActionableOption = newActionableOption
                    SaveSettings(IniPath, EmuHelper.Settings)
                end

                -- Groups Section
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()

                -- First column
                ImGui.Columns(2)
                for i = 1, numBotsPerColumn do
                    local botIndex = i
                    if ImGui.BeginPopupContextItem() then
                        if ImGui.MenuItem("Add New Bot") then
                            -- Define default bot configuration
                            local defaultBot = {
                                UseBot = false,
                                Name = 'None'
                            }
                            table.insert(EmuHelper.Bots, i + 1, defaultBot) -- Insert a new bot at the correct position
                        end
                        if ImGui.MenuItem("Delete Bot") and #EmuHelper.Bots > 1 then
                            table.remove(EmuHelper.Bots, i) -- Delete the bot at the given position if there are multiple bots
                        end
                        ImGui.EndPopup()
                    end
                    if ImGui.TreeNode("Bot " .. botIndex .. "##Bot" .. botIndex) then
                        -- Enable checkbox
                        EmuHelper.Bots[botIndex].UseBot = ImGui.Checkbox('Enable##Bot' .. botIndex,
                            EmuHelper.Bots[botIndex].UseBot)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Enables using bot #' .. botIndex .. '.')

                        -- Name input field
                        EmuHelper.Bots[botIndex].Name = ImGui.InputText('##BotName' .. botIndex,
                            EmuHelper.Bots[botIndex].Name)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The name of your bot.')

                        -- Save settings if changed
                        local settingKey = 'BotName' .. botIndex
                        local currentValue = EmuHelper.Bots[botIndex].Name
                        if EmuHelper.Settings[settingKey] ~= currentValue then
                            EmuHelper.Settings[settingKey] = currentValue
                            SaveSettings(IniPathBots, EmuHelper.Bots)
                        end

                        local settingKey2 = 'UseBot' .. botIndex
                        local currentValue2 = EmuHelper.Bots[botIndex].UseBot
                        if EmuHelper.Settings[settingKey2] ~= currentValue2 then
                            EmuHelper.Settings[settingKey2] = currentValue2
                            SaveSettings(IniPathBots, EmuHelper.Bots)
                        end

                        ImGui.TreePop()
                    end
                end

                -- Second column
                ImGui.NextColumn()
                for i = numBotsPerColumn + 1, numBots do
                    local botIndex = i
                    if ImGui.BeginPopupContextItem() then
                        if ImGui.MenuItem("Add New Bot") then
                            -- Define default bot configuration
                            local defaultBot = {
                                UseBot = false,
                                Name = 'None'
                            }
                            table.insert(EmuHelper.Bots, i + 1, defaultBot) -- Insert a new bot at the correct position
                        end
                        if ImGui.MenuItem("Delete Bot") and #EmuHelper.Bots > 1 then
                            table.remove(EmuHelper.Bots, i) -- Delete the bot at the given position if there are multiple bots
                        end
                        ImGui.EndPopup()
                    end
                    if ImGui.TreeNode("Bot " .. botIndex .. "##Bot" .. botIndex) then
                        -- Enable checkbox
                        EmuHelper.Bots[botIndex].UseBot = ImGui.Checkbox('Enable##Bot' .. botIndex,
                            EmuHelper.Bots[botIndex].UseBot)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Enables using bot #' .. botIndex .. '.')

                        -- Name input field
                        EmuHelper.Bots[botIndex].Name = ImGui.InputText('##BotName' .. botIndex,
                            EmuHelper.Bots[botIndex].Name)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The name of your bot.')

                        -- Save settings if changed
                        local settingKey = 'BotName' .. botIndex
                        local currentValue = EmuHelper.Bots[botIndex].Name
                        if EmuHelper.Settings[settingKey] ~= currentValue then
                            EmuHelper.Settings[settingKey] = currentValue
                            SaveSettings(IniPathBots, EmuHelper.Bots)
                        end

                        local settingKey2 = 'UseBot' .. botIndex
                        local currentValue2 = EmuHelper.Bots[botIndex].UseBot
                        if EmuHelper.Settings[settingKey2] ~= currentValue2 then
                            EmuHelper.Settings[settingKey2] = currentValue2
                            SaveSettings(IniPathBots, EmuHelper.Bots)
                        end

                        ImGui.TreePop()
                    end
                end

                -- End columns
                ImGui.Columns(1)

                ImGui.Unindent()
            end

            if imgui.CollapsingHeader("Resource Clicks") then
                ImGui.Indent();
                for i = 1, #EmuHelper.HealthItems do
                    if imgui.CollapsingHeader('Click Item ' .. i .. '##ClickResource' .. i) then
                        EmuHelper.HealthItems[i].UseItem = ImGui.Checkbox('Enable##ClickResource' .. i,
                            EmuHelper.HealthItems[i].UseItem)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Enables using your Heal Item #1.')
                        if EmuHelper.Settings['UseHealClicks' .. string.format("%02d", i)] ~= EmuHelper.HealthItems[i].UseItem then
                            EmuHelper.Settings['UseHealClicks' .. string.format("%02d", i)] = EmuHelper.HealthItems[i]
                                .UseItem
                            SaveSettings(IniPathHealthClicks, EmuHelper.HealthItems)
                        end

                        ImGui.SameLine()
                        EmuHelper.HealthItems[i].CombatOnly = ImGui.Checkbox('Combat Only##ClickResource' .. i,
                            EmuHelper.HealthItems[i].CombatOnly)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Only use item when in combat when enabled.')
                        if EmuHelper.Settings['HpItemCombatOnly' .. string.format("%02d", i)] ~= EmuHelper.HealthItems[i].CombatOnly then
                            EmuHelper.Settings['HpItemCombatOnly' .. string.format("%02d", i)] = EmuHelper.HealthItems
                                [i].CombatOnly
                            SaveSettings(IniPathHealthClicks, EmuHelper.HealthItems)
                        end
                        ImGui.Separator();

                        EmuHelper.HealthItems[i].Name = ImGui.InputText('Name##ClickResource' .. i,
                            EmuHelper.HealthItems[i].Name)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The click item you would to use.')
                        if EmuHelper.Settings['HpItem' .. string.format("%02d", i)] ~= EmuHelper.HealthItems[i].Name then
                            EmuHelper.Settings['HpItem' .. string.format("%02d", i)] = EmuHelper.HealthItems[i].Name
                            SaveSettings(IniPathHealthClicks, EmuHelper.HealthItems)
                        end

                        ImGui.Separator();

                        EmuHelper.HealthItems[i].PctHP = ImGui.SliderInt("Start HP##ClickResource" .. i,
                            EmuHelper.HealthItems[i].PctHP, 1, 99)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The percentage of HP to start using item #1.')
                        if EmuHelper.Settings['HpItemclickAtPct' .. string.format("%02d", i)] ~= EmuHelper.HealthItems[i].PctHP then
                            EmuHelper.Settings['HpItemclickAtPct' .. string.format("%02d", i)] = EmuHelper.HealthItems
                                [i].PctHP
                            SaveSettings(IniPathHealthClicks, EmuHelper.HealthItems)
                        end
                    end
                end
                ImGui.Unindent();
            end

            if imgui.CollapsingHeader("Item Clicks") then
                ImGui.Indent();
                for i = 1, #EmuHelper.ItemClicks do
                    if imgui.CollapsingHeader('Click Item ' .. i .. '##ClickItem' .. i) then
                        EmuHelper.ItemClicks[i].UseItem = ImGui.Checkbox('Enable##ClickItem' .. i,
                            EmuHelper.ItemClicks[i].UseItem)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Enables using your Heal Item #1.')
                        if EmuHelper.Settings['UseItemClick' .. string.format("%02d", i)] ~= EmuHelper.ItemClicks[i].UseItem then
                            EmuHelper.Settings['UseItemClick' .. string.format("%02d", i)] = EmuHelper.ItemClicks
                                [i].UseItem
                            SaveSettings(IniPathItemClicks, EmuHelper.ItemClicks)
                        end

                        ImGui.SameLine()
                        EmuHelper.ItemClicks[i].CombatOnly = ImGui.Checkbox('Combat Only##ClickItem' .. i,
                            EmuHelper.ItemClicks[i].CombatOnly)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Only use item when in combat when enabled.')
                        if EmuHelper.Settings['CombatOnly' .. string.format("%02d", i)] ~= EmuHelper.ItemClicks[i].CombatOnly then
                            EmuHelper.Settings['CombatOnly' .. string.format("%02d", i)] = EmuHelper
                                .ItemClicks[i].CombatOnly
                            SaveSettings(IniPathItemClicks, EmuHelper.ItemClicks)
                        end
                        ImGui.Separator();

                        EmuHelper.ItemClicks[i].Name = ImGui.InputText('Name##ClickItem' .. i,
                            EmuHelper.ItemClicks[i].Name)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The click item you would to use.')
                        if EmuHelper.Settings['ClickItem' .. string.format("%02d", i)] ~= EmuHelper.ItemClicks[i].Name then
                            EmuHelper.Settings['ClickItem' .. string.format("%02d", i)] = EmuHelper.ItemClicks[i]
                                .Name
                            SaveSettings(IniPathItemClicks, EmuHelper.ItemClicks)
                        end

                        ImGui.Separator();

                        EmuHelper.ItemClicks[i].PctHP = ImGui.SliderInt("Start HP##ClickItem" .. i,
                            EmuHelper.ItemClicks[i].PctHP, 1, 100)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The percentage of HP to start using item #1.')
                        if EmuHelper.Settings['clickAtPct' .. string.format("%02d", i)] ~= EmuHelper.ItemClicks[i].PctHP then
                            EmuHelper.Settings['clickAtPct' .. string.format("%02d", i)] = EmuHelper.ItemClicks[i].PctHP
                            SaveSettings(IniPathItemClicks, EmuHelper.ItemClicks)
                        end

                        ImGui.Separator();

                        EmuHelper.ItemClicks[i].AttackRange = ImGui.SliderInt("Start Distance##ClickItem" .. i,
                            EmuHelper.ItemClicks[i].AttackRange, 1, 500)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The range to start using ItemClicks.')
                        if EmuHelper.Settings['ItemClicksRange' .. string.format("%02d", i)] ~= EmuHelper.ItemClicks[i].AttackRange then
                            EmuHelper.Settings['ItemClicksRange' .. string.format("%02d", i)] = EmuHelper.ItemClicks[i]
                                .AttackRange
                            SaveSettings(IniPathItemClicks, EmuHelper.ItemClicks)
                        end
                    end
                end
                ImGui.Unindent();
            end

            if imgui.CollapsingHeader("Options") then
                EmuHelper.Settings.Debug = ImGui.Checkbox('Enable Debug Messages', EmuHelper.Settings.Debug)
                ImGui.SameLine()
                ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                if EmuHelper.DEBUG ~= EmuHelper.Settings.Debug then
                    EmuHelper.DEBUG = EmuHelper.Settings.Debug
                    SaveSettings(IniPath, EmuHelper.Settings)
                end
                ImGui.Separator();

                ImGui.Text("Chat Message Delay");
                ImGui.SameLine()
                EmuHelper.Settings.ChatDelay = ImGui.InputInt('##ChatDelay', EmuHelper.Settings.ChatDelay)
                ImGui.SameLine()
                ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                if EmuHelper.ChatDelay ~= EmuHelper.Settings.ChatDelay then
                    EmuHelper.ChatDelay = EmuHelper.Settings.ChatDelay
                    SaveSettings(IniPath, EmuHelper.Settings)
                end
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");

                ImGui.Separator();

                if imgui.CollapsingHeader("Change Log") then
                    ChangeLog()
                end
            end
        end
        ImGui.End()
    end
end

mq.imgui.init('EmuHelper', EmuHelperGUI)
Open = true

function EmuHelper.LockRaid()
    mq.TLO.Window('RaidWindow').Child('RAID_LockButton').LeftMouseUp()
    mq.delay(750, function() return mq.TLO.Raid.Locked() == true end)
    if mq.TLO.Raid.Locked() then EmuHelper.LockRaid() end
end

function EmuHelper.UnLockRaid()
    mq.TLO.Window('RaidWindow').Child('RAID_UnLockButton').LeftMouseUp()
    mq.delay(750, function() return mq.TLO.Raid.Locked() == false end)
    if mq.TLO.Raid.Locked() then EmuHelper.UnLockRaid() end
end

function EmuHelper.InvitePlayers()
    for _, group in ipairs(EmuHelper.Raid_Groups) do
        if group.enabled then
            for _, name in ipairs(group.members) do
                if name and name ~= '' and name ~= 'None' then
                    mq.cmdf('/raidinvite %s', name)
                    mq.delay(100)
                end
            end
        end
        print() -- Empty line to separate groups in the output
    end
    mq.cmd('/dga /yes')
    mq.delay(500)
end

function EmuHelper.MovePlayer(index, player, groupnum)
    mq.cmdf('/notify RaidWindow RAID_NotInGroupPlayerList ListSelect %s', index)
    mq.delay(50)
    mq.TLO.Window('RaidWindow').Child('RAID_Group' .. groupnum .. 'Button').LeftMouseUp()
    mq.delay(50)
    if mq.TLO.Window('RaidWindow').Child('RAID_NotInGroupPlayerList').List(index, 2) == player then
        EmuHelper.MovePlayer(index,
            player, groupnum)
    end
end

function EmuHelper.MoveToGroup(player, groupnum)
    local toRemove = 'Group'
    local escapedGroup = toRemove:gsub('[%^$%(%)%%%.%[%]%*%+%-%?]', '%%%1')
    local group = groupnum:gsub(escapedGroup, '')
    for i = 1, mq.TLO.Window('RaidWindow').Child('RAID_NotInGroupPlayerList').Items() do
        if mq.TLO.Window('RaidWindow').Child('RAID_NotInGroupPlayerList').List(i, 2)() == player then
            --printf('%s: %s', group, player)
            EmuHelper.MovePlayer(i, player, group)
            return true
        end
    end
end

function EmuHelper.GroupPlayers()
    for _, group in ipairs(EmuHelper.Raid_Groups) do
        if group.enabled then
            for _, name in ipairs(group.members) do
                printf('%s: %s', group.name, name)
                EmuHelper.MoveToGroup(name, group.name)
                mq.delay(100)
            end
        end
    end
    mq.delay(250)
end

function EmuHelper.SetupRaid()
    if not mq.TLO.Window('RaidWindow').Open() then
        print('Raid Window Not Open!')
        mq.TLO.Window('RaidWindow').DoOpen()
        mq.delay(4000, function() return mq.TLO.Window('RaidWindow').Open() == true end)
    end
    EmuHelper.UnLockRaid()
    mq.delay(500)
    EmuHelper.InvitePlayers()
    mq.delay(2500, function() return mq.TLO.Raid.Members() == EmuHelper.Raid_Members end)
    EmuHelper.LockRaid()
    mq.delay(500)
    EmuHelper.GroupPlayers()
end

function EmuHelper.BotsRange()
    for i = 1, #EmuHelper.Bots do
        if EmuHelper.Bots[i].UseBot and mq.TLO.Spawn(EmuHelper.Bots[i].Name)() ~= nil then
            mq.cmdf('/target pc %s', EmuHelper.Bots[i].Name)
            mq.delay(10000, function() return mq.TLO.Target() ~= nil end)
            mq.delay(50)
            if mq.TLO.Target() == EmuHelper.Bots[i].Name then
                mq.cmdf('/say ^casterrange %s %s', EmuHelper.Settings.casterRange,
                    EmuHelper.Bot.CastRange_Options[EmuHelper.Settings.selectedActionableOption])
                mq.delay(EmuHelper.ChatDelay)
            end
            mq.delay(250)
        end
    end
end

function EmuHelper.BotsStance()
    for i = 1, #EmuHelper.Bots do
        if EmuHelper.Bots[i].UseBot and mq.TLO.Spawn(EmuHelper.Bots[i].Name)() ~= nil then
            mq.cmdf('/target pc %s', EmuHelper.Bots[i].Name)
            mq.delay(10000, function() return mq.TLO.Target() ~= nil end)
            if mq.TLO.Target() == EmuHelper.Bots[i].Name then
                mq.cmdf('/say ^stance %s', EmuHelper.Settings.SelectedBotStance)
                mq.delay(EmuHelper.ChatDelay)
            else
                if mq.TLO.Spawn(EmuHelper.Bots[i].Name)() ~= nil then
                    mq.cmdf('/target pc %s', EmuHelper.Bots[i].Name)
                    mq.delay(10000, function() return mq.TLO.Target() ~= nil end)
                    mq.cmdf('/say ^stance %s', EmuHelper.Settings.SelectedBotStance)
                    mq.delay(EmuHelper.ChatDelay)
                end
            end
        end
    end
end

function EmuHelper.BotsSpawn()
    for i = 1, #EmuHelper.Bots do
        if EmuHelper.Bots[i].UseBot then
            mq.cmdf('/say #bot spawn %s', EmuHelper.Bots[i].Name)
            mq.delay(EmuHelper.ChatDelay)
        end
    end
end

function EmuHelper.BotsInvite()
    for i = 1, #EmuHelper.Bots do
        if EmuHelper.Bots[i].UseBot and mq.TLO.Spawn(EmuHelper.Bots[i].Name)() ~= nil then
            mq.cmdf('/invite %s', EmuHelper.Bots[i].Name)
            mq.delay(EmuHelper.ChatDelay)
        end
    end
end

function EmuHelper.BotsSummon()
    mq.cmd('/say ^summon all')
end

function EmuHelper.ItemClick(itemName, itemRange, itemCombatOnly)
    if mq.TLO.FindItem(itemName).ID() ~= nil then
        if itemCombatOnly then
            if mq.TLO.Me.Combat() and (mq.TLO.Target.ID() and mq.TLO.Target.Distance() <= itemRange and mq.TLO.FindItem(itemName).TimerReady()) then
                mq.cmdf('/casting "%s" item', itemName)
                return true
            end
        else
            if mq.TLO.Target.ID() and mq.TLO.Target.Distance() <= itemRange and mq.TLO.FindItem(itemName).TimerReady() then
                mq.cmdf('/casting "%s" item', itemName)
                return true
            end
        end
        return false
    end
end

function EmuHelper.ResourceClick(itemName, itemPct, itemCombatOnly)
    if mq.TLO.FindItem(itemName).ID() ~= nil then
        if itemCombatOnly then
            if mq.TLO.Me.Combat() and mq.TLO.Me.PctHPs() <= itemPct and mq.TLO.FindItem(itemName).TimerReady() then
                mq.cmdf('/casting "%s" item', itemName)
                return true
            end
        else
            if mq.TLO.Me.PctHPs() <= itemPct and mq.TLO.FindItem(itemName).TimerReady() then
                mq.cmdf('/casting "%s" item', itemName)
                return true
            end
        end
        return false
    end
end

function EmuHelper.Raid_Start()
    EmuHelper.Messages.CONSOLEMETHOD(false, 'Raid starting RGMercs.')
    mq.cmdf('/dgre /target %s pc', mq.TLO.Me.Name())
    mq.delay(750)
    mq.cmd('/dgre /rgstart')
    mq.delay(750)
    mq.cmd('/dgre /rg AssistOutside 1')
    mq.delay(750)
    mq.cmdf('/dgre /rg OutsideAssistList %s', mq.TLO.Me.Name())
    mq.delay(750)
    mq.cmd('/dgre /rgstart')
end

function EmuHelper.Raid_Form()
    EmuHelper.Messages.CONSOLEMETHOD(false, 'Forming raid groups.')
    EmuHelper.SetupRaid()
end

function EmuHelper.Raid_Loot()
    EmuHelper.Messages.CONSOLEMETHOD(false, 'Raid looting corpses.')
    EmuHelper.RaidTurboLoot()
end

function EmuHelper.Raid_Give(whoToGiveTo)
    EmuHelper.Messages.CONSOLEMETHOD(false, 'Giving tradable items to %s', whoToGiveTo)
    EmuHelper.GTM.GiveEZItems(whoToGiveTo)
end

local function emuhelper_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            if Open then
                EmuHelper.Messages.CONSOLEMETHOD(false, 'Hiding %s Bot GUI', EmuHelper.Command_LongName)
                Open = false
            else
                EmuHelper.Messages.CONSOLEMETHOD(false, 'Restoring %s Bot GUI', EmuHelper.Command_LongName)
                Open = true
            end
            return
        elseif args[1] == 'raid' then
            if args[2] == 'form' then
                EmuHelper.Raid_Form()
            elseif args[2] == 'loot' then
                EmuHelper.Raid_Loot()
            elseif args[2] == 'give' then
                if args[3] ~= nil then
                    EmuHelper.Raid_Give(args[3])
                else
                    if mq.TLO.Target.ID() ~= nil then
                        EmuHelper.Raid_Give(mq.TLO.Target.Name())
                    else
                        EmuHelper.Raid_Give(mq.TLO.Me.Name())
                    end
                end
            elseif args[2] == 'start' then
                EmuHelper.Raid_Start()
            else
                EmuHelper.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                EmuHelper.Messages.CONSOLEMETHOD(false,
                '/%s \atraid\aw \apform\aw - Forms a raid from the Raid_Groups array',
                    EmuHelper.Command_ShortName)
                EmuHelper.Messages.CONSOLEMETHOD(false,
                    '/%s \atraid\aw \aploot\aw - Tells the raid to run TurboLoot macro for the current Zone ShortName with delay per launch',
                    EmuHelper.Command_ShortName)
            end
            return
        elseif args[1] == 'quit' then
            EmuHelper.Terminate = true
            return
        elseif args[1] == 'invite' then
            EmuHelper.GroupBots = true
            return
        elseif args[1] == 'summon' then
            EmuHelper.SummonBots = true
            return
        elseif args[1] == 'spawn' then
            EmuHelper.SpawnBots = true
            return
        elseif args[1] == 'stance' then
            EmuHelper.SetBotStance = true
            return
        elseif args[1] == 'range' then
            EmuHelper.SetBotRange = true
            return
        else
            EmuHelper.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            EmuHelper.Messages.CONSOLEMETHOD(false, '/%s gui - Toggles the %s GUI', EmuHelper.Command_ShortName,
                EmuHelper.Command_LongName)
            EmuHelper.Messages.CONSOLEMETHOD(false, '/%s invite - Invites bots to group.', EmuHelper.Command_ShortName)
            EmuHelper.Messages.CONSOLEMETHOD(false, '/%s summon - Summons active bots to you.',
            EmuHelper.Command_ShortName)
            EmuHelper.Messages.CONSOLEMETHOD(false, '/%s spawn - Spawns bots.', EmuHelper.Command_ShortName)
            EmuHelper.Messages.CONSOLEMETHOD(false, '/%s quit - Quits the %s lua script.', EmuHelper.Command_ShortName,
                EmuHelper.Command_LongName)
        end
    else
        EmuHelper.Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        EmuHelper.Messages.CONSOLEMETHOD(false, '/%s gui - Toggles the %s GUI', EmuHelper.Command_ShortName,
            EmuHelper.Command_LongName)
        EmuHelper.Messages.CONSOLEMETHOD(false, '/%s invite - Invites bots to group.', EmuHelper.Command_ShortName)
        EmuHelper.Messages.CONSOLEMETHOD(false, '/%s summon - Summons active bots to you.', EmuHelper.Command_ShortName)
        EmuHelper.Messages.CONSOLEMETHOD(false, '/%s spawn - Spawns bots.', EmuHelper.Command_ShortName)
        EmuHelper.Messages.CONSOLEMETHOD(false, '/%s quit - Quits the %s lua script.', EmuHelper.Command_ShortName,
            EmuHelper.Command_LongName)
    end
end
mq.bind('/' .. EmuHelper.Command_ShortName, emuhelper_command)
mq.bind('/' .. EmuHelper.Command_LongName, emuhelper_command)

function EmuHelper.Main()
    printf('[%s] %s Bot Started up! [%s]', EmuHelper.Command_ShortName, EmuHelper.Command_LongName,
        EmuHelper.Command_ShortName)
    if not mq.TLO.Plugin('MQ2Cast').IsLoaded() then mq.cmd('/plugin mq2cast load') end

    while not EmuHelper.Terminate do
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then EmuHelper.Terminate = true end
        if EmuHelper.FormRaid then
            local RaidForm_Status, RaidForm_Error = pcall(EmuHelper.Raid_Form)
            if RaidForm_Status then
                EmuHelper.FormRaid = false
            else
                EmuHelper.FormRaid = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue forming raid!")
                EmuHelper.Messages.CONSOLEMETHOD(false, RaidForm_Error)
            end
        end
        if EmuHelper.StartRaid then
            local RaidStart_Status, RaidStart_Error = pcall(EmuHelper.Raid_Start)
            if RaidStart_Status then
                EmuHelper.StartRaid = false
            else
                EmuHelper.StartRaid = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue starting raid!")
                EmuHelper.Messages.CONSOLEMETHOD(false, RaidStart_Error)
            end
        end
        if EmuHelper.RaidLoot then
            local RaidLoot_Status, RaidLoot_Error = pcall(EmuHelper.Raid_Loot)
            if RaidLoot_Status then
                EmuHelper.RaidLoot = false
            else
                EmuHelper.RaidLoot = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue starting raid looting!")
                EmuHelper.Messages.CONSOLEMETHOD(false, RaidLoot_Error)
            end
        end
        if EmuHelper.RaidGive then
            local RaidGive_Status, RaidGive_Error = pcall(EmuHelper.Raid_Give)
            if RaidGive_Status then
                EmuHelper.RaidGive = false
            else
                EmuHelper.RaidGive = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue starting raid give!")
                EmuHelper.Messages.CONSOLEMETHOD(false, RaidGive_Error)
            end
        end

        if EmuHelper.SpawnBots then
            local SpawnBots_Status, SpawnBots_Error = pcall(EmuHelper.BotsSpawn)
            if SpawnBots_Status then
                EmuHelper.SpawnBots = false
            else
                EmuHelper.SpawnBots = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue spawning bots!")
                EmuHelper.Messages.CONSOLEMETHOD(false, SpawnBots_Error)
            end
        end
        if EmuHelper.SetBotStance then
            local SetBotStance_Status, SetBotStance_Error = pcall(EmuHelper.BotsStance)
            if SetBotStance_Status then
                EmuHelper.SetBotStance = false
            else
                EmuHelper.SetBotStance = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue setting bot stance!")
                EmuHelper.Messages.CONSOLEMETHOD(false, SetBotStance_Error)
            end
        end
        if EmuHelper.SetBotRange then
            local SetBotRange_Status, SetBotRange_Error = pcall(EmuHelper.BotsRange)
            if SetBotRange_Status then
                EmuHelper.SetBotRange = false
            else
                EmuHelper.SetBotRange = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue setting bot range!")
                EmuHelper.Messages.CONSOLEMETHOD(false, SetBotRange_Error)
            end
        end
        if EmuHelper.GroupBots then
            local GroupBots_Status, GroupBots_Error = pcall(EmuHelper.BotsInvite)
            if GroupBots_Status then
                EmuHelper.GroupBots = false
            else
                EmuHelper.GroupBots = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue inviting bots to group!")
                EmuHelper.Messages.CONSOLEMETHOD(false, GroupBots_Error)
            end
        end
        if EmuHelper.SummonBots then
            local SummonBots_Status, SummonBots_Error = pcall(EmuHelper.BotsSummon)
            if SummonBots_Status then
                EmuHelper.SummonBots = false
            else
                EmuHelper.SummonBots = false
                EmuHelper.Messages.CONSOLEMETHOD(false, "Issue summmoning bots!")
                EmuHelper.Messages.CONSOLEMETHOD(false, SummonBots_Error)
            end
        end
        if EmuHelper.BotRunning then
            for i = 1, #EmuHelper.ItemClicks do
                if EmuHelper.ItemClicks[i].UseItem then
                    local ItemClick_Status, ItemClick_Error = pcall(EmuHelper.ItemClick, EmuHelper.ItemClicks[i].Name,
                        EmuHelper.ItemClicks[i].AttackRange, EmuHelper.ItemClicks[i].CombatOnly)
                    if not ItemClick_Status then
                        EmuHelper.Messages.CONSOLEMETHOD(false, "Item Click Error!!!")
                        EmuHelper.Messages.CONSOLEMETHOD(false, ItemClick_Error)
                    end
                end
            end

            for i = 1, #EmuHelper.HealthItems do
                local HealthItems_Status, HealthItems_Error = pcall(EmuHelper.ResourceClick, EmuHelper.HealthItems[i].Name, EmuHelper.HealthItems[i].PctHP, EmuHelper.HealthItems[i].CombatOnly)
                if not HealthItems_Status then
                    EmuHelper.Messages.CONSOLEMETHOD(false, "Resource Click Error!!!")
                    EmuHelper.Messages.CONSOLEMETHOD(false, HealthItems_Error)
                end
            end
        end
        mq.delay(EmuHelper.Loop_Wait)
        --if not ShowUI then return end
    end
end

if EmuHelper.DEBUG then EmuHelper.Messages.CONSOLEMETHOD(false, 'Main Loop Entry') end
EmuHelper.Main()
if EmuHelper.DEBUG then EmuHelper.Messages.CONSOLEMETHOD(false, 'Main Loop Exit') end

if EmuHelper.DEBUG then EmuHelper.Messages.CONSOLEMETHOD(false, 'Shutting down') end
mq.unbind('/' .. EmuHelper.Command_ShortName)
mq.unbind('/' .. EmuHelper.Command_LongName)
return EmuHelper
