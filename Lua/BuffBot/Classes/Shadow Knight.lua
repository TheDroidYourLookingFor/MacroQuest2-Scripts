---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local shadowknight = {}
shadowknight.version = '1.0.0'

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

shadowknight.summon_Spell = {
    'Summon Remains'
}
shadowknight.shadowknight_settings = {
    version = shadowknight.version,
    runDebug = DEBUG,
    summonSpells = shadowknight.summon_Spell,
    summonEnabled = false,
    summon_current_idx = 1,
}

function shadowknight.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, shadowknight.shadowknight_settings)
end

function shadowknight.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        shadowknight.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= shadowknight.version then
            shadowknight.saveSettings()
            shadowknight.Setup()
        else
            shadowknight.shadowknight_settings = conf
        end
    end
end

function shadowknight.MemorizeSpells()
    return
end

function shadowknight.Buff()
    return
end

local summonEnabled
local summon_current_idx

function shadowknight.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Shadowknight v" .. shadowknight.version) then
        ImGui.Text("SHADOWKNIGHT:")
        ImGui.BulletText('Please invite me to "summon" your corpse.')
        ImGui.Separator();

        --
        -- Summon
        --
        if ImGui.TreeNode('Summon') then
            ImGui.SameLine()
            shadowknight.shadowknight_settings.summonEnabled = ImGui.Checkbox('Enable',
                shadowknight.shadowknight_settings.summonEnabled)
            if summonEnabled ~= shadowknight.shadowknight_settings.summonEnabled then
                summonEnabled = shadowknight.shadowknight_settings.summonEnabled
                shadowknight.saveSettings()
            end
            ImGui.Separator()

            shadowknight.shadowknight_settings.summon_current_idx = GUI.CreateBuffBox:draw("Summon Spell",
                shadowknight.shadowknight_settings.summonSpells,
                shadowknight.shadowknight_settings.summon_current_idx);
            if summon_current_idx ~= shadowknight.shadowknight_settings.summon_current_idx then
                summon_current_idx = shadowknight.shadowknight_settings.summon_current_idx
                shadowknight.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Help
        --
        if imgui.CollapsingHeader("Shadowknight Options") then
            Settings.advertise = ImGui.Checkbox('Enable Advertising', Settings.advertise)
            ImGui.SameLine()
            ImGui.HelpMarker('Enables adversing to the player about the bots capabilities.')
            if Advertise ~= Settings.advertise then
                Advertise = Settings.advertise
                SaveSettings(IniPath, Settings)
            end

            Settings.advertiseChat = ImGui.InputText('Advertise Command', Settings.advertiseChat)
            ImGui.SameLine()
            ImGui.HelpMarker('The command used by the Buffer to advertises its capabilities to the player.')
            if AdvertiseChat ~= Settings.advertiseChat then
                AdvertiseChat = Settings.advertiseChat
                SaveSettings(IniPath, Settings)
            end

            Settings.advertiseMessage = ImGui.InputText('Advertise Message', Settings.advertiseMessage)
            ImGui.SameLine()
            ImGui.HelpMarker('The message displayed when the Buffer advertises its capabilities to the player.')
            if AdvertiseMessage ~= Settings.advertiseMessage then
                AdvertiseMessage = Settings.advertiseMessage
                SaveSettings(IniPath, Settings)
            end
            ImGui.Separator()

            if imgui.Button('REBUILD##Save File') then
                SaveSettings(iniPath, shadowknight.shadowknight_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return shadowknight
