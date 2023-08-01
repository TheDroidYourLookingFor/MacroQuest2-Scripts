local mq = require('mq')
---@type ImGui
local ImGui = require 'ImGui'
local args = { ... }
local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
local command_ShortName = 'tdc'

local TheDroidControlPanel = {}
TheDroidControlPanel.MainLoop = true
TheDroidControlPanel.BotRunning = true
TheDroidControlPanel.IniPath = mq.configDir .. '\\TheDroidControlPanel_' .. my_Name .. '.ini'
TheDroidControlPanel.Debug = false

TheDroidControlPanel.Settings = {
    debug = TheDroidControlPanel.Debug,
    version = '1.0.1',
}

function HasTimePassed(startTime, seconds)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime

    return elapsedTime >= seconds
end

function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = 'TDC'
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    if TheDroidControlPanel.Settings.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

local function PRINTMETHOD(printMessage, ...)
    printf("[TDC] " .. printMessage, ...)
end

function SaveSettings(iniFile, settingsList)
    CONSOLEMETHOD('function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function Setup()
    CONSOLEMETHOD('function Setup() Entry')
    local conf
    local configData, err = loadfile(TheDroidControlPanel.IniPath)
    if err then
        SaveSettings(TheDroidControlPanel.IniPath, TheDroidControlPanel.Settings)
    elseif configData then
        conf = configData()
        TheDroidControlPanel.Settings = conf
    end
end
Setup()

function TheDroidControlPanel.ReadINI(filename, section, option)
    return mq.TLO.Ini.File(filename).Section(section).Key(option).Value()
end

function TheDroidControlPanel.SetINI(filename, section, option, value)
    print(filename, section, option, value)
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', filename, section, option, value)
end

function TheDroidControlPanel.NavToTarget(navTarget)
    PRINTMETHOD('Moving to %s.', navTarget)
    mq.cmd('/nav target')
    while mq.TLO.Navigation.Active() do
        if (mq.TLO.Spawn(navTarget).Distance3D() < 20) then
            mq.cmd('/nav stop')
        end
        mq.delay(50)
    end
end

local function split(input, sep)
    if sep == nil then
        sep = "|"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function DanNetQuery(peer, query, timeout)
    mq.cmdf('/dquery %s -q "%s"', peer, query)
    mq.delay(timeout)
    local value = mq.TLO.DanNet(peer).Q(query)()
    return value
end
local DanNetClients = {}
local function CheckDanNetClients()
    local DanNetClientInfo = {}
    local toons = split(mq.TLO.DanNet.Peers())
    for _, toon in ipairs(toons) do
        table.insert(DanNetClientInfo, toon)
    end
    return DanNetClientInfo
end
local function DanNetCharInfo()
    DanNetClients = {}
    local toons = split(mq.TLO.DanNet.Peers())
    for _, toon in ipairs(toons) do
        table.insert(DanNetClients,
            { toon, DanNetQuery(toon, 'Zone', 25), DanNetQuery(toon, 'Me.Level', 25), DanNetQuery(toon, 'Me.Class', 25),
                DanNetQuery(toon, 'Macro', 25), DanNetQuery(toon, 'Me.AAPoints', 25),
                DanNetQuery(toon, 'Me.AAPointsTotal', 25) })
    end

    DanNetLastPollTime = os.time()
    return DanNetClients
end

local TABLE_FLAGS = bit32.bor(ImGuiTableFlags.ScrollY, ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter,
    ImGuiTableFlags.BordersV, ImGuiTableFlags.SizingStretchSame, ImGuiTableFlags.Sortable,
    ImGuiTableFlags.Hideable, ImGuiTableFlags.Resizable, ImGuiTableFlags.Reorderable)
local WINDOW_FLAGS = bit32.bor(ImGuiCond.Once, ImGuiCond.Appearing, ImGuiCond.FirstUseEver)

CurrentStatus = ' '
local Open = false
local ShowUI = false
local x_size = 850
local y_size = 550
local io = ImGui.GetIO()
local center_x = io.DisplaySize.x / 2
local center_y = io.DisplaySize.y / 2
local function TheDroidControlPanelGUI()
    if Open then
        Open, ShowUI = ImGui.Begin('TheDroid Control Panel v' .. TheDroidControlPanel.Settings.version, Open)
        center_x = io.DisplaySize.x / 2
        center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, WINDOW_FLAGS)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, WINDOW_FLAGS)
        if TheDroidControlPanel.Settings.debug then
            ImGui.SetWindowSize(x_size, y_size, ImGuiCond.Always)
            ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.Always)
        end
        if ShowUI then
            local buttonWidth, buttonHeight = 150, 30
            local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
            if TheDroidControlPanel.BotRunning then
                if ImGui.Button('Pause', buttonImVec2) then
                    TheDroidControlPanel.BotRunning = false
                end
            else
                if ImGui.Button('Resume', buttonImVec2) then
                    TheDroidControlPanel.BotRunning = true
                end
            end
            ImGui.SameLine(250)
            ImGui.Spacing()
            ImGui.SameLine()
            ImGui.Text(CurrentStatus);
            local windowSizeX, windowSizeY = ImGui.GetWindowSize()
            ImGui.SameLine(windowSizeX - 165)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Quit TDC', buttonImVec2) then
                TheDroidControlPanel.MainLoop = false
            end
            ImGui.Spacing()

            if ImGui.CollapsingHeader("Self") then
                ImGui.Text('')
                ImGui.SameLine(windowSizeX * 0.50 - 25)
                ImGui.Text('RGMercs')
                if ImGui.BeginTable('self##RGMercs', 6, TABLE_FLAGS, windowSizeX - 15, 70) then
                    buttonWidth, buttonHeight = windowSizeX / 6 - 12, 30
                    buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                    ImGui.TableNextColumn()
                    if ImGui.Button('Start##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rgstart')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Stop##' .. my_Name, buttonImVec2) then
                        mq.cmd('/end')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('RG ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg on')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('RG OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg off')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('PULL ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg DoPull 1')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('PULL OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg DoPull 0')
                    end
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp Here##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg CampHere')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp Hard##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg CampHard')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg CampOff')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Chase ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg ChaseOn')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Chase OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/rg ChaseOff')
                    end
                    ImGui.EndTable()
                end

                ImGui.Spacing()

                ImGui.Text('')
                ImGui.SameLine(windowSizeX * 0.50 - 27)
                ImGui.Text('KissAssist')
                if ImGui.BeginTable('self##KISSASSIST', 6, TABLE_FLAGS, windowSizeX - 15, 70) then
                    buttonWidth, buttonHeight = windowSizeX / 6 - 12, 30
                    buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                    ImGui.TableNextColumn()
                    if ImGui.Button('Start##' .. my_Name, buttonImVec2) then
                        mq.cmd('/macro KissAssist')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Stop##' .. my_Name, buttonImVec2) then
                        mq.cmd('/end')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CAMP ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/camphere on')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CAMP OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/camphere off')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CHASE ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/chaseon')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CHASE OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/chaseoff')
                    end
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    if ImGui.Button('LOOT ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/looton 1')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('LOOT OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/looton 0')
                    end
                    ImGui.EndTable()
                end
            end
            if ImGui.CollapsingHeader("All") then
                if CheckDanNetClients()[1] ~= nil then
                    if ImGui.BeginTable('allClients##', 9, TABLE_FLAGS, windowSizeX - 15, windowSizeY * 0.50) then
                        buttonWidth, buttonHeight = 75, 30
                        buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                        local ColumnID_Name = 0
                        local ColumnID_Follow = 1
                        local ColumnID_ComeToMe = 2
                        local ColumnID_GiveToMe = 3
                        local ColumnID_RGMercs = 4
                        local ColumnID_KissAssist = 5
                        local ColumnID_AutoLooter = 6
                        local ColumnID_EndMacro = 7
                        local ColumnID_StopLua = 8
                        ImGui.TableSetupScrollFreeze(0, 1)
                        ImGui.TableSetupColumn('Name', ImGuiTableColumnFlags.DefaultSort, 4, ColumnID_Name)
                        ImGui.TableSetupColumn('Follow', ImGuiTableColumnFlags.None, 2, ColumnID_Follow)
                        ImGui.TableSetupColumn('Come to Me', ImGuiTableColumnFlags.None, 2, ColumnID_ComeToMe)
                        ImGui.TableSetupColumn('Give to Me', ImGuiTableColumnFlags.None, 2, ColumnID_GiveToMe)
                        ImGui.TableSetupColumn('RGMercs', ImGuiTableColumnFlags.None, 2, ColumnID_RGMercs)
                        ImGui.TableSetupColumn('KissAssist', ImGuiTableColumnFlags.None, 2, ColumnID_KissAssist)
                        ImGui.TableSetupColumn('AutoLoot', ImGuiTableColumnFlags.None, 2, ColumnID_AutoLooter)
                        ImGui.TableSetupColumn('Macro', ImGuiTableColumnFlags.None, 2, ColumnID_EndMacro)
                        ImGui.TableSetupColumn('Lua', ImGuiTableColumnFlags.None, 2, ColumnID_StopLua)
                        ImGui.TableHeadersRow()
                        for i, toon in ipairs(CheckDanNetClients()) do
                            ImGui.TableNextRow()

                            ImGui.TableNextColumn()
                            ImGui.Text(toon)
                            ImGui.SameLine()
                            local toon_Name = ' '
                            local toon_Zone = ' '
                            local toon_Level = ' '
                            local toon_Class = ' '
                            local toon_Macro = ' '
                            local toon_AAPoints = ' '
                            local toon_AAPointsSpent = ' '

                            if DanNetClients[i] ~= nil then
                                local toon_Info = DanNetClients[i]
                                toon_Name = toon_Info[1] or ' '
                                toon_Zone = toon_Info[2] or ' '
                                toon_Level = toon_Info[3] or ' '
                                toon_Class = toon_Info[4] or ' '
                                toon_Macro = toon_Info[5] or ' '
                                toon_AAPoints = toon_Info[6] or ' '
                                toon_AAPointsSpent = toon_Info[7] or ' '
                            end
                            ImGui.HelpMarker('Name: ' .. toon_Name .. '\n' ..
                                'Class: ' .. toon_Class .. '\n' ..
                                'Level: ' .. toon_Level .. '\n' ..
                                'AA Free: ' .. toon_AAPoints .. '\n' ..
                                'AA Spent: ' .. toon_AAPointsSpent .. '\n' ..
                                'Macro: ' .. toon_Macro .. '\n' ..
                                'Zone: ' .. toon_Zone .. '\n')

                            ImGui.TableNextColumn()
                            if ImGui.Button('Follow##' .. toon, buttonImVec2) then
                                mq.cmdf('/dex %s /afol %s', toon, mq.TLO.Me.ID())
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('Come##' .. toon, buttonImVec2) then
                                mq.cmdf('/dex %s /nav ID %s', toon, mq.TLO.Me.ID())
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('Give##' .. toon, buttonImVec2) then
                                mq.cmdf('/lua run GTM %s', my_Name)
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('RGMercs##' .. toon, buttonImVec2) then
                                mq.cmd('/rgstart')
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('KissAssist##' .. toon, buttonImVec2) then
                                mq.cmdf('/target %s pc', my_Name)
                                mq.cmd('/macro KissAssist')
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('AutoLoot##' .. toon, buttonImVec2) then
                                mq.cmd('/lua run lootnscoot standalone')
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('End##Macro' .. toon, buttonImVec2) then
                                mq.cmd('/end')
                            end

                            ImGui.TableNextColumn()
                            if ImGui.Button('End##Lua' .. toon, buttonImVec2) then
                                mq.cmd('/lua stop')
                            end
                        end
                        ImGui.EndTable()
                    end
                    ImGui.Spacing()
                end
            end
            if ImGui.CollapsingHeader("Group") then
                ImGui.Text('')
                ImGui.SameLine(windowSizeX * 0.50 - 25)
                ImGui.Text('RGMercs')
                if ImGui.BeginTable('group##RGMercs', 6, TABLE_FLAGS, windowSizeX - 15, 70) then
                    buttonWidth, buttonHeight = windowSizeX / 6 - 12, 30
                    buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                    ImGui.TableNextColumn()
                    if ImGui.Button('Start##' .. my_Name, buttonImVec2) then
                        mq.cmdf('/target %s pc', my_Name)
                        mq.cmd('/dgga /rgstart')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Stop##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /end')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('RG ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg on')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('RG OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg off')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('PULL ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg DoPull 1')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('PULL OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg DoPull 0')
                    end
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp Here##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg CampHere')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp Hard##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg CampHard')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg CampOff')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Chase ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg ChaseOn')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Chase OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /rg ChaseOff')
                    end
                    ImGui.EndTable()
                end

                ImGui.Spacing()

                ImGui.Text('')
                ImGui.SameLine(windowSizeX * 0.50 - 27)
                ImGui.Text('KissAssist')
                if ImGui.BeginTable('group##KISSASSIST', 6, TABLE_FLAGS, windowSizeX - 15, 70) then
                    buttonWidth, buttonHeight = windowSizeX / 6 - 12, 30
                    buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                    ImGui.TableNextColumn()
                    if ImGui.Button('Start##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /macro KissAssist')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Stop##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /end')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CAMP ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /camphere on')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CAMP OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /camphere off')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CHASE ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /chaseon')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CHASE OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /chaseoff')
                    end
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    if ImGui.Button('LOOT ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /looton 1')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('LOOT OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /looton 0')
                    end
                    ImGui.EndTable()
                end
            end
            if ImGui.CollapsingHeader("Raid") then
                ImGui.Text('')
                ImGui.SameLine(windowSizeX * 0.50 - 25)
                ImGui.Text('RGMercs')
                if ImGui.BeginTable('group##RGMercs', 6, TABLE_FLAGS, windowSizeX - 15, 70) then
                    buttonWidth, buttonHeight = windowSizeX / 6 - 12, 30
                    buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                    ImGui.TableNextColumn()
                    if ImGui.Button('Start##' .. my_Name, buttonImVec2) then
                        mq.cmdf('/target %s pc', my_Name)
                        mq.cmd('/dgra /rgstart')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Stop##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /end')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('RG ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg on')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('RG OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg off')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('PULL ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg DoPull 1')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('PULL OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg DoPull 0')
                    end
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp Here##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg CampHere')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp Hard##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg CampHard')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Camp OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg CampOff')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Chase ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg ChaseOn')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Chase OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgra /rg ChaseOff')
                    end
                    ImGui.EndTable()
                end

                ImGui.Spacing()

                ImGui.Text('')
                ImGui.SameLine(windowSizeX * 0.50 - 27)
                ImGui.Text('KissAssist')
                if ImGui.BeginTable('group##KISSASSIST', 6, TABLE_FLAGS, windowSizeX - 15, 70) then
                    buttonWidth, buttonHeight = windowSizeX / 6 - 12, 30
                    buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                    ImGui.TableNextColumn()
                    if ImGui.Button('Start##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /macro KissAssist')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('Stop##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /end')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CAMP ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /camphere on')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CAMP OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /camphere off')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CHASE ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /chaseon')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('CHASE OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /chaseoff')
                    end
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    if ImGui.Button('LOOT ON##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /looton 1')
                    end
                    ImGui.TableNextColumn()
                    if ImGui.Button('LOOT OFF##' .. my_Name, buttonImVec2) then
                        mq.cmd('/dgga /looton 0')
                    end
                    ImGui.EndTable()
                end
            end

            if ImGui.CollapsingHeader("Options") then
                TheDroidControlPanel.Settings.debug = ImGui.Checkbox('Enable Debug Messages',
                    TheDroidControlPanel.Settings.debug)
                ImGui.SameLine()
                ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                if TheDroidControlPanel.Debug ~= TheDroidControlPanel.Settings.debug then
                    TheDroidControlPanel.Debug = TheDroidControlPanel.Settings.debug
                    SaveSettings(TheDroidControlPanel.IniPath, TheDroidControlPanel.Settings)
                end
                ImGui.Separator();
                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
            end
        end
        ImGui.End()
    end
