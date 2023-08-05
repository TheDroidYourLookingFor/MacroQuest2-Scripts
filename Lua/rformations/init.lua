--Author - Szazor and CHATGPT (See it is useful - just a bit painful omg)

local mq = require "mq"
local math = require "math"

local distance = tonumber(...) or 10


local raiders = mq.TLO.Raid.Members
mq.cmd('/echo The Raid Total Members: ', raiders)

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

    mq.cmd('/echo Adding toon:', myRaid[toon_number][1], myRaid[toon_number][2])

    toon_number = toon_number + 1
end

local sin = math.sin
print('Sin: ', sin)
print('')
print('')

local cos = math.cos
print('Cos: ', cos)
print('')
print('')

local heading = mq.TLO.Me.Heading.Degrees
print('My heading is: ', heading)
print('')
print('')

local ID = mq.TLO.Me.ID
print('My ID Value is: ', ID)
print('')
print('')

local x = mq.TLO.Me.X
local y = mq.TLO.Me.Y
local z = mq.TLO.Me.Z

print('My X Value is: ', x)
print('')
print('')

print('My Y Value is: ', y)
print('')
print('')

print('My Z Value is: ', z)
print('')
print('')


mq.cmd('/echo Asking toons to spread out', distance)

-- Calculate the new X and Y coordinates for each raid member
local angle_per_member = 360 / raiders()
local angle_in_radians = math.rad(heading() - 90)
local player_x = x
local player_y = y
for i = 1, raiders() do
    local angle = math.rad(i * angle_per_member)
    local new_x = player_x() + (distance * math.cos(angle_in_radians + angle))
    local new_y = player_y() + (distance * math.sin(angle_in_radians + angle))

mq.cmd('/dex ', myRaid[i][1], ' /moveto loc ', new_y, new_x )

    mq.cmd('/echo shooting a DEX to: ', myRaid[i][1], ' to move to location ',new_y, new_x)
end
