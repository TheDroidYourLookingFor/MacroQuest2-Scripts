---@type Mq
local mq = require('mq')
local Storage = require('BuffBot.Core.Storage')

local Progression = {}

Progression.Settings = {
    debug = true,
    command_Long = 'EzProgression',
    command_Short = 'EzPro',
    chatCommand = 'dgt',
    EZCharIni = mq.configDir .. '\\EZProgression_' .. mq.TLO.Me() .. '.ini',
    EZArmorIni = mq.configDir .. '\\EZProgression_Armor_List' .. '.ini',
    myClass = mq.TLO.Me.Class.Name(),
    Tiers = 'QVIC|CAZIC|T1|T2|T3|T4|T5|T6|T7|T8|',
    TierList = 'QVIC|CAZIC|T1|T2|T3|T4|T5|T6|T7|T8|',
    Slots = 'Head|Chest|Arms|Legs|Wrist1|Wrist2|Hands|Feet|',
    SlotList = 'Head,Chest,Arms,Legs,Wrist,Hands,Feet',
    SlotsShort = 'Head,Ches,Arms,Legs,Wris,Wris,Hand,Feet',
    ShowWrist2 = false
}

function Progression.Help()
    mq.cmdf('/%s \aw=============== \arEZ Progression Armor Tracker \aw===============',
        Progression.Settings.chatCommand)
    mq.cmdf('/%s Tiers: \aoQVIC, CAZIC, T1, T2, T3, T4, T5, T6, T7, T8 \ax(Not available - T9, T10)',
        Progression.Settings.chatCommand)
    mq.cmdf('/%s Slots: \aoHead, Chest, Arms, Legs, Wrist, Hands, Feet', Progression.Settings.chatCommand)
    mq.cmdf('/%s \ayUsage: \aw/Progression \atCommand  \awor  \aw/EzP \atCommand', Progression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at(Blank) \ax-- Current Armor slot needed with needed pattern and component',
        Progression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at*Tier* \ax-- Armor status for the given \aoTier', Progression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at*Slot* \ax-- Armor status for the given \aoSlot', Progression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at*Tier* *Slot* \ax-- Armor status for the given \aoTier \axand \aoSlot',
        Progression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \atCompleted \ax-- Shows the highest Tier completed for each slot',
        Progression.Settings.chatCommand)
    mq.cmdf('/%s \ayExamples: \ax/Progression \aoCAZIC', Progression.Settings.chatCommand)
    mq.cmdf('/%s \ayExamples: \ax/Progression \aoT3 Chest', Progression.Settings.chatCommand)
    mq.cmdf('/%s \ayExamples: \ax/Progression \aoCompleted', Progression.Settings.chatCommand)
    mq.cmdf('/%s \aw=====================================================', Progression.Settings.chatCommand)
end

local function split(input, sep)
    if sep == nil then
        sep = "|"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function HaveMessage(itenName, PatternCount, Component1Count)
    local returnString
    if itenName ~= nil then
        if PatternCount > 0 then
            returnString = itenName .. ', PatternQty:' .. PatternCount
        end
    else
        if PatternCount > 0 then
            returnString = '\aw| \agHave: PatternQty:' .. PatternCount
        end
    end

    if itenName ~= nil then
        if Component1Count > 0 then
            returnString = itenName .. ', ComponentQty:' .. Component1Count
        end
    else
        if Component1Count > 0 then
            returnString = '\aw| \agHave: ComponentQty:' .. Component1Count
        end
    end

    return returnString
end

local function NeedMessage(itenName, ComponentCount)
    local returnString

    if itenName ~= nil then
        returnString = itenName .. ', ' .. "'" .. ComponentCount .. "'\aw"
    else
        returnString = '\aw| \agNeed: ' .. itenName
    end

    return returnString
end

local function SetupCharacter()
    local INI = Storage.ReadINI(Progression.Settings.EZCharIni, 1, 'Tier')
    if INI == 'NULL' then
        mq.cmdf('/%s No Progression INI found for \ay%s\aw, creating one.', Progression.Settings.chatCommand,
            mq.TLO.Me.Name())
        mq.cmdf('/alias /%s /ez Progression', Progression.Settings.command_Long)
        mq.cmdf('/alias /%s /ez Progression', Progression.Settings.command_Short)
        local tiersTable = split(Progression.Settings.Tiers, "|")
        local slotsTable = split(Progression.Settings.SlotList, ",")

        Storage.SetINI(Progression.Settings.EZCharIni, 'Settings', 'ShowWrist2', false)
        for i, tier in ipairs(tiersTable) do
            Storage.SetINI(Progression.Settings.EZCharIni, i, 'Tier', tier)
            for j, slot in ipairs(slotsTable) do
                Storage.SetINI(Progression.Settings.EZCharIni, i, slot .. '_Completed', false)
            end
        end
    end
