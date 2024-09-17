local mq = require('mq')

--
-- Dont edit these settings
--
local RB = {
    version = '1.0.1',
    debug = false,
    Terminate = false,
    CurrentRebirths = 0,
    mob_Wait = 50000,
    zone_Wait = 50000,
    rebirth_Wait = 2500,
    wait_One = 500,
    wait_Two = 750,
    wait_Three = 1000,
    wait_Four = 250,
    reset_Instance_At = 5,
    spawnSearch = '%s radius %d zradius %d',
}

--
-- Edit these settings
--
RB.Settings = {
    staticHuntMode = true,                                                              -- Should we camp a spot and kill or move around?
    huntZoneName = 'pofire',                                                            -- Where should we kill?
    rebirthStopAt = 20,                                                                 -- After how many Rebirths should we stop?
    reset_At_Mob_Count = 10,                                                            -- How few mobs in the zone should cause a repop?
    aggro_Radius = 75,                                                                  -- How far around our camp should we look for mobs
    aggro_zRadius = 25,                                                                 -- Same but Z axis
    returnHomeDistance = 50,                                                            -- How far away from camp should we get before returning
    warpToMobDistance = 25,                                                             -- How coulse to warp to a mob?
    hideCorpses = true,                                                                 -- Should we hide corpses?
    --corpse_Phrase = '/say #deletecorpse',                                                  -- The commands we should use to hide corpses.
    corpse_Phrase = '/hidecorpse all',                                                  -- The commands we should use to hide corpses.
    castSpells = false,                                                                 -- Should we cast spells?
    spells = { 'My Awesome Pew Pew Spell', 'My Other Awesome Pew Pew Spell Rk. 9001' }, -- Which spells should we cast? Put as many as you want
    buffItem = 'Amulet of Ultimate Buffing',                                            -- Name of the item that gives us buff
    BuffCheckName = 'Hand of Conviction',                                               -- The name of the buff we should be checking to see if buffItem worked
    useXP_Potions = false,                                                              -- Should we consume XP potions?
    XPPotionName = 'Potion of Adventure II',                                            -- What is the name of the XP Potion?
    XPPotionBuff = 'Potion of Adventure II',                                            -- What is the name of the XP Potion Buff?
    zoneRefresh = 'Charm of Refreshing',                                                -- Name of the item we use to refresh the zone
    moveOnPull = true,                                                                  -- Should we move automatically when we pull away from the mob stack?
    -- zonePull = 'Charm of Hate',                                                        -- Name of the item we use to mass aggro
    zonePull = 'Derekthomx\'s Horrorkrunk Hook',                                        -- Name of the item we use to mass aggro
    hubZoneID = 451                                                                     -- Zone ID of our hub zone
}

RB.AltToons = {
    Binli = {
        UseRepop = false,
        UseRefresh = false
    }
}

RB.huntZone = {
    paw = {
        ID = 18,
        X = 42.53,
        Y = 718.35,
        Y_Pull = 700,
        Z = 4.12,
        ignoreTarget = 'an imprisoned gnoll'
    },
    pofire = {
        ID = 217,
        X = 612.22,
        Y = 657.17,
        Y_Pull = 627.17,
        Z = -166.87,
        ignoreTarget = 'Essence of Fire'
    },
    maiden = {
        ID = 173,
        X = 1426,
        Y = 955,
        Y_Pull = 925,
        Z = -152,
        ignoreTarget = ''
    }
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
    Bard = true,
    Beastlord = true,
    Berserker = true,
    Cleric = true,
    Druid = true,
    Enchanter = true,
    Magician = true,
    Monk = true,
    Necromancer = true,
    Paladin = true,
    Ranger = true,
    Rogue = true,
    Shadowknight = true,
    Shaman = true,
    Warrior = true,
    Wizard = true
}
--
-- Stop editing! :D You know unless you really want to and know what you're doing
--

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
    if RB.CurrentRebirths >= RB.Settings.rebirthStopAt then
        if mq.TLO.Zone.ID() ~= RB.Settings.HubZoneID then mq.cmdf('/say #zone %s', RB.Settings.HubZoneID) end
        mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.Settings.HubZoneID end)
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
        if mq.TLO.Zone.ID() ~= RB.Settings.HubZoneID then mq.cmdf('/say #zone %s', RB.Settings.HubZoneID) end
        mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.Settings.HubZoneID end)
        mq.delay(RB.wait_One)
        mq.cmd('/dzq')
        if mq.TLO.DynamicZone() ~= nil then
            mq.cmd('/dzq')
            mq.delay(RB.wait_One)
            mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
            mq.delay(RB.wait_Two)
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID end)
        else
            mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
            mq.delay(RB.wait_Two)
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID end)
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
    if not mq.TLO.Me.Buff(RB.Settings.XPPotionBuff).ID() then
        mq.cmdf('/useitem "%s"', RB.Settings.XPPotionName)
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Shadowknight'] and not mq.TLO.Me.Buff('Shad\'s Warts').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Shadowknight']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Shadowknight'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Warrior'] and not mq.TLO.Me.Buff('Defensive Disc').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Warrior']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Warrior'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Wizard'] and not mq.TLO.Me.Buff('Mystereon\'s Prismatic Rune').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Wizard']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Wizard'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Bard'] and not mq.TLO.Me.Buff('Bard Mastery Greatest In The World').ID() and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Bard']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Bard'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Enchanter'] and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Enchanter']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Enchanter'])
        mq.delay(RB.wait_One)
    end
    if mq.TLO.Me.Buff(RB.Settings.BuffCheckName).ID() == nil and mq.TLO.Me.ItemReady(RB.Settings.buffItem)() then
        mq.cmdf('/useitem %s', RB.Settings.buffItem)
        mq.delay(RB.wait_One)
    end
