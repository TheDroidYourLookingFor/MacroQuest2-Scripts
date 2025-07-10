local mq = require('mq')

local towerMain_Loop = true
local towerMain_delay = 1000

local function event_HubToTower1_handler(line)
    print(line)
    mq.flushevents()
end
mq.event('HubToTower1', "#*# whispers, '#*#'", event_HubToTower1_handler, { keepLinks = true })

while towerMain_Loop do
    mq.doevents()
    mq.delay(towerMain_delay)
end