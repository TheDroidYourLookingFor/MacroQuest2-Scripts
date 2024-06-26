---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local cleric = {}
cleric.version = '1.0.0'

cleric.rez_Spell = {
    'Reviviscence',
    'Blessing of Resurrection',
    'Resurrection',
    'Restoration',
    'Resuscitate',
    'Renewal',
    'Revive',
    'Reparation',
    'Reconstitution',
    'Reanimation'
}

cleric.symbol_Buffs = {
    "Unified Hand of the Diabo",
    "Symbol of Sanguineous",
    "Unity of the Sanguine",
    "Unified Hand of Jorlleag",
    "Unity of Jorlleag",
    "Symbol of Jorlleag",
    "Unified Hand of Emra",
    "Unity of Emra",
    "Unified Hand of Nonia",
    "Unity of Nonia",
    "Symbol of Nonia",
    "Unified Hand of Gezat",
    "Unity of Gezat",
    "Symbol of Gezat",
    "Unified Hand of the Triumvirate",
    "Unity of the Triumvirate",
    "Symbol of the Triumvirate",
    "Ealdun's Mark",
    "Symbol of Ealdun",
    "Darianna's Mark",
    "Symbol of Darianna",
    "Kaerra's Mark",
    "Symbol of Kaerra",
    "Elushar's Mark",
    "Symbol of Elushar",
    "Balikor's Mark",
    "Symbol of Balikor",
    "Kazad's Mark",
    "Symbol of Kazad",
    "Marzin's Mark",
    "Naltron's Mark",
    "Symbol of Marzin",
    "Symbol of Naltron",
    "Symbol of Pinzarn",
    "Symbol of Ryltan",
    "Symbol of Transal"
}

cleric.hp_Buffs = {
    'Unified Hand of Persistence',
    'Unified Persistence',
    "Mercenary's Hand of Persistence",
    'Persistence',
    'Unified Hand of Righteousness',
    'Unified Righteousness',
    'Hand of Righteousness',
    'Righteousness',
    'Unified Hand of Assurance',
    'Unified Assurance',
    'Hand of Assurance',
    'Assurance',
    'Unified Hand of Surety',
    'Unified Surety',
    'Hand of Surety',
    'Surety',
    'Unified Hand of Certitude',
    'Unified Certitude',
    'Hand of Certitude',
    'Certitude',
    'Unified Hand of Credence',
    'Unified Credence',
    'Hand of Credence',
    'Credence',
    'Hand of Reliance',
    'Reliance',
    'Hand of Gallantry',
    'Gallantry',
    'Hand of Temerity',
    'Temerity',
    'Hand of Tenacity',
    'Tenacity',
    'Hand of Conviction',
    'Conviction',
    'Hand of Virtue',
    'Virtue',
    'Faith',
    'Blessing of Aegolism',
    'Aegolism',
    'Fortitude',
    'Heroic Bond',
    'Heroism',
    'Blessing of Temperance',
    'Resolution',
    'Temperance',
    'Valor',
    'Bravery',
    'Daring',
    'Center',
    'Courage'
}
cleric.haste_Buffs = {
    'Hand of Devoutness',
    'Benediction of Resplendence',
    'Hand of Reverence',
    'Benediction of Reverence',
    'Hand of Zeal',
    'Benediction of Piety',
    'Hand of Fervor',
    'Blessing of Fervor',
    'Hand of Assurance',
    'Blessing of Assurance',
    'Hand of Will',
    'Blessing of Will',
    'Aura of Loyalty',
    'Blessing of Loyalty',
    'Aura of Resolve',
    'Blessing of Resolve',
    'Aura of Purpose',
    'Blessing of Purpose',
    'Aura of Devotion',
    'Blessing of Devotion',
    'Aura of Reverence',
    'Blessing of Reverence',
    'Blessing of Faith',
    'Blessing of Piety'
}
cleric.guard_Buffs = {
    'Rallied Greater Bulwark of Vie',
    'Greater Bulwark of Vie',
    'Rallied Greater Protection of Vie',
    'Greater Protection of Vie',
    'Rallied Greater Guard of Vie',
    'Greater Guard of Vie',
    'Rallied Greater Ward of Vie',
    'Greater Ward of Vie',
    'Rallied Bastion of Vie',
    'Bastion of Vie',
    'Rallied Armor of Vie',
    'Armor of Vie',
    'Rallied Rampart of Vie',
    'Rampart of Vie',
    'Rallied Palladium of Vie',
    'Palladium of Vie',
    'Rallied Aegis of Vie',
    'Aegis of Vie',
    'Panoply of Vie',
    'Bulwark of Vie',
    'Protection of Vie',
    'Guard of Vie',
    'Ward of Vie'
}
cleric.purity_Buffs = {
    'Shared Purity'
}
local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniClericPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

