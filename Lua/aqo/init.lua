local mq = require('mq')
require 'ImGui'
local CONSOLE = ImGui.ConsoleWidget.new("##AQOConsole")
CONSOLE.maxBufferLines = 1000

local logger = require('utils.logger')
logger.setConsole(CONSOLE)

local commands = require('interface.commands')
local config = require('interface.configuration')
local ui = require('interface.ui')
local tlo = require('interface.tlo')

-- local loot = require('utils.lootutils')
local loot = require('DroidLoot.lib.LootUtils')
local movement = require('utils.movement')
local timer = require('libaqo.timer')

local common = require('common')
local constants = require('constants')
local mode = require('mode')
local state = require('state')
local status = require('status')

ui.setConsole(CONSOLE)

local class = require('classes.'..mq.TLO.Me.Class.ShortName():lower())

aqo = {}

local routines = {'assist','buff','camp','conditions','cure','debuff','events','heal','mez','pull','tank'}
for _,routine in ipairs(routines) do
    aqo[routine] = require('routines.'..routine)
    aqo[routine].init(class)
end

local function init()
    class:init()
    aqo.events.initClassBasedEvents()
    commands.init(class)
    ui.init(class)
    tlo.init(class)
    status.init()

    state.currentZone = mq.TLO.Zone.ID()
    state.subscription = mq.TLO.Me.Subscription()
    config.loadIgnores()

    if state.emu then
        mq.cmd('/hidecorpse looted')
    else
        mq.cmd('/hidecorpse alwaysnpc')
    end
    mq.cmd('/pet ghold on')
    mq.cmd('/squelch /stick set verbflags 0')
    -- mq.cmd('/squelch /stick set delaystrafe off')
    mq.cmd('/squelch /stick set delaystrafe on')
    mq.cmd('/squelch /stick set strafemindelay 500')
    mq.cmd('/squelch /stick set strafemaxdelay 1000')
    mq.cmd('/squelch /plugin melee unload noauto')
    mq.cmd('/squelch /rez accept on')
    mq.cmd('/squelch /rez pct 90')
    mq.cmd('/squelch /assist off')
    mq.cmd('/squelch /autofeed 5000')
    mq.cmd('/squelch /autodrink 5000')
    mq.cmdf('/setwintitle %s (Level %s %s)', mq.TLO.Me.CleanName(), mq.TLO.Me.Level(), state.class)
end

---Check if the current game state is not INGAME, and exit the script if it is.
---Otherwise, update state for the current loop so we don't have to go to the TLOs every time.
local function updateLoopState()
    if mq.TLO.MacroQuest.GameState() ~= 'INGAME' then
        logger.info('Not in game, stopping aqo.')
        mq.exit()
    end
    state.actionTaken = false
end

---Reset assist/tank ID and turn off attack if we have no target or are targeting a corpse
---If targeting a corpse, also clear target unless its a healer
local clearTargetTimer = timer:new(5000)
local function checkTarget()
    local targetType = mq.TLO.Target.Type()
    local masterType = mq.TLO.Target.Master.Type()
    local isPC = targetType == 'PC' or (targetType == 'Pet' and masterType == 'PC')
    if not targetType or targetType == 'Corpse' then
        state.assistMobID = 0
        state.tankMobID = 0
        if mq.TLO.Me.Combat() then
            mq.cmd('/attack off')
        elseif mq.TLO.Me.AutoFire() then
            mq.cmd('/autofire off')
        end
        if mq.TLO.Stick.Active() then
            mq.cmd('/squelch /stick off')
        end
        if targetType == 'Corpse' then
            if clearTargetTimer.start_time == 0 then
                -- clearing target in 3 seconds
                clearTargetTimer:reset()
            elseif clearTargetTimer:expired() then
                mq.cmd('/squelch /mqtarget clear')
                clearTargetTimer:reset(0)
            end
        elseif clearTargetTimer.start_time ~= 0 then
            clearTargetTimer:reset(0)
        end
    -- elseif targetType == 'Pet' or targetType == 'PC' then
    elseif isPC then
        state.assistMobID = 0
        state.tankMobID = 0
        if mq.TLO.Me.Combat() then mq.cmd('/attack off') end
    end
