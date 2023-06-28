---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

function ShowNecromancerBuffbot()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Necromancer") then
        ImGui.Text("Necromancer Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
end

return ShowNecromancerBuffbot
