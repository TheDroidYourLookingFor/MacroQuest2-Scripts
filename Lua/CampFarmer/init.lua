local mq = require('mq')

local CampFarmer = {
    debug = false,
    loop = true,
    startX = mq.TLO.Me.X(),
    startY = mq.TLO.Me.Y(),
    startZ = mq.TLO.Me.Z(),
    startZone = mq.TLO.Zone.ID(),
    startZoneName = mq.TLO.Zone.ShortName()
}

CampFarmer.DelayTimes = {
    One = 250,
    Two = 500,
    Three = 750,
    Four = 1000,
    Five = 1500,
    Six = 2000
}

CampFarmer.Settings = {
    IgnoreListNum = 1,
    PriorityListNum = 2,
    MinMobsInZone = 10,
    warpToMobDistance = 5,
    returnToCampDistance = 200,
    goblinSearch = 'npc alert 2',
    spawnSearch = "npc radius 60 los targetable noalert 1",
    mobsSearch = "npc targetable noalert 1",
    aggroItem = "Charm of Hate",
    respawnItem = "Charm of Refreshing",
    ClickAATokens = true,
}

CampFarmer.IgnoreList = {
    "Gillamina Garstobidokis",
    "an ornate chest",
    "${Me.CleanName}'s Pet",
    "${Me.CleanName}",
    "Cruel Illusion",
    "lockout ikkinz",
    "Kilidna",
    "Pixtt Grand Summoner",
    "Kevren Nalavat",
    "Kenra Kalekkio",
    "Pixtt Nemis",
    "Undari Perunea",
    "Sentinel of the Altar",
    "Retharg",
    "Siska the Spumed",
    "a shark",
    "The ground"
}

