---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local ranger = {}

local ranger_version = '1.0.0'

ranger.enrichment_Buffs = {
    "Arbor Stalker's Enrichment",
    "Wildstalker's Enrichment",
    "Copsestalker's Enrichment"
}
ranger.hp_Buffs = {
    'Dusksage Coat',
    'Obsidian Coat',
    'Blackscale',
    'Ravencoat',
    'Shadowscale',
    'Shadowcoat',
    'Mottlecoat',
    'Mottlescale',
    'Ravenscale',
    'Obsidian Skin',
    'Onyx Skin',
    'Natureskin',
    'Skin like Nature',
    'Skin like Diamond',
    'Skin like Steel',
    'Skin like Rock',
    'Skin like Wood'
}

ranger.ac_Buffs = {
    'Cloak of Bloodbarbs',
    'Shared Cloak of Rimespurs',
    'Cloak of Rimespurs',
    'Shared Cloak of Needlebarbs',
    'Cloak of Needlebarbs',
    'Cloak of Nettlespears',
    'Shared Cloak of Spurs',
    'Cloak of Spurs',
    'Shared Cloak of Burrs',
    'Cloak of Burrs',
    'Cloak of Quills',
    'Cloak of Feathers',
    'Cloak of Scales',
    'Guard of the Earth',
    'Call of the Rathe',
    'Call of Earth',
    'Force of Nature',
    "Riftwind's Protection"
}

ranger.ds_Buffs = {
    'Shield of Shadowthorns',
    'Shield of Rimespurs',
    'Shield of Needlebarbs',
    'Shield of Nettlespears',
    'Shield of Nettlespines',
    'Shield of Bramblespikes',
    'Shield of Nettlespikes',
    'Shield of Dryspines',
    'Shield of Spurs',
    'Shield of Needles',
    'Shield of Briar',
    'Shield of Thorns',
    'Shield of Spikes',
    'Spikecoat',
    'Shield of Thistles',
    'Thistlecoat'
}
ranger.attack_Buffs = {
    'Bay of the Predator',
    'Strength of the Dusksage Stalker',
    'Frostroar of the Predator',
    'Strength of the Arbor Stalker',
    'Protection of the Woodlands',
    'Strength of the Wildstalker',
    'Bellow of the Predator',
    'Strength of the Copsestalker',
    'Shout of the Predator',
    'Strength of the Bosquestalker',
    'Cry of the Predator',
    'Strength of the Gladetender',
    'Roar of the Predator',
    'Strength of the Thicket Stalker',
    'Yowl of the Predator',
    'Strength of the Tracker',
    'Gnarl of the Predator',
    'Strength of the Gladewalker',
    'Snarl of the Predator',
    'Strength of the Forest Stalker',
    'Howl of the Predator',
    'Strength of the Hunter',
    'Spirit of the Predator',
    'Strength of Tunare',
    'Call of the Predator',
    'Mark of the Predator',
    'Strength of Nature',
    'Force of Nature'
}
ranger.sow_Buffs = {
    'Spirit of Wolf',
    'Spirit of Falcons',
    'Spirit of Eagle',
    'Pact Shrew',
    'Spirit of the Shrew'
}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

ranger.ranger_settings = {
    runDebug = DEBUG,
    hpBuffs = ranger.hp_Buffs,
    dsBuffs = ranger.ds_Buffs,
    attackBuffs = ranger.attack_Buffs,
    sowBuffs = ranger.sow_Buffs,
    enrichmentBuffs = ranger.enrichment_Buffs,
    acBuffs = ranger.ac_Buffs,
    sow_1_45_current_idx = 1,
    sow_46_plus_current_idx = 1,
    buffs_1_45_Enabled = false,
    hp_buff_1_45_current_idx = 1,
    ds_buff_1_45_current_idx = 1,
    ac_buff_1_45_current_idx = 1,
    attack_buff_1_45_current_idx = 1,

    buffs_46_60_Enabled = false,
    hp_buff_46_60_current_idx = 1,
    ds_buff_46_60_current_idx = 1,
    ac_buff_46_60_current_idx = 1,
    attack_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    hp_buff_61_70_current_idx = 1,
    ds_buff_61_70_current_idx = 1,
    ac_buff_61_70_current_idx = 1,
    attack_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    hp_buff_71_84_current_idx = 1,
    ds_buff_71_84_current_idx = 1,
    ac_buff_71_84_current_idx = 1,
    attack_buff_71_84_current_idx = 1,
    enrichment_buff_75_current_idx = 1,

    buffs_85_plus_Enabled = false,
    hp_buff_85_plus_current_idx = 1,
    ds_buff_85_plus_current_idx = 1,
    ac_buff_85_plus_current_idx = 1,
    attack_buff_85_plus_current_idx = 1,
}

function ranger.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, ranger.ranger_settings)
end

