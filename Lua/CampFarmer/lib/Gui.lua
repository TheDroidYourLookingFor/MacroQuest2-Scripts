---@type Mq
local mq = require('mq')
local gui = {
    _version = '1.0.11',
    _author = 'TheDroidUrLookingFor'
}

-- CampFarmer
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
function gui.CampFarmerGUI()
    if gui.Open then
        gui.Open, gui.ShowUI = ImGui.Begin('TheDroid Camp Farmer v' .. CampFarmer._version, gui.Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        if gui.ShowUI then
            -- Get the elapsed time since CampFarmer.StartTime
            local formattedElapsedTime = CampFarmer.getElapsedTime(CampFarmer.StartTime)
            ImGui.SameLine(250)
            ImGui.Text('Run Time:')
            ImGui.SameLine()
            ImGui.Text(formattedElapsedTime)
            ImGui.Separator();
            local buttonWidth, buttonHeight = 140, 30
            local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
            if ImGui.Button('Bank', buttonImVec2) then
                CampFarmer.needToBank = true
            end
            ImGui.SameLine(150)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Plat Sell', buttonImVec2) then
                CampFarmer.needToVendorSell = true
            end
            ImGui.SameLine(300)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Cash Sell', buttonImVec2) then
                CampFarmer.needToCashSell = true
            end
            ImGui.SameLine(450)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Fabled Sell', buttonImVec2) then
                CampFarmer.needToFabledSell = true
            end

            if ImGui.CollapsingHeader("Camp Farmer") then
                ImGui.Indent()
                ImGui.Text("This is a simple script I threw together to help out a few friends.\n" ..
                    "It will loot anything set in the EZLoot.ini,\n")
                ImGui.Separator();

                ImGui.Text("COMMANDS:");
                ImGui.BulletText('/' .. CampFarmer.command_ShortName .. ' bank');
                ImGui.BulletText('/' .. CampFarmer.command_ShortName .. ' cash');
                ImGui.BulletText('/' .. CampFarmer.command_ShortName .. ' fabled');
                ImGui.BulletText('/' .. CampFarmer.command_ShortName .. ' quit');
                ImGui.Separator();

                ImGui.Text("CREDIT:");
                ImGui.BulletText("TheDroidUrLookingFor");
                ImGui.Unindent()
            end
            if ImGui.CollapsingHeader('Gains') then
                local totalDoubloons, doubloonsPerHour, totalPapers, papersPerHour, totalCash, cashPerHour = CampFarmer.CurrencyStatus()
                local totalAA, aaPerHour = CampFarmer.AAStatus()
                local formattedTotalAA = CampFarmer.formatNumberWithCommas(totalAA)
                local formattedAAPerHour = CampFarmer.formatNumberWithCommas(math.floor(aaPerHour))
                local formattedDoubloonsPerHour = CampFarmer.formatNumberWithCommas(math.floor(doubloonsPerHour))
                local formattedPaperssPerHour = CampFarmer.formatNumberWithCommas(math.floor(papersPerHour))
                local formattedCashPerHour = CampFarmer.formatNumberWithCommas(math.floor(cashPerHour))
                local formattedTotalDoubloons = CampFarmer.formatNumberWithCommas(totalDoubloons)
                local formattedTotalPapers = CampFarmer.formatNumberWithCommas(totalPapers)
                local formattedTotalCash = CampFarmer.formatNumberWithCommas(totalCash)
                ImGui.Text('AA Gained')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedTotalAA))
                ImGui.SameLine(400)
                ImGui.Text('AA / Hour')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedAAPerHour))
                ImGui.Separator();

                ImGui.Text('Doubloons Gained')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedTotalDoubloons))
                ImGui.SameLine(400)
                ImGui.Text('Doubloons / Hour')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedDoubloonsPerHour))
                ImGui.Separator();

                ImGui.Text('Papers Gained')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedTotalPapers))
                ImGui.SameLine(400)
                ImGui.Text('Papers / Hour')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedPaperssPerHour))
                ImGui.Separator();

                ImGui.Text('Cash Gained')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedTotalCash))
                ImGui.SameLine(400)
                ImGui.Text('Cash / Hour')
                ImGui.SameLine()
                ImGui.Text(tostring(formattedCashPerHour))
                ImGui.Separator();
            end
            if ImGui.CollapsingHeader("Options") then
                ImGui.Indent()
                if ImGui.CollapsingHeader("Items") then
                    ImGui.Indent()
                    CampFarmer.Settings.useCoinSack = ImGui.Checkbox('Enable Coin Sack', CampFarmer.Settings.useCoinSack)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use coin sack for free donator coins??')
                    if gui.USECOINSACK ~= CampFarmer.Settings.useCoinSack then
                        gui.USECOINSACK = CampFarmer.Settings.useCoinSack
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.aggroItem = ImGui.InputText('Aggro Item', CampFarmer.Settings.aggroItem)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your zone wide aggro item.')
                    if gui.AGGROITEM ~= CampFarmer.Settings.aggroItem then
                        gui.AGGROITEM = CampFarmer.Settings.aggroItem
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.aggroUberItem = ImGui.InputText('Uber Aggro Item',
                        CampFarmer.Settings.aggroUberItem)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your uber zone wide aggro item.')
                    if gui.AGGROUBERITEM ~= CampFarmer.Settings.aggroUberItem then
                        gui.AGGROUBERITEM = CampFarmer.Settings.aggroUberItem
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.UberPullMobsInZone = ImGui.InputInt("Uber Pull Limit",
                        CampFarmer.Settings.UberPullMobsInZone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of mobs allowed before we uber pull them.')
                    if gui.UBERPULLMOBSINZONE ~= CampFarmer.Settings.UberPullMobsInZone then
                        gui.UBERPULLMOBSINZONE = CampFarmer.Settings.UberPullMobsInZone
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.respawnItem = ImGui.InputText('Respawn Item', CampFarmer.Settings.respawnItem)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your zone respawn item.')
                    if gui.RESPAWNITEM ~= CampFarmer.Settings.respawnItem then
                        gui.RESPAWNITEM = CampFarmer.Settings.respawnItem
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.MinMobsInZone = ImGui.InputInt("Respawn Mobs Limit",
                        CampFarmer.Settings.MinMobsInZone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of mobs allowed before we respawn the zone.')
                    if gui.MINMOBSINZONE ~= CampFarmer.Settings.MinMobsInZone then
                        gui.MINMOBSINZONE = CampFarmer.Settings.MinMobsInZone
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.buffCharmName = ImGui.InputText('Buff Item', CampFarmer.Settings.buffCharmName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of your buff item.')
                    if gui.BUFFCHARMNAME ~= CampFarmer.Settings.buffCharmName then
                        gui.BUFFCHARMNAME = CampFarmer.Settings.buffCharmName
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.buffCharmBuffName = ImGui.InputText('Buff Name',
                        CampFarmer.Settings.buffCharmBuffName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name the buff to check if buff item worked.')
                    if gui.BUFFCHARMBUFFNAME ~= CampFarmer.Settings.buffCharmBuffName then
                        gui.BUFFCHARMBUFFNAME = CampFarmer.Settings.buffCharmBuffName
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.GroupAlt = ImGui.Checkbox('Enable Grouping Alt', CampFarmer.Settings.GroupAlt)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we the amount of corpses the client sees?')
                    if gui.GROUPALT ~= CampFarmer.Settings.GroupAlt then
                        gui.GROUPALT = CampFarmer.Settings.GroupAlt
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.AltLooterName = ImGui.InputText('Looter Alt Name',
                        CampFarmer.Settings.AltLooterName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name your alt who is looting.')
                    if gui.ALTLOOTERNAME ~= CampFarmer.Settings.AltLooterName then
                        gui.ALTLOOTERNAME = CampFarmer.Settings.AltLooterName
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Donor Items") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    CampFarmer.Settings.useBemChest = ImGui.Checkbox('Enable Bems Chest', CampFarmer.Settings
                    .useBemChest)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Bemevaras Breastplate?')
                    if gui.USEBEMCHEST ~= CampFarmer.Settings.useBemChest then
                        gui.USEBEMCHEST = CampFarmer.Settings.useBemChest
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.useBemGloves = ImGui.Checkbox('Enable Bems Gloves',
                        CampFarmer.Settings.useBemGloves)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Bemevaras Gloves?')
                    if gui.USEBEMGLOVES ~= CampFarmer.Settings.useBemGloves then
                        gui.USEBEMGLOVES = CampFarmer.Settings.useBemGloves
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.useBemLegs = ImGui.Checkbox('Enable Bems Legs', CampFarmer.Settings.useBemLegs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Bemevaras Leggings?')
                    if gui.USEBEMLEGS ~= CampFarmer.Settings.useBemLegs then
                        gui.USEBEMLEGS = CampFarmer.Settings.useBemLegs
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.useErtzStone = ImGui.Checkbox('Enable Ertz\'s Stone',
                        CampFarmer.Settings.useErtzStone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use Ertz\'s Mage Stone in combat?')
                    if gui.USEERTZSTONE ~= CampFarmer.Settings.useErtzStone then
                        gui.USEERTZSTONE = CampFarmer.Settings.useErtzStone
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.useCurrencyCharm = ImGui.Checkbox('Enable Currency Stone',
                        CampFarmer.Settings.useCurrencyCharm)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Use currency doubler?')
                    if gui.USECURRENCYCHARM ~= CampFarmer.Settings.useCurrencyCharm then
                        gui.USECURRENCYCHARM = CampFarmer.Settings.useCurrencyCharm
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    ImGui.Columns(1);
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("AAs") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    CampFarmer.Settings.useClericAA = ImGui.Checkbox('Enable Cleric AA', CampFarmer.Settings.useClericAA)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Enable the use of the Cleric Class AA.')
                    if gui.USECLERICAA ~= CampFarmer.Settings.useClericAA then
                        gui.USECLERICAA = CampFarmer.Settings.useClericAA
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.usePaladinAA = ImGui.Checkbox('Enable Paladin AA',
                        CampFarmer.Settings.usePaladinAA)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Enable the use of the Paladin Class AA.')
                    if gui.USEPALADINAA ~= CampFarmer.Settings.usePaladinAA then
                        gui.USEPALADINAA = CampFarmer.Settings.usePaladinAA
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Columns(1);
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Experience Potions") then
                    ImGui.Indent()
                    CampFarmer.Settings.useExpPotions = ImGui.Checkbox('Enable Exp Potions',
                        CampFarmer.Settings.useExpPotions)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                    if gui.USEEXPPOTIONS ~= CampFarmer.Settings.useExpPotions then
                        gui.USEEXPPOTIONS = CampFarmer.Settings.useExpPotions
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.potionName = ImGui.InputText('Potion Name', CampFarmer.Settings.potionName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the experience potion.')
                    if gui.POTIONNAME ~= CampFarmer.Settings.potionName then
                        gui.POTIONNAME = CampFarmer.Settings.potionName
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.potionBuff = ImGui.InputText('Potion Buff', CampFarmer.Settings.potionBuff)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the experience buff.')
                    if gui.POTIONBUFF ~= CampFarmer.Settings.potionBuff then
                        gui.POTIONBUFF = CampFarmer.Settings.potionBuff
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Hunt Method") then
                    ImGui.Indent()
                    CampFarmer.Settings.staticHunt = ImGui.Checkbox('Enable Static Hunt', CampFarmer.Settings.staticHunt)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Always use the same Hunting Zone.')
                    if gui.STATICHUNT ~= CampFarmer.Settings.staticHunt then
                        gui.STATICHUNT = CampFarmer.Settings.staticHunt
                        CampFarmer.CheckCampInfo()
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.staticZoneName = ImGui.InputText('Zone Name', CampFarmer.Settings.staticZoneName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The short name of the Static Hunt Zone.')
                    if gui.STATICZONENAME ~= CampFarmer.Settings.staticZoneName then
                        gui.STATICZONENAME = CampFarmer.Settings.staticZoneName
                        CampFarmer.CheckCampInfo()
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.staticZoneID = ImGui.InputText('Zone ID', CampFarmer.Settings.staticZoneID)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The ID of the static Hunting Zone.')
                    if gui.STATICZONEID ~= CampFarmer.Settings.staticZoneID then
                        gui.STATICZONEID = CampFarmer.Settings.staticZoneID
                        CampFarmer.CheckCampInfo()
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    local start_y_Options = ImGui.GetCursorPosY()
                    ImGui.SetCursorPosY(start_y_Options + 3)
                    ImGui.Text('X')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.staticX = ImGui.InputText('##Zone X', CampFarmer.Settings.staticX)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The X loc in the static Hunting Zone to camp.')
                    if gui.STATICX ~= CampFarmer.Settings.staticX then
                        gui.STATICX = CampFarmer.Settings.staticX
                        CampFarmer.CheckCampInfo()
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.SameLine();

                    ImGui.SetCursorPosY(start_y_Options + 1)
                    ImGui.Text('Y')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.staticY = ImGui.InputText('##Zone Y', CampFarmer.Settings.staticY)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The Y loc in the static Hunting Zone to camp.')
                    if gui.STATICY ~= CampFarmer.Settings.staticY then
                        gui.STATICY = CampFarmer.Settings.staticY
                        CampFarmer.CheckCampInfo()
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.SameLine();

                    ImGui.SetCursorPosY(start_y_Options + 1)
                    ImGui.Text('Z')
                    ImGui.SameLine()
                    ImGui.SetNextItemWidth(120)
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.staticZ = ImGui.InputText('##Zone Z', CampFarmer.Settings.staticZ)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The Z loc in the static Hunting Zone to camp.')
                    if gui.STATICZ ~= CampFarmer.Settings.staticZ then
                        gui.STATICZ = CampFarmer.Settings.staticZ
                        CampFarmer.CheckCampInfo()
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Hub Operations") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    CampFarmer.Settings.bankDeposit = ImGui.Checkbox('Enable Bank Deposit',
                        CampFarmer.Settings.bankDeposit)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Moves to hub to deposit items into bank when limit is reached.')
                    if gui.BANKDEPOSIT ~= CampFarmer.Settings.bankDeposit then
                        gui.BANKDEPOSIT = CampFarmer.Settings.bankDeposit
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.sellVendor = ImGui.Checkbox('Enable Vendor Selling',
                        CampFarmer.Settings.sellVendor)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items for Platinum when enabled.')
                    if gui.SELLVENDOR ~= CampFarmer.Settings.sellVendor then
                        gui.SELLVENDOR = CampFarmer.Settings.sellVendor
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.sellFabled = ImGui.Checkbox('Enable Fabled Item Selling',
                        CampFarmer.Settings.sellFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items fabled items for currency when enabled.')
                    if gui.SELLFABLED ~= CampFarmer.Settings.sellFabled then
                        gui.SELLFABLED = CampFarmer.Settings.sellFabled
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.sellCash = ImGui.Checkbox('Enable Cash Item Selling',
                        CampFarmer.Settings.sellCash)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Sells items for Cash when enabled.')
                    if gui.SELLCASH ~= CampFarmer.Settings.sellCash then
                        gui.SELLCASH = CampFarmer.Settings.sellCash
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Columns(1)

                    CampFarmer.Settings.bankZone = ImGui.InputInt('Bank Zone', CampFarmer.Settings.bankZone)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Zone where we can access banking services.')
                    if gui.BANKZONE ~= CampFarmer.Settings.bankZone then
                        gui.BANKZONE = CampFarmer.Settings.bankZone
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.bankNPC = ImGui.InputText('Bank NPC', CampFarmer.Settings.bankNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for banking.')
                    if gui.BANKNPC ~= CampFarmer.Settings.bankNPC then
                        gui.BANKNPC = CampFarmer.Settings.bankNPC
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.vendorNPC = ImGui.InputText('Vendor NPC', CampFarmer.Settings.vendorNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to warp to for vendoring.')
                    if gui.VENDORNPC ~= CampFarmer.Settings.vendorNPC then
                        gui.VENDORNPC = CampFarmer.Settings.vendorNPC
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.cashNPC = ImGui.InputText('Cash NPC', CampFarmer.Settings.cashNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to sell cash items to.')
                    if gui.CASHNPC ~= CampFarmer.Settings.cashNPC then
                        gui.CASHNPC = CampFarmer.Settings.cashNPC
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.SellFabledFor_idx = gui.CreateComboBox:draw("Fabled Sell For",
                        gui.SellFabledForType, CampFarmer.Settings.SellFabledFor_idx);
                    if SellFabledFor_idx ~= CampFarmer.Settings.SellFabledFor_idx then
                        SellFabledFor_idx = CampFarmer.Settings.SellFabledFor_idx
                        if SellFabledFor_idx == 1 then
                            CampFarmer.Settings.SellFabledFor = 'Doubloons'
                        elseif SellFabledFor_idx == 2 then
                            CampFarmer.Settings.SellFabledFor = 'Papers'
                        else
                            CampFarmer.Settings.SellFabledFor = 'Cash'
                        end
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end

                    CampFarmer.Settings.fabledNPC = ImGui.InputText('Fabled NPC', CampFarmer.Settings.fabledNPC)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The name of the npc to sell fabled items to.')
                    if gui.FABLEDNPC ~= CampFarmer.Settings.fabledNPC then
                        gui.FABLEDNPC = CampFarmer.Settings.fabledNPC
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.bankAtFreeSlots = ImGui.InputInt("Inventory Free Slots",
                        CampFarmer.Settings.bankAtFreeSlots, 1, 20)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of free slots before we should bank.')
                    if gui.BANKATFREESLOTS ~= CampFarmer.Settings.bankAtFreeSlots then
                        gui.BANKATFREESLOTS = CampFarmer.Settings.bankAtFreeSlots
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Movement Operations") then
                    ImGui.Indent()
                    ImGui.Columns(2)
                    local start_y_Options = ImGui.GetCursorPosY()
                    CampFarmer.Settings.returnHomeAfterLoot = ImGui.Checkbox('Enable Return Home After Loot',
                        CampFarmer.Settings.returnHomeAfterLoot)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Return to start X/Y/Z after looting?')
                    if gui.RETURNHOMEAFTERLOOT ~= CampFarmer.Settings.returnHomeAfterLoot then
                        gui.RETURNHOMEAFTERLOOT = CampFarmer.Settings.returnHomeAfterLoot
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    ImGui.NextColumn();
                    ImGui.SetCursorPosY(start_y_Options)
                    CampFarmer.Settings.lootGroundSpawns = ImGui.Checkbox('Enable Pickup Groundspawns',
                        CampFarmer.Settings.lootGroundSpawns)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we pickup groundspawns treasure goblins drops?')
                    if gui.LOOTGROUNDSPAWNS ~= CampFarmer.Settings.lootGroundSpawns then
                        gui.LOOTGROUNDSPAWNS = CampFarmer.Settings.lootGroundSpawns
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Columns(1)

                    CampFarmer.Settings.ReturnToHomeDistance = ImGui.InputInt("Return To Home Distance",
                        CampFarmer.Settings.ReturnToHomeDistance, 1, 100000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The distance we can get before we trigger return to camp.')
                    if gui.RETURNTOCAMPDISTANCE ~= CampFarmer.Settings.ReturnToHomeDistance then
                        gui.RETURNTOCAMPDISTANCE = CampFarmer.Settings.ReturnToHomeDistance
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                if ImGui.CollapsingHeader("Corpse Cleanup") then
                    ImGui.Indent()
                    CampFarmer.Settings.corpseCleanup = ImGui.Checkbox('Enable Corpse Cleanup',
                        CampFarmer.Settings.corpseCleanup)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we the amount of corpses the client sees?')
                    if gui.CORPSECLEANUP ~= CampFarmer.Settings.corpseCleanup then
                        gui.CORPSECLEANUP = CampFarmer.Settings.corpseCleanup
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.corpseCleanupCommand = ImGui.InputText('Corpse Cleanup Command',
                        CampFarmer.Settings.corpseCleanupCommand)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Look for this name on corpses when looting.')
                    if gui.CORPSECLEANUPCOMMAND ~= CampFarmer.Settings.corpseCleanupCommand then
                        gui.CORPSECLEANUPCOMMAND = CampFarmer.Settings.corpseCleanupCommand
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.corpseLimit = ImGui.InputInt("Corpse Limit", CampFarmer.Settings.corpseLimit)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The amount of corpses allowed before we clean them for performance.')
                    if gui.CORPSELIMIT ~= CampFarmer.Settings.corpseLimit then
                        gui.CORPSELIMIT = CampFarmer.Settings.corpseLimit
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();
                    ImGui.Unindent();
                end
                if ImGui.CollapsingHeader("Corpse Targetting") then
                    ImGui.Indent();
                    CampFarmer.Settings.lootAll = ImGui.Checkbox('Enable Loot all', CampFarmer.Settings.lootAll)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Should we just loot all corpses ignoring corpse filter?')
                    if gui.LOOTALL ~= CampFarmer.Settings.lootAll then
                        gui.LOOTALL = CampFarmer.Settings.lootAll
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.targetName = ImGui.InputText('Corpse Target Name', CampFarmer.Settings
                    .targetName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Look for this name on corpses when looting.')
                    if gui.TARGETNAME ~= CampFarmer.Settings.targetName then
                        gui.TARGETNAME = CampFarmer.Settings.targetName
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.spawnSearch = ImGui.InputText('Corpse Search', CampFarmer.Settings.spawnSearch)
                    ImGui.SameLine()
                    ImGui.HelpMarker('How we should filter corpses')
                    if gui.SPAWNSEARCH ~= CampFarmer.Settings.spawnSearch then
                        gui.SPAWNSEARCH = CampFarmer.Settings.spawnSearch
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.scan_Radius = ImGui.InputInt("Scan Radius", CampFarmer.Settings.scan_Radius, 1,
                        100000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The radius we should look for corpses.')
                    if gui.SCANRADIUS ~= CampFarmer.Settings.scan_Radius then
                        gui.SCANRADIUS = CampFarmer.Settings.scan_Radius
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Separator();

                    CampFarmer.Settings.scan_zRadius = ImGui.InputInt("Scan zRadius", CampFarmer.Settings.scan_zRadius, 1,
                        10000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('The z radius we should look for corpses.')
                    if gui.SCANZRADIUS ~= CampFarmer.Settings.scan_zRadius then
                        gui.SCANZRADIUS = CampFarmer.Settings.scan_zRadius
                        CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                    end
                    ImGui.Unindent();
                end
                ImGui.Columns(2)
                local start_y_Options = ImGui.GetCursorPosY()
                CampFarmer.Settings.debug = ImGui.Checkbox('Enable Debug Messages', CampFarmer.Settings.debug)
                ImGui.SameLine()
                ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
                if gui.DEBUG ~= CampFarmer.Settings.debug then
                    gui.DEBUG = CampFarmer.Settings.debug
                    CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                end
                ImGui.Separator();

                CampFarmer.Settings.KeepMaxLevel = ImGui.Checkbox('Enable Keep Max Lvl', CampFarmer.Settings
                .KeepMaxLevel)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we try to stay level 80 if we die?')
                if gui.KEEPMAXLEVEL ~= CampFarmer.Settings.KeepMaxLevel then
                    gui.KEEPMAXLEVEL = CampFarmer.Settings.KeepMaxLevel
                    CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                end
                ImGui.Separator();

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y_Options)
                CampFarmer.Settings.doStand = ImGui.Checkbox('Enable Do Stand', CampFarmer.Settings.doStand)
                ImGui.SameLine()
                ImGui.HelpMarker('Should we stand up if we arent?')
                if gui.DOSTAND ~= CampFarmer.Settings.doStand then
                    gui.DOSTAND = CampFarmer.Settings.doStand
                    CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                end
                ImGui.Columns(1);
                ImGui.Unindent()
            end
            if ImGui.CollapsingHeader('EZLoot Options') then
                ImGui.Indent()
                if ImGui.CollapsingHeader("WastingTime Options") then
                    ImGui.Indent()
                    CampFarmer.LootUtils.LootPlatinumBags = ImGui.Checkbox('Enable Loot Platinum Bags',
                        CampFarmer.LootUtils.LootPlatinumBags)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots platinum bags.')
                    if gui.LOOTPLATINUMBAGS ~= CampFarmer.LootUtils.LootPlatinumBags then
                        gui.LOOTPLATINUMBAGS = CampFarmer.LootUtils.LootPlatinumBags
                        CampFarmer.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    CampFarmer.LootUtils.LootTokensOfAdvancement = ImGui.Checkbox('Enable Loot Tokens of Advancement',
                        CampFarmer.LootUtils.LootTokensOfAdvancement)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots tokens of advancement.')
                    if gui.LOOTTOKENSOFADVANCEMENT ~= CampFarmer.LootUtils.LootTokensOfAdvancement then
                        gui.LOOTTOKENSOFADVANCEMENT = CampFarmer.LootUtils.LootTokensOfAdvancement
                        CampFarmer.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    CampFarmer.LootUtils.LootEmpoweredFabled = ImGui.Checkbox('Enable Loot Empowered Fabled',
                        CampFarmer.LootUtils.LootEmpoweredFabled)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots empowered fabled items.')
                    if gui.LOOTEMPOWEREDFABLED ~= CampFarmer.LootUtils.LootEmpoweredFabled then
                        gui.LOOTEMPOWEREDFABLED = CampFarmer.LootUtils.LootEmpoweredFabled
                        CampFarmer.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    CampFarmer.LootUtils.LootAllFabledAugs = ImGui.Checkbox('Enable Loot All Fabled Augments',
                        CampFarmer.LootUtils.LootAllFabledAugs)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Loots all fabled augments.')
                    if gui.LOOTALLFABLEDAUGS ~= CampFarmer.LootUtils.LootAllFabledAugs then
                        gui.LOOTALLFABLEDAUGS = CampFarmer.LootUtils.LootAllFabledAugs
                        CampFarmer.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    CampFarmer.LootUtils.EmpoweredFabledMinHP = ImGui.InputInt("Empowered Fabled Min HP",
                        CampFarmer.LootUtils.EmpoweredFabledMinHP, 0, 1000)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Minimum HP for Empowered Fabled to be considered.')
                    if gui.EMPOWEREDFABLEDMINHP ~= CampFarmer.LootUtils.EmpoweredFabledMinHP then
                        gui.EMPOWEREDFABLEDMINHP = CampFarmer.LootUtils.EmpoweredFabledMinHP
                        CampFarmer.LootUtils.writeSettings()
                    end
                    ImGui.Separator();

                    CampFarmer.LootUtils.EmpoweredFabledName = ImGui.InputText('Empowered Fabled Name',
                        CampFarmer.LootUtils.EmpoweredFabledName)
                    ImGui.SameLine()
                    ImGui.HelpMarker('Name of the empowered fabled item.')
                    if gui.EMPOWEREDFABLEDNAME ~= CampFarmer.LootUtils.EmpoweredFabledName then
                        gui.EMPOWEREDFABLEDNAME = CampFarmer.LootUtils.EmpoweredFabledName
                        CampFarmer.LootUtils.writeSettings()
                    end
                    ImGui.Separator();
                    ImGui.Unindent()
                end
                ImGui.Columns(2)
                local start_y = ImGui.GetCursorPosY()
                CampFarmer.LootUtils.UseWarp = ImGui.Checkbox('Enable Warp', CampFarmer.LootUtils.UseWarp)
                ImGui.SameLine()
                ImGui.HelpMarker('Uses warp when enabled.')
                if gui.USEWARP ~= CampFarmer.LootUtils.UseWarp then
                    gui.USEWARP = CampFarmer.LootUtils.UseWarp
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.AddNewSales = ImGui.Checkbox('Enable New Sales', CampFarmer.LootUtils.AddNewSales)
                ImGui.SameLine()
                ImGui.HelpMarker('Add new sales when enabled.')
                if gui.ADDNEWSALES ~= CampFarmer.LootUtils.AddNewSales then
                    gui.ADDNEWSALES = CampFarmer.LootUtils.AddNewSales
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.LootForage = ImGui.Checkbox('Enable Loot Forage', CampFarmer.LootUtils.LootForage)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot forage when enabled.')
                if gui.LOOTFORAGE ~= CampFarmer.LootUtils.LootForage then
                    gui.LOOTFORAGE = CampFarmer.LootUtils.LootForage
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.LootTradeSkill = ImGui.Checkbox('Enable Loot TradeSkill',
                    CampFarmer.LootUtils.LootTradeSkill)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot trade skill items when enabled.')
                if gui.LOOTTRADESKILL ~= CampFarmer.LootUtils.LootTradeSkill then
                    gui.LOOTTRADESKILL = CampFarmer.LootUtils.LootTradeSkill
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.Settings.DoLoot = ImGui.Checkbox('Enable Looting', CampFarmer.Settings.DoLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables looting.')
                if gui.DOLOOT ~= CampFarmer.Settings.DoLoot then
                    gui.DOLOOT = CampFarmer.Settings.DoLoot
                    CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                end
                ImGui.Separator();

                CampFarmer.LootUtils.EquipUsable = ImGui.Checkbox('Enable Equip Usable', CampFarmer.LootUtils
                .EquipUsable)
                ImGui.SameLine()
                ImGui.HelpMarker('Equips usable items. Buggy at best.')
                if gui.EQUIPUSABLE ~= CampFarmer.LootUtils.EquipUsable then
                    gui.EQUIPUSABLE = CampFarmer.LootUtils.EquipUsable
                    CampFarmer.LootUtils.writeSettings()
                end

                ImGui.NextColumn();
                ImGui.SetCursorPosY(start_y)
                CampFarmer.LootUtils.AnnounceLoot = ImGui.Checkbox('Enable Announce Loot',
                    CampFarmer.LootUtils.AnnounceLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to announce channel.')
                if gui.ANNOUNCELOOT ~= CampFarmer.LootUtils.AnnounceLoot then
                    gui.ANNOUNCELOOT = CampFarmer.LootUtils.AnnounceLoot
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.ReportLoot = ImGui.Checkbox('Enable Report Loot', CampFarmer.LootUtils.ReportLoot)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports looted items to console.')
                if gui.REPORTLOOT ~= CampFarmer.LootUtils.ReportLoot then
                    gui.REPORTLOOT = CampFarmer.LootUtils.ReportLoot
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.ReportSkipped = ImGui.Checkbox('Enable Report Skipped',
                    CampFarmer.LootUtils.ReportSkipped)
                ImGui.SameLine()
                ImGui.HelpMarker('Reports skipped loots.')
                if gui.REPORTSKIPPED ~= CampFarmer.LootUtils.ReportSkipped then
                    gui.REPORTSKIPPED = CampFarmer.LootUtils.ReportSkipped
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.SpamLootInfo = ImGui.Checkbox('Enable Spam Loot Info',
                    CampFarmer.LootUtils.SpamLootInfo)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot info.')
                if gui.SPAMLOOTINFO ~= CampFarmer.LootUtils.SpamLootInfo then
                    gui.SPAMLOOTINFO = CampFarmer.LootUtils.SpamLootInfo
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.LootForageSpam = ImGui.Checkbox('Enable Loot Forage Spam',
                    CampFarmer.LootUtils.LootForageSpam)
                ImGui.SameLine()
                ImGui.HelpMarker('Spams loot forage info.')
                if gui.LOOTFORAGESPAM ~= CampFarmer.LootUtils.LootForageSpam then
                    gui.LOOTFORAGESPAM = CampFarmer.LootUtils.LootForageSpam
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.Settings.CombatLooting = ImGui.Checkbox('Enable Combat Looting',
                    CampFarmer.Settings.CombatLooting)
                ImGui.SameLine()
                ImGui.HelpMarker('Loots during combat.')
                if gui.COMBATLOOTING ~= CampFarmer.Settings.CombatLooting then
                    gui.COMBATLOOTING = CampFarmer.Settings.CombatLooting
                    CampFarmer.Storage.SaveSettings(CampFarmer.settingsFile, CampFarmer.Settings)
                end
                ImGui.Columns(1)

                CampFarmer.LootUtils.CorpseRadius = ImGui.InputInt("Corpse Radius", CampFarmer.LootUtils.CorpseRadius, 1,
                    5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The radius we should scan for corpses.')
                if gui.CORPSERADIUS ~= CampFarmer.LootUtils.CorpseRadius then
                    gui.CORPSERADIUS = CampFarmer.LootUtils.CorpseRadius
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.MobsTooClose = ImGui.InputInt("Mobs Too Close", CampFarmer.LootUtils.MobsTooClose, 1,
                    5000)
                ImGui.SameLine()
                ImGui.HelpMarker('The range to check for nearby mobs.')
                if gui.MOBSTOOCLOSE ~= CampFarmer.LootUtils.MobsTooClose then
                    gui.MOBSTOOCLOSE = CampFarmer.LootUtils.MobsTooClose
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.StackPlatValue = ImGui.InputInt("Stack Platinum Value",
                    CampFarmer.LootUtils.StackPlatValue, 0, 10000)
                ImGui.SameLine()
                ImGui.HelpMarker('The value of platinum stacks.')
                if gui.STACKPLATVALUE ~= CampFarmer.LootUtils.StackPlatValue then
                    gui.STACKPLATVALUE = CampFarmer.LootUtils.StackPlatValue
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.SaveBagSlots = ImGui.InputInt("Save Bag Slots", CampFarmer.LootUtils.SaveBagSlots, 0,
                    100)
                ImGui.SameLine()
                ImGui.HelpMarker('The number of bag slots to save.')
                if gui.SAVEBAGSLOTS ~= CampFarmer.LootUtils.SaveBagSlots then
                    gui.SAVEBAGSLOTS = CampFarmer.LootUtils.SaveBagSlots
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.MinSellPrice = ImGui.InputInt("Min Sell Price", CampFarmer.LootUtils.MinSellPrice, 1,
                    100000)
                ImGui.SameLine()
                ImGui.HelpMarker('The minimum price at which items will be sold.')
                if gui.MINSELLPRICE ~= CampFarmer.LootUtils.MinSellPrice then
                    gui.MINSELLPRICE = CampFarmer.LootUtils.MinSellPrice
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.LootChannel = ImGui.InputText('Loot Channel', CampFarmer.LootUtils.LootChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to report loot to.')
                if gui.LOOTCHANNEL ~= CampFarmer.LootUtils.LootChannel then
                    gui.LOOTCHANNEL = CampFarmer.LootUtils.LootChannel
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.LootUtils.AnnounceChannel = ImGui.InputText('Announce Channel',
                    CampFarmer.LootUtils.AnnounceChannel)
                ImGui.SameLine()
                ImGui.HelpMarker('Channel to announce events.')
                if gui.ANNOUNCECHANNEL ~= CampFarmer.LootUtils.AnnounceChannel then
                    gui.ANNOUNCECHANNEL = CampFarmer.LootUtils.AnnounceChannel
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();

                CampFarmer.Settings.lootINIFile = ImGui.InputText('Loot file', CampFarmer.Settings.lootINIFile)
                ImGui.SameLine()
                ImGui.HelpMarker('Loot file to use.')
                if gui.LOOTINIFILE ~= CampFarmer.Settings.lootINIFile then
                    gui.LOOTINIFILE = CampFarmer.Settings.lootINIFile
                    CampFarmer.LootUtils.writeSettings()
                end
                ImGui.Separator();
                ImGui.Unindent()
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
    mq.imgui.init('CampFarmer', gui.CampFarmerGUI)
    gui.Open = true
end

return gui
