local mq = require('mq')

local ReBirther = {
    Loop = true
}
local function Main()
    while ReBirther.Loop do
        if mq.TLO.EverQuest.GameState() == 'CHARSELECT' then
            ReBirther.Loop = false
            return
        end
        if mq.TLO.Me.Level() >= 80 then
            mq.cmd('/say #rebirth')
            mq.delay(1000)
        end
        mq.delay(100)
    end
end

Main()
