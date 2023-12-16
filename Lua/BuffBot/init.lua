local version = '1.0.10'
---|------------------------------------------------------------|
---|                   BuffBot
---|
---|              Created by: TheDroidUrLookingFor
---|              Modified by: TheDroidUrLookingFor
---|
---|		     Version: 1.0.10
---|
---|------------------------------------------------------------|

---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local PackageMan = require('mq/PackageMan')
local Utils = require('mq/Utils')
local lfs_check = Utils.Library.Include("lfs")
if not lfs_check then
    if PackageMan.Install("luafilesystem") == 2 then
        print("User canceled the install, cannot proceed")
        mq.exit()
    end
end

local my_Class = mq.TLO.Me.Class() or ''
local my_Name = mq.TLO.Me.Name() or ''
ConfigDir = mq.configDir .. '\\BuffBot'
SettingsDir = mq.configDir .. '\\BuffBot\\Settings'
FileName = '\\BuffBot_' .. my_Name .. '.ini'
IniPath = SettingsDir .. FileName

Class = require('BuffBot.Classes.' .. my_Class .. '')
Storage = require('BuffBot.Core.Storage')
Casting = require('BuffBot.Core.Casting')
Accounting = require('BuffBot.Accounting.Accounting')
GUI = require('BuffBot.Core.Gui')

DEBUG = false
MedAtPct = 30
DoneMeddingPct = 75
UseAFKMessage = true
AfkMessage = 'Find me in Guild Lobby if you need me.'
UseMedMessage = true
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
PortMessage = 'Please say "ports" for a list of ports.'

local MainLoop = true
local BotRunning = true
local supported_Class = false

