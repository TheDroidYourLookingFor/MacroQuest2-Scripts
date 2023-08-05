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
        -- [1] = 'Pixtt Llan Kvish',
        -- [2] = 'Hexxt Iik Klokk',
        -- [3] = 'Pixtt Sho Val Kgi',
        -- [4] = 'Igthinxa Karnkvi',
        -- [5] = 'Averixx Quimeri',
        -- [6] = 'Dovin Msha',
        -- [7] = 'Ptav Msha',
        -- [8] = 'Hexxt Jkak Mig',
        -- [9] = 'Mnat Msha',
        -- [10] = 'Lxt Rslav',
        -- [11] = 'Aganetti the Keeper',
        -- [12] = 'Rav Karnkki',
        -- [13] = 'Rav Marnkki',
        -- [14] = 'Rav Gemkki',
        [1] = '-779.89, -105.12, -415.02',
        [2] = '-1009.28, 236.98, -410.48',
        [3] = '-628.43, 228.18, -418.51',
        [4] = '-158.32, 661.07, -392.52',
        [5] = '261.04, 436.41, -404.83',
        [6] = '-13.60, 147.11, -253.38',
        [7] = '232.60, -160.66, -372.53',
        [8] = '-255.82, -158.15, -483.80',
        [9] = '-286.29, -707.75, -424.58',
        [10] = '-593.90, -160.57, -427.05',
        [11] = '-693.32, -941.25, -373.07',
        [12] = '-1061.18, -372.75, -410.57',
        [13] = '-72.40, -1514.38, -445.10',
        [14] = '-841.13, -1485.08, -469.60',
        returnHome = true
    }
}

local function PullBosses(bossTable, useXYZ)
    mq.cmd('/unequip mainhand')
    mq.delay(250)
    local returnHome = bossTable.returnHome
    local start_X = mq.TLO.Me.X()
    local start_Y = mq.TLO.Me.Y()
    local start_Z = mq.TLO.Me.Z()

    for i = 1, #bossTable do
        if useXYZ then
            Navigation.NavToStringXYZ(bossTable[i])
        else
            local currentTarget = bossTable[i]
            local currentTargetID
            mq.cmdf('/target npc %s', currentTarget)
            mq.delay(4000, function () return mq.TLO.Target.ID ~= nil end)
            currentTargetID = mq.TLO.Target.ID()
            Navigation.NavToTarget(currentTargetID)
        end
    end

    if returnHome then Navigation.NavToXYZ(start_X, start_Y, start_Z) end
    mq.delay(250)
    mq.cmdf('/exchange "%s" mainhand', EZ.mainHand)
end

local function ez_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'potimea' then
            PullBosses(Bosses.potimea, false)
        elseif args[1] == 'qvic' then
            PullBosses(Bosses.qvic, true)
        elseif args[1] == 'mmcd' then
            PullBosses(Bosses.mmcd, false)
        elseif args[1] == 'takd' then
            PullBosses(Bosses.takd, false)
        elseif args[1] == 'ruji' then
            PullBosses(Bosses.ruji, false)
        elseif args[1] == 'guka' then
            PullBosses(Bosses.guka, false)
        elseif args[1] == 'mirh' then
            PullBosses(Bosses.mirh, false)
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
