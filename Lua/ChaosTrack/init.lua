local mq = require('mq')

ChaosTrack = {
    _version = '1.0.1',
    _author = 'TheDroidUrLookingFor'
}
ChaosTrack.MainLoopDelay = 100
ChaosTrack.DoStatTrack = true
ChaosTrack.script_ShortName = 'ChaosTrack'
ChaosTrack.command_ShortName = 'cg'
ChaosTrack.command_LongName = 'ChaosTrack'
ChaosTrack.NewDisconnectHandler = true
ChaosTrack.terminate = false
ChaosTrack.doPause = false
ChaosTrack.ChaoticCounter = 0

ChaosTrack.StartKC = 0
ChaosTrack.StartAA = 0
ChaosTrack.StartTime = os.time()
ChaosTrack.LastReportTime = os.time()
ChaosTrack.MobCounter = 0
ChaosTrack.SlainMobTypes = {}
ChaosTrack.SlainChaoticTypes = {}

ChaosTrack.Open = false
ChaosTrack.ShowUI = false

function ChaosTrack.ReadINI(filename, section, option)
    return mq.TLO.Ini.File(filename).Section(section).Key(option).Value()
end

function ChaosTrack.SetINI(filename, section, option, value)
    print(filename, section, option, value)
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', filename, section, option, value)
end

