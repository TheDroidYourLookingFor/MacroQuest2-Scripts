---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local enchanter = {}
enchanter.version = '1.0.0'

enchanter.haste_Buffs = {
    'Hastening of Margator',
    'Speed of Margator',
    'Hastening of Jharin',
    'Speed of Itzal',
    'Hastening of Cekenar',
    'Speed of Cekenar',
    'Hastening of Milyex',
    'Speed of Milyex',
    'Hastening of Prokev',
    'Speed of Prokev',
    'Hastening of Sviir',
    'Speed of Sviir',
    'Hastening of Aransir',
    'Speed of Aransir',
    'Hastening of Novak',
    'Speed of Novak',
    'Hastening of Erradien',
    'Speed of Erradien',
    'Hastening of Ellowind',
    'Speed of Ellowind',
    'Hastening of Salik',
    'Speed of Salik',
    'Vallon\'s Quickening',
    'Speed of Vallon',
    'Speed of the Brood',
    'Visions of Grandeur',
    'Wondrous Rapidity',
    'Augment',
    'Aanya\'s Quickening',
    'Swift Like the Wind',
    'Celerity',
    'Augmentation',
    'Alacrity',
    'Quickness'
}
enchanter.clarity_Buffs = {
    'Voice of Preordination',
    'Preordination',
    'Voice of Perception',
    'Scrying Visions',
    'Voice of Sagacity',
    'Sagacity',
    'Voice of Perspicacity',
    'Perspicacity',
    'Voice of Precognition',
    'Precognition',
    'Voice of Foresight',
    'Foresight',
    'Voice of Premeditation',
    'Premeditation',
    'Voice of Forethought',
    'Forethought',
    'Voice of Prescience',
    'Prescience',
    'Voice of Cognizance',
    'Seer\'s Cognizance',
    'Voice of Intuition',
    'Seer\'s Intuition',
    'Voice of Clairvoyance',
    'Clairvoyance',
    'Voice of Quellious',
    'Tranquility',
    'Koadic\'s Endless Intellect',
    'Gift of Pure Thought',
    'Clarity II',
    'Boon of the Clear Mind',
    'Clarity',
    'Breeze'
}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

enchanter.enchanter_settings = {
    version = enchanter.version,
    runDebug = DEBUG,
    hasteBuffs = enchanter.haste_Buffs,
    clarityBuffs = enchanter.clarity_Buffs,

    buffs_1_45_Enabled = false,
    haste_buff_1_45_current_idx = 1,
    clarity_buff_1_45_current_idx = 1,

    buffs_46_60_Enabled = false,
    haste_buff_46_60_current_idx = 1,
    clarity_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    haste_buff_61_70_current_idx = 1,
    clarity_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    haste_buff_71_84_current_idx = 1,
    clarity_buff_71_84_current_idx = 1,

    buffs_85_plus_Enabled = false,
    haste_buff_85_plus_current_idx = 1,
    clarity_buff_85_plus_current_idx = 1
}

function enchanter.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, enchanter.enchanter_settings)
end

function enchanter.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        enchanter.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= enchanter.version then
            enchanter.saveSettings()
            enchanter.Setup()
        else
            enchanter.enchanter_settings = conf
            enchanter.clarity_Buffs = enchanter.enchanter_settings.clarityBuffs
            enchanter.haste_Buffs = enchanter.enchanter_settings.hasteBuffs
        end
    end
end

function enchanter.MemorizeSpells()
    if enchanter.enchanter_settings.buffs_1_45_Enabled then
        Casting.MemSpell(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_1_45_current_idx], 1)
        Casting.MemSpell(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_1_45_current_idx], 2)
    end

    if enchanter.enchanter_settings.buffs_46_60_Enabled then
        Casting.MemSpell(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_46_60_current_idx], 1)
        Casting.MemSpell(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_46_60_current_idx], 2)
    end

    if enchanter.enchanter_settings.buffs_61_70_Enabled then
        Casting.MemSpell(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_61_70_current_idx], 1)
        Casting.MemSpell(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_61_70_current_idx], 2)
    end

    if enchanter.enchanter_settings.buffs_71_84_Enabled then
        Casting.MemSpell(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_71_84_current_idx], 1)
        Casting.MemSpell(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_71_84_current_idx], 2)
    end

    if enchanter.enchanter_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_85_plus_current_idx], 1)
        Casting.MemSpell(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_85_plus_current_idx], 2)
    end
end

