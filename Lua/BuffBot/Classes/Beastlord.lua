---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local beastloard = {}
beastloard.version = '1.0.0'

beastloard.hp_Buffs = {
    'Focus of Jaegir',
    'Focus of Tobart',
    'Focus of Artikla',
    'Focus of Okasi',
    'Focus of Sanera',
    'Focus of Klar',
    'Focus of Emiq',
    'Focus of Yemall',
    'Focus of Zott',
    'Focus of Amilan',
    'Focus of Alladnu',
    'Talisman of Kragg',
    'Talisman of Altuna',
    'Talisman of Tnarg',
    'Inner Fire'
}
beastloard.mana_Buffs = {
    'Spiritual Erudition',
    'Spiritual Insight',
    'Spiritual Empowerment',
    'Spiritual Elaboration',
    'Spiritual Evolution',
    'Spiritual Enrichment',
    'Spiritual Enhancement',
    'Spiritual Edification',
    'Spiritual Epiphany',
    'Spiritual Enlightenment',
    'Spiritual Ascendance',
    'Spiritual Dominion',
    'Spiritual Purity',
    'Spiritual Radiance',
    'Spiritual Light'
}
beastloard.attack_Buffs = {
    'Spiritual Vigor',
    'Spiritual Vehemence',
    'Spiritual Vibrancy',
    'Spiritual Vivification',
    'Spiritual Vindication',
    'Spiritual Valiance',
    'Spiritual Valor',
    'Spiritual Verve',
    'Spiritual Vivacity',
    'Spiritual Vim',
    'Spiritual Vitality',
    'Spiritual Vigor',
    'Spiritual Strength',
    'Spiritual Brawn'
}
beastloard.attack_v2_Buffs = {
    'Shared Merciless Ferocity',
    'Merciless Ferocity',
    'Shared Brutal Ferocity',
    'Brutal Ferocity',
    'Callous Ferocity',
    'Savage Ferocity',
    'Vicious Ferocity',
    'Ruthless Ferocity',
    'Ferocity of Irionu',
    'Ferocity',
    'Savagery'
}
local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

beastloard.beastloard_settings = {
    version = beastloard.version,
    runDebug = DEBUG,
    hpBuffs = beastloard.hp_Buffs,
    manaBuffs = beastloard.mana_Buffs,
    attackBuffs = beastloard.attack_Buffs,
    attackv2Buffs = beastloard.attack_v2_Buffs,

    buffs_1_45_Enabled = false,
    hp_buff_1_45_current_idx = 1,
    attack_buff_1_45_current_idx = 1,
    mana_buff_1_45_current_idx = 1,
    attackv2_buff_1_45_current_idx = 1,

    buffs_46_60_Enabled = false,
    hp_buff_46_60_current_idx = 1,
    attack_buff_46_60_current_idx = 1,
    mana_buff_46_60_current_idx = 1,
    attackv2_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    _buff_61_70_current_idx = 1,
    attack_buff_61_70_current_idx = 1,
    mana_buff_61_70_current_idx = 1,
    attackv2_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    hp_buff_71_84_current_idx = 1,
    attack_buff_71_84_current_idx = 1,
    mana_buff_71_84_current_idx = 1,
    attackv2_buff_71_84_current_idx = 1,

    buffs_85_plus_Enabled = false,
    hp_buff_85_plus_current_idx = 1,
    attack_buff_85_plus_current_idx = 1,
    mana_buff_85_plus_current_idx = 1,
    attackv2_buff_85_plus_current_idx = 1
}

function beastloard.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, beastloard.beastloard_settings)
end

function beastloard.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        beastloard.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= beastloard.version then
            beastloard.saveSettings()
            beastloard.Setup()
        else
            beastloard.beastloard_settings = conf
            beastloard.attack_Buffs = beastloard.beastloard_settings.attackBuffs
            beastloard.hp_Buffs = beastloard.beastloard_settings.hpBuffs
        end
    end
end

