local mq = require('mq')
local actor = require('interface.actor')
local config = require('interface.configuration')
local ui = require('interface.ui')
local assist = require('routines.assist')
local camp = require('routines.camp')
local pull = require('routines.pull')
local tank = require('routines.tank')
local helpers = require('utils.helpers')
local logger = require('utils.logger')
-- local loot = require('utils.lootutils')
local loot = require('DroidLoot.lib.LootUtils')
local movement = require('utils.movement')
local timer = require('libaqo.timer')
local constants = require('constants')
local mode = require('mode')
local state = require('state')

local class
local commands = {}

function commands.init(_class)
    class = _class

    mq.bind('/aqo', commands.commandHandler)
    mq.bind(('/%s'):format(state.class), commands.commandHandler)
    mq.bind('/nowcast', commands.nowcastHandler)

    actor.register('commands', commands.callback)
end

local function printMDTable(columns, rows, keys, valueFormatter)
    local tbl = ''
    for _,col in ipairs(columns) do
        tbl = tbl .. '|' .. col
    end
    tbl = tbl .. '|\n'
    for _,_ in ipairs(columns) do
        tbl = tbl .. '|---'
    end
    tbl = tbl .. '|\n'
    if type(rows) == 'function' then
        tbl = rows(tbl)
    else
        for _,row in ipairs(rows) do
            if keys then
                for i,key in ipairs(keys) do
                    tbl = tbl .. '|' .. row[key]
                end
            elseif valueFormatter then
                tbl = tbl .. (valueFormatter(row) or '')
            else
                for i,val in ipairs(row) do
                    tbl = tbl .. '|' .. val
                end
            end
            tbl = tbl .. '|\n'
        end
    end
    tbl = tbl .. '\n'
    printf(tbl)
end

local function printMD()
    
end

---Display help information for the script.
local function showHelp()
    local prefix = '\n- /'..state.class..' '
    local output = logger.logLine('AQO Bot 1.0\n')
    output = output .. '\ayCommands:\aw'
    for _,command in ipairs(constants.commandHelp) do
        output = output .. prefix .. command.command .. ' -- ' .. command.tip
    end
    -- printMDTable({'Command', 'Description'}, constants.commandHelp, {'command', 'tip'})
    output = output .. '\n- /nowcast [name] alias <targetID> -- Tells the named character or yourself to cast a spell on the specified target ID.'
    for _,category in ipairs(config.categories()) do
        output = output .. '\n\ay' .. category .. ' configuration:\aw'
        for _,key in ipairs(config.getByCategory(category)) do
            local cfg = config[key]
            if type(cfg) == 'table' and (not cfg.classes or cfg.classes[state.class]) then
                output = output .. prefix .. key .. ' <' .. type(cfg.value) .. '> -- '..cfg.tip
            end
        end
        -- printMDTable({'Command', 'Description'}, config.getByCategory(category), nil, function(key)
        --     local cfg = config[key]
        --     if type(cfg) == 'table' and (not cfg.classes or cfg.classes[state.class]) then
        --         return '|/' .. state.class .. ' ' .. key .. ' <' .. type(cfg.value) .. '>|' .. cfg.tip
        --     end
        -- end)
    end
    output = output .. '\n\ayClass Configuration\aw'
    for key,value in pairs(class.options) do
        local valueType = type(value.value)
        if valueType == 'string' or valueType == 'number' or valueType == 'boolean' then
            output = output .. prefix .. key .. ' <' .. valueType .. '>'
            if value.tip then output = output .. ' -- '..value.tip end
        end
    end
    -- printMDTable({'Command', 'Description'}, function(tbl)
    --     for key,value in pairs(class.options) do
    --         local valueType = type(value.value)
    --         if valueType == 'string' or valueType == 'number' or valueType == 'boolean' then
    --             tbl = tbl .. '|/' .. state.class .. ' ' .. key .. ' <' .. valueType .. '>|'
    --             if value.tip then tbl = tbl .. value.tip .. '|\n' else tbl = tbl .. '|\n' end
    --         end
    --     end
    --     return tbl
    -- end)
    output = output .. '\n\ayGear Check:\aw /tell <name> gear <slotname> -- Slot Names: ' .. constants.slotList
    output = output .. '\n\ayBuff Begging:\aw /tell <name> <alias> -- Aliases: '
    for alias,_ in pairs(class.requestAliases) do
        output = output .. alias .. ', '
    end
    output = (output .. '\ax'):gsub('cls', state.class)
    -- output is too long for the boring old chat window
    if not mq.TLO.Plugin('MQ2ChatWnd').IsLoaded() then logger.info(output) end
end

