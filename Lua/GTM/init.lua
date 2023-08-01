local mq = require('mq')
local version = '1.0.1'
local args = { ... }

local Settings = {
    debug = true,
    tradeToPerson = '',
    enableCustomCoin = false,
    customCoin = 'Diamond Coin',
    enableDiamonds = false,
    diamond = 'Diamond',
    enableRawDiamonds = false,
    rawDiamond = 'Raw Diamond',
    enableBlueDiamonds = false,
    blueDiamond = 'Blue Diamond',
    enablePlatinumCoin = false,
    enableGoldCoin = false,
    enableSilverCoin = false,
    enableCopperCoin = false
}

local Group_Settings = {
    groupMode = true,
    delay = 500,
    distance = 20,
    redistribute = false,
    redistribute_Amount = 100,
    directMessage = '/dex'
}
local function PRINTMETHOD(printMessage, ...)
    printf("[GiveToMe] " .. printMessage, ...)
end

local function InventoryOpen()
    if mq.TLO.Window('InventoryWindow').Open() then return true else return false end
end
local function CheckCursor()
    if mq.TLO.Cursor.ID() == 0 then return false else return true end
end
local function CursorEmpty()
    if mq.TLO.Cursor.ID() == 0 then return true else return false end
end
local function HaveTarget()
    if mq.TLO.Target.ID() ~= nil then return true else return false end
end
local WaitTime = 750

local function Give(itenName)
    if mq.TLO.FindItem(itenName).ID() ~= nil then
        if mq.TLO.FindItem(itenName).StackCount() >= 1 then
            local itemSlot = mq.TLO.FindItem(itenName).ItemSlot()
            local itemSlot2 = mq.TLO.FindItem(itenName).ItemSlot2()
            local pickup1 = itemSlot - 22
            local pickup2 = itemSlot2 + 1
            mq.cmd('/shift /itemnotify in pack' .. pickup1 .. ' ' .. pickup2 .. ' leftmouseup')
            mq.delay(WaitTime, CheckCursor)
            mq.cmd('/click left target')
            mq.delay(WaitTime, CursorEmpty)
        end
    end
end

local function GiveCoins(coinToggle, coinType)
    if coinToggle then
        if coinType == Settings.customCoin then
            Give(Settings.customCoin)
        elseif coinType == Settings.diamond then
            Give(Settings.diamond)
        elseif coinType == Settings.rawDiamond then
            Give(Settings.rawDiamond)
        elseif coinType == Settings.blueDiamond then
            Give(Settings.blueDiamond)
        elseif coinType == 'Platinum' then
            if mq.TLO.Me.Platinum() >= 1 then
                mq.cmd('/shift /notify InventoryWindow IW_Money0 leftmouseup')
                mq.delay(WaitTime, CheckCursor)
                mq.cmd('/click left target')
                mq.delay(WaitTime, CursorEmpty)
            end
        elseif coinType == 'Gold' then
            if mq.TLO.Me.Gold() >= 1 then
                mq.cmd('/shift /notify InventoryWindow IW_Money1 leftmouseup')
                mq.delay(WaitTime, CheckCursor)
                mq.cmd('/click left target')
                mq.delay(WaitTime, CursorEmpty)
            end
        elseif coinType == 'Silver' then
            if mq.TLO.Me.Silver() >= 1 then
                mq.cmd('/shift /notify InventoryWindow IW_Money2 leftmouseup')
                mq.delay(WaitTime, CheckCursor)
                mq.cmd('/click left target')
                mq.delay(WaitTime, CursorEmpty)
            end
        elseif coinType == 'Copper' then
            if mq.TLO.Me.Copper() >= 1 then
                mq.cmd('/shift /notify InventoryWindow IW_Money3 leftmouseup')
                mq.delay(WaitTime, CheckCursor)
                mq.cmd('/click left target')
                mq.delay(WaitTime, CursorEmpty)
            end
        end
    end
end

