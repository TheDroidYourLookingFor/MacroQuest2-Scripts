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
    CONSOLEMETHOD('function MemSpell(%s, %s)', spellToMem, spellGemNum)
    if not mq.TLO.Me.Book(spellToMem)() then return end
    if mq.TLO.Cursor.ID() then mq.cmd('/autoinventory') end
    if mq.TLO.Me.Gem(spellGemNum)() == spellToMem then return end
    if mq.TLO.Me.Gem(spellToMem)() == nil then
        CONSOLEMETHOD('Spell not memorized! \ar(%s)\ax', spellToMem)
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
    CONSOLEMETHOD('function CastBuff(' .. buffName .. ',' .. buffGem .. ') Entry')
    if not mq.TLO.Me.Book(buffName)() then return end
    if mq.TLO.Me.SpellInCooldown() then
        mq.delay(2000)
        casting.CastBuff(buffName, buffGem)
    end
    casting.MemSpell(buffName, buffGem)
    mq.delay(5500,
        function() return mq.TLO.Me.SpellReady(buffName)() == true or mq.TLO.Me.AltAbilityReady(buffName) == true end)
    PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', buffName, mq.TLO.Target())

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
    CONSOLEMETHOD('function CastItem(' .. itemName .. ') Entry')
    CONSOLEMETHOD('Casting ' .. itemName .. ' on ' .. mq.TLO.Target())
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. itemName .. '" item')
    mq.delay(15000, casting.DoneCasting)
    mq.doevents()
    mq.delay(1500)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.CastItem(itemName)
    end
end

function casting.CastAbility(abilityName)
    CONSOLEMETHOD('function CastAbility(' .. abilityName .. ') Entry')

    CONSOLEMETHOD('Casting ' .. abilityName .. ' on ' .. mq.TLO.Target())
    if mq.TLO.Me.AltAbility(abilityName)() then
        mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. abilityName .. '" alt')
        mq.delay(15000, casting.DoneCasting)
        mq.doevents()
        mq.delay(1500)
        if Fizzled_Last_Spell then
            Fizzled_Last_Spell = false
            casting.CastAbility(abilityName)
        end
    elseif mq.TLO.Me.CombatAbility(abilityName)() then
        mq.cmd('/disc ' .. '"' .. mq.TLO.Me.CombatAbility(abilityName)() .. '"')
    elseif mq.TLO.Me.Ability(abilityName)() then
        mq.cmd('/doability ' .. '"' .. mq.TLO.Me.Ability(abilityName)() .. '"')
    end
end

local Buff = ClassOptions.Buff
function casting.BuffTarget(WhoToBuff)
    CONSOLEMETHOD('local function BuffTarget(' .. WhoToBuff .. ') Entry')
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

    if mq.TLO.Target() == WhoToBuff then PRINTMETHOD('Buffing started on ' .. mq.TLO.Target() .. '!') else return end

    local windowOpen = mq.TLO.Window('TradeWnd').Open()
    if windowOpen then Accounting.ProcessTrade() end

    if TargPetID > 0 then
        mq.TLO.Spawn('id ' .. TargPetID).DoTarget()
        mq.delay(25, mq.TLO.Target.ID)
        mq.cmd('/face')
        Buff()
        PRINTMETHOD('Serviced: ' .. mq.TLO.Target())
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToBuff,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToBuff) -
                    Settings.BuffCost))
        end
    else
        PRINTMETHOD(WhoToBuff .. ' has no Pet moving on.')
    end

    if TargMercID > 0 then
        mq.TLO.Spawn('id ' .. TargMercID).DoTarget()
        mq.delay(25, mq.TLO.Target.ID)
        mq.cmd('/face')
        Buff()
        PRINTMETHOD('Serviced: ' .. mq.TLO.Target())
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToBuff,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToBuff) -
                    Settings.BuffCost))
        end
    else
        PRINTMETHOD(WhoToBuff .. ' has no Merc moving on.')
    end

    if mq.TLO.Spawn('pc ' .. WhoToBuff) then
        mq.TLO.Spawn('pc ' .. WhoToBuff).DoTarget()
        mq.delay(25, mq.TLO.Target.ID)
        mq.cmd('/face')
        Buff()
        PRINTMETHOD('Serviced: ' .. mq.TLO.Target())
        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToBuff,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToBuff) -
                    Settings.BuffCost))
        end
    end

    PRINTMETHOD('Buffing Finished on ' .. mq.TLO.Target() .. '!')
end