CampFarmer.PriorityList = {
    "Cash Treasure Goblin",
    "Platinum Treasure Goblin",
    "Augment Treasure Goblin",
    "Paper Treasure Goblin",
    "Raging Treasure Goblin",
    "Treasure Goblin"
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
    if CampFarmer.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function PRINTMETHOD(printMessage, ...)
    printf(Colors.u .. "[Camp Farmer]" .. Colors.w .. printMessage .. "\aC\n", ...)
end

function CheckPetButton(numButton, buttonText, stateWanted)
    local buttonName = string.format("Pet%d_Button", numButton)
    -- Check if the button text matches the expected buttonText
    if mq.TLO.Window("PetInfoWindow").Child(buttonName).Text() == buttonText then
        -- Check if the button state does not match the desired state
        if mq.TLO.Window("PetInfoWindow").Child(buttonName).Checked() ~= stateWanted then
            -- Trigger a left mouse click on the button
            mq.cmdf("/notify PetInfoWindow %s leftmouseup", buttonName)
        end
    end
end

function CheckPetAoE()
    -- Check if the Pet Info window is open
    if mq.TLO.Window("PetInfoWindow").Open() then
        for x = 0, 10 do
            CheckPetButton(x, "hold", 0)
            CheckPetButton(x, "focus", 1)
            -- CheckPetButton(x, "taunt", 0) -- Uncomment if needed
        end
    end
end

function CampFarmer.CheckDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function CampFarmer.CombatSpells()
    if not mq.TLO.Me.Buff('Shad\'s Warts').ID() and mq.TLO.Me.AltAbilityReady(33905)() then mq.cmdf('/alt act %s', 33905) end
    if not mq.TLO.Me.Buff('Mystereon\'s Prismatic Rune').ID() and mq.TLO.Me.AltAbilityReady(39912)() then
        mq.cmdf(
            '/alt act %s', 39912)
    end
    if not mq.TLO.Me.Buff('Monk Mastery of A Thousand Fists').ID() and mq.TLO.Me.AltAbilityReady(39907)() then
        mq.cmdf(
            '/alt act %s', 39907)
    end
    if mq.TLO.Me.AltAbilityReady(39911)() then mq.cmdf('/alt act %s', 39911) end
    if mq.TLO.Me.AltAbilityReady(39909)() then mq.cmdf('/alt act %s', 39909) end
    if mq.TLO.Me.AltAbilityReady(39916)() then mq.cmdf('/alt act %s', 39916) end
    if mq.TLO.Me.AltAbilityReady(39908)() then mq.cmdf('/alt act %s', 39908) end
    if mq.TLO.Me.AltAbilityReady(39904)() then mq.cmdf('/alt act %s', 39904) end
    if mq.TLO.FindItemCount('Potion of Adventure II')() > 0 and not mq.TLO.Me.Buff('Potion of Adventure II').ID() then
        mq
            .cmdf('/useitem %s', 'Potion of Adventure II')
    end
    if mq.TLO.FindItemCount('Amulet of Ultimate Buffing')() > 0 and not mq.TLO.Me.Buff('Talisman of the Panther Rk. III').ID() then
        mq.cmdf('/itemnotify charm rightmouseup')
    end
    if mq.TLO.Me.Casting() and mq.TLO.Me.Buff('Spikecoat').Duration.Ticks() <= 59 then
        mq.cmdf('/useitem %s', mq.TLO.FindItem('living thorns').Name())
        mq.delay(250)
    end
    if mq.TLO.Target.Type() == 'NPC' and (mq.TLO.Me.Class.ShortName() == 'WIZ' or mq.TLO.Me.Class.ShortName() == 'MAG') and not mq.TLO.Me.Stunned() then
        mq.cmdf('/casting %s', 'Fires of Lorelahna')
        mq.delay(250)
    end
    if mq.TLO.Target.Type() == 'NPC' and mq.TLO.Me.Class.ShortName() == 'NEC' and not mq.TLO.Me.Stunned() then
        mq.cmdf('/casting %s', 'Drucilog\'s Virulent Poison Rk. I')
        mq.delay(250)
    end
    if mq.TLO.Target.Type() == 'NPC' and mq.TLO.Me.Class.ShortName() == 'WIZ' and not mq.TLO.Me.Stunned() then
        mq.cmdf('/casting %s', 'Flame Lick')
        mq.delay(250)
    end
end

function CampFarmer.Kill()
    mq.cmd('/squelch /attack on')
    mq.delay(CampFarmer.DelayTimes.One)
    mq.cmd('/squelch /face fast')
    mq.delay(CampFarmer.DelayTimes.One)
    if mq.TLO.Me.Combat() and mq.TLO.Me.Pet.ID() and not mq.TLO.Me.Pet.Combat() then
        mq.cmd('/pet attack')
        mq.delay(CampFarmer.DelayTimes.One)
    end
    CampFarmer.CombatSpells()
end

function CampFarmer.RespawnZone()
    if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() > CampFarmer.Settings.MinMobsInZone then return end
    if not mq.TLO.Me.ItemReady(CampFarmer.Settings.respawnItem)() then return end
    mq.cmdf('/useitem %s', CampFarmer.Settings.respawnItem)
    mq.delay(CampFarmer.DelayTimes.Two)
end

function CampFarmer.AggroZone()
    if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() <= CampFarmer.Settings.MinMobsInZone then return end
    mq.cmd('/target myself')
    mq.delay(CampFarmer.DelayTimes.Four, function() return mq.TLO.Target.ID()() == mq.TLO.Me.ID()() end)
    mq.cmdf('/useitem %s', CampFarmer.Settings.aggroItem)
    mq.delay(CampFarmer.DelayTimes.Two)
end

function CampFarmer.CheckForGoblins()
    if mq.TLO.SpawnCount(CampFarmer.Settings.goblinSearch)() > 0 then
        mq.cmdf('/target id %s', mq.TLO.Spawn(CampFarmer.Settings.goblinSearch).ID())
        mq.delay(250)
        if mq.TLO.Target() and mq.TLO.Target.Distance() > CampFarmer.Settings.warpToMobDistance and mq.TLO.Target.CleanName() ~= 'Raging Treasure Goblin' then
            mq.cmd('/warp t')
            mq.delay(250)
            CampFarmer.Kill()
        end
        if mq.TLO.Me.AltAbilityReady(33911)() then
            mq.cmdf('/alt act %s', 39911)
            mq.delay(250)
        end
        if mq.TLO.Me.AltAbilityReady(33914)() then
            mq.cmdf('/alt act %s', 39914)
            mq.delay(250)
        end
    end
end

function CampFarmer.CheckZone()
    if mq.TLO.Zone.ID() ~= CampFarmer.startZone and mq.TLO.DynamicZone() ~= nil then
        mq.cmd('/say #enter')
        mq.delay(50000, function() return mq.TLO.Zone.ID()() == CampFarmer.startZone end)
        mq.delay(1000)
        mq.TLO.DynamicZone.Name()
    elseif mq.TLO.Zone.ID() ~= CampFarmer.startZone and mq.TLO.DynamicZone() == nil then
        mq.cmdf('/say #create solo %s', CampFarmer.startZoneName)
        mq.delay(50000, function() return mq.TLO.Zone.ID()() == CampFarmer.startZone end)
        mq.delay(1000)
    end
end

function CampFarmer.HideCorpses()
    if mq.TLO.SpawnCount('corpse')() > 100 then
        mq.cmdf('%s', '/hidecorpse all')
        mq.delay(CampFarmer.DelayTimes.One)
    end
end

function CampFarmer.UseAATokens()
    if CampFarmer.Settings.ClickAATokens and mq.TLO.FindItemCount('Token of Advancement')() then
        mq.cmdf('/useitem %s', mq.TLO.FindItem('Token of Advancement').Name())
        mq.delay(CampFarmer.DelayTimes.One)
    end
end

function CampFarmer.CheckCamp()
    if CampFarmer.CheckDistance(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z()) > CampFarmer.Settings.returnToCampDistance then
        mq.cmdf('/warp loc %s %s %s', CampFarmer.Settings.startY, CampFarmer.Settings.startX, CampFarmer.Settings.startZ)
        mq.delay(CampFarmer.DelayTimes.One)
    end
end

function CampFarmer.FarmMobs()
    if mq.TLO.SpawnCount(CampFarmer.Settings.goblinSearch)() > 0 then return end
    if mq.TLO.SpawnCount(CampFarmer.Settings.spawnSearch)() > 0 then
        mq.cmdf('/target id %s', mq.TLO.Spawn(CampFarmer.Settings.spawnSearch).ID())
        mq.delay(250)
        if mq.TLO.Target() and mq.TLO.Target.Distance() > CampFarmer.Settings.warpToMobDistance and mq.TLO.Target.CleanName() ~= 'Raging Treasure Goblin' then
            mq.cmd('/warp t')
            mq.delay(250)
            CampFarmer.Kill()
        end
    else
        CampFarmer.AggroZone()
    end
end

function CampFarmer.Checks()
    CampFarmer.CheckZone()
    CampFarmer.CheckCamp()
    CampFarmer.HideCorpses()
    if mq.TLO.SpawnCount(CampFarmer.Settings.mobsSearch)() <= CampFarmer.Settings.MinMobsInZone then CampFarmer.RespawnZone() end
    if mq.TLO.Me.XTarget() == 0 then CampFarmer.AggroZone() end
    CampFarmer.FarmMobs()
    CampFarmer.CheckForGoblins()
    CampFarmer.UseAATokens()
end

local function event_refreshInstance_handler(line, minutes)
    CONSOLEMETHOD('function event_refreshInstance_handler(line, rebirths)')
    local minutesLeft = tonumber(minutes)
    if minutesLeft <= 5 then
        mq.cmdf('%s', '/dgga /dzq')
        mq.delay(250)
        mq.cmdf('/say #create solo %s', CampFarmer.startZoneName)
        mq.delay(50000, function() return mq.TLO.Zone.ID()() == CampFarmer.startZone end)
        mq.delay(1000)
        mq.cmdf('%s','/dgge /say #enter')
        mq.delay(250)
    end
end
mq.event('RefreshInstance', "You only have #1# minutes remaining before this expedition comes to an end.", event_refreshInstance_handler)

function CampFarmer.Main()
    PRINTMETHOD('++ Starting Up ++')

    PRINTMETHOD('++ Setting up Ignore List ++')
    mq.cmdf('/squelch /alert clear %s', 1)
    for _, name in ipairs(CampFarmer.IgnoreList) do
        mq.cmdf('/squelch /alert add 1 "%s"', name)
        mq.delay(50)
    end
    PRINTMETHOD('++ Setting up Priority List ++')
    mq.cmdf('/squelch /alert clear %s', 2)
    for _, name in ipairs(CampFarmer.PriorityList) do
        mq.cmdf('/squelch /alert add 2 "%s"', name)
        mq.delay(50)
    end

    PRINTMETHOD('++ Starting Main Loop ++')
    while CampFarmer.loop do
        CampFarmer.Checks()
        mq.delay(100)
    end
end

CampFarmer.Main()
