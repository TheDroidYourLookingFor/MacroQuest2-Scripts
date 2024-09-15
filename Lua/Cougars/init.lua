local mq            = require('mq')
local lootutils     = require 'Cougars.lib.LootUtils'
local Casting       = require('Cougars.lib.Casting')
local Navigation    = require('Cougars.lib.Movement')

local CougarsConfig = require('lib.config')
CougarsConfig:LoadSettings()

local MainLoop = true

function ScriptInfo()
    local level = 1
    local sName
    local sLine
    while true do
        local info = debug.getinfo(level, "l")
        if not info then break end -- a Lua function
        sName = 'Cougars'
        sLine = info.currentline
        level = level + 1
    end
    return sName .. ' @ ' .. sLine
end

function CONSOLEMETHOD(consoleMessage, ...)
    if CougarsConfig.Globals.debug then
        printf("[%s] ---> " .. consoleMessage, ScriptInfo(), ...)
    end
end

function PRINTMETHOD(printMessage, ...)
    printf(CougarsConfig.Colors.u .. "[Cougars]" .. CougarsConfig.Colors.w .. printMessage .. "\aC\n", ...)
end

local function MoveXYZ(X, Y, Z, StopAt)
    Navigation.NavToXYZ(X, Y, Z)
end

local function MoveToID(targetID, ...)
    local args = { ... }
    if args[1] ~= nil then
        Navigation.NavToTarget(targetID, args[1])
    else
        Navigation.NavToTarget(targetID)
    end
end

local function Pet_CheckHP()
    if mq.TLO.Pet.ID() ~= 0 and mq.TLO.Pet.PctHPs() <= CougarsConfig.Globals.Heal_Pet_Pct and mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(CougarsConfig.Globals.Heal_Name).Mana() then
        if not mq.TLO.Pet.LineOfSight() and mq.TLO.Pet.Distance() > 98 then
            MoveToID(mq.TLO.Pet.ID(), 'distance=40 lineofsight=on')
        end
        Casting.CastSpell(mq.TLO.Pet.ID(), CougarsConfig.Globals.Heal_Name, 8)
    end
end

local function Pet_CheckBuffs()
    if CougarsConfig.Globals.Cast_Pet_Haste then
        if mq.TLO.Pet.ID() ~= 0 and not mq.TLO.Pet.Buff(CougarsConfig.Globals.Pet_Haste) and mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(CougarsConfig.Globals.Pet_Haste).Mana() then
            if not mq.TLO.Pet.LineOfSight() and mq.TLO.Pet.Distance() > 98 then
                MoveToID(mq.TLO.Pet.ID(), 'distance=40 lineofsight=on')
            end
            mq.TLO.Target.DoTarget()
            Casting.CastSpell(mq.TLO.Pet.ID(), CougarsConfig.Globals.Pet_Haste, 7)
        end
    end
end


local function Pet_Checks()
    Pet_CheckHP()
    Pet_CheckBuffs()
end

local function Move_To_Next_Level()
    mq.cmdf('/target %s', CougarsConfig.Globals.Name_Boss)
    mq.delay(5000, mq.TLO.Target.ID)
    mq.cmd('/hail')
    mq.delay(1000)
    mq.doevents('TaskFinished')
    mq.delay(2000)
    mq.cmd('/say progression')
    mq.delay(2000)
    mq.cmd('/say defeat')
    mq.delay(2000)
    mq.doevents('TaskTimer')
    mq.delay(2000)
    mq.flushevents()
    mq.delay(2000)
    mq.cmd('/notify LargeDialogWindow LDW_YesButton leftmouseup')
end

local function LootBoss()
    local BossName = mq.TLO.Target.CleanName()
    PRINTMETHOD('Looting %s%s%s.', CougarsConfig.Colors.g, BossName, CougarsConfig.Colors.x)
    lootutils.lootMobs()
    if mq.TLO.SpawnCount('npccorpse radius 200')() == 0 then Move_To_Next_Level() end
end

local function Move_To_Corpse()
    mq.cmd('/target corpse')
    mq.delay(5000, mq.TLO.Target.ID)
    if not mq.TLO.Target or (mq.TLO.Target.ID() == mq.TLO.Pet.ID() or mq.TLO.Target.ID() == mq.TLO.Me.ID()) then
        Move_To_Corpse()
    end
    if mq.TLO.Target.CleanName() == CougarsConfig.Boss.Safe_Locations[2].Name then
        mq.cmd('/stick')
        mq.delay(10000, function() return not mq.TLO.Me.Moving() end)
    else
        MoveToID(mq.TLO.Target.ID(), 'distance=10 lineofsight=on')
    end
end

