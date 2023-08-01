--|------------------------------------------------------------|
--|          ManaStone
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')

-- local Casting = require('ManaStone.Lib.Casting')
-- local Events = require('ManaStone.Lib.Events')
-- local Gui = require('ManaStone.Lib.Gui')
local Messages = require('ManaStone.Lib.Messages')
-- local Navigation = require('ManaStone.lib.Movement')
-- local SpellRoutines = require('ManaStone.lib.spell_routines')
-- local Storage = require('ManaStone.lib.Storage')

local manaStone = {
    Debug = false,
    Terminate = false,
    Command_ShortName = 'ms',
    Command_LongName = 'manastone',
    Name = 'Manastone',
    CombatCast = true,
    PctHP = 50,
    PctMP = 90
}

function manaStone.Use()
    if mq.TLO.FindItem(manaStone.Name).ID() ~= nil then
        if mq.TLO.Me.PctHPs() >= manaStone.PctHP and mq.TLO.Me.PctMana() <= manaStone.PctMP then
            if manaStone.Debug then Messages.CONSOLEMETHOD(false, 'Casting \ag%S\aw (\ag%s\aw/\ab%s\aw)', manaStone.Name, manaStone.PctHP, manaStone.PctMP) end
            if mq.TLO.Me.Combat() and manaStone.CombatCast then
                mq.cmdf('/casting "%s" item', manaStone.Name)
                return true
            end
            if not mq.TLO.Me.Combat() then
                mq.cmdf('/casting "%s" item', manaStone.Name)
                return true
            end
        end
        return false
    end
end

local function msb_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            if Open then
                Messages.CONSOLEMETHOD(false, 'Hiding ManaStone Bot GUI')
                Open = false
            else
                Messages.CONSOLEMETHOD(false, 'Restoring ManaStone Bot GUI')
                Open = true
            end
            return
        elseif args[1] == 'combat' then
            if manaStone.CombatCast then
                Messages.CONSOLEMETHOD(false, 'Disabling combat casting the ManaStone')
                manaStone.CombatCast = false
            else
                Messages.CONSOLEMETHOD(false, 'Enabling combat casting the ManaStone')
                manaStone.CombatCast = true
            end
            return
        elseif args[1] == 'hp' then
            if args[2] ~= nil then
                manaStone.PctHP = args[2]
                Messages.CONSOLEMETHOD(false, 'Casting the ManaStone at %s% hp.',manaStone.PctHP)
            end
            return
        elseif args[1] == 'mp' then
            if args[2] ~= nil then
                manaStone.PctMP = args[2]
                Messages.CONSOLEMETHOD(false, 'Casting the ManaStone at %s% mana.',manaStone.PctMP)
            end
            return
        elseif args[1] == 'quit' then
            MainLoop = false
            return
        else
            Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            Messages.CONSOLEMETHOD(false, '/%s gui - Toggles the ManaStone GUI', manaStone.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s combat - Toggles casting the ManaStone in combat', manaStone.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s hp - Set the percent hp to use ManaStone', manaStone.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s mp - Set the percent mp to use ManaStone', manaStone.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s quit - Quits the ManaStone lua script.', manaStone.Command_ShortName)
        end
    else
        Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        Messages.CONSOLEMETHOD(false, '/%s gui - Toggles the ManaStone GUI', manaStone.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s combat - Toggles casting the ManaStone in combat', manaStone.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s hp - Set the percent hp to use ManaStone', manaStone.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s mp - Set the percent mp to use ManaStone', manaStone.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s quit - Quits the ManaStone lua script.', manaStone.Command_ShortName)
    end
end
mq.bind('/' .. manaStone.Command_ShortName, msb_command)
mq.bind('/' .. manaStone.Command_LongName, msb_command)

function manaStone.Main()
    print('[MSB] ManaStone Bot Started up! [MSB]')
    if not mq.TLO.Plugin('MQ2Cast').IsLoaded() then mq.cmd('/plugin mq2cast load') end

    while not manaStone.Terminate do
        manaStone.Use()
        mq.delay(25)
    end
end

manaStone.Main()

Messages.CONSOLEMETHOD(false, 'Shutting down')
mq.unbind('/'..manaStone.Command_ShortName)
mq.unbind('/'..manaStone.Command_LongName)
return manaStone
