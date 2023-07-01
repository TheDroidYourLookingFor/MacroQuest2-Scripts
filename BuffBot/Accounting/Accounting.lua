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
    return accountBalance()
end

function accounting.AddBalance(Account, Amount)
    local accountBalance = accounting.GetBalance(Account)
    CONSOLEMETHOD('Adding balance to ' .. Account .. ' of ' .. Amount .. 'p!')
    local finalBalance = accountBalance + Amount
    CONSOLEMETHOD('Balance: ' .. finalBalance)
    storage.SetINI(accounting.AccountsPath, 'Balances', Account, finalBalance)
    return accounting.GetBalance(Account)
end

function accounting.RemoveBalance(Account, Amount)
    local accountBalance = accounting.GetBalance(Account)
    CONSOLEMETHOD('Deducting balance from ' .. Account .. ' of ' .. Amount .. 'p!')
    local finalBalance = accountBalance - Amount
    CONSOLEMETHOD('Balance: ' .. finalBalance)
    storage.SetINI(accounting.AccountsPath, 'Balances', Account, finalBalance)
    return accounting.GetBalance(Account)
end

function accounting.GetFriend(Account)
    return storage.ReadINI(accounting.FriendsPath, 'Friends', Account)
end
function accounting.SetFriend(Account, FriendStatus)
    return storage.SetINI(accounting.FriendsPath, 'Friends', Account, FriendStatus)
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
            PRINTMETHOD('Received a donation from ' .. mq.TLO.Target() .. ' of ' .. testMoney .. 'p!')
            local finalBalance = accountBalance() + testMoney
            PRINTMETHOD('Balance: ' .. finalBalance)
            storage.SetINI(accounting.AccountsPath, 'Balances', mq.TLO.Target(), finalBalance)
            mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
        end
    end
    mq.delay('2s')
end

return accounting
