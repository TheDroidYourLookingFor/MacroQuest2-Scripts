--|------------------------------------------------------------|
--|          MoveBot
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')
local moveBot = {
    debug = false,
    terminate = false,
    anchor_X = 0,
    anchor_Y = 0,
    anchor_Z = 0,
    last_X = 0,
    last_Y = 0,
    last_Z = 0,
    delay_Soft = 5000,
    delay_Hard = 1000,
    spawnSearch = '%s los radius %d zradius %d',
    nearestSearch = '%s targetable los radius %d zradius %d noalert 3',
    command_Prefix = '/dgga ',
    macro_Start = '/ma startup',
    macro_Stop = '/end'
}
moveBot.Settings = {
    mode = 'Camp', -- Camp | Hunt | BuiltIn
    returnToCamp = true,
    anchor_Radius = 30,
    aggro_Radius = 100,
    aggro_zRadius = 10,
    meditate = false,
    meditate_At = 25,
}

-- local Casting = require('MoveBot.Lib.Casting')
-- local Events = require('MoveBot.Lib.Events')
-- local Gui = require('MoveBot.Lib.Gui')
local Messages = require('MoveBot.Lib.Messages')
local Navigation = require('MoveBot.lib.Movement')
-- local SpellRoutines = require('MoveBot.lib.spell_routines')
local Storage = require('MoveBot.lib.Storage')

function moveBot.SetAnchor()
    moveBot.anchor_X = mq.TLO.Me.X()
    moveBot.anchor_Y = mq.TLO.Me.Y()
    moveBot.anchor_Z = mq.TLO.Me.Z()
end

function moveBot.Move(X, Y, Z, StopAt)
    moveBot.last_X = X
    moveBot.last_Y = Y
    moveBot.last_Z = Z
    Navigation.NavToXYZ(X, Y, Z)
end

function moveBot.DoDPS(spellTargetID, spellName, spellGem)
    if spellGem == 'alt' then
        Casting.CastDPS(spellTargetID, spellName, 'alt')
    elseif spellGem == 'item' then
        Casting.CastDPS(spellTargetID, spellName, 'item')
    else
        Casting.CastDPS(spellTargetID, spellName, spellGem)
    end
end

function moveBot.KillAllNear()
    if mq.TLO.Navigation.Active() then mq.cmd('/nav pause') end
    if mq.TLO.AdvPath.Active() then mq.cmd('/nav pause') end
    if mq.TLO.SpawnCount(moveBot.spawnSearch:format('npc', moveBot.Settings.aggro_Radius, moveBot.Settings.aggro_zRadius)) > 0 then
        Messages.CONSOLEMETHOD(moveBot.debug, 'Mobs Found!')
        mq.cmdf(moveBot.command_Prefix .. ' /target %s pc', mq.TLO.Group.MainTank())
        mq.delay(2000, function() return mq.TLO.Target.ID() ~= nil end)
        mq.cmd(moveBot.command_Prefix .. moveBot.macro_Start)
        while mq.TLO.SpawnCount(moveBot.spawnSearch:format('npc', moveBot.Settings.aggro_Radius, moveBot.Settings.aggro_zRadius)) > 0 do
            mq.delay(250)
        end
        mq.cmd(moveBot.command_Prefix .. moveBot.macro_Stop)
    end
end

function moveBot.Checks()

end

function moveBot.DoPull()
    local start_X = mq.TLO.Me.X()
    local start_Y = mq.TLO.Me.Y()
    mq.cmd(moveBot.macro_Start)
    mq.delay(1000)
    mq.cmd('/dgge /nav stop')
    mq.delay(200)
    mq.cmd('/rg CampHard')
    mq.delay(1000)
    mq.cmd('/rg DoPull 1')
    mq.delay(30000, function ()
        return ((mq.TLO.Me.X() - start_X) or (mq.TLO.Me.Y() - start_Y)) > 5
    end)
    while Navigation.GetDistance(moveBot.anchor_X,moveBot.anchor_Y,moveBot.anchor_Z) <= moveBot.Settings.anchor_Radius do
        mq.delay(250)
    end
    mq.cmd('/end')
end

function moveBot.HuntMob()
end

function moveBot.CampMode()
    if Navigation.GetDistance(moveBot.anchor_X,moveBot.anchor_Y,moveBot.anchor_Z) > moveBot.Settings.anchor_Radius and moveBot.Settings.returnToCamp then Navigation.NavToXYZ(moveBot.anchor_X,moveBot.anchor_Y,moveBot.anchor_Z) end
    moveBot.DoPull()
    mq.delay(250)
    moveBot.KillAllNear()
end

function moveBot.HuntMode()
    if Navigation.GetDistance(moveBot.anchor_X,moveBot.anchor_Y,moveBot.anchor_Z) > moveBot.Settings.anchor_Radius and moveBot.Settings.returnToCamp then Navigation.NavToXYZ(moveBot.anchor_X,moveBot.anchor_Y,moveBot.anchor_Z) end
    moveBot.HuntMob()
    mq.delay(250)
    moveBot.KillAllNear()
end

function moveBot.Main()
    print('[MB] MoveBot Started up! [MB]')
    if not mq.TLO.Plugin('MQ2Nav').IsLoaded() then mq.cmd('/plugin mq2nav load') end

    while not moveBot.terminate do
        moveBot.Checks()
        if moveBot.Settings.mode == 'Camp' then
            moveBot.CampMode()
        elseif moveBot.Settings.mode == 'Hunt' then
            moveBot.HuntMode()
        else
            if mq.TLO.Zone.Name() == 'Hatchery Wing' and moveBot.Settings.mode == 'BuiltIn' then end
            if mq.TLO.Zone.Name() == 'Wall of Slaughter' and moveBot.Settings.mode == 'BuiltIn' then end
            if mq.TLO.Zone.Name() == 'Riftseekers\' Sanctum' and moveBot.Settings.mode == 'BuiltIn' then end
            if mq.TLO.Zone.Name() == 'Muramite Proving Grounds' and moveBot.Settings.mode == 'BuiltIn' then end
        end
        mq.delay(25)
    end
end

Messages.CONSOLEMETHOD(false, 'Shutting down')

return moveBot
