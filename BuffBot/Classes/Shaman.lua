---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local shaman_version = '1.0.0'
local shaman = {}
shaman.haste_Buffs = {
    'Talisman of Celerity',
    'Celerity',
    'Alacrity',
    'Quickness'
}
shaman.hp_Buffs = {
    'Talisman of Tnarg','Talisman of Altuna','Harnessing of Spirit','Talisman of Kragg','Focus of Soul','Unity of the Doomscale','Talisman of the Usurper'
}
shaman.regen_Buffs = {
    'Talisman of the Tenacious',
    'Replenishment',
    'Regrowth of Dar Khura',
    'Chloroplast',
    'Regeneration'
}
shaman.sow_Buffs = {
    'Spirit of Wolf',
    'Spirit of Bih`Li',
    'Spirit of the Shrew',
    'Pact Shrew'
}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_'.. class ..'.ini'

shaman.shaman_settings = {
    runDebug = DEBUG,
    hasteBuffs = shaman.haste_Buffs,
    hpBuffs = shaman.hp_Buffs,
    regenBuffs = shaman.regen_Buffs,
    sowBuffs = shaman.sow_Buffs,

    haste_Enabled = false,
    sow_1_45_current_idx = 1,
    sow_46_plus_current_idx = 1,
    buffs_1_45_Enabled = false,
    hp_buff_1_45_current_idx = 1,
    regen_buff_1_45_current_idx = 1,

    haste_1_45_current_idx = 1,
    haste_46_plus_current_idx = 1,

    buffs_46_60_Enabled = false,
    hp_buff_46_60_current_idx = 1,
    regen_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    hp_buff_61_70_current_idx = 1,
    regen_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    hp_buff_71_84_current_idx = 1,
    regen_buff_71_84_current_idx = 1,

    buffs_85_plus_Enabled = false,
    hp_buff_85_plus_current_idx = 1,
    regen_buff_85_plus_current_idx = 1
}

local function saveShamanSettings()
    SaveSettings(iniPath, shaman.shaman_settings)
end

local function setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        saveShamanSettings()
    elseif configData then
        conf = configData()
        shaman.shaman_settings = conf
        shaman.hp_Buffs = shaman.shaman_settings.hpBuffs
        shaman.regen_Buffs = shaman.shaman_settings.regenBuffs
        shaman.haste_Buffs = shaman.shaman_settings.hasteBuffs
        shaman.sow_Buffs = shaman.shaman_settings.sowBuffs
    end
end
setup()

function shaman.MemorizeSpells()
    if shaman.shaman_settings.buffs_1_45_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_1_45_current_idx], 1)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_1_45_current_idx], 2)
        Casting.MemSpell(shaman.shaman_settings.sowBuffs[shaman.shaman_settings.sow_1_45_current_idx], 6)
        Casting.MemSpell(shaman.shaman_settings.hasteBuffs[shaman.shaman_settings.haste_buff_1_45_current_idx], 3)
    end

    if shaman.shaman_settings.buffs_46_60_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_46_60_current_idx], 4)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_46_60_current_idx], 5)
        Casting.MemSpell(shaman.shaman_settings.sowBuffs[shaman.shaman_settings.sow_46_plus_current_idx], 6)
        Casting.MemSpell(shaman.shaman_settings.hasteBuffs[shaman.shaman_settings.haste_46_plus_current_idx], 7)
    end

    if shaman.shaman_settings.buffs_61_70_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_61_70_current_idx], 7)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_61_70_current_idx], 8)
    end

    if shaman.shaman_settings.buffs_71_84_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_71_84_current_idx], 11)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_71_84_current_idx], 12)
    end

    if shaman.shaman_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_85_plus_current_idx], 14)
        Casting.MemSpell(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.guard_buff_85_plus_current_idx], 15)
    end
end

