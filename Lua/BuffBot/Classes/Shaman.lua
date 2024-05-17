---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local shaman = {}
shaman.version = '1.0.0'

shaman.haste_Buffs = {
    'Talisman of Celerity',
    'Symbol of Celerity',
    'Swift Like the Wind',
    'Celerity',
    'Alacrity',
    'Quickness'
}
shaman.hp_Buffs = {
    'Talisman of the Usurper',
    'Unity of the Vampyre',
    'Vampyre Focusing',
    'Talisman of the Ry\'Gorr',
    'Unity of the Kromrif',
    'Kromrif Focusing',
    'Talisman of the Wulthan',
    'Unity of the Wulthan',
    'Wulthan Focusing',
    'Talisman of the Doomscale',
    'Unity of the Doomscale',
    'Doomscale Focusing',
    'Talisman of the Courageous',
    'Unity of the Courageous',
    'Insistent Focusing',
    'Talisman of Kolos\' Unity',
    'Unity of Kolos',
    'Imperative Focusing',
    'Talisman of Soul\'s Unity',
    'Unity of the Soul',
    'Exigent Focusing',
    'Talisman of Unity',
    'Unity of the Spirits',
    'Talisman of the Bloodworg',
    'Bloodworg Focusing',
    'Talisman of the Dire',
    'Dire Focusing',
    'Talisman of Wunshi',
    'Wunshi\'s Focusing',
    'Focus of the Seventh',
    'Focus of Soul',
    'Khura\'s Focusing',
    'Focus of Spirit',
    'Talisman of Kragg',
    'Harnessing of Spirit',
    'Talisman of Altuna',
    'Talisman of Tnarg',
    'Inner Fire'
}
shaman.regen_Buffs = {
    'Talisman of the Tenacious',
    'Spirit of the Tenacious',
    'Talisman of the Enduring',
    'Spirit of the Enduring',
    'Talisman of the Unwavering',
    'Spirit of the Unwavering',
    'Talisman of the Faithful',
    'Spirit of the Faithful',
    'Talisman of the Steadfast',
    'Spirit of the Steadfast',
    'Talisman of the Indomitable',
    'Spirit of the Indomitable',
    'Talisman of the Relentless',
    'Spirit of the Relentless',
    'Talisman of the Resolute',
    'Spirit of the Resolute',
    'Talisman of the Stalwart',
    'Spirit of the Stalwart',
    'Talisman of the Stoic One',
    'Spirit of the Stoic One',
    'Talisman of Perseverance',
    'Spirit of Perseverance',
    'Blessing of Replenishment',
    'Replenishment',
    'Regrowth of Dar Khura',
    'Regrowth',
    'Chloroplast',
    'Regeneration'
}
shaman.proc_Buffs = {
    'Melancholy',
    'Talisman of the Kerran',
    'Ennui',
    'Talisman of the Lioness',
    'Incapacity',
    'Talisman of the Sabretooth',
    'Sluggishness',
    'Talisman of the Leopard',
    'Fatigue',
    'Apathy',
    'Talisman of the Lion',
    'Lethargy',
    'Talisman of the Tiger',
    'Listlessness',
    'Talisman of the Lynx',
    'Languor',
    'Talisman of the Cougar',
    'Lassitude',
    'Talisman of the Panther',
    'Spirit of the Panther',
    'Lingering Sloth',
    'Spirit of the Leopard',
    'Spirit of the Jaguar',
    'Spirit of the Puma'
}
shaman.sow_Buffs = {
    'Spirit of Wolf',
    'Spirit of Tala`Tak',
    'Spirit of Bih`Li',
    'Spirit of the Shrew',
    'Pact Shrew'
}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

