local mq = require 'mq'
local actor = require('interface.actor')
local config = require('interface.configuration')
local camp = require('routines.camp')
local helpers = require('utils.helpers')
local logger = require('utils.logger')
local movement = require('utils.movement')
local timer = require('libaqo.timer')
local mode = require('mode')
local state = require('state')

local tank = {}

function tank.init()
    actor.register('tanking', tank.callback)
end

local campBuffer = 20

--- Tank Functions

function tank.isTank()
    return mode.currentMode:isTankMode() or mq.TLO.Group.MainTank() == mq.TLO.Me.CleanName() or config.get('MAINTANK')
end

function tank.callback(message)
    if message.content.tankID == mq.TLO.Me.ID() then return end
    state.actorAssistID = message.content.tankMobID
    state.actorTankID = message.content.tankID
end

function tank.broadcastTankMob()
    local header = {script = 'aqo'}
    local tankingMessage = {id='tanking', tankMobID=state.tankMobID, tankID=mq.TLO.Me.ID()}
    actor.actor:send(header, tankingMessage)
end

---Iterate through mobs in the common.TARGETS table and find a mob in camp to begin tanking.
---Sets common.tankMobID to the ID of the mob to tank.
function tank.findMobToTank()
    if state.mobCount == 0 then
        -- No mobs present to tank
        return false
    end
    if mq.TLO.Target() and mq.TLO.Target.Name() == 'Reward Chest' and mq.TLO.Target.PctHPs() == 100 and mq.TLO.EverQuest.Server() == 'Chaotic' then
        mq.cmd('/say /open')
        mq.delay(150)
        mq.cmd('/autoinv')
    end
    if state.tankMobID > 0 and mq.TLO.Target() and mq.TLO.Target.Type() ~= 'Corpse' and state.tankMobID == mq.TLO.Target.ID() then
        -- Already actively tanking a mob
        tank.stickToMob()
        if not mq.TLO.Me.Combat() then mq.cmd('/attack on') end
        if config.USEBOTS and mq.TLO.Group() and mq.TLO.Group.Member(1).Distance3D() > 25 then
            mq.cmd('/say ^summon all')
            mq.delay(500)
            mq.cmd('/say ^attack')
        end
        return false
    else
        state.tankMobID = 0
    end
    logger.debug(logger.flags.routines.tank, 'Find mob to tank')
    if config.get('OFFTANK') then
        if state.actors then
            local offtankIDs = {}
            local numTanks = 0
            for _,charData in pairs(state.actors) do
                if charData.missingAggro then
                    numTanks = numTanks + 1
                    for _,mobID in ipairs(charData.missingAggro) do
                        offtankIDs[mobID] = (offtankIDs[mobID] or 0) + 1
                    end
                end
            end
            for id,count in pairs(offtankIDs) do
                if count == numTanks then
                    logger.debug(logger.flags.routines.tank, 'No tank has aggro on mob (%s), offtanking', id)
                    state.tankMobID = id
                    return true
                end
            end
        end
    end
    local highestlvl = 0
    local highestlvlid = 0
    local lowesthp = 98
    local lowesthpid = 0
    local firstid = 0
    local firstname = nil
    for id,_ in pairs(state.targets) do
        -- loop through for named, highest level, unmezzed, lowest hp
        local mob = mq.TLO.Spawn(id)
        if mob() then
            local name = mob.CleanName() or ''
            if firstid == 0 then firstid = mob.ID() firstname = name end
            if mob.Named() then
                logger.debug(logger.flags.routines.tank, 'Selecting Named mob to tank next (%s)', mob.ID())
                state.tankMobID = mob.ID()
                return true
            else--if not mob.Mezzed() then -- TODO: mez check requires targeting
                if firstname and firstname:find('scarab') and not name:find('scarab') then
                    firstid = mob.ID()
                    firstname = mob.CleanName()
                end
                if (mob.Level() or 0) > highestlvl and not name:find('scarab') then
                    highestlvlid = id
                    highestlvl = mob.Level()
                end
                if (mob.PctHPs() or 100) < lowesthp and not name:find('scarab') then
                    lowesthpid = id
                    lowesthp = mob.PctHPs()
                end
            end
        end
    end
    if lowesthpid ~= 0 and lowesthp < 98 then
        logger.debug(logger.flags.routines.tank, 'Selecting lowest HP mob to tank next (%s)', lowesthpid)
        state.tankMobID = lowesthpid
        return true
    elseif highestlvlid ~= 0 then
        logger.debug(logger.flags.routines.tank, 'Selecting highest level mob to tank next (%s)', highestlvlid)
        state.tankMobID = highestlvlid
        return true
    end
    -- no named or unmezzed mobs, break a mez
    if firstid ~= 0 then
        logger.debug(logger.flags.routines.tank, 'Selecting first available mob to tank next (%s)', firstid)
        state.tankMobID = firstid
        return true
    end
    return false
