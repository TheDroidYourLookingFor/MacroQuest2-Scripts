local mq = require('mq')

ChaosGrind = {
    _version = '1.0.1',
    _author = 'TheDroidUrLookingFor'
}
ChaosGrind.GUI = require('ChaosGrind.lib.Gui')
ChaosGrind.Storage = require('ChaosGrind.lib.Storage')
ChaosGrind.settingsFile = mq.configDir .. '\\ChaosGrind.' .. mq.TLO.Me.CleanName() .. '.ini'
ChaosGrind.Settings = {}
ChaosGrind.Settings.Version = ChaosGrind._version
ChaosGrind.Settings.DoStatTrack = true
ChaosGrind.Settings.script_ShortName = 'ChaosGrind'
ChaosGrind.Settings.command_ShortName = 'cg'
ChaosGrind.Settings.command_LongName = 'ChaosGrind'
ChaosGrind.Settings.OriginItem = 'Chaotic Token of Return'
ChaosGrind.Settings.MainLoopDelay = 100
ChaosGrind.Settings.ChatDelay = 1000
ChaosGrind.Settings.ZoneDelay = 30000
ChaosGrind.Settings.UseWarp = true
ChaosGrind.Settings.WarpBeforeStart = true
ChaosGrind.Settings.InstanceNPC = 'Eldrin'
ChaosGrind.Settings.HubZone = 998

ChaosGrind.Settings.LifetapItem = 'Crazok\'s Talking Eartackle'
ChaosGrind.Settings.LifetapAt = 99
ChaosGrind.Settings.UseLifetapItem = true

ChaosGrind.Settings.PBAoEItem = 'Tanza the Crystal-Bound'
ChaosGrind.Settings.PBAoEAt = 99
ChaosGrind.Settings.UsePBAoEItem = true

ChaosGrind.Settings.NukeItem = 'Stalwart Sagacious Helm'
ChaosGrind.Settings.NukeAt = 99
ChaosGrind.Settings.UseNukeItem = true

ChaosGrind.Settings.GroupHealItem = 'Mythic Minli`s Greaves of Stability'
ChaosGrind.Settings.GroupHealAt = 90
ChaosGrind.Settings.DoGroupHeals = true
ChaosGrind.Settings.DoSelfHeals = true

ChaosGrind.Settings.DoZonePulls = true
ChaosGrind.Settings.mobsSearch = 'npc targetable noalert 1'
ChaosGrind.Settings.aggroItem = 'Chaotic Horn of Aggro'
ChaosGrind.Settings.respawnItem = 'Chaotic Horn of Reborm'
ChaosGrind.Settings.spawnSearch = 'npc radius 60 los targetable noalert 1'
ChaosGrind.Settings.mobsSearch = 'npc targetable noalert 1'
ChaosGrind.Settings.MinMobsInZone = 10
ChaosGrind.Settings.lastRespawnUse = 0
ChaosGrind.Settings.COOLDOWN_SECONDS = 600
ChaosGrind.Settings.NewDisconnectHandler = true
ChaosGrind.Settings.HuntLuaScript = 'aqo'
ChaosGrind.Settings.HuntLuaScriptCmd1 = '/aqo pause on'
ChaosGrind.Settings.HuntLuaScriptCmd2 = '/aqo pause off'
ChaosGrind.Settings.lastMove_Cooldown = 60
ChaosGrind.Settings.lastMove = os.time()
ChaosGrind.Settings.idleTime = os.time()
ChaosGrind.Settings.lastX = mq.TLO.Me.X()
ChaosGrind.Settings.lastY = mq.TLO.Me.Y()
ChaosGrind.Settings.moveCounter = 0
ChaosGrind.Settings.RestartCounter = 600
ChaosGrind.Settings.terminate = false
ChaosGrind.Settings.doPause = true
ChaosGrind.Settings.LootCounter = 0
ChaosGrind.Settings.ChaoticCounter = 0
ChaosGrind.Settings.CursedEpicCounter = 0
ChaosGrind.Settings.ChaoticThreadCounter = 0
ChaosGrind.Settings.AugmentTokenCounter = 0
ChaosGrind.Settings.ChaoticAATokenCounter = 0
ChaosGrind.Settings.WarpToTargetDistance = 15
ChaosGrind.Settings.StartKC = 0
ChaosGrind.Settings.StartAA = 0
ChaosGrind.Settings.StartTime = os.time()
ChaosGrind.Settings.LastReportTime = os.time()
ChaosGrind.Settings.MobCounter = 0
ChaosGrind.Settings.SlainMobTypes = {}
ChaosGrind.Settings.SlainChaoticTypes = {}

