local mq = require('mq')
local config = require('interface.configuration')
local abilities = require('ability')
local constants = require('constants')
local state = require('state')

local class
local debuff = {}

debuff.SLOW_IMMUNES = {}
debuff.SNARE_IMMUNES = {}

function debuff.init(_class)
    class = _class
end

function debuff.shouldUseDebuff(ability)
    if ability.opt == 'USEDISPEL' then
        local beneficial = mq.TLO.Target.Beneficial
        return beneficial() and beneficial.Dispellable() and not constants.ignoreBuff[beneficial()]
    elseif ability.opt == 'USECRIPPLE' then
        return mq.TLO.Target() and mq.TLO.Target.Named()
    elseif ability.opt == 'USESLOWAOE' or ability.opt == 'USESLOW' then
        return mq.TLO.Target() and not mq.TLO.Target.Slowed() and not debuff.SLOW_IMMUNES[mq.TLO.Target.CleanName()]
    elseif ability.opt == 'USESNARE' then
        return mq.TLO.Target() and not mq.TLO.Target.Snared() and not debuff.SNARE_IMMUNES[mq.TLO.Target.CleanName()] and (mq.TLO.Target.PctHPs() or 100) < 40
    else
        return (not ability.condition and not mq.TLO.Target.Buff(ability.CheckFor or ability.Name)() and mq.TLO.Spell(ability.CheckFor or ability.Name).StacksTarget()) or (ability.condition and ability.condition())
    end
end

function debuff.findNextDebuff(opt, targetID)
    for _,ability in ipairs(class.debuffs) do
        local resistCount = state.resists[ability.Name] or 0
        local resistStopCount = config.get('RESISTSTOPCOUNT')
        if ability:canUse() == abilities.IsReady.CAN_CAST then
            if targetID then mq.TLO.Spawn('id '..targetID).DoTarget() mq.delay(1000, function() return mq.TLO.Target.BuffsPopulated() end) end
            if (resistStopCount == 0 or resistCount < resistStopCount) and ability.opt == opt and debuff.shouldUseDebuff(ability) then
                if abilities.use(ability) then return true end
            end
        end
    end
end

local debuffTypeMap = {Dispel='USEDISPEL',DebuffAOE='USEDEBUFFAOE',Debuff='USEDEBUFF',SlowAOE='USESLOWAOE',Slow='USESLOW',Cripple='USECRIPPLE',Snare='USESNARE'}
function debuff.castDebuffs()
    -- if mq.TLO.Target.Type() ~= 'NPC' or not mq.TLO.Target.Aggressive() then return end
    for _,debuffType in ipairs(class.debuffOrder) do
        if class:isEnabled(debuffTypeMap[debuffType]) then
            if debuff.findNextDebuff(debuffTypeMap[debuffType]) then
                if debuffType == 'SlowAOE' or debuffType == 'Slow' then
                    mq.doevents('event_debuffSlowImmune')
                elseif debuffType == 'Snare' then
                    mq.doevents('event_debuffSnareImmune')
                end
                return true
            end
        end
    end
end

function debuff.debuffOthers()
    for id,mobdata in pairs(state.targets) do
        if id ~= state.assistMobID then
            if not mobdata.slowed then
                -- mq.TLO.Spawn('id '..id).DoTarget()
                -- mq.delay(1000, function() return mq.TLO.Target.BuffsPopulated() end)
                if debuff.findNextDebuff('USESLOW', id) then
                    state.targets[id].slowed = true
                    mq.doevents('event_debuffSlowImmune')
                    return true
                end
            end
        end
    end
end

-- attempt to avoid trying to slow mobs that are slow immune. currently this table is never cleaned up unless restarted
function debuff.eventSlowImmune(line)
    local target_name = mq.TLO.Target.CleanName()
    if target_name and not debuff.SLOW_IMMUNES[target_name] then
        debuff.SLOW_IMMUNES[target_name] = 1
    end
end

-- attempt to avoid trying to snare mobs that are snare immune. currently this table is never cleaned up unless restarted
function debuff.eventSnareImmune()
    local target_name = mq.TLO.Target.CleanName()
    if target_name and not debuff.SNARE_IMMUNES[target_name] then
        debuff.SNARE_IMMUNES[target_name] = 1
    end
end

function debuff.setupEvents()
    if class.options.USESLOW or class.options.USESLOWAOE then
        mq.event('event_debuffSlowImmune', 'Your target is immune to changes in its attack speed#*#', debuff.eventSlowImmune)
    end
    if class.options.USESNARE then
        mq.event('event_debuffRunspeedImmune', 'Your target is immune to changes in its run speed#*#', debuff.eventSnareImmune)
        mq.event('event_debuffSnareImmune', 'Your target is immune to snare spells#*#', debuff.eventSnareImmune)
    end
end

return debuff