shaman.shaman_settings = {
    version = shaman.version,
    runDebug = DEBUG,
    hasteBuffs = shaman.haste_Buffs,
    hpBuffs = shaman.hp_Buffs,
    regenBuffs = shaman.regen_Buffs,
    sowBuffs = shaman.sow_Buffs,
    procBuffs = shaman.proc_Buffs,

    haste_Enabled = false,
    sow_Enabled = false,
    sow_1_45_current_idx = 1,
    sow_46_plus_current_idx = 1,
    buffs_1_45_Enabled = false,
    hp_buff_1_45_current_idx = 1,
    regen_buff_1_45_current_idx = 1,
    proc_buff_1_45_current_idx = 1,

    haste_1_45_current_idx = 1,
    haste_46_plus_current_idx = 1,

    buffs_46_60_Enabled = false,
    hp_buff_46_60_current_idx = 1,
    regen_buff_46_60_current_idx = 1,
    proc_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    hp_buff_61_70_current_idx = 1,
    regen_buff_61_70_current_idx = 1,
    proc_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    hp_buff_71_84_current_idx = 1,
    regen_buff_71_84_current_idx = 1,
    proc_buff_71_84_current_idx = 1,

    buffs_85_plus_Enabled = false,
    hp_buff_85_plus_current_idx = 1,
    regen_buff_85_plus_current_idx = 1,
    proc_buff_85_plus_current_idx = 1
}

function shaman.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, shaman.shaman_settings)
end

function shaman.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        shaman.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= shaman.version then
            shaman.saveSettings()
            shaman.Setup()
        else
            shaman.shaman_settings = conf
            shaman.hp_Buffs = shaman.shaman_settings.hpBuffs
            shaman.regen_Buffs = shaman.shaman_settings.regenBuffs
            shaman.haste_Buffs = shaman.shaman_settings.hasteBuffs
            shaman.sow_Buffs = shaman.shaman_settings.sowBuffs
            shaman.proc_Buffs = shaman.shaman_settings.procBuffs
        end
    end
end

function shaman.MemorizeSpells()
    if shaman.shaman_settings.buffs_1_45_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_1_45_current_idx], 1)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_1_45_current_idx], 2)
        Casting.MemSpell(shaman.shaman_settings.sowBuffs[shaman.shaman_settings.sow_1_45_current_idx], 6)
        Casting.MemSpell(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_1_45_current_idx], 6)
        Casting.MemSpell(shaman.shaman_settings.hasteBuffs[shaman.shaman_settings.haste_buff_1_45_current_idx], 3)
    end

    if shaman.shaman_settings.buffs_46_60_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_46_60_current_idx], 4)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_46_60_current_idx], 5)
        Casting.MemSpell(shaman.shaman_settings.sowBuffs[shaman.shaman_settings.sow_46_plus_current_idx], 6)
        Casting.MemSpell(shaman.shaman_settings.hasteBuffs[shaman.shaman_settings.haste_46_plus_current_idx], 7)
        Casting.MemSpell(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_46_60_current_idx], 8)
    end

    if shaman.shaman_settings.buffs_61_70_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_61_70_current_idx], 7)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_61_70_current_idx], 8)
        Casting.MemSpell(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_61_70_current_idx], 7)
    end

    if shaman.shaman_settings.buffs_71_84_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_71_84_current_idx], 11)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_71_84_current_idx], 12)
        Casting.MemSpell(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_71_84_current_idx], 6)
    end

    if shaman.shaman_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_85_plus_current_idx], 14)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_85_plus_current_idx], 15)
        Casting.MemSpell(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_85_plus_current_idx], 6)
    end
end

function shaman.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_1_45_current_idx], 'gem2')
        Casting.CastBuff(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_1_45_current_idx], 'gem3')
        Casting.CastBuff(shaman.shaman_settings.sowBuffs[shaman.shaman_settings.sow_1_45_current_idx], 'gem4')
        Casting.CastBuff(shaman.shaman_settings.hasteBuffs[shaman.shaman_settings.haste_1_45_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 then
        Casting.CastBuff(shaman.shaman_settings.sowBuffs[shaman.shaman_settings.sow_46_plus_current_idx], 'gem4')
        Casting.CastBuff(shaman.shaman_settings.hasteBuffs[shaman.shaman_settings.haste_46_plus_current_idx], 'gem5')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_46_60_current_idx], 'gem4')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_46_60_current_idx], 'gem5')
        Casting.CastBuff(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_46_60_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_61_70_current_idx], 'gem8')
        Casting.CastBuff(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_61_70_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_71_84_current_idx], 'gem11')
        Casting.CastBuff(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_71_84_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_85_plus_current_idx], 'gem2')
        Casting.CastBuff(shaman.shaman_settings.procBuffs[shaman.shaman_settings.proc_buff_85_plus_current_idx], 'gem3')
    end