ChaosGrind.Settings.GrindZone = {
    paw = {
        ID = 18,
        X = 42.53,
        Y = 718.35,
        Z = 4.12,
        Expansion = 'The Ruins of Kunark',
        ignoreTarget = 'an imprisoned gnoll'
    },
    pofire = {
        ID = 217,
        X = 612.22,
        Y = 657.17,
        Z = -166.87,
        Expansion = 'The Planes of Power',
        ignoreTarget = 'Essence of Fire'
    },
    sebilis = {
        ID = 89,
        X = 110,
        Y = -1104,
        Z = -178,
        Expansion = 'The Ruins of Kunark',
        ignoreTarget = ''
    }
}
ChaosGrind.Settings.Zone = 'pofire'
ChaosGrind.Settings.Expansion = ChaosGrind.Settings.GrindZone[ChaosGrind.Settings.Zone].Expansion
ChaosGrind.Settings.GrindZoneID = ChaosGrind.Settings.GrindZone[ChaosGrind.Settings.Zone].ID
ChaosGrind.Settings.respawnX = ChaosGrind.Settings.GrindZone[ChaosGrind.Settings.Zone].X
ChaosGrind.Settings.respawnY = ChaosGrind.Settings.GrindZone[ChaosGrind.Settings.Zone].Y
ChaosGrind.Settings.respawnZ = ChaosGrind.Settings.GrindZone[ChaosGrind.Settings.Zone].Z
ChaosGrind.Settings.startZoneName = ChaosGrind.Settings.Zone
ChaosGrind.Settings.startZone = tonumber(ChaosGrind.Settings.GrindZoneID)
ChaosGrind.Settings.startX = tonumber(ChaosGrind.Settings.respawnX)
ChaosGrind.Settings.startY = tonumber(ChaosGrind.Settings.respawnY)
ChaosGrind.Settings.startZ = tonumber(ChaosGrind.Settings.respawnZ)

function ChaosGrind.CheckCampInfo()
    ChaosGrind.Settings.startZoneName = ChaosGrind.Settings.Zone
    ChaosGrind.Settings.startZone = tonumber(ChaosGrind.Settings.GrindZoneID)
    ChaosGrind.Settings.startX = tonumber(ChaosGrind.Settings.respawnX)
    ChaosGrind.Settings.startY = tonumber(ChaosGrind.Settings.respawnY)
    ChaosGrind.Settings.startZ = tonumber(ChaosGrind.Settings.respawnZ)
end

function ChaosGrind.CheckDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

ChaosGrind.Delays = {
    One = 25,
    Two = 50,
    Three = 75,
    Four = 100,
    Five = 125,
    Six = 150,
    Seven = 200,
    Eight = 250,
    Nine = 500,
    Ten = 1000,
    Eleven = 750,
    Warp = 500,
    Repop = 1500,
    Aggro = 1500
}
local function navToID(spawnID)
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    local playerLoopDelay = 100 + playerPing
    if ChaosGrind.Settings.UseWarp and mq.TLO.Zone.ID() == ChaosGrind.Settings.GrindZoneID then
        mq.cmdf('/target id %s', spawnID)
        mq.delay(playerDelay, function() return mq.TLO.Target() ~= nil end)
        mq.cmd('/squelch /warp t')
    else
        mq.cmdf('/nav id %d log=off', spawnID)
        mq.delay(50)
        if mq.TLO.Navigation.Active() then
            local startTime = os.time()
            while mq.TLO.Navigation.Active() do
                mq.delay(playerLoopDelay)
                if os.difftime(os.time(), startTime) > 5 then
                    break
                end
            end
        end
    end
end

