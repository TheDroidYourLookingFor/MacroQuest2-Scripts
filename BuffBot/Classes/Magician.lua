---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

function ShowMagicianBuffbot()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Magician") then
        ImGui.Text("Magician Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
end

return ShowMagicianBuffbot
