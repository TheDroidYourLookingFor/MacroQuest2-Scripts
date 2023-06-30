---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local magician = {}

local magician_version = '1.0.0'

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

magician.magician_settings = {
    runDebug = DEBUG,
}

function magician.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, magician.magician_settings)
end

function magician.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        magician.saveSettings()
    elseif configData then
        conf = configData()
        magician.magician_settings = conf
    end
end

function magician.MemorizeSpells()
end

function magician.Buff()
end

function magician.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Magician v"..magician_version) then
        ImGui.Text("Magician Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
end

return magician
