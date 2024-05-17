--|------------------------------------------------------------|
--|          EZ
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')

-- local Casting = require('EZ.lib.Casting')
-- local Events = require('EZ.Lib.Events')
-- local Gui = require('EZ.lib.Gui')
local Messages = require('EZ.lib.Messages')
-- local Navigation = require('EZ.lib.Movement')
-- local SpellRoutines = require('EZ.lib.spell_routines')
-- local Storage = require('EZ.lib.Storage')
-- local lootutils = require('EZ.lib.LootUtils')
local GTM = require('EZ.lib.GivetoMain')
local Progression = require('EZ.lib.EzProgression')

local EZ = {
    Debug = false,
    Terminate = false,
    Loop_Wait = 1000,
    TurboLoot_Delay = 7500,
    TurboLoot_Macro = '/ma EZ/TurboLoot/' .. mq.TLO.Zone.ShortName(),
    TurboLoot_ReverseOrder = true,
    Command_ShortName = 'ez',
    directMessage = '/dex',
    Raid_Mode = true,
}
local Raid_Members = 19
-- local Raid_Groups = {
--     {
--         name = "Group1",
--         members = {
--             "Winli", "Jinli", "Dinli", "Einli", "Minli", "Binli"
--         }
--     },
--     {
--         name = "Group2",
--         members = {
--             "Tinli", "Oinli", "Hinli", "Qinli", "Finli", "Kinli"
--         }
--     },
--     {
--         name = "Group3",
--         members = {
--             "Ginli", "Uinli", "Ninli", "Yinli", "Zinli", "Xinli"
--         }
--     }
-- }

local Raid_Groups = {
    {
        name = "Group1",
        members = {
            "Winli", "Gronwick", "Sorta", "Binli", "Tinli", "Zinli"
        }
    },
    {
        name = "Group2",
        members = {
            "Pinli", "Cinli", "Einli", "Rinli", "Jinli", "Finli"
        }
    },
    {
        name = "Group3",
        members = {
            "Hinli", "Kinli", "Ginli", "Ninli", "Linli", "Vinli"
        }
    },
    {
        name = "Group4",
        members = {
            "Xinli"
        }
    },
}

local function GroupCreateInstance(instanceType, ...)
    local args = { ... }
    if EZ.Raid_Mode then
        for i = 1, mq.TLO.Raid.Members() - 1 do
            if args[1] == nil then
                mq.cmdf('%s %s /say create %s instance confirm', EZ.directMessage, mq.TLO.Raid.Member(i).Name(),
                    instanceType)
            else
                mq.cmdf('%s %s /say create %s instance %s confirm', EZ.directMessage, mq.TLO.Raid.Member(i).Name(),
                    instanceType, args[1])
            end
        end
    else
        for i = 1, mq.TLO.Me.GroupSize() - 1 do
            if args[1] == nil then
                mq.cmdf('%s %s /say create %s instance confirm', EZ.directMessage, mq.TLO.Group.Member(i).Name(),
                    instanceType)
            else
                mq.cmdf('%s %s /say create %s instance %s confirm', EZ.directMessage, mq.TLO.Group.Member(i).Name(),
                    instanceType, args[1])
            end
        end
    end
    if args[1] == nil then
        mq.cmdf('/say create %s instance confirm', instanceType)
    else
        mq.cmdf('/say create %s instance %s confirm', instanceType, args[1])
    end
end

local function GroupEnterInstance(instanceType, instanceName)
    if EZ.Raid_Mode then
        for i = 1, mq.TLO.Raid.Members() - 1 do
            mq.cmdf('%s %s /say enter %s %s %s', EZ.directMessage, mq.TLO.Raid.Member(i).Name(), instanceType,
                mq.TLO.Raid.Member(i).Name(), instanceName)
        end
    else
        for i = 1, mq.TLO.Me.GroupSize() - 1 do
            mq.cmdf('%s %s /say enter %s %s %s', EZ.directMessage, mq.TLO.Group.Member(i).Name(), instanceType,
                mq.TLO.Group.Member(i).Name(), instanceName)
        end
    end
    mq.cmdf('/say enter %s %s %s', instanceType, mq.TLO.Me.Name(), instanceName)
end

local function GroupInviteInstance(instanceType, instanceName, inviteString)
    if EZ.Raid_Mode then
        for i = 1, mq.TLO.Raid.Members() - 1 do
            mq.cmdf('%s %s /say %s invite %s %s', EZ.directMessage, mq.TLO.Raid.Member(i).Name(), instanceType,
                instanceName,
                inviteString)
        end
    else
        for i = 1, mq.TLO.Me.GroupSize() - 1 do
            mq.cmdf('%s %s /say %s invite %s %s', EZ.directMessage, mq.TLO.Group.Member(i).Name(), instanceType,
                instanceName,
                inviteString)
        end
    end
    mq.cmdf('/say %s invite %s %s', instanceType, instanceName, inviteString)
