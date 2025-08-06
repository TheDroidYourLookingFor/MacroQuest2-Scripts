local mq = require('mq')

ChaosGrind = {
    _version = '1.0.1',
    _author = 'TheDroidUrLookingFor'
}
ChaosGrind.GUI = require('ChaosGrind.lib.Gui')
ChaosGrind.GrindZone = 89
ChaosGrind.Expansion = 'The Ruins of Kunark'
ChaosGrind.Zone = 'sebilis'
ChaosGrind.DoStatTrack = true
ChaosGrind.script_ShortName = 'ChaosGrind'
ChaosGrind.command_ShortName = 'cg'
ChaosGrind.command_LongName = 'ChaosGrind'
ChaosGrind.OriginItem = 'Chaotic Token of Return'
ChaosGrind.MainLoopDelay = 100
ChaosGrind.ChatDelay = 1000
ChaosGrind.ZoneDelay = 30000
ChaosGrind.UseWarp = true
ChaosGrind.InstanceNPC = 'Eldrin'
ChaosGrind.HubZone = 998
ChaosGrind.GroupHealItem = 'Mythic Minli`s Greaves of Stability'
ChaosGrind.GroupHealAt = 90
ChaosGrind.DoGroupHeals = true
ChaosGrind.DoSelfHeals = true
ChaosGrind.DoZonePulls = true
ChaosGrind.mobsSearch = 'npc targetable noalert 1'
ChaosGrind.aggroItem = 'Chaotic Horn of Aggro'
ChaosGrind.respawnItem = 'Chaotic Horn of Reborm'
ChaosGrind.lastRespawnUse = 0
ChaosGrind.COOLDOWN_SECONDS = 600
ChaosGrind.NewDisconnectHandler = true
ChaosGrind.HuntLuaScript = 'aqo'
ChaosGrind.HuntLuaScriptCmd2 = '/aqo pause off'
ChaosGrind.lastMove_Cooldown = 60
ChaosGrind.lastMove = os.time()

ChaosGrind.lastX = mq.TLO.Me.X()
ChaosGrind.lastY = mq.TLO.Me.Y()
ChaosGrind.moveCounter = 0
ChaosGrind.RestartCounter = 600
ChaosGrind.terminate = false
ChaosGrind.doPause = false
ChaosGrind.ChaoticCounter = 0
ChaosGrind.CursedEpicCounter = 0
ChaosGrind.ChaoticThreadCounter = 0
ChaosGrind.AugmentTokenCounter = 0
ChaosGrind.ChaoticAATokenCounter = 0

ChaosGrind.StartKC = 0
ChaosGrind.StartAA = 0
ChaosGrind.StartTime = os.time()
ChaosGrind.LastReportTime = os.time()
ChaosGrind.MobCounter = 0
ChaosGrind.SlainMobTypes = {}
ChaosGrind.SlainChaoticTypes = {}

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
    if ChaosGrind.UseWarp and mq.TLO.Zone.ID() == ChaosGrind.GrindZone then
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
    if mq.TLO.Zone.ID() ~= ChaosGrind.HubZone then return end
    if not mq.TLO.Target() then
        mq.cmdf('/target npc %s', ChaosGrind.InstanceNPC)
        mq.delay(2000, function() return mq.TLO.Target() ~= nil end)
    end
    local vendorName = mq.TLO.Target.CleanName()
    if vendorName ~= ChaosGrind.InstanceNPC then ChaosGrind.goToInstanceNPC() end
    if mq.TLO.Target.Distance() > 15 then
        if ChaosGrind.UseWarp then
            mq.cmdf('%s', '/warp t')
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
    ChaosGrind.ChaoticCounter = (ChaosGrind.ChaoticCounter or 0) + 1
    ChaosGrind.SlainChaoticTypes[mobName] = (ChaosGrind.SlainChaoticTypes[mobName] or 0) + 1
end
mq.event('GoblinCheck', "Chaotic#1# twists into a chaotic reflection of itself!#*#", event_chaoticCounter_handler)