end

function RB.UseClassCombatAAs()
    if RB.UseClassAA['Rogue'] and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Rogue']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Rogue'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Berseker'] and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Berseker']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Berseker'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Shaman'] and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Shaman']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Shaman'])
        mq.delay(RB.wait_One)
    end
    if RB.UseClassAA['Necromancer'] and mq.TLO.Me.AltAbilityReady(RB.ClassAAs['Necromancer']) then
        mq.cmdf('/alt act %s', RB.ClassAAs['Necromancer'])
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
        if RB.Settings.hideCorpses then
            mq.cmdf('%s', RB.Settings.corpse_Phrase)
            mq.delay(RB.wait_Four)
        end
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
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID and RB.Settings.staticHuntMode then
        pcall(RB.MoveToStaticSpot)
    end
end

function RB.MoveToStaticSpot()
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
        if RB.CheckDistanceToXYZ() > RB.Settings.returnHomeDistance then
            mq.cmdf('/warp loc %s %s %s', RB.huntZone[RB.Settings.huntZoneName].Y,
            RB.huntZone[RB.Settings.huntZoneName].X,
                RB.huntZone[RB.Settings.huntZoneName].Z)
            mq.delay(RB.wait_One)
        end
    end
end

function RB.CheckDistanceToXYZ()
    local deltaX = RB.huntZone[RB.Settings.huntZoneName].X - mq.TLO.Me.X()
    local deltaY = RB.huntZone[RB.Settings.huntZoneName].Y - mq.TLO.Me.Y()
    local deltaZ = RB.huntZone[RB.Settings.huntZoneName].Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function RB.CheckZone()
    if mq.TLO.Zone.ID() ~= RB.huntZone[RB.Settings.huntZoneName].ID then
        if mq.TLO.DynamicZone() ~= nil then
            mq.cmdf('/say #enter')
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID end)
            mq.delay(RB.wait_Four)
            if RB.Settings.hideCorpses then
                mq.cmdf('%s', RB.Settings.corpse_Phrase)
                mq.delay(RB.wait_Four)
            end
            pcall(RB.CheckLocation)
        else
            mq.cmdf('/say #create solo %s', RB.Settings.huntZoneName)
            mq.delay(RB.wait_One)
            mq.delay(RB.zone_Wait, function() return mq.TLO.Zone.ID()() == RB.huntZone[RB.Settings.huntZoneName].ID end)
            mq.delay(RB.wait_Four)
            pcall(RB.CheckLocation)
        end
    end
end

