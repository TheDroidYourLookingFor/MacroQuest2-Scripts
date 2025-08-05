local mq = require('mq')
local Monk = {
    _version = '1.0.0',
    _author = 'TheDroidUrLookingFor'
}
Monk.MainLoop = true
Monk.debug = false
Monk.script_ShortName = 'Monk'
Monk.command_ShortName = 'Mnk'
Monk.command_LongName = 'Monk'
Monk.UseEpic = false
Monk.Epic = 'Celestial Fists X'
Monk.EpicBuff = 'Celestial Tranquility X'
Monk.GroupHealItem = 'Mythic Minli`s Greaves of Stability'
Monk.GroupHealAt = 90

function Monk.Main()
    while Monk.MainLoop do
        if Monk.UseEpic and mq.TLO.Me.Combat() and mq.TLO.FindItem('=' .. Monk.Epic)() and not mq.TLO.Me.Buff(Monk.EpicBuff)() then
            mq.cmdf('/cast item "%s"', Monk.Epic)
            mq.delay(500)
        end
        if mq.TLO.Group() and mq.TLO.Group.GroupSize() > 2 then
            for i = 1, mq.TLO.Group.Members() do
                local member = mq.TLO.Group.Member(i)
                if member() and member.PctHPs() ~= nil and member.PctHPs() <= Monk.GroupHealAt then
                    if mq.TLO.FindItem('=' .. Monk.GroupHealItem)() then
                        if not mq.TLO.Me.Stunned() then
                            mq.cmdf('/useitem "%s"', Monk.GroupHealItem)
                            mq.delay(100)
                        end
                        break
                    end
                end
            end
        end
        if mq.TLO.Me.PctHPs() <= Monk.GroupHealAt then
            if not mq.TLO.Me.Stunned() then
                mq.cmdf('/useitem "%s"', Monk.GroupHealItem)
                mq.delay(100)
            end
        end
        mq.delay(100)
    end
end

Monk.Main()

return Monk
