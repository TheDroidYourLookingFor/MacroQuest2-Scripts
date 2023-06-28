---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

function ShowPaladinBuffbot()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Paladin") then
        ImGui.Text("Paladin Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
end

return ShowPaladinBuffbot
