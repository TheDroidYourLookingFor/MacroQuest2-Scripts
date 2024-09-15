---@type Mq
local mq = require('mq')

local casting = {}

function casting.LoadSpellSet(spellSetName)
    mq.cmd('/memspellset ' .. spellSetName)
end

function casting.DoneCasting()
    -- implement some more complex condition for when to break
    -- early from the delay.
    return not mq.TLO.Me.Casting()
end

function casting.MemSpell(spellToMem, spellGemNum)
    CONSOLEMETHOD('function MemSpell(%s, %s)', spellToMem, spellGemNum)
    if not mq.TLO.Me.Book(spellToMem)() then return end
    if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
    if mq.TLO.Me.Gem(spellGemNum)() == spellToMem then return end
    if mq.TLO.Me.Gem(spellToMem)() == nil then
        CONSOLEMETHOD('Spell not memorized! \ar(%s)\ax', spellToMem)
        mq.cmd('/memspell ' .. spellGemNum .. ' "' .. spellToMem .. '"')
        mq.delay(5500, function() return mq.TLO.Me.Gem(spellGemNum)() == spellToMem end)
    end
end

Fizzled_Last_Spell = false
local function event_cast_fizzle()
    Fizzled_Last_Spell = true
end
mq.event('Fizzle', "Your spell fizzles#*#", event_cast_fizzle)

local cast_Mode = 'casting'
function casting.CastSpell(WhoToBuff, buffName, buffGem)
    CONSOLEMETHOD('function CastBuff(' .. buffName .. ',' .. buffGem .. ') Entry')
    if not mq.TLO.Me.Book(buffName)() then return end
    if mq.TLO.Spawn(WhoToBuff) then
        mq.TLO.Spawn(WhoToBuff).DoTarget()
        mq.delay(25, mq.TLO.Target.ID)
        mq.cmd('/face')
    end

    if mq.TLO.Me.SpellInCooldown() then
        mq.delay(2000)
        casting.CastSpell(WhoToBuff, buffName, buffGem)
    end
    casting.MemSpell(buffName, buffGem)
    mq.delay(5500,
        function() return mq.TLO.Me.SpellReady(buffName)() == true or mq.TLO.Me.AltAbilityReady(buffName) == true end)
    PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', buffName, mq.TLO.Target())

    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(buffName).RankName() .. '" ' .. buffGem)
    while mq.TLO.Me.Casting() do
        mq.delay(1000, casting.DoneCasting)
    end
    mq.doevents()
    mq.delay(1500)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.CastSpell(WhoToBuff, buffName, buffGem)
    end
end

function casting.CastItem(itemName)
    CONSOLEMETHOD('function CastItem(' .. itemName .. ') Entry')
    CONSOLEMETHOD('Casting ' .. itemName .. ' on ' .. mq.TLO.Target())
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. itemName .. '" item')
    mq.delay(15000, casting.DoneCasting)
    mq.doevents()
    mq.delay(1500)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.CastItem(itemName)
    end
end

function casting.CastDPS(spellTargetID, spellName, spellGem)
    CONSOLEMETHOD('Casting ' .. spellName .. ' on ' .. mq.TLO.Target())
    if not mq.TLO.Me.Book(spellName)() then return end
    if mq.TLO.Spawn(spellTargetID) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. spellTargetID .. '" id')
        mq.delay(2000, function () return mq.TLO.Target.ID() ~= nil end)
        mq.cmd('/face')
    else
        return
    end
    casting.MemSpell(spellName, spellGem)
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(spellName).RankName() .. '" ')
    PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', spellName, mq.TLO.Target())
    mq.delay(15000, Casting.DoneCasting)
    mq.doevents()
    mq.delay(250)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.CastDPS(spellName)
    end
end

function casting.IsScribed(spellName, spellId)
    local bookId = mq.TLO.Me.Book(spellName)()

    if (not bookId) then
        bookId = mq.TLO.Me.CombatAbility(spellName)()
    end

    if (not bookId) then
        return false
    end

    if (bookId and not spellId) then
        return true
    end

    return mq.TLO.Me.Book(bookId).ID() == spellId or mq.TLO.Me.CombatAbility(bookId).ID() == spellId
end

return casting