end

---Determine whether the target to be tanked is within the camp radius.
---@return boolean @Returns true if the target is within the camp radius, otherwise false.
local function tankMobInRange(tank_spawn)
    local mob_x = tank_spawn.X()
    local mob_y = tank_spawn.Y()
    if not mob_x or not mob_y then return false end
    local camp_radius = config.get('CAMPRADIUS')
    if mode.currentMode:isReturnToCampMode() and camp.Active then
        local dist = helpers.distance(camp.X, camp.Y, mob_x, mob_y)
        if dist < camp_radius^2 then
            return true
        else
            local targethp = tank_spawn.PctHPs()
            if targethp and targethp < 95 and dist < camp_radius+campBuffer then
                return true
            end
            return false
        end
    else
        if helpers.distance(mq.TLO.Me.X(), mq.TLO.Me.Y(), mob_x, mob_y) < camp_radius^2 then
            return true
        else
            return false
        end
    end
end

function tank.approachMob()
    if state.tankMobID == 0 then return false end
    local tank_spawn = mq.TLO.Spawn(state.tankMobID)
    if not tank_spawn() or tank_spawn.Type() == 'Corpse' then
        state.tankMobID = 0
        return false
    end
    if not tankMobInRange(tank_spawn) then
        state.tankMobID = 0
        return false
    end
    if not tank_spawn.LineOfSight() then
        movement.navToTarget(nil, 2000)
        return true
    end
    return true
end

function tank.acquireTarget()
    if state.tankMobID == 0 then return false end
    local tank_spawn = mq.TLO.Spawn(state.tankMobID)
    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= tank_spawn.ID() then
        tank_spawn.DoTarget()
    end
    return true
end

local stickTimer = timer:new(3000)
local tankAnnounced = nil
---Tank the mob whose ID is stored in common.tankMobID.
function tank.tankMob()
    --[[if state.tankMobID == 0 then return end
    local tank_spawn = mq.TLO.Spawn(state.tankMobID)
    if not tank_spawn() or tank_spawn.Type() == 'Corpse' then
        state.tankMobID = 0
        return
    end
    if not tankMobInRange(tank_spawn) then
        state.tankMobID = 0
        return
    end
    if not tank_spawn.LineOfSight() then
        movement.navToTarget(nil, 2000)
        return
    end
    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= tank_spawn.ID() then
        tank_spawn.DoTarget()
    end]]
    if not mq.TLO.Target() or mq.TLO.Target.Type() == 'Corpse' then
        state.tankMobID = 0
        return false
    end
    if mq.TLO.Target() and mq.TLO.Target.Name() == 'Reward Chest' and mq.TLO.Target.PctHPs() == 100 and mq.TLO.EverQuest.Server() == 'Chaotic' then
        mq.cmd('/say /open')
        mq.delay(150)
        mq.cmd('/autoinv')
    end
    
    --movement.stop()
    if mq.TLO.Navigation.Active() then mq.cmd('/squelch /nav stop') end
    mq.cmd('/multiline ; /stand ; /squelch /face fast')
    if not mq.TLO.Me.Combat() and not state.dontAttack then
        if state.tankMobID ~= tankAnnounced then
            logger.info('Tanking \at%s\ax (\at%s\ax)', mq.TLO.Target.CleanName(), state.tankMobID)
            tankAnnounced = state.tankMobID
            tank.broadcastTankMob()
        end
        -- /stick snaproll front moveback
        -- /stick mod -2
        state.resists = {}
        mq.cmd('/attack on')
        if config.USEBOTS and mq.TLO.Group() and mq.TLO.Group.Member(1).Distance3D() > 25 then
            mq.cmd('/say ^summon all')
            mq.delay(500)
            mq.cmd('/say ^attack')
        end
        stickTimer:reset(0)
    elseif state.dontAttack and state.enrageTimer:expired() then
        state.dontAttack = false
    end
    return true
    --[[if mq.TLO.Me.Combat() and stickTimer:expired() and not mq.TLO.Stick.Active() and mode.currentMode:getName() ~= 'manual' then
        mq.cmd('/squelch /stick front loose moveback 10')
        stickTimer:reset()
    end]]
end

function tank.callAssist()
    if state.tankMobID ~= tankAnnounced then
        logger.info('Tanking \at%s\ax (\at%s\ax)', mq.TLO.Target.CleanName(), state.tankMobID)
        tankAnnounced = state.tankMobID
        tank.broadcastTankMob()
    end
    -- /stick snaproll front moveback
    -- /stick mod -2
    state.resists = {}
    stickTimer:reset(0)
end

function tank.stickToMob()
    if mq.TLO.Me.Combat() and stickTimer:expired() and not mq.TLO.Stick.Active() and mode.currentMode:getName() ~= 'manual' then
        mq.cmd('/squelch /stick front loose moveback 10')
        stickTimer:reset()
    end
end

return tank