cleric.cleric_settings = {
    version = cleric.version,
    runDebug = DEBUG,
    hpBuffs = cleric.hp_Buffs,
    hasteBuffs = cleric.haste_Buffs,
    guardBuffs = cleric.guard_Buffs,
    symbolBuffs = cleric.symbol_Buffs,
    purityBuffs = cleric.purity_Buffs,
    resSpells = cleric.rez_Spell,
    rezEnabled = false,
    rez_current_idx = 1,
    buffs_1_45_Enabled = false,
    hp_buff_1_45_current_idx = 43,
    haste_buff_1_45_current_idx = 23,
    guard_buff_1_45_current_idx = 22,

    buffs_46_60_Enabled = false,
    hp_buff_46_60_current_idx = 38,
    haste_buff_46_60_current_idx = 22,
    guard_buff_46_60_current_idx = 21,

    buffs_61_70_Enabled = false,
    hp_buff_61_70_current_idx = 35,
    haste_buff_61_70_current_idx = 21,
    guard_buff_61_70_current_idx = 20,
    purity_buff_61_current_idx = 1,

    buffs_71_84_Enabled = false,
    hp_buff_71_84_current_idx = 7,
    haste_buff_71_84_current_idx = 15,
    guard_buff_71_84_current_idx = 15,

    buffs_85_plus_Enabled = false,
    hp_buff_85_plus_current_idx = 1,
    haste_buff_85_plus_current_idx = 1,
    guard_buff_85_plus_current_idx = 1,
    symbol_buff_85_plus_current_idx = 1
}

function cleric.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniClericPath, cleric.cleric_settings)
end

function cleric.Setup()
    local conf
    local configData, err = loadfile(iniClericPath)
    if err then
        cleric.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= cleric.version then
            cleric.saveSettings()
            cleric.Setup()
        else
            cleric.cleric_settings = conf
            cleric.hp_Buffs = cleric.cleric_settings.hpBuffs
            cleric.haste_Buffs = cleric.cleric_settings.hasteBuffs
            cleric.guard_Buffs = cleric.cleric_settings.guardBuffs
        end
    end
end

function cleric.MemorizeSpells()
    if cleric.cleric_settings.buffs_1_45_Enabled then
        Casting.MemSpell(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_1_45_current_idx], 1)
        Casting.MemSpell(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_1_45_current_idx], 2)
        Casting.MemSpell(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_1_45_current_idx], 3)
    end

    if cleric.cleric_settings.buffs_46_60_Enabled then
        Casting.MemSpell(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_46_60_current_idx], 4)
        Casting.MemSpell(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_46_60_current_idx], 5)
        Casting.MemSpell(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_46_60_current_idx], 6)
    end

    if cleric.cleric_settings.buffs_61_70_Enabled then
        Casting.MemSpell(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_61_70_current_idx], 7)
        Casting.MemSpell(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_61_70_current_idx], 8)
        Casting.MemSpell(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_61_70_current_idx], 9)
        Casting.MemSpell(cleric.cleric_settings.purityBuffs[cleric.cleric_settings.purity_buff_61_current_idx], 10)
    end

    if cleric.cleric_settings.buffs_71_84_Enabled then
        Casting.MemSpell(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_71_84_current_idx], 11)
        Casting.MemSpell(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_71_84_current_idx], 12)
        Casting.MemSpell(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_71_84_current_idx], 13)
    end

    if cleric.cleric_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_85_plus_current_idx], 14)
        Casting.MemSpell(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_85_plus_current_idx], 15)
        Casting.MemSpell(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_85_plus_current_idx], 16)
        Casting.MemSpell(cleric.cleric_settings.symbolBuffs[cleric.cleric_settings.symbol_buff_85_plus_current_idx], 16)
    end
end

