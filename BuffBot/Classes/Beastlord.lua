---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

function ShowBeastlordBuffbot()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Beastlord") then
        ImGui.Text("Beastlord Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
end

return ShowBeastlordBuffbot