end

local function resetClearTargets()
    if state.cleartargets and not mq.TLO.Spawn('npc radius 60').Aggressive() then
        state.cleartargets = false
        config.getOrSetOption('MODE', config.get('MODE'), state.previousmode, 'MODE')
        state.previousmode = nil
    end
end

local function checkFD()
    if mq.TLO.Me.Feigning() and (not constants.fdClasses[state.class] or not state.didFD) then
        mq.cmd('/stand')
    end
end

---Remove harmful buffs such as lich if HP is getting low, regardless of paused state
local torporLandedInCombat = false
local function buffSafetyCheck()
    if state.class == 'NEC' and mq.TLO.Me.PctHPs() < 40 then
        if class.spells.lich then
            mq.cmdf('/removebuff %s', class.spells.lich.Name)
            if class.spells.flesh then
                mq.cmdf('/removebuff %s', class.spells.flesh.Name)
            end
        end
        if not mq.TLO.Me.Feigning() and not mq.TLO.Me.Sitting() and mq.TLO.Me.CombatState() ~= 'COMBAT' then
            mq.cmd('/sit')
        end
    end
    if not torporLandedInCombat and mq.TLO.Me.Song('Transcendent Torpor')() and mq.TLO.Me.CombatState() == 'COMBAT' then
        torporLandedInCombat = true
    end
    if (torporLandedInCombat or mq.TLO.SpawnCount('xtarhater radius 25')() == 0) and mq.TLO.Me.CombatState() ~= 'COMBAT' and mq.TLO.Me.Song('Transcendent Torpor')() then
        mq.cmdf('/removebuff "Transcendent Torpor"')
        torporLandedInCombat = false
    end
    if state.class == 'MNK' and mq.TLO.Me.PctHPs() < config.get('HEALPCT') and mq.TLO.Me.AbilityReady('Mend')() then
        mq.cmd('/doability mend')
    end
    -- emu doesnt split out invis info?
    -- if not state.paused and state.class ~= 'ROG' and mq.TLO.Me.Invis() and not mq.TLO.Me.Invis(1)() and not mq.TLO.Me.Invis(2)() then
    --     mq.cmd('/makemevis')
    -- end
    if not state.paused and state.mobCountNoPets > 0 and state.fadeTimer:expired() then mq.cmd('/makemevis') end
    if mq.TLO.Me.Buff('Resurrection Sickness')() and mq.TLO.Me.Aura(1)() then
        mq.cmdf('/removeaura %s', mq.TLO.Me.Aura(1)())
    end
end

local lootMyCorpseTimer = timer:new(2000)
local reloadTimer = timer:new(60000)
local function doLooting()
    local myCorpse = mq.TLO.Spawn('pccorpse '..mq.TLO.Me.CleanName()..'\'s corpse radius 100')
    if mq.TLO.SpawnCount('pccorpse '..mq.TLO.Me.CleanName()..'\'s corpse radius 100')() > 1 and reloadTimer:expired() then mq.cmd('/reload') mq.delay(5000) reloadTimer:reset() end
    -- if not mq.TLO.Me.Combat() and mq.TLO.Me.CombatState() ~= 'COMBAT' and myCorpse() and lootMyCorpseTimer:expired() then
    if myCorpse() and not mq.TLO.Me.Combat() and lootMyCorpseTimer:expired() then
        lootMyCorpseTimer:reset()
        myCorpse.DoTarget()
        if mq.TLO.Target.Type() == 'Corpse' then
            mq.cmd('/keypress CONSIDER')
            mq.delay(500)
            mq.doevents('eventCannotRezNew')
            if state.cannotRez then
                state.cannotRez = nil
                mq.cmd('/corpse')
                movement.navToTarget(nil, 10000)
                if (mq.TLO.Target.Distance3D() or 100) > 10 then return end
                loot.lootMyCorpse()
                if mq.TLO.Cursor() then mq.cmd('/autoinv') end
                state.actionTaken = true
                return
            end
        end
    end
    if config.get('LOOTMOBS') and (state.mobCount == 0 or config.get('LOOTCOMBAT')) and not state.pullStatus then
        state.actionTaken = loot.lootMobs(1)
        if state.lootBeforePull then state.lootBeforePull = false end
    end