function ranger.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        ranger.saveSettings()
    elseif configData then
        conf = configData()
        ranger.ranger_settings = conf
        ranger.hp_Buffs = ranger.ranger_settings.hpBuffs
        ranger.ds_Buffs = ranger.ranger_settings.dsBuffs
        ranger.attack_Buffs = ranger.ranger_settings.attackBuffs
        ranger.ac_Buffs = ranger.ranger_settings.acBuffs
    end
end

function ranger.MemorizeSpells()
    if ranger.ranger_settings.buffs_1_45_Enabled then
        Casting.MemSpell(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_1_45_current_idx], 1)
        Casting.MemSpell(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_1_45_current_idx], 2)
        Casting.MemSpell(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_1_45_current_idx], 3)
        Casting.MemSpell(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_1_45_current_idx], 3)
    end

    if ranger.ranger_settings.buffs_46_60_Enabled then
        Casting.MemSpell(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_46_60_current_idx], 4)
        Casting.MemSpell(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_46_60_current_idx], 5)
        Casting.MemSpell(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_46_60_current_idx], 6)
        Casting.MemSpell(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_46_60_current_idx], 3)
    end

    if ranger.ranger_settings.buffs_61_70_Enabled then
        Casting.MemSpell(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_61_70_current_idx], 7)
        Casting.MemSpell(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_61_70_current_idx], 8)
        Casting.MemSpell(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_61_70_current_idx], 9)
        Casting.MemSpell(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_61_70_current_idx], 3)
    end

    if ranger.ranger_settings.buffs_71_84_Enabled then
        Casting.MemSpell(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_71_84_current_idx], 11)
        Casting.MemSpell(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_71_84_current_idx], 12)
        Casting.MemSpell(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_71_84_current_idx], 13)
        Casting.MemSpell(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_71_84_current_idx], 3)
        Casting.MemSpell(ranger.ranger_settings.enrichmentBuffs[ranger.ranger_settings.enrichment_buff_75_current_idx],
            10)
    end

    if ranger.ranger_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_85_plus_current_idx], 14)
        Casting.MemSpell(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_85_plus_current_idx], 15)
        Casting.MemSpell(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_85_plus_current_idx], 3)
        Casting.MemSpell(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_85_plus_current_idx], 16)
    end
end