function RB.AggroAllMobs()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID then
        PRINTMETHOD('++ Attempting to Aggro the Zone ++')
        if RB.Settings.hideCorpses then
            mq.cmdf('%s', RB.Settings.corpse_Phrase)
            mq.delay(RB.wait_Four)
        end
        if RB.Settings.moveOnPull and RB.Settings.staticHuntMode then
            mq.cmdf('/warp loc %s %s %s', RB.huntZone[RB.Settings.huntZoneName].Y, RB.huntZone[RB.Settings.huntZoneName].X,
                RB.huntZone[RB.Settings.huntZoneName].Z)
            mq.delay(RB.wait_One)
        end
        mq.cmd('/target myself')
        mq.delay(RB.wait_Two)
        mq.cmdf('/useitem %s', RB.Settings.zonePull)
        mq.delay(RB.wait_Two)
        if RB.Settings.moveOnPull and RB.Settings.staticHuntMode then
            mq.cmdf('/warp loc %s %s %s', RB.huntZone[RB.Settings.huntZoneName].Y_Pull, RB.huntZone[RB.Settings.huntZoneName].X,
                RB.huntZone[RB.Settings.huntZoneName].Z)
            mq.delay(RB.wait_One)
            mq.cmdf('/squelch /face fast %s,%s', RB.huntZone[RB.Settings.huntZoneName].Y, RB.huntZone[RB.Settings.huntZoneName].X)
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
    if mq.TLO.Zone.ID() == RB.huntZone[RB.Settings.huntZoneName].ID and mq.TLO.Me.ItemReady(RB.Settings.zoneRefresh)() and mq.TLO.SpawnCount('npc')() < RB.Settings.reset_At_Mob_Count then
        PRINTMETHOD('++ Attempting to Respawn the Zone ++')
        mq.cmdf('/useitem %s', RB.Settings.zoneRefresh)
        mq.delay(RB.wait_Two)
        RB.AggroAllMobs()
        mq.delay(RB.wait_Two)
        if RB.Settings.hideCorpses then
            mq.cmdf('%s', RB.Settings.corpse_Phrase)
            mq.delay(RB.wait_Four)
        end
    end
end

function RB.KillAllMobs()
    if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
        RB.Terminate = false
        return
    end
    pcall(RB.RespawnAllMobs)
    if mq.TLO.Me.XTarget() <= RB.Settings.reset_At_Mob_Count and mq.TLO.SpawnCount('npc')() >= RB.Settings.reset_At_Mob_Count then
        RB.AggroAllMobs()
    end
    while mq.TLO.SpawnCount(RB.spawnSearch:format('npc ', RB.Settings.aggro_Radius, RB.Settings.aggro_zRadius))() > 0 do
        RB.Checks()
        if mq.TLO.Me.XTarget() <= RB.Settings.reset_At_Mob_Count then
            RB.AggroAllMobs()
            return
        end
        if not mq.TLO.Target.ID() or mq.TLO.Target.ID() == mq.TLO.Me.ID() or mq.TLO.Target.Distance() > RB.Settings.returnHomeDistance then
            mq.cmd('/target npc')
            mq.delay(RB.wait_Four)
            if mq.TLO.Target.Name() == RB.huntZone[RB.Settings.huntZoneName].ignoreTarget then return end
        end
        if mq.TLO.Target.Distance() >= RB.Settings.returnHomeDistance then
            mq.cmd('/target clear')
            return
        end
        while mq.TLO.Target.ID() and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() and mq.TLO.Target.Distance() <= RB.Settings.returnHomeDistance and not mq.TLO.Spawn(mq.TLO.Target.ID()).Dead() do
            RB.Checks()
            if not mq.TLO.Me.Combat() then
                mq.cmd('/squelch /attack on')
                mq.delay(RB.wait_Four)
                mq.cmd('/squelch /face fast')
                mq.delay(RB.wait_Four)
            end
            if not RB.Settings.staticHuntMode then RB.MoveTarg() end
            RB.UseClassCombatAAs()
            if RB.Settings.castSpells then
                for i, spell in ipairs(RB.Settings.spells) do
                    if mq.TLO.Spell(spell).Name() then
                        mq.cmdf('/casting "%s"', spell)
                        mq.delay(RB.wait_Four)
                    end
                end
                mq.delay(RB.wait_Four)
            end
            mq.delay(RB.wait_Four)
        end
        mq.delay(RB.wait_Four)
    end
end

function RB.Checks()
    pcall(RB.CheckLevel)
    pcall(RB.CheckZone)
    pcall(RB.CheckBuffs)
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
        RB.Checks()
        pcall(RB.KillAllMobs)
        mq.doevents()
    end
    CONSOLEMETHOD('Main Loop Exit')
end

RB.Main()

return RB
