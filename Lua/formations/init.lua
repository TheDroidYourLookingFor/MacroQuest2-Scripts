--[[
    Created by Special.Ed
        halfmoon formation - ported from kaens macro
    Shout out to the homies:
        Lads
        Dannuic (my on again off again thing)
        Knightly (no, i won't take that bet) (he knows math too)
--]]

local mq = require('mq')
local formations = {}

local Output = function(msg) print('\aw[\atFormations :: Bind\aw] \a-t' .. msg) end
local Debug = function(msg) Output('[Debug] ' .. msg) end

local print_usage = function()
    local vals
    Output('Usage: /formation <name>')
    for k, v in pairs(formations) do vals = k .. ', ' end
    Output('Available formations: ' .. vals:gsub(', $', ''))
end

-- add your formation code like this
-- note: they can take whatever arguments you want to pass in

-- formations.example = function(dist, someRandomizeValue, debug, etc...)
--   -- do the things
-- end

formations.halfmoon = function(dist, debug)
    -- set defaults
    dist = dist or 10
    if debug == 'on' then debug = true else debug = false end

    -- check inputs / print formation usage
    if tonumber(dist) == nil then
        Output('Usage: /formation halfmoon [dist = 20] [debug on|off]')
        return
    end

    -- calc the things
    for i = 1, mq.TLO.Group.Members() do
        local y = mq.TLO.Me.Y() + (dist * math.sin(((i * 36) + (mq.TLO.Me.Heading.Degrees() - 198)) / (180 / math.pi)))
        local x = mq.TLO.Me.X() + (dist * math.cos(((i * 36) + (mq.TLO.Me.Heading.Degrees() - 198)) / (180 / math.pi)))
        local cmd = string.format('dex %s /moveto loc %.2f %.2f', mq.TLO.Group.Member(i).Name(), y, x)
        mq.cmd[cmd]()
        if debug then Debug('/' .. cmd) end
        mq.delay(100)
    end
end

formations.line = function(dist, direction, debug)
    -- set defaults
    direction = direction or 'north'
    dist = dist or 10
    if debug == 'on' then debug = true else debug = false end

    -- check inputs / print formation usage
    if tonumber(dist) == nil then
        print(dist)
        Output('Usage: /formation line [dist = 5] [direction north|west] [debug on|off]')
        return
    end

    -- calc the things
    for i = 1, mq.TLO.Group.Members() do
        local y
        local x
        local z
        if direction == 'north' then
            y = mq.TLO.Me.Y() + (dist * i)
            x = mq.TLO.Me.X() + (dist)
            z = mq.TLO.Me.Z()
        elseif direction == 'west' then
            y = mq.TLO.Me.Y() + (dist)
            x = mq.TLO.Me.X() + (dist * i)
            z = mq.TLO.Me.Z()
        end
        local cmd = string.format('dex %s /nav locxyz %.2f %.2f %.2f distance=0.00', mq.TLO.Group.Member(i).Name(), x, y, z)
        mq.cmd[cmd]()
        if debug then Debug('/' .. cmd) end
        mq.delay(100)
    end
end

local bind_formation = function(name, ...)
    local args = { ... }
    if formations[name] ~= nil then
        formations[name](unpack(args))
    else
        print_usage()
    end
end

mq.bind('/formation', bind_formation)

while true do mq.delay(100) end
