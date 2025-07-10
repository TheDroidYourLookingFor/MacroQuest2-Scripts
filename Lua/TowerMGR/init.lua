local mq = require('mq')

local towerMain_Loop = true
local towerMain_delay = 1000
local nextFloor_WaitTime = 6000
local tower_Zone = 490
local hub_Zone = 344
local gate_Item = 'Gate Potion'
local minFree_Slots = 19
local chestname = 'Reward Chest'

local function event_NotStanding_handler(line)
    mq.cmd('/warp target')
    mq.delay(750)
    mq.flushevents('WarpToTarget')
end
mq.event('WarpToTarget', "You must be standing to attack!", event_NotStanding_handler)

local function event_NextFloor_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'next') then
            mq.ExecuteTextLink(link)
            mq.flushevents("NextFloor")
            mq.delay(nextFloor_WaitTime)
            return
        end
    end
end
mq.event('NextFloor', "Sicard whispers, 'Hello #*#, you were last on Floor #*#.'", event_NextFloor_handler, { keepLinks = true })

local function event_HubToTower1_handler(line)
    print(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'Endless Tower') then
            mq.ExecuteTextLink(link)
            mq.flushevents("HubToTower1")
            mq.delay(1500)
            mq.delay(15000, function() return mq.TLO.Zone.ID() == tower_Zone end)
            mq.delay(750)
            mq.cmd('/hidecorpse all')
            mq.delay(750)
            mq.cmd('/hidecorpse looted')
            mq.doevents()
            return
        end
    end
end
mq.event('HubToTower1', "Bellboy whispers, 'Greetings, #*#.  You stand before the base of the [#*#].'", event_HubToTower1_handler, { keepLinks = true })

local function event_HubToTower2_handler(line)
    local links = mq.ExtractLinks(line)
    for _, link in ipairs(links) do
        local linkText = link.text or tostring(link)
        if string.find(linkText, 'enter') then
            mq.ExecuteTextLink(link)
            mq.flushevents("HubToTower2")
            mq.delay(nextFloor_WaitTime)
            mq.delay(30000, function() return mq.TLO.Zone.ID() == tower_Zone end)
            return
        end
    end
end
mq.event('HubToTower2', "Bellboy whispers, 'Are you prepared to #*# the tower?#*#'", event_HubToTower2_handler, { keepLinks = true })

local function event_HubToTower3_handler(line)
    mq.flushevents("HubToTower3")
    mq.cmdf('/target npc %s', 'Sicard')
    mq.delay(1500, function() return mq.TLO.Target.Name() == 'Sicard' end)
    mq.delay(250)
    if mq.TLO.Target.Distance3D() > 10 then
        mq.cmd('/warp target')
        mq.delay(1250)
    end
    mq.cmd('/hail')
    mq.delay(1500)
    mq.doevents('NextFloor')
end
mq.event('HubToTower3', "Sicard whispers, 'You haven\'t cleared your current floor yet.#*#'", event_HubToTower3_handler)

local IgnoreList = {
    "Sicard",
    "Statcard",
    "Reward Chest",
    "${Me.CleanName}'s Pet",
    "${Me.CleanName}"
}
mq.cmd('/squelch /alert clear 1')
for _, name in ipairs(IgnoreList) do
    mq.cmdf('/squelch /alert add 1 "%s"', name)
    mq.delay(25)