if mq.TLO.FindItem(Settings.customCoin).ID ~= nil then Settings.enableCustomCoin = true end
if mq.TLO.FindItem(Settings.diamond).ID ~= nil then Settings.enableDiamonds = true end
if mq.TLO.FindItem(Settings.rawDiamond).ID ~= nil then Settings.enableRawDiamonds = true end
if mq.TLO.FindItem(Settings.blueDiamond).ID ~= nil then Settings.enableBlueDiamonds = true end
if mq.TLO.Me.Platinum() >= 1 then Settings.enablePlatinumCoin = true end
if mq.TLO.Me.Gold() >= 1 then Settings.enableGoldCoin = true end
if mq.TLO.Me.Silver() >= 1 then Settings.enableSilverCoin = true end
if mq.TLO.Me.Copper() >= 1 then Settings.enableCopperCoin = true end

local function NavToTrade(navTarget)
    PRINTMETHOD('Moving to %s.', navTarget)
    mq.cmd('/nav target')
    while mq.TLO.Navigation.Active() do
        if (mq.TLO.Spawn(navTarget).Distance3D() < 20) then
            mq.cmd('/nav stop')
        end
        mq.delay(50)
    end
end

local function GroupMode()
    for i = 1, mq.TLO.Me.GroupSize() - 1 do
        printf('Group Member Name: %s', mq.TLO.Group.Member(i).Name())
        mq.cmdf('%s %s /lua run GTM %s', Group_Settings.directMessage, mq.TLO.Group.Member(i).Name(), mq.TLO.Me.Name())
        while (mq.TLO.Spawn(mq.TLO.Group.Member(i).Name()).Distance3D() > Group_Settings.distance) do
            mq.delay(Group_Settings.delay)
        end
        mq.delay(Group_Settings.delay *3,function () return mq.TLO.Window('TradeWnd').Open() == true end)
        while mq.TLO.Window('TradeWnd').Open() do
            mq.delay(Group_Settings.delay)
        end
        mq.delay(Group_Settings.delay)
    end
    if Group_Settings.redistribute then mq.cmdf('/split %s',Group_Settings.redistribute_Amount) end
end

local function Main()
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Give To Me Started ++')
    PRINTMETHOD('++ Custom: %s / Platinum: %s / Gold: %s / Silver %s / Copper %s ++', Settings.enableCustomCoin,
        Settings.enablePlatinumCoin, Settings.enableGoldCoin, Settings.enableSilverCoin, Settings.enableCopperCoin)
    PRINTMETHOD('++ Diamond: %s / Raw Diamond: %s / Blue Diamond: %s ++', Settings.enableDiamonds,
        Settings.enableRawDiamonds, Settings.enableBlueDiamonds)
    if args[1] == nil then
        if mq.TLO.Target.ID() ~= nil then Settings.tradeToPerson = mq.TLO.Target.Name() else return end
    else
        if args[1] ~= nil and args[1] == 'group' then
            GroupMode()
            return
        else
            Settings.tradeToPerson = args[1]
        end
    end

    PRINTMETHOD('Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)

    PRINTMETHOD('Targetting %s', Settings.tradeToPerson)
    mq.cmd('/target "' .. Settings.tradeToPerson .. '" pc')
    mq.delay(2000, HaveTarget)
    mq.cmd('/face')

    if mq.TLO.Spawn(Settings.tradeToPerson).Distance3D() > 20 then
        NavToTrade(Settings.tradeToPerson)
    end

    GiveCoins(Settings.enableCustomCoin, Settings.customCoin)
    GiveCoins(Settings.enableDiamonds, Settings.diamond)
    GiveCoins(Settings.enableRawDiamonds, Settings.rawDiamond)
    GiveCoins(Settings.enableBlueDiamonds, Settings.blueDiamond)
    GiveCoins(Settings.enablePlatinumCoin, 'Platinum')
    GiveCoins(Settings.enableGoldCoin, 'Gold')
    GiveCoins(Settings.enableSilverCoin, 'Silver')
    GiveCoins(Settings.enableCopperCoin, 'Copper')

    mq.delay(WaitTime)
    mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
    mq.delay(WaitTime)
end
Main()
