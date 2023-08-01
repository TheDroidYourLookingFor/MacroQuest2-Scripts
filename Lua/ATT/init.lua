--|------------------------------------------------------------|
--|     Fisherman's Companion - Alcohol Tolerance Trainer
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|        Originally by: TheDroidUrLookingFor
--|
--|------------------------------------------------------------|
local mq = require('mq')
local version = '1.0.0'

local settings = {
    terminate = false,
    drunkCap = mq.TLO.Skill('Alcohol Tolerance').SkillCap(),
    maxSnacks = 20,
    summonAt = 1,
    summonDelayTime = 3000,
    booze = 'Summoned: Ale',
    boozeItem = 'Brell\'s Fishin\' Pole',
    preBoozeItem = 'Fisherman\'s Companion',
}

--|------------------------------------------------------------|
--|          Events
--|------------------------------------------------------------|
local function event_skillUp(SkillUpText,SkillName,Amount)
    printf('\ay%s \awincreased - \ag%s \ar/ \ag%s \ax',SkillName,Amount,settings.drunkCap)
end

local function event_tooDrunk()
    local stumble
    stumble = 20+math.random(10)
    printf('Too Drunk to drink right now ( waiting %ss )',stumble)
    mq.delay(stumble * 1000)
end

local function defineEvents()
    mq.event('SkillUp', "You have become better at #1# (#2#)", event_skillUp)
    mq.event('TooDrunk', "You could not possibly consume more alcohol or become more intoxicated#*#", event_tooDrunk)
end
defineEvents()

--|------------------------------------------------------------|
--|          End Events
--|------------------------------------------------------------|

--|------------------------------------------------------------|
--|          Other Rountines
--|------------------------------------------------------------|
local function summonBooze()
    printf('Starting to summon: %s!',settings.booze)
    while mq.TLO.FindItemCount(settings.booze) < settings.maxSnacks do
        if mq.TLO.FindItem(settings.boozeItem).TimerReady() and mq.TLO.FindItemCount(settings.booze) <= settings.maxSnacks and mq.TLO.FindItem(settings.boozeItem).Name() ~= nil then
            printf('Summoning %s', settings.booze)
            mq.cmdf('/useitem %s', mq.TLO.FindItem(settings.boozeItem))
        end
        mq.delay(settings.summonDelayTime)
        mq.cmd('/autoinventory')
        mq.delay(25)
    end
    printf('Summoned %s of %s!',settings.maxSnacks,settings.booze)
end
--|------------------------------------------------------------|
--|          End Other Rountines
--|------------------------------------------------------------|

--|------------------------------------------------------------|
--|          Main Rountine
--|------------------------------------------------------------|
local function main()
    if mq.TLO.Skill('Alcohol Tolerance') == settings.drunkCap then
        print('\ayYou are a professionsal drinker! skill maxed\ax')
        mq.cmd('/beep')
        return
    end

    if mq.TLO.FindItemCount(settings.boozeItem) == 0 and mq.TLO.FindItem(settings.preBoozeItem).Name() ~= nil then
        mq.cmdf('/useitem %s', mq.TLO.FindItem(settings.preBoozeItem))
    end

    printf('\ayStarting Alcohol Tolerance Trainer \ar( \ag%s \ar/ \ag%s\ar) \ax', mq.TLO.Skill('Alcohol Tolerance'), settings.drunkCap)

    while not settings.terminate do
        if mq.TLO.Me.Skill('Alcohol Tolerance') == mq.TLO.Me.Skill('Alcohol Tolerance').SkillCap() then
            print('\ayYou are a professionsal drinker! skill maxed\ax')
            mq.cmd('/beep')
            settings.terminate = true
            return
        end
        if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
        if mq.TLO.FindItemCount(settings.booze) <= settings.summonAt then summonBooze() end
        if mq.TLO.Me.Drunk() < 100 and mq.TLO.FindItemCount(settings.booze) >= 1 then
            mq.cmdf('/useitem %s', mq.TLO.FindItem(settings.booze))
        end
        mq.delay(1000)
        mq.doevents()
    end
end
--|------------------------------------------------------------|
--|          End Main Rountine
--|------------------------------------------------------------|
main()
