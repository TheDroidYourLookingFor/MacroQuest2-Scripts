local version = '1.0.0'
---|------------------------------------------------------------|
---|                   BuffBot
---|
---|              Created by: TheDroidUrLookingFor
---|              Modified by: TheDroidUrLookingFor
---|
---|		     Version: 1.0.0
---|
---|------------------------------------------------------------|

---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'
Casting = require('BuffBot.Core.Casting')
Accounting = require('BuffBot.Accounting.Accounting')

local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
IniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. my_Name .. '.ini'

DEBUG = false
MedAtPct = 30
DoneMeddingPct = 75
AfkMessage = 'Find me in Guild Lobby if you need me.'
MedMessage = '..Meditating... Low on mana.'
MountItem = 'Jungle Raptor Saddle'
UseMount = false
BuffCost = 100
SummonCost = 100
RezCost = 100
AccountMode = false
FriendMode = false
GuildMode = false
BuffGuildOnly = false
FriendFree = true
GuildFree = true
Advertise = false
AdvertiseChat = '/say'
AdvertiseMessage = ''
PortChat = '/say'
PortMessage = ''

local MainLoop = true
local BotRunning = true
local supported_Class = false

Settings = {
    debug = false,
    medAtPct = 35,
    medDonePct = 75,
    afkMessage = 'Find me in Guild Lobby if you need me.',
    medMessage = '..Meditating... Low on mana.',
    useMount = false,
    mountItem = 'Jungle Raptor Saddle',
    advertise = false,
    advertiseChat = '/say',
    advertiseMessage = '',
    portChat = '/say',
    portMessage = '',
    buffCost = 100,
    summonCost = 100,
    rezCost = 100,
    accountMode = false,
    friendMode = false,
    guildMode = false,
    buffGuildOnly = false,
    friendFree = true,
    guildFree = true
}

function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = 'BuffBot'
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    if Settings.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function SaveSettings(iniFile, settingsList)
    CONSOLEMETHOD('function SaveSettings(iniFile, settingsList) Entry')
---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function Setup()
    CONSOLEMETHOD('function Setup() Entry')
    local conf
    local configData, err = loadfile(IniPath)
    if err then
        SaveSettings(IniPath, Settings)
    elseif configData then
        conf = configData()
        Settings = conf
    end
end

Setup()

CONSOLEMETHOD('Class detected as %s', my_Class)
Class = require('BuffBot.Classes.' .. my_Class .. '')

local ports_List_txt
local function CheckClassSupport()
    local supported_Classes = {
        Enchanter = { true, 'Please hail me for buffs!' },
        Magician = { true, 'Please say toys, toys (1-20), rod, drod, invis, other, or arrows.' },
        Ranger = { true, 'Please hail me for buffs!' },
        Shaman = { true, 'Please hail me for buffs!' },
        Beastlord = { true, 'Please hail me for buffs!' },
        Cleric = { true, 'Please say "rez" for a ressurection.' },
        Druid = { true, 'Please say "ports" for a list of ports.' },
        Paladin = { true, 'Please hail me for buffs!' },
        Necromancer = { true, 'Please invite me to "summon" your corpse.' },
        Wizard = { true, 'Please say "ports" for a list of ports.' },
    }
    for class, value in pairs(supported_Classes) do
        if my_Class == class and value[1] == true then
            supported_Class = value[1]
            Settings.advertiseMessage = value[2]
            AdvertiseMessage = Settings.advertiseMessage
            CONSOLEMETHOD('Class %s is supported: %s', class, value[1])
        end
    end
    if my_Class == 'Druid' or my_Class == 'Wizard' then
        Settings.portMessage = Class.BuildPortText()
    end
end
CheckClassSupport()

local function event_rez_handler(line, sender)
    CONSOLEMETHOD('function event_rez_handler(line, sender)')
    if my_Class ~= 'Cleric' then return end
    Casting.RezTarget(sender, Class.rez_Spell[Class.cleric_settings.rez_current_idx])
end

local function event_buff_handler(line, sender)
    CONSOLEMETHOD('function event_buff_handler(line, sender)')
    Casting.BuffTarget(sender)
end

