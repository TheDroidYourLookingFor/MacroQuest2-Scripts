local mq = require "mq"
local math = require "math"

local distance = tonumber(...) or 30

local raiders = mq.TLO.Raid.Members
printf('The Raid Total Members: %s', raiders)

-- Initialise the Raid Array
local myRaid = {}
for i = 1, raiders() do
    myRaid[i] = {} -- create a new row
    for j = 1, 3 do
        myRaid[i][j] = 0
    end
end

local toon_number = 1

-- TODO - sort the raid array my Class (Tanks up front, Casters to the back)

while toon_number <= raiders() do
    local Toon_Name = mq.TLO.Raid.Member(toon_number).Name()
    local Toon_Class = mq.TLO.Raid.Member(toon_number).Class()

    myRaid[toon_number][1] = Toon_Name
    myRaid[toon_number][2] = Toon_Class

    toon_number = toon_number + 1
end

printf('Asking toons to spread out %s', distance)

-- Calculate the new X and Y coordinates for each raid member
local angle_per_member = 360 / raiders()
local angle_in_radians = math.rad(mq.TLO.Me.Heading.Degrees() - 90)
local player_x = mq.TLO.Me.X
local player_y = mq.TLO.Me.Y
for i = 1, raiders() do
    local angle = math.rad(i * angle_per_member)
    local new_x = player_x() + (distance * math.cos(angle_in_radians + angle))
    local new_y = player_y() + (distance * math.sin(angle_in_radians + angle))

    mq.cmdf('/dex %s /nav locxy %.2f %.2f distance=0.00', myRaid[i][1], new_x, new_y)
    mq.delay(100)
end
mq.delay(1500)
mq.cmdf('/dgre /target id %s', mq.TLO.Me.ID())
mq.delay(500)
mq.cmd('/dgre /face fast')