---Process binding commands.
---@vararg string @The input given to the bind command.
function commands.commandHandler(...)
    local args = {...}
    if not args[1] then
        showHelp()
        return
    end

    local opt = args[1]:upper()
    local new_value = args[2] and args[2]:lower()
    local configName = config[opt] and opt or nil
    if opt == 'HELP' then
        showHelp()
    elseif opt == 'RESTART' then
        state.restart = true
    elseif opt == 'SAVE' then
        class:saveSettings()
        logger.info('Saved settings')
    elseif opt == 'DEBUG' then
        local section = args[2]
        local subsection = args[3]
        if logger.flags[section] and logger.flags[section][subsection] ~= nil then
            logger.flags[section][subsection] = not logger.flags[section][subsection]
        end
    elseif opt == 'SELL' and not new_value then
        loot.sellStuff()
    elseif opt == 'BURNNOW' then
        if new_value then
        -- if constants.burns[new_value] then
            state.burn_type = new_value
        elseif not new_value then
            state.burn_type = nil
        end
        state.burnNow = true
        logger.info('\arActivating Burns (on demand%s)\ax', state.burn_type and ' - '..state.burn_type or '')
    elseif opt == 'PREBURN' then
        if class.preburn then class:preburn() end
    elseif opt == 'PAUSE' then
        if not new_value then
            state.resetCombatState()
            state.paused = not state.paused
            if state.paused then
                mq.cmd('/stopcast')
            end
        else
            if constants.booleans[new_value] == nil then return end
            if state.paused ~= constants.booleans[new_value] then state.resetCombatState() end
            state.paused = constants.booleans[new_value]
            if state.paused then
                mq.cmd('/stopcast')
            else
                camp.setCamp()
            end
        end
    elseif opt == 'SHOW' then
        ui.toggleGUI(true)
    elseif opt == 'HIDE' then
        ui.toggleGUI(false)
    elseif opt == 'MODE' then
        local current_mode = config.get('MODE')
        if new_value then new_value = mode.nameFromString(new_value) end
        config.getOrSetOption(opt, config.get(configName), new_value, configName)
        if config.get('MODE') ~= current_mode then
            mode.currentMode = mode.fromString(config.get('MODE'))
            state.resetCombatState()
            if not state.paused then camp.setCamp() end
        end
    elseif opt == 'RESETCAMP' then
        camp.setCamp(true)
    elseif opt == 'RETURN' then
        camp.returnToCamp(true)
    elseif opt == 'CAMPRADIUS' or opt == 'RADIUS' or opt == 'PULLARC' then
        config.getOrSetOption(opt, config.get(configName), new_value, configName)
        camp.setCamp()
    elseif opt == 'TIMESTAMPS' then
        config.getOrSetOption(opt, config.get(configName), new_value, configName)
        logger.timestamps = config.get(configName)
    elseif configName then
        config.getOrSetOption(opt, config.get(configName), new_value, configName)
        local pullSettings = config.getByCategory('Pull')
        for _,v in ipairs(pullSettings) do if v == opt then pull.clearPullVars('configupdate') end end
    elseif opt == 'IGNORE' then
        local zone = mq.TLO.Zone.ShortName()
        if new_value then
            config.addIgnore(zone, args[2]) -- use not lowercased value
        else
            local target_name = mq.TLO.Target.CleanName()
            if target_name then config.addIgnore(zone, target_name) end
        end
    elseif opt == 'UNIGNORE' then
        local zone = mq.TLO.Zone.ShortName()
        if new_value then
            config.removeIgnore(zone, args[2]) -- use not lowercased value
        else
            local target_name = mq.TLO.Target.CleanName()
            if target_name then config.removeIgnore(zone, target_name) end
        end
    elseif opt == 'ADDCLICKY' then
        local clickyType = new_value
        local itemName = mq.TLO.Cursor()
        local nextIndex = 3
        local clicky = {name=itemName, clickyType=clickyType, enabled=true}
        if not itemName then
            clicky.name = args[3]
            nextIndex = 4
        end
        for i=nextIndex,#args do
            local match = args[i]:gmatch('[^/]+')
            local first = match()
            local secondstring = match()
            if first and secondstring then
                local second
                if tonumber(secondstring) then second = tonumber(secondstring)
                elseif secondstring == 'true' then second = true
                elseif secondstring == 'false' then second = false
                else second = secondstring end
                clicky[first] = second
            end
        end
        if clicky.name then
            -- printf('Add Clicky: name=%s, clickyType=%s, enabled=%s, summonMinimum=%s, alias=%s, condition=%s, usebelowpct=%s, opt=%s',
            --     clicky.name, clicky.clickyType, clicky.enabled, clicky.summonMinimum, clicky.alias, clicky.condition, clicky.usebelowpct, clicky.opt)
            class:addClicky(clicky)
            class:saveSettings()
        else
            logger.info('addclicky Usage:\n\tPlace clicky item on cursor\n\t/%s addclicky category\n\tCategories: burn, mash, heal, buff', state.class)
        end
    elseif opt == 'REMOVECLICKY' then
        local itemName = mq.TLO.Cursor()
        if not itemName then
            itemName = args[2]
        end
        if itemName then
            class:removeClicky(itemName)
            class:saveSettings()
        else
            logger.info('removeclicky Usage:\n\tPlace clicky item on cursor\n\t/%s removeclicky', state.class)
        end
    elseif opt == 'ENABLECLICKY' then
        local itemName = mq.TLO.Cursor()
        if not itemName then
            itemName = args[2]
        end
        if itemName then
            class:enableClicky(itemName)
            class:saveSettings()
        else
            logger.info('enableclickyUsage:\n\tPlace clicky item on cursor\n\t/%s enableclicky', state.class)
        end
    elseif opt == 'DISABLECLICKY' then
        local itemName = mq.TLO.Cursor()
        if not itemName then
            itemName = args[2]
        end
        if itemName then
            class:disableClicky(itemName)
            class:saveSettings()
        else
            logger.info('disableclickyUsage:\n\tPlace clicky item on cursor\n\t/%s disableclicky', state.class)
        end
    elseif opt == 'LISTCLICKIES' then
        local clickies = ''
        for clickyName,clicky in pairs(class.clickies) do
            clickies = clickies .. '\n- ' .. clickyName .. ' (' .. clicky.clickyType .. ') Enabled='..tostring(clicky.enabled)
        end
        logger.info('Clickies: %s', clickies)
    elseif opt == 'BUFFALIASES' then
        local aliases = 'Buff Aliases:\n'
        for _,buffline in ipairs(constants.bufflines) do
            aliases = aliases .. '- \ay' .. buffline.key .. '\ax\n'
        end
        logger.info(aliases)
    elseif opt == 'WANTBUFF' then
        local buffalias = args[2] and args[2]:upper() or nil
        local toggle = args[3] and args[3]:lower() or nil
        for _,buffline in ipairs(constants.bufflines) do
            if buffline.key == buffalias then
                if not toggle or constants.booleans[toggle] == nil then
                    logger.info('Want Buff: \ag%s\ax [\ay%s\ax]', buffalias, class.desiredBuffs[buffalias])
                else
                    class.desiredBuffs[buffalias] = constants.booleans[toggle]
                end
            end
        end
    elseif opt == 'OFFERBUFF' then
        local buffalias = args[2] and args[2]:upper() or nil
        local toggle = args[3] and args[3]:lower() or nil
        for _,buffline in ipairs(constants.bufflines) do
            if buffline.key == buffalias then
                if not toggle or constants.booleans[toggle] == nil then
                    logger.info('Offer Buff: \ag%s\ax [\ay%s\ax]', buffalias, class.availableBuffs[buffalias])
                else
                    class.availableBuffs[buffalias] = constants.booleans[toggle]
                end
            end
        end
    elseif opt == 'INVIS' then
        if class.invis then
            class:invis()
        end
    elseif opt == 'TRIBUTE' then
        mq.cmd('/keypress TOGGLE_TRIBUTEBENEFITWIN')
        mq.cmd('/notify TBW_PersonalPage TBWP_ActivateButton leftmouseup')
        mq.cmd('/keypress TOGGLE_TRIBUTEBENEFITWIN')
    elseif opt == 'BARK' then
        local repeatstring = ''
        for i=2,#args do
            repeatstring = repeatstring .. ' ' .. args[i]
        end
        mq.cmdf('/dgga /say %s', repeatstring)
    elseif opt == 'FORCE' then
        assist.forceAssist(new_value)
    elseif opt == 'UPDATE' then
        os.execute('start https://github.com/aquietone/aqobot/archive/refs/heads/emu.zip')
    elseif opt == 'DOCS' then
        os.execute('start https://aquietone.github.io/docs/aqobot/classes/'..state.class)
    elseif opt == 'WIKI' then
        os.execute('start https://www.lazaruseq.com/Wiki/index.php/Main_Page')
    elseif opt == 'BAZ' then
        os.execute('start https://www.lazaruseq.com/Magelo/index.php?page=bazaar')
    elseif opt == 'DOOR' then
        mq.cmd('/doortarget')
        mq.delay(50)
        mq.cmd('/click left door')
    elseif opt == 'MANASTONE' then
        local manastone = mq.TLO.FindItem('Manastone')
        if not manastone() then return end
        state.useManastone = true
        state.manastoneCount = 0
    elseif opt == 'ARMPETS' then
        class:armPets()
    elseif opt == 'ASSISTME' then
        state.tankMobID = mq.TLO.Target.ID()
        tank.callAssist()
    elseif opt == 'BLOCKSPELLS' then
        for _,spellid in ipairs(constants.BLOCKSPELLS) do
            mq.cmdf('/blockspell add me %s', spellid)
            mq.delay(1)
        end
        for _,spellid in ipairs(constants.BLOCKPETSPELLS) do
            mq.cmdf('/blockspell add pet %s', spellid)
            mq.delay(1)
        end
        if constants.intClasses[mq.TLO.Me.Class.ShortName()] then
            mq.cmdf('/blockspell add me %s', 5415) -- talisman of wunshi, use caster self shield buff
        end
    elseif opt == 'REZ' then
        -- mq.delay(3000, function() return not mq.TLO.Me.Casting() end)
        -- if class.rezAbility and not mq.TLO.Me.Casting() then
        --     mq.cmdf('/squelch /mqt pccorpse =%s', args[2])
        --     class.rezAbility:use()
        -- end
    elseif opt == 'REZALL' then
        class.massRez()
    elseif opt == 'REBUFF' then
        state.rebuff = true
    elseif opt == 'RTZ' then
        local heading = tonumber(args[2])
        if heading then
            mq.cmdf('/multiline ; /nav stop; /stick off; /afollow off;')
            mq.delay(100)
            mq.cmdf('/face fast heading %s', heading*-1)
            mq.delay(500)
            mq.cmd('/nomodkey /keypress forward hold')
            mq.delay(3000)
            mq.cmd('/nomodkey /keypress forward')
        else
            heading = mq.TLO.Me.Heading.Degrees()
            mq.cmdf('/noparse /dgge /docommand /${Me.Class.ShortName} rtz %s', heading)
        end
    elseif opt == 'CLEARTARGETS' then
        state.cleartargets = true
        state.previousmode = config.get('MODE')
        local newmode = mode.nameFromString('tank')
        config.getOrSetOption('MODE', config.get('MODE'), newmode, 'MODE')
        camp.setCamp()
    elseif opt == 'TIMERS' then
        local header = {script = 'aqo', server = mq.TLO.EverQuest.Server()}
        actor.actor:send(header, {id='commands', })
    elseif opt == 'GETTINGSTARTED' then
        state.ShowGettingStarted = true
    else
        commands.classSettingsHandler(opt, new_value)
    end