function ChaosGrind.goToInstanceNPC()
    if mq.TLO.Zone.ID() ~= ChaosGrind.Settings.HubZone then return end
    if not mq.TLO.Target() or (mq.TLO.Target() and mq.TLO.Target.Name() ~= ChaosGrind.Settings.InstanceNPC) then
        mq.cmdf('/target npc %s', ChaosGrind.Settings.InstanceNPC)
        mq.delay(2000, function() return mq.TLO.Target() ~= nil end)
    end
    local vendorName = mq.TLO.Target.CleanName()
    if vendorName ~= ChaosGrind.Settings.InstanceNPC then ChaosGrind.goToInstanceNPC() end
    if mq.TLO.Target.Distance() > 15 then
        if ChaosGrind.Settings.UseWarp then
            mq.cmdf('%s', '/squelch /warp t')
            local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
            local playerDelay = 500 + playerPing
            mq.delay(playerDelay)
        else
            navToID(mq.TLO.Target.ID())
        end
    end
    return true
end

local function event_chaoticCounter_handler(line, mobName)
    ChaosGrind.Settings.ChaoticCounter = (ChaosGrind.Settings.ChaoticCounter or 0) + 1
    ChaosGrind.Settings.SlainChaoticTypes[mobName] = (ChaosGrind.Settings.SlainChaoticTypes[mobName] or 0) + 1
end
mq.event('GoblinCheck', "Chaotic#1# twists into a chaotic reflection of itself!#*#", event_chaoticCounter_handler)

local function event_cursedEpicCheck_handler(line, lootName)
    -- printf('Looted: %s / Line: %s', lootName, line)
    if string.find(lootName, 'Innoruuk\'s Dark Curse') then
        ChaosGrind.Settings.CursedEpicCounter = (ChaosGrind.Settings.CursedEpicCounter or 0) + 1
    elseif string.find(lootName, 'Chaotic Augment Token') then
        ChaosGrind.Settings.AugmentTokenCounter = (ChaosGrind.Settings.AugmentTokenCounter or 0) + 1
    elseif string.find(lootName, 'Chaotic Thread') then
        ChaosGrind.Settings.ChaoticThreadCounter = (ChaosGrind.Settings.ChaoticThreadCounter or 0) + 1
    elseif string.find(lootName, 'Chaotic AA Token') then
        ChaosGrind.Settings.ChaoticAATokenCounter = (ChaosGrind.Settings.ChaoticAATokenCounter or 0) + 1
    end
    ChaosGrind.Settings.LootCounter = (ChaosGrind.Settings.LootCounter or 0) + 1
    mq.flushevents("CursedEpicCheck")
end
mq.event('CursedEpicCheck', "--You have looted #1#.--", event_cursedEpicCheck_handler)

local function event_ListExpansions_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'list expansions') then
            mq.ExecuteTextLink(link)
            mq.flushevents("ListExpansions")
            mq.delay(ChaosGrind.Settings.ChatDelay)
        end
    end
end
mq.event('ListExpansions', "#*#Eldrin whispers, 'Greetings!#*#'", event_ListExpansions_handler, { keepLinks = true })

local function event_SelectExpansion_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, ChaosGrind.Settings.Expansion) then
            mq.ExecuteTextLink(link)
            mq.flushevents("SelectExpansion")
            mq.delay(ChaosGrind.Settings.ChatDelay)
        end
    end
end
mq.event('SelectExpansion', "#*#whispers, 'Available Expansions: #*#'", event_SelectExpansion_handler, { keepLinks = true })

local function event_Selectzone_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        -- if string.find(linkText, ChaosGrind.Settings.Zone) then
        if linkText == ChaosGrind.Settings.Zone then
            mq.ExecuteTextLink(link)
            mq.flushevents("SelectZone")
            mq.delay(ChaosGrind.Settings.ChatDelay)
        end
    end
end
mq.event('SelectZone', "#*#Eldrin whispers, '#*#'", event_Selectzone_handler, { keepLinks = true })

local function event_EnterInstance_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'private instance') then
            mq.ExecuteTextLink(link)
            mq.flushevents("EnterInstance")
            mq.delay(ChaosGrind.Settings.ChatDelay)
        end
    end
end
mq.event('EnterInstance', "#*#Eldrin whispers, 'Normal port#*#'", event_EnterInstance_handler, { keepLinks = true })