function beastloard.MemorizeSpells()
    if beastloard.beastloard_settings.buffs_1_45_Enabled then
        Casting.MemSpell(beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_1_45_current_idx],
            1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_1_45_current_idx], 2)
        Casting.MemSpell(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_1_45_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_1_45_current_idx], 2)
    end

    if beastloard.beastloard_settings.buffs_46_60_Enabled then
        Casting.MemSpell(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_46_60_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_46_60_current_idx], 2)
        Casting.MemSpell(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_46_60_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_46_60_current_idx], 2)
    end

    if beastloard.beastloard_settings.buffs_61_70_Enabled then
        Casting.MemSpell(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_61_70_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_61_70_current_idx], 2)
        Casting.MemSpell(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_61_70_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_61_70_current_idx], 2)
    end

    if beastloard.beastloard_settings.buffs_71_84_Enabled then
        Casting.MemSpell(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_71_84_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_71_84_current_idx], 2)
        Casting.MemSpell(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_71_84_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_71_84_current_idx], 2)
    end

    if beastloard.beastloard_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_85_plus_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_85_plus_current_idx], 2)
        Casting.MemSpell(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_85_plus_current_idx], 1)
        Casting.MemSpell(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_85_plus_current_idx], 2)
    end
end

function beastloard.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_1_45_current_idx],
            'gem1')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_1_45_current_idx], 'gem2')
        Casting.CastBuff(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_1_45_current_idx], 'gem3')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_1_45_current_idx],
            'gem4')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_46_60_current_idx], 'gem5')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_46_60_current_idx], 'gem6')
        Casting.CastBuff(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_46_60_current_idx], 'gem7')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_46_60_current_idx],
            'gem8')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_61_70_current_idx], 'gem9')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_61_70_current_idx], 'gem10')
        Casting.CastBuff(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_61_70_current_idx], 'gem11')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_61_70_current_idx],
            'gem12')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_71_84_current_idx], 'gem11')
        Casting.CastBuff(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_71_84_current_idx], 'gem3')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_71_84_current_idx],
            'gem4')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(
        beastloard.beastloard_settings.hpBuffs[beastloard.beastloard_settings.hp_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackBuffs[beastloard.beastloard_settings.attack_buff_85_plus_current_idx],
            'gem2')
        Casting.CastBuff(
        beastloard.beastloard_settings.manaBuffs[beastloard.beastloard_settings.mana_buff_85_plus_current_idx], 'gem3')
        Casting.CastBuff(
        beastloard.beastloard_settings.attackv2Buffs[beastloard.beastloard_settings.attackv2_buff_85_plus_current_idx],
            'gem4')
    end
end

local buffs_1_45_Enabled
local hp_buff_1_45_current_idx
local attack_buff_1_45_current_idx
local mana_buff_1_45_current_idx
local attackv2_buff_1_45_current_idx

local buffs_46_60_Enabled
local hp_buff_46_60_current_idx
local attack_buff_46_60_current_idx
local mana_buff_46_60_current_idx
local attackv2_buff_46_60_current_idx

local buffs_61_70_Enabled
local hp_buff_61_70_current_idx
local attack_buff_61_70_current_idx
local mana_buff_61_70_current_idx
local attackv2_buff_61_70_current_idx

local buffs_71_84_Enabled
local hp_buff_71_84_current_idx
local attack_buff_71_84_current_idx
local mana_buff_71_84_current_idx
local attackv2_buff_71_84_current_idx

local buffs_85_plus_Enabled
local hp_buff_85_plus_current_idx
local attack_buff_85_plus_current_idx
local mana_buff_85_plus_current_idx
local attackv2_buff_85_plus_current_idx
function beastloard.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Beastloard v" .. beastloard.version) then
        ImGui.Text("BEASTLORD:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.Separator()
        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            beastloard.beastloard_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                beastloard.beastloard_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= beastloard.beastloard_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = beastloard.beastloard_settings.buffs_1_45_Enabled
                beastloard.saveSettings()
            end
            ImGui.Separator()

            beastloard.beastloard_settings.hp_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP",
                beastloard.hp_Buffs,
                beastloard.beastloard_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= beastloard.beastloard_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = beastloard.beastloard_settings.hp_buff_1_45_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attack_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 ATTACK",
                beastloard.attack_Buffs,
                beastloard.beastloard_settings.attack_buff_1_45_current_idx);
            if attack_buff_1_45_current_idx ~= beastloard.beastloard_settings.attack_buff_1_45_current_idx then
                attack_buff_1_45_current_idx = beastloard.beastloard_settings.attack_buff_1_45_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.mana_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 MANA",
                beastloard.mana_Buffs,
                beastloard.beastloard_settings.mana_buff_1_45_current_idx);
            if mana_buff_1_45_current_idx ~= beastloard.beastloard_settings.mana_buff_1_45_current_idx then
                mana_buff_1_45_current_idx = beastloard.beastloard_settings.mana_buff_1_45_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attackv2_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 ATTACKv2",
                beastloard.attack_v2_Buffs,
                beastloard.beastloard_settings.attackv2_buff_1_45_current_idx);
            if attackv2_buff_1_45_current_idx ~= beastloard.beastloard_settings.attackv2_buff_1_45_current_idx then
                attackv2_buff_1_45_current_idx = beastloard.beastloard_settings.attackv2_buff_1_45_current_idx
                beastloard.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            beastloard.beastloard_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                beastloard.beastloard_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= beastloard.beastloard_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = beastloard.beastloard_settings.buffs_46_60_Enabled
                beastloard.saveSettings()
            end
            ImGui.Separator()

            beastloard.beastloard_settings.hp_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP",
                beastloard.hp_Buffs,
                beastloard.beastloard_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= beastloard.beastloard_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = beastloard.beastloard_settings.hp_buff_46_60_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attack_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 ATTACK",
                beastloard.attack_Buffs,
                beastloard.beastloard_settings.attack_buff_46_60_current_idx);
            if attack_buff_46_60_current_idx ~= beastloard.beastloard_settings.attack_buff_46_60_current_idx then
                attack_buff_46_60_current_idx = beastloard.beastloard_settings.attack_buff_46_60_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.mana_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 MANA",
                beastloard.mana_Buffs,
                beastloard.beastloard_settings.mana_buff_46_60_current_idx);
            if mana_buff_46_60_current_idx ~= beastloard.beastloard_settings.mana_buff_46_60_current_idx then
                mana_buff_46_60_current_idx = beastloard.beastloard_settings.mana_buff_46_60_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attackv2_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 ATTACKv2",
                beastloard.attack_v2_Buffs,
                beastloard.beastloard_settings.attackv2_buff_46_60_current_idx);
            if attackv2_buff_46_60_current_idx ~= beastloard.beastloard_settings.attackv2_buff_46_60_current_idx then
                attackv2_buff_46_60_current_idx = beastloard.beastloard_settings.attackv2_buff_46_60_current_idx
                beastloard.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            beastloard.beastloard_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                beastloard.beastloard_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= beastloard.beastloard_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = beastloard.beastloard_settings.buffs_61_70_Enabled
                beastloard.saveSettings()
            end
            ImGui.Separator()

            beastloard.beastloard_settings.hp_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP",
                beastloard.hp_Buffs,
                beastloard.beastloard_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= beastloard.beastloard_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = beastloard.beastloard_settings.hp_buff_61_70_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attack_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 ATTACK",
                beastloard.attack_Buffs,
                beastloard.beastloard_settings.attack_buff_61_70_current_idx);
            if attack_buff_61_70_current_idx ~= beastloard.beastloard_settings.attack_buff_61_70_current_idx then
                attack_buff_61_70_current_idx = beastloard.beastloard_settings.attack_buff_61_70_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.mana_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 MANA",
                beastloard.mana_Buffs,
                beastloard.beastloard_settings.mana_buff_61_70_current_idx);
            if mana_buff_61_70_current_idx ~= beastloard.beastloard_settings.mana_buff_61_70_current_idx then
                mana_buff_61_70_current_idx = beastloard.beastloard_settings.mana_buff_61_70_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attackv2_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 ATTACKv2",
                beastloard.attack_v2_Buffs,
                beastloard.beastloard_settings.attackv2_buff_61_70_current_idx);
            if attackv2_buff_61_70_current_idx ~= beastloard.beastloard_settings.attackv2_buff_61_70_current_idx then
                attackv2_buff_61_70_current_idx = beastloard.beastloard_settings.attackv2_buff_61_70_current_idx
                beastloard.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            beastloard.beastloard_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                beastloard.beastloard_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= beastloard.beastloard_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = beastloard.beastloard_settings.buffs_71_84_Enabled
                beastloard.saveSettings()
            end
            ImGui.Separator()

            beastloard.beastloard_settings.hp_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP",
                beastloard.hp_Buffs,
                beastloard.beastloard_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= beastloard.beastloard_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = beastloard.beastloard_settings.hp_buff_71_84_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attack_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 ATTACK",
                beastloard.attack_Buffs,
                beastloard.beastloard_settings.attack_buff_71_84_current_idx);
            if attack_buff_71_84_current_idx ~= beastloard.beastloard_settings.attack_buff_71_84_current_idx then
                attack_buff_71_84_current_idx = beastloard.beastloard_settings.attack_buff_71_84_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.mana_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 MANA",
                beastloard.mana_Buffs,
                beastloard.beastloard_settings.mana_buff_71_84_current_idx);
            if mana_buff_71_84_current_idx ~= beastloard.beastloard_settings.mana_buff_71_84_current_idx then
                mana_buff_71_84_current_idx = beastloard.beastloard_settings.mana_buff_71_84_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attackv2_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 ATTACKv2",
                beastloard.attack_v2_Buffs,
                beastloard.beastloard_settings.attackv2_buff_71_84_current_idx);
            if attackv2_buff_71_84_current_idx ~= beastloard.beastloard_settings.attackv2_buff_71_84_current_idx then
                attackv2_buff_71_84_current_idx = beastloard.beastloard_settings.attackv2_buff_71_84_current_idx
                beastloard.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            beastloard.beastloard_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                beastloard.beastloard_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= beastloard.beastloard_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = beastloard.beastloard_settings.buffs_85_plus_Enabled
                beastloard.saveSettings()
            end
            ImGui.Separator()

            beastloard.beastloard_settings.hp_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP",
                beastloard.hp_Buffs,
                beastloard.beastloard_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= beastloard.beastloard_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = beastloard.beastloard_settings.hp_buff_85_plus_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attack_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ ATTACK",
                beastloard.attack_Buffs,
                beastloard.beastloard_settings.attack_buff_85_plus_current_idx);
            if attack_buff_85_plus_current_idx ~= beastloard.beastloard_settings.attack_buff_85_plus_current_idx then
                attack_buff_85_plus_current_idx = beastloard.beastloard_settings.attack_buff_85_plus_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.mana_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ MANA",
                beastloard.mana_Buffs,
                beastloard.beastloard_settings.mana_buff_85_plus_current_idx);
            if mana_buff_85_plus_current_idx ~= beastloard.beastloard_settings.mana_buff_85_plus_current_idx then
                mana_buff_85_plus_current_idx = beastloard.beastloard_settings.mana_buff_85_plus_current_idx
                beastloard.saveSettings()
            end

            beastloard.beastloard_settings.attackv2_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ ATTACKv2",
                beastloard.attack_v2_Buffs,
                beastloard.beastloard_settings.attackv2_buff_85_plus_current_idx);
            if attackv2_buff_85_plus_current_idx ~= beastloard.beastloard_settings.attackv2_buff_85_plus_current_idx then
                attackv2_buff_85_plus_current_idx = beastloard.beastloard_settings.attackv2_buff_85_plus_current_idx
                beastloard.saveSettings()
            end
            imgui.TreePop()
        end

        --
        -- Help
        --
        if imgui.CollapsingHeader("Beastloard Options") then
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
                SaveSettings(iniPath, beastloard.beastloard_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return beastloard