end

function commands.classSettingsHandler(opt, new_value)
    if new_value then
        if opt == 'SPELLSET' and class:get('SPELLSET') then
            if class.spellRotations[new_value] then
                logger.info('Setting %s to: %s', opt, new_value)
                class:set('SPELLSET', new_value)
            end
        elseif opt == 'USEEPIC' and class:get('USEEPIC') then
            if class.EPIC_OPTS[new_value] then
                logger.info('Setting %s to: %s', opt, new_value)
                class:set('USEEPIC', new_value)
            end
        elseif opt == 'AURA1' and class:get('AURA1') then
            if class.AURAS[new_value] then
                logger.info('Setting %s to: %s', opt, new_value)
                class:set('AURA1', new_value)
            end
        elseif opt == 'AURA2' and class:get('AURA2') then
            if class.AURAS[new_value] then
                logger.info('Setting %s to: %s', opt, new_value)
                class:set('AURA2', new_value)
            end
        elseif opt == 'PETTYPE' and class:get('PETTYPE') then
            if class.PetTypes[new_value] then
                logger.info('Setting %s to %s', opt, new_value)
                class:set('PETTYPE', new_value)
            end
        elseif type(class:get(opt)) == 'boolean' then
            if constants.booleans[new_value] == nil then return end
            class:set(opt, constants.booleans[new_value])
            logger.info('Setting %s to: %s', opt, constants.booleans[new_value])
        elseif type(class:get(opt)) == 'number' then
            if tonumber(new_value) then
                logger.info('Setting %s to: %s', opt, tonumber(new_value))
                class:set(opt, tonumber(new_value))
            end
        else
            logger.info('Unsupported command line option: %s %s', opt, new_value)
        end
    else
        if class.options[opt] ~= nil then
            logger.info('%s: %s', opt:lower(), class:get(opt))
        else
            logger.info('Unrecognized option: %s', opt)
        end
    end
end

function commands.nowcastHandler(...)
    class:nowCast({...})
end

function commands.callback(message)
    local content = message.content()
    if content.id == 'commands' then
        printf('received timer response')
    end
end

return commands