ChaosTrack.dir_exists = function(path)
    printf('function dir_exists(%s) Entry', path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

ChaosTrack.make_dir = function(path)
    printf('function make_dir(%s) Entry', path)
    local success, errorMsg = os.execute("mkdir \"" .. path .. "\"")
    if success then
        return true
    else
        return false, errorMsg
    end
end

function ChaosTrack.SaveSettings(iniFile, settingsList)
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

ChaosTrack.outputLog = {}
-- Function to add output to the log with a timestamp
function ChaosTrack.addToConsole(text, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")

    -- Handle item links correctly by passing through string.format
    local formattedText = string.format(text, ...)

    -- Add the timestamp to the message
    local logEntry = string.format("%s %s", timestamp, formattedText)

    -- Add the combined message with timestamp to the log
    table.insert(ChaosTrack.outputLog, logEntry)
end

ChaosTrack.CreateComboBox = {
    flags = 0
}

-- Global state variable
local show_main = true -- Main form is visible by default
local dlFullImg = mq.CreateTexture(mq.luaDir .. "/ChaosTrack/Resources/icon.png")

local function event_ct_chaoticCounter_handler(line, mobName)
    ChaosTrack.ChaoticCounter = (ChaosTrack.ChaoticCounter or 0) + 1
    ChaosTrack.SlainChaoticTypes[mobName] = (ChaosTrack.SlainChaoticTypes[mobName] or 0) + 1
end
mq.event('GoblinCheck', "Chaotic#1# twists into a chaotic reflection of itself!#*#", event_ct_chaoticCounter_handler)

local function event_ct_slainMob_handler(line, mobName)
    ChaosTrack.MobCounter = (ChaosTrack.MobCounter or 0) + 1
    ChaosTrack.SlainMobTypes[mobName] = (ChaosTrack.SlainMobTypes[mobName] or 0) + 1
end
mq.event('SlainMob', "#*#You have slain #1#!#*#", event_ct_slainMob_handler)

local function event_ct_aagain_handler(line, gainedPoints)
    local pointsGained = tonumber(gainedPoints) or 1
    ChaosTrack.StartAA = (ChaosTrack.StartAA or 0) + pointsGained
end
mq.event('AACheck', "You have gained #1# ability point(s)!#*#", event_ct_aagain_handler)
mq.event('AACheck2', "You have gained an ability point!#*#", event_ct_aagain_handler)

function ChaosTrack.getElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTimeInSeconds = os.difftime(currentTime, startTime)

    -- Calculate hours, minutes, and seconds
    local hours = math.floor(elapsedTimeInSeconds / 3600)
    local minutes = math.floor((elapsedTimeInSeconds % 3600) / 60)
    local seconds = elapsedTimeInSeconds % 60

    -- Format as HH:MM:SS
    return string.format('%02d:%02d:%02d', hours, minutes, seconds)
end

function ChaosTrack.formatNumberWithCommas(number)
    local formatted = tostring(number)
    -- Use pattern to insert commas
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function ChaosTrack.AAStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosTrack.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local aaPerHour = 0
    if elapsedTimeInHours > 0 then
        aaPerHour = ChaosTrack.StartAA / elapsedTimeInHours
    end

    return ChaosTrack.StartAA, aaPerHour
end

function ChaosTrack.KillStatus(MobKillCount)
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosTrack.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local killsPerHour = 0
    if elapsedTimeInHours > 0 then
        killsPerHour = MobKillCount / elapsedTimeInHours
    end

    return killsPerHour
end

function ChaosTrack.ChaoticStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosTrack.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local chaoticPerHour = 0
    if elapsedTimeInHours > 0 then
        chaoticPerHour = ChaosTrack.ChaoticCounter / elapsedTimeInHours
    end

    return ChaosTrack.ChaoticCounter, chaoticPerHour
end

function ChaosTrack.KillsStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosTrack.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local killsPerHour = 0
    if elapsedTimeInHours > 0 then
        killsPerHour = ChaosTrack.MobCounter / elapsedTimeInHours
    end

    return ChaosTrack.MobCounter, killsPerHour
end

function ChaosTrack.CurrencyStatus()
    -- Get current AA points and current time
    local currentKC = mq.TLO.Me.AltCurrency('Kill Credit')()
    local currentTime = os.time()

    local kcGained = currentKC - ChaosTrack.StartKC

    -- Calculate elapsed time in seconds and convert to hours
    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosTrack.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    -- Prevent division by zero if somehow elapsedTimeInHours is too small
    local kcPerHour = 0
    if elapsedTimeInHours > 0 then
        kcPerHour = kcGained / elapsedTimeInHours
    end

    -- Return both total AA gained and AA per hour
    return kcGained, kcPerHour
end

function ChaosTrack.ChaosGrindGUI()
    if show_main then
        if ChaosTrack.Open then
            ChaosTrack.Open, ChaosTrack.ShowUI = ImGui.Begin('TheDroid Chaos Tracker v' .. ChaosTrack._version, ChaosTrack.Open)
            ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
            local x_size = 620
            local y_size = 680
            local io = ImGui.GetIO()
            local center_x = io.DisplaySize.x / 2
            local center_y = io.DisplaySize.y / 2
            ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
            ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
            if ChaosTrack.ShowUI then
                local windowWidth = ImGui.GetWindowContentRegionWidth()
                local buttonWidth, buttonHeight = 140, 30
                local buttonWidthSmall = 90
                -- Get the elapsed time since ChaosTrack.StartTime
                local formattedElapsedTime = ChaosTrack.getElapsedTime(ChaosTrack.StartTime)
                ImGui.SameLine(250)
                ImGui.Text('Run Time:')
                ImGui.SameLine()
                ImGui.Text(formattedElapsedTime)
                ImGui.Separator();
                local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                ImGui.SetCursorPosX(15)
                if ChaosTrack.doPause then
                    if ImGui.Button('Resume', buttonImVec2) then
                        ChaosTrack.doPause = false
                    end
                else
                    if ImGui.Button('Pause', buttonImVec2) then
                        ChaosTrack.doPause = true
                    end
                end
                ImGui.SameLine()
                local spacing = 60
                local totalCenterWidth = buttonWidthSmall * 3 + spacing * 2
                -- Position cursor to center start
                local centerStartX = (windowWidth - totalCenterWidth) / 2
                ImGui.Dummy(ImVec2(spacing, 0)) -- spacing
                ImGui.SameLine()
                if ImGui.Button('Minimize', buttonImVec2) then
                    show_main = false
                end
                ImGui.SameLine()
                -- Right button (Quit DroidLoot) aligned to right edge
                -- Position cursor at right edge minus button width
                local rightStartX = windowWidth - buttonWidth
                ImGui.SetCursorPosX(rightStartX)
                if ImGui.Button('Quit', ImVec2(buttonWidth, buttonHeight)) then
                    ChaosTrack.terminate = true
                    mq.cmdf('/lua stop %s', 'ChaosTrack')
                end
                ImGui.Separator();

                local totalKC, kcPerHour = ChaosTrack.CurrencyStatus()
                local totalAA, aaPerHour = ChaosTrack.AAStatus()
                local formattedTotalAA = ChaosTrack.formatNumberWithCommas(totalAA)
                local formattedAAPerHour = ChaosTrack.formatNumberWithCommas(math.floor(aaPerHour))
                local formattedCashPerHour = ChaosTrack.formatNumberWithCommas(math.floor(kcPerHour))
                local formattedTotalCash = ChaosTrack.formatNumberWithCommas(totalKC)

                local totalKills, killsPerHour = ChaosTrack.KillsStatus()
                local formattedTotalKills = ChaosTrack.formatNumberWithCommas(totalKills)
                local formattedKillsPerHour = ChaosTrack.formatNumberWithCommas(math.floor(killsPerHour))

                local totalChaotics, chaoticsPerHour = ChaosTrack.ChaoticStatus()
                local formattedTotalChaotics = ChaosTrack.formatNumberWithCommas(totalChaotics)
                local formattedChaoticsPerHour = ChaosTrack.formatNumberWithCommas(chaoticsPerHour)

                ImGui.Text('AA Gained');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedTotalAA));
                ImGui.SameLine(400);
                ImGui.Text('AA / Hour');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedAAPerHour));
                ImGui.Separator();

                ImGui.Text('KC Gained');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedTotalCash));
                ImGui.SameLine(400);
                ImGui.Text('KC / Hour');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedCashPerHour));
                ImGui.Separator();

                ImGui.Text('Mobs Killed');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedTotalKills));
                ImGui.SameLine(400);
                ImGui.Text('Kills / Hour');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedKillsPerHour));
                ImGui.Separator();

                ImGui.Text('Chaotic Spawned');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedTotalChaotics));
                ImGui.SameLine(400);
                ImGui.Text('Chaotic / Hour');
                ImGui.SameLine();
                ImGui.Text(tostring(formattedChaoticsPerHour));
                ImGui.Separator();
                if ImGui.CollapsingHeader('Mob Info') then
                    ImGui.Indent()
                    for mobName, killCount in pairs(ChaosTrack.SlainMobTypes) do
                        local mobKillsPerHour = ChaosTrack.KillStatus(killCount)

                        ImGui.Text(mobName .. ':')
                        ImGui.SameLine()
                        ImGui.Text(tostring(killCount))
                        ImGui.SameLine(400)
                        ImGui.Text('Kills / Hour')
                        ImGui.SameLine()
                        ImGui.Text(string.format("%.2f", mobKillsPerHour))
                        ImGui.Separator()
                    end
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader('Chaotic Mob Info') then
                    ImGui.Indent()
                    for mobName, killCount in pairs(ChaosTrack.SlainChaoticTypes) do
                        local mobKillsPerHour = ChaosTrack.KillStatus(killCount)

                        ImGui.Text(mobName .. ':')
                        ImGui.SameLine()
                        ImGui.Text(tostring(killCount))
                        ImGui.SameLine(400)
                        ImGui.Text('Kills / Hour')
                        ImGui.SameLine()
                        ImGui.Text(string.format("%.2f", mobKillsPerHour))
                        ImGui.Separator()
                    end
                    ImGui.Unindent()
                end
            end
            ImGui.End()
        end
    else
        -- Position once only, no fixed size
        ImGui.SetNextWindowPos(ImVec2(100, 100), ImGuiCond.Once)

        -- Begin with auto resize flag, no title bar, no resize allowed
        local visible, open = ImGui.Begin("Minimized", true, ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.AlwaysAutoResize)

        if visible then
            local buttonWidth, buttonHeight = 20, 20
            local buttonImVec = ImVec2(buttonWidth, buttonHeight)
            if ImGui.Button('-', buttonImVec) then
                show_main = true
            end
            ImGui.SameLine()
            if ImGui.Button('X', buttonImVec) then
                ChaosTrack.terminate = true
                mq.cmdf('/lua stop %s', 'ChaosGrinder')
            end
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(0, 0)) -- No padding inside button
            local buttonColor
            if ChaosTrack.doPause then
                buttonColor = ImVec4(1, 0, 0, 1)
                if ImGui.ImageButton('Resume', dlFullImg:GetTextureID(), ImVec2(44, 44), ImVec2(0.0, 0.0), ImVec2(0.62, 0.62), ImVec4(0, 0, 0, 0), buttonColor) then
                    ChaosTrack.doPause = false
                end
            else
                buttonColor = ImVec4(0, 1, 0, 1)
                if ImGui.ImageButton('Pause', dlFullImg:GetTextureID(), ImVec2(44, 44), ImVec2(0.0, 0.0), ImVec2(0.62, 0.62), ImVec4(0, 0, 0, 0), buttonColor) then
                    ChaosTrack.doPause = true
                end
            end
            ImGui.PopStyleVar()
        end

        ImGui.End()
    end