local function event_InstanceExpiring_handler(line)
    mq.cmdf('/lua stop %s', ChaosGrind.Settings.HuntLuaScript)
    mq.delay(500)
    mq.cmdf('/useitem "%s"', ChaosGrind.Settings.OriginItem)
    mq.delay(ChaosGrind.Settings.ZoneDelay, function() return mq.TLO.Zone.ID() == ChaosGrind.Settings.HubZone end)
    mq.delay(50)
    ChaosGrind.goToInstanceNPC()
    mq.cmd('/say destroy instance')
    mq.delay(ChaosGrind.Settings.ChatDelay)
end
mq.event('InstanceExpire', "You only have #*# minutes remaining before this expedition comes to an end.", event_InstanceExpiring_handler)

function ChaosGrind.GetInstance()
    mq.cmd('/hail')
    mq.delay(ChaosGrind.Settings.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.Settings.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.Settings.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.Settings.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.Settings.ZoneDelay, function() return mq.TLO.Zone.ID() == ChaosGrind.Settings.GrindZoneID end)
    mq.delay(50)
end

function ChaosGrind.CheckGroupHealth()
    if mq.TLO.Group() and mq.TLO.Group.GroupSize() > 2 and ChaosGrind.Settings.DoGroupHeals then
        for i = 1, mq.TLO.Group.Members() do
            local member = mq.TLO.Group.Member(i)
            if member() and member.PctHPs() ~= nil and member.PctHPs() <= ChaosGrind.Settings.GroupHealAt then
                if mq.TLO.FindItem('=' .. ChaosGrind.Settings.GroupHealItem)() then
                    mq.cmdf('/useitem "%s"', ChaosGrind.Settings.GroupHealItem)
                    mq.delay(250)
                    break
                end
            end
            mq.delay(10)
        end
    end
end

function ChaosGrind.CheckSelfHealth()
    if mq.TLO.Me.PctHPs() <= ChaosGrind.Settings.GroupHealAt and ChaosGrind.Settings.DoSelfHeals then
        if mq.TLO.FindItem('=' .. ChaosGrind.Settings.GroupHealItem)() then
            mq.cmdf('/useitem "%s"', ChaosGrind.Settings.GroupHealItem)
            mq.delay(250)
        end
    end
end

function ChaosGrind.HandleDisconnect()
    if ChaosGrind.Settings.NewDisconnectHandler then
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' and not mq.TLO.AutoLogin.Active() then
            mq.TLO.AutoLogin.Profile.ReRun()
            mq.delay(ChaosGrind.Settings.Delays.Two)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(ChaosGrind.Settings.Delays.Two)
        end
    else
        if mq.TLO.EverQuest.GameState() == 'PRECHARSELECT' then
            mq.cmd("/notify serverselect SERVERSELECT_PlayLastServerButton leftmouseup")
            mq.delay(ChaosGrind.Settings.Delays.Two)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'CHARSELECT'
            end)
            mq.delay(ChaosGrind.Settings.Delays.Two)
        end
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
            mq.cmd("/notify CharacterListWnd CLW_Play_Button leftmouseup")
            mq.delay(ChaosGrind.Settings.Delays.Two)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(ChaosGrind.Settings.Delays.Two)
        end
    end
end

function ChaosGrind.MassAggro()
    if not ChaosGrind.Settings.DoZonePulls then return end
    ChaosGrind.HandleDisconnect()
    if not mq.TLO.NearestSpawn(ChaosGrind.Settings.spawnSearch)() and not mq.TLO.Me.XTarget(1)() then
        if mq.TLO.SpawnCount(ChaosGrind.Settings.mobsSearch)() < ChaosGrind.Settings.MinMobsInZone then
            local now = os.time()
            -- Check respawn item cooldown
            if now - ChaosGrind.Settings.lastRespawnUse >= ChaosGrind.Settings.COOLDOWN_SECONDS then
                if mq.TLO.SpawnCount(ChaosGrind.Settings.mobsSearch)() < ChaosGrind.Settings.MinMobsInZone then
                    return
                end
                print('Attempting to respawn the zone!')
                mq.cmdf('/warp loc %s %s %s', ChaosGrind.Settings.respawnY, ChaosGrind.Settings.respawnX, ChaosGrind.Settings.respawnZ)
                mq.delay(ChaosGrind.Settings.Delays.Repop)
                mq.cmdf('/useitem %s', ChaosGrind.Settings.respawnItem)
                mq.delay(ChaosGrind.Settings.Delays.Repop)
                print('Attempting to aggro the zone!')
                mq.delay(ChaosGrind.Settings.Delays.Two)
                mq.cmdf('/useitem %s', ChaosGrind.Settings.aggroItem)
                mq.delay(ChaosGrind.Settings.Delays.Aggro)
                ChaosGrind.Settings.lastRespawnUse = os.time()
            end
        end
    end
