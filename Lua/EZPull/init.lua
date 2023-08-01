--|------------------------------------------------------------|
--|          EZ
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')

-- local Casting = require('EZPull.lib.Casting')
-- local Events = require('EZPull.Lib.Events')
-- local Gui = require('EZPull.lib.Gui')
local Messages = require('EZPull.lib.Messages')
local Navigation = require('EZPull.lib.Movement')
-- local SpellRoutines = require('EZPull.lib.spell_routines')
-- local Storage = require('EZPull.lib.Storage')
-- local lootutils = require('EZPull.lib.LootUtils')

local EZ = {
    Debug = false,
    Terminate = false,
    Loop_Wait = 1000,
    Command_ShortName = 'ezp',
    directMessage = '/dex',
    mainHand = 'Ultimate Great Axe II'
}

local Bosses = {
    potimea = {
        [1] = 'Gemcutter',
        [2] = 'Warlord Statue',
        [3] = 'Stampy',
        [4] = 'Eight Eyes',
        [5] = 'Ssss',
        [6] = 'Djinni',
        [7] = 'The Eternal',
        [8] = 'Lockjaw\'s Big Brother',
        [9] = 'Silver Knight',
        returnHome = true
    },
    mmcd = {
        [1] = 'Bloodguard Harvester',
        [2] = 'Malicious Scion Shadow',
        returnHome = false
    },
    takd = {
        [1] = 'Mature Sand Frog',
        [2] = 'Petrified Great Tree',
        returnHome = false
    },
    ruji = {
        [1] = 'Metal Melter',
        [2] = 'Rebellious Arcanist',
        returnHome = false
    },
    guka = {
        [1] = 'Evil Eye',
        [2] = 'Froglok Ghost',
        returnHome = false
    },
    mirh = {
        [1] = 'Balrog',
        [2] = 'Chaos',
        returnHome = false
    },
    qvic = {
        [1] = 'Pixtt Llan Kvish',
        [2] = 'Hexxt Iik Klokk',
        [3] = 'Pixtt Sho Val Kgi',
        [4] = 'Igthinxa Karnkvi',
        [5] = 'Averixx Quimeri',
        [6] = 'Dovin Msha',
        [7] = 'Ptav Msha',
        [8] = 'Hexxt Jkak Mig',
        [9] = 'Mnat Msha',
        [10] = 'Lxt Rslav',
        [11] = 'Aganetti the Keeper',
        [12] = 'Rav Karnkki',
        [13] = 'Rav Marnkki',
        [14] = 'Rav Gemkki',
        returnHome = true
    }
}

local function PullBosses(bossTable)
    mq.cmd('/unequip mainhand')
    mq.delay(250)
    local returnHome = bossTable.returnHome
    local start_X = mq.TLO.Me.X()
    local start_Y = mq.TLO.Me.Y()
    local start_Z = mq.TLO.Me.Z()

    for i = 1, #bossTable do
        local currentTarget = bossTable[i]
        local currentTargetID
        mq.cmdf('/target npc %s', currentTarget)
        mq.delay(4000, function () return mq.TLO.Target.ID ~= nil end)
        currentTargetID = mq.TLO.Target.ID()
        Navigation.NavToTarget(currentTargetID)
    end

    if returnHome then Navigation.NavToXYZ(start_X, start_Y, start_Z) end
    mq.delay(250)
    mq.cmdf('/exchange "%s" mainhand', EZ.mainHand)
end

local function ez_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'potimea' then
            PullBosses(Bosses.potimea)
        elseif args[1] == 'qvic' then
            PullBosses(Bosses.qvic)
        else
            Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            Messages.CONSOLEMETHOD(false, '/%s \atgui\aw - Toggles the EZ GUI', EZ.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s \atquit\aw - Quits the EZ lua script.', EZ.Command_ShortName)
        end
    else
        Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        Messages.CONSOLEMETHOD(false, '/%s \atgui\aw - Toggles the EZ GUI', EZ.Command_ShortName)
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
