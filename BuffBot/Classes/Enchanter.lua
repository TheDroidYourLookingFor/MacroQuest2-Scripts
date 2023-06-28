---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

function ShowEnchanterBuffbot()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Enchanter") then
        ImGui.Text("Enchanter Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
end

return ShowEnchanterBuffbot
