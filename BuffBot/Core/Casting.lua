---@type Mq
local mq = require('mq')

local Storage = require('BuffBot.Core.Storage')

local className = mq.TLO.Me.Class.Name()
ClassOptions = require('BuffBot.Classes.' .. className .. '')

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
    CONSOLEMETHOD('function MemSpell(%s, %d)', spellToMem, spellGemNum)
    if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
    if mq.TLO.Me.Gem(spellGemNum)() == spellToMem then return end
    if not mq.TLO.Me.Book(spellToMem)() then return end
    if mq.TLO.Me.Gem(spellToMem)() == nil then
        CONSOLEMETHOD('Spell not memorized! (%s)', spellToMem)
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
function casting.CastBuff(buffName, buffGem)
    CONSOLEMETHOD('[' .. ScriptInfo() .. '] ---> function CastBuff(' .. buffName .. ',' .. buffGem .. ') Entry')
    if mq.TLO.Me.SpellInCooldown() then
        mq.delay('2s')
        casting.CastBuff(buffName, buffGem)
    end
    CONSOLEMETHOD('[' .. ScriptInfo() .. '] ---> Casting ' .. buffName .. ' on ' .. mq.TLO.Target())
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(buffName).RankName() .. '" ' .. buffGem)
    while mq.TLO.Me.Casting() do
        mq.delay(1000, casting.DoneCasting)
    end
    mq.doevents()
    mq.delay(1500)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.CastBuff(buffName, buffGem)
    end
end

function casting.CastItem(itemName)
    CONSOLEMETHOD('[' .. ScriptInfo() .. '] ---> function CastItem(' .. itemName .. ') Entry')
    if DEBUG then print('Casting ' .. itemName .. ' on ' .. mq.TLO.Target()) end
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. itemName .. '" item')
    mq.delay(15000, casting.DoneCasting)
    mq.doevents()
    mq.delay(1500)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.CastItem(itemName)
    end
end

local Buff = ClassOptions.Buff
function casting.BuffTarget(WhoToBuff)
    CONSOLEMETHOD('[' .. ScriptInfo() .. '] ---> local function BuffTarget(' .. WhoToBuff .. ') Entry')
    local TargMercID = mq.TLO.Spawn('pc ' .. WhoToBuff).MercID()
    local TargPetID = mq.TLO.Spawn('pc ' .. WhoToBuff).Pet.ID()
    local TargAccBal = Accounting.GetBalance(WhoToBuff)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(WhoToBuff) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(WhoToBuff) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(WhoToBuff) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. WhoToBuff).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.BuffCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            WhoToBuff ..
            " (" .. WhoToBuff .. ")Balance:(" .. TargAccBal .. ") Buff Cost:(" ..
            Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if Settings.advertise then
        mq.cmd(Settings.advertiseChat .. ' ' .. WhoToBuff .. ' ' .. Settings.advertiseMessage)
    end

    mq.TLO.Spawn('pc ' .. WhoToBuff).DoTarget()
    mq.delay(2, mq.TLO.Target.ID)

    if mq.TLO.Target() == WhoToBuff then print('Buffing started on ' .. mq.TLO.Target() .. '!') else return end

    local windowOpen = mq.TLO.Window('TradeWnd').Open()
    if windowOpen then Accounting.ProcessTrade() end

    if TargPetID > 0 then
        mq.TLO.Spawn('id ' .. TargPetID).DoTarget()
        mq.delay(2, mq.TLO.Target.ID)
        mq.cmd('/face')
        Buff()
        print('Serviced: ' .. mq.TLO.Target())
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToBuff,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToBuff) -
                    Settings.BuffCost))
        end
    else
        print(WhoToBuff .. ' has no Pet moving on.')
    end

    if TargMercID > 0 then
        mq.TLO.Spawn('id ' .. TargMercID).DoTarget()
        mq.delay(2, mq.TLO.Target.ID)
        mq.cmd('/face')
        Buff()
        print('Serviced: ' .. mq.TLO.Target())
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToBuff,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToBuff) -
                    Settings.BuffCost))
        end
    else
        print(WhoToBuff .. ' has no Merc moving on.')
    end

    if mq.TLO.Spawn('pc ' .. mq.TLO.Target()) then
        mq.TLO.Spawn('pc ' .. mq.TLO.Target()).DoTarget()
        mq.delay(2, mq.TLO.Target.ID)
        mq.cmd('/face')
        Buff()
        print('Serviced: ' .. mq.TLO.Target())
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToBuff,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToBuff) -
                    Settings.BuffCost))
        end
    end

    print('Buffing Finished on ' .. mq.TLO.Target() .. '!')
