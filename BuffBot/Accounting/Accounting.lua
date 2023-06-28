---@type Mq
local mq = require('mq')
local storage = require('BuffBot.Core.Storage')

local accounting = {}

accounting.AccountsPath = mq.configDir .. '\\BuffBot\\' .. 'BuffBot.Accounts.ini'
accounting.FriendsPath = mq.configDir .. '\\BuffBot\\' .. 'BuffBot.Friends.ini'
accounting.GuildsPath = mq.configDir .. '\\BuffBot\\' .. 'BuffBot.Guilds.ini'

accounting.Accounts = {}
accounting.Friends = {}
accounting.Guilds = {}

function accounting.GetBalance(Account)
    local accountBalance = 0
    accountBalance = storage.ReadINI(accounting.AccountsPath, 'Balances', Account)
    -- if accountBalance == 0 then accountBalance = 1000 end
    return accountBalance
end

function accounting.GetFriend(Account)
    return storage.ReadINI(accounting.FriendsPath, 'Friends', Account)
end

function accounting.GetGuild(Account)
    return storage.ReadINI(accounting.GuildsPath, 'Guilds', Account)
end

function accounting.ProcessTrade()
    mq.delay('3s', mq.TLO.Window('TradeWnd').Open)
    mq.delay('3s', mq.TLO.Window('TradeWnd').HisTradeReady)
    if mq.TLO.Window('TradeWnd').HisTradeReady then
        local tradeMoney = mq.TLO.Window('TradeWnd').Child('TRDW_HisMoney0').Text()
        local testMoney = tonumber(tradeMoney)

        if testMoney >= 1 then
            local accountBalance = accounting.GetBalance(mq.TLO.Target())
            print('Received a donation from ' .. mq.TLO.Target() .. ' of ' .. testMoney .. 'p!')
            local finalBalance = accountBalance() + testMoney
            print('Balance: ' .. finalBalance)
            storage.SetINI(accounting.AccountsPath, 'Balances', mq.TLO.Target(), finalBalance)
            mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
        end
    end
    mq.delay('2s')
end

return accounting