local function event_cursedEpicCheck_handler(line, lootName)
    if lootName == 'Innoruuk\'s Dark Curse' then
        ChaosGrind.CursedEpicCounter = (ChaosGrind.CursedEpicCounter or 0) + 1
    elseif lootName == 'Chaotic Augment Token' then
        ChaosGrind.AugmentTokenCounter = (ChaosGrind.AugmentTokenCounter or 0) + 1
    elseif lootName == 'Chaotic Thread' then
        ChaosGrind.ChaoticThreadCounter = (ChaosGrind.ChaoticThreadCounter or 0) + 1
    elseif lootName == 'Chaotic AA Token' then
        ChaosGrind.ChaoticAATokenCounter = (ChaosGrind.ChaoticAATokenCounter or 0) + 1
    end
end
mq.event('CursedEpicCheck', "#*#You have looted #1#.#*#", event_cursedEpicCheck_handler)

local function event_ListExpansions_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'list expansions') then
            mq.ExecuteTextLink(link)
            mq.flushevents("ListExpansions")
            mq.delay(ChaosGrind.ChatDelay)
        end
    end
end
mq.event('ListExpansions', "#*#Eldrin whispers, 'Greetings!#*#'", event_ListExpansions_handler, { keepLinks = true })

local function event_SelectExpansion_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, ChaosGrind.Expansion) then
            mq.ExecuteTextLink(link)
            mq.flushevents("SelectExpansion")
            mq.delay(ChaosGrind.ChatDelay)
        end
    end
end
mq.event('SelectExpansion', "#*#whispers, 'Available Expansions: #*#'", event_SelectExpansion_handler, { keepLinks = true })

local function event_Selectzone_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, ChaosGrind.Zone) then
            mq.ExecuteTextLink(link)
            mq.flushevents("SelectZone")
            mq.delay(ChaosGrind.ChatDelay)
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
            mq.delay(ChaosGrind.ChatDelay)
        end
    end
end
mq.event('EnterInstance', "#*#Eldrin whispers, 'Normal port#*#'", event_EnterInstance_handler, { keepLinks = true })

local function event_InstanceExpiring_handler(line)
    mq.cmdf('/lua stop %s', ChaosGrind.HuntLuaScript)
    mq.delay(500)
    mq.cmdf('/useitem "%s"', ChaosGrind.OriginItem)
    mq.delay(ChaosGrind.ZoneDelay, function() return mq.TLO.Zone.ID() == ChaosGrind.HubZone end)
    mq.delay(50)
    ChaosGrind.goToInstanceNPC()
    mq.cmd('/say destroy instance')
    mq.delay(ChaosGrind.ChatDelay)
end
mq.event('InstanceExpire', "You only have #*# minutes remaining before this expedition comes to an end.", event_InstanceExpiring_handler)

function ChaosGrind.GetInstance()
    mq.cmd('/hail')
    mq.delay(ChaosGrind.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.ChatDelay)
    mq.doevents()
    mq.delay(ChaosGrind.ZoneDelay, function() return mq.TLO.Zone.ID() == ChaosGrind.GrindZone end)
    mq.delay(50)
end

function ChaosGrind.CheckGroupHealth()
    if mq.TLO.Group() and mq.TLO.Group.GroupSize() > 2 and ChaosGrind.DoGroupHeals then
        for i = 1, mq.TLO.Group.Members() do
            local member = mq.TLO.Group.Member(i)
            if member() and member.PctHPs() ~= nil and member.PctHPs() <= ChaosGrind.GroupHealAt then
                if mq.TLO.FindItem('=' .. ChaosGrind.GroupHealItem)() then
                    mq.cmdf('/useitem "%s"', ChaosGrind.GroupHealItem)
                    mq.delay(250)
                    break
                end
            end
            mq.delay(10)
        end
    end
end

function ChaosGrind.CheckSelfHealth()
    if mq.TLO.Me.PctHPs() <= ChaosGrind.GroupHealAt and ChaosGrind.DoSelfHeals then
        if mq.TLO.FindItem('=' .. ChaosGrind.GroupHealItem)() then
            mq.cmdf('/useitem "%s"', ChaosGrind.GroupHealItem)
            mq.delay(250)
        end
    end
end

