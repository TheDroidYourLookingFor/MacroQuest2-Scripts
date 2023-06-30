
---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local gui = {}

gui.CreateBuffBox = {
    flags = 0
}
function gui.CreateBuffBox:draw(cb_label, buffs, current_idx)
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

return gui