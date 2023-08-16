local mq = require('mq')
local version = '1.0.1'
local Storage = require('EZ.lib.Storage')

local EZProgression = {}

EZProgression.Settings = {
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

function EZProgression.Help()
    mq.cmdf('/%s \aw=============== \arEZ Progression Armor Tracker \aw===============',
        EZProgression.Settings.chatCommand)
    mq.cmdf('/%s Tiers: \aoQVIC, CAZIC, T1, T2, T3, T4, T5, T6, T7, T8 \ax(Not available - T9, T10)',
        EZProgression.Settings.chatCommand)
    mq.cmdf('/%s Slots: \aoHead, Chest, Arms, Legs, Wrist, Hands, Feet', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \ayUsage: \aw/EzProgression \atCommand  \awor  \aw/EzP \atCommand', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at(Blank) \ax-- Current Armor slot needed with needed pattern and component',
        EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at*Tier* \ax-- Armor status for the given \aoTier', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at*Slot* \ax-- Armor status for the given \aoSlot', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \at*Tier* *Slot* \ax-- Armor status for the given \aoTier \axand \aoSlot',
        EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \aw-- \atCompleted \ax-- Shows the highest Tier completed for each slot',
        EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \ayExamples: \ax/EzProgression \aoCAZIC', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \ayExamples: \ax/EzProgression \aoT3 Chest', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \ayExamples: \ax/EzProgression \aoCompleted', EZProgression.Settings.chatCommand)
    mq.cmdf('/%s \aw=====================================================', EZProgression.Settings.chatCommand)
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

local function SetupCharacter()
    local INI = Storage.ReadINI(EZProgression.Settings.EZCharIni, 1, 'Tier')
    if INI == 'NULL' then
        mq.cmdf('/%s No EZProgression INI found for \ay%s\aw, creating one.', EZProgression.Settings.chatCommand,
            mq.TLO.Me.Name())
        mq.cmdf('/alias /%s /ez ezprogression', EZProgression.Settings.command_Long)
        mq.cmdf('/alias /%s /ez ezprogression', EZProgression.Settings.command_Short)
        local tiersTable = split(EZProgression.Settings.Tiers, "|")
        local slotsTable = split(EZProgression.Settings.SlotList, ",")

        Storage.SetINI(EZProgression.Settings.EZCharIni, 'Settings', 'ShowWrist2', false)
        for i, tier in ipairs(tiersTable) do
            Storage.SetINI(EZProgression.Settings.EZCharIni, i, 'Tier', tier)
            for j, slot in ipairs(slotsTable) do
                Storage.SetINI(EZProgression.Settings.EZCharIni, i, slot .. '_Completed', false)
            end
        end
    end
end

-- Sub UpdateCompletedArmor
function UpdateCompletedArmor(strArgSlot)
    local t, tp1, s, SlotStart, SlotEnd, i
    local intTier, strSlot, strArmor, intSlotFound, blnTierDone
    local slotsTable = split(EZProgression.Settings.Slots, "|")
    local tiersTable = split(EZProgression.Settings.Tiers, "|")
    blnTierDone = false

    -- 1 Parameters
    if strArgSlot and string.len(strArgSlot) > 0 then
        if string.sub(strArgSlot, 1, 4) == "Wrist" then
            SlotStart = 5
            SlotEnd = 6
        else
            SlotStart = tonumber(string.sub(strArgSlot, 1, 4))
            SlotEnd = SlotStart
        end
    else
        -- no Parameters
        SlotStart = 1
        SlotEnd = #slotsTable
    end

    for s = SlotStart, SlotEnd do
        strSlot = slotsTable[s]
        blnTierDone = false

        for t = #tiersTable, 1, -1 do
            if not blnTierDone then
                intTier = t
                strArmor =
                    Storage.ReadINI(EZProgression.Settings.EZCharIni, t, mq.TLO.Me.Class.Name() .. "_" .. strSlot)

                -- If Tier_Slot not completed
                if not Storage.ReadINI(EZProgression.Settings.EZCharIni, t, strSlot .. "_Completed") then
                    intSlotFound = mq.TLO.FindItemCount(strArmor) + mq.TLO.FindItemBankCount(strArmor)

                    if strSlot == "Wrist2" then
                        -- Check if Wrist1 is completed
                        tp1 = intTier + 1
                        if Storage.ReadINI(EZProgression.Settings.EZCharIni, tp1, "Wrist1_Completed") then
                            if intSlotFound > 0 then
                                Storage.SetINI(EZProgression.Settings.EZCharIni, t, strSlot .. "_Completed", "TRUE")
                                if intTier > 1 then
                                    for i = intTier - 1, 1, -1 do
                                        Storage.SetINI(EZProgression.Settings.EZCharIni, i, strSlot .. "_Completed",
                                            "TRUE")
                                    end
                                end
                                blnTierDone = true
                            end
                        else
                            if intSlotFound > 1 then
                                Storage.SetINI(EZProgression.Settings.EZCharIni, t, strSlot .. "_Completed", "TRUE")
                                if intTier > 1 then
                                    for i = intTier - 1, 1, -1 do
                                        Storage.SetINI(EZProgression.Settings.EZCharIni, i, strSlot .. "_Completed",
                                            "TRUE")
                                    end
                                end
                                blnTierDone = true
                            end
                        end
                    else
                        if intSlotFound > 0 then
                            Storage.SetINI(EZProgression.Settings.EZCharIni, intTier, strSlot .. "_Completed", "TRUE")
                            if intTier > 1 then
                                for i = intTier - 1, 1, -1 do
                                    Storage.SetINI(EZProgression.Settings.EZCharIni, i, strSlot .. "_Completed", "TRUE")
                                end
                            end
                            blnTierDone = true
                        end
                    end
                end
            end
        end
    end
end

-- End Sub UpdateCompletedArmor

function ArmorNeeded(strArgSlot, strArgTier)
    local slotsTable = split(EZProgression.Settings.Slots, "|")
    local slotsShortTable = split(EZProgression.Settings.SlotsShort, "|")
    local tiersTable = split(EZProgression.Settings.Tiers, "|")

    local TierStart
    local TierEnd
    local tp1
    local s
    local SlotStart
    local SlotEnd
    local intTier
    local strSlot
    local intPatternCount
    local intComponentCount
    local strPattern
    local strComponent
    local strHave
    local strNeed
    local blnTierDone
    local strDragonCls

    local strMsgHead
    local strMsgChest
    local strMsgArms
    local strMsgLegs
    local strMsgWrist1
    local strMsgWrist2
    local strMsgHands
    local strMsgFeet

    if strArgSlot ~= nil then
        local slotIndex = tonumber(strArgSlot:sub(1, 4))
        if slotsShortTable[slotIndex] == 5 then
            SlotStart = 5
            SlotEnd = 6
        else
            SlotStart = slotIndex
            SlotEnd = slotIndex
        end
    else
        SlotStart = 1
        SlotEnd = #slotsTable
    end

    if strArgTier ~= nil then
        local tierIndex = tonumber(strArgTier)
        if tiersTable[tierIndex] ~= nil then
            TierStart = tierIndex
            TierEnd = tierIndex
        else
            TierStart = 1
            TierEnd = #tiersTable
        end
    else
        TierStart = 1
        TierEnd = #tiersTable
    end

    for s = SlotStart, SlotEnd do
        strSlot = slotsTable[s]
        blnTierDone = false

        for t = TierStart, TierEnd do
            intTier = t

            if not blnTierDone then
                strPattern = Storage.ReadINI(EZProgression.Settings.EZArmorIni, t,
                    EZProgression.Settings.myClass .. "_" .. strSlot .. "_Pattern")
                strComponent = Storage.ReadINI(EZProgression.Settings.EZArmorIni, tiersTable,
                    EZProgression.Settings.myClass .. "_" .. strSlot .. "_Comp")
                strHave = ""
                strNeed = ""
                local finishedPiece = Storage.ReadINI(EZProgression.Settings.EZCharIni, t, strSlot .. "_Completed")
                if not finishedPiece then
                    intPatternCount = mq.TLO.FindItemCount(strPattern) + mq.TLO.FindItemBankCount(strPattern)

                    -- T2 Dragon Class Armor Slots
                    if t == 4 then
                        if strSlot == "Wrist1" or strSlot == "Wrist2" then
                            strDragonCls = "Dragon Class " .. strSlot:sub(1, 5) .. " Slot"
                        elseif strSlot == "Hands" then
                            strDragonCls = "Dragon Class " .. strSlot:sub(1, 4) .. " Slot"
                        else
                            strDragonCls = "Dragon Class " .. strSlot .. " Slot"
                        end
                        intPatternCount = intPatternCount + mq.TLO.FindItemCount(strDragonCls) +
                            mq.TLO.FindItemBankCount(strDragonCls)
                    end

                    if strComponent ~= "Null" then
                        intComponentCount = mq.TLO.FindItemCount(strComponent) + mq.TLO.FindItemBankCount(strComponent)
                    end

                    if strSlot == "Wrist2" then
                        -- Check if Wrist 1 is completed
                        tp1 = t

                        local wrist1_Complete = Storage.ReadINI(EZProgression.Settings.EZCharIni, tp1,
                            "Wrist1_Completed")
                        if wrist1_Complete then
                            -- PATTERN
                            if intPatternCount > 0 then
                                strHave = HaveMessage(strHave, intPatternCount, 0)
                            else
                                strNeed = NeedMessage(strNeed, strPattern)
                            end

                            -- COMPONENT
                            if strComponent ~= "Null" then
                                if intComponentCount > 0 then
                                    strHave = HaveMessage(strHave, 0, intComponentCount)
                                else
                                    strNeed = NeedMessage(strNeed, strComponent)
                                end
                            end
                        else
                            -- PATTERN
                            if intPatternCount > 1 then
                                strHave = HaveMessage(strHave, intPatternCount, 0)
                            else
                                strNeed = NeedMessage(strNeed, strPattern)
                            end

                            -- COMPONENT
                            if strComponent ~= "Null" then
                                if intComponentCount > 1 then
                                    strHave = HaveMessage(strHave, 0, intComponentCount)
                                else
                                    strNeed = NeedMessage(strNeed, strComponent)
                                end
                            end
                        end
                    else
                        -- PATTERN
                        if intPatternCount > 0 then
                            strHave = HaveMessage(strHave, intPatternCount, 0)
                        else
                            strNeed = NeedMessage(strNeed, strPattern)
                        end

                        -- COMPONENT
                        if strComponent ~= "Null" then
                            if intComponentCount > 0 then
                                strHave = HaveMessage(strHave, 0, intComponentCount)
                            else
                                strNeed = NeedMessage(strNeed, strComponent)
                            end
                        end
                    end

                    -- Message with slot information
                    -- _G["strMsg" .. strSlot] = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    if strSlot == "Head" then
                        strMsgHead = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Chest" then
                        strMsgChest = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Arms" then
                        strMsgArms = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Legs" then
                        strMsgLegs = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Wrist1" then
                        strMsgWrist1 = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Wrist2" then
                        strMsgWrist2 = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Hands" then
                        strMsgHands = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    elseif strSlot == "Feet" then
                        strMsgFeet = t .. " " .. strSlot .. " " .. tiersTable[t] .. " " .. strNeed .. " " .. strHave
                    end
                    blnTierDone = true
                end
            end
        end
    end

    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgHead)
    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgChest)
    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgArms)
    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgLegs)
    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgWrist1)
    if EZProgression.Settings.ShowWrist2 then
        mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgWrist2)
    end
    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgHands)
    mq.cmdf('/%s %s', EZProgression.Settings.chatCommand, strMsgFeet)