end

local function LockRaid()
    mq.TLO.Window('RaidWindow').Child('RAID_LockButton').LeftMouseUp()
    mq.delay(750, function() return mq.TLO.Raid.Locked() == true end)
    if mq.TLO.Raid.Locked() then LockRaid() end
end
local function UnLockRaid()
    mq.TLO.Window('RaidWindow').Child('RAID_UnLockButton').LeftMouseUp()
    mq.delay(750, function() return mq.TLO.Raid.Locked() == false end)
    if mq.TLO.Raid.Locked() then UnLockRaid() end
end
local function InvitePlayers()
    for _, group in ipairs(Raid_Groups) do
        for _, name in ipairs(group.members) do
            if name ~= '' then
                mq.cmdf('/raidinvite %s', name)
                mq.delay(100)
            end
        end
        print() -- Empty line to separate groups in the output
    end
    mq.cmd('/dga /yes')
    mq.delay(500)
end

local function MovePlayer(index, player, groupnum)
    mq.cmdf('/notify RaidWindow RAID_NotInGroupPlayerList ListSelect %s', index)
    mq.delay(50)
    mq.TLO.Window('RaidWindow').Child('RAID_Group' .. groupnum .. 'Button').LeftMouseUp()
    mq.delay(50)
    if mq.TLO.Window('RaidWindow').Child('RAID_NotInGroupPlayerList').List(index, 2) == player then
        MovePlayer(index,
            player, groupnum)
    end
end

local function MoveToGroup(player, groupnum)
    local toRemove = 'Group'
    local escapedGroup = toRemove:gsub('[%^$%(%)%%%.%[%]%*%+%-%?]', '%%%1')
    local group = groupnum:gsub(escapedGroup, '')
    for i = 1, mq.TLO.Window('RaidWindow').Child('RAID_NotInGroupPlayerList').Items() do
        if mq.TLO.Window('RaidWindow').Child('RAID_NotInGroupPlayerList').List(i, 2)() == player then
            --printf('%s: %s', group, player)
            MovePlayer(i, player, group)
            return true
        end
    end
end

local function GroupPlayers()
    for _, group in ipairs(Raid_Groups) do
        for _, name in ipairs(group.members) do
            printf('%s: %s', group.name, name)
            MoveToGroup(name, group.name)
            mq.delay(100)
        end
    end
    mq.delay(250)
end


local function SetupRaid()
    if not mq.TLO.Window('RaidWindow').Open() then
        print('Raid Window Not Open!')
        mq.TLO.Window('RaidWindow').DoOpen()
        mq.delay(4000, function() return mq.TLO.Window('RaidWindow').Open() == true end)
    end
    UnLockRaid()
    mq.delay(50)
    InvitePlayers()
    mq.delay(2500, function() return mq.TLO.Raid.Members() == Raid_Members end)
    LockRaid()
    mq.delay(50)
    GroupPlayers()
end

local function RaidTurboLoot()
    mq.cmdf('/dgre /nav id %s', mq.TLO.Me.ID())
    mq.delay(5000)
    if EZ.TurboLoot_ReverseOrder then
        local reversed_groups = {}                  -- Table to store groups in reverse order
        for group, members in pairs(Raid_Groups) do
            table.insert(reversed_groups, 1, group) -- Insert the name at the beginning of the table
        end
        -- Loop through each group
        for group, members in pairs(reversed_groups) do
            -- Loop through each member in the current group
            local reversed_members = {}                 -- Table to store members in reverse order
            for position, name in pairs(members) do
                table.insert(reversed_members, 1, name) -- Insert the name at the beginning of the table
            end
            for position, name in pairs(reversed_members) do
                if name ~= '' then -- Check if the name is not an empty string
                    mq.cmdf('%s %s %s', EZ.directMessage, name, EZ.TurboLoot_Macro)
                    mq.delay(EZ.TurboLoot_Delay)
                end
            end
        end
    else
        -- Loop through each group
        for group, members in pairs(Raid_Groups) do
            -- Loop through each member in the current group
            for position, name in pairs(members) do
                if name ~= '' then -- Check if the name is not an empty string
                    mq.cmdf('%s %s %s', EZ.directMessage, name, EZ.TurboLoot_Macro)
                    mq.delay(EZ.TurboLoot_Delay)
                end
            end
        end
    end
    mq.delay(250)
end

