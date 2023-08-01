---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local wizard = {}
wizard.version = '1.0.0'

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

wizard.allPorts = {
    'Translocate Shadow Valley',
    'Translocate Shadeweaver\'s Tangle',
    'Translocate Cobalt Scar',
    'Translocate The Great Divide',
    'Translocate Esianti',
    'Translocate Skyfire',
    'Translocate Tempest Temple',
    'Translocate Lceanium',
    'Translocate West Karana',
    'Translocate Shard\'s Landing',
    'Translocate Pillars of Alra',
    'Translocate Sarith',
    'Translocate the Grounds',
    'Translocate Brell\'s Rest',
    'Translocate Plane of Time',
    'Translocate Dragonscale Hills',
    'Translocate Katta Castrum',
    'Translocate Icefall Glacier',
    'Translocate Slaughter',
    'Translocate Barindu',
    'Translocate Sunderock Springs',
    'Translocate Bloodfields',
    'Translocate Tranquility',
    'Translocate Natimbi',
    'Translocate Arcstone',
    'Translocate Undershore',
    'Translocate',
    'Translocate Dawnshroud',
    'Translocate Cobalt Scar',
    'Translocate Wakening Lands',
    'Translocate Great Divide',
    'Translocate Knowledge',
    'Translocate Iceclad',
    'Translocate Cazic',
    'Translocate Ro',
    'Translocate West',
    'Translocate Twilight',
    'Translocate Nek',
    'Translocate Secondary Anchor',
    'Translocate Primary Anchor',
    'Translocate Common',
    'Translocate Grimling',
    'Translocate Combine',
    'Translocate Tox',
    'Translocate Nexus',
    'Translocate Fay',
    'Translocate Stonebrunt',
    'Translocate North',
    'Translocate Blightfire Moors'
}
wizard.portsList = {
    'Translocate Shadow Valley',
    'Translocate Shadeweaver\'s Tangle',
    'Translocate Cobalt Scar',
    'Translocate The Great Divide',
    'Translocate Esianti',
    'Translocate Skyfire',
    'Translocate Tempest Temple',
    'Translocate Lceanium',
    'Translocate West Karana',
    'Translocate Shard\'s Landing',
    'Translocate Pillars of Alra',
    'Translocate Sarith',
    'Translocate the Grounds',
    'Translocate Brell\'s Rest',
    'Translocate Plane of Time',
    'Translocate Dragonscale Hills',
    'Translocate Katta Castrum',
    'Translocate Icefall Glacier',
    'Translocate Slaughter',
    'Translocate Barindu',
    'Translocate Sunderock Springs',
    'Translocate Bloodfields',
    'Translocate Tranquility',
    'Translocate Natimbi',
    'Translocate Arcstone',
    'Translocate Undershore',
    'Translocate',
    'Translocate Dawnshroud',
    'Translocate Cobalt Scar',
    'Translocate Wakening Lands',
    'Translocate Great Divide',
    'Translocate Knowledge',
    'Translocate Iceclad',
    'Translocate Cazic',
    'Translocate Ro',
    'Translocate West',
    'Translocate Twilight',
    'Translocate Nek',
    'Translocate Secondary Anchor',
    'Translocate Primary Anchor',
    'Translocate Common',
    'Translocate Grimling',
    'Translocate Combine',
    'Translocate Tox',
    'Translocate Nexus',
    'Translocate Fay',
    'Translocate Stonebrunt',
    'Translocate North',
    'Translocate Blightfire Moors'
}

function wizard.CheckForPort()
    local ownedPorts = {}
    for spellBookSlot = 1, 1440 do
        if mq.TLO.Me.Book(spellBookSlot).Name() ~= nil then
            if string.find(mq.TLO.Me.Book(spellBookSlot).Name(), 'Translocate') then
                if not mq.TLO.Me.Gem(mq.TLO.Me.Book(spellBookSlot).Name())() then
                    local portName = mq.TLO.Me.Book(spellBookSlot).Name()
                    table.insert(ownedPorts, portName)
                end
            end
        end
    end
    return table.sort(ownedPorts)
end

