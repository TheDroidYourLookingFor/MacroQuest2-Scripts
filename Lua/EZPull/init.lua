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
    Boss_Wait = 250,
    Command_ShortName = 'ezp',
    directMessage = '/dex',
    mainHand = mq.TLO.Me.Inventory(13).Name()
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
        stepWait = 250,
        returnHome = true
    },
    mmcd = {
        [1] = 'Bloodguard Harvester',
        [2] = 'Malicious Scion Shadow',
        stepWait = 250,
        returnHome = false
    },
    takd = {
        [1] = 'Mature Sand Frog',
        [2] = 'Petrified Great Tree',
        stepWait = 250,
        returnHome = false
    },
    ruji = {
        [1] = 'Metal Melter',
        [2] = 'Rebellious Arcanist',
        stepWait = 250,
        returnHome = false
    },
    guka = {
        [1] = 'Evil Eye',
        [2] = 'Froglok Ghost',
        stepWait = 250,
        returnHome = false
    },
    mirh = {
        [1] = 'Balrog',
        [2] = 'Chaos',
        stepWait = 250,
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
        [2] = '-1084.42 76.13 -410.57',
        [3] = '-628.43, 228.18, -418.51',
        [4] = '-158.32, 661.07, -392.52',
        [5] = '248.00 435.00 -415.87',
        [6] = '-13.60, 147.11, -253.38',
        [7] = '232.60, -160.66, -372.53',
        [8] = '-255.82, -158.15, -483.80',
        [9] = '-286.29, -707.75, -424.58',
        [10] = '-593.90, -160.57, -427.05',
        [11] = '-693.32, -941.25, -373.07',
        [12] = '-1061.18, -372.75, -410.57',
        [13] = '-72.40, -1514.38, -445.10',
        [14] = '-841.13, -1485.08, -469.60',
        stepWait = 250,
        returnHome = false
    },
    frozenshadow = {
        [1] = '340.31 118.79 -2.31',
        [2] = '376.88 238.81 -1.89',
        [3] = '376.94 334.51 -2.45',
        [4] = '198.86 438.92 -1.22',
        [5] = '60.30 350.76 -1.99',
        [6] = '28.93 314.24 -2.57',
        [7] = '31.10 128.83 -2.50',
        [8] = '355.06 432.25 -1.68',
        stepWait = 250,
        returnHome = true
    },
    frozenshadow2 = {
        [1] = '859.60 276.22 23.90',
        [2] = '869.50 337.20 23.90',
        [3] = '749.37 338.74 23.89',
        [4] = '773.38 384.85 23.89',
        [5] = '869.96 383.51 23.89',
        [6] = '876.50 439.24 23.89',
        [7] = '746.72 439.65 25.51',
        [8] = '770.45 495.74 25.51',
        [9] = '875.50 496.75 25.51',
        [10] = '879.59 553.42 25.51',
        [11] = '425.09 552.92 25.51',
        [12] = '421.80 496.92 25.51',
        [13] = '547.27 495.94 25.50',
        [14] = '530.09 439.12 25.52',
        [15] = '423.92 441.00 25.52',
        [16] = '423.94 385.48 25.52',
        [17] = '554.55 385.47 25.52',
        [18] = '529.64 313.11 25.52',
        [19] = '434.76 330.46 25.52',
        [20] = '427.68 199.41 25.52',
        [21] = '430.10 176.34 25.49',
        [22] = '518.06 221.20 25.49',
        [23] = '639.93 340.29 28.41',
        [24] = '640.24 483.45 28.40',
        [25] = '684.00 502.95 28.40',
        [26] = '682.74 349.80 28.40',
        [27] = '658.23 255.36 28.40',
        stepWait = 250,
        returnHome = true
    },
    frozenshadow3 = {
        [1] = '743.00 749.00 75.71',
        [2] = '762.62 789.62 75.72',
        [3] = '796.00 747.00 75.72',
        [4] = '820.00 803.00 75.71',
        [5] = '848.00 753.75 75.72',
        [6] = '873.50 774.37 75.72',
        [7] = '876.00 887.75 75.72',
        [8] = '823.00 873.00 75.71',
        [9] = '738.37 832.00 75.72',
        [10] = '768.00 805.00 75.72',
        [11] = '791.12 809.62 75.72',
        [12] = '858.12 861.00 75.72',
        [13] = '723.00 862.00 75.72',
        [14] = '629.12 854.50 76.34',
        [15] = '619.12 817.87 76.34',
        [16] = '628.50 776.62 76.34',
        [17] = '705.00 820.00 75.72',
        [18] = '671.62 1028.37 75.87',
        [19] = '842.87 921.87 75.72',
        [20] = '866.62 1049.50 76.00',
        [21] = '793.25 1169.87 75.75',
        [22] = '787.00 1077.00 75.62',
        [23] = '566.25 1029.37 75.87',
        [24] = '664.87 1164.12 83.75',
        [25] = '494.00 1169.00 68.62',
        [26] = '427.25 1130.00 68.75',
        [27] = '455.62 877.87 79.34',
        [28] = '423.00 752.00 76.34',
        [29] = '490.87 760.00 76.34',
        [30] = '595.75 800.00 77.43',
        [31] = '672.86 755.21 76.22',
        stepWait = 100,
        returnHome = false
    },
    arthicrex = {
        [1] = '152.25 -511.37 3.75',
        [2] = '520.51 -390.46 6.64',
        [3] = '631.90 -429.40 5.15',
        [4] = '704.52 -91.77 5.33',
        [5] = '510.08 10.94 5.04',
        [6] = '989.42 480.22 9.40',
        [7] = '1335.42 689.75 9.60',
        [8] = '793.45 844.01 3.77',
        [9] = '684.33 672.54 7.40',
        [10] = '547.88 590.65 5.42',
        [11] = '557.30 1020.51 3.95',
        [12] = '445.61 1198.72 5.50',
        [13] = '297.77 1131.26 4.68',
        [14] = '323.78 796.36 6.35',
        [15] = '215.34 9.67 3.38',
        [16] = '-136.02 271.94 5.92',
        [17] = '-449.82 119.38 7.42',
        [18] = '-328.55 935.65 3.41',
        [19] = '-520.52 884.22 3.40',
        [20] = '-577.56 694.66 8.28',
        [21] = '-1117.14 798.06 4.30',
        [22] = '-1359.34 782.28 4.48',
        [23] = '-1369.41 452.81 5.85',
        [24] = '-916.52 72.49 4.30',
        [25] = '-1094.75 -347.50 12.34',
        [26] = '-1287.37 -320.94 8.05',
        [27] = '-1373.97 -493.53 8.75',
        [28] = '-1346.34 -613.79 11.32',
        [29] = '-962.36 -750.89 5.42',
        [30] = '-822.54 -826.18 3.68',
        [31] = '-706.65 -748.27 4.41',
        [32] = '-1031.71 -448.48 3.42',
        [33] = '-594.52 -597.10 3.39',
        [34] = '-570.45 -774.04 15.50',
        [35] = '-408.00 -739.97 23.93',
        [36] = '-350.62 -394.32 4.56',
        [37] = '-378.74 -129.73 6.33',
        [38] = '-82.84 -27.08 16.47',
        [39] = '-162.11 -337.15 3.53',
        [40] = '100.36 -585.93 3.88',
        stepWait = 100,
        returnHome = false
    },
}