end

function ChaosTrack.initGUI()
    mq.imgui.init('ChaosTrack', ChaosTrack.ChaosGrindGUI)
    ChaosTrack.Open = true
end

function ChaosTrack.MainLoop()
    ChaosTrack.lastX = mq.TLO.Me.X()
    ChaosTrack.lastY = mq.TLO.Me.Y()
    ChaosTrack.lastZ = mq.TLO.Me.Z()
    ChaosTrack.moveCounter = 0
    ChaosTrack.initGUI()
    print('Chaos Server Chaotic Tracker Starting Up!')
    ChaosTrack.StartKC = mq.TLO.Me.AltCurrency('Kill Credit')()
    ChaosTrack.StartTime = os.time()
    while not ChaosTrack.terminate do
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' then
            -- Add logic later
        else
            if not ChaosTrack.doPause then
                if ChaosTrack.ReportGain then
                    local currentTime = os.time()
                    if os.difftime(currentTime, ChaosTrack.LastReportTime) >= ChaosTrack.ReportAATime then
                        local totalAA, aaPerHour = ChaosTrack.AAStatus()
                        printf('Total AA gained: %d', totalAA)
                        printf('Current AA per hour: %.2f', aaPerHour)
                        ChaosTrack.LastReportTime = currentTime -- Update the last report time
                    end
                end
                mq.doevents()
            end
        end
        mq.delay(ChaosTrack.MainLoopDelay)
    end
end

ChaosTrack.MainLoop()
return ChaosTrack
