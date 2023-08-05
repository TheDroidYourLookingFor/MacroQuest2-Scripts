--|------------------------------------------------------------|
--|          dHunt
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')
local dHunt = {
    terminate = false,
    aggro_Radius = 2000,
    aggro_zRadius = 250,
    mob_Wait = 50000,
    strict_targ = true,
    targetName = { 'tarant', 'spider' },
    spawnSearch = '%s radius %d zradius %d',
    doLoot = false,
    corpse_Radius = 100,
    corpse_zRadius = 25
}

-- local Casting = require('dHunt.lib.Casting')
-- local Events = require('dHunt.lib.Events')
-- local Gui = require('dHunt.lib.Gui')
local Messages = require('dHunt.lib.Messages')
local Navigation = require('dHunt.lib.Movement')
-- local SpellRoutines = require('dHunt.lib.spell_routines')
-- local Storage = require('dHunt.lib.Storage')
local lootutils = require('dHunt.lib.LootUtils')

local function GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function dHunt.MoveXYZ(X, Y, Z, StopAt)
    Navigation.NavToXYZ(X, Y, Z)
end

function dHunt.MoveTarg(targetID)
    Navigation.NavToTarget(targetID)
end

function dHunt.Checks()
end

function dHunt.LookForMob()
    for mob, value in pairs(dHunt.targetName) do
        if dHunt.strict_targ then
            if mq.TLO.SpawnCount(dHunt.spawnSearch:format('npc ' .. value, dHunt.aggro_Radius, dHunt.aggro_zRadius))() > 0 then
                mq.cmdf('/target %s',
                    mq.TLO.NearestSpawn(dHunt.spawnSearch:format('npc ' .. value, dHunt.aggro_Radius, dHunt
                    .aggro_zRadius))())
                local lastTargID = mq.TLO.Target.ID()
                dHunt.MoveTarg(lastTargID)
                if not mq.TLO.Me.Combat() then mq.cmd('/attack on') end
                mq.delay(dHunt.mob_Wait, function() return mq.TLO.Spawn(lastTargID)() == nil end)
            end
        else
            if mq.TLO.SpawnCount(dHunt.spawnSearch:format('npc ' , dHunt.aggro_Radius, dHunt.aggro_zRadius))() > 0 then
                mq.cmdf('/target %s',
                    mq.TLO.NearestSpawn(dHunt.spawnSearch:format('npc ', dHunt.aggro_Radius, dHunt
                    .aggro_zRadius))())
                local lastTargID = mq.TLO.Target.ID()
                dHunt.MoveTarg(lastTargID)
                if not mq.TLO.Me.Combat() then mq.cmd('/attack on') end
                mq.delay(dHunt.mob_Wait, function() return mq.TLO.Spawn(lastTargID)() == nil or mq.TLO.Spawn(lastTargID).Dead() end)
            end
        end
    end
end

function dHunt.CheckForLoot()
    local deadCount = mq.TLO.SpawnCount(dHunt.spawnSearch:format('npccorpse', dHunt.corpse_Radius, dHunt.corpse_zRadius))()
    if dHunt.doLoot and deadCount ~= 0 then
        lootutils.lootMobs()
        mq.delay(100)
    end
end

function dHunt.Main()
    print('[HB] HuntBot Started up! [HB]')
    if not mq.TLO.Plugin('MQ2Nav').IsLoaded() then mq.cmd('/plugin mq2nav load') end
    if not mq.TLO.Plugin('MQ2Melee').IsLoaded() then mq.cmd('/plugin mq2melee load') end

    while not dHunt.terminate do
        dHunt.Checks()
        dHunt.LookForMob()
        dHunt.CheckForLoot()
        mq.delay(25)
    end
end

dHunt.Main()
Messages.CONSOLEMETHOD(false, 'Shutting down')

return dHunt