local function PullBosses(bossTable, useXYZ, ...)
    local args = { ... }
    local stopDist = args[1] or 10
    print('Beginning Boss Pull.')
    mq.cmd('/unequip mainhand')
    mq.delay(250)
    local returnHome = bossTable.returnHome
    local stepWait = bossTable.stepWait
    local start_X = mq.TLO.Me.X()
    local start_Y = mq.TLO.Me.Y()
    local start_Z = mq.TLO.Me.Z()

    for i = 1, #bossTable do
        if useXYZ then
            Navigation.NavToStringXYZ(bossTable[i], stopDist)
            mq.delay(stepWait)
        else
            local currentTarget = bossTable[i]
            local currentTargetID
            mq.cmdf('/target npc %s', currentTarget)
            mq.delay(4000, function() return mq.TLO.Target.ID ~= nil end)
            currentTargetID = mq.TLO.Target.ID()
            Navigation.NavToTarget(currentTargetID, stopDist)
            mq.delay(stepWait)
        end
    end

    if returnHome then Navigation.NavToXYZ(start_X, start_Y, start_Z) end
    mq.delay(250)
    mq.cmdf('/exchange "%s" mainhand', EZ.mainHand)
    print('Finished Boss Pull.')
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
        elseif args[1] == 'frozenshadow' then
            PullBosses(Bosses.frozenshadow, true, 1)
        elseif args[1] == 'frozenshadow2' then
            PullBosses(Bosses.frozenshadow2, true, 1)
        elseif args[1] == 'frozenshadow3' then
            PullBosses(Bosses.frozenshadow3, true, 1)
        elseif args[1] == 'arthicrex' then
            PullBosses(Bosses.arthicrex, true, 1)
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
