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

formations.halfmoon = function(dist)
    -- set defaults
    dist = dist or 10

    -- check inputs / print formation usage
    if tonumber(dist) == nil then
        Output('Usage: /formation halfmoon [dist = 20]')
        return
    end

    local main_character_x = mq.TLO.Me.X()
    local main_character_y = mq.TLO.Me.Y()

    if mq.TLO.Raid.Members() > 0 then
        -- calc the things
        for i = 1, mq.TLO.Raid.Members() do
            local y = main_character_y +
                (dist * math.sin(((i * 36) + (mq.TLO.Me.Heading.Degrees() - 198)) / (180 / math.pi)))
            local x = main_character_x +
                (dist * math.cos(((i * 36) + (mq.TLO.Me.Heading.Degrees() - 198)) / (180 / math.pi)))
            mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', mq.TLO.Raid.Member(i).Name(), x, y)
            mq.delay(100)
        end
    else
        -- calc the things
        for i = 1, mq.TLO.Group.Members() do
            local y = main_character_y +
                (dist * math.sin(((i * 36) + (mq.TLO.Me.Heading.Degrees() - 198)) / (180 / math.pi)))
            local x = main_character_x +
                (dist * math.cos(((i * 36) + (mq.TLO.Me.Heading.Degrees() - 198)) / (180 / math.pi)))
            mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', mq.TLO.Group.Member(i).Name(), x, y)
            mq.delay(100)
        end
    end
end

formations.line = function(dist, direction)
    -- set defaults
    direction = direction or 'north'
    dist = dist or 10

    -- check inputs / print formation usage
    if tonumber(dist) == nil then
        Output('Usage: /formation line [dist = 5] [direction north|south|west|east]')
        return
    end

    local main_character_x = mq.TLO.Me.X()
    local main_character_y = mq.TLO.Me.Y()

    if mq.TLO.Raid.Members() > 0 then
        -- calc the things
        for i = 1, mq.TLO.Raid.Members() do
            local y
            local x
            if direction == 'north' then
                y = main_character_y + (dist * i)
                x = main_character_x + (dist)
            elseif direction == 'south' then
                y = main_character_y - (dist * i)
                x = main_character_x - (dist)
            elseif direction == 'west' then
                y = main_character_y + (dist)
                x = main_character_x + (dist * i)
            elseif direction == 'east' then
                y = main_character_y - (dist)
                x = main_character_x - (dist * i)
            end
            mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', mq.TLO.Raid.Member(i).Name(), x, y)
            mq.delay(100)
        end
    else
        -- calc the things
        for i = 1, mq.TLO.Group.Members() do
            local y
            local x
            if direction == 'north' then
                y = main_character_y + (dist * i)
                x = main_character_x + (dist)
            elseif direction == 'south' then
                y = main_character_y - (dist * i)
                x = main_character_x - (dist)
            elseif direction == 'west' then
                y = main_character_y + (dist)
                x = main_character_x + (dist * i)
            elseif direction == 'east' then
                y = main_character_y - (dist)
                x = main_character_x - (dist * i)
            end
            mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', mq.TLO.Group.Member(i).Name(), x, y)
            mq.delay(100)
        end
    end
end

formations.circle = function(radius)
    -- set defaults
    radius = radius or 30

    -- check inputs / print formation usage
    if tonumber(radius) == nil then
        Output('Usage: /formation circle [radius = 10]')
        return
    end

    local main_character_x = mq.TLO.Me.X()
    local main_character_y = mq.TLO.Me.Y()

    if mq.TLO.Raid.Members() > 0 then
        local num_members = mq.TLO.Raid.Members()

        -- Calculate angle increment based on the number of members
        local angle_increment = (2 * math.pi) / (num_members - 1)

        for i = 1, num_members do
            -- Calculate angle for each member
            local angle = angle_increment * (i - 1)

            -- Calculate position around the main character
            local x = main_character_x + radius * math.cos(angle)
            local y = main_character_y + radius * math.sin(angle)

            -- Move the character to the calculated position
            mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', mq.TLO.Raid.Member(i).Name(), x, y)

            -- Add a slight delay before moving the next character
            mq.delay(100)
        end

        mq.delay(1500)
        mq.cmdf('/dgre /target id %s', mq.TLO.Me.ID())
        mq.delay(500)
        mq.cmd('/dgre /face fast')
    else
        local num_members = mq.TLO.Group.Members()

        -- Calculate angle increment based on the number of members
        local angle_increment = (2 * math.pi) / (num_members - 1)

        for i = 1, num_members do
            -- Calculate angle for each member
            local angle = angle_increment * (i - 1)

            -- Calculate position around the main character
            local x = main_character_x + radius * math.cos(angle)
            local y = main_character_y + radius * math.sin(angle)

            -- Move the character to the calculated position
            mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', mq.TLO.Group.Member(i).Name(), x, y)

            -- Add a slight delay before moving the next character
            mq.delay(100)
        end

        mq.delay(1500)
        mq.cmdf('/dgge /target id %s', mq.TLO.Me.ID())
        mq.delay(500)
        mq.cmd('/dgge /face fast')
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
