local mq = require('mq')
local EpicTrial = {
    debug = false,
    script_ShortName = 'EpicTrial',
    name = 'Veteran Ralvek',
    UseWarp = true,
    getTrialZone = 344,
    levelingZone = 32,
    trialZone = 184,
    levelingZoneName = 'soldungb',
    gateItem = 'Gate Potion',
    userBattleScript1 = '/lua run aqo',
    userBattleScript2 = '/lua stop aqo',
    userBattleScriptCmd1 = '/aqo mode 7',
    userBattleScriptCmd2 = '/aqo pause off',
    restockPotionsAt = 10,
    restockAmount = 100,
    restockNPC = 'Thaddeus',
    closeSellWindow = false,
    rebirthNPC = 'Zalthar the Eternal',
    teleportNPC = 'Eldrin',
    instanceNPC = 'Mirage',
    buffNPC = 'Throm',
    bankNPC = '',
    bankDeposit = true,
    vendorSell = true,
    bankAtFreeSlots = 3,
    RebirthLevel = 70,
    shrink = true,
    shrinkItem = "Anizok's Minimizing Device"
}
EpicTrial.LootUtils = require('DroidLoot.lib.LootUtils')
EpicTrial.needToBank = false
EpicTrial.needToVendorSell = false
EpicTrial.MobCounter = 0
EpicTrial.SlainMobTypes = {}

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

function EpicTrial.formatNumberWithCommas(number)
    local formatted = tostring(number)
    -- Use pattern to insert commas
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function EpicTrial.ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then
            break
        end -- a Lua function
        sName = EpicTrial.script_ShortName
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function EpicTrial.CONSOLEMETHOD(isDebugMessage, consoleMessage, ...)
    -- Get the current time in a readable format (HH:MM:SS)
    local timestamp = os.date("[%H:%M:%S]")
    if isDebugMessage then
        if EpicTrial.debug then
            printf("%s" .. Colors.g .. "[%s] " .. Colors.r .. consoleMessage .. Colors.x, timestamp, EpicTrial.ScriptInfo(), ...)
        end
    else
        printf("%s" .. Colors.g .. "[%s] " .. Colors.w .. consoleMessage .. Colors.x, timestamp, EpicTrial.script_ShortName, ...)
    end
end

local function navToID(spawnID)
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local playerDelay = 1000 + playerPing
    local playerLoopDelay = 100 + playerPing
    if EpicTrial.UseWarp and mq.TLO.Me.InInstance() and mq.TLO.Zone.ID() ~= EpicTrial.getTrialZone then
        mq.cmdf('/target id %s', spawnID)
        mq.delay(playerDelay, function() return mq.TLO.Target() ~= nil end)
        mq.cmd('/squelch /warp t')
        local playerPing1 = math.floor(mq.TLO.EverQuest.Ping() * 2)
        local playerDelay1 = 500 + playerPing1
        mq.delay(playerDelay1)
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

function EpicTrial.BankDropOff()
    if mq.TLO.Me.FreeInventory() <= EpicTrial.LootUtils.bankAtFreeSlots or EpicTrial.needToBank then
        local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
        if mq.TLO.Zone.ID() ~= EpicTrial.getTrialZone then
            mq.cmdf('/cast item "%s"', EpicTrial.gateItem)
            mq.delay(60000 + playerPing, function() return mq.TLO.Zone.ID() == EpicTrial.getTrialZone end)
            mq.delay(1000 + playerPing)
        end
        if mq.TLO.Zone.ID() == EpicTrial.getTrialZone then
            mq.cmdf('/target npc %s', EpicTrial.bankNPC)
            mq.delay(250 + playerPing)
            mq.delay(5000 + playerPing, function() return mq.TLO.Target() ~= nil end)
            EpicTrial.LootUtils.navToID(mq.TLO.Target.ID())
            mq.delay(250 + playerPing)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000 + playerPing, function() return mq.TLO.Window('BigBankWnd').Open() end)
            mq.delay(50 + playerPing)
            EpicTrial.LootUtils.bankStuff()
            mq.delay(500 + playerPing)
            if EpicTrial.vendorSell then
                EpicTrial.needToVendorSell = true
                EpicTrial.VendorSell()
                mq.delay(500 + playerPing)
            end
            EpicTrial.needToBank = false
        end
    end
end