end
mq.imgui.init('TDC', TheDroidControlPanelGUI)
Open = true

local function tdc_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            if Open then
                PRINTMETHOD('Hiding Buff Bot GUI')
                Open = false
            else
                PRINTMETHOD('Restoring Buff Bot GUI')
                Open = true
            end
            return
        elseif args[1] == 'quit' then
            TheDroidControlPanel.MainLoop = false
            return
        else
            PRINTMETHOD('Valid Commands:')
            PRINTMETHOD('/%s gui - Toggles the Control Panel GUI',command_ShortName)
            PRINTMETHOD('/%s quit - Quits the Control Panel lua script.',command_ShortName)
        end
    else
        PRINTMETHOD('Valid Commands:')
        PRINTMETHOD('/%s gui - Toggles the Control Panel GUI',command_ShortName)
        PRINTMETHOD('/%s quit - Quits the Control Panel lua script.',command_ShortName)
    end
end
mq.bind('/'..command_ShortName, tdc_command)

-- Example usage
local DanNetLastPollTime = os.time() -- Store the current time
local waitTime = 10                  -- Number of seconds to wait
DanNetCharInfo()

PRINTMETHOD('+ Initialized ++')
PRINTMETHOD('++ THE DROID CONTROL PANEL STARTED ++')

CONSOLEMETHOD('Main Loop Entry')
while TheDroidControlPanel.MainLoop do
    if HasTimePassed(DanNetLastPollTime, waitTime) then
        DanNetCharInfo()
        DanNetLastPollTime = os.time()
    end
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then TheDroidControlPanel.MainLoop = false end
    if TheDroidControlPanel.BotRunning then
        if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
        mq.doevents()
    end
    mq.delay(250)
    if not ShowUI then return end
end
CONSOLEMETHOD('Main Loop Exit')
mq.unbind('/'..command_ShortName)

return TheDroidControlPanel