function shaman.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_1_45_current_idx], 'gem2')
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
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_61_70_current_idx], 'gem8')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_71_84_current_idx], 'gem11')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(shaman.shaman_settings.hpBuffs[shaman.shaman_settings.hp_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(shaman.shaman_settings.regenBuffs[shaman.shaman_settings.regen_buff_85_plus_current_idx], 'gem2')
    end
end

shaman.CreateBuffBox = {
    flags = 0
}

function shaman.CreateBuffBox:draw(cb_label, buffs, current_idx)
    local combo_buffs = buffs[current_idx]
    local spell_Icon = mq.TLO.Spell(buffs[current_idx]).SpellIcon()

    local box = mq.FindTextureAnimation("A_SpellIcons")
    box:SetTextureCell(spell_Icon)
    ImGui.DrawTextureAnimation(box, 20, 20)
    ImGui.SameLine();
    if ImGui.BeginCombo(cb_label, combo_buffs) then
        for n = 1, #buffs do
            local is_selected = current_idx == n
            if ImGui.Selectable(buffs[n], is_selected) then -- fixme: selectable
                current_idx = n
                spell_Icon = mq.TLO.Spell(buffs[n]).SpellIcon();
            end

            -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
            if is_selected then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end
    return current_idx
end

local haste_Enabled
local sow_Enabled
local sow_1_45_current_idx
local sow_46_plus_current_idx
local buffs_1_45_Enabled
local hp_buff_1_45_current_idx
local regen_buff_1_45_current_idx

local haste_1_45_current_idx
local haste_46_plus_current_idx

local buffs_46_60_Enabled
local hp_buff_46_60_current_idx
local regen_buff_46_60_current_idx

local buffs_61_70_Enabled
local hp_buff_61_70_current_idx
local regen_buff_61_70_current_idx

local buffs_71_84_Enabled
local hp_buff_71_84_current_idx
local regen_buff_71_84_current_idx

local buffs_85_plus_Enabled
local hp_buff_85_plus_current_idx
local regen_buff_85_plus_current_idx
function shaman.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Shaman v" .. shaman_version) then
        ImGui.Text("SHAMAN:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.Separator()

        --
        -- Haste
        --
        if ImGui.TreeNode('Spirit of Wolf:') then
            ImGui.SameLine()
            shaman.shaman_settings.haste_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.haste_Enabled)
            if haste_Enabled ~= shaman.shaman_settings.haste_Enabled then
                haste_Enabled = shaman.shaman_settings.haste_Enabled
                saveShamanSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.sow_1_45_current_idx = shaman.CreateBuffBox:draw("1-45 SoW", shaman.sow_Buffs,
                shaman.shaman_settings.sow_1_45_current_idx);
            if sow_1_45_current_idx ~= shaman.shaman_settings.sow_1_45_current_idx then
                sow_1_45_current_idx = shaman.shaman_settings.sow_1_45_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.sow_46_plus_current_idx = shaman.CreateBuffBox:draw("46+ SoW", shaman.sow_Buffs,
                shaman.shaman_settings.sow_46_plus_current_idx);
            if sow_46_plus_current_idx ~= shaman.shaman_settings.sow_46_plus_current_idx then
                sow_46_plus_current_idx = shaman.shaman_settings.sow_46_plus_current_idx
                saveShamanSettings()
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
                saveShamanSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.haste_1_45_current_idx = shaman.CreateBuffBox:draw("1-45 Haste", shaman.haste_Buffs,
                shaman.shaman_settings.haste_1_45_current_idx);
            if haste_1_45_current_idx ~= shaman.shaman_settings.haste_1_45_current_idx then
                haste_1_45_current_idx = shaman.shaman_settings.haste_1_45_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.haste_46_plus_current_idx = shaman.CreateBuffBox:draw("46+ Haste", shaman.haste_Buffs,
                shaman.shaman_settings.haste_46_plus_current_idx);
            if haste_46_plus_current_idx ~= shaman.shaman_settings.haste_46_plus_current_idx then
                haste_46_plus_current_idx = shaman.shaman_settings.haste_46_plus_current_idx
                saveShamanSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= shaman.shaman_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = shaman.shaman_settings.buffs_1_45_Enabled
                saveShamanSettings()
            end
            ImGui.Separator()


            shaman.shaman_settings.hp_buff_1_45_current_idx = shaman.CreateBuffBox:draw("1-45 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= shaman.shaman_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = shaman.shaman_settings.hp_buff_1_45_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.regen_buff_1_45_current_idx = shaman.CreateBuffBox:draw("1-45 REGEN", shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_1_45_current_idx);
            if regen_buff_1_45_current_idx ~= shaman.shaman_settings.regen_buff_1_45_current_idx then
                regen_buff_1_45_current_idx = shaman.shaman_settings.regen_buff_1_45_current_idx
                saveShamanSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            shaman.shaman_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= shaman.shaman_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = shaman.shaman_settings.buffs_46_60_Enabled
                saveShamanSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_46_60_current_idx = shaman.CreateBuffBox:draw("46-60 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= shaman.shaman_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = shaman.shaman_settings.hp_buff_46_60_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.regen_buff_46_60_current_idx = shaman.CreateBuffBox:draw("46-60 REGEN", shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_46_60_current_idx);
            if regen_buff_46_60_current_idx ~= shaman.shaman_settings.regen_buff_46_60_current_idx then
                regen_buff_46_60_current_idx = shaman.shaman_settings.regen_buff_46_60_current_idx
                saveShamanSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= shaman.shaman_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = shaman.shaman_settings.buffs_61_70_Enabled
                saveShamanSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_61_70_current_idx = shaman.CreateBuffBox:draw("61-70 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= shaman.shaman_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = shaman.shaman_settings.hp_buff_61_70_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.regen_buff_61_70_current_idx = shaman.CreateBuffBox:draw("61-70 REGEN", shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_61_70_current_idx);
            if regen_buff_61_70_current_idx ~= shaman.shaman_settings.regen_buff_61_70_current_idx then
                regen_buff_61_70_current_idx = shaman.shaman_settings.regen_buff_61_70_current_idx
                saveShamanSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= shaman.shaman_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = shaman.shaman_settings.buffs_71_84_Enabled
                saveShamanSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_71_84_current_idx = shaman.CreateBuffBox:draw("71-84 HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= shaman.shaman_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = shaman.shaman_settings.hp_buff_71_84_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.regen_buff_71_84_current_idx = shaman.CreateBuffBox:draw("71-84 REGEN", shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_71_84_current_idx);
            if regen_buff_71_84_current_idx ~= shaman.shaman_settings.regen_buff_71_84_current_idx then
                regen_buff_71_84_current_idx = shaman.shaman_settings.regen_buff_71_84_current_idx
                saveShamanSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            shaman.shaman_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable', shaman.shaman_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= shaman.shaman_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = shaman.shaman_settings.buffs_85_plus_Enabled
                saveShamanSettings()
            end
            ImGui.Separator()

            shaman.shaman_settings.hp_buff_85_plus_current_idx = shaman.CreateBuffBox:draw("85+ HP", shaman.hp_Buffs,
                shaman.shaman_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= shaman.shaman_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = shaman.shaman_settings.hp_buff_85_plus_current_idx
                saveShamanSettings()
            end

            shaman.shaman_settings.regen_buff_85_plus_current_idx = shaman.CreateBuffBox:draw("85+ REGEN", shaman.regen_Buffs,
                shaman.shaman_settings.regen_buff_85_plus_current_idx);
            if regen_buff_85_plus_current_idx ~= shaman.shaman_settings.regen_buff_85_plus_current_idx then
                regen_buff_85_plus_current_idx = shaman.shaman_settings.regen_buff_85_plus_current_idx
                saveShamanSettings()
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