local function event_ports_handler(line, sender)
    CONSOLEMETHOD('function event_ports_handler(line, sender)')
    if my_Class ~= 'Wizard' and my_Class ~= 'Druid' then return end
    if Settings.portChat == '/tell' or Settings.portChat == '/t' then
        mq.cmd(Settings.portChat .. ' ' .. sender .. ' ' .. Settings.portMessage)
    else
        mq.cmd(Settings.portChat .. ' ' .. Settings.portMessage)
    end
end

local function event_port_handler(line, sender, destination)
    CONSOLEMETHOD('function event_port_handler(%s, %s, %s)', line, sender, destination)
    if my_Class ~= 'Wizard' and my_Class ~= 'Druid' then return end

    local portName
    for _, port in ipairs(Class.portsList) do
        local tempHolder = port
        local portSpell = string.lower(string.gsub(port, 'Zephyr: ', ''))
        local portRequested = string.lower(destination)
        if portSpell == portRequested then
            print(tempHolder)
            portName = tempHolder
            break
        end
    end

    local portSpellName = portName
    local portNameShort = string.gsub(portSpellName, 'Zephyr: ', '')
    local portRequested = string.lower(destination)
    if string.lower(portNameShort) == portRequested then
        print(mq.TLO.Me.Gem(portSpellName)())
        if mq.TLO.Me.Gem(portSpellName)() == nil then Casting.MemSpell(portSpellName, 4) end
        Casting.PortTarget(sender, portSpellName)
        return
    end
end

mq.event('Hail', "#1# says, 'Hail, " .. mq.TLO.Me.Name() .. "#*#'", event_buff_handler)
mq.event('Hail2', "#1# says, in #2#, 'Hail, " .. mq.TLO.Me.Name() .. "#*#'", event_buff_handler)

mq.event('Ports', "#1# says, 'ports'", event_ports_handler)
mq.event('Ports2', "#1# says, in #*#, 'ports'", event_ports_handler)

mq.event('Port', "#1# says, in #*#, '#2#'", event_port_handler)
mq.event('Port2', "#1# says, '#2#'", event_port_handler)

mq.event('Rez', "#1# says, 'rez'", event_rez_handler)
mq.event('Rez2', "#1# says, in #*#, 'rez'", event_rez_handler)

