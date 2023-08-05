local mq = require('mq')
local movement = {}

function movement.GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function movement.NavToTarget(navTargetID,...)
    local args = { ... }
    local stopDist = args[1] or 10
    if args[1] ~= nil then
        stopDist = args[1]
        mq.cmdf('/nav id %d log=off distance=%s', navTargetID,stopDist)
        mq.delay(50)
    else
        mq.cmdf('/nav id %d log=off', navTargetID)
        mq.delay(50)
    end
    if mq.TLO.Navigation.Active() then
        while mq.TLO.Navigation.Active() do
            if (mq.TLO.Spawn(navTargetID).Distance3D() < stopDist) then
                mq.cmd('/nav stop')
            end
            mq.delay(50)
        end
        return true
    end
    return false
end

function movement.NavToXYZ(navX, navY, navZ, ...)
    local args = { ... }
    local stopDist = args[1] or 10
    if args[1] ~= nil then
        stopDist = args[1]
        mq.cmdf('/nav locxyz %d %d %d distance=%s', navX, navY, navZ,stopDist)
    else
        mq.cmdf('/nav locxyz %d %d %d', navX, navY, navZ)
    end
    mq.delay(50)
    if mq.TLO.Navigation.Active() then
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
            if mq.TLO.Math.Distance(navX..','..navY)() <= stopDist then
                break
            end
        end
        return true
    end
    return false
end

function movement.NavToStringXYZ(navString)
    mq.cmdf('/nav locxyz %s', navString)
    mq.delay(50)
    if mq.TLO.Navigation.Active() then
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
            if mq.TLO.Math.Distance(navString)() <= 10 then
                break
            end
        end
        return true
    end
    return false
end

return movement
