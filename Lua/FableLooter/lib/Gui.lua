---@type Mq
local mq = require('mq')
local gui = {}

gui.version = '1.0.0'

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
gui.CASHNPC = 'Silent Bob'
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

-- EZLoot
gui.USEWARP = true
gui.ADDNEWSALES = true
gui.LOOTFORAGE = true
gui.LOOTTRADESKILL = false
gui.DOLOOT = true
gui.EQUIPUSABLE = false
gui.CORPSERADIUS = 100
gui.MOBSTOOCLOSE = 40
gui.REPORTLOOT = true
gui.REPORTSKIPPED = true
gui.LOOTCHANNEL = "dgt"
gui.ANNOUNCECHANNEL = 'dgt'
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
            local buttonWidth, buttonHeight = 150, 30
            local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
            if ImGui.Button('Bank', buttonImVec2) then
                FableLooter.needToBank = true
            end
            ImGui.SameLine(235)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Cash Sell', buttonImVec2) then
                FableLooter.needToCashSell = true
            end
            ImGui.SameLine(455)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Fabled Sell', buttonImVec2) then
                FableLooter.needToFabledSell = true
            end

            if ImGui.CollapsingHeader("Fable Loot Bot") then
                ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                    "It will loot anything set in the EZLoot.ini,\n")
                ImGui.Separator();

                ImGui.Text("FEATURES:");
                ImGui.BulletText("");
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' bank');
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' cash');
                ImGui.BulletText('/' .. FableLooter.command_ShortName .. ' quit');
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

                FableLooter.Settings.sellCash = ImGui.Checkbox('Enable Cash Item Selling', FableLooter.Settings
                    .sellCash)
                ImGui.SameLine()
                ImGui.HelpMarker('Sells items for Cash when enabled.')
                if gui.SELLCASH ~= FableLooter.Settings.sellCash then
                    gui.SELLCASH = FableLooter.Settings.sellCash
                    FableLooter.Storage.SaveSettings(FableLooter.settingsFile, FableLooter.Settings)
                end
                ImGui.Separator();

                FableLooter.Settings.sellFabled = ImGui.Checkbox('Enable Fabled Item Selling', FableLooter.Settings
                    .sellFabled)
                ImGui.SameLine()
                ImGui.HelpMarker('Sells items fabled items for currency when enabled.')
                if gui.SELLFABLED ~= FableLooter.Settings.sellFabled then
                    gui.SELLFABLED = FableLooter.Settings.sellFabled
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
                ImGui.HelpMarker('The name of the npc to warp to to bank.')
                if gui.BANKNPC ~= FableLooter.Settings.bankNPC then
                    gui.BANKNPC = FableLooter.Settings.bankNPC
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

                FableLooter.Settings.fabledNPC = ImGui.InputText('Cash NPC', FableLooter.Settings.fabledNPC)
                ImGui.SameLine()
                ImGui.HelpMarker('The name of the npc to sell fabled items to.')
                if gui.FABLEDNPC ~= FableLooter.Settings.fabledNPC then
                    gui.FABLEDNPC = FableLooter.Settings.fabledNPC
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
                ImGui.HelpMarker('Should we just loot all corpses ignoring corpse filter?')
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
            if ImGui.CollapsingHeader('EZLoot Options') then
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
                ImGui.Separator();

                FableLooter.LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot', FableLooter.LootUtils.ReportLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items.')
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
                ImGui.Separator();

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

                FableLooter.LootUtils.EmpoweredFabledMinHP = ImGui.SliderInt("Empowered Fabled Min HP",
                    FableLooter.LootUtils.EmpoweredFabledMinHP, 1, 10000)
                ImGui.SameLine()
                ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                if gui.EMPOWEREDFABLEDMINHP ~= FableLooter.LootUtils.EmpoweredFabledMinHP then
                    gui.EMPOWEREDFABLEDMINHP = FableLooter.LootUtils.EmpoweredFabledMinHP
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

                FableLooter.LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name',
                    FableLooter.LootUtils.EmpoweredFabledName)
                ImGui.SameLine()
                ImGui.HelpMarker('Name of the empowered fabled item.')
                if gui.EMPOWEREDFABLEDNAME ~= FableLooter.LootUtils.EmpoweredFabledName then
                    gui.EMPOWEREDFABLEDNAME = FableLooter.LootUtils.EmpoweredFabledName
                    FableLooter.LootUtils.writeSettings()
                end
                ImGui.Separator();

                FableLooter.LootUtils.Defaults = ImGui.InputText('Loot Defaults', FableLooter.LootUtils.Defaults)
                ImGui.SameLine()
                ImGui.HelpMarker('Default loot actions.')
                if gui.DEFAULTS ~= FableLooter.LootUtils.Defaults then
                    gui.DEFAULTS = FableLooter.LootUtils.Defaults
                    FableLooter.LootUtils.writeSettings()
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
