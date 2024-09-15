local mq = require('mq')

local RB = {
    debug = false,
    Terminate = false,
    instanceFlipper = false,
    deleteCorpses = true,
    castSpells = false,
    spells = { 'Chords of Dissonance' },
    ignoreTarget = 'an imprisoned gnoll',
    reset_At_Mob_Count = 6,
    reset_Instance_At = 5,
    aggro_Radius = 75,
    aggro_zRadius = 25,
    mob_Wait = 50000,
    zone_Wait = 50000,
    rebirth_Wait = 2500,
    wait_One = 500,
    wait_Two = 750,
    wait_Three = 1000,
    wait_Four = 250,
    warpToMobDistance = 25,
    returnHomeDistance = 50,
    buffItem = 'Amulet of Ultimate Buffing',
    BuffCheckName = 'Hand of Conviction',
    spawnSearch = '%s radius %d zradius %d',
    zoneRefresh = 'Charm of Refreshing',
    -- zonePull = 'Charm of Hate',
    zonePull = 'Derekthomx\'s Horrorkrunk Hook',
    hubZoneID = 451,
    staticHuntMode = true,
    huntZoneName = 'pofire',
    huntZoneID = 217,
    huntStaticX = 612.22,
    huntStaticY = 657.17,
    huntStaticY_Pull = 627.17,
    huntStaticZ = -166.87,
    -- huntZoneName = 'paw',
    -- huntZoneID = 18,
    -- huntStaticX = 42.53,
    -- huntStaticY = 718.35,
    -- huntStaticY_Pull = 700,
    -- huntStaticZ = 4.12,
    -- huntZoneName = 'maiden',
    -- huntZoneID = 173,
    -- huntStaticX = 1426,
    -- huntStaticY = 955,
    -- huntStaticY_Pull = 925,
    -- huntStaticZ = -152,
    rebirthStopAt = 20,
    doLoot = false,
    corpse_Radius = 200,
    corpse_zRadius = 25,
    CurrentRebirths = 0
}

RB.ClassAAs = {
    Bard = 39908,
    Beastlord = 39915,
    Berserker = 39916,
    Cleric = 39902,
    Druid = 39906,
    Enchanter = 39914,
    Magician = 39913,
    Monk = 39907,
    Necromancer = 39911,
    Paladin = 39903,
    Ranger = 39904,
    Rogue = 39909,
    Shadowknight = 39905,
    Shaman = 39910,
    Warrior = 39901,
    Wizard = 39912
}
RB.UseClassAA = {
    Bard = false,
    Beastlord = false,
    Berserker = false,
    Cleric = false,
    Druid = false,
    Enchanter = false,
    Magician = false,
    Monk = false,
    Necromancer = false,
    Paladin = false,
    Ranger = false,
    Rogue = false,
    Shadowknight = false,
    Shaman = false,
    Warrior = true,
    Wizard = false
}
-- TODO write class swaps
RB.Classes = {
    Bard = false,
    Beastlord = false,
    Berserker = false,
    Cleric = false,
    Druid = false,
    Enchanter = false,
    Magician = false,
    Monk = false,
    Necromancer = false,
    Paladin = false,
    Ranger = false,
    Rogue = false,
    Shadowknight = false,
    Shaman = false,
    Warrior = false,
    Wizard = false
}

local Colors = {
    b = "\ab",  -- black
    B = "\a-b", -- black (dark)

    g = "\ag",  -- green
    G = "\a-g", -- green (dark)

    m = "\am",  -- magenta
    M = "\a-m", -- magenta (dark)

    o = "\ao",  -- orange
    O = "\a-o", -- orange (dark)

    p = "\ap",  -- purple
    P = "\a-p", -- purple (dark)

    r = "\ar",  -- red
    R = "\a-r", -- red (dark)

    t = "\at",  -- cyan
    T = "\a-t", -- cyan (dark)

    u = "\au",  -- blue
    U = "\a-u", -- blue (dark)

    w = "\aw",  -- white
    W = "\a-w", -- white (dark)

    y = "\ay",  -- yellow
    Y = "\a-y", -- yellow (dark)

    x = "\ax"   -- previous color
}

function CONSOLEMETHOD(consoleMessage, ...)
    if RB.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function PRINTMETHOD(printMessage, ...)
    printf(Colors.u .. "[Rebirth Machine]" .. Colors.w .. printMessage .. "\aC\n", ...)
end

local function event_rebirth_handler(line, rebirths)
    CONSOLEMETHOD('function event_rebirth_handler(line, rebirths)')
    RB.CurrentRebirths = tonumber(rebirths)
    if RB.CurrentRebirths >= RB.rebirthStopAt then
        if mq.TLO.Zone.ID() ~= RB.hubZoneID then mq.cmdf('/say #zone %s', RB.hubZoneID) end
        mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.hubZoneID end)
        mq.delay(RB.wait_One)
        mq.cmd('/lua stop RebirthMachine')
    end