function EpicTrial.VendorSell()
    if EpicTrial.needToVendorSell then
        local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
        if mq.TLO.Zone.ID() ~= EpicTrial.getTrialZone then
            mq.cmdf('/cast item "%s"', EpicTrial.gateItem)
            mq.delay(60000, function() return mq.TLO.Zone.ID() == EpicTrial.getTrialZone end)
            mq.delay(1000)
        end
        if mq.TLO.Zone.ID() == EpicTrial.getTrialZone then
            mq.delay(500 + playerPing)
            mq.cmdf('/target npc %s', EpicTrial.restockNPC)
            mq.delay(250 + playerPing)
            mq.delay(5000 + playerPing, function() return mq.TLO.Target() ~= nil end)
            EpicTrial.LootUtils.navToID(mq.TLO.Target.ID())
            mq.delay(250 + playerPing)
            mq.cmdf('/nomodkey /click right target')
            mq.delay(5000 + playerPing, function() return mq.TLO.Window('MerchantWnd').Open() end)
            EpicTrial.LootUtils.sellStuff(EpicTrial.closeSellWindow, false)
            EpicTrial.needToVendorSell = false
        end
    end
end

local function goToVeteranRalve()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER goToVeteranRalve()')
    if mq.TLO.Zone.ID() ~= EpicTrial.getTrialZone then return end
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    EpicTrial.getBuffsFromNPC()
    if not mq.TLO.Target() or mq.TLO.Target.CleanName() ~= EpicTrial.name then
        mq.cmdf('/target npc %s', EpicTrial.name)
        mq.delay(2000 + playerPing, function() return mq.TLO.Target() ~= nil end)
    end
    local vendorName = mq.TLO.Target.CleanName()
    if vendorName ~= EpicTrial.name then goToVeteranRalve() end
    if mq.TLO.Target() and mq.TLO.Target.Distance() > 15 then
        navToID(mq.TLO.Target.ID())
        mq.cmd('/hail')
        mq.delay(1000 + playerPing)
        return true
    end
    return false
end

function EpicTrial.ReportKills()
    EpicTrial.CONSOLEMETHOD(false, 'Slain Mobs: %s / MobTypes: %s', EpicTrial.MobCounter, #EpicTrial.SlainMobTypes)
end

local function event_GetEpicTrial_handler(line, npcTextLink1)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_GetEpicTrial_handler()')
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'Trial of') then
            mq.ExecuteTextLink(link)
            return
        end
    end
end
mq.event('GetEpicTrial', "#*#whispers, '#*#The Trial #*# Will you face #1##*#?#*#'", event_GetEpicTrial_handler, { keepLinks = true })

local function event_ExitEpicTrial_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_ExitEpicTrial_handler()')
    EpicTrial.CONSOLEMETHOD(false, 'Finished missing, exiting trial, and attempting to get another.')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    while mq.TLO.SpawnCount('npc')() > 0 and (mq.TLO.Zone.ID() == EpicTrial.trialZone or mq.TLO.Zone.ID() == EpicTrial.levelingZone) do
        mq.delay(250 + playerPing)
    end
    EpicTrial.ReportKills()
    mq.delay(7500 + playerPing)
    mq.delay(15000 + playerPing, function() return mq.TLO.SpawnCount('npccorpse')() <= 0 end)
    mq.cmd(EpicTrial.userBattleScript2)
    mq.delay(500 + playerPing)
    mq.cmdf('/cast item "%s"', EpicTrial.gateItem)
    mq.delay(60000 + playerPing, function() return mq.TLO.Zone.ID() == EpicTrial.getTrialZone end)
    goToVeteranRalve()
end
mq.event('ExitEpicTrial1', "#*#You have slain Avatar of Endurance!#*#", event_ExitEpicTrial_handler)
mq.event('ExitEpicTrial2', "#*#Your gate is too unstable, and collapses.#*#", event_ExitEpicTrial_handler)

local function event_BeginEpicTrial_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_BeginEpicTrial_handler()')
    EpicTrial.CONSOLEMETHOD(false, 'Beginning Epic Trial.')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    mq.delay(250 + playerPing)
    if EpicTrial.UseWarp then
        mq.cmd('/squelch /warp loc -2.06 -314.10 10.26')
    else
        mq.cmd('/nav locxyz -314.10 -2.06 10.26')
    end
    mq.cmd(EpicTrial.userBattleScript1)
    mq.delay(750 + playerPing)
    mq.cmd(EpicTrial.userBattleScriptCmd1)
    mq.delay(750 + playerPing)
    mq.cmd(EpicTrial.userBattleScriptCmd2)
    mq.delay(750 + playerPing)