end

local function event_CantSeeMob_handler(line)
    mq.cmd('/squelch /warp t')
end
mq.event('CantSeeMob', "#*#You cannot see your target.#*#", event_CantSeeMob_handler)

local function event_slainMob_handler(line, mobName)
    ChaosGrind.Settings.MobCounter = (ChaosGrind.Settings.MobCounter or 0) + 1
    ChaosGrind.Settings.SlainMobTypes[mobName] = (ChaosGrind.Settings.SlainMobTypes[mobName] or 0) + 1
end
mq.event('SlainMob', "#*#You have slain #1#!#*#", event_slainMob_handler)

local function event_aagain_handler(line, gainedPoints)
    local pointsGained = tonumber(gainedPoints) or 1
    ChaosGrind.Settings.StartAA = (ChaosGrind.Settings.StartAA or 0) + pointsGained
end
mq.event('AACheck', "You have gained #1# ability point(s)!#*#", event_aagain_handler)
mq.event('AACheck2', "You have gained an ability point!#*#", event_aagain_handler)

function ChaosGrind.getElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTimeInSeconds = os.difftime(currentTime, startTime)

    -- Calculate hours, minutes, and seconds
    local hours = math.floor(elapsedTimeInSeconds / 3600)
    local minutes = math.floor((elapsedTimeInSeconds % 3600) / 60)
    local seconds = elapsedTimeInSeconds % 60

    -- Format as HH:MM:SS
    return string.format('%02d:%02d:%02d', hours, minutes, seconds)
end

function ChaosGrind.formatNumberWithCommas(number)
    local formatted = tostring(number)
    -- Use pattern to insert commas
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function ChaosGrind.AAStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local aaPerHour = 0
    if elapsedTimeInHours > 0 then
        aaPerHour = ChaosGrind.Settings.StartAA / elapsedTimeInHours
    end

    return ChaosGrind.Settings.StartAA, aaPerHour
end

function ChaosGrind.KillStatus(MobKillCount)
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local killsPerHour = 0
    if elapsedTimeInHours > 0 then
        killsPerHour = MobKillCount / elapsedTimeInHours
    end

    return killsPerHour
end

function ChaosGrind.ChaoticStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local chaoticPerHour = 0
    if elapsedTimeInHours > 0 then
        chaoticPerHour = ChaosGrind.Settings.ChaoticCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.ChaoticCounter, chaoticPerHour
end

function ChaosGrind.ThreadsStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local threadsPerHour = 0
    if elapsedTimeInHours > 0 then
        threadsPerHour = ChaosGrind.Settings.ChaoticThreadCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.ChaoticThreadCounter, threadsPerHour
end

function ChaosGrind.AATokensStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local aaTokensPerHour = 0
    if elapsedTimeInHours > 0 then
        aaTokensPerHour = ChaosGrind.Settings.ChaoticAATokenCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.ChaoticAATokenCounter, aaTokensPerHour
end

function ChaosGrind.AugmentTokensStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local augmentTokensPerHour = 0
    if elapsedTimeInHours > 0 then
        augmentTokensPerHour = ChaosGrind.Settings.AugmentTokenCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.AugmentTokenCounter, augmentTokensPerHour
end

function ChaosGrind.KillsStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local killsPerHour = 0
    if elapsedTimeInHours > 0 then
        killsPerHour = ChaosGrind.Settings.MobCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.MobCounter, killsPerHour
end

function ChaosGrind.LootsStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local lootsPerHour = 0
    if elapsedTimeInHours > 0 then
        lootsPerHour = ChaosGrind.Settings.LootCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.LootCounter, lootsPerHour