function ChaosGrind.HandleDisconnect()
    if ChaosGrind.NewDisconnectHandler then
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' and not mq.TLO.AutoLogin.Active() then
            mq.TLO.AutoLogin.Profile.ReRun()
            mq.delay(ChaosGrind.Delays.Two)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(ChaosGrind.Delays.Two)
        end
    else
        if mq.TLO.EverQuest.GameState() == 'PRECHARSELECT' then
            mq.cmd("/notify serverselect SERVERSELECT_PlayLastServerButton leftmouseup")
            mq.delay(ChaosGrind.Delays.Two)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'CHARSELECT'
            end)
            mq.delay(ChaosGrind.Delays.Two)
        end
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
            mq.cmd("/notify CharacterListWnd CLW_Play_Button leftmouseup")
            mq.delay(ChaosGrind.Delays.Two)
            mq.delay(25000, function()
                return mq.TLO.EverQuest.GameState() == 'INGAME'
            end)
            mq.delay(ChaosGrind.Delays.Two)
        end
    end
end

function ChaosGrind.MassAggro()
    if not ChaosGrind.DoZonePulls then return end
    ChaosGrind.HandleDisconnect()
    local now = os.time()
    -- Check respawn item cooldown
    if now - ChaosGrind.lastRespawnUse >= ChaosGrind.COOLDOWN_SECONDS then
        print('Attempting to respawn the zone!')
        mq.cmdf('/useitem %s', ChaosGrind.respawnItem)
        mq.delay(ChaosGrind.Delays.Repop)
        print('Attempting to aggro the zone!')
        mq.delay(ChaosGrind.Delays.Two)
        mq.cmdf('/useitem %s', ChaosGrind.aggroItem)
        mq.delay(ChaosGrind.Delays.Aggro)
        ChaosGrind.lastRespawnUse = os.time()
    end
end

local function event_CantSeeMob_handler(line)
    mq.cmd('/warp t')
end
mq.event('CantSeeMob', "#*#You cannot see your target.#*#", event_CantSeeMob_handler)

local function event_slainMob_handler(line, mobName)
    ChaosGrind.MobCounter = (ChaosGrind.MobCounter or 0) + 1
    ChaosGrind.SlainMobTypes[mobName] = (ChaosGrind.SlainMobTypes[mobName] or 0) + 1
end
mq.event('SlainMob', "#*#You have slain #1#!#*#", event_slainMob_handler)

local function event_aagain_handler(line, gainedPoints)
    local pointsGained = tonumber(gainedPoints) or 1
    ChaosGrind.StartAA = (ChaosGrind.StartAA or 0) + pointsGained
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

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local aaPerHour = 0
    if elapsedTimeInHours > 0 then
        aaPerHour = ChaosGrind.StartAA / elapsedTimeInHours
    end

    return ChaosGrind.StartAA, aaPerHour
end

function ChaosGrind.KillStatus(MobKillCount)
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local killsPerHour = 0
    if elapsedTimeInHours > 0 then
        killsPerHour = MobKillCount / elapsedTimeInHours
    end

    return killsPerHour
end

function ChaosGrind.ChaoticStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local chaoticPerHour = 0
    if elapsedTimeInHours > 0 then
        chaoticPerHour = ChaosGrind.ChaoticCounter / elapsedTimeInHours
    end

    return ChaosGrind.ChaoticCounter, chaoticPerHour
end

function ChaosGrind.ThreadsStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local threadsPerHour = 0
    if elapsedTimeInHours > 0 then
        threadsPerHour = ChaosGrind.ChaoticThreadCounter / elapsedTimeInHours
    end

    return ChaosGrind.ChaoticThreadCounter, threadsPerHour
end

function ChaosGrind.AATokensStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local aaTokensPerHour = 0
    if elapsedTimeInHours > 0 then
        aaTokensPerHour = ChaosGrind.ChaoticAATokenCounter / elapsedTimeInHours
    end

    return ChaosGrind.ChaoticAATokenCounter, aaTokensPerHour
end

function ChaosGrind.AugmentTokensStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local augmentTokensPerHour = 0
    if elapsedTimeInHours > 0 then
        augmentTokensPerHour = ChaosGrind.AugmentTokenCounter / elapsedTimeInHours
    end

    return ChaosGrind.AugmentTokenCounter, augmentTokensPerHour
end

