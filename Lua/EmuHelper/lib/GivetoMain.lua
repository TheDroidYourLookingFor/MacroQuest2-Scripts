local mq = require('mq')
local version = '1.0.1'

local GiveToMain = {}

GiveToMain.Settings = {
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
GiveToMain.Custom_Items = {
    [1] = 'Bag of Platinum Pieces',
    [2] = 'Chest of Platinum',
    [3] = 'Dragon Ore for Plate Multiclass',
    [4] = 'Dragon Ore for Bard',
    [5] = 'Dragon Ore for Paladin',
    [6] = 'Dragon Ore for Cleric',
    [7] = 'Dragon Ore for Shadowknight',
    [8] = 'Dragon Ore for Warrior',
    [9] = 'Dragon Ore for Chain Multiclass',
    [10] = 'Dragon Ore for Rogue',
    [11] = 'Dragon Ore for Berserker',
    [12] = 'Dragon Ore for Ranger',
    [13] = 'Dragon Ore for Shaman',
    [14] = 'Dragon Ore for Cloth Multiclass',
    [15] = 'Dragon Ore for Enchanter',
    [16] = 'Dragon Ore for Magician',
    [17] = 'Dragon Ore for Necromancer',
    [18] = 'Dragon Ore for Wizard',
    [19] = 'Dragon Ore for Leather Multiclass',
    [20] = 'Dragon Ore for Beastlord',
    [21] = 'Dragon Ore for Druid',
    [22] = 'Dragon Ore for Monk',
    [23] = 'Essence of Anguish',
    [24] = 'Essence of Cazic Thule',
    [25] = 'Essence of Dragons Major',
    [26] = 'Essence of Dragons Minor',
    [27] = 'Essence of Gods Major',
    [28] = 'Essence of Gods Minor',
    [29] = 'Essence of Loping Plains',
    [30] = 'Essence of Norrath',
    [31] = 'Essence of Old Commons',
    [32] = 'Essence of Qvic',
    [33] = 'Essence of Sunderock',
    [34] = 'Essence of Temple Veeshan',
    [35] = 'Essence of Frozen Shadow I',
    [36] = 'Essence of Frozen Shadow II',
    [37] = 'Essence of Frozen Shadow III',
    [38] = 'Flawless Rainbow Crystal',
    [39] = 'Greater Rainbow Crystal',
    [40] = 'Lesser Rainbow Crystal',
    [41] = 'Minor Rainbow Crystal',
    [42] = 'Major Rainbow Crystal',
    [43] = 'Supreme Rainbow Crystal',
    [44] = 'Gemstone of the Ages',
    [45] = 'Greater Lightstone',
    [46] = 'Superior Lightstone',
    [47] = 'Token of Pain Mk. I',
    [48] = 'Token of the Soul',
    [49] = 'Token of Growth Mk. I',
    [50] = 'Dragon Seal of Honor',
    [51] = 'Ultimate Willpower Rank I (Max Rank 600)',
    [52] = 'Ultimate Sturdiness Rank I (Max Rank 250)',
    [53] = 'Xorbb Currency',
    [54] = 'A Jar of Xorbb Currency (5)',
    [55] = 'A Box of Coldain Velium Shards (500)',
    [56] = '1,000 AA Token',
    [57] = '5,000 AA Token',
    [58] = '10,000 AA Token',
    [59] = '100,000 AA Token',
    [60] = '1,000,000 AA Token',
    [61] = '10,000,000 AA Token',
    [62] = '100,000,000 AA Token'
}

GiveToMain.Group_Settings = {
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

local function GiveCoin(coinToggle, coinType)
    if coinToggle then
        if coinType == GiveToMain.Settings.customCoin then
            Give(GiveToMain.Settings.customCoin)
        elseif coinType == GiveToMain.Settings.diamond then
            Give(GiveToMain.Settings.diamond)
        elseif coinType == GiveToMain.Settings.rawDiamond then
            Give(GiveToMain.Settings.rawDiamond)
        elseif coinType == GiveToMain.Settings.blueDiamond then
            Give(GiveToMain.Settings.blueDiamond)
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
        mq.cmdf('%s %s /lua run GTM %s', GiveToMain.Group_Settings.directMessage, mq.TLO.Group.Member(i).Name(), mq.TLO.Me.Name())
        while (mq.TLO.Spawn(mq.TLO.Group.Member(i).Name()).Distance3D() > GiveToMain.Group_Settings.distance) do
            mq.delay(GiveToMain.Group_Settings.delay)
        end
        mq.delay(GiveToMain.Group_Settings.delay *3,function () return mq.TLO.Window('TradeWnd').Open() == true end)
        while mq.TLO.Window('TradeWnd').Open() do
            mq.delay(GiveToMain.Group_Settings.delay)
        end
        mq.delay(GiveToMain.Group_Settings.delay)
    end
    if GiveToMain.Group_Settings.redistribute then mq.cmdf('/split %s',GiveToMain.Group_Settings.redistribute_Amount) end
end

function GiveToMain.GiveEZItems(...)
    local args = {...}
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Give To Me Started ++')

    if args[1] == nil then
        if mq.TLO.Target.ID() ~= nil then GiveToMain.Settings.tradeToPerson = mq.TLO.Target.Name() else return end
    else
        GiveToMain.Settings.tradeToPerson = args[1]
    end

    PRINTMETHOD('Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)

    PRINTMETHOD('Targetting %s', GiveToMain.Settings.tradeToPerson)
    mq.cmd('/target "' .. GiveToMain.Settings.tradeToPerson .. '" pc')
    mq.delay(2000, HaveTarget)
    mq.cmd('/face')

    if mq.TLO.Spawn(GiveToMain.Settings.tradeToPerson).Distance3D() > 20 then
        NavToTrade(GiveToMain.Settings.tradeToPerson)
    end

    local tradeCount = 0
    for index, item in ipairs(GiveToMain.Custom_Items) do
        if tradeCount < 10 and mq.TLO.FindItem(item).ID() ~= nil then
            Give(item)
            mq.delay(250)
            tradeCount = (tradeCount or 0) + 1
        end
    end

    mq.delay(WaitTime)
    mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
    mq.delay(WaitTime)
end

function GiveToMain.GiveCoins(...)
    local args = { ... }
    if mq.TLO.FindItem(GiveToMain.Settings.customCoin).ID ~= nil then GiveToMain.Settings.enableCustomCoin = true end
    if mq.TLO.FindItem(GiveToMain.Settings.diamond).ID ~= nil then GiveToMain.Settings.enableDiamonds = true end
    if mq.TLO.FindItem(GiveToMain.Settings.rawDiamond).ID ~= nil then GiveToMain.Settings.enableRawDiamonds = true end
    if mq.TLO.FindItem(GiveToMain.Settings.blueDiamond).ID ~= nil then GiveToMain.Settings.enableBlueDiamonds = true end
    if mq.TLO.Me.Platinum() >= 1 then GiveToMain.Settings.enablePlatinumCoin = true end
    if mq.TLO.Me.Gold() >= 1 then GiveToMain.Settings.enableGoldCoin = true end
    if mq.TLO.Me.Silver() >= 1 then GiveToMain.Settings.enableSilverCoin = true end
    if mq.TLO.Me.Copper() >= 1 then GiveToMain.Settings.enableCopperCoin = true end
    PRINTMETHOD('++ Initialized ++')
    PRINTMETHOD('++ Give To Me Started ++')
    PRINTMETHOD('++ Custom: %s / Platinum: %s / Gold: %s / Silver %s / Copper %s ++', GiveToMain.Settings.enableCustomCoin,
        GiveToMain.Settings.enablePlatinumCoin, GiveToMain.Settings.enableGoldCoin, GiveToMain.Settings.enableSilverCoin, GiveToMain.Settings.enableCopperCoin)
    PRINTMETHOD('++ Diamond: %s / Raw Diamond: %s / Blue Diamond: %s ++', GiveToMain.Settings.enableDiamonds,
        GiveToMain.Settings.enableRawDiamonds, GiveToMain.Settings.enableBlueDiamonds)
    if args[1] == nil then
        if mq.TLO.Target.ID() ~= nil then GiveToMain.Settings.tradeToPerson = mq.TLO.Target.Name() else return end
    else
        if args[1] ~= nil and args[1] == 'group' then
            GroupMode()
            return
        else
            GiveToMain.Settings.tradeToPerson = args[1]
        end
    end

    PRINTMETHOD('Opening Inventory')
    mq.TLO.Window('InventoryWindow').DoOpen()
    mq.delay(1500, InventoryOpen)

    PRINTMETHOD('Targetting %s', GiveToMain.Settings.tradeToPerson)
    mq.cmd('/target "' .. GiveToMain.Settings.tradeToPerson .. '" pc')
    mq.delay(2000, HaveTarget)
    mq.cmd('/face')

    if mq.TLO.Spawn(GiveToMain.Settings.tradeToPerson).Distance3D() > 20 then
        NavToTrade(GiveToMain.Settings.tradeToPerson)
    end

    GiveCoin(GiveToMain.Settings.enableCustomCoin, GiveToMain.Settings.customCoin)
    GiveCoin(GiveToMain.Settings.enableDiamonds, GiveToMain.Settings.diamond)
    GiveCoin(GiveToMain.Settings.enableRawDiamonds, GiveToMain.Settings.rawDiamond)
    GiveCoin(GiveToMain.Settings.enableBlueDiamonds, GiveToMain.Settings.blueDiamond)
    GiveCoin(GiveToMain.Settings.enablePlatinumCoin, 'Platinum')
    GiveCoin(GiveToMain.Settings.enableGoldCoin, 'Gold')
    GiveCoin(GiveToMain.Settings.enableSilverCoin, 'Silver')
    GiveCoin(GiveToMain.Settings.enableCopperCoin, 'Copper')

    mq.delay(WaitTime)
    mq.cmd('/notify TradeWnd TRDW_Trade_Button leftmouseup')
    mq.delay(WaitTime)
end

return GiveToMain