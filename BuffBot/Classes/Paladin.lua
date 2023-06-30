---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local paladin = {}

local paladin_version = '1.0.0'

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

paladin.rez_Spell = {
    'Resurrection',
    'Restoration',
    'Renewal',
    'Revive',
    'Reparation',
    'Reconstitution'
}

paladin.hp_Buffs = {
    'Hand of the Dreaming Keeper',
    'Shadewell Keeper',
    'Hand of the Stormwall Keeper',
    'Stormwall Keeper',
    'Hand of the Ashbound Keeper',
    'Ashbound Keeper',
    'Hand of the Stormbound Keeper',
    'Stormbound Keeper',
    'Hand of the Pledged Keeper',
    'Pledged Keeper',
    'Hand of the Avowed Keeper',
    'Avowed Keeper',
    'Oathbound Keeper',
    'Sworn Keeper',
    'Oathbound Protector',
    'Sworn Protector',
    'Affirmation',
    'Hand of Direction',
    'Direction',
    'Guidance',
    'Heroic Bond',
    'Heroism',
    'Resolution',
    'Blessing of Austerity',
    'Austerity',
    'Valor',
    'Daring',
    'Center',
    'Courage'
}

paladin.hp_v2_Buffs = {
    'Brell\'s Tenacious Barrier',
    'Brell\'s Blessed Barrier',
    'Brell\'s Blessed Bastion',
    'Brell\'s Stalwart Bulwark',
    'Brell\'s Steadfast Bulwark',
    'Brell\'s Tellurian Rampart',
    'Brell\'s Loamy Ward',
    'Brell\'s Earthen Aegis',
    'Brell\'s Stony Guard',
    'Brell\'s Brawny Bulwark',
    'Brell\'s Stalwart Shield',
    'Brell\'s Mountainous Barrier',
    'Divine Strength',
    'Divine Glory',
    'Brell\'s Steadfast Aegis',
    'Divine Vigor'
}

paladin.paladin_settings = {
    runDebug = DEBUG,
    rezSpell = paladin.rez_Spell,
    hpSpells = paladin.hp_Buffs,
    hpv2Spells = paladin.hp_v2_Buffs,

    rezEnabled = false,
    rez_current_idx = 1,

    buffs_1_45_Enabled = false,
    hp_buff_1_45_current_idx = 1,
    hp_v2_buff_1_45_current_idx = 1,

    buffs_46_60_Enabled = false,
    hp_buff_46_60_current_idx = 1,
    hp_v2_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    hp_buff_61_70_current_idx = 1,
    hp_v2_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    hp_buff_71_84_current_idx = 1,
    hp_v2_buff_71_84_current_idx = 1,

    buffs_85_plus_Enabled = false,
    hp_buff_85_plus_current_idx = 1,
    hp_v2_buff_85_plus_current_idx = 1
}

function paladin.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, paladin.paladin_settings)
end

function paladin.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        paladin.saveSettings()
    elseif configData then
        conf = configData()
        paladin.paladin_settings = conf
    end
end

function paladin.MemorizeSpells()
end

function paladin.Buff()
end

local rez_Enabled
local rez_current_idx
local buffs_1_45_Enabled
local hp_buff_1_45_current_idx
local hp_v2_buff_1_45_current_idx

local buffs_46_60_Enabled
local hp_buff_46_60_current_idx
local hp_v2_buff_46_60_current_idx

local buffs_61_70_Enabled
local hp_buff_61_70_current_idx
local hp_v2_buff_61_70_current_idx

local buffs_71_84_Enabled
local hp_buff_71_84_current_idx
local hp_v2_buff_71_84_current_idx

local buffs_85_plus_Enabled
local hp_buff_85_plus_current_idx
local hp_v2_buff_85_plus_current_idx