local function ez_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            if Open then
                Messages.CONSOLEMETHOD(false, 'Hiding EZ Bot GUI')
                Open = false
            else
                Messages.CONSOLEMETHOD(false, 'Restoring EZ Bot GUI')
                Open = true
            end
            return
        elseif args[1] == 'progress' then
            if args[2] ~= nil and args[3] ~= nil then
                Progression.Main(args[2], args[3])
            elseif args[2] ~= nil and args[3] == nil then
                Progression.Main(args[2])
            end
        elseif args[1] == 'instance' then
            if args[2] == 'solo' then
                if args[3] ~= nil then
                    Messages.CONSOLEMETHOD(false, 'Entering solo instance %s.', args[3])
                    GroupEnterInstance('solo', args[3])
                else
                    Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                    Messages.CONSOLEMETHOD(false,
                        '/%s \atinstance\aw \apsolo\aw \agName\aw - Tells group members to enter a solo instance',
                        EZ.Command_ShortName)
                end
                return
            elseif args[2] == 'raid' then
                if args[3] ~= nil then
                    Messages.CONSOLEMETHOD(false, 'Entering raid instance %s.', args[3])
                    GroupEnterInstance('raid', args[3])
                else
                    Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                    Messages.CONSOLEMETHOD(false,
                        '/%s \atinstance\aw \apraid\aw \agName\aw - Tells group members to enter a raid instance',
                        EZ.Command_ShortName)
                end
                return
            elseif args[2] == 'guild' then
                if args[3] ~= nil then
                    Messages.CONSOLEMETHOD(false, 'Entering guild instance %s.', args[3])
                    GroupEnterInstance('guild', args[3])
                else
                    Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                    Messages.CONSOLEMETHOD(false,
                        '/%s \atinstance\aw \apguild\aw \agName\aw - Tells group members to enter a guild instance',
                        EZ.Command_ShortName)
                end
                return
            elseif args[2] == 'invite' then
                if args[3] ~= nil and args[4] ~= nil and args[5] ~= nil then
                    Messages.CONSOLEMETHOD(false, 'Inviting to %s instance %s.', args[3], args[4])
                    GroupInviteInstance(args[3], args[4], args[5])
                else
                    Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                    Messages.CONSOLEMETHOD(false,
                        '/%s \atinstance\aw \apinvite\aw \agType\aw \ayName\aw \arInvitee\aw - Tells group members to invite to an instance',
                        EZ.Command_ShortName)
                end
                return
            elseif args[2] == 'inviteall' then
                if args[3] ~= nil and args[4] ~= nil then
                    local inviteString = ''
                    for i = 1, mq.TLO.Raid.Members() do
                        if i ~= mq.TLO.Raid.Members() then
                            inviteString = inviteString .. mq.TLO.Raid.Member(i).Name() .. ', '
                        else
                            inviteString = inviteString .. mq.TLO.Raid.Member(i).Name()
                        end
                    end
                    Messages.CONSOLEMETHOD(false, 'Inviting to %s instance %s.', args[3], args[4])
                    GroupInviteInstance(args[3], args[4], inviteString)
                else
                    Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                    Messages.CONSOLEMETHOD(false,
                        '/%s \atinstance\aw \apinvite\aw \agType\aw \ayName\aw \arInvitee\aw - Tells group members to invite to an instance',
                        EZ.Command_ShortName)
                end
                return
            elseif args[2] == 'create' then
                if args[3] ~= nil and args[4] == nil then
                    GroupCreateInstance(args[3])
                    Messages.CONSOLEMETHOD(false, 'Creating %s instance.', args[3])
                elseif args[3] ~= nil and args[4] ~= nil then
                    GroupCreateInstance(args[3], args[4])
                    Messages.CONSOLEMETHOD(false, 'Creating %s instance in %s.', args[3], args[4])
                    mq.delay(1000)
                    GroupInviteInstance(args[3], args[4], mq.TLO.Me.Name())
                else
                    Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                    Messages.CONSOLEMETHOD(false,
                        '/%s \atinstance\aw \apcreate\aw \agType\aw \ayName\aw - Tells group members to create an instance',
                        EZ.Command_ShortName)
                end
                return
            else
                Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                Messages.CONSOLEMETHOD(false,
                    '/%s \atinstance\aw \apcreate\aw \agType\aw \ayName\aw - Tells group members to create an instance',
                    EZ.Command_ShortName)
                Messages.CONSOLEMETHOD(false,
                    '/%s \atinstance\aw \apinvite\aw \agType\aw \ayName\aw \arInvitee\aw - Tells group members to invite to an instance',
                    EZ.Command_ShortName)
                Messages.CONSOLEMETHOD(false,
                    '/%s \atinstance\aw \apsolo\aw \agName\aw - Tells group members to enter a solo instance',
                    EZ.Command_ShortName)
                Messages.CONSOLEMETHOD(false,
                    '/%s \atinstance\aw \apraid\aw \agName\aw - Tells group members to enter a raid instance',
                    EZ.Command_ShortName)
                Messages.CONSOLEMETHOD(false,
                    '/%s \atinstance\aw \apguild\aw \agName\aw - Tells group members to enter a guild instance',
                    EZ.Command_ShortName)
            end
        elseif args[1] == 'raid' then
            if args[2] == 'form' then
                Messages.CONSOLEMETHOD(false, 'Forming raid groups.')
                SetupRaid()
            elseif args[2] == 'loot' then
                Messages.CONSOLEMETHOD(false, 'Raid looting corpses.')
                RaidTurboLoot()
            elseif args[2] == 'give' then
                Messages.CONSOLEMETHOD(false, 'Giving tradable items to %s', mq.TLO.Me.Name())
                GTM.GiveEZItems(mq.TLO.Me.Name())
            elseif args[2] == 'start' then
                Messages.CONSOLEMETHOD(false, 'Raid starting RGMercs.')
                mq.cmdf('/dgre /target %s pc', mq.TLO.Me.Name())
                mq.delay(750)
                mq.cmd('/dgre /rgstart')
                mq.delay(750)
                mq.cmd('/dgre /rg AssistOutside 1')
                mq.delay(750)
                mq.cmdf('/dgre /rg OutsideAssistList %s', mq.TLO.Me.Name())
                mq.delay(750)
                mq.cmd('/dgre /rgstart')
            else
                Messages.CONSOLEMETHOD(false, 'Valid Commands:')
                Messages.CONSOLEMETHOD(false, '/%s \atraid\aw \apform\aw - Forms a raid from the Raid_Groups array',
                    EZ.Command_ShortName)
                Messages.CONSOLEMETHOD(false,
                    '/%s \atraid\aw \aploot\aw - Tells the raid to run TurboLoot macro for the current Zone ShortName with delay per launch',
                    EZ.Command_ShortName)
            end
            return
        elseif args[1] == 'quit' then
            EZ.Terminate = true
            return
        else
            Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            Messages.CONSOLEMETHOD(false, '/%s \atgui\aw - Toggles the EZ GUI', EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false,
                '/%s \atinstance\aw \apcreate\aw \agType\aw \ayName\aw - Tells group members to create an instance',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false,
                '/%s \atinstance\aw \apinvite\aw \agType\aw \ayName\aw \arInvitee\aw - Tells group members to invite to an instance',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false,
                '/%s \atinstance\aw \apsolo\aw \agName\aw - Tells group members to enter a solo instance',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false,
                '/%s \atinstance\aw \apraid\aw \agName\aw - Tells group members to enter a raid instance',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false,
                '/%s \atinstance\aw \apguild\aw \agName\aw - Tells group members to enter a guild instance',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \atraid\aw \apform\aw - Forms a raid from the Raid_Groups array',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false,
                '/%s \atraid\aw \aploot\aw - Tells the raid to run TurboLoot macro for the current Zone ShortName with delay per launch',
                EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \atquit\aw - Quits the EZ lua script.', EZ.Command_ShortName)
        end
    else
        Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        Messages.CONSOLEMETHOD(false, '/%s \atgui\aw - Toggles the EZ GUI', EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false,
            '/%s \atinstance\aw \apcreate\aw \agType\aw \ayName\aw - Tells group members to create an instance',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false,
            '/%s \atinstance\aw \apinvite\aw \agType\aw \ayName\aw \arInvitee\aw - Tells group members to invite to an instance',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false,
            '/%s \atinstance\aw \apsolo\aw \agName\aw - Tells group members to enter a solo instance',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false,
            '/%s \atinstance\aw \apraid\aw \agName\aw - Tells group members to enter a raid instance',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false,
            '/%s \atinstance\aw \apguild\aw \agName\aw - Tells group members to enter a guild instance',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \atraid\aw \apform\aw - Forms a raid from the Raid_Groups array',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false,
            '/%s \atraid\aw \aploot\aw - Tells the raid to run TurboLoot macro for the current Zone ShortName with delay per launch',
            EZ.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s \atquit\aw - Quits the EZ lua script.', EZ.Command_ShortName)
    end
end
mq.bind('/' .. EZ.Command_ShortName, ez_command)

function EZ.Main()
    print('[EZ] EZ Server Bot Started up! [EZ]')

    while not EZ.Terminate do
        mq.delay(EZ.Loop_Wait)
    end
end

EZ.Main()

Messages.CONSOLEMETHOD(false, 'Shutting down')
mq.unbind('/' .. EZ.Command_ShortName)
return EZ