end

local function ArmorCompleted()
    local intTier, strSlot
    local blnTierDone = false

    for s = 1, #Progression.Settings.SlotList do
        strSlot = Progression.Settings.SlotList[s]
        blnTierDone = false

        for t = #Progression.Settings.TierList, 1, -1 do
            if not blnTierDone then
                intTier = t
                if Progression.Settings.EZCharIni[tostring(intTier)][strSlot .. "_Completed"] == "TRUE" then
                    if mq.TLO.Plugin.MQ2DanNet.Version() then
                        mq.cmdf('/%s all \at %s \aw| \ao %s \aw| \agCompleted',
                            Progression.Settings.chatCommand,
                            Progression.Settings.TierList[intTier],
                            strSlot)
                    end
                    if mq.TLO.Plugin.MQ2EQBC.Version() then
                        mq.cmdf('/%s \at %s \aw| \ao %s \aw| \agCompleted',
                            Progression.Settings.chatCommand,
                            Progression.Settings.TierList[intTier],
                            strSlot)
                    end
                    blnTierDone = true
                end
            end
        end
    end

    mq.delay(1)
end

local function ArmorNeeded(strArgSlot, strArgTier, SetupLootFlag)
    printf("slot: %s", tostring(strArgSlot))
    printf("tier: %s", tostring(strArgTier))

    local slotsTable = split(Progression.Settings.Slots, "|")
    local slotsShortTable = split(Progression.Settings.SlotsShort, "|")
    local tiersTable = split(Progression.Settings.Tiers, "|")

    local TierStart, TierEnd, tp1, SlotStart, SlotEnd, intTier, strSlot, intPatternCount, intComponentCount, strPattern, strComponent, strHave, strNeed, blnTierDone, strDragonCls
    local strMsgHead, strMsgChest, strMsgArms, strMsgLegs, strMsgWrist1, strMsgWrist2, strMsgHands, strMsgFeet

    intPatternCount = 0
    intComponentCount = 0
    blnTierDone = false

    if strArgSlot and strArgSlot:len() > 0 then
        if Progression.Settings.SlotsShort:sub(5, 5) == "5" then
            SlotStart = 5
            SlotEnd = 6
        else
            SlotStart = tonumber(Progression.Settings.SlotsShort:sub(5, 5))
            SlotEnd = tonumber(Progression.Settings.SlotsShort:sub(5, 5))
        end
    else
        SlotStart = 1
        SlotEnd = #slotsTable
    end

    if strArgTier and #strArgTier > 0 then
        if Progression.Settings.TierList:find(strArgTier) then
            TierStart = Progression.Settings.TierList:find(strArgTier)
            TierEnd = Progression.Settings.TierList:find(strArgTier)
        else
            TierStart = 1
            TierEnd = #Progression.Settings.TierList
        end
    else
        TierStart = 1
        TierEnd = #Progression.Settings.TierList
    end

    for s = SlotStart, SlotEnd do
        strSlot = slotsTable[s]
        blnTierDone = false

        for t = TierStart, TierEnd do
            intTier = t
            if not blnTierDone then
                strPattern = Storage.ReadINI(Progression.Settings.EZArmorIni, intTier,
                    Progression.Settings.myClass .. "_" .. strSlot .. "_Pattern")
                strComponent = Storage.ReadINI(Progression.Settings.EZArmorIni, intTier,
                    Progression.Settings.myClass .. "_" .. strSlot .. "_Comp")
                strHave = ""
                strNeed = ""

                local finishedPiece = Storage.ReadINI(Progression.Settings.EZCharIni, t, strSlot .. "_Completed")
                if not finishedPiece then
                    intPatternCount = mq.TLO.FindItemCount(strPattern)() + mq.TLO.FindItemBankCount(strPattern)()

                    if intTier == 4 then
                        if strSlot == "Wrist1" or strSlot == "Wrist2" then
                            strDragonCls = "Dragon Class " .. strSlot:sub(1, 5) .. " Slot"
                        elseif strSlot == "Hands" then
                            strDragonCls = "Dragon Class " .. strSlot:sub(1, 4) .. " Slot"
                        else
                            strDragonCls = "Dragon Class " .. strSlot .. " Slot"
                        end

                        intPatternCount = intPatternCount + mq.TLO.FindItemCount(strDragonCls)() +
                            mq.TLO.FindItemBankCount(strDragonCls)()
                    end

                    if strComponent ~= "Null" then
                        intComponentCount = mq.TLO.FindItemCount(strComponent)() +
                            mq.TLO.FindItemBankCount(strComponent)()
                    end

                    if strSlot == "Wrist2" then
                        tp1 = intTier

                        local wrist1_Complete = Storage.ReadINI(Progression.Settings.EZCharIni, tp1, "Wrist1_Completed")
                        if wrist1_Complete then
                            if intPatternCount > 0 then
                                HaveMessage(strHave, intPatternCount, 0)
                            else
                                NeedMessage(strNeed, strPattern)
                            end

                            if strComponent ~= "Null" then
                                if intComponentCount > 0 then
                                    HaveMessage(strHave, 0, intComponentCount)
                                else
                                    NeedMessage(strNeed, strComponent)
                                end
                            end

                            strMsgWrist2 = strSlot ..
                                " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                            blnTierDone = true
                        else
                            if intPatternCount > 1 then
                                HaveMessage(strHave, intPatternCount, 0)
                            else
                                NeedMessage(strNeed, strPattern)
                            end

                            if strComponent ~= "Null" then
                                if intComponentCount > 1 then
                                    HaveMessage(strHave, 0, intComponentCount)
                                else
                                    NeedMessage(strNeed, strComponent)
                                end
                            end

                            strMsgWrist2 = strSlot ..
                                " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                            blnTierDone = true
                        end
                    else
                        if intPatternCount > 0 then
                            HaveMessage(strHave, intPatternCount, 0)
                        else
                            NeedMessage(strNeed, strPattern)
                        end

                        if strComponent ~= "Null" then
                            if intComponentCount > 0 then
                                HaveMessage(strHave, 0, intComponentCount)
                            else
                                NeedMessage(strNeed, strComponent)
                            end
                        end

                        strMsgHead = strSlot ..
                            " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                        blnTierDone = true
                    end

                    if strSlot == "Head" then
                        strMsgHead = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Chest" then
                        strMsgChest = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Arms" then
                        strMsgArms = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Legs" then
                        strMsgLegs = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Wrist1" then
                        strMsgWrist1 = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Wrist2" then
                        strMsgWrist2 = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Hands" then
                        strMsgHands = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Feet" then
                        strMsgFeet = t ..
                            " " ..
                            strSlot .. " " .. Progression.Settings.TierList[intTier] .. " " .. strNeed .. " " .. strHave
                    end
                end
            end
        end
        --
    end
    if strMsgHead:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgHead) end
    if strMsgChest:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgChest) end
    if strMsgArms:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgArms) end
    if strMsgLegs:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgLegs) end
    if strMsgWrist1:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgWrist1) end
    if Progression.Settings.ShowWrist2 then
        if strMsgWrist2:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgWrist2) end
    end
    if strMsgHands:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgHands) end
    if strMsgFeet:len() > 0 then mq.cmdf('/%s %s', Progression.Settings.chatCommand, strMsgFeet) end