end

local function ArmorCompleted()
    local t
    local s
    local intTier
    local blnTierDone
    local tiersTable = split(EZProgression.Settings.Tiers, "|")
    local slotsTable = split(EZProgression.Settings.SlotList, ",")

    -- Slots
    for _, strSlot in ipairs(slotsTable) do
        blnTierDone = false

        -- Tiers
        for _, tierValue in ipairs(tiersTable) do
            t = tonumber(tierValue)
            if not blnTierDone then
                intTier = t
                local TierCheck = Storage.ReadINI(EZProgression.Settings.EZCharIni, tierValue, strSlot .. "_Completed")
                -- print(TierCheck)
                if TierCheck then
                    mq.cmdf('/%s \at%s \aw| \ao%s \aw| \agCompleted', EZProgression.Settings.chatCommand, tierValue,
                        strSlot)
                    blnTierDone = true
                end
            end
        end
    end
end

function EZProgression.Main(tier, slot)
    local tier_length = 0
    local slot_length = 0
    if tier then
        tier_length = string.len(tier)
    end
    if slot then
        slot_length = string.len(slot)
    end
    local strArgTier
    local strArgSlot
    local tiersTable = split(EZProgression.Settings.Tiers, "|")    -- You need to define the split function
    local slotsTable = split(EZProgression.Settings.SlotList, ",") -- You need to define the split function
    SetupCharacter()

    if slot_length > 0 then
        local tierValue = tonumber(tier)
        local slotValue = tonumber(slot)

        if tierValue and tiersTable[tierValue] and tiersTable[tierValue] > 0 then
            strArgTier = tierValue
        elseif slotValue and slotsTable[slotValue] and slotsTable[slotValue] > 0 then
            strArgSlot = slotValue
        end

        if slotValue and tiersTable[slotValue] and tiersTable[slotValue] > 0 then
            strArgTier = slotValue
        elseif slotValue and slotsTable[slotValue] and slotsTable[slotValue] > 0 then
            strArgSlot = slotValue
        end
    else
        local tierValue = tonumber(tier)

        if tierValue ~= nil and tiersTable[tierValue] and tiersTable[tierValue] > 0 then
            strArgTier = tierValue
        elseif tierValue ~= nil and slotsTable[tierValue] and slotsTable[tierValue] > 0 then
            strArgSlot = tierValue
        end
    end

    if tier_length == 0 then
        -- no Parameters - Show armor needed for lowest tier and all slots
        UpdateCompletedArmor()
        ArmorNeeded()
    else
        if tier == "Completed" then
            UpdateCompletedArmor()
            ArmorCompleted()
        elseif tier or slot then
            UpdateCompletedArmor(slot)
            ArmorNeeded(slot, tier)
        elseif tier == "help" then
            EZProgression.Help()
        else
            EZProgression.Help()
        end
    end
end

return EZProgression