Settings = {
    version = version,
    debug = DEBUG,
    medAtPct = 35,
    medDonePct = 75,
    useAFKMessage = true,
    afkMessage = 'Find me in Guild Lobby if you need me.',
    useMedMessage = true,
    medMessage = '..Meditating... Low on mana.',
    useMount = false,
    mountItem = 'Jungle Raptor Saddle',
    advertise = false,
    advertiseChat = '/say',
    advertiseMessage = '',
    portChat = '/say',
    portMessage = 'Please say "ports" for a list of ports.',
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

local versionOrder = { "1.0.11", "1.0.10", "1.0.9", "1.0.8", "1.0.7", "1.0.6", "1.0.5", "1.0.4", "1.0.3", "1.0.2",
    "1.0.1", "1.0.0" }
local change_Log = {
    ['1.0.0'] = { 'Initial Release',
        '- Added Cleric Class support',
        '- Added Druid Class support',
        '- Added Ranger Class support',
        '- Added Shaman Class support',
        '- Added Wizard Class support',
        '- Each Character will get a \\Config\\BuffBot\\BuffBot.CharacterName.ini',
        '- Modules will create each character will get a \\Config\\BuffBot\\BuffBot.CharacterName.CLASS.ini' },
    ['1.0.1'] = { 'Directory Fix',
        '- Fixed issues with directories' },
    ['1.0.2'] = { 'Druid Fix',
        '- Fixed an issue with the druid module not loading Setup' },
    ['1.0.3'] = { 'General Update',
        '- Added Change log tab to General Tab',
        '- Added Enable/Disable option for AFK Messages',
        '- Added Enable/Disable option for Med Messages',
        '- Added cleric Symbol buffs for level 85+',
        '- Added default spell level suggestions for Cleric',
        '- Increased main loops delay to save some memory',
        '- Fixed more setup->Setup issues',
        '- Removed GUI stuff from class files and put it into its own file',
        '- Updated the pending class includes',
        '- Updated the Wizards GUI for selecting the most common ports used.',
        '- Updated Druid default spells',
        '- Added Enchanter Class Support',
        '- Added Beastlord Class Support',
        '- Updated Shamans Spells' },
    ['1.0.4'] = { 'General Update',
        '- Added Necromancer Class Support',
        '- Added Shadow Knight Class Support',
        '- Added Paladin Support',
        '- Cleaned up some typos', },
    ['1.0.5'] = { 'Bug Fix Update',
        '- Fixed crash when minimizing BuffBot window' },
    ['1.0.6'] = { 'General Update',
        '- Added Conviction and Hand of Conviction to the default cleric hp buff spell list',
        '- Added Unity and Talisman buffs to Shaman HP buff spell list',
        '- Added Proc line of buffs to Shaman' },
    ['1.0.7'] = { 'General Update',
        '- Added /bb gui command',
        '- Added /bb quit command',
        '- Added /bb balance command',
        '- Added /bb friend command',
        '- Added /bb guild command',
        '- Added /bb buff command',
        '- Added buffing via tells when told "buff me"',
        '- Added a memorize check into Casting.CastBuff',
        '- Added a memorize check into Casting.CastRez',
        '- Added a memorize check into Casting.CastSummon' },
    ['1.0.8'] = { 'General Update',
        '- Fixed issue where med could stop BuffBot from closing until med level was met.',
        '- Fixed issue with Wizard ports',
        '- Fixed issue with Druid ports',
        '- Added label with the current status of the bot.' },
    ['1.0.9'] = { 'General Update',
        '- Added Magician Class support.',
        '- Now looking at both tells and say for commands.' },
    ['1.0.10'] = { 'General Update',
        '- Fixed issues with Utils loading',
        '- Fixed loading issues when moving to a new version. Will now overwrite INI on version changes.',
        '- Added ModRod1-4 to Mage',
        '- Fixed issue with Shaman SoW Spells',
        '- Added a wait after memming spells in the buff routine.',
        '- Fixed issue with Bih`li and Tala`Tak for shaman' },
    ['1.0.11'] = { 'General Update',
        '- Added 121-125 spells for Magician',
        '- Added 121-125 spells for Enchanter',
        '- Added 121-125 spells for Ranger',
        '- Added 121-125 spells for Shaman',
        '- Added 121-125 spells for Cleric',
        '- Added 121-125 spells for Beastlord',
        '- Added 121-125 spells for Druid',
        '- Added 121-125 spells for Paladin',
        '- Added 121-125 spells for Wizard' }
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

function PRINTMETHOD(printMessage, ...)
    printf("[BuffBot] " .. printMessage, ...)
end

function SaveSettings(iniFile, settingsList)
    CONSOLEMETHOD('function SaveSettings(iniFile, settingsList) Entry')
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

function Setup()
    CONSOLEMETHOD('function Setup() Entry')
    CurrentStatus = 'Loading Settings'
    if not Storage.dir_exists(ConfigDir) then Storage.make_dir(mq.configDir, 'BuffBot') end
    if not Storage.dir_exists(SettingsDir) then Storage.make_dir(mq.configDir, 'BuffBot\\Settings') end

    local conf
    local configData, err = loadfile(IniPath)
    if err then
        SaveSettings(IniPath, Settings)
    elseif configData then
        conf = configData()
        if conf.version ~= version then
            SaveSettings(IniPath, Settings)
            Setup()
        else
            Settings = conf
        end
    end

    PRINTMETHOD('Class detected as %s', my_Class)
    CurrentStatus = 'Running Class Setup'
    Class.Setup()
end

Setup()

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
        ['Shadow Knight'] = { true, 'Please invite me to "summon" your corpse.' },
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

local function event_summon_handler(line, sender)
    CONSOLEMETHOD('function event_rez_handler(line, sender)')
    if my_Class == 'Necromancer' then
        CurrentStatus = 'Summoning'
        Casting.SummonTarget(sender,
            Class.necromancer_settings.summon_Spell[Class.necromancer_settings.summon_current_idx])
        CurrentStatus = 'Waiting'
    elseif my_Class ~= 'Shadowknight' then
        CurrentStatus = 'Summoning'
        Casting.SummonTarget(sender,
            Class.shadowknight_settings.summon_Spell[Class.shadowknight_settings.summon_current_idx])
        CurrentStatus = 'Waiting'
    else
        CurrentStatus = 'Waiting'
        return
    end
end

local function event_rez_handler(line, sender)
    CONSOLEMETHOD('function event_rez_handler(line, sender)')
    if my_Class ~= 'Cleric' then return end
    CurrentStatus = 'Rezzing'
    Casting.RezTarget(sender, Class.rez_Spell[Class.cleric_settings.rez_current_idx])
    CurrentStatus = 'Waiting'
end

local function event_buff_handler(line, sender)
    CONSOLEMETHOD('function event_buff_handler(line, sender)')
    CurrentStatus = 'Buffing'
    Casting.BuffTarget(sender)
    CurrentStatus = 'Waiting'
end

local function event_toys_handler(line, sender)
    CONSOLEMETHOD('function event_toys_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.SummonToys(sender, 1)
    CurrentStatus = 'Waiting'
end
local function event_toyscustom_handler(line, sender, amount)
    CONSOLEMETHOD('function event_toyscustom_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.SummonToys(sender, amount)
    CurrentStatus = 'Waiting'
end
local function event_arrows_handler(line, sender)
    CONSOLEMETHOD('function event_arrows_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.MageSummonItem(sender, Class.arrows[Class.magician_settings.arrows_current_idx], 1)
    CurrentStatus = 'Waiting'
end
local function event_invis_handler(line, sender)
    CONSOLEMETHOD('function event_invis_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.MageSummonItem(sender, Class.invis[Class.magician_settings.invis_current_idx], 2)
    CurrentStatus = 'Waiting'
end
local function event_modrod_handler(line, sender)
    CONSOLEMETHOD('function event_modrod_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.SummonModRod(sender)
    CurrentStatus = 'Waiting'
end
local function event_damagerod_handler(line, sender)
    CONSOLEMETHOD('function event_damagerod_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.MageSummonItem(sender, Class.paradox[Class.magician_settings.paradox_current_idx], 3)
    CurrentStatus = 'Waiting'
end
local function event_other_handler(line, sender)
    CONSOLEMETHOD('function event_other_handler(line, sender)')
    if my_Class ~= 'Magician' then return end
    CurrentStatus = 'Summoning'
    Casting.SummonOther(sender)
    CurrentStatus = 'Waiting'
end

local function event_ports_handler(line, sender)
    CONSOLEMETHOD('function event_ports_handler(line, sender)')
    if not string.find(line, 'ports') then return end
    if my_Class ~= 'Wizard' and my_Class ~= 'Druid' then return end
    CurrentStatus = 'Advertising'
    if Settings.portChat == '/tell' or Settings.portChat == '/t' then
        mq.cmd(Settings.portChat .. ' ' .. sender .. ' ' .. Settings.portMessage)
    else
        mq.cmd(Settings.portChat .. ' ' .. Settings.portMessage)
    end
    CurrentStatus = 'Waiting'
end

local function event_port_handler(line, sender, destination)
    CONSOLEMETHOD('function event_port_handler(%s, %s, %s)', line, sender, destination)
    if my_Class ~= 'Wizard' and my_Class ~= 'Druid' then return end
    local foundPort = false
    for _, port in pairs(Class.CheckPorts()) do
        if string.find(string.lower(line), string.lower(port)) then foundPort = true end
    end
    if not foundPort then
        CONSOLEMETHOD('Couldn\'t find port: %s', destination)
        return
    end

    CurrentStatus = 'Porting'
    local replaceName
    if my_Class == 'Wizard' then
        replaceName = 'Translocate '
    elseif my_Class == 'Druid' then
        replaceName = 'Zephyr: '
    end

    local portName
    for _, port in ipairs(Class.portsList) do
        local tempHolder = port
        local portSpell = string.lower(string.gsub(port, replaceName, ''))
        local portRequested = string.lower(destination)
        if portSpell == portRequested then
            portName = tempHolder
            break
        end
    end

    local portSpellName = portName
    local portNameShort = string.gsub(portSpellName, replaceName, '')
    local portRequested = string.lower(destination)
    if string.lower(portNameShort) == portRequested then
        if mq.TLO.Me.Gem(portSpellName)() == nil then Casting.MemSpell(portSpellName, 4) end
        Casting.PortTarget(sender, portSpellName)
        return
    end

    CurrentStatus = 'Waiting'
end

-- Everyone
mq.event('Hail', "#1# says, 'Hail, " .. mq.TLO.Me.Name() .. "#*#'", event_buff_handler)
mq.event('Hail2', "#1# says, in #*#, 'Hail, " .. mq.TLO.Me.Name() .. "#*#'", event_buff_handler)
mq.event('Hail3', "#1# says, 'buff me#*#'", event_buff_handler)
mq.event('Hail4', "#1# says, in #*#, 'buff me#*#'", event_buff_handler)
mq.event('Hail5', "#1# tells you, 'buff me#*#'", event_buff_handler)
mq.event('Hail6', "#1# tells you, in #*#, 'buff me#*#'", event_buff_handler)

-- Wizard/Druid
mq.event('Ports', "#1# says, 'ports'", event_ports_handler)
mq.event('Ports2', "#1# says, in #*#, 'ports'", event_ports_handler)
mq.event('Ports3', "#1# tells you, 'ports'", event_ports_handler)
mq.event('Ports4', "#1# tells you, in #*#, 'ports'", event_ports_handler)

mq.event('Port', "#1# says, in #*#, '#2#'", event_port_handler)
mq.event('Port2', "#1# says, '#2#'", event_port_handler)
mq.event('Port3', "#1# tells you, in #*#, '#2#'", event_port_handler)
mq.event('Port4', "#1# tells you, '#2#'", event_port_handler)

-- Cleric/Paladin
mq.event('Rez', "#1# says, 'rez'", event_rez_handler)
mq.event('Rez2', "#1# says, in #*#, 'rez'", event_rez_handler)
mq.event('Rez3', "#1# tells you, 'rez'", event_rez_handler)
mq.event('Rez4', "#1# tells you, in #*#, 'rez'", event_rez_handler)

-- Necromancer/Shadowknight
mq.event('Summon', "#1# says, in #*#, 'summon'", event_summon_handler)
mq.event('Summon2', "#1# says, in #*#, 'summon'", event_summon_handler)
mq.event('Summon3', "#1# tells you, in #*#, 'summon'", event_summon_handler)
mq.event('Summon4', "#1# tells you, in #*#, 'summon'", event_summon_handler)

-- Magician
mq.event('Toys', "#1# says, in #*#, 'toys'", event_toys_handler)
mq.event('Toys2', "#1# says, 'toys'", event_toys_handler)
mq.event('Toys3', "#1# tells you, in #*#, 'toys'", event_toys_handler)
mq.event('Toys4', "#1# tells you, 'toys'", event_toys_handler)

mq.event('ToysCustom', "#1# says, in #*#, 'toys #2#'", event_toyscustom_handler)
mq.event('ToysCustom2', "#1# says, 'toys #2#'", event_toyscustom_handler)
mq.event('ToysCustom3', "#1# tells you, in #*#, 'toys #2#'", event_toyscustom_handler)
mq.event('ToysCustom4', "#1# tells you, 'toys #2#'", event_toyscustom_handler)

mq.event('Other', "#1# says, in #*#, 'other'", event_other_handler)
mq.event('Other2', "#1# says, 'other'", event_other_handler)
mq.event('Other3', "#1# tells you, in #*#, 'other'", event_other_handler)
mq.event('Other4', "#1# tells you, 'other'", event_other_handler)

mq.event('Invis', "#1# says, in #*#, 'invis'", event_invis_handler)
mq.event('Invis2', "#1# says, 'invis'", event_invis_handler)
mq.event('Invis3', "#1# tells you, in #*#, 'invis'", event_invis_handler)
mq.event('Invis4', "#1# tells you, 'invis'", event_invis_handler)

mq.event('ModRod', "#1# says, in #*#, 'rod'", event_modrod_handler)
mq.event('ModRod2', "#1# says, 'rod'", event_modrod_handler)
mq.event('ModRod3', "#1# tells you, in #*#, 'rod'", event_modrod_handler)
mq.event('ModRod4', "#1# tells you, 'rod'", event_modrod_handler)

mq.event('DmgRod', "#1# says, in #*#, 'drod'", event_damagerod_handler)
mq.event('DmgRod2', "#1# says, 'drod'", event_damagerod_handler)
mq.event('DmgRod3', "#1# tells you, in #*#, 'drod'", event_damagerod_handler)
mq.event('DmgRod4', "#1# tells you, 'drod'", event_damagerod_handler)

mq.event('Arrows', "#1# says, in #*#, 'arrows'", event_arrows_handler)
mq.event('Arrows2', "#1# says, 'arrows'", event_arrows_handler)
mq.event('Arrows3', "#1# tells you, in #*#, 'arrows'", event_arrows_handler)
mq.event('Arrows4', "#1# tells you, 'arrows'", event_arrows_handler)

function ChangeLog()
    imgui.Text("Change Log:")
    local logText = ""
    -- Iterate over the versionOrder table
    for _, version in ipairs(versionOrder) do
        local changes = change_Log[version]
        if changes then
            logText = logText .. "[" .. version .. "]\n"

            -- Get the update title from the first element
            local updateTitle = changes[1]
            logText = logText .. updateTitle .. "\n"

            -- Concatenate the updates for each version
            for i = 2, #changes do
                local change = changes[i]
                logText = logText .. change .. "\n"
            end

            logText = logText .. "\n"
        end
    end

    -- Create an ImGui textbox and display the parsed change log
    imgui.InputTextMultiline("##changeLog", logText, ImGui.GetWindowSize(), 300, ImGuiInputTextFlags.ReadOnly)
end

CurrentStatus = ' '
local Open = false
local ShowUI = false
local function BuffBotGUI()
    if Open then
        Open, ShowUI = ImGui.Begin('TheDroid Buff Bot v' .. version, Open)
        ImGui.SetWindowSize(620, 680, ImGuiCond.Once)
        local x_size = 620
        local y_size = 680
        local io = ImGui.GetIO()
        local center_x = io.DisplaySize.x / 2
        local center_y = io.DisplaySize.y / 2
        ImGui.SetWindowSize(x_size, y_size, ImGuiCond.FirstUseEver)
        ImGui.SetWindowPos(center_x - x_size / 2, center_y - y_size / 2, ImGuiCond.FirstUseEver)
        if ShowUI then
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
            ImGui.SameLine(250)
            ImGui.Spacing()
            ImGui.SameLine()
            ImGui.Text(CurrentStatus);
            ImGui.SameLine(450)
            ImGui.Spacing()
            ImGui.SameLine()
            if ImGui.Button('Quit BuffBot', buttonImVec2) then
                MainLoop = false
            end
            ImGui.Spacing()
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
                ImGui.BulletText(
                    "Account balances! Charge people for your buffs and stop buffing them if they can't afford it.");
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
                if imgui.CollapsingHeader("Change Log") then
                    ChangeLog()
                end
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
                    ImGui.HelpMarker(
                        'Allows "friends" aka people in the BuffBot.Friends.ini to bypass Buffing Only Guild Flag.')
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
                    ImGui.HelpMarker(
                        'Allows an entire guild in the BuffBot.Guilds.ini to bypass Buffing Only Guild Flag.')
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

                Settings.summonCost = ImGui.InputInt('Summon Cost ##', Settings.summonCost, ImGuiInputTextFlags
                    .AutoSelectAll)
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
                ImGui.SameLine()
                Settings.useAFKMessage = ImGui.Checkbox('Enable##AfkMessage', Settings.useAFKMessage)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables using your the AFK Message.')
                if UseAFKMessage ~= Settings.useAFKMessage then
                    UseAFKMessage = Settings.useAFKMessage
                    SaveSettings(IniPath, Settings)
                end

                Settings.medMessage = ImGui.InputText('Med Message', Settings.medMessage)
                ImGui.SameLine()
                ImGui.HelpMarker('The message displayed when the Buffer needs to take a break for mana.')
                if MedMessage ~= Settings.medMessage then
                    MedMessage = Settings.medMessage
                    SaveSettings(IniPath, Settings)
                end
                ImGui.SameLine()
                Settings.useMedMessage = ImGui.Checkbox('Enable##useMedMessage', Settings.useMedMessage)
                ImGui.SameLine()
                ImGui.HelpMarker('Enables using your the med Message.')
                if UseMedMessage ~= Settings.useMedMessage then
                    UseMedMessage = Settings.useMedMessage
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
        ImGui.End()
    end
end
mq.imgui.init('BuffBot', BuffBotGUI)
Open = true

local function addComma(number)
    local formatted = tostring(number)
    local integerPart, decimalPart = formatted:match("([^%.]+)%.(.*)")
    local k = integerPart:len()
    for i = k - 3, 1, -3 do
        integerPart = integerPart:sub(1, i) .. ',' .. integerPart:sub(i + 1)
    end
    return integerPart .. '.' .. decimalPart
end

local function bb_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'friend' then
            if args[2] == 'add' then
                Storage.SetINI(Accounting.FriendsPath, 'Friends', args[3], true)
            elseif args[2] == 'del' then
                Storage.SetINI(Accounting.FriendsPath, 'Friends', args[3], false)
            elseif args[2] == 'get' then
                if Accounting.GetFriend(args[3])() == 'TRUE' then
                    PRINTMETHOD('%s is a friend: %s', args[3], Accounting.GetFriend(args[3]))
                else
                    PRINTMETHOD('%s is not a friend: %s', args[3], Accounting.GetFriend(args[3]))
                end
            end
            return
        elseif args[1] == 'guild' then
            if args[2] == 'add' then
                Storage.SetINI(Accounting.GuildsPath, 'Guilds', args[3], true)
            elseif args[2] == 'del' then
                Storage.SetINI(Accounting.GuildsPath, 'Guilds', args[3], false)
            elseif args[2] == 'get' then
                if Accounting.GetGuild(args[3])() == 'TRUE' then
                    PRINTMETHOD('%s is a friend: %s', args[3], Accounting.GetGuild(args[3]))
                else
                    PRINTMETHOD('%s is not a friend: %s', args[3], Accounting.GetGuild(args[3]))
                end
            end
            return
        elseif args[1] == 'gui' then
            if Open then
                PRINTMETHOD('Hiding Buff Bot GUI')
                Open = false
            else
                PRINTMETHOD('Restoring Buff Bot GUI')
                Open = true
            end
            return
        elseif args[1] == 'balance' then
            if args[2] == 'add' then
                Accounting.AddBalance(args[3], args[4])
                local accountBalance = Accounting.GetBalance(args[3])
                accountBalance = string.format("%0.2f", accountBalance)
                accountBalance = addComma(accountBalance)
                PRINTMETHOD('%s\'s Balance: $%s', args[3], accountBalance)
            elseif args[2] == 'del' then
                Accounting.RemoveBalance(args[3], args[4])
                local accountBalance = Accounting.GetBalance(args[3])
                accountBalance = string.format("%0.2f", accountBalance)
                accountBalance = addComma(accountBalance)
                PRINTMETHOD('%s\'s Balance: $%s', args[3], accountBalance)
            elseif args[2] == 'get' then
                local accountBalance = Accounting.GetBalance(args[3])
                accountBalance = string.format("%0.2f", accountBalance)
                accountBalance = addComma(accountBalance)
                PRINTMETHOD('%s\'s Balance: $%s', args[3], accountBalance)
            end
            return
        elseif args[1] == 'buff' then
            event_buff_handler('', args[2])
            return
        elseif args[1] == 'quit' then
            MainLoop = false
            return
        else
            PRINTMETHOD('Valid Commands:')
            PRINTMETHOD('/bb gui - Toggles the BuffBot GUI')
            PRINTMETHOD('/bb quit - Quits the BuffBot lua script.')
            PRINTMETHOD('/bb buff friendName - Forces a Buff cycle on friendName')
            PRINTMETHOD('/bb balance add|del|get friendName - Adds/Removes or checks friends balance')
            PRINTMETHOD('/bb friend add|del|get friendName - Adds/Removes or checks friend status')
            PRINTMETHOD('/bb guild add|del|get guildName - Adds/Removes or checks friend status for an entire guild')
        end
    else
        PRINTMETHOD('Valid Commands:')
        PRINTMETHOD('/bb gui - Toggles the BuffBot GUI')
        PRINTMETHOD('/bb quit - Quits the BuffBot lua script.')
        PRINTMETHOD('/bb buff friendName - Forces a Buff cycle on friendName')
        PRINTMETHOD('/bb balance add|del|get friendName - Adds/Removes or checks friends balance')
        PRINTMETHOD('/bb friend add|del|get friendName - Adds/Removes or checks friend status')
        PRINTMETHOD('/bb guild add|del|get guildName - Adds/Removes or checks friend status for an entire guild')
    end
end
mq.bind('/bb', bb_command)

local function med()
    CONSOLEMETHOD('function med() Entry')
    if Settings.useMedMessage then mq.cmd('/afk ' .. Settings.medMessage) end
    CurrentStatus = 'Medding'
    while mq.TLO.Me.PctMana() < Settings.medDonePct and BotRunning and MainLoop do
        mq.delay(1000)
    end
    CurrentStatus = 'Running'
    if Settings.useAFKMessage then mq.cmd('/afk ' .. Settings.afkMessage) end
end

PRINTMETHOD('+ Initialized ++')
PRINTMETHOD('++ BUFF BOT STARTED ++')
Class.MemorizeSpells()
if Settings.useAFKMessage then mq.cmd('/afk ' .. Settings.afkMessage) end

CONSOLEMETHOD('Main Loop Entry')
while MainLoop do
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then MainLoop = false end
    if BotRunning then
        if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
        if mq.TLO.Me.PctMana() < MedAtPct then med() end
        if mq.TLO.Window('TradeWnd').Open() then
            CurrentStatus = 'Trading'
            Accounting.ProcessTrade()
        end
        if mq.TLO.Me.Mount.ID() == 0 and Settings.useMount and mq.TLO.FindItem(Settings.mountItem).ID then
            Casting
                .CastItem(Settings.mountItem)
        end
        if not mq.TLO.Me.Casting() and mq.TLO.Me.Standing() and not mq.TLO.Me.Mount.ID() and (not Settings.useMount or (Settings.useMount and mq.TLO.FindItem(Settings.mountItem).ID ~= 0)) then
            mq.TLO.Me.Sit()
        end
        mq.doevents()
    end
    mq.delay(250)
    if not ShowUI then return end
end
CONSOLEMETHOD('Main Loop Exit')

if not MainLoop then
    mq.unbind('/bb')
end