end
mq.event('RebirthLevel', "#*# whispers, 'You have rebirthed #1# times!'", event_rebirth_handler)
mq.event('RebirthLevel2', "You have rebirthed #1# times!'", event_rebirth_handler)
mq.event('RebirthLevelExp', "Rebirth Penalty: #1# rebirths = #*#", event_rebirth_handler)
mq.event('RebirthLevel20', 'Congratulations on your #1#th rebirth! You have been granted #*# Mastery AA!',
    event_rebirth_handler)

local function event_instance_handler(line, minutes)
    CONSOLEMETHOD('function event_instance_handler(line, minutes)')
    local minutesLeft = tonumber(minutes)
    if minutesLeft >= RB.reset_Instance_At then
        if mq.TLO.Zone.ID() ~= RB.hubZoneID then mq.cmdf('/say #zone %s', RB.hubZoneID) end
        mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.hubZoneID end)
        mq.delay(RB.wait_One)
        mq.cmd('/dzq')
        if mq.TLO.DynamicZone() ~= nil then
            mq.cmd('/dzq')
            mq.delay(RB.wait_One)
            mq.cmdf('/say #create solo %s', RB.huntZoneName)
            mq.delay(RB.wait_Two)
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZoneID end)
        else
            mq.cmdf('/say #create solo %s', RB.huntZoneName)
            mq.delay(RB.wait_Two)
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZoneID end)
        end
    end
end
mq.event('InstanceCheck', "You only have #1# minutes remaining before this expedition comes to an end.",
    event_instance_handler)

function RB.CheckBuffs()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    if RB.UseClassAA['Warrior'] and not mq.TLO.Me.Buff('Defensive Disc').ID() then
        mq.cmdf('/alt act %s', RB.ClassAAs['Warrior'])
        mq.delay(RB.wait_One)
    end

    if mq.TLO.Me.Buff(RB.BuffCheckName).ID() == nil and mq.TLO.Me.ItemReady(RB.buffItem)() then
        mq.cmdf('/useitem %s', RB.buffItem)
        mq.delay(RB.wait_One)
    end
end

function RB.CheckLevel()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    if mq.TLO.Me.Level() >= 80 then
        mq.delay(RB.wait_Four)
        mq.cmd('/say #rebirth')
        mq.delay(RB.wait_Three)
        mq.cmd('/say #deletecorpse')
        mq.delay(RB.rebirth_Wait)
        mq.cmd('/target npc')
        mq.delay(RB.wait_Four)
        mq.cmd('/squelch /face fast')
        mq.delay(RB.wait_Four)
        if not mq.TLO.Me.Combat() then
            if mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.ID() ~= nil then
                mq.cmd('/target npc')
                mq.delay(RB.wait_One)
            end
            mq.cmd('/squelch /attack on')
            mq.delay(RB.wait_Four)
        end
        mq.delay(RB.wait_Four)
        RB.CheckBuffs()
    end
end

function RB.CheckLocation()
    if mq.TLO.Zone.ID() == RB.huntZoneID and RB.staticHuntMode then
        pcall(RB.MoveToStaticSpot)
    end
end

function RB.MoveToStaticSpot()
    if mq.TLO.Zone.ID() == RB.huntZoneID then
        if RB.CheckDistanceToXYZ() > RB.returnHomeDistance then
            mq.cmdf('/warp loc %s %s %s', RB.huntStaticY, RB.huntStaticX, RB.huntStaticZ)
            mq.delay(RB.wait_One)
        end
    end
end

function RB.CheckDistanceToXYZ()
    local deltaX = RB.huntStaticX - mq.TLO.Me.X()
    local deltaY = RB.huntStaticY - mq.TLO.Me.Y()
    local deltaZ = RB.huntStaticZ - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function RB.CheckZone()
    if mq.TLO.Zone.ID() ~= RB.huntZoneID then
        if mq.TLO.DynamicZone() ~= nil then
            mq.cmdf('/say #enter')
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZoneID end)
            mq.delay(RB.wait_Four)
            mq.cmd('/say #deletecorpse')
            mq.delay(RB.wait_Two)
            pcall(RB.CheckLocation)
        else
            mq.cmdf('/say #create solo %s', RB.huntZoneName)
            mq.delay(RB.wait_One)
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZoneID end)
            mq.delay(RB.wait_Four)
            pcall(RB.CheckLocation)
        end
    end
end

function RB.InstanceFlip()
    PRINTMETHOD('Moving to next instance!')
    mq.cmd('/dzq')
    if mq.TLO.DynamicZone() ~= nil then
        mq.cmd('/dzq')
        mq.delay(RB.wait_One)
        mq.cmdf('/say #create solo %s', RB.huntZoneName)
        mq.delay(RB.wait_Two)
        mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZoneID end)
        mq.delay(RB.wait_One)
    else
        mq.cmdf('/say #create solo %s', RB.huntZoneName)
        mq.delay(RB.wait_Two)
        mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZoneID end)
        mq.delay(RB.wait_One)
    end