end

local function UpdateCompletedArmor(strArgSlot)
    local t, tp1, s, SlotStart, SlotEnd, i
    local intTier, strSlot, strArmor, intSlotFound
    local blnTierDone = false

    -- 1 Parameter
    if strArgSlot and #strArgSlot > 0 then
        if Progression.Settings.SlotsShort:sub(5, 5) == "5" then
            SlotStart = 5
            SlotEnd = 6
        else
            SlotStart = tonumber(Progression.Settings.SlotsShort:sub(5, 5))
            SlotEnd = tonumber(Progression.Settings.SlotsShort:sub(5, 5))
        end
    else
        -- No Parameters
        SlotStart = 1
        SlotEnd = #Progression.Settings.SlotList
    end

    for s = SlotStart, SlotEnd do
        strSlot = Progression.Settings.SlotList[s]
        blnTierDone = false

        for t = #Progression.Settings.TierList, 1, -1 do
            if not blnTierDone then
                intTier = t
                strArmor = Storage.ReadINI(Progression.Settings.EZArmorIni, intTier, Progression.Settings.myClass .. "_" .. strSlot .. "_Pattern")

                -- If Tier_Slot not completed
                if Progression.Settings.EZCharIni[tostring(intTier)][strSlot .. "_Completed"] ~= "TRUE" then
                    intSlotFound = mq.TLO.FindItemCount(strArmor)() + mq.TLO.FindItemBankCount(strArmor)()

                    if strSlot == "Wrist2" then
                        -- Check if Wrist1 is completed
                        tp1 = intTier + 1

                        if Progression.Settings.EZCharIni[tostring(tp1)]["Wrist1_Completed"] then
                            if intSlotFound > 0 then
                                Progression.Settings.EZCharIni[tostring(intTier)][strSlot .. "_Completed"] = "TRUE"

                                if intTier > 1 then
                                    for i = intTier - 1, 1, -1 do
                                        Progression.Settings.EZCharIni[tostring(i)][strSlot .. "_Completed"] = "TRUE"
                                    end
                                end

                                Storage.SetINI(Progression.Settings.EZCharIni, intTier, strSlot .. '_Completed', true)
                                blnTierDone = true
                            end
                        else
                            if intSlotFound > 1 then
                                Progression.Settings.EZCharIni[tostring(intTier)][strSlot .. "_Completed"] = "TRUE"

                                if intTier > 1 then
                                    for i = intTier - 1, 1, -1 do
                                        Progression.Settings.EZCharIni[tostring(i)][strSlot .. "_Completed"] = "TRUE"
                                    end
                                end

                                Storage.SetINI(Progression.Settings.EZCharIni, intTier, strSlot .. '_Completed', true)
                                blnTierDone = true
                            end
                        end
                    else
                        if intSlotFound > 0 then
                            Progression.Settings.EZCharIni[tostring(intTier)][strSlot .. "_Completed"] = "TRUE"

                            if intTier > 1 then
                                for i = intTier - 1, 1, -1 do
                                    Progression.Settings.EZCharIni[tostring(i)][strSlot .. "_Completed"] = "TRUE"
                                end
                            end

                            Storage.SetINI(Progression.Settings.EZCharIni, intTier, strSlot .. '_Completed', true)
                            blnTierDone = true
                        end
                    end
                end
            end
        end
    end

    mq.delay(1)