local function draw_window()
    local x_size = 610
    local y_size = 680
    local io = ImGui.GetIO()
    local center_x = io.DisplaySize.x / 2
    local center_y = io.DisplaySize.y / 2
    ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
    ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)

    --
    -- Buff Bot
    --
    local buttonWidth, buttonHeight = 150, 30
    local buttonImVec2 = ImVec2(buttonWidth, buttonHeight)
    if BotRunning then
        if ImGui.Button('Pause', buttonImVec2) then
            BotRunning = false
        end
    else
        if ImGui.Button('Resume', buttonImVec2) then
            BotRunning = true
        end
    end
    --
    -- Buff Bot
    --
    if imgui.CollapsingHeader("Buff Bot") then
        ImGui.Text("This is a simple macro I threw together to help out a few friends.\n" ..
            "You can run it on a Shaman, Magician, Enchanter, Ranger, Druid, Wizard,\n" ..
            "Beastlord, Cleric, or Paladin. You can even have a Necromancer summon corpses!\n\n")
        ImGui.Separator();

        ImGui.Text("FEATURES:");
        ImGui.BulletText("Buffs level appropriate buffs when Hailed");
        ImGui.BulletText("Setup to use languages for FV");
        ImGui.BulletText("Echos who it is helping to EQBC when debug is on");
        ImGui.BulletText("Account balances! Charge people for your buffs and stop buffing them if they can't afford it.");
        ImGui.BulletText("Will deduct a set amount each time it buffs a pet, merc, or the initiator.");
        ImGui.BulletText("Will deduct a set amount each time it summons on the mage.");
        ImGui.BulletText("Moved everything to LUA!");
        ImGui.BulletText("Advertise the commands available!");
        ImGui.Separator();

        ImGui.Text("COMMANDS:");
        ImGui.BulletText("All: Hail for level appropriate buffs.");
        ImGui.BulletText("Druid: ports");
        ImGui.BulletText("Wizard: ports");
        ImGui.BulletText("Magician: toys, toy 1-20, invis, arrows, rod, drod, other");
        ImGui.BulletText("Cleric: Rez");
        ImGui.BulletText("Necromancer: Summon");
        ImGui.Separator();

        if mq.TLO.Me.Class.Name() == "Magician" then
            ImGui.Text("MAGICIAN:");
            ImGui.BulletText("Mage: Summons Pet toys when it hears \"toys\"");
            ImGui.BulletText("Mage: Summons Between 1- 20 Pet toys when it hears \"toys 1-20\"");
            ImGui.BulletText("Mage: Summons Invis stone when it hears \"invis\"");
            ImGui.BulletText("Mage: Summons mod rod when it hears \"rod\"");
            ImGui.BulletText("Mage: Summons damage rod when it hears \"drod\"");
            ImGui.BulletText("Mage: Summons arrows/quiver when it hears \"arrows\"");
            ImGui.BulletText("Mage: Summons Invis stone, Lev Ring, Mod Rod, and Damage Rod,\n" ..
                "when it hears \"other\"");
            ImGui.Separator();
        end

        if mq.TLO.Me.Class.Name() == "Cleric" then
            ImGui.Text("CLERIC:");
            ImGui.BulletText("Cleric: Will resurrect a player when it hears \"rez\"");
            ImGui.Separator();
        end

        if mq.TLO.Me.Class.Name() == "Necromancer" then
            ImGui.Text("NECROMANCER:");
            ImGui.BulletText("Necromancer: Will summon a player when it hears \"summon\"");
            ImGui.Separator();
        end

        if mq.TLO.Me.Class.Name() == "Druid" then
            ImGui.Text("DRUID:");
            ImGui.BulletText("Druid: Ports to all available druid Zephyrs");
            ImGui.Separator();
        end

        if mq.TLO.Me.Class.Name() == "Wizard" then
            ImGui.Text("WIZARD:");
            ImGui.BulletText("Wizard: Ports to all available wizard Translocates.");
            ImGui.Separator();
        end

        ImGui.Text("CREDIT:");
        ImGui.BulletText("TheDroidUrLookingFor");
        ImGui.Separator();
    end

    if supported_Class then
        Class.ShowClassBuffBotGUI()
    else
        CONSOLEMETHOD('Class not detected or supported')
        ImGui.Text("Class not supported!");
    end

    if imgui.CollapsingHeader("Options") then
        Settings.debug = ImGui.Checkbox('Enable Debug Messages', Settings.debug)
        ImGui.SameLine()
        ImGui.HelpMarker('Shows more information in the MQ console when enabled.')
        if DEBUG ~= Settings.debug then
            DEBUG = Settings.debug
            SaveSettings(IniPath, Settings)
        end
        ImGui.Separator();

        Settings.medAtPct = ImGui.SliderInt("Meditation Start Percent", Settings.medAtPct, 1, 99)
        ImGui.SameLine()
        ImGui.HelpMarker('The percentage of mana to start meditating.')
        if MedAtPct ~= Settings.medAtPct then
            MedAtPct = Settings.medAtPct
            SaveSettings(IniPath, Settings)
        end

        Settings.medDonePct = ImGui.SliderInt("Meditation Done Percent", Settings.medDonePct, 1, 99)
        ImGui.SameLine()
        ImGui.HelpMarker('The percentage of mana to finish meditating.')
        if DoneMeddingPct ~= Settings.medDonePct then
            DoneMeddingPct = Settings.medDonePct
            SaveSettings(IniPath, Settings)
        end
        ImGui.Separator();

        if imgui.BeginTable('##table2', 3) then
            imgui.TableNextRow()
            imgui.TableSetColumnIndex(0)
            Settings.accountMode = ImGui.Checkbox('Enable Account Mode', Settings.accountMode)
            ImGui.SameLine()
            ImGui.HelpMarker(
                'Enables account mode. When account mode is enabled anyone interacting with the bot will be added to BuffBot.Accounts.ini and a balance added to their line. This balance can be refilled by giving platinum to the Buffer.')
            if AccountMode ~= Settings.accountMode then
                AccountMode = Settings.accountMode
                SaveSettings(IniPath, Settings)
            end

            imgui.TableSetColumnIndex(0)
            Settings.buffGuildOnly = ImGui.Checkbox('Enable Guild Only', Settings.buffGuildOnly)
            ImGui.SameLine()
            ImGui.HelpMarker('Enables buffing of only the guilds in BuffBot.Guilds.ini.')
            if BuffGuildOnly ~= Settings.buffGuildOnly then
                BuffGuildOnly = Settings.buffGuildOnly
                SaveSettings(IniPath, Settings)
            end

            imgui.TableSetColumnIndex(1)
            Settings.friendMode = ImGui.Checkbox('Enable Friend Mode', Settings.friendMode)
            ImGui.SameLine()
            ImGui.HelpMarker('Allows "friends" aka people in the BuffBot.Friends.ini to bypass Buffing Only Guild Flag.')
            if FriendMode ~= Settings.friendMode then
                FriendMode = Settings.friendMode
                SaveSettings(IniPath, Settings)
            end

            imgui.TableSetColumnIndex(1)
            Settings.friendFree = ImGui.Checkbox('Enable Friends Free', Settings.friendFree)
            ImGui.SameLine()
            ImGui.HelpMarker('Enables it so friends are not charged for buffs when using Account Mode.')
            if FriendFree ~= Settings.friendFree then
                FriendFree = Settings.friendFree
                SaveSettings(IniPath, Settings)
            end

            imgui.TableSetColumnIndex(2)
            Settings.guildMode = ImGui.Checkbox('Enable Guild Mode', Settings.guildMode)
            ImGui.SameLine()
            ImGui.HelpMarker('Allows an entire guild in the BuffBot.Guilds.ini to bypass Buffing Only Guild Flag.')
            if GuildMode ~= Settings.guildMode then
                GuildMode = Settings.guildMode
                SaveSettings(IniPath, Settings)
            end

            imgui.TableSetColumnIndex(2)
            Settings.guildFree = ImGui.Checkbox('Enable Guild Free', Settings.guildFree)
            ImGui.SameLine()
            ImGui.HelpMarker('Enables buffing for free the guilds in BuffBot.Guilds.ini.')
            if GuildFree ~= Settings.guildFree then
                GuildFree = Settings.guildFree
                SaveSettings(IniPath, Settings)
            end
            imgui.EndTable()
        end
        ImGui.Separator();

        Settings.mountItem = ImGui.InputText('Mount Item', Settings.mountItem)
        ImGui.SameLine()
        ImGui.HelpMarker('The mount item you would like your buffer to sit on to meditate.')
        if MountItem ~= Settings.mountItem then
            MountItem = Settings.mountItem
            SaveSettings(IniPath, Settings)
        end
        ImGui.SameLine()
        Settings.useMount = ImGui.Checkbox('Enable##Mount', Settings.useMount)
        ImGui.SameLine()
        ImGui.HelpMarker('Enables using your Mount Item to meditate for mana.')
        if UseMount ~= Settings.useMount then
            UseMount = Settings.useMount
            SaveSettings(IniPath, Settings)
        end
        ImGui.Separator();

        Settings.buffCost = ImGui.InputInt('Buff Cost##', Settings.buffCost, ImGuiInputTextFlags.AutoSelectAll)
        ImGui.SameLine()
        ImGui.HelpMarker(
            'The cost of buffs from the buffer per entity. If they have a pet that would be an additional charge and the same with a mercenary.')
        if BuffCost ~= Settings.buffCost then
            BuffCost = Settings.buffCost
            SaveSettings(IniPath, Settings)
        end

        Settings.summonCost = ImGui.InputInt('Summon Cost ##', Settings.summonCost, ImGuiInputTextFlags.AutoSelectAll)
        ImGui.SameLine()
        ImGui.HelpMarker('The cost for the Buffer to summon a corpse for the user.')
        if SummonCost ~= Settings.summonCost then
            SummonCost = Settings.SummonCost
            SaveSettings(IniPath, Settings)
        end

        Settings.rezCost = ImGui.InputInt('Rez Cost##', Settings.rezCost, ImGuiInputTextFlags.AutoSelectAll)
        ImGui.SameLine()
        ImGui.HelpMarker('The cost for the Buffer to ressurect a user.')
        if RezCost ~= Settings.rezCost then
            RezCost = Settings.rezCost
            SaveSettings(IniPath, Settings)
        end
        ImGui.Separator();

        Settings.afkMessage = ImGui.InputText('AFK Message', Settings.afkMessage)
        ImGui.SameLine()
        ImGui.HelpMarker('The message displayed when the Buffer is idle waiting to buffer users.')
        if AfkMessage ~= Settings.afkMessage then
            AfkMessage = Settings.afkMessage
            SaveSettings(IniPath, Settings)
        end

        Settings.medMessage = ImGui.InputText('Med Message', Settings.medMessage)
        ImGui.SameLine()
        ImGui.HelpMarker('The message displayed when the Buffer needs to take a break for mana.')
        if MedMessage ~= Settings.medMessage then
            MedMessage = Settings.medMessage
            SaveSettings(IniPath, Settings)
        end
        ImGui.Separator();

        if imgui.BeginTable('##table1', 2) then
            imgui.TableNextRow()
            imgui.TableSetColumnIndex(0)
            if imgui.Button('REBUILD##Save File') then
                SaveSettings(IniPath, Settings)
            end
            ImGui.SameLine()
            ImGui.Text('Save File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. IniPath)

            imgui.TableSetColumnIndex(0)
            if imgui.Button('REBUILD##Account File') then
                SaveSettings(Accounting.AccountsPath, Accounting.Accounts)
            end
            ImGui.SameLine()
            ImGui.Text('Account File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. Accounting.AccountsPath)

            imgui.TableSetColumnIndex(1)
            if imgui.Button('REBUILD##Friend File') then
                SaveSettings(Accounting.FriendsPath, Accounting.Friends)
            end
            ImGui.SameLine()
            ImGui.Text('Friend File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. Accounting.FriendsPath)

            imgui.TableSetColumnIndex(1)
            if imgui.Button('REBUILD##Guild File') then
                SaveSettings(Accounting.GuildsPath, Accounting.Guilds)
            end
            ImGui.SameLine()
            ImGui.Text('Guild File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. Accounting.GuildsPath)
            imgui.EndTable()
        end
        ImGui.Separator();
    end
end

local Open = true
local ShowUI = true
local function initWindow()
    Open, ShowUI = ImGui.Begin('TheDroid Buff Bot v' .. version, Open)
    if ShowUI then
        draw_window()
    end
    ImGui.End()
end
mq.imgui.init('CT', initWindow)

local function med()
    CONSOLEMETHOD('function med() Entry')
    mq.cmd('/afk ' .. Settings.medMsg)
    while mq.TLO.Me.PctMana() < Settings.medDonePct do
        mq.delay(1000)
    end
    mq.cmd('/afk ' .. Settings.afkMsg)
end

local function StartupMessage()
    CONSOLEMETHOD('function StartupMessage() Entry')
    print('[NBB]+ Initialized ++[NBB]')
    print('[NBB]++ NEWBIE BUFF BOT STARTED ++[NBB]')
end
StartupMessage()

Class.MemorizeSpells()

CONSOLEMETHOD('Main Loop Entry')
while MainLoop do
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then MainLoop = false end
    if BotRunning then
        if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
        if mq.TLO.Me.PctMana() < MedAtPct then med() end
        if mq.TLO.Window('TradeWnd').Open() then Accounting.ProcessTrade() end
        if mq.TLO.Me.Mount.ID() == 0 and Settings.useMount and mq.TLO.FindItem(Settings.mountItem).ID then
            Casting
                .CastItem(Settings.mountItem)
        end
        if not mq.TLO.Me.Casting() and mq.TLO.Me.Standing() and not mq.TLO.Me.Mount.ID() and (not Settings.useMount or (Settings.useMount and mq.TLO.FindItem(Settings.mountItem).ID ~= 0)) then
            mq.TLO.Me.Sit()
        end
        mq.doevents()
    end
    mq.delay(500)
    if not Open then return end
end
CONSOLEMETHOD('Main Loop Exit')
