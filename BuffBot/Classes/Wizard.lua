---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
local wizard = {}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

wizard.portsList = {}
function wizard.CheckForPort()
    wizard.portsList = {}
    for spellBookSlot = 1, 1440 do
        if mq.TLO.Me.Book(spellBookSlot).Name() ~= nil then
            if string.find(mq.TLO.Me.Book(spellBookSlot).Name(), 'Translocate') then
                if not mq.TLO.Me.Gem(mq.TLO.Me.Book(spellBookSlot).Name())() then
                    local portName = mq.TLO.Me.Book(spellBookSlot).Name()
                    table.insert(wizard.portsList, portName)
                end
            end
        end
    end
    table.sort(wizard.portsList)
end

function wizard.BuildPortText()
    wizard.CheckForPort()
    local out_Ports = 'Available Translocates:'
    for _, port in ipairs(wizard.portsList) do
        local portNameShort = string.gsub(port, 'Translocate: ', '')
        out_Ports = out_Ports .. ' ' .. portNameShort .. ','
    end
    out_Ports = string.sub(out_Ports, 1, -2)
    return out_Ports
end

wizard.gemList = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13
}

wizard.CheckForPort()
wizard.wizard_settings = {
    runDebug = DEBUG,
    maxGems = mq.TLO.Me.NumGems(),
    portList = wizard.portsList,
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
    commonPort01 = '',
    commonPort02 = '',
    commonPort03 = '',
    commonPort04 = '',
    commonPort05 = '',
    commonPort06 = '',
    commonPort07 = '',
    commonPort08 = '',
    commonPort09 = '',
    commonPort10 = '',
    commonPort11 = '',
    commonPort12 = '',
    commonPort13 = '',
    commonPort01_gem = '1',
    commonPort02_gem = '2',
    commonPort03_gem = '3',
    commonPort04_gem = '4',
    commonPort05_gem = '5',
    commonPort06_gem = '6',
    commonPort07_gem = '7',
    commonPort08_gem = '8',
    commonPort09_gem = '9',
    commonPort10_gem = '10',
    commonPort11_gem = '11',
    commonPort12_gem = '12',
    commonPort13_gem = '13',
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

local function saveWizardSettings()
    SaveSettings(iniPath, wizard.wizard_settings)
end

local function setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        saveWizardSettings()
    elseif configData then
        conf = configData()
        wizard.wizard_settings = conf
    end
end
setup()

wizard.CreateBuffBox = {
    flags = 0
}

function wizard.CreateBuffBox:draw(cb_label, buffs, current_idx)
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

function wizard.ShowWizardBuffbot()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Wizard") then
        ImGui.Text("Paladin Module:");
        ImGui.BulletText("This module will be available shortly.");
        ImGui.Separator();
    end
    --
    -- Common Ports
    --
    if ImGui.TreeNode('Common Ports:') then
        wizard.wizard_settings.commonPort01_Enabled = ImGui.Checkbox('Enable##CommonPort01',
            wizard.wizard_settings.commonPort01_Enabled)
        if CommonPort01_Enabled ~= wizard.wizard_settings.commonPort01_Enabled then
            CommonPort01_Enabled = wizard.wizard_settings.commonPort01_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort01_current_idx = wizard.CreateBuffBox:draw("Common Port:##01", wizard.portsList,
            wizard.wizard_settings.commonPort01_current_idx);
        if CommonPort01_current_idx ~= wizard.wizard_settings.commonPort01_current_idx then
            CommonPort01_current_idx = wizard.wizard_settings.commonPort01_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort01_gem = wizard.CreateBuffBox:draw("Gem:##01", wizard.gemList,
            wizard.wizard_settings.commonPort01_gem);
        if CommonPort01_gem ~= wizard.wizard_settings.commonPort01_gem then
            CommonPort01_gem = wizard.wizard_settings.commonPort01_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        wizard.wizard_settings.commonPort02_Enabled = ImGui.Checkbox('Enable##CommonPort02',
            wizard.wizard_settings.commonPort02_Enabled)
        if CommonPort02_Enabled ~= wizard.wizard_settings.commonPort02_Enabled then
            CommonPort02_Enabled = wizard.wizard_settings.commonPort02_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort02_current_idx = wizard.CreateBuffBox:draw("Common Port:##02", wizard.portsList,
            wizard.wizard_settings.commonPort02_current_idx);
        if CommonPort02_current_idx ~= wizard.wizard_settings.commonPort02_current_idx then
            CommonPort02_current_idx = wizard.wizard_settings.commonPort02_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort02_gem = wizard.CreateBuffBox:draw("Gem:##02", wizard.gemList,
            wizard.wizard_settings.commonPort02_gem);
        if CommonPort02_gem ~= wizard.wizard_settings.commonPort02_gem then
            CommonPort02_gem = wizard.wizard_settings.commonPort02_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 03
        wizard.wizard_settings.commonPort03_Enabled = ImGui.Checkbox('Enable##CommonPort03',
            wizard.wizard_settings.commonPort03_Enabled)
        if CommonPort03_Enabled ~= wizard.wizard_settings.commonPort03_Enabled then
            CommonPort03_Enabled = wizard.wizard_settings.commonPort03_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort03_current_idx = wizard.CreateBuffBox:draw("Common Port:##03", wizard.portsList,
            wizard.wizard_settings.commonPort03_current_idx);
        if CommonPort03_current_idx ~= wizard.wizard_settings.commonPort03_current_idx then
            CommonPort03_current_idx = wizard.wizard_settings.commonPort03_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort03_gem = wizard.CreateBuffBox:draw("Gem:##03", wizard.gemList,
            wizard.wizard_settings.commonPort03_gem);
        if CommonPort03_gem ~= wizard.wizard_settings.commonPort03_gem then
            CommonPort03_gem = wizard.wizard_settings.commonPort03_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 04
        wizard.wizard_settings.commonPort04_Enabled = ImGui.Checkbox('Enable##CommonPort04',
            wizard.wizard_settings.commonPort04_Enabled)
        if CommonPort04_Enabled ~= wizard.wizard_settings.commonPort04_Enabled then
            CommonPort04_Enabled = wizard.wizard_settings.commonPort04_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort04_current_idx = wizard.CreateBuffBox:draw("Common Port:##04", wizard.portsList,
            wizard.wizard_settings.commonPort04_current_idx);
        if CommonPort04_current_idx ~= wizard.wizard_settings.commonPort04_current_idx then
            CommonPort04_current_idx = wizard.wizard_settings.commonPort04_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort04_gem = wizard.CreateBuffBox:draw("Gem:##04", wizard.gemList,
            wizard.wizard_settings.commonPort04_gem);
        if CommonPort04_gem ~= wizard.wizard_settings.commonPort04_gem then
            CommonPort04_gem = wizard.wizard_settings.commonPort04_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 05
        wizard.wizard_settings.commonPort05_Enabled = ImGui.Checkbox('Enable##CommonPort05',
            wizard.wizard_settings.commonPort05_Enabled)
        if CommonPort05_Enabled ~= wizard.wizard_settings.commonPort05_Enabled then
            CommonPort05_Enabled = wizard.wizard_settings.commonPort05_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort05_current_idx = wizard.CreateBuffBox:draw("Common Port:##05", wizard.portsList,
            wizard.wizard_settings.commonPort05_current_idx);
        if CommonPort05_current_idx ~= wizard.wizard_settings.commonPort05_current_idx then
            CommonPort05_current_idx = wizard.wizard_settings.commonPort05_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort05_gem = wizard.CreateBuffBox:draw("Gem:##05", wizard.gemList,
            wizard.wizard_settings.commonPort05_gem);
        if CommonPort05_gem ~= wizard.wizard_settings.commonPort05_gem then
            CommonPort05_gem = wizard.wizard_settings.commonPort05_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 06
        wizard.wizard_settings.commonPort06_Enabled = ImGui.Checkbox('Enable##CommonPort06',
            wizard.wizard_settings.commonPort06_Enabled)
        if CommonPort06_Enabled ~= wizard.wizard_settings.commonPort06_Enabled then
            CommonPort06_Enabled = wizard.wizard_settings.commonPort06_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort06_current_idx = wizard.CreateBuffBox:draw("Common Port:##06", wizard.portsList,
            wizard.wizard_settings.commonPort06_current_idx);
        if CommonPort06_current_idx ~= wizard.wizard_settings.commonPort06_current_idx then
            CommonPort06_current_idx = wizard.wizard_settings.commonPort06_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort06_gem = wizard.CreateBuffBox:draw("Gem:##06", wizard.gemList,
            wizard.wizard_settings.commonPort06_gem);
        if CommonPort06_gem ~= wizard.wizard_settings.commonPort06_gem then
            CommonPort06_gem = wizard.wizard_settings.commonPort06_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 07
        wizard.wizard_settings.commonPort07_Enabled = ImGui.Checkbox('Enable##CommonPort07',
            wizard.wizard_settings.commonPort07_Enabled)
        if CommonPort07_Enabled ~= wizard.wizard_settings.commonPort07_Enabled then
            CommonPort07_Enabled = wizard.wizard_settings.commonPort07_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort07_current_idx = wizard.CreateBuffBox:draw("Common Port:##07", wizard.portsList,
            wizard.wizard_settings.commonPort07_current_idx);
        if CommonPort07_current_idx ~= wizard.wizard_settings.commonPort07_current_idx then
            CommonPort07_current_idx = wizard.wizard_settings.commonPort07_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort07_gem = wizard.CreateBuffBox:draw("Gem:##07", wizard.gemList,
            wizard.wizard_settings.commonPort07_gem);
        if CommonPort07_gem ~= wizard.wizard_settings.commonPort07_gem then
            CommonPort07_gem = wizard.wizard_settings.commonPort07_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 08
        wizard.wizard_settings.commonPort08_Enabled = ImGui.Checkbox('Enable##CommonPort08',
            wizard.wizard_settings.commonPort08_Enabled)
        if CommonPort08_Enabled ~= wizard.wizard_settings.commonPort08_Enabled then
            CommonPort08_Enabled = wizard.wizard_settings.commonPort08_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort08_current_idx = wizard.CreateBuffBox:draw("Common Port:##08", wizard.portsList,
            wizard.wizard_settings.commonPort08_current_idx);
        if CommonPort08_current_idx ~= wizard.wizard_settings.commonPort08_current_idx then
            CommonPort08_current_idx = wizard.wizard_settings.commonPort08_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort08_gem = wizard.CreateBuffBox:draw("Gem:##08", wizard.gemList,
            wizard.wizard_settings.commonPort08_gem);
        if CommonPort08_gem ~= wizard.wizard_settings.commonPort08_gem then
            CommonPort08_gem = wizard.wizard_settings.commonPort08_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 09
        wizard.wizard_settings.commonPort09_Enabled = ImGui.Checkbox('Enable##CommonPort09',
            wizard.wizard_settings.commonPort09_Enabled)
        if CommonPort09_Enabled ~= wizard.wizard_settings.commonPort09_Enabled then
            CommonPort09_Enabled = wizard.wizard_settings.commonPort09_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort09_current_idx = wizard.CreateBuffBox:draw("Common Port:##09", wizard.portsList,
            wizard.wizard_settings.commonPort09_current_idx);
        if CommonPort09_current_idx ~= wizard.wizard_settings.commonPort09_current_idx then
            CommonPort09_current_idx = wizard.wizard_settings.commonPort09_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort09_gem = wizard.CreateBuffBox:draw("Gem:##09", wizard.gemList,
            wizard.wizard_settings.commonPort09_gem);
        if CommonPort09_gem ~= wizard.wizard_settings.commonPort09_gem then
            CommonPort09_gem = wizard.wizard_settings.commonPort09_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 10
        wizard.wizard_settings.commonPort10_Enabled = ImGui.Checkbox('Enable##CommonPort10',
            wizard.wizard_settings.commonPort10_Enabled)
        if CommonPort10_Enabled ~= wizard.wizard_settings.commonPort10_Enabled then
            CommonPort10_Enabled = wizard.wizard_settings.commonPort10_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort10_current_idx = wizard.CreateBuffBox:draw("Common Port:##10", wizard.portsList,
            wizard.wizard_settings.commonPort10_current_idx);
        if CommonPort10_current_idx ~= wizard.wizard_settings.commonPort10_current_idx then
            CommonPort10_current_idx = wizard.wizard_settings.commonPort10_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort10_gem = wizard.CreateBuffBox:draw("Gem:##10", wizard.gemList,
            wizard.wizard_settings.commonPort10_gem);
        if CommonPort10_gem ~= wizard.wizard_settings.commonPort10_gem then
            CommonPort10_gem = wizard.wizard_settings.commonPort10_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 11
        wizard.wizard_settings.commonPort11_Enabled = ImGui.Checkbox('Enable##CommonPort11',
            wizard.wizard_settings.commonPort11_Enabled)
        if CommonPort11_Enabled ~= wizard.wizard_settings.commonPort11_Enabled then
            CommonPort11_Enabled = wizard.wizard_settings.commonPort11_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort11_current_idx = wizard.CreateBuffBox:draw("Common Port:##11", wizard.portsList,
            wizard.wizard_settings.commonPort11_current_idx);
        if CommonPort11_current_idx ~= wizard.wizard_settings.commonPort11_current_idx then
            CommonPort11_current_idx = wizard.wizard_settings.commonPort11_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort11_gem = wizard.CreateBuffBox:draw("Gem:##11", wizard.gemList,
            wizard.wizard_settings.commonPort11_gem);
        if CommonPort11_gem ~= wizard.wizard_settings.commonPort11_gem then
            CommonPort11_gem = wizard.wizard_settings.commonPort11_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 12
        wizard.wizard_settings.commonPort12_Enabled = ImGui.Checkbox('Enable##CommonPort12',
            wizard.wizard_settings.commonPort12_Enabled)
        if CommonPort12_Enabled ~= wizard.wizard_settings.commonPort12_Enabled then
            CommonPort12_Enabled = wizard.wizard_settings.commonPort12_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort12_current_idx = wizard.CreateBuffBox:draw("Common Port:##12", wizard.portsList,
            wizard.wizard_settings.commonPort12_current_idx);
        if CommonPort12_current_idx ~= wizard.wizard_settings.commonPort12_current_idx then
            CommonPort12_current_idx = wizard.wizard_settings.commonPort12_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort12_gem = wizard.CreateBuffBox:draw("Gem:##12", wizard.gemList,
            wizard.wizard_settings.commonPort12_gem);
        if CommonPort12_gem ~= wizard.wizard_settings.commonPort12_gem then
            CommonPort12_gem = wizard.wizard_settings.commonPort12_gem
            saveWizardSettings()
        end
        ImGui.Separator();

        -- Common Port 13
        wizard.wizard_settings.commonPort13_Enabled = ImGui.Checkbox('Enable##CommonPort13',
            wizard.wizard_settings.commonPort13_Enabled)
        if CommonPort13_Enabled ~= wizard.wizard_settings.commonPort13_Enabled then
            CommonPort13_Enabled = wizard.wizard_settings.commonPort13_Enabled
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort13_current_idx = wizard.CreateBuffBox:draw("Common Port:##13", wizard.portsList,
            wizard.wizard_settings.commonPort13_current_idx);
        if CommonPort13_current_idx ~= wizard.wizard_settings.commonPort13_current_idx then
            CommonPort13_current_idx = wizard.wizard_settings.commonPort13_current_idx
            saveWizardSettings()
        end
        ImGui.SameLine()
        wizard.wizard_settings.commonPort13_gem = wizard.CreateBuffBox:draw("Gem:##13", wizard.gemList,
            wizard.wizard_settings.commonPort13_gem);
        if CommonPort13_gem ~= wizard.wizard_settings.commonPort13_gem then
            CommonPort13_gem = wizard.wizard_settings.commonPort13_gem
            saveWizardSettings()
        end
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

return wizard
