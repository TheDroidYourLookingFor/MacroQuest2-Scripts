---@type Mq
local mq = require('mq')
local gui = { _version = '1.0.19', _author = 'TheDroidUrLookingFor' }

-- FableLooter
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
gui.CAMPCHECK = false
gui.ZONECHECK = true
gui.LOOTGROUNDSPAWNS = true
gui.RETURNHOMEAFTERLOOT = false
gui.DOSTAND = true
gui.KEEPMAXLEVEL = true
gui.LOOTALL = false
gui.CORPSECLEANUP = true
gui.CORPSECLEANUPCOMMAND = '/say #deletecorpse'
gui.CORPSELIMIT = 100
gui.TARGETNAME = 'treasure'
gui.SPAWNSEARCH = '%s radius %d zradius %d'

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
gui.USEEXPPOTIONS = false
gui.POTIONNAME = 'Potion of Adventure II'
gui.POTIONBUFF = 'Potion of Adventure II'
gui.STATICHUNT = false
gui.STATICZONEID = '173'
gui.STATICZONENAME = 'maiden'
gui.STATICX = '1905'
gui.STATICY = '940'
gui.STATICZ = '-151.74'

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
function gui.FableLooterGUI()
    if gui.Open then
        gui.Open, gui.ShowUI = ImGui.Begin('TheDroid Fable Loot Bot v' .. gui._version, gui.Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        if gui.ShowUI then
            local buttonWidth, buttonHeight = 140, 30
            local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
            if ImGui.Button('Bank', buttonImVec2) then
                FableLooter.needToBank = true
            end
            ImGui.SameLine(150)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Plat Sell', buttonImVec2) then
                FableLooter.needToVendorSell = true
            end
            ImGui.SameLine(300)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Cash Sell', buttonImVec2) then
                FableLooter.needToCashSell = true
            end
            ImGui.SameLine(450)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Fabled Sell', buttonImVec2) then
                FableLooter.needToFabledSell = true
            end

            if ImGui.CollapsingHeader("Fable Loot Bot") then
                ImGui.Indent()
                ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                    "It will loot anything set in the EZLoot.ini,\n")
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' bank');
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' cash');
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' fabled');
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' quit');
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
                ImGui.Unindent()
            end
            if ImGui.CollapsingHeader("Options") then
                ImGui.Indent()
                if ImGui.CollapsingHeader("Experience Potions") then
                    ImGui.Indent()
                    FableLooter.Settings.useExpPotions = ImGui.Checkbox('Enable Exp Potions',
                        FableLooter.Settings.useExpPotions)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                    if gui.USEEXPPOTIONS ~= FableLooter.Settings.useExpPotions then
                        gui.USEEXPPOTIONS = FableLooter.Settings.useExpPotions
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.potionName = ImGui.InputText('Potion Name', FableLooter.Settings.potionName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the experience potion.')
                    if gui.POTIONNAME ~= FableLooter.Settings.potionName then
                        gui.POTIONNAME = FableLooter.Settings.potionName
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.potionBuff = ImGui.InputText('Potion Buff', FableLooter.Settings.potionBuff)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the experience buff.')
                    if gui.POTIONBUFF ~= FableLooter.Settings.potionBuff then
                        gui.POTIONBUFF = FableLooter.Settings.potionBuff
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Hunt Method") then
                    ImGui.Indent()
                    FableLooter.Settings.staticHunt = ImGui.Checkbox('Enable Static Hunt',
                        FableLooter.Settings.staticHunt)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Always use the same Hunting Zone.')
                    if gui.STATICHUNT ~= FableLooter.Settings.staticHunt then
                        gui.STATICHUNT = FableLooter.Settings.staticHunt
                        FableLooter.CheckCampInfo()
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.staticZoneName = ImGui.InputText('Zone Name',
                        FableLooter.Settings.staticZoneName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The short name of the Static Hunt Zone.')
                    if gui.STATICZONENAME ~= FableLooter.Settings.staticZoneName then
                        gui.STATICZONENAME = FableLooter.Settings.staticZoneName
                        FableLooter.CheckCampInfo()
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.staticZoneID = ImGui.InputText('Zone ID', FableLooter.Settings.staticZoneID)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The ID of the static Hunting Zone.')
                    if gui.STATICZONEID ~= FableLooter.Settings.staticZoneID then
                        gui.STATICZONEID = FableLooter.Settings.staticZoneID
                        FableLooter.CheckCampInfo()
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    local start_y_Options = ImGui.GetCursorPosY()
                    ImGui.SetCursorPosY(start_y_Options + 3)
                    ImGui.Text('X')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    FableLooter.Settings.staticX = ImGui.InputText('##Zone X', FableLooter.Settings.staticX)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The X loc in the static Hunting Zone to camp.')
                    if gui.STATICX ~= FableLooter.Settings.staticX then
                        gui.STATICX = FableLooter.Settings.staticX
                        FableLooter.CheckCampInfo()
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.SameLine();

                    ImGui.SetCursorPosY(start_y_Options + 1)
                    ImGui.Text('Y')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    FableLooter.Settings.staticY = ImGui.InputText('##Zone Y', FableLooter.Settings.staticY)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The Y loc in the static Hunting Zone to camp.')
                    if gui.STATICY ~= FableLooter.Settings.staticY then
                        gui.STATICY = FableLooter.Settings.staticY
                        FableLooter.CheckCampInfo()
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.SameLine();

                    ImGui.SetCursorPosY(start_y_Options + 1)
                    ImGui.Text('Z')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    FableLooter.Settings.staticZ = ImGui.InputText('##Zone Z', FableLooter.Settings.staticZ)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The Z loc in the static Hunting Zone to camp.')
                    if gui.STATICZ ~= FableLooter.Settings.staticZ then
                        gui.STATICZ = FableLooter.Settings.staticZ
                        FableLooter.CheckCampInfo()
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Hub Operations") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    FableLooter.Settings.bankDeposit = ImGui.Checkbox('Enable Bank Deposit', FableLooter.Settings
                        .bankDeposit)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                    if gui.BANKDEPOSIT ~= FableLooter.Settings.bankDeposit then
                        gui.BANKDEPOSIT = FableLooter.Settings.bankDeposit
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.sellVendor = ImGui.Checkbox('Enable Vendor Selling', FableLooter.Settings.sellVendor)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items for Platinum when enabled.')
                    if gui.SELLVENDOR ~= FableLooter.Settings.sellVendor then
                        gui.SELLVENDOR = FableLooter.Settings.sellVendor
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    FableLooter.Settings.sellFabled = ImGui.Checkbox('Enable Fabled Item Selling', FableLooter.Settings
                        .sellFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items fabled items for currency when enabled.')
                    if gui.SELLFABLED ~= FableLooter.Settings.sellFabled then
                        gui.SELLFABLED = FableLooter.Settings.sellFabled
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.sellCash = ImGui.Checkbox('Enable Cash Item Selling', FableLooter.Settings
                        .sellCash)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items for Cash when enabled.')
                    if gui.SELLCASH ~= FableLooter.Settings.sellCash then
                        gui.SELLCASH = FableLooter.Settings.sellCash
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Columns(1)

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
                    ImGui.HelpMarker('The name of the npc to warp to for banking.')
                    if gui.BANKNPC ~= FableLooter.Settings.bankNPC then
                        gui.BANKNPC = FableLooter.Settings.bankNPC
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.vendorNPC = ImGui.InputText('Vendor NPC', FableLooter.Settings.vendorNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for vendoring.')
                    if gui.VENDORNPC ~= FableLooter.Settings.vendorNPC then
                        gui.VENDORNPC = FableLooter.Settings.vendorNPC
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.cashNPC = ImGui.InputText('Cash NPC', FableLooter.Settings.cashNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to sell cash items to.')
                    if gui.CASHNPC ~= FableLooter.Settings.cashNPC then
                        gui.CASHNPC = FableLooter.Settings.cashNPC
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.SellFabledFor_idx = gui.CreateComboBox:draw("Fabled Sell For", gui.SellFabledForType, FableLooter.Settings.SellFabledFor_idx);
                    if SellFabledFor_idx ~= FableLooter.Settings.SellFabledFor_idx then
                        SellFabledFor_idx = FableLooter.Settings.SellFabledFor_idx
                        if SellFabledFor_idx == 1 then
                            FableLooter.Settings.SellFabledFor = 'Doubloons'
                        elseif SellFabledFor_idx == 2 then
                            FableLooter.Settings.SellFabledFor = 'Papers'
                        else
                            FableLooter.Settings.SellFabledFor = 'Cash'
                        end
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end

                    FableLooter.Settings.fabledNPC = ImGui.InputText('Fabled NPC', FableLooter.Settings.fabledNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to sell fabled items to.')
                    if gui.FABLEDNPC ~= FableLooter.Settings.fabledNPC then
                        gui.FABLEDNPC = FableLooter.Settings.fabledNPC
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
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Movement Operations") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    FableLooter.Settings.camp_Check = ImGui.Checkbox('Enable Camp Check', FableLooter.Settings
                        .camp_Check)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Return home if we get too far away?')
                    if gui.CAMPCHECK ~= FableLooter.Settings.camp_Check then
                        gui.CAMPCHECK = FableLooter.Settings.camp_Check
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.zone_Check = ImGui.Checkbox('Enable Zone Check', FableLooter.Settings
                        .zone_Check)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Return to start zone if we leave it?')
                    if gui.ZONECHECK ~= FableLooter.Settings.zone_Check then
                        gui.ZONECHECK = FableLooter.Settings.zone_Check
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
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
                    ImGui.Columns(1)

                    FableLooter.Settings.returnToCampDistance = ImGui.SliderInt("Return To Camp Distance",
                        FableLooter.Settings.returnToCampDistance, 1, 100000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The distance we can get before we trigger return to camp.')
                    if gui.RETURNTOCAMPDISTANCE ~= FableLooter.Settings.returnToCampDistance then
                        gui.RETURNTOCAMPDISTANCE = FableLooter.Settings.returnToCampDistance
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Corpse Cleanup") then
                    ImGui.Indent()
                    FableLooter.Settings.corpseCleanup = ImGui.Checkbox('Enable Corpse Cleanup',
                        FableLooter.Settings.corpseCleanup)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we the amount of corpses the client sees?')
                    if gui.CORPSECLEANUP ~= FableLooter.Settings.corpseCleanup then
                        gui.CORPSECLEANUP = FableLooter.Settings.corpseCleanup
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.corpseCleanupCommand = ImGui.InputText('Corpse Cleanup Command',
                        FableLooter.Settings.corpseCleanupCommand)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Look for this name on corpses when looting.')
                    if gui.CORPSECLEANUPCOMMAND ~= FableLooter.Settings.corpseCleanupCommand then
                        gui.CORPSECLEANUPCOMMAND = FableLooter.Settings.corpseCleanupCommand
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.corpseLimit = ImGui.SliderInt("Corpse Limit", FableLooter.Settings.corpseLimit,
                        1,
                        2500)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of corpses allowed before we clean them for performance.')
                    if gui.CORPSELIMIT ~= FableLooter.Settings.corpseLimit then
                        gui.CORPSELIMIT = FableLooter.Settings.corpseLimit
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Corpse Targetting") then
                    ImGui.Indent();
                    FableLooter.Settings.lootAll = ImGui.Checkbox('Enable Loot all', FableLooter.Settings.lootAll)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we just loot all corpses ignoring corpse filter?')
                    if gui.LOOTALL ~= FableLooter.Settings.lootAll then
                        gui.LOOTALL = FableLooter.Settings.lootAll
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.targetName = ImGui.InputText('Corpse Target Name',
                        FableLooter.Settings.targetName)
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

                    FableLooter.Settings.scan_Radius = ImGui.SliderInt("Scan Radius", FableLooter.Settings.scan_Radius, 1,
                        100000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The radius we should look for corpses.')
                    if gui.SCANRADIUS ~= FableLooter.Settings.scan_Radius then
                        gui.SCANRADIUS = FableLooter.Settings.scan_Radius
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Separator();

                    FableLooter.Settings.scan_zRadius = ImGui.SliderInt("Scan zRadius", FableLooter.Settings
                        .scan_zRadius, 1,
                        10000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The z radius we should look for corpses.')
                    if gui.SCANZRADIUS ~= FableLooter.Settings.scan_zRadius then
                        gui.SCANZRADIUS = FableLooter.Settings.scan_zRadius
                        FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                    end
                    ImGui.Unindent();
                end
                ImGui.Columns(2)
                local start_y_Options = ImGui.GetCursorPosY()
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

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y_Options)
                FableLooter.Settings.doStand = ImGui.Checkbox('Enable Do Stand', FableLooter.Settings.doStand)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we stand up if we arent?')
                if gui.DOSTAND ~= FableLooter.Settings.doStand then
                    gui.DOSTAND = FableLooter.Settings.doStand
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end

                FableLooter.Settings.KeepMaxLevel = ImGui.Checkbox('Keep Max Level', FableLooter.Settings.KeepMaxLevel)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we try to keep level 80?')
                if gui.KEEPMAXLEVEL ~= FableLooter.Settings.KeepMaxLevel then
                    gui.KEEPMAXLEVEL = FableLooter.Settings.KeepMaxLevel
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();
                ImGui.Columns(1);
                ImGui.Unindent()
            end
            if ImGui.CollapsingHeader('EZLoot Options') then
                ImGui.Indent()
                if ImGui.CollapsingHeader("WastingTime Options") then
                    ImGui.Indent()
                    FableLooter.LootUtils.LootPlatinumBags = ImGui.Checkbox('Enable Loot Platinum Bags',
                        FableLooter.LootUtils.LootPlatinumBags)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots platinum bags.')
                    if gui.LOOTPLATINUMBAGS ~= FableLooter.LootUtils.LootPlatinumBags then
                        gui.LOOTPLATINUMBAGS = FableLooter.LootUtils.LootPlatinumBags
                        FableLooter.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    FableLooter.LootUtils.LootTokensOfAdvancement = ImGui.Checkbox('Enable Loot Tokens of Advancement',
                        FableLooter.LootUtils.LootTokensOfAdvancement)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots tokens of advancement.')
                    if gui.LOOTTOKENSOFADVANCEMENT ~= FableLooter.LootUtils.LootTokensOfAdvancement then
                        gui.LOOTTOKENSOFADVANCEMENT = FableLooter.LootUtils.LootTokensOfAdvancement
                        FableLooter.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    FableLooter.LootUtils.LootEmpoweredFabled = ImGui.Checkbox('Enable Loot Empowered Fabled',
                        FableLooter.LootUtils.LootEmpoweredFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots empowered fabled items.')
                    if gui.LOOTEMPOWEREDFABLED ~= FableLooter.LootUtils.LootEmpoweredFabled then
                        gui.LOOTEMPOWEREDFABLED = FableLooter.LootUtils.LootEmpoweredFabled
                        FableLooter.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    FableLooter.LootUtils.LootAllFabledAugs = ImGui.Checkbox('Enable Loot All Fabled Augments',
                        FableLooter.LootUtils.LootAllFabledAugs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots all fabled augments.')
                    if gui.LOOTALLFABLEDAUGS ~= FableLooter.LootUtils.LootAllFabledAugs then
                        gui.LOOTALLFABLEDAUGS = FableLooter.LootUtils.LootAllFabledAugs
                        FableLooter.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    FableLooter.LootUtils.EmpoweredFabledMinHP = ImGui.SliderInt("Empowered Fabled Min HP",
                        FableLooter.LootUtils.EmpoweredFabledMinHP, 0, 1000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                    if gui.EMPOWEREDFABLEDMINHP ~= FableLooter.LootUtils.EmpoweredFabledMinHP then
                        gui.EMPOWEREDFABLEDMINHP = FableLooter.LootUtils.EmpoweredFabledMinHP
                        FableLooter.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    FableLooter.LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name',
                        FableLooter.LootUtils.EmpoweredFabledName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Name of the empowered fabled item.')
                    if gui.EMPOWEREDFABLEDNAME ~= FableLooter.LootUtils.EmpoweredFabledName then
                        gui.EMPOWEREDFABLEDNAME = FableLooter.LootUtils.EmpoweredFabledName
                        FableLooter.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                ImGui.Columns(2)
                local start_y = ImGui.GetCursorPosY()
                FableLooter.LootUtils.UseWarp = ImGui.Checkbox('Enable Warp', FableLooter.LootUtils.UseWarp)
                ImGui.SameLine()
                ImGui.HelpMarker('Uses warp when enabled.')
                if gui.USEWARP ~= FableLooter.LootUtils.UseWarp then
                    gui.USEWARP = FableLooter.LootUtils.UseWarp
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.AddNewSales = ImGui.Checkbox('Enable New Sales', FableLooter.LootUtils.AddNewSales)
                ImGui.SameLine()
                ImGui.HelpMarker('Add new sales when enabled.')
                if gui.ADDNEWSALES ~= FableLooter.LootUtils.AddNewSales then
                    gui.ADDNEWSALES = FableLooter.LootUtils.AddNewSales
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.LootForage = ImGui.Checkbox('Enable Loot Forage', FableLooter.LootUtils.LootForage)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot forage when enabled.')
                if gui.LOOTFORAGE ~= FableLooter.LootUtils.LootForage then
                    gui.LOOTFORAGE = FableLooter.LootUtils.LootForage
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.LootTradeSkill = ImGui.Checkbox('Enable Loot TradeSkill',
                    FableLooter.LootUtils.LootTradeSkill)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot trade skill items when enabled.')
                if gui.LOOTTRADESKILL ~= FableLooter.LootUtils.LootTradeSkill then
                    gui.LOOTTRADESKILL = FableLooter.LootUtils.LootTradeSkill
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.DoLoot = ImGui.Checkbox('Enable Looting', FableLooter.LootUtils.DoLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables looting.')
                if gui.DOLOOT ~= FableLooter.LootUtils.DoLoot then
                    gui.DOLOOT = FableLooter.LootUtils.DoLoot
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.EquipUsable = ImGui.Checkbox('Enable Equip Usable',
                    FableLooter.LootUtils.EquipUsable)
                ImGui.SameLine()
                ImGui.HelpMarker('Equips usable items. Buggy at best.')
                if gui.EQUIPUSABLE ~= FableLooter.LootUtils.EquipUsable then
                    gui.EQUIPUSABLE = FableLooter.LootUtils.EquipUsable
                    FableLooter.LootUtils.writeSettings()
                end

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y)
                FableLooter.LootUtils.AnnounceLoot = ImGui.Checkbox('Enable Announce Loot', FableLooter.LootUtils.AnnounceLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to announce channel.')
                if gui.ANNOUNCELOOT ~= FableLooter.LootUtils.AnnounceLoot then
                    gui.ANNOUNCELOOT = FableLooter.LootUtils.AnnounceLoot
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot', FableLooter.LootUtils.ReportLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to console.')
                if gui.REPORTLOOT ~= FableLooter.LootUtils.ReportLoot then
                    gui.REPORTLOOT = FableLooter.LootUtils.ReportLoot
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.ReportSkipped = ImGui.Checkbox('Enable Report Skipped',
                    FableLooter.LootUtils.ReportSkipped)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports skipped loots.')
                if gui.REPORTSKIPPED ~= FableLooter.LootUtils.ReportSkipped then
                    gui.REPORTSKIPPED = FableLooter.LootUtils.ReportSkipped
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spam Loot Info',
                    FableLooter.LootUtils.SpamLootInfo)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot info.')
                if gui.SPAMLOOTINFO ~= FableLooter.LootUtils.SpamLootInfo then
                    gui.SPAMLOOTINFO = FableLooter.LootUtils.SpamLootInfo
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.LootForageSpam = ImGui.Checkbox('Enable Loot Forage Spam',
                    FableLooter.LootUtils.LootForageSpam)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot forage info.')
                if gui.LOOTFORAGESPAM ~= FableLooter.LootUtils.LootForageSpam then
                    gui.LOOTFORAGESPAM = FableLooter.LootUtils.LootForageSpam
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.CombatLooting = ImGui.Checkbox('Enable Combat Looting',
                    FableLooter.LootUtils.CombatLooting)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots during combat.')
                if gui.COMBATLOOTING ~= FableLooter.LootUtils.CombatLooting then
                    gui.COMBATLOOTING = FableLooter.LootUtils.CombatLooting
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Columns(1)

                FableLooter.LootUtils.CorpseRadius = ImGui.SliderInt("Corpse Radius", FableLooter.LootUtils.CorpseRadius,
                    1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should scan for corpses.')
                if gui.CORPSERADIUS ~= FableLooter.LootUtils.CorpseRadius then
                    gui.CORPSERADIUS = FableLooter.LootUtils.CorpseRadius
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.MobsTooClose = ImGui.SliderInt("Mobs Too Close", FableLooter.LootUtils
                    .MobsTooClose, 1, 5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The range to check for nearby mobs.')
                if gui.MOBSTOOCLOSE ~= FableLooter.LootUtils.MobsTooClose then
                    gui.MOBSTOOCLOSE = FableLooter.LootUtils.MobsTooClose
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.StackPlatValue = ImGui.SliderInt("Stack Platinum Value",
                    FableLooter.LootUtils.StackPlatValue, 0, 10000)
                ImGui.SameLine()
                ImGui.HelpMarker('The value of platinum stacks.')
                if gui.STACKPLATVALUE ~= FableLooter.LootUtils.StackPlatValue then
                    gui.STACKPLATVALUE = FableLooter.LootUtils.StackPlatValue
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.SaveBagSlots = ImGui.SliderInt("Save Bag Slots", FableLooter.LootUtils
                    .SaveBagSlots, 0, 100)
                ImGui.SameLine()
                ImGui.HelpMarker('The number of bag slots to save.')
                if gui.SAVEBAGSLOTS ~= FableLooter.LootUtils.SaveBagSlots then
                    gui.SAVEBAGSLOTS = FableLooter.LootUtils.SaveBagSlots
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.MinSellPrice = ImGui.SliderInt("Min Sell Price", FableLooter.LootUtils
                    .MinSellPrice, 1, 100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum price at which items will be sold.')
                if gui.MINSELLPRICE ~= FableLooter.LootUtils.MinSellPrice then
                    gui.MINSELLPRICE = FableLooter.LootUtils.MinSellPrice
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.LootChannel = ImGui.InputText('Loot Channel', FableLooter.LootUtils.LootChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to report loot to.')
                if gui.LOOTCHANNEL ~= FableLooter.LootUtils.LootChannel then
                    gui.LOOTCHANNEL = FableLooter.LootUtils.LootChannel
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.AnnounceChannel = ImGui.InputText('Announce Channel',
                    FableLooter.LootUtils.AnnounceChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to announce events.')
                if gui.ANNOUNCECHANNEL ~= FableLooter.LootUtils.AnnounceChannel then
                    gui.ANNOUNCECHANNEL = FableLooter.LootUtils.AnnounceChannel
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.Settings.lootINIFile = ImGui.InputText('Loot file', FableLooter.Settings.lootINIFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot file to use.')
                if gui.LOOTINIFILE ~= FableLooter.Settings.lootINIFile then
                    gui.LOOTINIFILE = FableLooter.Settings.lootINIFile
                    FableLooter.LootUtils.Settings.LootFile = FableLooter.Settings.lootINIFile
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
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
end

function gui.initGUI()
    mq.imgui.init('FableLooter', gui.FableLooterGUI)
    gui.Open = true
end

return gui