--wizard.portsList = wizard.CheckForPort()

function wizard.CheckPorts()
    local availablePorts = wizard.CheckForPort()
    if availablePorts == nil then availablePorts = wizard.allPorts end
    local out_Ports = {}
    for _, port in ipairs(availablePorts) do
        local portNameShort = string.gsub(port, 'Translocate ', '')
        table.insert(out_Ports, portNameShort)
    end
    return out_Ports
end

function wizard.BuildPortText()
    local availablePorts = wizard.CheckForPort()
    if availablePorts == nil then return 'Available Translocates: No ports currently.' end
    local out_Ports = 'Available Translocates:'
    for _, port in ipairs(availablePorts) do
        local portNameShort = string.gsub(port, 'Translocate ', '')
        out_Ports = out_Ports .. ' ' .. portNameShort .. ','
    end
    out_Ports = string.sub(out_Ports, 1, -2)
    return out_Ports
end

wizard.gemList = {
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13'
}

wizard.CheckForPort()
wizard.wizard_settings = {
    version = wizard.version,
    runDebug = DEBUG,
    maxGems = mq.TLO.Me.NumGems(),
    portList = wizard.allPorts,
    commonPort01_current_idx = 1,
    commonPort02_current_idx = 1,
    commonPort03_current_idx = 1,
    commonPort04_current_idx = 1,
    commonPort05_current_idx = 1,
    commonPort06_current_idx = 1,
    commonPort07_current_idx = 1,
    commonPort08_current_idx = 1,
    commonPort09_current_idx = 1,
    commonPort10_current_idx = 1,
    commonPort11_current_idx = 1,
    commonPort12_current_idx = 1,
    commonPort13_current_idx = 1,
    commonPort01 = 'Translocate ',
    commonPort02 = 'Translocate Primary Anchor',
    commonPort03 = 'Translocate Secondary Anchor',
    commonPort04 = 'Translocate Knowledge',
    commonPort05 = 'Translocate Nexus',
    commonPort06 = 'Translocate Common',
    commonPort07 = 'Translocate West',
    commonPort08 = 'Translocate Ro',
    commonPort09 = 'Translocate Great Divide',
    commonPort10 = 'Translocate Wakening Lands',
    commonPort11 = 'Translocate Cobalt Scar',
    commonPort12 = 'Translocate Dawnshroud',
    commonPort13 = 'Translocate Slaughter',
    commonPort01_gem = 1,
    commonPort02_gem = 2,
    commonPort03_gem = 3,
    commonPort04_gem = 4,
    commonPort05_gem = 5,
    commonPort06_gem = 6,
    commonPort07_gem = 7,
    commonPort08_gem = 8,
    commonPort09_gem = 9,
    commonPort10_gem = 10,
    commonPort11_gem = 11,
    commonPort12_gem = 12,
    commonPort13_gem = 13,
    commonPort01_Enabled = false,
    commonPort02_Enabled = false,
    commonPort03_Enabled = false,
    commonPort04_Enabled = false,
    commonPort05_Enabled = false,
    commonPort06_Enabled = false,
    commonPort07_Enabled = false,
    commonPort08_Enabled = false,
    commonPort09_Enabled = false,
    commonPort10_Enabled = false,
    commonPort11_Enabled = false,
    commonPort12_Enabled = false,
    commonPort13_Enabled = false
}

function wizard.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, wizard.wizard_settings)
end

function wizard.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        wizard.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= wizard.version then
            wizard.saveSettings()
            wizard.Setup()
        else
            wizard.wizard_settings = conf
        end
    end
end

function wizard.MemorizeSpells()
    if wizard.wizard_settings.commonPort01_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort01_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort02_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort02_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort03_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort03_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort04_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort04_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort05_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort05_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort06_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort06_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort07_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort07_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort08_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort08_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort09_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort09_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort10_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort10_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort11_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort11_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort12_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort12_current_idx], 1)
    end
    if wizard.wizard_settings.commonPort13_Enabled then
        Casting.MemSpell(
            wizard.allPorts[wizard.wizard_settings.commonPort13_current_idx], 1)
    end