end

function RB.AggroAllMobs()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    if mq.TLO.Zone.ID() == RB.huntZoneID then
        if RB.staticHuntMode then
            mq.cmdf('/warp loc %s %s %s', RB.huntStaticY, RB.huntStaticX, RB.huntStaticZ)
            mq.delay(RB.wait_One)
        end
        mq.cmd('/target myself')
        mq.delay(RB.wait_One)
        mq.cmdf('/useitem %s', RB.zonePull)
        mq.delay(RB.wait_One)
        if RB.staticHuntMode then
            mq.cmdf('/warp loc %s %s %s', RB.huntStaticY_Pull, RB.huntStaticX, RB.huntStaticZ)
            mq.delay(RB.wait_One)
            mq.cmdf('/squelch /face fast %s,%s', RB.huntStaticY, RB.huntStaticX)
            mq.delay(RB.wait_One)
            mq.cmd('/target npc')
            mq.delay(RB.wait_One)
            if not mq.TLO.Me.Combat() then
                if mq.TLO.Target.ID() == nil or mq.TLO.Target.ID() == mq.TLO.Me.ID() then
                    mq.cmd('/target npc')
                    mq.delay(RB.wait_One)
                end
                mq.cmd('/squelch /attack on')
                mq.delay(RB.wait_One)
            end
        end
    end
end

function RB.RespawnAllMobs()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    if mq.TLO.Zone.ID() == RB.huntZoneID then
        if mq.TLO.Me.ItemReady(RB.zoneRefresh)() then
            if mq.TLO.SpawnCount('npc')() < RB.reset_At_Mob_Count then
                mq.cmdf('/useitem %s', RB.zoneRefresh)
                mq.delay(RB.wait_Two)
                RB.AggroAllMobs()
                mq.delay(RB.wait_Two)
            end
        else
            if RB.instanceFlipper then
                if mq.TLO.SpawnCount('npc')() < RB.reset_At_Mob_Count then
                    RB.InstanceFlip()
                    RB.CheckLocation()
                    mq.delay(RB.wait_Two)
                    RB.AggroAllMobs()
                    mq.delay(RB.wait_Two)
                end
            end
        end
    end
end

function RB.KillAllMobs()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    while mq.TLO.SpawnCount(RB.spawnSearch:format('npc ', RB.aggro_Radius, RB.aggro_zRadius))() > RB.reset_At_Mob_Count do
        if not mq.TLO.Me.Combat() then
            if mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.ID() ~= nil or mq.TLO.Target.Distance() > RB.returnHomeDistance then
                mq.cmd('/target npc')
                mq.delay(RB.wait_One)
                if mq.TLO.Target.Name() == RB.ignoreTarget then return end
            end
            mq.cmd('/squelch /attack on')
            mq.delay(RB.wait_One)
            mq.cmd('/squelch /face fast')
            mq.delay(RB.wait_One)
            local lastTargID = mq.TLO.Target.ID()
            while mq.TLO.Spawn(lastTargID)() ~= nil and not mq.TLO.Spawn(lastTargID).Dead() and mq.TLO.Target.ID() ~= nil and mq.TLO.Spawn(lastTargID).Distance() <= RB.returnHomeDistance do
                if mq.TLO.Spawn(lastTargID)() ~= nil and not mq.TLO.Spawn(lastTargID).Dead() then
                    if mq.TLO.Spawn(lastTargID).Distance() >= RB.returnHomeDistance then
                        mq.cmd('/target npc')
                    else
                        mq.cmdf('/target id %s', lastTargID)
                        mq.delay(RB.wait_One)
                    end
                end
                RB.CheckZone()
                if mq.TLO.Target.ID() == nil or (mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.Distance() > RB.returnHomeDistance) then
                    mq.cmd('/target npc')
                    mq.delay(RB.wait_One)
                end
                if not RB.staticHuntMode then RB.MoveTarg() end
                if RB.castSpells then
                    for i, spell in ipairs(RB.spells) do
                        if mq.TLO.Spell(spell).Name() then
                            mq.cmdf('/casting "%s"', spell)
                            mq.delay(RB.wait_Three)
                        end
                    end
                end
                mq.delay(RB.wait_One)
            end
        end
    end
end

function RB.Main()
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Sequence: Taunt Morzain initiated ++')
    CONSOLEMETHOD('Main Loop Entry')
    PRINTMETHOD('Putting MQ2Melee into basic melee mode.')
    mq.cmd('/melee melee=on stickmode=off stickrange=75 save')
    mq.doevents()
    while not RB.Terminate do
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
            RB.Terminate = false
            return
        end
        pcall(RB.CheckLevel)
        pcall(RB.CheckZone)
        pcall(RB.CheckBuffs)
        pcall(RB.RespawnAllMobs)
        pcall(RB.AggroAllMobs)
        pcall(RB.KillAllMobs)
        mq.doevents()
    end
    CONSOLEMETHOD('Main Loop Exit')
end

RB.Main()

return RB