function cleric.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_1_45_current_idx], 'gem2')
        Casting.CastBuff(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_1_45_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_46_60_current_idx], 'gem4')
        Casting.CastBuff(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_46_60_current_idx], 'gem5')
        Casting.CastBuff(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_46_60_current_idx], 'gem6')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_61_70_current_idx], 'gem8')
        Casting.CastBuff(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_61_70_current_idx], 'gem9')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 then
        Casting.CastBuff(cleric.cleric_settings.purityBuffs[cleric.cleric_settings.purity_buff_61_current_idx], 'gem10')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_71_84_current_idx], 'gem11')
        Casting.CastBuff(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_71_84_current_idx], 'gem12')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(cleric.cleric_settings.hpBuffs[cleric.cleric_settings.hp_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(cleric.cleric_settings.hasteBuffs[cleric.cleric_settings.haste_buff_85_plus_current_idx], 'gem2')
        Casting.CastBuff(cleric.cleric_settings.guardBuffs[cleric.cleric_settings.guard_buff_85_plus_current_idx], 'gem3')
        Casting.CastBuff(cleric.cleric_settings.symbolBuffs[cleric.cleric_settings.symbol_buff_85_plus_current_idx],
            'gem3')
    end
end

local rez_Enabled
local rez_current_idx
local buffs_1_45_Enabled
local hp_buff_1_45_current_idx
local haste_buff_1_45_current_idx
local guard_buff_1_45_current_idx

local buffs_46_60_Enabled
local hp_buff_46_60_current_idx
local haste_buff_46_60_current_idx
local guard_buff_46_60_current_idx

local buffs_61_70_Enabled
local hp_buff_61_70_current_idx
local haste_buff_61_70_current_idx
local guard_buff_61_70_current_idx
local purity_buff_61_current_idx

local buffs_71_84_Enabled
local hp_buff_71_84_current_idx
local haste_buff_71_84_current_idx
local guard_buff_71_84_current_idx

local buffs_85_plus_Enabled
local hp_buff_85_plus_current_idx
local haste_buff_85_plus_current_idx
local guard_buff_85_plus_current_idx
local symbol_buff_85_plus_current_idx

local hp_buffs_current_idx
function cleric.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Cleric v" .. cleric.version) then
        ImGui.Text("CLERIC:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.BulletText("Cleric: Will resurrect a player when it hears \"rez\"")
        ImGui.Separator()

        --
        -- Rez
        --
        if ImGui.TreeNode('Resurrect:') then
            ImGui.SameLine()
            cleric.cleric_settings.rez_Enabled = ImGui.Checkbox('Enable', cleric.cleric_settings.rez_Enabled)
            if rez_Enabled ~= cleric.cleric_settings.rez_Enabled then
                rez_Enabled = cleric.cleric_settings.rez_Enabled
                cleric.saveSettings()
            end
            ImGui.Separator()


            cleric.cleric_settings.rez_current_idx = GUI.CreateBuffBox:draw("Res Spell", cleric.rez_Spell,
                cleric.cleric_settings.rez_current_idx);
            if rez_current_idx ~= cleric.cleric_settings.rez_current_idx then
                rez_current_idx = cleric.cleric_settings.rez_current_idx
                cleric.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            cleric.cleric_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                cleric.cleric_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= cleric.cleric_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = cleric.cleric_settings.buffs_1_45_Enabled
                cleric.saveSettings()
            end
            ImGui.Separator()


            cleric.cleric_settings.hp_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP", cleric.hp_Buffs,
                cleric.cleric_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= cleric.cleric_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = cleric.cleric_settings.hp_buff_1_45_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.haste_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HASTE",
                cleric.haste_Buffs,
                cleric.cleric_settings.haste_buff_1_45_current_idx);
            if haste_buff_1_45_current_idx ~= cleric.cleric_settings.haste_buff_1_45_current_idx then
                haste_buff_1_45_current_idx = cleric.cleric_settings.haste_buff_1_45_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.guard_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 GUARD",
                cleric.guard_Buffs,
                cleric.cleric_settings.guard_buff_1_45_current_idx);
            if guard_buff_1_45_current_idx ~= cleric.cleric_settings.guard_buff_1_45_current_idx then
                guard_buff_1_45_current_idx = cleric.cleric_settings.guard_buff_1_45_current_idx
                cleric.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            cleric.cleric_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                cleric.cleric_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= cleric.cleric_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = cleric.cleric_settings.buffs_46_60_Enabled
                cleric.saveSettings()
            end
            ImGui.Separator()

            cleric.cleric_settings.hp_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP", cleric.hp_Buffs,
                cleric.cleric_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= cleric.cleric_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = cleric.cleric_settings.hp_buff_46_60_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.haste_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HASTE",
                cleric.haste_Buffs,
                cleric.cleric_settings.haste_buff_46_60_current_idx);
            if haste_buff_46_60_current_idx ~= cleric.cleric_settings.haste_buff_46_60_current_idx then
                haste_buff_46_60_current_idx = cleric.cleric_settings.haste_buff_46_60_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.guard_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 GUARD",
                cleric.guard_Buffs,
                cleric.cleric_settings.guard_buff_46_60_current_idx);
            if guard_buff_46_60_current_idx ~= cleric.cleric_settings.guard_buff_46_60_current_idx then
                guard_buff_46_60_current_idx = cleric.cleric_settings.guard_buff_46_60_current_idx
                cleric.saveSettings()
            end

            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            cleric.cleric_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                cleric.cleric_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= cleric.cleric_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = cleric.cleric_settings.buffs_61_70_Enabled
                cleric.saveSettings()
            end
            ImGui.Separator()

            cleric.cleric_settings.hp_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP", cleric.hp_Buffs,
                cleric.cleric_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= cleric.cleric_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = cleric.cleric_settings.hp_buff_61_70_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.haste_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HASTE",
                cleric.haste_Buffs,
                cleric.cleric_settings.haste_buff_61_70_current_idx);
            if haste_buff_61_70_current_idx ~= cleric.cleric_settings.haste_buff_61_70_current_idx then
                haste_buff_61_70_current_idx = cleric.cleric_settings.haste_buff_61_70_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.guard_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 GUARD",
                cleric.guard_Buffs,
                cleric.cleric_settings.guard_buff_61_70_current_idx);
            if guard_buff_61_70_current_idx ~= cleric.cleric_settings.guard_buff_61_70_current_idx then
                guard_buff_61_70_current_idx = cleric.cleric_settings.guard_buff_61_70_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.purity_buff_61_current_idx = GUI.CreateBuffBox:draw("61+ PURITY",
                cleric.purity_Buffs,
                cleric.cleric_settings.purity_buff_61_current_idx);
            if purity_buff_61_current_idx ~= cleric.cleric_settings.purity_buff_61_current_idx then
                purity_buff_61_current_idx = cleric.cleric_settings.purity_buff_61_current_idx
                cleric.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            cleric.cleric_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                cleric.cleric_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= cleric.cleric_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = cleric.cleric_settings.buffs_71_84_Enabled
                cleric.saveSettings()
            end
            ImGui.Separator()

            cleric.cleric_settings.hp_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP", cleric.hp_Buffs,
                cleric.cleric_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= cleric.cleric_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = cleric.cleric_settings.hp_buff_71_84_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.haste_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HASTE",
                cleric.haste_Buffs,
                cleric.cleric_settings.haste_buff_71_84_current_idx);
            if haste_buff_71_84_current_idx ~= cleric.cleric_settings.haste_buff_71_84_current_idx then
                haste_buff_71_84_current_idx = cleric.cleric_settings.haste_buff_71_84_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.guard_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 GUARD",
                cleric.guard_Buffs,
                cleric.cleric_settings.guard_buff_71_84_current_idx);
            if guard_buff_71_84_current_idx ~= cleric.cleric_settings.guard_buff_71_84_current_idx then
                guard_buff_71_84_current_idx = cleric.cleric_settings.guard_buff_71_84_current_idx
                cleric.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            cleric.cleric_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                cleric.cleric_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= cleric.cleric_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = cleric.cleric_settings.buffs_85_plus_Enabled
                cleric.saveSettings()
            end
            ImGui.Separator()

            cleric.cleric_settings.hp_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP", cleric.hp_Buffs,
                cleric.cleric_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= cleric.cleric_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = cleric.cleric_settings.hp_buff_85_plus_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.haste_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HASTE",
                cleric.haste_Buffs,
                cleric.cleric_settings.haste_buff_85_plus_current_idx);
            if haste_buff_85_plus_current_idx ~= cleric.cleric_settings.haste_buff_85_plus_current_idx then
                haste_buff_85_plus_current_idx = cleric.cleric_settings.haste_buff_85_plus_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.guard_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ GUARD",
                cleric.guard_Buffs,
                cleric.cleric_settings.guard_buff_85_plus_current_idx);
            if guard_buff_85_plus_current_idx ~= cleric.cleric_settings.guard_buff_85_plus_current_idx then
                guard_buff_85_plus_current_idx = cleric.cleric_settings.guard_buff_85_plus_current_idx
                cleric.saveSettings()
            end

            cleric.cleric_settings.symbol_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ SYMBOL",
                cleric.symbol_Buffs,
                cleric.cleric_settings.symbol_buff_85_plus_current_idx);
            if symbol_buff_85_plus_current_idx ~= cleric.cleric_settings.symbol_buff_85_plus_current_idx then
                symbol_buff_85_plus_current_idx = cleric.cleric_settings.symbol_buff_85_plus_current_idx
                cleric.saveSettings()
            end
            imgui.TreePop()
        end
        --
        -- Help
        --
        if imgui.CollapsingHeader("Cleric Options") then
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
                SaveSettings(iniClericPath, cleric.cleric_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniClericPath)
            ImGui.Separator();
        end
    end
end

return cleric