end
mq.event('BeginEpicTrial', "#*#You have entered Loading Zone.#*#", event_BeginEpicTrial_handler)

local function event_slainMob_handler(line, mobName)
    EpicTrial.MobCounter = (EpicTrial.MobCounter or 0) + 1
    EpicTrial.SlainMobTypes[mobName] = (EpicTrial.SlainMobTypes[mobName] or 0) + 1
    -- EpicTrial.Messages.Info('%s / %s / %s', mobName, EpicTrial.MobCounter, EpicTrial.SlainMobTypes[mobName])
end
mq.event('SlainMob', "#*#You have slain #1#!#*#", event_slainMob_handler)

local function event_rebithTime_handler(line, rebirthLink)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_rebithTime_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'seek to be reborn') then
            mq.ExecuteTextLink(link)
            mq.delay(1500 + playerPing)
            return
        elseif string.find(linkText, 'ready to be reborn') then
            mq.ExecuteTextLink(link)
            mq.delay(5000 + playerPing)
            return
        end
    end
end
mq.event('RebirthTime1', "#*#whispers, '#*#Greetings, seeker of power. I am#*# Do you #1# and claim the rewards of eternity?#*#'", event_rebithTime_handler, { keepLinks = true })
mq.event('RebirthTime2', "#*#whispers, '#*#Ah, a worthy candidate!#*#'", event_rebithTime_handler, { keepLinks = true })
mq.event('RebirthTime3', "#*#whispers, '#*#Welcome back, #*#. Your current#*#'", event_rebithTime_handler, { keepLinks = true })

local function event_GetBuffsFromNPC_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_GetBuffsFromNPC_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    local buffLink
    local speedLink
    local keiLink
    local healLink
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'buffs') then
            buffLink = link
        end
        if string.find(linkText, 'speed buff') then
            speedLink = link
        end
        if string.find(linkText, 'KEI') then
            keiLink = link
        end
        if string.find(linkText, 'heal') then
            healLink = link
        end
    end
    mq.ExecuteTextLink(buffLink)
    mq.delay(500 + playerPing)
    mq.ExecuteTextLink(speedLink)
    mq.delay(500 + playerPing)
    mq.ExecuteTextLink(keiLink)
    mq.delay(500 + playerPing)
    mq.ExecuteTextLink(healLink)
    mq.delay(500 + playerPing)
    mq.flushevents('GetBuffsFromNPC1')
end
mq.event('GetBuffsFromNPC1', "#*#Throm whispers, 'Greetings#*#", event_GetBuffsFromNPC_handler, { keepLinks = true })

local function event_MoveToLevelingZone1_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_MoveToLevelingZone1_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'list the expansions') then
            mq.ExecuteTextLink(link)
            mq.delay(500 + playerPing)
            return
        end
    end
end
local function event_MoveToLevelingZone2_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_MoveToLevelingZone2_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'Classic') then
            mq.ExecuteTextLink(link)
            mq.delay(500 + playerPing)
            return
        end
    end
end
local function event_MoveToLevelingZone3_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_MoveToLevelingZone3_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, EpicTrial.levelingZoneName) then
            mq.ExecuteTextLink(link)
            mq.delay(500 + playerPing)
            return
        end
    end
end
local function event_MoveToLevelingZone4_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_MoveToLevelingZone4_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'enter') then
            mq.ExecuteTextLink(link)
            mq.delay(500 + playerPing)
            return
        end
    end
