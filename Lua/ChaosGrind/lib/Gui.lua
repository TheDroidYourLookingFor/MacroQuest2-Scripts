---@type Mq
local mq = require('mq')
local gui = {
    _version = '1.0.11',
    _author = 'TheDroidUrLookingFor'
}
-- Global state variable
local show_main = true -- Main form is visible by default
local dlIconImg = mq.CreateTexture(mq.luaDir .. "/DroidLoot/Resources/DroidLoot.png")
local dlFullImg = mq.CreateTexture(mq.luaDir .. "/DroidLoot/Resources/icon.png")
-- ChaosGrind
gui.DEBUG = false
gui.PAUSEMACRO = false
gui.BANKDEPOSIT = false
gui.SELLCASH = false
gui.SELLFABLED = false
gui.BANKATFREESLOTS = 5
gui.BANKZONE = 451
gui.BANKNPC = 'Griphook'
gui.FABLEDNPC = 'The Fabled Jim Carrey'
gui.SELLVENDOR = false
gui.VENDORNPC = 'Kirito'
gui.CASHNPC = 'Silent Bob'
gui.SELLFABLEDFOR = 'Papers'
gui.SCANRADIUS = 10000
gui.SCANZRADIUS = 250
gui.RETURNTOCAMPDISTANCE = 200
gui.STICKCOMMAND = '/stick'
gui.CAMPCHECK = false
gui.ZONECHECK = true
gui.LOOTGROUNDSPAWNS = true
gui.RETURNHOMEAFTERLOOT = false
gui.DOSTAND = true
gui.LOOTALL = false
gui.CORPSECLEANUP = true
gui.CORPSECLEANUPCOMMAND = '/say #deletecorpse'
gui.CORPSELIMIT = 100
gui.TARGETNAME = 'treasure'
gui.SPAWNSEARCH = '%s radius %d zradius %d'

gui.AGGROITEM = 'Charm of Hate'
gui.AGGROUBERITEM = 'Derekthomx\'s Horrorkrunk Hook'
gui.UBERPULLMOBSINZONE = 50
gui.MINMOBSINZONE = 10
gui.RESPAWNITEM = 'Uber Charm of Refreshing'
gui.BUFFCHARMNAME = 'Amulet of Ultimate Buffing'
gui.BUFFCHARMBUFFNAME = 'Talisman of the Panther Rk. III'
gui.GROUPALT = false
gui.ALTLOOTERNAME = 'Binli'
gui.DOSTATTRACK = true

gui.GROUPHEALAT = 90
gui.GROUPHEALITEM = ''
gui.DOGROUPHEALS = false
gui.DOSELFHEALS = false

gui.LIFETAPITEM = 'Crazok\'s Talking Eartackle'
gui.LIFETAPAT = 99
gui.USELIFETAPITEM = false

gui.PBAOEITEM = 'Tanza the Crystal-Bound'
gui.PBAOEAT = 99
gui.USEPBAOEITEM = false

gui.NUKEITEM = 'Stalwart Sagacious Helm'
gui.NUKEAT = 99
gui.USENUKEITEM = false


gui.USEPALADINAA = true
gui.USECLERICAA = true
gui.USEBEMCHEST = true
gui.USEBEMLEGS = true
gui.USEERTZSTONE = true
gui.USEBEMGLOVES = true
gui.USEBUFFCHARM = true
gui.KEEPMAXLEVEL = true
gui.USECOINSACK = true
gui.USECURRENCYCHARM = true
gui.LOOTGROUNDSPAWNS = false
gui.CLICKAATOKENS = true