function casting.castRez(rezSpellName)
    CONSOLEMETHOD('Casting ' .. rezSpellName .. ' on ' .. mq.TLO.Target())
    if rezSpellName == 'Blessing of Resurrection' then
        mq.cmd('/alt act 3800')
    else
        casting.MemSpell(rezSpellName, 5)
        if not mq.TLO.Me.Book(rezSpellName)() then return end
        mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(rezSpellName).RankName() .. '" ')
    end
    PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', rezSpellName, mq.TLO.Target())
    mq.delay(15000, Casting.DoneCasting)
    mq.doevents()
    mq.delay(250)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.castRez(rezSpellName)
    end
end

function casting.castPort(portSpellName)
    CONSOLEMETHOD('Casting ' .. portSpellName .. ' on ' .. mq.TLO.Target())
    if not mq.TLO.Me.Book(portSpellName)() then return end
    casting.MemSpell(portSpellName, 5)
    mq.delay(5500, function() return mq.TLO.Me.SpellReady(portSpellName)() == true end)
    mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(portSpellName).RankName() .. '" ')
    PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', portSpellName, mq.TLO.Target())
    mq.delay(15000, Casting.DoneCasting)
    mq.doevents()
    mq.delay(250)
    if Fizzled_Last_Spell then
        Fizzled_Last_Spell = false
        casting.castPort(portSpellName)
    end
end

function casting.castSummon(summonSpellName, summonIsAltAbility)
    CONSOLEMETHOD('Casting ' .. summonSpellName .. ' on ' .. mq.TLO.Target())
    if summonIsAltAbility then
        local altID = mq.TLO.Me.AltAbility(summonSpellName).ID()
        mq.cmdf('/alt act %s', altID)
    else
        casting.MemSpell(summonSpellName, 5)
        mq.delay(5500, function() return mq.TLO.Me.SpellReady(summonSpellName)() == true end)
        mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(summonSpellName).RankName() .. '" ')
    end
    PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', summonSpellName, mq.TLO.Target())
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
            Storage.SetINI(Accounting.AccountsPath, 'Balances', WhoToSummon,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', WhoToSummon) - Settings.RezCost))
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
            CONSOLEMETHOD('User has no corpse.')
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

function casting.SummonToys(summonTarget, requestedAmount)
    CONSOLEMETHOD('function SummonToys(%s, %s)', summonTarget, requestedAmount)
    local summonAmmount = 1
    local MaxRequest = 20
    local TargAccBal = Accounting.GetBalance(summonTarget)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(summonTarget) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(summonTarget) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(summonTarget) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. summonTarget).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.SummonCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            summonTarget ..
            " (" ..
            summonTarget ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end
    if requestedAmount > MaxRequest then summonAmmount = MaxRequest else summonAmmount = requestedAmount end

    if mq.TLO.Spawn('pc ' .. summonTarget) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. summonTarget .. '" pc')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.cmd('/face')

        for i = 1, summonAmmount do
            if Class.magician_settings.enable_visor then
                casting.CastBuff(
                    Class.visor[Class.magician_settings.visor_current_idx], 1)
            end
            if Class.magician_settings.enable_weapon then
                casting.CastBuff(
                    Class.weapon[Class.magician_settings.weapon_current_idx], 2)
            end
            if Class.magician_settings.enable_armor then
                casting.CastBuff(
                    Class.armor[Class.magician_settings.armor_current_idx], 3)
            end
            if Class.magician_settings.enable_heirloom then
                casting.CastBuff(
                    Class.heirloom[Class.magician_settings.heirloom_current_idx], 4)
            end
        end

        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', summonTarget,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', summonTarget) - Settings.SummonCost))
        end
    end
end

function casting.SummonModRod(summonTarget)
    CONSOLEMETHOD('function SummonModRod(%s)', summonTarget)
    local TargAccBal = Accounting.GetBalance(summonTarget)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(summonTarget) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(summonTarget) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(summonTarget) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. summonTarget).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.SummonCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            summonTarget ..
            " (" ..
            summonTarget ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if mq.TLO.Spawn('pc ' .. summonTarget) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. summonTarget .. '" pc')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.cmd('/face')

        if Class.magician_settings.enable_modrod1 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod1_current_idx], 5)
        end
        if Class.magician_settings.enable_modrod2 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod2_current_idx], 6)
        end
        if Class.magician_settings.enable_modrod3 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod3_current_idx], 7)
        end
        if Class.magician_settings.enable_modrod4 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod4_current_idx], 8)
        end

        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', summonTarget,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', summonTarget) - Settings.SummonCost))
        end
    end
end

