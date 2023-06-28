---@type Mq
local mq = require('mq')

local storage = {}

function storage.ReadINI(filename, section, option)
    return (mq.TLO.Ini(filename, section, option))
end

function storage.SetINI(filename, section, option, value)
    mq.cmd('/ini ' .. filename .. ' ' .. section .. ' ' .. option .. ' ' .. value)
end

return storage