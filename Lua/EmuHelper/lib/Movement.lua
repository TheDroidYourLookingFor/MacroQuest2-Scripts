local mq = require('mq')
local movement = {}

function movement.GetDistance(X, Y, Z)
    local deltaX = X - mq.TLO.Me.X()
    local deltaY = Y - mq.TLO.Me.Y()
    local deltaZ = Z - mq.TLO.Me.Z()
    local distance = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)
    return distance
end

function movement.NavToTarget(navTargetID)
    mq.cmdf('/nav id %d log=off', navTargetID)
    mq.delay(50)
    if mq.TLO.Navigation.Active() then
        local startTime = os.time()
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
            if os.difftime(os.time(), startTime) > 5 then
                break
            end
        end
        return true
    end
    return false
end

function movement.NavToXYZ(navX, navY, navZ, ...)
    local args = { ... }
    if args[1] ~= nil then
        mq.cmdf('/nav locxyz %d %d %d distance=%s', navX, navY, navZ,args[1])
    else
        mq.cmdf('/nav locxyz %d %d %d', navX, navY, navZ)
    end
    mq.delay(50)
    if mq.TLO.Navigation.Active() then
        local startTime = os.time()
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
            if os.difftime(os.time(), startTime) > 5 then
                break
            end
        end
        return true
    end
    return false
end

return movement