function casting.SummonOther(summonTarget)
    CONSOLEMETHOD('function SummonOther(%s)', summonTarget)
    local TargAccBal = Accounting.GetBalance(summonTarget)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(summonTarget) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(summonTarget) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(summonTarget) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. summonTarget).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.SummonCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            summonTarget ..
            " (" ..
            summonTarget ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if mq.TLO.Spawn('pc ' .. summonTarget) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. summonTarget .. '" pc')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.cmd('/face')

        if Class.magician_settings.enable_invis then
            casting.CastBuff(
                Class.invis[Class.magician_settings.invis_current_idx], 10)
        end
        if Class.magician_settings.enable_lev then
            casting.CastBuff(Class.lev[Class.magician_settings.lev_current_idx],
                11)
        end

        if Class.magician_settings.enable_modrod1 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod1_current_idx], 5)
        end
        if Class.magician_settings.enable_modrod2 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod2_current_idx], 6)
        end
        if Class.magician_settings.enable_modrod3 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod3_current_idx], 7)
        end
        if Class.magician_settings.enable_modrod4 then
            casting.CastBuff(
                Class.modrod[Class.magician_settings.modrod4_current_idx], 8)
        end
        if Class.magician_settings.enable_paradox then
            casting.CastBuff(
                Class.paradox[Class.magician_settings.paradox_current_idx], 9)
        end

        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', summonTarget,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', summonTarget) - Settings.SummonCost))
        end
    end
end

function casting.MageSummonItem(summonTarget, spellName, spellGem)
    CONSOLEMETHOD('function MageSummonItem(%s, %s, %s)', summonTarget, spellName, spellGem)
    local TargAccBal = Accounting.GetBalance(summonTarget)
    local TargIsFriend
    local TargGuildIsFriend
    if Settings.AccountMode then TargAccBal = Accounting.GetBalance(summonTarget) end
    if Settings.FriendMode then TargIsFriend = Accounting.GetFriend(summonTarget) end
    if Settings.GuildMode then TargGuildIsFriend = Accounting.GetGuild(summonTarget) end
    if Settings.BuffGuildOnly and mq.TLO.Spawn('pc ' .. summonTarget).Guild ~= mq.TLO.Me.Guild and not (TargIsFriend or TargGuildIsFriend) then return end
    if (Settings.AccountMode and TargAccBal < Settings.SummonCost) and not (TargIsFriend or TargGuildIsFriend or Settings.FriendFree or Settings.GuildFree) then
        mq.cmd("/tell " ..
            summonTarget ..
            " (" ..
            summonTarget ..
            ")Balance:(" ..
            TargAccBal .. ") Buff Cost:(" .. Settings.BuffCost .. ") Summon Cost:(" .. Settings.SummonCost .. "))")
        return
    end

    if mq.TLO.Spawn('pc ' .. summonTarget) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. summonTarget .. '" pc')
        mq.delay(2000, mq.TLO.Target.ID)
        mq.cmd('/face')

        casting.CastBuff(spellName, spellGem)

        if Settings.AccountMode and (not TargIsFriend and not Settings.FriendFree) and (not TargGuildIsFriend and not Settings.GuildFree) then
            Storage.SetINI(Accounting.AccountsPath, 'Balances', summonTarget,
                mq.TLO.Math(Storage.ReadINI(Accounting.AccountsPath, 'Balances', summonTarget) - Settings.SummonCost))
        end
    end
end

function casting.CastDPS(spellTargetID, spellName, spellGem)
    CONSOLEMETHOD('Casting ' .. spellName .. ' on ' .. mq.TLO.Target())
    if mq.TLO.Spawn(spellTargetID) then
        if mq.TLO.Me.Sitting() then mq.TLO.Me.Stand() end
        mq.cmd('/target "' .. spellTargetID .. '" id')
        mq.delay(2000, function() return mq.TLO.Target.ID() ~= nil end)
        mq.cmd('/face')
    else
        return
    end

    if spellGem == 'alt' then
        casting.CastAbility(spellName)
    elseif spellGem == 'item' then
        casting.CastItem(spellName)
    else
        if not mq.TLO.Me.Book(spellName)() then return end
        casting.MemSpell(spellName, spellGem)
        mq.cmd('/' .. cast_Mode .. ' ' .. '"' .. mq.TLO.Spell(spellName).RankName() .. '" ')
        PRINTMETHOD('Casting \ag %s \ax on \ag %s\ax', spellName, mq.TLO.Target())
        mq.delay(15000, Casting.DoneCasting)
        mq.doevents()
        mq.delay(250)
        if Fizzled_Last_Spell then
            Fizzled_Last_Spell = false
            casting.CastDPS(spellName)
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
