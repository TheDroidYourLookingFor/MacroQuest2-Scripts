local mq = require('mq')

local zp_settings = {
    -- zonePull = 'Charm of Hate',
    zonePull = 'Derekthomx\'s Horrorkrunk Hook',
    zoneRefresh = 'Charm of Refreshing',
    move_amount = 30,
    shift_X = false,
    shift_Y = true
}
local function Main()
    -- mq.cmd('/say #deletecorpse')
    -- mq.delay(500)
    mq.cmdf('/useitem %s', zp_settings.zoneRefresh)
    mq.delay(500)

    mq.cmd('/target myself')
    mq.delay(500)
    mq.cmdf('/useitem %s', zp_settings.zonePull)
    mq.delay(250)
    local previous_x = mq.TLO.Me.X()
    local previous_y = mq.TLO.Me.Y()
    local previous_z = mq.TLO.Me.Z()
    if zp_settings.shift_Y then
        mq.cmdf('/warp loc %s %s %s', previous_y - zp_settings.move_amount, previous_x, previous_z)
        mq.delay(250)
    elseif zp_settings.shift_X then
        mq.cmdf('/warp loc %s %s %s', previous_y, previous_x - zp_settings.move_amount, previous_z)
        mq.delay(250)
    end
    mq.cmdf('/squelch /face fast %s,%s', previous_y, previous_x)
    mq.cmd('/target npc')
    mq.delay(250)
    mq.cmd('/squelch /attack on')
end

Main()