end

function ChaosGrind.CurrencyStatus()
    -- Get current AA points and current time
    local currentKC = mq.TLO.Me.AltCurrency('Kill Credit')()
    local currentTime = os.time()

    local kcGained = currentKC - ChaosGrind.Settings.StartKC

    -- Calculate elapsed time in seconds and convert to hours
    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    -- Prevent division by zero if somehow elapsedTimeInHours is too small
    local kcPerHour = 0
    if elapsedTimeInHours > 0 then
        kcPerHour = kcGained / elapsedTimeInHours
    end

    -- Return both total AA gained and AA per hour
    return kcGained, kcPerHour
end

function ChaosGrind.CursedEpicStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.Settings.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local epicsPerHour = 0
    if elapsedTimeInHours > 0 then
        epicsPerHour = ChaosGrind.Settings.CursedEpicCounter / elapsedTimeInHours
    end

    return ChaosGrind.Settings.CursedEpicCounter, epicsPerHour
end

function ChaosGrind.LoadSettings()
    local conf
    local configData, err = loadfile(ChaosGrind.settingsFile)
    if err then
        ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile, ChaosGrind.Settings)
    elseif configData then
        conf = configData()
        if conf.Version ~= ChaosGrind.Settings.Version then
            ChaosGrind.Storage.SaveSettings(ChaosGrind.settingsFile, ChaosGrind.Settings)
            ChaosGrind.LoadSettings()
        else
            ChaosGrind.Settings = conf
        end
    end
end