end

local function handleStates(class)
    -- Async state handling
    --if state.looting then loot.lootMobs() return true end
    --if state.selling then loot.sellStuff() return true end
    --if state.banking then loot.bankStuff() return true end
    if not state.handlePositioningState() then return true end
    if not state.handleMemSpell() then return true end
    if not state.handleCastingState(class) then return true end
    if not state.handleQueuedAction() then return true end
end

local function main()
    init()

    local debugTimer = timer:new(3000)
    local statusTimer = timer:new(1000)
    local delay = 500
    -- Main Loop
    while true do
        if state.restart then
            mq.cmd('/timed 5 /lua run aqo')
            return
        end
        local loopStart = mq.gettime()
        if state.debug and debugTimer:expired() then
            logger.debug(logger.flags.aqo.main, 'Start Main Loop')
            debugTimer:reset()
        end

        mq.doevents()
        updateLoopState()
        buffSafetyCheck()
        if not state.paused and common.inControl() then
            if not handleStates(class) then
                if state.reacquireTargetID then mq.cmdf('/mqtar id %s', state.reacquireTargetID) state.reacquireTargetID = nil end
                aqo.camp.cleanTargets()
                checkTarget()
                resetClearTargets()
                if not mq.TLO.Me.Invis() and not common.isBlockingWindowOpen() then
                    -- do active combat assist things when not paused and not invis
                    checkFD()
                    common.checkCursor()
                    if state.emu then
                        doLooting()
                    end
                    if not state.actionTaken then
                        class:mainLoop()
                    end
                    delay = 16
                else
                    -- stay in camp or stay chasing chase target if not paused but invis
                    local pet_target_id = mq.TLO.Pet.Target.ID() or 0
                    if mq.TLO.Pet.ID() > 0 and pet_target_id > 0 then mq.cmd('/pet back') end
                    aqo.camp.mobRadar()
                    if (mode:isTankMode() and state.mobCount > 0) or (mode:isAssistMode() and aqo.assist.shouldAssist()) or mode:getName() == 'huntertank' then mq.cmd('/makemevis') end
                    aqo.camp.checkCamp()
                    common.checkChase()
                    common.rest()
                    delay = 16
                end
            end
            -- printf('%s %s %s %s', state.useManastone, state.manastoneCount, state.actionTaken, mq.TLO.Me.Casting())
            if state.useManastone and state.manastoneCount < 10 and not state.actionTaken and not mq.TLO.Me.Casting() then
                -- printf('should use manastone')
                local manastoneTimer = timer:new(500)
                while mq.TLO.Me.PctHPs() > 50 and mq.TLO.Me.PctMana() < 90 do
                    mq.cmd('/useitem Manastone')
                    mq.delay(1)
                    if manastoneTimer:expired() then break end
                end
                state.manastoneCount = state.manastoneCount + 1
                if state.manastoneCount == 10 then
                    state.useManastone = false
                    state.manastoneCount = 0
                end
            end
        else
            if mq.TLO.Me.Invis() then
                -- if paused and invis, back pet off, otherwise let it keep doing its thing if we just paused mid-combat for something
                local pet_target_id = mq.TLO.Pet.Target.ID() or 0
                if mq.TLO.Pet.ID() > 0 and pet_target_id > 0 then mq.cmd('/pet back') end
            end
            if config.get('CHASEPAUSED') then
                common.checkChase()
            end
            delay = 500
        end
        if statusTimer:expired() then
            status.send(class)
            statusTimer:reset()
        end
        logger.debug(logger.flags.aqo.main, 'loop execution time: %s loop delay: %s', mq.gettime() - loopStart, delay)
        mq.delay(delay)
    end
end

main()