function ranger.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_1_45_current_idx], 'gem2')
        Casting.CastBuff(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_1_45_current_idx], 'gem3')
        Casting.CastBuff(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_1_45_current_idx], 'gem3')
        Casting.CastBuff(ranger.ranger_settings.sowBuffs[ranger.ranger_settings.sow_1_45_current_idx], 'gem4')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 then
        Casting.CastBuff(ranger.ranger_settings.sowBuffs[ranger.ranger_settings.sow_46_plus_current_idx], 'gem4')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_46_60_current_idx], 'gem4')
        Casting.CastBuff(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_46_60_current_idx], 'gem5')
        Casting.CastBuff(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_46_60_current_idx], 'gem6')
        Casting.CastBuff(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_46_60_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_61_70_current_idx], 'gem8')
        Casting.CastBuff(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_61_70_current_idx], 'gem9')
        Casting.CastBuff(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_61_70_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_71_84_current_idx], 'gem11')
        Casting.CastBuff(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_71_84_current_idx],
            'gem12')
        Casting.CastBuff(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_71_84_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 75 then
        Casting.CastBuff(ranger.ranger_settings.enrichmentBuffs[ranger.ranger_settings.enrichment_buff_75_current_idx],
            'gem12')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(ranger.ranger_settings.hpBuffs[ranger.ranger_settings.hp_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(ranger.ranger_settings.dsBuffs[ranger.ranger_settings.ds_buff_85_plus_current_idx], 'gem2')
        Casting.CastBuff(ranger.ranger_settings.attackBuffs[ranger.ranger_settings.attack_buff_85_plus_current_idx],
            'gem3')
        Casting.CastBuff(ranger.ranger_settings.acBuffs[ranger.ranger_settings.ac_buff_85_plus_current_idx], 'gem3')
    end
end

local sow_Enabled
local sow_1_45_current_idx
local sow_46_plus_current_idx
local buffs_1_45_Enabled
local hp_buff_1_45_current_idx
local ds_buff_1_45_current_idx
local ac_buff_1_45_current_idx
local attack_buff_1_45_current_idx

local buffs_46_60_Enabled
local hp_buff_46_60_current_idx
local ds_buff_46_60_current_idx
local ac_buff_46_60_current_idx
local attack_buff_46_60_current_idx

local buffs_61_70_Enabled
local hp_buff_61_70_current_idx
local ds_buff_61_70_current_idx
local ac_buff_61_70_current_idx
local attack_buff_61_70_current_idx
local enrichment_buff_75_current_idx

local buffs_71_84_Enabled
local hp_buff_71_84_current_idx
local ds_buff_71_84_current_idx
local ac_buff_71_84_current_idx
local attack_buff_71_84_current_idx

local buffs_85_plus_Enabled
local hp_buff_85_plus_current_idx
local ds_buff_85_plus_current_idx
local ac_buff_85_plus_current_idx
local attack_buff_85_plus_current_idx
function ranger.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Ranger v" .. ranger_version) then
        ImGui.Text("RANGER:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.Separator()

        --
        -- SoW
        --
        if ImGui.TreeNode('Spirit of Wolf:') then
            ImGui.SameLine()
            ranger.ranger_settings.sow_Enabled = ImGui.Checkbox('Enable', ranger.ranger_settings.sow_Enabled)
            if sow_Enabled ~= ranger.ranger_settings.sow_Enabled then
                sow_Enabled = ranger.ranger_settings.sow_Enabled
                ranger.saveSettings()
            end
            ImGui.Separator()

            ranger.ranger_settings.sow_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 SoW", ranger.sow_Buffs,
                ranger.ranger_settings.sow_1_45_current_idx);
            if sow_1_45_current_idx ~= ranger.ranger_settings.sow_1_45_current_idx then
                sow_1_45_current_idx = ranger.ranger_settings.sow_1_45_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.sow_46_plus_current_idx = GUI.CreateBuffBox:draw("46+ SoW", ranger.sow_Buffs,
                ranger.ranger_settings.sow_46_plus_current_idx);
            if sow_46_plus_current_idx ~= ranger.ranger_settings.sow_46_plus_current_idx then
                sow_46_plus_current_idx = ranger.ranger_settings.sow_46_plus_current_idx
                ranger.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            ranger.ranger_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                ranger.ranger_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= ranger.ranger_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = ranger.ranger_settings.buffs_1_45_Enabled
                ranger.saveSettings()
            end
            ImGui.Separator()


            ranger.ranger_settings.hp_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP", ranger.hp_Buffs,
                ranger.ranger_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= ranger.ranger_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = ranger.ranger_settings.hp_buff_1_45_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ds_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 DS", ranger.ds_Buffs,
                ranger.ranger_settings.ds_buff_1_45_current_idx);
            if ds_buff_1_45_current_idx ~= ranger.ranger_settings.ds_buff_1_45_current_idx then
                ds_buff_1_45_current_idx = ranger.ranger_settings.ds_buff_1_45_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.attack_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 ATTACK", ranger.attack_Buffs,
                ranger.ranger_settings.attack_buff_1_45_current_idx);
            if attack_buff_1_45_current_idx ~= ranger.ranger_settings.attack_buff_1_45_current_idx then
                attack_buff_1_45_current_idx = ranger.ranger_settings.attack_buff_1_45_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ac_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 AC", ranger.ac_Buffs,
                ranger.ranger_settings.ac_buff_1_45_current_idx);
            if ac_buff_1_45_current_idx ~= ranger.ranger_settings.ac_buff_1_45_current_idx then
                ac_buff_1_45_current_idx = ranger.ranger_settings.ac_buff_1_45_current_idx
                ranger.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            ranger.ranger_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                ranger.ranger_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= ranger.ranger_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = ranger.ranger_settings.buffs_46_60_Enabled
                ranger.saveSettings()
            end
            ImGui.Separator()

            ranger.ranger_settings.hp_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP", ranger.hp_Buffs,
                ranger.ranger_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= ranger.ranger_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = ranger.ranger_settings.hp_buff_46_60_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ds_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 DS", ranger.ds_Buffs,
                ranger.ranger_settings.ds_buff_46_60_current_idx);
            if ds_buff_46_60_current_idx ~= ranger.ranger_settings.ds_buff_46_60_current_idx then
                ds_buff_46_60_current_idx = ranger.ranger_settings.ds_buff_46_60_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.attack_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 ATTACK", ranger
                .attack_Buffs,
                ranger.ranger_settings.attack_buff_46_60_current_idx);
            if attack_buff_46_60_current_idx ~= ranger.ranger_settings.attack_buff_46_60_current_idx then
                attack_buff_46_60_current_idx = ranger.ranger_settings.attack_buff_46_60_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ac_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 AC", ranger.ac_Buffs,
                ranger.ranger_settings.ac_buff_46_60_current_idx);
            if ac_buff_46_60_current_idx ~= ranger.ranger_settings.ac_buff_46_60_current_idx then
                ac_buff_46_60_current_idx = ranger.ranger_settings.ac_buff_46_60_current_idx
                ranger.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            ranger.ranger_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                ranger.ranger_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= ranger.ranger_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = ranger.ranger_settings.buffs_61_70_Enabled
                ranger.saveSettings()
            end
            ImGui.Separator()

            ranger.ranger_settings.hp_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP", ranger.hp_Buffs,
                ranger.ranger_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= ranger.ranger_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = ranger.ranger_settings.hp_buff_61_70_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ds_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 DS", ranger.ds_Buffs,
                ranger.ranger_settings.ds_buff_61_70_current_idx);
            if ds_buff_61_70_current_idx ~= ranger.ranger_settings.ds_buff_61_70_current_idx then
                ds_buff_61_70_current_idx = ranger.ranger_settings.ds_buff_61_70_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.attack_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 ATTACK", ranger
                .attack_Buffs,
                ranger.ranger_settings.attack_buff_61_70_current_idx);
            if attack_buff_61_70_current_idx ~= ranger.ranger_settings.attack_buff_61_70_current_idx then
                attack_buff_61_70_current_idx = ranger.ranger_settings.attack_buff_61_70_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ac_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 AC", ranger.ac_Buffs,
                ranger.ranger_settings.ac_buff_61_70_current_idx);
            if ac_buff_61_70_current_idx ~= ranger.ranger_settings.ac_buff_61_70_current_idx then
                ac_buff_61_70_current_idx = ranger.ranger_settings.ac_buff_61_70_current_idx
                ranger.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            ranger.ranger_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                ranger.ranger_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= ranger.ranger_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = ranger.ranger_settings.buffs_71_84_Enabled
                ranger.saveSettings()
            end
            ImGui.Separator()

            ranger.ranger_settings.hp_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP", ranger.hp_Buffs,
                ranger.ranger_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= ranger.ranger_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = ranger.ranger_settings.hp_buff_71_84_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ds_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 DS", ranger.ds_Buffs,
                ranger.ranger_settings.ds_buff_71_84_current_idx);
            if ds_buff_71_84_current_idx ~= ranger.ranger_settings.ds_buff_71_84_current_idx then
                ds_buff_71_84_current_idx = ranger.ranger_settings.ds_buff_71_84_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.attack_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 ATTACK", ranger
                .attack_Buffs,
                ranger.ranger_settings.attack_buff_71_84_current_idx);
            if attack_buff_71_84_current_idx ~= ranger.ranger_settings.attack_buff_71_84_current_idx then
                attack_buff_71_84_current_idx = ranger.ranger_settings.attack_buff_71_84_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ac_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 AC", ranger.ac_Buffs,
                ranger.ranger_settings.ac_buff_71_84_current_idx);
            if ac_buff_71_84_current_idx ~= ranger.ranger_settings.ac_buff_71_84_current_idx then
                ac_buff_71_84_current_idx = ranger.ranger_settings.ac_buff_71_84_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.enrichment_buff_75_current_idx = GUI.CreateBuffBox:draw("75+ Enrichment",
                ranger.enrichment_Buffs,
                ranger.ranger_settings.enrichment_buff_75_current_idx);
            if enrichment_buff_75_current_idx ~= ranger.ranger_settings.enrichment_buff_75_current_idx then
                enrichment_buff_75_current_idx = ranger.ranger_settings.enrichment_buff_75_current_idx
                ranger.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            ranger.ranger_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                ranger.ranger_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= ranger.ranger_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = ranger.ranger_settings.buffs_85_plus_Enabled
                ranger.saveSettings()
            end
            ImGui.Separator()

            ranger.ranger_settings.hp_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP", ranger.hp_Buffs,
                ranger.ranger_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= ranger.ranger_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = ranger.ranger_settings.hp_buff_85_plus_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ds_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ DS", ranger.ds_Buffs,
                ranger.ranger_settings.ds_buff_85_plus_current_idx);
            if ds_buff_85_plus_current_idx ~= ranger.ranger_settings.ds_buff_85_plus_current_idx then
                ds_buff_85_plus_current_idx = ranger.ranger_settings.ds_buff_85_plus_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.ac_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ AC", ranger.ac_Buffs,
                ranger.ranger_settings.ac_buff_85_plus_current_idx);
            if ac_buff_85_plus_current_idx ~= ranger.ranger_settings.ac_buff_85_plus_current_idx then
                ac_buff_85_plus_current_idx = ranger.ranger_settings.ac_buff_85_plus_current_idx
                ranger.saveSettings()
            end

            ranger.ranger_settings.attack_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ ATTACK", ranger
                .attack_Buffs,
                ranger.ranger_settings.attack_buff_85_plus_current_idx);
            if attack_buff_85_plus_current_idx ~= ranger.ranger_settings.attack_buff_85_plus_current_idx then
                attack_buff_85_plus_current_idx = ranger.ranger_settings.attack_buff_85_plus_current_idx
                ranger.saveSettings()
            end
            imgui.TreePop()
        end
        --
        -- Help
        --
        if imgui.CollapsingHeader("Ranger Options") then
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
                SaveSettings(iniPath, ranger.ranger_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return ranger
