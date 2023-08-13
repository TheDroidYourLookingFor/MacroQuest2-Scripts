local mq = require('mq')
local movement = {}

function movement.GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function movement.NavToTarget(navTargetID, ...)
    local args = { ... }
    local stopDist = args[1] or 10
    mq.cmdf('/nav id %d log=off distance=%s', navTargetID, stopDist)
    mq.delay(1000, function () return mq.TLO.Navigation.Active() == true end)
    if mq.TLO.Navigation.Active() then
        while mq.TLO.Navigation.Active() do
            if (mq.TLO.Spawn(navTargetID).Distance3D() < stopDist) then
                mq.cmd('/nav stop')
            end
            mq.delay(1000, function () return mq.TLO.Navigation.Active() == false end)
        end
        return true
    end
    return false
end

function movement.NavToXYZ(navX, navY, navZ, ...)
    local args = { ... }
    local stopDist = args[1] or 10
    mq.cmdf('/nav locxyz %d %d %d distance=%s', navX, navY, navZ, stopDist)
    mq.delay(1000, function () return mq.TLO.Navigation.Active() == true end)
    if mq.TLO.Navigation.Active() then
        while mq.TLO.Navigation.Active() do
            if mq.TLO.Math.Distance(navX .. ',' .. navY)() <= stopDist then
                break
            end
            mq.delay(1000, function () return mq.TLO.Navigation.Active() == false end)
        end
        return true
    end
    return false
end

function movement.NavToStringXYZ(navString, ...)
    local args = { ... }
    local stopDist = args[1] or 10
    mq.cmdf('/nav locxyz %s', navString)
    mq.delay(1000, function () return mq.TLO.Navigation.Active() == true end)
    if mq.TLO.Navigation.Active() then
        while mq.TLO.Navigation.Active() do
            if mq.TLO.Math.Distance(navString)() <= stopDist then
                break
            end
            mq.delay(1000, function () return mq.TLO.Navigation.Active() == false end)
        end
        return true
    end
    return false
end

return movement