local function Move_To_Boss()
    if mq.TLO.Zone.ID() == 422 then
        mq.cmdf('%s We died or something as we are in Barren!!', CougarsConfig.Globals.Chat_Command)
        mq.cmd('/lua stop Cougars')
    end
    mq.cmdf('/target %s', CougarsConfig.Globals.Name_Boss)
    mq.delay(5000, mq.TLO.Target.ID)
    mq.cmd('/face')

    if mq.TLO.Target.CleanName() == 'Event Ender Steve' then
        LootBoss()
        return
    end
    --if mq.TLO.Target.CleanName() then end
    if mq.TLO.Target.ID() == mq.TLO.Pet.ID() or mq.TLO.Target.ID() == mq.TLO.Me.ID() then
        mq.cmd('/target clear')
        Move_To_Boss()
    end
    if not mq.TLO.Target() then
        mq.cmdf('%s We could not find a boss on this level!', CougarsConfig.Globals.Chat_Command)
        mq.cmd('/lua stop Cougars')
    end
    if mq.TLO.Target.CleanName() == CougarsConfig.Boss.Safe_Locations[1].Name or mq.TLO.Target.CleanName() == CougarsConfig.Boss.Safe_Locations[2].Name then
        if mq.TLO.Target.CleanName() == CougarsConfig.Boss.Safe_Locations[1].Name then
            MoveXYZ(CougarsConfig.Boss.Safe_Locations[1].X, CougarsConfig.Boss.Safe_Locations[1].Y,
                CougarsConfig.Boss.Safe_Locations[1].Z, 5)
        end
        if mq.TLO.Target.CleanName() == CougarsConfig.Boss.Safe_Locations[2].Name then
            MoveXYZ(CougarsConfig.Boss.Safe_Locations[2].X, CougarsConfig.Boss.Safe_Locations[2].Y,
                CougarsConfig.Boss.Safe_Locations[2].Z, 5)
        end
    else
        MoveToID(mq.TLO.Pet.ID(), 'distance=' .. CougarsConfig.Globals.NavStopDistance .. ' lineofsight=off')
    end

    mq.delay(100)
    mq.cmdf('%s Starting attack on boss %s!', CougarsConfig.Globals.Chat_Command, mq.TLO.Target.CleanName())
    mq.delay(100)
    mq.cmdf('%s', CougarsConfig.Globals.Engage_Command)
    mq.delay(1000)
    if CougarsConfig.Globals.Engage_Command2 ~= nil then mq.cmdf('%s', CougarsConfig.Globals.Engage_Command2) end
    mq.delay(1000)
    mq.cmd('/pet attack')
end

local function event_task_update(line, sender)
    CONSOLEMETHOD('function event_task_update(line, sender)')
    mq.cmdf('%s Task %s completed!', CougarsConfig.Globals.Chat_Command, sender)
    mq.delay(1000)
    Move_To_Corpse()
    LootBoss()
    Move_To_Next_Level()
end

local function event_task_finished(line, sender)
    CONSOLEMETHOD('function event_task_finished(line, sender)')
    mq.cmdf('%s Task %s completed! Headed to barren.', CougarsConfig.Globals.Chat_Command, sender)
    mq.cmdf('%s', CougarsConfig.Globals.Home_Command)
    mq.delay(60000, function() return mq.TLO.Zone.ID() == CougarsConfig.Globals.Home_ZoneID end)
    mq.cmdf('/target pc %s', CougarsConfig.Globals.Loot_Character)
    mq.delay(5000, mq.TLO.Target.ID)
    MoveToID(mq.TLO.Target.ID())
    mq.cmdf('%s', CougarsConfig.Globals.Drop_Off_Command)
    mq.delay(10000)
    mq.cmd('/lua stop Cougars')
end

local function event_task_timer(line, sender)
    CONSOLEMETHOD('function event_task_timer(line, sender)')
    mq.cmdf('%s We have a task timer and will try to get the task again.', CougarsConfig.Globals.Chat_Command)
    mq.delay(30000)
    mq.cmd('/target npc')
    mq.delay(5000, mq.TLO.Target.ID)
    mq.delay(500)
    mq.cmd('/say defeat')
    mq.doevents()
    mq.delay(1000)
    mq.cmd('/notify LargeDialogWindow LDW_YesButton leftmouseup')
end

local function event_new_zone(line, sender)
    CONSOLEMETHOD('function event_new_zone(line, sender)')
    mq.cmdf('%s We have moved into a new zone.', CougarsConfig.Globals.Chat_Command)
    mq.delay(500)
    Move_To_Boss()
end

mq.event('TaskUpdate', "Your task '#1#' has been updated.#*#", event_task_update)
mq.event('TaskFinished', "#*#This mission set has been completed#*#", event_task_finished)
mq.event('NewZone', "You have entered #1#.", event_task_timer)
mq.event('TaskTimer', "Player '#*#' currently has a lockout for #*#", event_new_zone)

local function Main()
    if not mq.TLO.Plugin('MQ2Nav').IsLoaded() then mq.cmd('/plugin mq2nav load') end

    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Cougars Bot Started ++')
    PRINTMETHOD('Current Class: %s', CougarsConfig.Globals.CurLoadedClass)
    PRINTMETHOD('Current Heal: %s', CougarsConfig.Globals.Heal_Name)

    CONSOLEMETHOD('Main Loop Entry')
    while MainLoop do
        if mq.TLO.Zone.ID() == 422 then mq.cmdf('%s', '/lua stop Cougars') end
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then MainLoop = false end
        if not mq.TLO.Me.Casting() and mq.TLO.Me.Standing() and not mq.TLO.Me.Mount.ID() and (not CougarsConfig.Globals.Use_Horse or (CougarsConfig.Globals.Use_Horse and mq.TLO.FindItem(CougarsConfig.Globals.Horse_Item).ID ~= 0)) then
            mq.TLO.Me.Sit()
        end
        Pet_Checks()
        if not mq.TLO.Pet.Combat() then Move_To_Boss() end
        mq.doevents()
        mq.delay(250)
    end
    CONSOLEMETHOD('Main Loop Exit')
end
Main()
