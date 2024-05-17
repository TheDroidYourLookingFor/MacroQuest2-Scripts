--|------------------------------------------------------------|
--|          SlurpyStone
--|
--|      Last Modified by: TheDroidUrLookingFor
--|
--|		Version:	1.0.0
--|
--|------------------------------------------------------------|
local mq = require('mq')

-- local Casting = require('SlurpyStone.Lib.Casting')
-- local Events = require('SlurpyStone.Lib.Events')
-- local Gui = require('SlurpyStone.Lib.Gui')
local Messages = require('SlurpyStone.Lib.Messages')
-- local Navigation = require('SlurpyStone.lib.Movement')
-- local SpellRoutines = require('SlurpyStone.lib.spell_routines')
-- local Storage = require('SlurpyStone.lib.Storage')

local SlurpyStone = {
    Debug = false,
    Terminate = false,
    Command_ShortName = 'ss',
    Command_LongName = 'SlurpyStone',
    Name = 'Slurpy Stone',
	AttackRange = 20
}

function SlurpyStone.Use()
    if mq.TLO.FindItem(SlurpyStone.Name).ID() ~= nil then
        if mq.TLO.Me.Combat() and (mq.TLO.Target.ID() and mq.TLO.Target.Distance() <= SlurpyStone.AttackRange and mq.TLO.FindItem(SlurpyStone.Name).TimerReady()) then
			mq.cmdf('/casting "%s" item', SlurpyStone.Name)
			return true
		end
        return false
    end
end

local function ssb_command(...)
    local args = { ... }
    if args ~= nil then
        if args[1] == 'gui' then
            if Open then
                Messages.CONSOLEMETHOD(false, 'Hiding SlurpyStone Bot GUI')
                Open = false
            else
                Messages.CONSOLEMETHOD(false, 'Restoring SlurpyStone Bot GUI')
                Open = true
            end
            return
        elseif args[1] == 'quit' then
            MainLoop = false
            return
        else
            Messages.CONSOLEMETHOD(false, 'Valid Commands:')
            Messages.CONSOLEMETHOD(false, '/%s gui - Toggles the SlurpyStone GUI', SlurpyStone.Command_ShortName)
            Messages.CONSOLEMETHOD(false, '/%s quit - Quits the SlurpyStone lua script.', SlurpyStone.Command_ShortName)
        end
    else
        Messages.CONSOLEMETHOD(false, 'Valid Commands:')
        Messages.CONSOLEMETHOD(false, '/%s gui - Toggles the SlurpyStone GUI', SlurpyStone.Command_ShortName)
        Messages.CONSOLEMETHOD(false, '/%s quit - Quits the SlurpyStone lua script.', SlurpyStone.Command_ShortName)
    end
end
mq.bind('/' .. SlurpyStone.Command_ShortName, ssb_command)
mq.bind('/' .. SlurpyStone.Command_LongName, ssb_command)

function SlurpyStone.Main()
    print('[SSB] SlurpyStone Bot Started up! [SSB]')
    if not mq.TLO.Plugin('MQ2Cast').IsLoaded() then mq.cmd('/plugin mq2cast load') end

    while not SlurpyStone.Terminate do
        SlurpyStone.Use()
        mq.delay(25)
    end
end

SlurpyStone.Main()

Messages.CONSOLEMETHOD(false, 'Shutting down')
mq.unbind('/'..SlurpyStone.Command_ShortName)
mq.unbind('/'..SlurpyStone.Command_LongName)
return SlurpyStone
