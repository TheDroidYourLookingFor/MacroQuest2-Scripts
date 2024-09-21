local mq = require('mq')

local Janitor = {}

Janitor.Settings = {
    main_Loop = true,
    camp_Check = true,
    hide_Corpses = true,
    huntZoneID = mq.TLO.Zone.ID(),
    camp_X = mq.TLO.Me.X(),
    camp_Y = mq.TLO.Me.Y(),
    camp_Z = mq.TLO.Me.Z(),
    returnToCampDistance = 100
}

function Janitor.CheckZone()
    if mq.TLO.Zone.ID() ~= Janitor.Settings.huntZoneID and mq.TLO.DynamicZone() ~= nil then
        mq.delay(1000)
        mq.cmd('/say #enter')
        mq.delay(50000, function() return mq.TLO.Zone.ID()() == Janitor.Settings.huntZoneID end)
        mq.delay(1000)
        mq.cmdf('/warp loc %s %s %s', Janitor.Settings.camp_Y, Janitor.Settings.camp_X, Janitor.Settings.camp_Z)
    end
end

function Janitor.CheckDistanceToXYZ()
    local deltaX = Janitor.Settings.camp_X - mq.TLO.Me.X()
    local deltaY = Janitor.Settings.camp_Y - mq.TLO.Me.Y()
    local deltaZ = Janitor.Settings.camp_Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function Janitor.MoveToCamp()
    if mq.TLO.Zone.ID() == Janitor.Settings.huntZoneID then
        if Janitor.CheckDistanceToXYZ() > Janitor.Settings.returnToCampDistance then
            mq.cmdf('/warp loc %s %s %s', Janitor.Settings.camp_Y, Janitor.Settings.camp_X, Janitor.Settings.camp_Z)
            mq.delay(500)
        end
    end
end

function Janitor.Main()
    while Janitor.Settings.main_Loop do
        Janitor.CheckZone()
        if mq.TLO.Me.Level() < 80 then mq.cmd('/alt on 90') end
        if mq.TLO.Me.Level() >= 80 then mq.cmd('/alt on 100') end
        if Janitor.Settings.camp_Check then Janitor.MoveToCamp() end
        if Janitor.Settings.hide_Corpses and mq.TLO.SpawnCount('corpse')() > 50 then mq.cmd('/hidecorpse all') end
        mq.delay(1000)
    end
end

Janitor.Main()