end

local haste_Enabled
local sow_Enabled
local sow_1_45_current_idx
local sow_46_plus_current_idx
local buffs_1_45_Enabled
local hp_buff_1_45_current_idx
local regen_buff_1_45_current_idx
local proc_buff_1_45_current_idx

local haste_1_45_current_idx
local haste_46_plus_current_idx

local buffs_46_60_Enabled
local hp_buff_46_60_current_idx
local regen_buff_46_60_current_idx
local proc_buff_46_60_current_idx

local buffs_61_70_Enabled
local hp_buff_61_70_current_idx
local regen_buff_61_70_current_idx
local proc_buff_61_70_current_idx

local buffs_71_84_Enabled
local hp_buff_71_84_current_idx
local regen_buff_71_84_current_idx
local proc_buff_71_84_current_idx

local buffs_85_plus_Enabled
local hp_buff_85_plus_current_idx
local regen_buff_85_plus_current_idx
local proc_buff_85_plus_current_idx
function shaman.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Shaman v" .. shaman.version) then
        ImGui.Text("SHAMAN:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.Separator()

        --
        -- Haste
        --
        if ImGui.TreeNode('Spirit of Wolf:') then
            ImGui.SameLine()
            shaman.shaman_settings.sow_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.sow_Enabled)
            if sow_Enabled ~= shaman.shaman_settings.sow_Enabled then
                sow_Enabled = shaman.shaman_settings.sow_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.sow_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 SoW", shaman.sow_Buffs,
                shaman.shaman_settings.sow_1_45_current_idx);
            if sow_1_45_current_idx ~= shaman.shaman_settings.sow_1_45_current_idx then
                sow_1_45_current_idx = shaman.shaman_settings.sow_1_45_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.sow_46_plus_current_idx = GUI.CreateBuffBox:draw("46+ SoW", shaman.sow_Buffs,
                shaman.shaman_settings.sow_46_plus_current_idx);
            if sow_46_plus_current_idx ~= shaman.shaman_settings.sow_46_plus_current_idx then
                sow_46_plus_current_idx = shaman.shaman_settings.sow_46_plus_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- SoW
        --
        if ImGui.TreeNode('Haste:') then
            ImGui.SameLine()
            shaman.shaman_settings.haste_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.haste_Enabled)
            if haste_Enabled ~= shaman.shaman_settings.haste_Enabled then
                haste_Enabled = shaman.shaman_settings.haste_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.haste_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 Haste", shaman.haste_Buffs,
                shaman.shaman_settings.haste_1_45_current_idx);
            if haste_1_45_current_idx ~= shaman.shaman_settings.haste_1_45_current_idx then
                haste_1_45_current_idx = shaman.shaman_settings.haste_1_45_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.haste_46_plus_current_idx = GUI.CreateBuffBox:draw("46+ Haste", shaman.haste_Buffs,
                shaman.shaman_settings.haste_46_plus_current_idx);
            if haste_46_plus_current_idx ~= shaman.shaman_settings.haste_46_plus_current_idx then
                haste_46_plus_current_idx = shaman.shaman_settings.haste_46_plus_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                shaman.shaman_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= shaman.shaman_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = shaman.shaman_settings.buffs_1_45_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()


            shaman.shaman_settings.hp_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= shaman.shaman_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = shaman.shaman_settings.hp_buff_1_45_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.regen_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 REGEN", shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_1_45_current_idx);
            if regen_buff_1_45_current_idx ~= shaman.shaman_settings.regen_buff_1_45_current_idx then
                regen_buff_1_45_current_idx = shaman.shaman_settings.regen_buff_1_45_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.proc_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 PROC", shaman.proc_Buffs,
                shaman.shaman_settings.proc_buff_1_45_current_idx);
            if proc_buff_1_45_current_idx ~= shaman.shaman_settings.proc_buff_1_45_current_idx then
                proc_buff_1_45_current_idx = shaman.shaman_settings.proc_buff_1_45_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            shaman.shaman_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                shaman.shaman_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= shaman.shaman_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = shaman.shaman_settings.buffs_46_60_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= shaman.shaman_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = shaman.shaman_settings.hp_buff_46_60_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.regen_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 REGEN",
                shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_46_60_current_idx);
            if regen_buff_46_60_current_idx ~= shaman.shaman_settings.regen_buff_46_60_current_idx then
                regen_buff_46_60_current_idx = shaman.shaman_settings.regen_buff_46_60_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.proc_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 PROC",
                shaman.proc_Buffs,
                shaman.shaman_settings.proc_buff_46_60_current_idx);
            if proc_buff_46_60_current_idx ~= shaman.shaman_settings.proc_buff_46_60_current_idx then
                proc_buff_46_60_current_idx = shaman.shaman_settings.proc_buff_46_60_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                shaman.shaman_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= shaman.shaman_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = shaman.shaman_settings.buffs_61_70_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= shaman.shaman_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = shaman.shaman_settings.hp_buff_61_70_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.regen_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 REGEN",
                shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_61_70_current_idx);
            if regen_buff_61_70_current_idx ~= shaman.shaman_settings.regen_buff_61_70_current_idx then
                regen_buff_61_70_current_idx = shaman.shaman_settings.regen_buff_61_70_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.proc_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 PROC",
                shaman.proc_Buffs,
                shaman.shaman_settings.proc_buff_61_70_current_idx);
            if proc_buff_61_70_current_idx ~= shaman.shaman_settings.proc_buff_61_70_current_idx then
                proc_buff_61_70_current_idx = shaman.shaman_settings.proc_buff_61_70_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                shaman.shaman_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= shaman.shaman_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = shaman.shaman_settings.buffs_71_84_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= shaman.shaman_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = shaman.shaman_settings.hp_buff_71_84_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.regen_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 REGEN",
                shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_71_84_current_idx);
            if regen_buff_71_84_current_idx ~= shaman.shaman_settings.regen_buff_71_84_current_idx then
                regen_buff_71_84_current_idx = shaman.shaman_settings.regen_buff_71_84_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.proc_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 PROC",
                shaman.proc_Buffs,
                shaman.shaman_settings.proc_buff_71_84_current_idx);
            if proc_buff_71_84_current_idx ~= shaman.shaman_settings.proc_buff_71_84_current_idx then
                proc_buff_71_84_current_idx = shaman.shaman_settings.proc_buff_71_84_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                shaman.shaman_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= shaman.shaman_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = shaman.shaman_settings.buffs_85_plus_Enabled
                shaman.saveSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= shaman.shaman_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = shaman.shaman_settings.hp_buff_85_plus_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.regen_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ REGEN",
                shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_85_plus_current_idx);
            if regen_buff_85_plus_current_idx ~= shaman.shaman_settings.regen_buff_85_plus_current_idx then
                regen_buff_85_plus_current_idx = shaman.shaman_settings.regen_buff_85_plus_current_idx
                shaman.saveSettings()
            end

            shaman.shaman_settings.proc_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ PROC",
                shaman.proc_Buffs,
                shaman.shaman_settings.proc_buff_85_plus_current_idx);
            if proc_buff_85_plus_current_idx ~= shaman.shaman_settings.proc_buff_85_plus_current_idx then
                proc_buff_85_plus_current_idx = shaman.shaman_settings.proc_buff_85_plus_current_idx
                shaman.saveSettings()
            end
            imgui.TreePop()
        end

        --
        -- Help
        --
        if imgui.CollapsingHeader("Shaman Options") then
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
                SaveSettings(iniPath, shaman.shaman_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return shaman