function paladin.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Paladin v" .. paladin_version) then
        ImGui.Text("PALADIN");
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.BulletText("Paladin: Will resurrect a player when it hears \"rez\"")
        ImGui.Separator();

        --
        -- Rez
        --
        if ImGui.TreeNode('Resurrect:') then
            ImGui.SameLine()
            paladin.paladin_settings.rez_Enabled = ImGui.Checkbox('Enable', paladin.paladin_settings.rez_Enabled)
            if rez_Enabled ~= paladin.paladin_settings.rez_Enabled then
                rez_Enabled = paladin.paladin_settings.rez_Enabled
                paladin.saveSettings()
            end
            ImGui.Separator()


            paladin.paladin_settings.rez_current_idx = GUI.CreateBuffBox:draw("Res Spell", paladin.rez_Spell,
                paladin.paladin_settings.rez_current_idx);
            if rez_current_idx ~= paladin.paladin_settings.rez_current_idx then
                rez_current_idx = paladin.paladin_settings.rez_current_idx
                paladin.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            paladin.paladin_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                paladin.paladin_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= paladin.paladin_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = paladin.paladin_settings.buffs_1_45_Enabled
                paladin.saveSettings()
            end
            ImGui.Separator()


            paladin.paladin_settings.hp_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP", paladin.hp_Buffs,
                paladin.paladin_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= paladin.paladin_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = paladin.paladin_settings.hp_buff_1_45_current_idx
                paladin.saveSettings()
            end

            paladin.paladin_settings.hp_v2_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP V2",
                paladin.hp_v2_Buffs,
                paladin.paladin_settings.hp_v2_buff_1_45_current_idx);
            if hp_v2_buff_1_45_current_idx ~= paladin.paladin_settings.hp_v2_buff_1_45_current_idx then
                hp_v2_buff_1_45_current_idx = paladin.paladin_settings.hp_v2_buff_1_45_current_idx
                paladin.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            paladin.paladin_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                paladin.paladin_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= paladin.paladin_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = paladin.paladin_settings.buffs_46_60_Enabled
                paladin.saveSettings()
            end
            ImGui.Separator()

            paladin.paladin_settings.hp_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP", paladin.hp_Buffs,
                paladin.paladin_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= paladin.paladin_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = paladin.paladin_settings.hp_buff_46_60_current_idx
                paladin.saveSettings()
            end

            paladin.paladin_settings.hp_v2_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP V2",
                paladin.hp_v2_Buffs,
                paladin.paladin_settings.hp_v2_buff_46_60_current_idx);
            if hp_v2_buff_46_60_current_idx ~= paladin.paladin_settings.hp_v2_buff_46_60_current_idx then
                hp_v2_buff_46_60_current_idx = paladin.paladin_settings.hp_v2_buff_46_60_current_idx
                paladin.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            paladin.paladin_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                paladin.paladin_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= paladin.paladin_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = paladin.paladin_settings.buffs_61_70_Enabled
                paladin.saveSettings()
            end
            ImGui.Separator()

            paladin.paladin_settings.hp_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP", paladin.hp_Buffs,
                paladin.paladin_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= paladin.paladin_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = paladin.paladin_settings.hp_buff_61_70_current_idx
                paladin.saveSettings()
            end

            paladin.paladin_settings.hp_v2_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP V2",
                paladin.hp_v2_Buffs,
                paladin.paladin_settings.hp_v2_buff_61_70_current_idx);
            if hp_v2_buff_61_70_current_idx ~= paladin.paladin_settings.hp_v2_buff_61_70_current_idx then
                hp_v2_buff_61_70_current_idx = paladin.paladin_settings.hp_v2_buff_61_70_current_idx
                paladin.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            paladin.paladin_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                paladin.paladin_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= paladin.paladin_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = paladin.paladin_settings.buffs_71_84_Enabled
                paladin.saveSettings()
            end
            ImGui.Separator()

            paladin.paladin_settings.hp_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP", paladin.hp_Buffs,
                paladin.paladin_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= paladin.paladin_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = paladin.paladin_settings.hp_buff_71_84_current_idx
                paladin.saveSettings()
            end

            paladin.paladin_settings.hp_v2_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP V2", paladin.hp_v2_Buffs,
                paladin.paladin_settings.hp_v2_buff_71_84_current_idx);
            if hp_v2_buff_71_84_current_idx ~= paladin.paladin_settings.hp_v2_buff_71_84_current_idx then
                hp_v2_buff_71_84_current_idx = paladin.paladin_settings.hp_v2_buff_71_84_current_idx
                paladin.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            paladin.paladin_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                paladin.paladin_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= paladin.paladin_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = paladin.paladin_settings.buffs_85_plus_Enabled
                paladin.saveSettings()
            end
            ImGui.Separator()

            paladin.paladin_settings.hp_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP", paladin.hp_Buffs,
                paladin.paladin_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= paladin.paladin_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = paladin.paladin_settings.hp_buff_85_plus_current_idx
                paladin.saveSettings()
            end

            paladin.paladin_settings.hp_v2_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP V2",
                paladin.hp_v2_Buffs,
                paladin.paladin_settings.hp_v2_buff_85_plus_current_idx);
            if hp_v2_buff_85_plus_current_idx ~= paladin.paladin_settings.hp_v2_buff_85_plus_current_idx then
                hp_v2_buff_85_plus_current_idx = paladin.paladin_settings.hp_v2_buff_85_plus_current_idx
                paladin.saveSettings()
            end
            imgui.TreePop()
        end
        --
        -- Help
        --
        if imgui.CollapsingHeader("Paladin Options") then
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
                SaveSettings(iniPath, paladin.paladin_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return paladin