end

local function EZProgressionLogic(strArg1, strArg2)
    local strArgTier
    local strArgSlot

    if strArg1 == nil or strArg1 == "" then
        error("strArg1 cannot be null or empty")
    end

    SetupCharacter()

    -- Has 2 Parameters
    if strArg2 and #strArg2 > 0 then
        if Progression.Settings.TierList[strArg1] and Progression.Settings.TierList[strArg1] > 0 then
            strArgTier = strArg1
        elseif Progression.Settings.SlotList[strArg1] and Progression.Settings.SlotList[strArg1] > 0 then
            strArgSlot = strArg1
        end

        if Progression.Settings.TierList[strArg2] and Progression.Settings.TierList[strArg2] > 0 then
            strArgTier = strArg2
        elseif Progression.Settings.SlotList[strArg2] and Progression.Settings.SlotList[strArg2] > 0 then
            strArgSlot = strArg2
        end
    else
        if Progression.Settings.TierList[strArg1] and Progression.Settings.TierList[strArg1] > 0 then
            strArgTier = strArg1
        elseif Progression.Settings.SlotList[strArg1] and Progression.Settings.SlotList[strArg1] > 0 then
            strArgSlot = strArg1
        end
    end

    -- Has at least 1 Parameter
    if #strArg1 == 0 then
        -- No Parameters - Show armor needed for lowest tier and all slots
        UpdateCompletedArmor()
        ArmorNeeded()
    else
        -- Has Parameters(s)
        if strArg1 == "Completed" then
            -- Show highest Tier Completed for all slots
            UpdateCompletedArmor()
            ArmorCompleted()
        elseif strArgSlot and #strArgSlot > 0 or strArgTier and #strArgTier > 0 then
            -- Show Needed armor for Tier and/or Slot provided
            UpdateCompletedArmor(strArgSlot)
            ArmorNeeded(strArgSlot, strArgTier)
        elseif strArg1 == "help" then
            Progression.Help()
        end
    end
end

function Progression.Main(...)
    local args = { ... }

    local function countArgs(...)
        return select("#", ...)
    end

    local argsCount = countArgs(args)
    if argsCount == 1 then
        EZProgressionLogic(args[1])
    elseif argsCount == 2 then
    else
        Progression.Help()
    end
end

return Progression