end
local function event_MoveToLevelingZone5_handler(line)
    EpicTrial.CONSOLEMETHOD(true, 'ENTER event_MoveToLevelingZone5_handler()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'create instance') then
            mq.ExecuteTextLink(link)
            mq.delay(500 + playerPing)
            return
        end
    end
end
mq.event('MoveToLevelingZone1', "#*#Greetings, adventurer! Ready to explore#*#", event_MoveToLevelingZone1_handler, { keepLinks = true })
mq.event('MoveToLevelingZone2', "#*#Available Expansions:#*#", event_MoveToLevelingZone2_handler, { keepLinks = true })
mq.event('MoveToLevelingZone3', "#*#More zones:#*#", event_MoveToLevelingZone3_handler, { keepLinks = true })
mq.event('MoveToLevelingZone4', "#*#You already have an instance for this zone#*#", event_MoveToLevelingZone4_handler, { keepLinks = true })
mq.event('MoveToLevelingZone5', "#*#Very well, I do charge#*#", event_MoveToLevelingZone5_handler, { keepLinks = true })

function EpicTrial.CheckSupplies()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER CheckSupplies()')
    if mq.TLO.Zone.ID() ~= EpicTrial.getTrialZone then return end
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    local currentPotions = mq.TLO.FindItemCount(EpicTrial.gateItem)()
    if currentPotions >= EpicTrial.restockPotionsAt then return end

    mq.cmdf('/target npc %s', EpicTrial.restockNPC)
    mq.delay(1000 + playerPing, function() return mq.TLO.Target() ~= nil and mq.TLO.Target.CleanName() == EpicTrial.restockNPC end)

    if mq.TLO.Target() and mq.TLO.Target.Distance() > 15 then
        navToID(mq.TLO.Target.ID())
    end
    if not mq.TLO.Target() then return end

    EpicTrial.CONSOLEMETHOD(false, 'Opening merchant window to restock potions.')
    mq.cmd('/click right target') -- open merchant window
    mq.delay(2000 + playerPing, function() return mq.TLO.Window("MerchantWnd").Open() end)

    if not mq.TLO.Window("MerchantWnd").Open() then
        EpicTrial.CONSOLEMETHOD(false, 'Merchant window did not open.')
        return
    end

    local needed = EpicTrial.restockAmount - currentPotions
    EpicTrial.CONSOLEMETHOD(false, 'Currently have %d gate potions. Need to buy %d more.', currentPotions, needed)

    local listIndex = mq.TLO.Window("MerchantWnd").Child("ItemList").List("=" .. EpicTrial.gateItem .. ",2")()
    if not listIndex or listIndex == 0 then
        EpicTrial.CONSOLEMETHOD(false, 'Could not find %s in merchant list.', EpicTrial.gateItem)
        return
    end
    mq.cmdf('/notify MerchantWnd ItemList listselect %d', listIndex)
    mq.delay(100 + playerPing)
    mq.cmdf('/buyitem %d', needed)
    mq.delay(1000 + playerPing)
    mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup')
    mq.delay(500 + playerPing)
end

function EpicTrial.CheckLevelForRebirth()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER CheckLevelForRebirth()')
    if mq.TLO.Zone.ID() ~= EpicTrial.getTrialZone then return end
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    if mq.TLO.Me.Level() >= EpicTrial.RebirthLevel then
        mq.cmdf('/target npc %s', EpicTrial.rebirthNPC)
        if mq.TLO.Target() and mq.TLO.Target.Distance() > 15 then
            navToID(mq.TLO.Target.ID())
        end
        if not mq.TLO.Target() then return end
        mq.delay(250 + playerPing)
        mq.cmd('/hail')
        mq.delay(750 + playerPing)
        mq.doevents()
        mq.delay(750 + playerPing)
        mq.delay(15000 + playerPing)
    end
end

function EpicTrial.getBuffsFromNPC()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER getBuffsFromNPC()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    if mq.TLO.Zone.ID() == EpicTrial.getTrialZone then
        mq.cmdf('/target npc %s', EpicTrial.buffNPC)
        mq.delay(250 + playerPing)
        if mq.TLO.Target() and mq.TLO.Target.Distance() > 15 then
            navToID(mq.TLO.Target.ID())
        end
        if not mq.TLO.Target() then return end
        mq.delay(250 + playerPing)
        mq.cmd('/hail')
        mq.delay(1000 + playerPing)
        mq.doevents()
        mq.delay(3000 + playerPing)
    end
end

local function getToLevelingZone()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER getToLevelingZone()')
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    EpicTrial.getBuffsFromNPC()
    if mq.TLO.Me.Level() < 50 then
        if mq.TLO.Zone.ID() == EpicTrial.getTrialZone then
            mq.cmdf('/target npc %s', EpicTrial.teleportNPC)
            mq.delay(250 + playerPing)
            if mq.TLO.Target() and mq.TLO.Target.Distance() > 15 then
                navToID(mq.TLO.Target.ID())
            end
            if not mq.TLO.Target() then return end
            mq.delay(1000 + playerPing)
            mq.cmd('/hail')
            mq.doevents()
            mq.delay(1000 + playerPing)
            mq.doevents()
            mq.delay(1000 + playerPing)
            mq.doevents()
            mq.delay(1000 + playerPing)
            mq.doevents()
            mq.delay(1000 + playerPing)
            mq.delay(60000 + playerPing, function() return mq.TLO.Zone.ID() == EpicTrial.levelingZone end)
            mq.cmdf('/target npc %s', EpicTrial.instanceNPC)
            mq.delay(750 + playerPing)
            mq.cmd('/hail')
            mq.delay(750 + playerPing)
            mq.doevents()
            mq.delay(750 + playerPing)
            mq.doevents()
            mq.delay(5000 + playerPing)
            if EpicTrial.shrink and mq.TLO.FindItem(EpicTrial.shrinkItem).ID() then
                mq.cmd('/target id %s', mq.TLO.Me.ID())
                mq.delay(2500, function() return mq.TLO.Target.ID() == mq.TLO.Me.ID() end)
                mq.cmdf('/cast item "%s"', EpicTrial.shrinkItem)
                mq.delay(1000)
                mq.cmdf('/cast item "%s"', EpicTrial.shrinkItem)
                mq.delay(1000)
            end
            EpicTrial.ClearLevelingZone()
        end
    end
end

function EpicTrial.ClearLevelingZone()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER ClearLevelingZone()')
    if mq.TLO.Me.InInstance() and mq.TLO.Zone.ID() == EpicTrial.levelingZone then
        local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
        if mq.TLO.Lua.Script('aqo').Status() ~= 'RUNNING' then
            mq.cmd(EpicTrial.userBattleScript1)
            mq.delay(750 + playerPing)
            mq.cmd(EpicTrial.userBattleScriptCmd1)
            mq.delay(750 + playerPing)
            mq.cmd(EpicTrial.userBattleScriptCmd2)
            mq.delay(750 + playerPing)
        end
    end
end

function EpicTrial.GoToHub()
    mq.cmdf('/cast item "%s"', EpicTrial.gateItem)
    mq.delay(60000, function() return mq.TLO.Zone.ID() == EpicTrial.getTrialZone end)
end

function EpicTrial.LevelUpForTrials()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER LevelUpForTrials()')
    if mq.TLO.Me.Level() >= 50 and mq.TLO.Zone.ID() == EpicTrial.levelingZone then
        local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
        EpicTrial.GoToHub()
        mq.delay(500 + playerPing)
        goToVeteranRalve()
        return
    end
    if mq.TLO.Me.Level() >= 50 then return end
    if mq.TLO.Zone.ID() == EpicTrial.getTrialZone and mq.TLO.Me.Level() < 50 then getToLevelingZone() end
    if mq.TLO.Me.InInstance() and mq.TLO.Zone.ID() == EpicTrial.levelingZone and mq.TLO.Me.Level() < 50 then EpicTrial.ClearLevelingZone() end
end

function EpicTrial.MainLoop()
    EpicTrial.CONSOLEMETHOD(true, 'ENTER MainLoop()')
    local firstrun = true
    local playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
    while true do
        playerPing = math.floor(mq.TLO.EverQuest.Ping() * 2)
        if firstrun and mq.TLO.Zone.ID() == EpicTrial.getTrialZone and mq.TLO.Me.Level() >= 50 then
            goToVeteranRalve()
            firstrun = false
        end
        if not mq.TLO.Me.Standing() or mq.TLO.Me.Ducking() then
            mq.TLO.Me.Stand()
        end
        if EpicTrial.bankDeposit and mq.TLO.Me.FreeInventory() <= EpicTrial.bankAtFreeSlots then
            EpicTrial.needToBank = true
        end
        if EpicTrial.needToBank then
            EpicTrial.BankDropOff()
        end
        if EpicTrial.needToVendorSell then
            EpicTrial.VendorSell()
        end
        EpicTrial.CheckSupplies()
        EpicTrial.CheckLevelForRebirth()
        EpicTrial.LevelUpForTrials()
        mq.doevents()
        mq.delay(500 + playerPing)
    end
end

EpicTrial.MainLoop()

return EpicTrial