-- EZLoot
gui.USEWARP = true
gui.ADDNEWSALES = true
gui.LOOTFORAGE = true
gui.LOOTTRADESKILL = false
gui.DOLOOT = true
gui.EQUIPUSABLE = false
gui.CORPSERADIUS = 100
gui.MOBSTOOCLOSE = 40
gui.REPORTLOOT = false
gui.ANNOUNCELOOT = true
gui.REPORTSKIPPED = true
gui.LOOTCHANNEL = "dgt"
gui.ANNOUNCECHANNEL = 'dgt'
gui.LOOTINIFILE = 'EZLoot\\EZloot.ini'
gui.SPAMLOOTINFO = false
gui.LOOTFORAGESPAM = false
gui.COMBATLOOTING = true
gui.LOOTPLATINUMBAGS = true
gui.LOOTTOKENSOFADVANCEMENT = true
gui.LOOTEMPOWEREDFABLED = true
gui.LOOTALLFABLEDAUGS = true
gui.EMPOWEREDFABLEDNAME = 'Empowered'
gui.EMPOWEREDFABLEDMINHP = 700
gui.STACKPLATVALUE = 0
gui.SAVEBAGSLOTS = 3
gui.MINSELLPRICE = 5000
gui.STACKABLEONLY = false
gui.USESINGLEFILEFORALLCHARACTERS = true
gui.USEZONELOOTFILE = false
gui.USECLASSLOOTFILE = false
gui.USEARMORTYPELOOTFILE = false
gui.USEEXPPOTIONS = true
gui.POTIONNAME = 'Potion of Adventure II'
gui.POTIONBUFF = 'Potion of Adventure II'
gui.STATICHUNT = false
gui.STATICZONEID = '173'
gui.STATICZONENAME = 'maiden'
gui.EXPANSION = 'The Ruins of Kunark'
gui.STATICX = '1905'
gui.STATICY = '940'
gui.STATICZ = '-151.74'
gui.WARPTOTARGETDISTANCE = 15
gui.WARPBEFORESTART = true

gui.Open = false
gui.ShowUI = false