function enchanter.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_1_45_current_idx], 'gem2')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_46_60_current_idx], 'gem4')
        Casting.CastBuff(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_46_60_current_idx], 'gem5')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_61_70_current_idx], 'gem8')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_71_84_current_idx], 'gem11')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(
        enchanter.enchanter_settings.hasteBuffs[enchanter.enchanter_settings.haste_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(
        enchanter.enchanter_settings.clarityBuffs[enchanter.enchanter_settings.clarity_buff_85_plus_current_idx], 'gem2')
    end
end

local buffs_1_45_Enabled
local haste_buff_1_45_current_idx
local clarity_buff_1_45_current_idx

local buffs_46_60_Enabled
local haste_buff_46_60_current_idx
local clarity_buff_46_60_current_idx

local buffs_61_70_Enabled
local haste_buff_61_70_current_idx
local clarity_buff_61_70_current_idx

local buffs_71_84_Enabled
local haste_buff_71_84_current_idx
local clarity_buff_71_84_current_idx

local buffs_85_plus_Enabled
local haste_buff_85_plus_current_idx
local clarity_buff_85_plus_current_idx
function enchanter.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Enchanter v" .. enchanter.version) then
        ImGui.Text("ENCHANTER:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.Separator()
        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            enchanter.enchanter_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                enchanter.enchanter_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= enchanter.enchanter_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = enchanter.enchanter_settings.buffs_1_45_Enabled
                enchanter.saveSettings()
            end
            ImGui.Separator()


            enchanter.enchanter_settings.haste_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HASTE",
                enchanter.haste_Buffs,
                enchanter.enchanter_settings.haste_buff_1_45_current_idx);
            if haste_buff_1_45_current_idx ~= enchanter.enchanter_settings.haste_buff_1_45_current_idx then
                haste_buff_1_45_current_idx = enchanter.enchanter_settings.haste_buff_1_45_current_idx
                enchanter.saveSettings()
            end

            enchanter.enchanter_settings.clarity_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 CLARITY",
                enchanter.clarity_Buffs,
                enchanter.enchanter_settings.clarity_buff_1_45_current_idx);
            if clarity_buff_1_45_current_idx ~= enchanter.enchanter_settings.clarity_buff_1_45_current_idx then
                clarity_buff_1_45_current_idx = enchanter.enchanter_settings.clarity_buff_1_45_current_idx
                enchanter.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            enchanter.enchanter_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                enchanter.enchanter_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= enchanter.enchanter_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = enchanter.enchanter_settings.buffs_46_60_Enabled
                enchanter.saveSettings()
            end
            ImGui.Separator()

            enchanter.enchanter_settings.haste_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HASTE",
                enchanter.haste_Buffs,
                enchanter.enchanter_settings.haste_buff_46_60_current_idx);
            if haste_buff_46_60_current_idx ~= enchanter.enchanter_settings.haste_buff_46_60_current_idx then
                haste_buff_46_60_current_idx = enchanter.enchanter_settings.haste_buff_46_60_current_idx
                enchanter.saveSettings()
            end

            enchanter.enchanter_settings.clarity_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 CLARITY",
                enchanter.clarity_Buffs,
                enchanter.enchanter_settings.clarity_buff_46_60_current_idx);
            if clarity_buff_46_60_current_idx ~= enchanter.enchanter_settings.clarity_buff_46_60_current_idx then
                clarity_buff_46_60_current_idx = enchanter.enchanter_settings.clarity_buff_46_60_current_idx
                enchanter.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            enchanter.enchanter_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                enchanter.enchanter_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= enchanter.enchanter_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = enchanter.enchanter_settings.buffs_61_70_Enabled
                enchanter.saveSettings()
            end
            ImGui.Separator()

            enchanter.enchanter_settings.haste_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HASTE",
                enchanter.haste_Buffs,
                enchanter.enchanter_settings.haste_buff_61_70_current_idx);
            if haste_buff_61_70_current_idx ~= enchanter.enchanter_settings.haste_buff_61_70_current_idx then
                haste_buff_61_70_current_idx = enchanter.enchanter_settings.haste_buff_61_70_current_idx
                enchanter.saveSettings()
            end

            enchanter.enchanter_settings.clarity_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 CLARITY",
                enchanter.clarity_Buffs,
                enchanter.enchanter_settings.clarity_buff_61_70_current_idx);
            if clarity_buff_61_70_current_idx ~= enchanter.enchanter_settings.clarity_buff_61_70_current_idx then
                clarity_buff_61_70_current_idx = enchanter.enchanter_settings.clarity_buff_61_70_current_idx
                enchanter.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            enchanter.enchanter_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                enchanter.enchanter_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= enchanter.enchanter_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = enchanter.enchanter_settings.buffs_71_84_Enabled
                enchanter.saveSettings()
            end
            ImGui.Separator()

            enchanter.enchanter_settings.haste_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HASTE",
                enchanter.haste_Buffs,
                enchanter.enchanter_settings.haste_buff_71_84_current_idx);
            if haste_buff_71_84_current_idx ~= enchanter.enchanter_settings.haste_buff_71_84_current_idx then
                haste_buff_71_84_current_idx = enchanter.enchanter_settings.haste_buff_71_84_current_idx
                enchanter.saveSettings()
            end

            enchanter.enchanter_settings.clarity_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 CLARITY",
                enchanter.clarity_Buffs,
                enchanter.enchanter_settings.clarity_buff_71_84_current_idx);
            if clarity_buff_71_84_current_idx ~= enchanter.enchanter_settings.clarity_buff_71_84_current_idx then
                clarity_buff_71_84_current_idx = enchanter.enchanter_settings.clarity_buff_71_84_current_idx
                enchanter.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            enchanter.enchanter_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                enchanter.enchanter_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= enchanter.enchanter_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = enchanter.enchanter_settings.buffs_85_plus_Enabled
                enchanter.saveSettings()
            end
            ImGui.Separator()

            enchanter.enchanter_settings.haste_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HASTE",
                enchanter.haste_Buffs,
                enchanter.enchanter_settings.haste_buff_85_plus_current_idx);
            if haste_buff_85_plus_current_idx ~= enchanter.enchanter_settings.haste_buff_85_plus_current_idx then
                haste_buff_85_plus_current_idx = enchanter.enchanter_settings.haste_buff_85_plus_current_idx
                enchanter.saveSettings()
            end

            enchanter.enchanter_settings.clarity_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ CLARITY",
                enchanter.clarity_Buffs,
                enchanter.enchanter_settings.clarity_buff_85_plus_current_idx);
            if clarity_buff_85_plus_current_idx ~= enchanter.enchanter_settings.clarity_buff_85_plus_current_idx then
                clarity_buff_85_plus_current_idx = enchanter.enchanter_settings.clarity_buff_85_plus_current_idx
                enchanter.saveSettings()
            end
            imgui.TreePop()
        end

        --
        -- Help
        --
        if imgui.CollapsingHeader("Enchanter Options") then
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
                SaveSettings(iniPath, enchanter.enchanter_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return enchanter
