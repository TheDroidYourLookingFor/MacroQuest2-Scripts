local mq = require('mq')
local formations = {}

local Output = function(msg) print('\aw[\atFormations :: Bind\aw] \a-t' .. msg) end
local Debug = function(msg) Output('[Debug] ' .. msg) end

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
        Output('Usage: /formation line [dist = 5] [direction north|south|west|east] [debug on|off]')
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
        elseif direction == 'south' then
            y = mq.TLO.Me.Y() - (dist * i)
            x = mq.TLO.Me.X() - (dist)
            z = mq.TLO.Me.Z()
        elseif direction == 'west' then
            y = mq.TLO.Me.Y() + (dist)
            x = mq.TLO.Me.X() + (dist * i)
            z = mq.TLO.Me.Z()
        elseif direction == 'east' then
            y = mq.TLO.Me.Y() - (dist)
            x = mq.TLO.Me.X() - (dist * i)
            z = mq.TLO.Me.Z()
        end
        local cmd = string.format('dex %s /nav locxyz %.2f %.2f %.2f distance=0.00', mq.TLO.Group.Member(i).Name(), x, y,
            z)
        mq.cmd[cmd]()
        if debug then Debug('/' .. cmd) end
        mq.delay(100)
    end
end

formations.circle = function(radius, debug)
    -- set defaults
    radius = radius or 10
    if debug == 'on' then debug = true else debug = false end

    -- check inputs / print formation usage
    if tonumber(radius) == nil then
        Output('Usage: /formation circle [radius = 10] [debug on|off]')
        return
    end

    local num_members = mq.TLO.Group.Members()

    -- Calculate angle increment based on the number of members
    local angle_increment = (2 * math.pi) / num_members

    local main_character_x = mq.TLO.Me.X()
    local main_character_y = mq.TLO.Me.Y()
    local main_character_z = mq.TLO.Me.Z()

    for i = 1, num_members do
        -- Calculate angle for each member
        local angle = angle_increment * (i - 1)

        -- Calculate position around the main character
        local x = main_character_x + radius * math.cos(angle)
        local y = main_character_y + radius * math.sin(angle)
        local z = main_character_z

        -- Move the character to the calculated position
        local cmd = string.format('dex %s /nav locxyz %.2f %.2f %.2f distance=0.00', mq.TLO.Group.Member(i).Name(), x, y,
            z)
        mq.cmd[cmd]()

        -- Optionally print debug information
        if debug then Debug('/' .. cmd) end

        -- Add a slight delay before moving the next character
        mq.delay(100)
    end
end

return formations