gui.outputLog = {}
-- Function to add output to the log with a timestamp
function gui.addToConsole(text, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")

    -- Handle item links correctly by passing through string.format
    local formattedText = string.format(text, ...)

    -- Add the timestamp to the message
    local logEntry = string.format("%s %s", timestamp, formattedText)

    -- Add the combined message with timestamp to the log
    table.insert(gui.outputLog, logEntry)
end

gui.CreateComboBox = {
    flags = 0
}
function gui.CreateComboBox:draw(cb_label, buffs, current_idx, width)
    local combo_buffs = buffs[current_idx]

    ImGui.PushItemWidth(width)
    if ImGui.BeginCombo(cb_label, combo_buffs, ImGuiComboFlags.None) then
        for n = 1, #buffs do
            local is_selected = current_idx == n
            if ImGui.Selectable(buffs[n], is_selected) then -- fixme: selectable
                current_idx = n
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

local SellFabledFor_idx
gui.SellFabledForType = {
    'Doubloons',
    'Papers',
    'Cash'
}
function gui.ChaosGrindGUI()
    if show_main then
        if gui.Open then
            gui.Open, gui.ShowUI = ImGui.Begin('TheDroid Chaos Grinder v' .. ChaosGrind._version, gui.Open)
            ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
            local x_size = 620
            local y_size = 680
            local io = ImGui.GetIO()
            local center_x = io.DisplaySize.x / 2
            local center_y = io.DisplaySize.y / 2
            ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
            ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
            if gui.ShowUI then
                local windowWidth = ImGui.GetWindowContentRegionWidth()
                local buttonWidth, buttonHeight = 140, 30
                local buttonWidthSmall = 90
                -- Get the elapsed time since ChaosGrind.Settings.StartTime
                local formattedElapsedTime = ChaosGrind.getElapsedTime(ChaosGrind.Settings.StartTime)
                ImGui.SameLine(250)
                ImGui.Text('Run Time:')
                ImGui.SameLine()
                ImGui.Text(formattedElapsedTime)

                ImGui.Separator();
                ImGui.Text('Idle Time:')
                ImGui.SameLine()
                ImGui.Text(string.format('%02d:%02d:%02d',
                    math.floor((os.time() - ChaosGrind.Settings.idleTime) / 3600),
                    math.floor(((os.time() - ChaosGrind.Settings.idleTime) % 3600) / 60),
                    (os.time() - ChaosGrind.Settings.idleTime) % 60))

                ImGui.Separator();
                local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
                ImGui.SetCursorPosX(15)
                if ChaosGrind.Settings.doPause then
                    if ImGui.Button('Resume', buttonImVec2) then
                        ChaosGrind.Settings.doPause = false
                    end
                else
                    if ImGui.Button('Pause', buttonImVec2) then
                        ChaosGrind.Settings.doPause = true
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
                    ChaosGrind.Settings.terminate = true
                    mq.cmdf('/lua stop %s', 'ChaosGrind')
                end

                -- local rightStartX = windowWidth - buttonWidth
                -- ImGui.SetCursorPosX(rightStartX)
                -- if ImGui.Button('Kill AQO', ImVec2(buttonWidth, buttonHeight)) then
                --     mq.cmdf('/lua stop %s', 'AQO')
                -- end

                if ImGui.CollapsingHeader("Chaos Grind") then
                    ImGui.Indent();
                    ImGui.Text("This is a simple script I threw together to grind instances on the\n" ..
                        "Chaotic Treasures EQEmu Server.\n")
                    ImGui.Separator();

                    ImGui.Text("COMMANDS:");
                    ImGui.BulletText('/' .. ChaosGrind.Settings.command_ShortName .. ' quit');
                    ImGui.Separator();

                    ImGui.Text("CREDIT:");
                    ImGui.BulletText("TheDroidUrLookingFor");
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader('Gains') then
                    ImGui.Indent();
                    ChaosGrind.Settings.DoStatTrack = ImGui.Checkbox('Enable Stat Track', ChaosGrind.Settings.DoStatTrack)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Track our gains?')
                    if gui.DOSTATTRACK ~= ChaosGrind.Settings.DoStatTrack then
                        gui.DOSTATTRACK = ChaosGrind.Settings.DoStatTrack
                        ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                    end
                    ImGui.Separator();
                    if ChaosGrind.Settings.DoStatTrack then
                        local totalKC, kcPerHour = ChaosGrind.CurrencyStatus()
                        local totalAA, aaPerHour = ChaosGrind.AAStatus()
                        local formattedTotalAA = ChaosGrind.formatNumberWithCommas(totalAA)
                        local formattedAAPerHour = ChaosGrind.formatNumberWithCommas(math.floor(aaPerHour))
                        local formattedCashPerHour = ChaosGrind.formatNumberWithCommas(math.floor(kcPerHour))
                        local formattedTotalCash = ChaosGrind.formatNumberWithCommas(totalKC)

                        local totalKills, killsPerHour = ChaosGrind.KillsStatus()
                        local formattedTotalKills = ChaosGrind.formatNumberWithCommas(totalKills)
                        local formattedKillsPerHour = ChaosGrind.formatNumberWithCommas(math.floor(killsPerHour))

                        local totalChaotics, chaoticsPerHour = ChaosGrind.ChaoticStatus()
                        local formattedTotalChaotics = ChaosGrind.formatNumberWithCommas(totalChaotics)
                        local formattedChaoticsPerHour = ChaosGrind.formatNumberWithCommas(chaoticsPerHour)

                        local totalEpics, epicsPerHour = ChaosGrind.CursedEpicStatus()
                        local formattedTotalEpics = ChaosGrind.formatNumberWithCommas(totalEpics)
                        local formattedEpicsPerHour = ChaosGrind.formatNumberWithCommas(math.floor(epicsPerHour))

                        local totalThreads, threadsPerHour = ChaosGrind.ThreadsStatus()
                        local formattedTotalThreads = ChaosGrind.formatNumberWithCommas(totalThreads)
                        local formattedThreadsPerHour = ChaosGrind.formatNumberWithCommas(math.floor(threadsPerHour))

                        local totalAugmentTokens, augmentTokensPerHour = ChaosGrind.AugmentTokensStatus()
                        local formattedTotalAugmentTokens = ChaosGrind.formatNumberWithCommas(totalAugmentTokens)
                        local formattedAugmentTokensPerHour = ChaosGrind.formatNumberWithCommas(math.floor(augmentTokensPerHour))

                        local totalAATokens, aaTokensPerHour = ChaosGrind.AATokensStatus()
                        local formattedTotalAATokens = ChaosGrind.formatNumberWithCommas(totalAATokens)
                        local formattedAATokensPerHour = ChaosGrind.formatNumberWithCommas(math.floor(aaTokensPerHour))

                        local totalItems, itemsPerHour = ChaosGrind.LootsStatus()
                        local formattedTotalItems = ChaosGrind.formatNumberWithCommas(totalItems)
                        local formattedItemsPerHour = ChaosGrind.formatNumberWithCommas(math.floor(itemsPerHour))

                        ImGui.Text('Items Found');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedTotalItems));
                        ImGui.SameLine(400);
                        ImGui.Text('Items / Hour');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedItemsPerHour));
                        ImGui.Separator();

                        ImGui.Text('Cursed Epics Found');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedTotalEpics));
                        ImGui.SameLine(400);
                        ImGui.Text('Epics / Hour');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedEpicsPerHour));
                        ImGui.Separator();

                        ImGui.Text('Chaotic Threads Found');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedTotalThreads));
                        ImGui.SameLine(400);
                        ImGui.Text('Threads / Hour');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedThreadsPerHour));
                        ImGui.Separator();

                        ImGui.Text('Augment Tokens Found');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedTotalAugmentTokens));
                        ImGui.SameLine(400);
                        ImGui.Text('Tokens / Hour');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedAugmentTokensPerHour));
                        ImGui.Separator();

                        ImGui.Text('AA Tokens Found');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedTotalAATokens));
                        ImGui.SameLine(400);
                        ImGui.Text('Tokens / Hour');
                        ImGui.SameLine();
                        ImGui.Text(tostring(formattedAATokensPerHour));
                        ImGui.Separator();

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
                            for mobName, killCount in pairs(ChaosGrind.Settings.SlainMobTypes) do
                                local mobKillsPerHour = ChaosGrind.KillStatus(killCount)

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
                            for mobName, killCount in pairs(ChaosGrind.Settings.SlainChaoticTypes) do
                                local mobKillsPerHour = ChaosGrind.KillStatus(killCount)

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
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Options") then
                    ImGui.Indent();
                    if ImGui.CollapsingHeader("Items") then
                        ImGui.Indent();
                        if ImGui.CollapsingHeader("Zone Pull") then
                            ImGui.Indent();
                            ChaosGrind.Settings.aggroItem = ImGui.InputText('Aggro Item', ChaosGrind.Settings.aggroItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The name of your zone wide aggro item.')
                            if gui.AGGROITEM ~= ChaosGrind.Settings.aggroItem then
                                gui.AGGROITEM = ChaosGrind.Settings.aggroItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();

                            ChaosGrind.Settings.respawnItem = ImGui.InputText('Respawn Item', ChaosGrind.Settings.respawnItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The name of your zone respawn item.')
                            if gui.RESPAWNITEM ~= ChaosGrind.Settings.respawnItem then
                                gui.RESPAWNITEM = ChaosGrind.Settings.respawnItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();

                            ChaosGrind.Settings.MinMobsInZone = ImGui.InputInt("Respawn Mobs Limit",
                                ChaosGrind.Settings.MinMobsInZone)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The amount of mobs allowed before we respawn the zone.')
                            if gui.MINMOBSINZONE ~= ChaosGrind.Settings.MinMobsInZone then
                                gui.MINMOBSINZONE = ChaosGrind.Settings.MinMobsInZone
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();
                            ImGui.Unindent();
                        end

                        if ImGui.CollapsingHeader("Group Heal Item##collapsingheader") then
                            ImGui.Indent();

                            ChaosGrind.Settings.DoSelfHeals = ImGui.Checkbox('Enable Self Heals', ChaosGrind.Settings.DoSelfHeals)
                            ImGui.SameLine()
                            ImGui.HelpMarker('Enables the use of the group heal item to heal self.')
                            if gui.DOSELFHEALS ~= ChaosGrind.Settings.DoSelfHeals then
                                gui.DOSELFHEALS = ChaosGrind.Settings.DoSelfHeals
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.DoGroupHeals = ImGui.Checkbox('Enable Group Heals', ChaosGrind.Settings.DoGroupHeals)
                            ImGui.SameLine()
                            ImGui.HelpMarker('Enables the use of the group heal item.')
                            if gui.DOGROUPHEALS ~= ChaosGrind.Settings.DoGroupHeals then
                                gui.DOGROUPHEALS = ChaosGrind.Settings.DoGroupHeals
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.GroupHealItem = ImGui.InputText('Group Heal Item', ChaosGrind.Settings.GroupHealItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The name of your group heal item.')
                            if gui.GROUPHEALITEM ~= ChaosGrind.Settings.GroupHealItem then
                                gui.GROUPHEALITEM = ChaosGrind.Settings.GroupHealItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.GroupHealAt = ImGui.InputInt("Group Heal At", ChaosGrind.Settings.GroupHealAt)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The percent of health to use group heal item at.')
                            if gui.GROUPHEALAT ~= ChaosGrind.Settings.GroupHealAt then
                                gui.GROUPHEALAT = ChaosGrind.Settings.GroupHealAt
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();
                            ImGui.Unindent();
                        end

                        if ImGui.CollapsingHeader("PBAoE Item##collapsingheader") then
                            ImGui.Indent();
                            ChaosGrind.Settings.UsePBAoEItem = ImGui.Checkbox('Enable PBAoE Item', ChaosGrind.Settings.UsePBAoEItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('Enables the use of the PBAoE item.')
                            if gui.USEPBAOEITEM ~= ChaosGrind.Settings.UsePBAoEItem then
                                gui.USEPBAOEITEM = ChaosGrind.Settings.UsePBAoEItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.PBAoEItem = ImGui.InputText('PBAoE Item', ChaosGrind.Settings.PBAoEItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The name of your PBAoE item.')
                            if gui.PBAOEITEM ~= ChaosGrind.Settings.PBAoEItem then
                                gui.PBAOEITEM = ChaosGrind.Settings.PBAoEItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.PBAoEAt = ImGui.InputInt("PBAoE At", ChaosGrind.Settings.PBAoEAt)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The percent of health to use PBAoE item at.')
                            if gui.PBAOEAT ~= ChaosGrind.Settings.PBAoEAt then
                                gui.PBAOEAT = ChaosGrind.Settings.PBAoEAt
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();
                            ImGui.Unindent();
                        end

                        if ImGui.CollapsingHeader("Lifetap Item##collapsingheader") then
                            ImGui.Indent();
                            ChaosGrind.Settings.UseLifetapItem = ImGui.Checkbox('Enable Lifetap Item', ChaosGrind.Settings.UseLifetapItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('Enables the use of the lifetap item.')
                            if gui.DOGROUPHEALS ~= ChaosGrind.Settings.UseLifetapItem then
                                gui.DOGROUPHEALS = ChaosGrind.Settings.UseLifetapItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.LifetapItem = ImGui.InputText('Lifetap Item', ChaosGrind.Settings.LifetapItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The name of your lifetap item.')
                            if gui.GROUPHEALITEM ~= ChaosGrind.Settings.LifetapItem then
                                gui.GROUPHEALITEM = ChaosGrind.Settings.LifetapItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.LifetapAt = ImGui.InputInt("Lifetap At", ChaosGrind.Settings.LifetapAt)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The percent of health to use lifetap item at.')
                            if gui.GROUPHEALAT ~= ChaosGrind.Settings.LifetapAt then
                                gui.GROUPHEALAT = ChaosGrind.Settings.LifetapAt
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();
                            ImGui.Unindent();
                        end

                        if ImGui.CollapsingHeader("Nuke Item##collapsingheader") then
                            ImGui.Indent();
                            ChaosGrind.Settings.UseNukeItem = ImGui.Checkbox('Enable Nuke Item', ChaosGrind.Settings.UseNukeItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('Enables the use of the Nuke item.')
                            if gui.USENUKEITEM ~= ChaosGrind.Settings.UseNukeItem then
                                gui.USENUKEITEM = ChaosGrind.Settings.UseNukeItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.NukeItem = ImGui.InputText('Nuke Item', ChaosGrind.Settings.NukeItem)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The name of your Nuke item.')
                            if gui.NUKEITEM ~= ChaosGrind.Settings.NukeItem then
                                gui.NUKEITEM = ChaosGrind.Settings.NukeItem
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end

                            ChaosGrind.Settings.NukeAt = ImGui.InputInt("Nuke At", ChaosGrind.Settings.NukeAt)
                            ImGui.SameLine()
                            ImGui.HelpMarker('The percent of health to use Nuke item at.')
                            if gui.NUKEAT ~= ChaosGrind.Settings.NukeAt then
                                gui.NUKEAT = ChaosGrind.Settings.NukeAt
                                ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            end
                            ImGui.Separator();
                            ImGui.Unindent();
                        end

                        ImGui.Unindent();
                    end
                    if ImGui.CollapsingHeader("Kill Zone") then
                        ImGui.Indent();

                        -- ComboBox for Presets
                        ImGui.Text("Presets")
                        ImGui.SameLine()
                        if not gui.SelectedPreset then gui.SelectedPreset = '' end
                        if not gui.PresetIndex then gui.PresetIndex = 0 end

                        local presetNames = {}
                        local presetIndex = 0
                        local selectedIndex = gui.PresetIndex or 0

                        for name, _ in pairs(ChaosGrind.Settings.GrindZone) do
                            table.insert(presetNames, name)
                        end

                        table.sort(presetNames) -- optional, sort alphabetically

                        if ImGui.BeginCombo("##PresetCombo", presetNames[selectedIndex + 1] or "Select Preset") then
                            for i, name in ipairs(presetNames) do
                                local isSelected = (i - 1) == selectedIndex
                                if ImGui.Selectable(name, isSelected) then
                                    selectedIndex = i - 1
                                    gui.PresetIndex = selectedIndex
                                    gui.SelectedPreset = name

                                    -- Set values from the selected preset
                                    local preset = ChaosGrind.Settings.GrindZone[name]
                                    if preset then
                                        ChaosGrind.Settings.Zone = name
                                        ChaosGrind.Settings.Expansion = preset.Expansion or ''
                                        ChaosGrind.Settings.GrindZoneID = preset.ID or 0
                                        ChaosGrind.Settings.respawnX = math.floor(preset.X or 0)
                                        ChaosGrind.Settings.respawnY = math.floor(preset.Y or 0)
                                        ChaosGrind.Settings.respawnZ = math.floor(preset.Z or 0)
                                        ChaosGrind.Settings.ignoreTarget = preset.ignoreTarget or ''

                                        -- Save and update camp info
                                        ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                                        ChaosGrind.CheckCampInfo()
                                    end
                                end
                                if isSelected then
                                    ImGui.SetItemDefaultFocus()
                                end
                            end
                            ImGui.EndCombo()
                        end

                        ImGui.Separator()

                        ChaosGrind.Settings.Zone = ImGui.InputText('Zone Name', ChaosGrind.Settings.Zone)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The short name of the Static Hunt Zone.')
                        if gui.STATICZONENAME ~= ChaosGrind.Settings.Zone then
                            gui.STATICZONENAME = ChaosGrind.Settings.Zone
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            ChaosGrind.CheckCampInfo()
                        end
                        ImGui.Separator();

                        ChaosGrind.Settings.Expansion = ImGui.InputText('Expansion Name', ChaosGrind.Settings.Expansion)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The expansion for the hunt Zone.')
                        if gui.EXPANSION ~= ChaosGrind.Settings.Expansion then
                            gui.EXPANSION = ChaosGrind.Settings.Expansion
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                        end
                        ImGui.Separator();

                        ChaosGrind.Settings.GrindZoneID = ImGui.InputInt('Zone ID', ChaosGrind.Settings.GrindZoneID)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The ID of the static Hunting Zone.')
                        if gui.STATICZONEID ~= ChaosGrind.Settings.GrindZoneID then
                            gui.STATICZONEID = ChaosGrind.Settings.GrindZoneID
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            ChaosGrind.CheckCampInfo()
                        end
                        ImGui.Separator();

                        local start_y_Options = ImGui.GetCursorPosY()
                        ImGui.SetCursorPosY(start_y_Options + 3)
                        ImGui.Text('X')
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(120)
                        ImGui.SetCursorPosY(start_y_Options)
                        ChaosGrind.Settings.respawnX = ImGui.InputInt('##Zone X', ChaosGrind.Settings.respawnX)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The X loc in the Hunting Zone to zone pull.')
                        if gui.STATICX ~= ChaosGrind.Settings.respawnX then
                            gui.STATICX = ChaosGrind.Settings.respawnX
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            ChaosGrind.CheckCampInfo()
                        end
                        ImGui.SameLine();

                        ImGui.SetCursorPosY(start_y_Options + 1)
                        ImGui.Text('Y')
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(120)
                        ImGui.SetCursorPosY(start_y_Options)
                        ChaosGrind.Settings.respawnY = ImGui.InputInt('##Zone Y', ChaosGrind.Settings.respawnY)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The Y loc in the Hunting Zone to zone pull.')
                        if gui.STATICY ~= ChaosGrind.Settings.respawnY then
                            gui.STATICY = ChaosGrind.Settings.respawnY
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            ChaosGrind.CheckCampInfo()
                        end
                        ImGui.SameLine();

                        ImGui.SetCursorPosY(start_y_Options + 1)
                        ImGui.Text('Z')
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(120)
                        ImGui.SetCursorPosY(start_y_Options)
                        ChaosGrind.Settings.respawnZ = ImGui.InputInt('##Zone Z', ChaosGrind.Settings.respawnZ)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The Z loc in the Hunting Zone to zone pull.')
                        if gui.STATICZ ~= ChaosGrind.Settings.respawnZ then
                            gui.STATICZ = ChaosGrind.Settings.respawnZ
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                            ChaosGrind.CheckCampInfo()
                        end
                        ImGui.Separator();

                        ChaosGrind.Settings.WarpToTargetDistance = ImGui.InputInt('Warp Distance', ChaosGrind.Settings.WarpToTargetDistance)
                        ImGui.SameLine()
                        ImGui.HelpMarker('The distance from target we will auto warp to it.')
                        if gui.WARPTOTARGETDISTANCE ~= ChaosGrind.Settings.WarpToTargetDistance then
                            gui.WARPTOTARGETDISTANCE = ChaosGrind.Settings.WarpToTargetDistance
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                        end
                        ImGui.Separator();

                        ChaosGrind.Settings.WarpBeforeStart = ImGui.Checkbox('Warp Before Start', ChaosGrind.Settings.WarpBeforeStart)
                        ImGui.SameLine()
                        ImGui.HelpMarker('Should the bot warp to the X/Y/Z before starting?')
                        if gui.WARPBEFORESTART ~= ChaosGrind.Settings.WarpBeforeStart then
                            gui.WARPBEFORESTART = ChaosGrind.Settings.WarpBeforeStart
                            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                        end
                        ImGui.Separator();
                        ImGui.Unindent();
                    end
                    ChaosGrind.Settings.debug = ImGui.Checkbox('Enable Debug Messages', ChaosGrind.Settings.debug)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                    if gui.DEBUG ~= ChaosGrind.Settings.debug then
                        gui.DEBUG = ChaosGrind.Settings.debug
                        ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile,  ChaosGrind.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Console") then
                    ImGui.Indent()
                    local ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags.AlwaysVerticalScrollbar
                    if ImGui.BeginChild("ScrollingRegion", -1, 550, nil, ImGuiWindowFlags_AlwaysVerticalScrollbar) then
                        for _, line in ipairs(gui.outputLog) do
                            ImGui.Text(line)
                        end
                        ImGui.SetScrollHereY(1.0) -- Scroll to the bottom of the log
                    end
                    ImGui.EndChild()
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
                ChaosGrind.Settings.terminate = true
                mq.cmdf('/lua stop %s', 'ChaosGrind')
            end
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImVec2(0, 0)) -- No padding inside button
            local buttonColor
            if ChaosGrind.Settings.doPause then
                buttonColor = ImVec4(1, 0, 0, 1)
                if ImGui.ImageButton('Resume', dlFullImg:GetTextureID(), ImVec2(44, 44), ImVec2(0.0, 0.0), ImVec2(0.62, 0.62), ImVec4(0, 0, 0, 0), buttonColor) then
                    ChaosGrind.Settings.doPause = false
                end
            else
                buttonColor = ImVec4(0, 1, 0, 1)
                if ImGui.ImageButton('Pause', dlFullImg:GetTextureID(), ImVec2(44, 44), ImVec2(0.0, 0.0), ImVec2(0.62, 0.62), ImVec4(0, 0, 0, 0), buttonColor) then
                    ChaosGrind.Settings.doPause = true
                end
            end
            ImGui.PopStyleVar()
        end

        ImGui.End()
    end
end

function gui.initGUI()
    mq.imgui.init('ChaosGrind', gui.ChaosGrindGUI)
    gui.Open = true
end

return gui