function ChaosGrind.KillsStatus()
    local currentTime = os.time()

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local killsPerHour = 0
    if elapsedTimeInHours > 0 then
        killsPerHour = ChaosGrind.MobCounter / elapsedTimeInHours
    end

    return ChaosGrind.MobCounter, killsPerHour
end

function ChaosGrind.CurrencyStatus()
    -- Get current AA points and current time
    local currentKC = mq.TLO.Me.AltCurrency('Kill Credit')()
    local currentTime = os.time()

    local kcGained = currentKC - ChaosGrind.StartKC

    -- Calculate elapsed time in seconds and convert to hours
    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
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

    local elapsedTimeInSeconds = os.difftime(currentTime, ChaosGrind.StartTime)
    local elapsedTimeInHours = elapsedTimeInSeconds / 3600 -- Convert seconds to hours

    local epicsPerHour = 0
    if elapsedTimeInHours > 0 then
        epicsPerHour = ChaosGrind.CursedEpicCounter / elapsedTimeInHours
    end

    return ChaosGrind.CursedEpicCounter, epicsPerHour
end

function ChaosGrind.MainLoop()
    ChaosGrind.lastX = mq.TLO.Me.X()
    ChaosGrind.lastY = mq.TLO.Me.Y()
    ChaosGrind.moveCounter = 0
    ChaosGrind.GUI.initGUI()
    print('Chaos Server Instance Grind Bot Starting Up!')
    ChaosGrind.StartKC = mq.TLO.Me.AltCurrency('Kill Credit')()
    ChaosGrind.StartTime = os.time()
    while not ChaosGrind.terminate do
        if mq.TLO.EverQuest.GameState() ~= 'INGAME' then
            ChaosGrind.HandleDisconnect()
        else
            if not ChaosGrind.doPause then
                if ChaosGrind.HubZone == mq.TLO.Zone.ID() then
                    ChaosGrind.goToInstanceNPC()
                    ChaosGrind.GetInstance()
                end
                if ChaosGrind.GrindZone == mq.TLO.Zone.ID() then
                    if mq.TLO.Lua.Script(ChaosGrind.HuntLuaScript).Status() ~= 'RUNNING' then
                        mq.cmdf('/lua run %s', ChaosGrind.HuntLuaScript)
                        mq.delay(1250)
                        mq.cmd(ChaosGrind.HuntLuaScriptCmd2)
                    end
                    if ChaosGrind.lastX == mq.TLO.Me.X() and ChaosGrind.lastY == mq.TLO.Me.Y() then
                        local now = os.time()
                        if now - ChaosGrind.lastMove >= ChaosGrind.lastMove_Cooldown then
                            printf('We\'ve exceeded our stand still timer: %s seconds', ChaosGrind.lastMove_Cooldown)
                            mq.cmdf('/lua stop %s', ChaosGrind.HuntLuaScript)
                            mq.delay(500)
                            ChaosGrind.lastX = mq.TLO.Me.X()
                            ChaosGrind.lastY = mq.TLO.Me.Y()
                            ChaosGrind.lastMove = os.time()
                        end
                    end
                    ChaosGrind.CheckSelfHealth()
                    ChaosGrind.CheckGroupHealth()
                    ChaosGrind.MassAggro()
                    mq.doevents()
                end
                if mq.TLO.Zone.ID() ~= ChaosGrind.HubZone and mq.TLO.Zone.ID() ~= ChaosGrind.GrindZone then
                    mq.cmdf('/lua stop %s', ChaosGrind.HuntLuaScript)
                    mq.delay(500)
                    mq.cmdf('/useitem "%s"', ChaosGrind.OriginItem)
                    mq.delay(ChaosGrind.ZoneDelay, function() return mq.TLO.Zone.ID() == ChaosGrind.HubZone end)
                    mq.delay(50)
                    ChaosGrind.goToInstanceNPC()
                    mq.cmd('/say destroy instance')
                    mq.delay(ChaosGrind.ChatDelay)
                end
            else
                if mq.TLO.Lua.Script(ChaosGrind.HuntLuaScript).Status() == 'RUNNING' then
                    mq.cmdf('/lua stop %s', ChaosGrind.HuntLuaScript)
                    mq.delay(500)
                end
            end
        end
        mq.delay(ChaosGrind.MainLoopDelay)
    end
end

ChaosGrind.MainLoop()
return ChaosGrind