end
mq.cmd('/squelch /alert clear 2')
mq.cmdf('/squelch /alert add 2 "%s"', 'Reward Chest')
local noTargetCounter = 0
local noTargetFail = 100
local gotRewardFromChest = false
while towerMain_Loop do
    local mobCount = mq.TLO.SpawnCount('npc noalert 1')()
    local rewardChestCount = mq.TLO.SpawnCount('npc alert 2')()
    mq.delay(100)
    if rewardChestCount ~= 0 and not gotRewardFromChest then
        gotRewardFromChest = true
        mq.cmd('/lua stop aqo')
        mq.delay(750)
        mq.cmdf('/target npc "%s"', 'Reward Chest')
        mq.delay(1500, function() return mq.TLO.Target.Name() == 'Reward Chest' end)
        mq.delay(1250)
        mq.cmd('/warp target')
        mq.delay(1250)
        mq.cmd('/say /open')
        mq.delay(750)
        mq.cmd('/autoinv')
    end

    if mq.TLO.Me.XTarget(1).ID() and mq.TLO.Target() == nil and mq.TLO.Zone.ID() == tower_Zone then
        mq.TLO.Me.XTarget(1).DoTarget()
        mq.delay(2000, function() return mq.TLO.Target.ID() == mq.TLO.Me.XTarget(1).ID() end)
        if mq.TLO.Target() and mq.TLO.Target.Distance3D() > 10 then
            mq.cmd('/warp target')
            mq.delay(1250)
            mq.TLO.Me.XTarget(1).DoTarget()
        end
    end
    if mq.TLO.Me.FreeInventory() <= minFree_Slots and mq.TLO.Zone.ID() == tower_Zone then
        print('Low inventory space moving to hub.')
        mq.delay(250)
        mq.cmd('/lua stop aqo')
        mq.delay(750)
        mq.cmdf('/cast item "%s"', gate_Item)
        mq.delay(30000, function() return mq.TLO.Zone.ID() == hub_Zone end)
        mq.delay(250)
        if mq.TLO.Zone.ID() == hub_Zone then
            mq.cmd('/lua run chompsauto')
            while mq.TLO.Lua.Script('chompsauto').Status() == 'RUNNING' do
                mq.delay(100)
            end
        end
        mq.delay(100)
    end
    if mq.TLO.Zone.ID() == hub_Zone and mq.TLO.Me.FreeInventory() >= minFree_Slots then
        mq.cmdf('/target npc %s', 'BellBoy')
        mq.delay(1500, function() return mq.TLO.Target.Name() == 'BellBoy' end)
        mq.delay(250)
        mq.cmd('/nav target')
        mq.delay(15000, function() return not mq.TLO.Navigation.Active() end)
        mq.delay(100)
        mq.cmd('/hail')
        mq.delay(1000)
        mq.doevents('HubToTower1')
    end
    if mobCount == 0 and mq.TLO.Zone.ID() == tower_Zone and mq.TLO.Me.FreeInventory() >= minFree_Slots then
        print('Watcher script found no mobs moving onto new floor.')
        mq.cmd('/lua stop aqo')
        mq.cmdf('/target npc %s', 'Sicard')
        mq.delay(1500, function() return mq.TLO.Target.Name() == 'Sicard' end)
        mq.delay(250)
        mq.cmd('/warp target')
        mq.delay(1250)
        mq.cmd('/hail')
        mq.delay(1250)
        mq.doevents('NextFloor')
        mq.delay(2500)
        gotRewardFromChest = false
    end
    if mq.TLO.Lua.Script('aqo').Status() ~= 'RUNNING' and mobCount >= 1 and mq.TLO.Zone.ID() == tower_Zone then
        mq.cmdf('/lua run %s', 'aqo')
        mq.delay(1000)
        mq.cmd('/aqo pause off')
    end
    if not mq.TLO.Target() and mobCount >= 1 and not mq.TLO.Me.Casting() and mq.TLO.Zone.ID() == tower_Zone and mq.TLO.Me.FreeInventory() >= minFree_Slots then
        noTargetCounter = noTargetCounter + 1
        if noTargetCounter >= noTargetFail then
            mq.cmd('/target npc')
            mq.delay(1250)
            mq.cmd('/attack on')
            noTargetCounter = 0
        end
    end
    if mq.TLO.Target() and mq.TLO.Target.Distance3D() > 15 then
        mq.cmd('/warp target')
        mq.delay(1000)
    end
    -- printf("There are %d mobs in the zone (excluding specified ones).", mobCount)
    mq.doevents()
    mq.delay(towerMain_delay)
end



-- Bellboy whispers, 'Greetings, #*#. You stand before the base of #*#.#*#'
-- Bellboy whispers, 'Are you prepared to #*# the tower?#*#'

-- Sicard whispers, 'Hello #*#, you were last on floor #*#. You can #*# again, go to the #*# floor, or #*# your access.#*#'
-- Sicard whispers, 'Welcome back #*#, you can #*# again or #*# your access if you wish. Or if you\'re here to #*# me again... *cough* that\'s fine too.#*#'