end

function wizard.Buff()
end

local CommonPort01_Enabled
local CommonPort02_Enabled
local CommonPort03_Enabled
local CommonPort04_Enabled
local CommonPort05_Enabled
local CommonPort06_Enabled
local CommonPort07_Enabled
local CommonPort08_Enabled
local CommonPort09_Enabled
local CommonPort10_Enabled
local CommonPort11_Enabled
local CommonPort12_Enabled
local CommonPort13_Enabled

local CommonPort01_current_idx
local CommonPort02_current_idx
local CommonPort03_current_idx
local CommonPort04_current_idx
local CommonPort05_current_idx
local CommonPort06_current_idx
local CommonPort07_current_idx
local CommonPort08_current_idx
local CommonPort09_current_idx
local CommonPort10_current_idx
local CommonPort11_current_idx
local CommonPort12_current_idx
local CommonPort13_current_idx

local CommonPort01_gem
local CommonPort02_gem
local CommonPort03_gem
local CommonPort04_gem
local CommonPort05_gem
local CommonPort06_gem
local CommonPort07_gem
local CommonPort08_gem
local CommonPort09_gem
local CommonPort10_gem
local CommonPort11_gem
local CommonPort12_gem
local CommonPort13_gem

function wizard.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Wizard" .. wizard.version) then
        ImGui.Text("WIZARD:");
        ImGui.BulletText('Please say "ports" for a list of ports.')
        ImGui.Separator();

        --
        -- Common Ports
        --
        if ImGui.TreeNode('Common Ports:') then
            wizard.wizard_settings.commonPort01_Enabled = ImGui.Checkbox('Enable##CommonPort01',
                wizard.wizard_settings.commonPort01_Enabled)
            if CommonPort01_Enabled ~= wizard.wizard_settings.commonPort01_Enabled then
                CommonPort01_Enabled = wizard.wizard_settings.commonPort01_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort01_current_idx = GUI.CreateBuffBox:draw("##Common Port:##01",
                wizard.allPorts,
                wizard.wizard_settings.commonPort01_current_idx);
            if CommonPort01_current_idx ~= wizard.wizard_settings.commonPort01_current_idx then
                CommonPort01_current_idx = wizard.wizard_settings.commonPort01_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort01_gem = GUI.CreateComboBox:draw("##Gem:##01", wizard.gemList,
                wizard.wizard_settings.commonPort01_gem, 50);
            if CommonPort01_gem ~= wizard.wizard_settings.commonPort01_gem then
                CommonPort01_gem = wizard.wizard_settings.commonPort01_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            wizard.wizard_settings.commonPort02_Enabled = ImGui.Checkbox('Enable##CommonPort02',
                wizard.wizard_settings.commonPort02_Enabled)
            if CommonPort02_Enabled ~= wizard.wizard_settings.commonPort02_Enabled then
                CommonPort02_Enabled = wizard.wizard_settings.commonPort02_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort02_current_idx = GUI.CreateBuffBox:draw("##Common Port:##02",
                wizard.allPorts,
                wizard.wizard_settings.commonPort02_current_idx);
            if CommonPort02_current_idx ~= wizard.wizard_settings.commonPort02_current_idx then
                CommonPort02_current_idx = wizard.wizard_settings.commonPort02_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort02_gem = GUI.CreateComboBox:draw("##Gem:##02", wizard.gemList,
                wizard.wizard_settings.commonPort02_gem, 50);
            if CommonPort02_gem ~= wizard.wizard_settings.commonPort02_gem then
                CommonPort02_gem = wizard.wizard_settings.commonPort02_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 03
            wizard.wizard_settings.commonPort03_Enabled = ImGui.Checkbox('Enable##CommonPort03',
                wizard.wizard_settings.commonPort03_Enabled)
            if CommonPort03_Enabled ~= wizard.wizard_settings.commonPort03_Enabled then
                CommonPort03_Enabled = wizard.wizard_settings.commonPort03_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort03_current_idx = GUI.CreateBuffBox:draw("##Common Port:##03",
                wizard.allPorts,
                wizard.wizard_settings.commonPort03_current_idx);
            if CommonPort03_current_idx ~= wizard.wizard_settings.commonPort03_current_idx then
                CommonPort03_current_idx = wizard.wizard_settings.commonPort03_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort03_gem = GUI.CreateComboBox:draw("##Gem:##03", wizard.gemList,
                wizard.wizard_settings.commonPort03_gem, 50);
            if CommonPort03_gem ~= wizard.wizard_settings.commonPort03_gem then
                CommonPort03_gem = wizard.wizard_settings.commonPort03_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 04
            wizard.wizard_settings.commonPort04_Enabled = ImGui.Checkbox('Enable##CommonPort04',
                wizard.wizard_settings.commonPort04_Enabled)
            if CommonPort04_Enabled ~= wizard.wizard_settings.commonPort04_Enabled then
                CommonPort04_Enabled = wizard.wizard_settings.commonPort04_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort04_current_idx = GUI.CreateBuffBox:draw("##Common Port:##04",
                wizard.allPorts,
                wizard.wizard_settings.commonPort04_current_idx);
            if CommonPort04_current_idx ~= wizard.wizard_settings.commonPort04_current_idx then
                CommonPort04_current_idx = wizard.wizard_settings.commonPort04_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort04_gem = GUI.CreateComboBox:draw("##Gem:##04", wizard.gemList,
                wizard.wizard_settings.commonPort04_gem, 50);
            if CommonPort04_gem ~= wizard.wizard_settings.commonPort04_gem then
                CommonPort04_gem = wizard.wizard_settings.commonPort04_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 05
            wizard.wizard_settings.commonPort05_Enabled = ImGui.Checkbox('Enable##CommonPort05',
                wizard.wizard_settings.commonPort05_Enabled)
            if CommonPort05_Enabled ~= wizard.wizard_settings.commonPort05_Enabled then
                CommonPort05_Enabled = wizard.wizard_settings.commonPort05_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort05_current_idx = GUI.CreateBuffBox:draw("##Common Port:##05",
                wizard.allPorts,
                wizard.wizard_settings.commonPort05_current_idx);
            if CommonPort05_current_idx ~= wizard.wizard_settings.commonPort05_current_idx then
                CommonPort05_current_idx = wizard.wizard_settings.commonPort05_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort05_gem = GUI.CreateComboBox:draw("##Gem:##05", wizard.gemList,
                wizard.wizard_settings.commonPort05_gem, 50);
            if CommonPort05_gem ~= wizard.wizard_settings.commonPort05_gem then
                CommonPort05_gem = wizard.wizard_settings.commonPort05_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 06
            wizard.wizard_settings.commonPort06_Enabled = ImGui.Checkbox('Enable##CommonPort06',
                wizard.wizard_settings.commonPort06_Enabled)
            if CommonPort06_Enabled ~= wizard.wizard_settings.commonPort06_Enabled then
                CommonPort06_Enabled = wizard.wizard_settings.commonPort06_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort06_current_idx = GUI.CreateBuffBox:draw("##Common Port:##06",
                wizard.allPorts,
                wizard.wizard_settings.commonPort06_current_idx);
            if CommonPort06_current_idx ~= wizard.wizard_settings.commonPort06_current_idx then
                CommonPort06_current_idx = wizard.wizard_settings.commonPort06_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort06_gem = GUI.CreateComboBox:draw("##Gem:##06", wizard.gemList,
                wizard.wizard_settings.commonPort06_gem, 50);
            if CommonPort06_gem ~= wizard.wizard_settings.commonPort06_gem then
                CommonPort06_gem = wizard.wizard_settings.commonPort06_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 07
            wizard.wizard_settings.commonPort07_Enabled = ImGui.Checkbox('Enable##CommonPort07',
                wizard.wizard_settings.commonPort07_Enabled)
            if CommonPort07_Enabled ~= wizard.wizard_settings.commonPort07_Enabled then
                CommonPort07_Enabled = wizard.wizard_settings.commonPort07_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort07_current_idx = GUI.CreateBuffBox:draw("##Common Port:##07",
                wizard.allPorts,
                wizard.wizard_settings.commonPort07_current_idx);
            if CommonPort07_current_idx ~= wizard.wizard_settings.commonPort07_current_idx then
                CommonPort07_current_idx = wizard.wizard_settings.commonPort07_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort07_gem = GUI.CreateComboBox:draw("##Gem:##07", wizard.gemList,
                wizard.wizard_settings.commonPort07_gem, 50);
            if CommonPort07_gem ~= wizard.wizard_settings.commonPort07_gem then
                CommonPort07_gem = wizard.wizard_settings.commonPort07_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 08
            wizard.wizard_settings.commonPort08_Enabled = ImGui.Checkbox('Enable##CommonPort08',
                wizard.wizard_settings.commonPort08_Enabled)
            if CommonPort08_Enabled ~= wizard.wizard_settings.commonPort08_Enabled then
                CommonPort08_Enabled = wizard.wizard_settings.commonPort08_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort08_current_idx = GUI.CreateBuffBox:draw("##Common Port:##08",
                wizard.allPorts,
                wizard.wizard_settings.commonPort08_current_idx);
            if CommonPort08_current_idx ~= wizard.wizard_settings.commonPort08_current_idx then
                CommonPort08_current_idx = wizard.wizard_settings.commonPort08_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort08_gem = GUI.CreateComboBox:draw("##Gem:##08", wizard.gemList,
                wizard.wizard_settings.commonPort08_gem, 50);
            if CommonPort08_gem ~= wizard.wizard_settings.commonPort08_gem then
                CommonPort08_gem = wizard.wizard_settings.commonPort08_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 09
            wizard.wizard_settings.commonPort09_Enabled = ImGui.Checkbox('Enable##CommonPort09',
                wizard.wizard_settings.commonPort09_Enabled)
            if CommonPort09_Enabled ~= wizard.wizard_settings.commonPort09_Enabled then
                CommonPort09_Enabled = wizard.wizard_settings.commonPort09_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort09_current_idx = GUI.CreateBuffBox:draw("##Common Port:##09",
                wizard.allPorts,
                wizard.wizard_settings.commonPort09_current_idx);
            if CommonPort09_current_idx ~= wizard.wizard_settings.commonPort09_current_idx then
                CommonPort09_current_idx = wizard.wizard_settings.commonPort09_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort09_gem = GUI.CreateComboBox:draw("##Gem:##09", wizard.gemList,
                wizard.wizard_settings.commonPort09_gem, 50);
            if CommonPort09_gem ~= wizard.wizard_settings.commonPort09_gem then
                CommonPort09_gem = wizard.wizard_settings.commonPort09_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 10
            wizard.wizard_settings.commonPort10_Enabled = ImGui.Checkbox('Enable##CommonPort10',
                wizard.wizard_settings.commonPort10_Enabled)
            if CommonPort10_Enabled ~= wizard.wizard_settings.commonPort10_Enabled then
                CommonPort10_Enabled = wizard.wizard_settings.commonPort10_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort10_current_idx = GUI.CreateBuffBox:draw("##Common Port:##10",
                wizard.allPorts,
                wizard.wizard_settings.commonPort10_current_idx);
            if CommonPort10_current_idx ~= wizard.wizard_settings.commonPort10_current_idx then
                CommonPort10_current_idx = wizard.wizard_settings.commonPort10_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort10_gem = GUI.CreateComboBox:draw("##Gem:##10", wizard.gemList,
                wizard.wizard_settings.commonPort10_gem, 50);
            if CommonPort10_gem ~= wizard.wizard_settings.commonPort10_gem then
                CommonPort10_gem = wizard.wizard_settings.commonPort10_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 11
            wizard.wizard_settings.commonPort11_Enabled = ImGui.Checkbox('Enable##CommonPort11',
                wizard.wizard_settings.commonPort11_Enabled)
            if CommonPort11_Enabled ~= wizard.wizard_settings.commonPort11_Enabled then
                CommonPort11_Enabled = wizard.wizard_settings.commonPort11_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort11_current_idx = GUI.CreateBuffBox:draw("##Common Port:##11",
                wizard.allPorts,
                wizard.wizard_settings.commonPort11_current_idx);
            if CommonPort11_current_idx ~= wizard.wizard_settings.commonPort11_current_idx then
                CommonPort11_current_idx = wizard.wizard_settings.commonPort11_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort11_gem = GUI.CreateComboBox:draw("##Gem:##11", wizard.gemList,
                wizard.wizard_settings.commonPort11_gem, 50);
            if CommonPort11_gem ~= wizard.wizard_settings.commonPort11_gem then
                CommonPort11_gem = wizard.wizard_settings.commonPort11_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 12
            wizard.wizard_settings.commonPort12_Enabled = ImGui.Checkbox('Enable##CommonPort12',
                wizard.wizard_settings.commonPort12_Enabled)
            if CommonPort12_Enabled ~= wizard.wizard_settings.commonPort12_Enabled then
                CommonPort12_Enabled = wizard.wizard_settings.commonPort12_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort12_current_idx = GUI.CreateBuffBox:draw("##Common Port:##12",
                wizard.allPorts,
                wizard.wizard_settings.commonPort12_current_idx);
            if CommonPort12_current_idx ~= wizard.wizard_settings.commonPort12_current_idx then
                CommonPort12_current_idx = wizard.wizard_settings.commonPort12_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort12_gem = GUI.CreateComboBox:draw("##Gem:##12", wizard.gemList,
                wizard.wizard_settings.commonPort12_gem, 50);
            if CommonPort12_gem ~= wizard.wizard_settings.commonPort12_gem then
                CommonPort12_gem = wizard.wizard_settings.commonPort12_gem
                wizard.saveSettings()
            end
            ImGui.Separator();

            -- Common Port 13
            wizard.wizard_settings.commonPort13_Enabled = ImGui.Checkbox('Enable##CommonPort13',
                wizard.wizard_settings.commonPort13_Enabled)
            if CommonPort13_Enabled ~= wizard.wizard_settings.commonPort13_Enabled then
                CommonPort13_Enabled = wizard.wizard_settings.commonPort13_Enabled
                wizard.saveSettings()
            end
            ImGui.SameLine()
            ImGui.PushItemWidth(400)
            wizard.wizard_settings.commonPort13_current_idx = GUI.CreateBuffBox:draw("##Common Port:##13",
                wizard.allPorts,
                wizard.wizard_settings.commonPort13_current_idx);
            if CommonPort13_current_idx ~= wizard.wizard_settings.commonPort13_current_idx then
                CommonPort13_current_idx = wizard.wizard_settings.commonPort13_current_idx
                wizard.saveSettings()
            end
            ImGui.SameLine()
            wizard.wizard_settings.commonPort13_gem = GUI.CreateComboBox:draw("##Gem:##13", wizard.gemList,
                wizard.wizard_settings.commonPort13_gem, 50);
            if CommonPort13_gem ~= wizard.wizard_settings.commonPort13_gem then
                CommonPort13_gem = wizard.wizard_settings.commonPort13_gem
                wizard.saveSettings()
            end
            ImGui.PushItemWidth(425)
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Help
        --
        if imgui.CollapsingHeader("Wizard Options") then
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

            Settings.portChat = ImGui.InputText('Port Command', Settings.portChat)
            ImGui.SameLine()
            ImGui.HelpMarker('The command used by the Buffer to advertises its capabilities to the player.')
            if PortChat ~= Settings.portChat then
                PortChat = Settings.portChat
                SaveSettings(IniPath, Settings)
            end

            Settings.portMessage = ImGui.InputText('Port Message', Settings.portMessage)
            ImGui.SameLine()
            ImGui.HelpMarker(
                'The message displayed when the Buffer advertises its capabilities to the player. This text is automatically generated based on the ports the Buffer has.')
            if PortMessage ~= Settings.portMessage then
                PortMessage = Settings.portMessage
                SaveSettings(IniPath, Settings)
            end
            ImGui.Separator()

            if imgui.Button('REBUILD##Save File') then
                SaveSettings(iniPath, wizard.wizard_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return wizard