local HitLvl70SetAA100 = false
function ChaosGrind.MainLoop()
    ChaosGrind.LoadSettings()
    ChaosGrind.CheckCampInfo()
    ChaosGrind.Settings.idleTime = os.time()
    ChaosGrind.Settings.lastX = mq.TLO.Me.X()
    ChaosGrind.Settings.lastY = mq.TLO.Me.Y()
    ChaosGrind.Settings.moveCounter = 0
    ChaosGrind.GUI.initGUI()
    print('Chaos Server Instance Grind Bot Starting Up!')
    ChaosGrind.Settings.StartKC = mq.TLO.Me.AltCurrency('Kill Credit')()
    ChaosGrind.Settings.StartTime = os.time()
    while not ChaosGrind.Settings.terminate do
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' then
            ChaosGrind.HandleDisconnect()
        else
            if not ChaosGrind.Settings.doPause then
                if ChaosGrind.Settings.HubZone == mq.TLO.Zone.ID() then
                    ChaosGrind.goToInstanceNPC()
                    ChaosGrind.GetInstance()
                end
                if ChaosGrind.Settings.GrindZoneID == mq.TLO.Zone.ID() then
                    if mq.TLO.Lua.Script(ChaosGrind.Settings.HuntLuaScript).Status() ~= 'RUNNING' then
                        if ChaosGrind.Settings.WarpBeforeStart then
                            mq.cmdf('/squelch /warp loc %s %s %s', ChaosGrind.Settings.respawnY, ChaosGrind.Settings.respawnX, ChaosGrind.Settings.respawnZ)
                            mq.delay(ChaosGrind.Settings.Delays.Warp)
                        end
                        mq.cmdf('/lua run %s', ChaosGrind.Settings.HuntLuaScript)
                        mq.delay(1250)
                        mq.cmd(ChaosGrind.Settings.HuntLuaScriptCmd2)
                        mq.delay(1250)
                    end
                    -- Define your movement threshold (e.g., 0.5 units)
                    local movementThreshold = 2.5
                    -- Calculate distance moved since last check
                    local dx = ChaosGrind.Settings.lastX - mq.TLO.Me.X()
                    local dy = ChaosGrind.Settings.lastY - mq.TLO.Me.Y()
                    local distance = math.sqrt(dx * dx + dy * dy)

                    if distance < movementThreshold then
                        local now = os.time()
                        if now - ChaosGrind.Settings.lastMove >= ChaosGrind.Settings.lastMove_Cooldown then
                            printf('We\'ve exceeded our stand still timer: %s seconds', ChaosGrind.Settings.lastMove_Cooldown)
                            mq.cmdf('/lua stop %s', ChaosGrind.Settings.HuntLuaScript)
                            -- Update position and time
                            ChaosGrind.Settings.lastX = mq.TLO.Me.X()
                            ChaosGrind.Settings.lastY = mq.TLO.Me.Y()
                            ChaosGrind.Settings.lastMove = now
                        end
                    else
                        local now = os.time()
                        -- If we moved enough, reset the last move timer
                        ChaosGrind.Settings.lastX = mq.TLO.Me.X()
                        ChaosGrind.Settings.lastY = mq.TLO.Me.Y()
                        ChaosGrind.Settings.lastMove = now
                        ChaosGrind.Settings.idleTime = now
                    end
                    if mq.TLO.Me.XTarget(1)() and not mq.TLO.Target() then mq.TLO.Me.XTarget(1).DoTarget() end
                    ChaosGrind.CheckSelfHealth()
                    ChaosGrind.CheckGroupHealth()
                    ChaosGrind.MassAggro()
                    pcall(function()
                        if mq.TLO.Target() and mq.TLO.Target.Distance3D() >= ChaosGrind.Settings.WarpToTargetDistance then
                            mq.cmd('/squelch /warp t')
                        end
                        if ChaosGrind.Settings.UsePBAoEItem and mq.TLO.Target() and mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.Distance3D() <= ChaosGrind.Settings.WarpToTargetDistance and mq.TLO.Target.PctHPs() <= ChaosGrind.Settings.PBAoEAt then
                            if mq.TLO.FindItem('=' .. ChaosGrind.Settings.PBAoEItem)() then
                                mq.cmdf('/useitem "%s"', ChaosGrind.Settings.PBAoEItem)
                                mq.delay(250)
                            end
                        end
                        if ChaosGrind.Settings.UseNukeItem and mq.TLO.Target() and mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.Distance3D() <= ChaosGrind.Settings.WarpToTargetDistance and mq.TLO.Target.PctHPs() <= ChaosGrind.Settings.NukeAt then
                            if mq.TLO.FindItem('=' .. ChaosGrind.Settings.NukeItem)() then
                                mq.cmdf('/useitem "%s"', ChaosGrind.Settings.NukeItem)
                                mq.delay(250)
                            end
                        end
                        if ChaosGrind.Settings.UseLifetapItem and mq.TLO.Target() and mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.Distance3D() <= ChaosGrind.Settings.WarpToTargetDistance and mq.TLO.Target.PctHPs() <= ChaosGrind.Settings.LifetapAt then
                            if mq.TLO.FindItem('=' .. ChaosGrind.Settings.LifetapItem)() then
                                mq.cmdf('/useitem "%s"', ChaosGrind.Settings.LifetapItem)
                                mq.delay(250)
                            end
                        end
                    end)
                    mq.doevents()
                end
                if mq.TLO.Zone.ID() ~= ChaosGrind.Settings.HubZone and mq.TLO.Zone.ID() ~= ChaosGrind.Settings.GrindZoneID then
                    mq.cmdf(ChaosGrind.Settings.HuntLuaScriptCmd1)
                    mq.delay(500)
                    mq.cmdf('/useitem "%s"', ChaosGrind.Settings.OriginItem)
                    mq.delay(ChaosGrind.Settings.ZoneDelay, function() return mq.TLO.Zone.ID() == ChaosGrind.Settings.HubZone end)
                    mq.delay(50)
                    ChaosGrind.goToInstanceNPC()
                    mq.cmd('/say destroy instance')
                    mq.delay(ChaosGrind.Settings.ChatDelay)
                end
            else
                if mq.TLO.Lua.Script(ChaosGrind.Settings.HuntLuaScript).Status() == 'RUNNING' then
                    mq.cmdf('/lua stop %s', ChaosGrind.Settings.HuntLuaScript)
                end
                mq.delay(ChaosGrind.Settings.MainLoopDelay)
            end
        end
        if not HitLvl70SetAA100 and mq.TLO.Me.Level() >= 70 then
            HitLvl70SetAA100 = true
            mq.cmd('/alt on 100')
        end
        mq.delay(ChaosGrind.Settings.MainLoopDelay)
    end
end

ChaosGrind.MainLoop()
return ChaosGrind
