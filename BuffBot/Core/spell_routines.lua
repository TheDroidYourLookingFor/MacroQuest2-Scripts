--[[
|======================================================================================================================
|  Cast: the main subroutine that casts spells or items for you
|     Usage:
|        /call Cast "spellname|itemname|AAname|AA#" [item|alt|gem#] [give up time][s|m] [custom subroutine name] [Number of resist recasts]
|     Examples:
|
|     To cast Howl of Tashan and mem it in slot 3 if not memmed:
|       /call Cast "Howl of Tashan" gem3
|
|     To cast Arcane Rune and keep trying for 7 seconds, in case of interrupts.
|       /call Cast "Arcane Rune" gem5 7s
|
|     To click Grim Aura earring that's in a bag:
|       /call Cast "Shrunken Goblin Skull Earring" item
|
|     To use AA ability Eldritch Rune:
|       /call Cast "Eldritch Rune" alt
|         or
|       /call Cast "173" alt
|
|     To call a subroutine that interrupts CH if target gets healed before it lands:
|       /call Cast "Complete Healing" gem1 0 CheckHP
|     Then in your macro have somewhere:
|       Sub CheckHP
|          /if ( ${Target.PctHPs}>=80 ) /call Interrupt
|       /return
|======================================================================================================================
|  Below is a list of outer scope variables you can access in your macros:
|      refreshTime        - How much time is left till you're done recovering from casting
|      castEndTime        - How much time left till you're done casting the current spell... usable in custom spell Subs
|      spellNotHold       - 1 if your last spell didn't take hold, 0 otherwise
|      spellRecastTime1-9 - How much time left till that spell is back up
|
|======================================================================================================================
|----------------------+----------------------------------------------------------------------+
| CAST_CANCELLED       | Spell was cancelled by ducking (either manually or because mob died) |
| CAST_CANNOTSEE       | You can't see your target                                            |
| CAST_IMMUNE          | Target is immune to this spell                                       |
| CAST_INTERRUPTED     | Casting was interrupted and exceeded the given time limit            |
| CAST_INVIS           | You were invis, and noInvis is set to true                           |
| CAST_NOTARGET        | You don't have a target selected for this spell                      |
| CAST_NOTMEMMED       | Spell is not memmed and you gem to mem was not specified             |
| CAST_NOTREADY        | AA ability or spell is not ready yet                                 |
| CAST_OUTOFMANA       | You don't have enough mana for this spell!                           |
| CAST_OUTOFRANGE      | Target is out of range                                               |
| CAST_RESISTED        | Your spell was resisted!                                             |
| CAST_SUCCESS         | Your spell was cast successfully! (yay)                              |
| CAST_UNKNOWNSPELL    | Spell/Item/Ability was not found                                     |
| CAST_NOTHOLD         | Spell woundn't take hold on target                                   |
|----------------------+----------------------------------------------------------------------+
	#Event BeginCast "You begin casting#*#"
	#Event Collapse "Your gate is too unstable, and collapses.#*#"
	#Event FDFail "#1# has fallen to the ground.#*#"
	#Event Fizzle "Your spell fizzles#*#"
	#Event Immune "Your target is immune to changes in its attack speed#*#"
	#Event Immune "Your target is immune to changes in its run speed#*#"
	#Event Immune "Your target cannot be mesmerized#*#"
	#Event Interrupt "Your casting has been interrupted#*#"
	#Event Interrupt "Your spell is interrupted#*#"
	#Event NoHold "Your spell did not take hold#*#"
	#Event NoHold "Your spell would not have taken hold#*#"
	#Event NoHold "You must first target a group member#*#"
	#Event NoHold "Your spell is too powerful for your intended target#*#"
	#Event NoLOS "You cannot see your target.#*#"
	#Event NoMount "#*#You can not summon a mount here.#*#"
	#Event NoTarget "You must first select a target for this spell!#*#"
	#Event NotReady "Spell recast time not yet met.#*#"
	#Event OutOfMana "Insufficient Mana to cast this spell!#*#"
	#Event OutOfRange "Your target is out of range, get closer!#*#"
	#Event Recover "You haven't recovered yet...#*#"
	#Event Recover "Spell recovery time not yet met#*#"
	#Event Resisted "Your target resisted the #1# spell#*#"
	#Event Resisted2 "You resist the #1# spell#*#"
	#Event Standing "You must be standing to cast a spell#*#"
	#Event Stunned "You are stunned#*#"
	#Event Stunned "You can't cast spells while stunned!#*#"
	#Event Stunned "You *CANNOT* cast spells, you have been silenced!#*#"
]]

-- | --------------------------------------------------------------------------------------------
-- | SUB: Cast
-- | --------------------------------------------------------------------------------------------
---@type Mq
local mq = require('mq')
local storage = require('BuffBot.Core.Storage')

local spell_Routines = {}
spell_Routines.Cast_Returns = {
    CAST_CANCELLED = 'CAST_CANCELLED',
    CAST_CANNOTSEE = 'CAST_CANNOTSEE',
    CAST_IMMUNE = 'CAST_IMMUNE',
    CAST_INTERRUPTED = 'CAST_INTERRUPTED',
    CAST_INVIS = 'CAST_INVIS',
    CAST_NOTARGET = 'CAST_NOTARGET',
    CAST_NOTMEMMED = 'CAST_NOTMEMMED',
    CAST_NOTREADY = 'CAST_NOTREADY',
    CAST_OUTOFMANA = 'CAST_OUTOFMANA',
    CAST_OUTOFRANGE = 'CAST_OUTOFRANGE',
    CAST_RESISTED = 'CAST_RESISTED',
    CAST_SUCCESS = 'CAST_SUCCESS',
    CAST_UNKNOWNSPELL = 'CAST_UNKNOWNSPELL',
    CAST_NOTHOLD = 'CAST_NOTHOLD'
}
spell_Routines.Cast_Returns_Desc = {
    CAST_CANCELLED = 'Spell was cancelled by ducking (either manually or because mob died)',
    CAST_CANNOTSEE = 'You can\'t see your target',
    CAST_IMMUNE = 'Target is immune to this spell',
    CAST_INTERRUPTED = 'Casting was interrupted and exceeded the given time limit',
    CAST_INVIS = 'You were invis, and noInvis is set to true',
    CAST_NOTARGET = 'You don\'t have a target selected for this spell',
    CAST_NOTMEMMED = 'Spell is not memmed and you gem to mem was not specified',
    CAST_NOTREADY = 'AA ability or spell is not ready yet ',
    CAST_OUTOFMANA = 'You don\'t have enough mana for this spell!',
    CAST_OUTOFRANGE = 'Target is out of range',
    CAST_RESISTED = 'Your spell was resisted!',
    CAST_SUCCESS = 'Your spell was cast successfully! (yay)',
    CAST_UNKNOWNSPELL = 'Spell/Item/Ability was not found',
    CAST_NOTHOLD = 'Spell woundn\'t take hold on target'
}

local noInvis
local FollowFlag
local giveUpTimer
local ResistCounter
local PauseFlag

local noInterrupt = 0
local moveBack = false
local selfResist
local selfResistSpell
local castEndTime
local refreshTime
local itemRefreshTime
local spellNotHold

local function DoCastingEvents()
end
local function PauseFunction()
end
local function ItemCast(spellName, mySub)
end
local function AltCast(spellName, mySub)
end
local function SpellCast(spellType, spellName, spellGem, spellID, giveUpValue)
    if not mq.TLO.Me.Gem(spellName) then
        if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
        if not mq.TLO.Me.Gem(spellName) then mq.cmd('/memspell '.. spellGem .. ' '..  spellName) else return spell_Routines.Cast_Returns.CAST_NOTMEMMED end
    end
end

spell_Routines.Cast = function(spellName, spellGem, spellType, giveUpValue, ResistTotal)
    local castTime
    local castReturn
    local spellID

    if not castReturn then castReturn = spell_Routines.Cast_Returns.CAST_CANCELLED end
    DoCastingEvents()
    castReturn = 'X'
    if mq.TLO.Me.Invis() and noInvis then return end
    if spellType == 'item' then
        if not mq.TLO.FindItem(spellName).ID then return spell_Routines.Cast_Returns.CAST_UNKNOWNSPELL end
        castTime = mq.TLO.FindItem(spellName).CastTime()
    elseif spellType == 'alt' then
        if not mq.TLO.Me.AltAbilityReady(spellName) then return spell_Routines.Cast_Returns.CAST_NOTREADY end
        castTime = mq.TLO.Me.AltAbility(spellName).Spell.CastTime()
    else
        if not mq.TLO.Me.Book(spellName) then return spell_Routines.Cast_Returns.CAST_NOTREADY end
        spellID = mq.TLO.Me.Book(spellName).ID()
        castTime = mq.TLO.Spell(spellName).CastTime()
        if mq.TLO.Me.CurrentMana() < mq.TLO.Spell(spellName).Mana then return spell_Routines.Cast_Returns.CAST_OUTOFMANA end
    end
    if castTime > 0.1 then
        mq.TLO.MoveUtils.MovePause()
        if FollowFlag then PauseFunction() end
        if mq.TLO.Me.Moving then mq.cmd('/keypress back') end
    end
    if not spellType then spellType = 'spell' end
    if giveUpValue then giveUpTimer = giveUpValue end
    if ResistTotal then ResistCounter = ResistTotal end
    while mq.TLO.Me.Casting() or (not mq.TLO.Me.Class.ShortName == 'BRD' and castTime > 0.1) do
        if mq.TLO.Me.Casting() then mq.delay(100) end
    end
    if mq.TLO.Window('SpellBookWnd').Open() then mq.cmd('/keypress spellbook') end
    if mq.TLO.Me.Ducking() then mq.cmd('/keypress duck') end
    if spellType == 'item' then ItemCast(spellName) end
    if spellType == 'alt' then AltCast(spellName) end
    if spellType ~= 'item' and spellType ~= 'alt' then SpellCast(spellType, spellName, spellGem, spellID, giveUpValue) end
    if PauseFlag then PauseFunction() end
    giveUpTimer = 0
    ResistCounter = 0
    return castReturn
end


-- | --------------------------------------------------------------------------------------------
-- | Event Functions
-- | --------------------------------------------------------------------------------------------
Fizzled_Last_Spell = false
local function event_cast_fizzle()
    Fizzled_Last_Spell = true
end

-- | --------------------------------------------------------------------------------------------
-- | MQ2 Events
-- | --------------------------------------------------------------------------------------------
mq.event('BeginCast', "You begin casting#*#", event_cast_fizzle)
mq.event('Collapse', "Your gate is too unstable, and collapses.#*#", event_cast_fizzle)
mq.event('FDFail', "#1# has fallen to the ground.#*#", event_cast_fizzle)
mq.event('Fizzle', "Your spell fizzles#*#", event_cast_fizzle)
mq.event('Immune1', "Your target is immune to changes in its attack speed#*#", event_cast_fizzle)
mq.event('Immune2', "Your target is immune to changes in its run speed#*#", event_cast_fizzle)
mq.event('Immune3', "Your target cannot be mesmerized#*#", event_cast_fizzle)
mq.event('Interrupt1', "Your casting has been interrupted#*#", event_cast_fizzle)
mq.event('Interrupt2', "Your spell is interrupted#*#", event_cast_fizzle)
mq.event('NoHold1', "Your spell did not take hold#*#", event_cast_fizzle)
mq.event('NoHold2', "Your spell would not have taken hold#*#", event_cast_fizzle)
mq.event('NoHold3', "You must first target a group member#*#", event_cast_fizzle)
mq.event('NoHold4', "Your spell is too powerful for your intended target#*#", event_cast_fizzle)
mq.event('NoLOS', "You cannot see your target.#*#", event_cast_fizzle)
mq.event('NoMount', "#*#You can not summon a mount here.#*#", event_cast_fizzle)
mq.event('NoTarget', "You must first select a target for this spell!#*#", event_cast_fizzle)
mq.event('NotReady', "Spell recast time not yet met.#*#", event_cast_fizzle)
mq.event('OutOfMana', "Insufficient Mana to cast this spell!#*#", event_cast_fizzle)
mq.event('OutOfRange', "Your target is out of range, get closer!#*#", event_cast_fizzle)
mq.event('Recover1', "You haven't recovered yet...#*#", event_cast_fizzle)
mq.event('Recover2', "Spell recovery time not yet met#*#", event_cast_fizzle)
mq.event('Resisted', "Your target resisted the #1# spell#*#", event_cast_fizzle)
mq.event('SelfResisted', "You resist the #1# spell#*#", event_cast_fizzle)
mq.event('Standing', "You must be standing to cast a spell#*#", event_cast_fizzle)
mq.event('Stunned', "You are stunned#*#", event_cast_fizzle)
mq.event('Stunned', "You can't cast spells while stunned!#*#", event_cast_fizzle)
mq.event('Stunned', "You *CANNOT* cast spells, you have been silenced!#*#", event_cast_fizzle)


return spell_Routines