end

local cast_Mode = 'Casting'
function casting.castRez(rezSpellName)
    if DEBUG then print('Casting ' .. rezSpellName .. ' on ' .. mq.TLO.Target()) end
    if rezSpellName == 'Blessing of Resurrection' then
        mq.cmd('/alt act 3800')
    else
        mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(rezSpellName).RankName() .. '" ')
    end
    mq.delay(15000, Casting.DoneCasting)
    mq.doevents()
    mq.delay(250)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.castRez(rezSpellName)
    end
end

function casting.castPort(portSpellName)
    if DEBUG then print('Casting ' .. portSpellName .. ' on ' .. mq.TLO.Target()) end
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(portSpellName).RankName() .. '" ')
    mq.delay(15000, Casting.DoneCasting)
    mq.doevents()
    mq.delay(250)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.castPort(portSpellName)
    end
end

function casting.castSummon(summonSpellName, summonIsAltAbility)
    if DEBUG then print('Casting ' .. summonSpellName .. ' on ' .. mq.TLO.Target()) end
    if summonIsAltAbility then
        local altID = mq.TLO.Me.AltAbility(summonSpellName).ID()
        mq.cmdf('/alt act %s', altID)
    else
        mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(summonSpellName).RankName() .. '" ')
    end
    mq.delay(15000, Casting.DoneCasting)
    mq.doevents()
    mq.delay(250)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.castSummon(summonSpellName, summonIsAltAbility)
    end
end


function casting.SummonTarget(WhoToSummon, SummonSpell)
    local TargAccBal = Accounting.GetBalance(WhoToSummon)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(WhoToSummon) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(WhoToSummon) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(WhoToSummon) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. WhoToSummon).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.BuffCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
        WhoToSummon ..
            " (" ..
            WhoToSummon ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if mq.TLO.Spawn('pc ' .. WhoToSummon) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. WhoToSummon .. '" corpse')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.cmd('/face')
        local summonIsAltAbility = false
        if SummonSpell == 'Summon Remains' then summonIsAltAbility = true end
        casting.castSummon(SummonSpell, summonIsAltAbility)
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToSummon, mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToSummon) - Settings.RezCost))
        end
    end
end

local userHasCorpse = true
local function event_Failed_Target_Corpse()
    userHasCorpse = false
end

mq.event('NoCorpse', "#*#There are no spawns matching: (0-200) corpse#*#", event_Failed_Target_Corpse)

function casting.RezTarget(WhoToRez, RezSpell)
    local TargAccBal = Accounting.GetBalance(WhoToRez)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(WhoToRez) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(WhoToRez) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(WhoToRez) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. WhoToRez).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.BuffCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            WhoToRez ..
            " (" ..
            WhoToRez ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if mq.TLO.Spawn('pc ' .. WhoToRez) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. WhoToRez .. '" corpse')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.doevents()
        if not userHasCorpse then
            if DEBUG then print('User has no corpse.') end
            return
        end
        mq.cmd('/face')
        casting.castRez(RezSpell)
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToRez,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToRez) - Settings.RezCost))
        end
    end
end

function casting.PortTarget(whoToPort, spellToUse)
    CONSOLEMETHOD('function PortTarget(%s, %s)', whoToPort, spellToUse)
    local TargAccBal = Accounting.GetBalance(whoToPort)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(whoToPort) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(whoToPort) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(whoToPort) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. whoToPort).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.BuffCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            whoToPort ..
            " (" ..
            whoToPort ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if mq.TLO.Spawn('pc ' .. whoToPort) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. whoToPort .. '" pc')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.cmd('/face')
        casting.castPort(spellToUse)
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', whoToPort,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', whoToPort) - Settings.RezCost))
        end
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
