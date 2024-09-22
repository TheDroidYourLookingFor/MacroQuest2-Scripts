---@type Mq
local mq = require('mq')
local gui = {}

gui.version = '1.0.0'

gui.DEBUG = false
gui.PAUSEMACRO = false
gui.BANKDEPOSIT = false
gui.BANKATFREESLOTS = 5
gui.BANKZONE = 451
gui.BANKNPC = 'Griphook'
gui.SCANRADIUS = 10000
gui.SCANZRADIUS = 250
gui.RETURNTOCAMPDISTANCE = 200
gui.CAMPCHECK = false
gui.ZONECHECK = true
gui.LOOTGROUNDSPAWNS = true
gui.RETURNHOMEAFTERLOOT = false
gui.DOSTAND = true
gui.LOOTALL = false
gui.TARGETNAME = 'treasure'
gui.SPAWNSEARCH = '%s radius %d zradius %d'

gui.Open = false
gui.ShowUI = false

gui.outputLog = {}
-- Function to add output to the log with a timestamp
function gui.addToConsole(text, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")
    -- Combine all arguments into a single string
    local combinedText = string.format(text, ...)
    -- Add the timestamp to the message
    local logEntry = string.format("%s %s", timestamp, combinedText)
    -- Add the combined message with timestamp to the log
    table.insert(gui.outputLog, logEntry)
end

function gui.FableLooterGUI()
    if gui.Open then
        gui.Open, gui.ShowUI = ImGui.Begin('TheDroid Fable Loot Bot v' .. gui.version, gui.Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        if gui.ShowUI then
            if ImGui.CollapsingHeader("Fable Loot Bot") then
                ImGui.Text("This is a simple macro I threw together to help out a few friends.\n" ..
                    "You can run it on a Shaman, Magician, Enchanter, Ranger, Druid, Wizard,\n" ..
                    "Beastlord, Cleric, or Paladin. You can even have a Necromancer summon corpses!\n\n")
                ImGui.Separator();

                ImGui.Text("FEATURES:");
                ImGui.BulletText("");
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText("");
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
            end
            if ImGui.CollapsingHeader("Options") then
                FableLooter.Settings.debug = ImGui.Checkbox('Enable Debug Messages', FableLooter.Settings.debug)
                ImGui.SameLine()
                ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                if gui.DEBUG ~= FableLooter.Settings.debug then
                    gui.DEBUG = FableLooter.Settings.debug
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.pauseMacro = ImGui.Checkbox('Enable Pause Macro', FableLooter.Settings.pauseMacro)
                ImGui.SameLine()
                ImGui.HelpMarker('Pauses the currently running macro to loot.')
                if gui.PAUSEMACRO ~= FableLooter.Settings.pauseMacro then
                    gui.PAUSEMACRO = FableLooter.Settings.pauseMacro
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.bankDeposit = ImGui.Checkbox('Enable Bank Deposit', FableLooter.Settings
                    .bankDeposit)
                ImGui.SameLine()
                ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                if gui.BANKDEPOSIT ~= FableLooter.Settings.bankDeposit then
                    gui.BANKDEPOSIT = FableLooter.Settings.bankDeposit
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.bankAtFreeSlots = ImGui.SliderInt("Inventory Free Slots",
                    FableLooter.Settings.bankAtFreeSlots, 1, 20)
                ImGui.SameLine()
                ImGui.HelpMarker('The amount of free slots before we should bank.')
                if gui.BANKATFREESLOTS ~= FableLooter.Settings.bankAtFreeSlots then
                    gui.BANKATFREESLOTS = FableLooter.Settings.bankAtFreeSlots
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.bankZone = ImGui.InputInt('Bank Zone', FableLooter.Settings.bankZone)
                ImGui.SameLine()
                ImGui.HelpMarker('Zone where we can access banking services.')
                if gui.BANKZONE ~= FableLooter.Settings.bankZone then
                    gui.BANKZONE = FableLooter.Settings.bankZone
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.bankNPC = ImGui.InputText('Bank NPC', FableLooter.Settings.bankNPC)
                ImGui.SameLine()
                ImGui.HelpMarker('The mount item you would like your buffer to sit on to meditate.')
                if gui.BANKNPC ~= FableLooter.Settings.bankNPC then
                    gui.BANKNPC = FableLooter.Settings.bankNPC
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.scan_Radius = ImGui.SliderInt("Scan Radius", FableLooter.Settings.scan_Radius, 1,
                    100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should look for corpses.')
                if gui.SCANRADIUS ~= FableLooter.Settings.scan_Radius then
                    gui.SCANRADIUS = FableLooter.Settings.scan_Radius
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.scan_zRadius = ImGui.SliderInt("Scan Radius", FableLooter.Settings.scan_zRadius, 1,
                    10000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should look for corpses.')
                if gui.SCANZRADIUS ~= FableLooter.Settings.scan_zRadius then
                    gui.SCANZRADIUS = FableLooter.Settings.scan_zRadius
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.returnToCampDistance = ImGui.SliderInt("Return To Camp Distance",
                    FableLooter.Settings.returnToCampDistance, 1, 100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The distance we can get before we trigger return to camp.')
                if gui.RETURNTOCAMPDISTANCE ~= FableLooter.Settings.returnToCampDistance then
                    gui.RETURNTOCAMPDISTANCE = FableLooter.Settings.returnToCampDistance
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.camp_Check = ImGui.Checkbox('Enable Camp Check', FableLooter.Settings.camp_Check)
                ImGui.SameLine()
                ImGui.HelpMarker('Return home if we get too far away?')
                if gui.CAMPCHECK ~= FableLooter.Settings.camp_Check then
                    gui.CAMPCHECK = FableLooter.Settings.camp_Check
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.zone_Check = ImGui.Checkbox('Enable Zone Check', FableLooter.Settings.zone_Check)
                ImGui.SameLine()
                ImGui.HelpMarker('Return to start zone if we leave it?')
                if gui.ZONECHECK ~= FableLooter.Settings.zone_Check then
                    gui.ZONECHECK = FableLooter.Settings.zone_Check
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.returnHomeAfterLoot = ImGui.Checkbox('Enable Return Home After Loot',
                    FableLooter.Settings.returnHomeAfterLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Return to start X/Y/Z after looting?')
                if gui.RETURNHOMEAFTERLOOT ~= FableLooter.Settings.returnHomeAfterLoot then
                    gui.RETURNHOMEAFTERLOOT = FableLooter.Settings.returnHomeAfterLoot
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.lootGroundSpawns = ImGui.Checkbox('Enable Pickup Groundspawns',
                    FableLooter.Settings.lootGroundSpawns)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we pickup groundspawns treasure goblins drops?')
                if gui.LOOTGROUNDSPAWNS ~= FableLooter.Settings.lootGroundSpawns then
                    gui.LOOTGROUNDSPAWNS = FableLooter.Settings.lootGroundSpawns
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.doStand = ImGui.Checkbox('Enable Do Stand', FableLooter.Settings.doStand)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we stand up if we arent?')
                if gui.DOSTAND ~= FableLooter.Settings.doStand then
                    gui.DOSTAND = FableLooter.Settings.doStand
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.lootAll = ImGui.Checkbox('Enable Loot all', FableLooter.Settings.lootAll)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we just loot everything on the corpse no matter what?')
                if gui.LOOTALL ~= FableLooter.Settings.lootAll then
                    gui.LOOTALL = FableLooter.Settings.lootAll
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.targetName = ImGui.InputText('Corpse Target Name', FableLooter.Settings.targetName)
                ImGui.SameLine()
                ImGui.HelpMarker('Look for this name on corpses when looting.')
                if gui.TARGETNAME ~= FableLooter.Settings.targetName then
                    gui.TARGETNAME = FableLooter.Settings.targetName
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.spawnSearch = ImGui.InputText('Corpse Search', FableLooter.Settings.spawnSearch)
                ImGui.SameLine()
                ImGui.HelpMarker('How we should filter corpses')
                if gui.SPAWNSEARCH ~= FableLooter.Settings.spawnSearch then
                    gui.SPAWNSEARCH = FableLooter.Settings.spawnSearch
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();
            end

            if ImGui.CollapsingHeader("Console") then
                local ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags.AlwaysVerticalScrollbar
                if ImGui.BeginChild("ScrollingRegion", -1, 550, nil, ImGuiWindowFlags_AlwaysVerticalScrollbar) then
                    for _, line in ipairs(gui.outputLog) do
                        ImGui.Text(line)
                    end
                    ImGui.SetScrollHereY(1.0) -- Scroll to the bottom of the log
                end
                ImGui.EndChild()
            end
        end
        ImGui.End()
    end
end

function gui.initGUI()
    mq.imgui.init('FableLooter', gui.FableLooterGUI)
    gui.Open = true
end

return gui
