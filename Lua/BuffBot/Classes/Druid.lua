---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local druid = {}
druid.version = '1.0.0'

druid.allPorts = {
    'Zephyr Laurion',
    'Zephyr Shadow Valley',
    'Zephyr Shadeweaver\'s Tangle',
    'Zephyr Cobalt Scar',
    'Zephyr The Great Divide',
    'Zephyr Esianti',
    'Zephyr Skyfire',
    'Zephyr Tempest Temple',
    'Zephyr Lceanium',
    'Zephyr West Karana',
    'Zephyr Shard\'s Landing',
    'Zephyr Pillars of Alra',
    'Zephyr Beasts\' Domain',
    'Zephyr the Grounds',
    'Zephyr Brell\'s Rest',
    'Zephyr Plane of Time',
    'Zephyr Loping Plains',
    'Zephyr Direwind',
    'Zephyr Slaughter',
    'Zephyr Buried Sea',
    'Zephyr The Steppes',
    'Zephyr Tranquility',
    'Zephyr Bloodfields',
    'Zephyr Barindu',
    'Zephyr Dawnshroud',
    'Zephyr Natimbi',
    'Zephyr Arcstone',
    'Zephyr Undershore',
    'Zephyr Lavastorm',
    'Zephyr Knowledge',
    'Zephyr Misty',
    'Zephyr Cobalt Scar',
    'Zephyr Wakening Lands',
    'Zephyr Great Divide',
    'Zephyr Twilight',
    'Zephyr Secondary Anchor',
    'Zephyr Primary Anchor',
    'Zephyr Ro',
    'Zephyr Combines',
    'Zephyr Steamfont',
    'Zephyr Feerrott',
    'Zephyr Grimling',
    'Zephyr Stonebrunt',
    'Zephyr Surefall Glade',
    'Zephyr Commonlands',
    'Zephyr Karana',
    'Zephyr Iceclad',
    'Zephyr Butcherblock',
    'Zephyr Toxxulia',
    'Zephyr Nexus',
    'Zephyr Blightfire Moors'
}

druid.hp_Buffs = {
    'Emberquartz Blessing',
    'Emberquartz Skin',
    'Luclinite Blessing',
    'Luclinite Skin',
    'Opaline Blessing',
    'Opaline Skin',
    'Arcronite Blessing',
    'Arcronite Skin',
    'Shieldstone Blessing',
    'Shieldstone Skin',
    'Granitebark Blessing',
    'Granitebark Skin',
    'Stonebark Blessing',
    'Stonebark Skin',
    'Blessing of the Timbercore',
    'Timbercore Skin',
    'Blessing of the Heartwood',
    'Heartwood Skin',
    'Blessing of the Ironwood',
    'Ironwood Skin',
    'Blessing of the Direwild',
    'Direwild Skin',
    'Blessing of Steeloak',
    'Steeloak Skin',
    'Blessing of the Nine',
    'Protection of the Nine',
    'Protection of the Glades',
    'Protection of the Cabbage',
    'Natureskin',
    'Protection of Nature',
    'Skin like Nature',
    'Protection of Diamond',
    'Skin like Diamond',
    'Protection of Steel',
    'Skin like Steel',
    'Protection of Rock',
    'Skin like Rock',
    'Protection of Wood',
    'Skin like Wood'
}
druid.regen_Buffs = {
    'Talisman of the Unforgettable',
    'Spirit of the Unforgettable',
    'Talisman of the Tenacious',
    'Spirit of the Tenacious',
    'Talisman of the Enduring',
    'Spirit of the Enduring',
    'Talisman of the Unwavering',
    'Spirit of the Unwavering',
    'Talisman of the Faithful',
    'Spirit of the Faithful',
    'Talisman of the Steadfast',
    'Spirit of the Steadfast',
    'Talisman of the Indomitable',
    'Spiri of the Indomitable',
    'Talisman of the Relentless',
    'Spirit of the Relentless',
    'Talisman of the Resolute',
    'Spirit of the Resolute',
    'Talisman of the Stalwart',
    'Spirit of the Stalwart',
    'Blessing of Oak',
    'Oaken Vigor',
    'Blessing of Replenishment',
    'Replenishment',
    "Nature's Recovery",
    'Regrowth of the Grove',
    'Regrowth',
    'Pack Chloroplast',
    'Chloroplast',
    'Pack Regeneration',
    'Regeneration'
}
druid.big_ds_Buffs = {
    'Frondbarb',
    'Barkspur',
    'Fernspur',
    'Fernspike',
    'Thornspur',
    'Vinespur',
    'Stemfang',
    'Daggerthorn',
    'Thornspike',
    'Vinespike',
    'Duskthorn'
}
druid.ds_Buffs = {
    'Legacy of Bramblespikes',
    'Bramblespike Bulwark',
    'Legacy of Bloodspikes',
    'Nightspire Bulwark',
    'Legacy of Icebriars',
    'Icebriar Bulwark',
    'Legacy of Daggerspikes',
    'Daggerspike Bulwark',
    'Legacy of Daggerspurs',
    'Daggerspur Bulwark',
    'Legacy of Spikethistles',
    'Spikethistle Bulwark',
    'Legacy of Spineburrs',
    'Spineburr Bulwark',
    'Legacy of Bonebriar',
    'Bonebriar Bulwark',
    'Legacy of Brierbloom',
    'Brierbloom Bulwark',
    'Legacy of Viridithorns',
    'Viridifloral Bulwark',
    'Legacy of Viridiflora',
    'Viridifloral Shield',
    'Legacy of Nettles',
    'Nettle Shield',
    'Legacy of Bracken',
    'Shield of Bracken',
    'Ancient Legacy of Thorn',
    'Legacy of Thorn',
    'Shield of Blades',
    'Legacy of Spike',
    'Shield of Thorns',
    'Shield of Brambles',
    'Shield of Barbs',
    'Shield of Thistles'
}
druid.sow_Buffs = {
    'Spirit of Wolf',
    'Flight of Falcons',
    'Spirit of Falcons',
    'Flight of Eagles',
    'Spirit of Eagle',
    'Spirit of the Shrew',
    'Share Wolf Form',
    'Pack Spirit',
    'Pact Shrew'
}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

druid.portsList = {}
function druid.CheckForPort()
    druid.portsList = {}
    for spellBookSlot = 1, 1440 do
        if mq.TLO.Me.Book(spellBookSlot).Name() ~= nil then
            if string.find(mq.TLO.Me.Book(spellBookSlot).Name(), 'Zephyr') then
                if not mq.TLO.Me.Gem(mq.TLO.Me.Book(spellBookSlot).Name())() then
                    local portName = mq.TLO.Me.Book(spellBookSlot).Name()
                    table.insert(druid.portsList, portName)
                end
            end
        end
    end
    return table.sort(druid.portsList)
end

function druid.BuildPortText()
    local availablePorts = druid.CheckForPort()
    if availablePorts == nil then return 'Available Zephyrs: No ports currently.' end
    local out_Ports = 'Available Zephyrs:'
    for _, port in ipairs(druid.portsList) do
        --printf('Full: %s / Short: %s',port[1], port[2])
        local portNameShort = string.gsub(port, 'Zephyr: ', '')
        out_Ports = out_Ports .. ' ' .. portNameShort .. ','
    end
    out_Ports = string.sub(out_Ports, 1, -2)
    return out_Ports
end

function druid.CheckPorts()
    local availablePorts = druid.CheckForPort()
    if availablePorts == nil then availablePorts = druid.allPorts end
    local out_Ports = {}
    for _, port in ipairs(availablePorts) do
        local portNameShort = string.gsub(port, 'Zephyr: ', '')
        table.insert(out_Ports, portNameShort)
    end
    return out_Ports
end

druid.druid_settings = {
    version = druid.version,
    runDebug = DEBUG,

    dsBuffs = druid.ds_Buffs,
    ds_buff_1_45_current_idx = 29,
    ds_buff_46_60_current_idx = 24,
    ds_buff_61_70_current_idx = 6,
    ds_buff_71_84_current_idx = 3,
    ds_buff_85_plus_current_idx = 1,

    bigDSBuffs = druid.big_ds_Buffs,
    big_ds_buff_1_45_current_idx = 10,
    big_ds_buff_46_60_current_idx = 8,
    big_ds_buff_61_70_current_idx = 6,
    big_ds_buff_71_84_current_idx = 3,
    big_ds_buff_85_plus_current_idx = 1,

    hpBuffs = druid.hp_Buffs,
    hp_buff_1_45_current_idx = 29,
    hp_buff_46_60_current_idx = 24,
    hp_buff_61_70_current_idx = 8,
    hp_buff_71_84_current_idx = 5,
    hp_buff_85_plus_current_idx = 1,

    regenBuffs = druid.regen_Buffs,
    regen_buff_1_45_current_idx = 27,
    regen_buff_46_60_current_idx = 22,
    regen_buff_61_70_current_idx = 6,
    regen_buff_71_84_current_idx = 3,
    regen_buff_85_plus_current_idx = 1,

    sowBuffs = druid.sow_Buffs,
    sow_1_45_current_idx = 1,
    sow_46_plus_current_idx = 5,

    buffs_1_45_Enabled = false,
    buffs_46_60_Enabled = false,
    buffs_61_70_Enabled = false,
    buffs_71_84_Enabled = false,
    buffs_85_plus_Enabled = false
}

function druid.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, druid.druid_settings_settings)
end

function druid.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        druid.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= druid.version then
            druid.saveSettings()
            druid.Setup()
        else
            druid.druid_settings = conf
            druid.hp_Buffs = druid.druid_settings.hpBuffs
            druid.regen_Buffs = druid.druid_settings.regenBuffs
            druid.ds_Buffs = druid.druid_settings.dsBuffs
            druid.sow_Buffs = druid.druid_settings.sowBuffs
        end
    end
end

function druid.MemorizeSpells()
    if druid.druid_settings.buffs_1_45_Enabled then
        Casting.MemSpell(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_1_45_current_idx], 1)
        Casting.MemSpell(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_1_45_current_idx], 2)
        Casting.MemSpell(druid.druid_settings.dsBuffs[druid.druid_settings.ds_1_45_current_idx], 3)
        Casting.MemSpell(druid.druid_settings.sowBuffs[druid.druid_settings.sow_1_45_current_idx], 4)
    end

    if druid.druid_settings.buffs_46_60_Enabled then
        Casting.MemSpell(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_46_60_current_idx], 5)
        Casting.MemSpell(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_46_60_current_idx], 6)
        Casting.MemSpell(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_46_60_current_idx], 7)
        Casting.MemSpell(druid.druid_settings.sowBuffs[druid.druid_settings.sow_46_plus_current_idx], 8)
    end

    if druid.druid_settings.buffs_61_70_Enabled then
        Casting.MemSpell(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_61_70_current_idx], 9)
        Casting.MemSpell(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_61_70_current_idx], 10)
        Casting.MemSpell(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_61_70_current_idx], 11)
    end

    if druid.druid_settings.buffs_71_84_Enabled then
        Casting.MemSpell(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_71_84_current_idx], 13)
        Casting.MemSpell(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_71_84_current_idx], 14)
        Casting.MemSpell(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_71_84_current_idx], 15)
    end

    if druid.druid_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_85_plus_current_idx], 16)
        Casting.MemSpell(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_85_plus_current_idx], 15)
        Casting.MemSpell(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_85_plus_current_idx], 16)
    end
end

function druid.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_1_45_current_idx], 'gem2')
        Casting.CastBuff(druid.druid_settings.dsBuffs[druid.druid_settings.ds_1_45_current_idx], 'gem3')
        Casting.CastBuff(druid.druid_settings.sowBuffs[druid.druid_settings.sow_1_45_current_idx], 'gem4')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 then
        Casting.CastBuff(druid.druid_settings.sowBuffs[druid.druid_settings.sow_46_plus_current_idx], 'gem4')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_46_60_current_idx], 'gem4')
        Casting.CastBuff(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_46_60_current_idx], 'gem5')
        Casting.CastBuff(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_46_60_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_61_70_current_idx], 'gem8')
        Casting.CastBuff(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_61_70_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_71_84_current_idx], 'gem10')
        Casting.CastBuff(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_71_84_current_idx], 'gem11')
        Casting.CastBuff(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_71_84_current_idx], 'gem3')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(druid.druid_settings.hpBuffs[druid.druid_settings.hp_buff_85_plus_current_idx], 'gem1')
        Casting.CastBuff(druid.druid_settings.regenBuffs[druid.druid_settings.regen_buff_85_plus_current_idx], 'gem2')
        Casting.CastBuff(druid.druid_settings.dsBuffs[druid.druid_settings.ds_buff_85_plus_current_idx], 'gem3')
    end
end

local sow_Enabled
local sow_1_45_current_idx
local sow_46_plus_current_idx

local buffs_1_45_Enabled
local buffs_46_60_Enabled
local buffs_61_70_Enabled
local buffs_71_84_Enabled
local buffs_85_plus_Enabled

local hp_buff_1_45_current_idx
local hp_buff_46_60_current_idx
local hp_buff_61_70_current_idx
local hp_buff_71_84_current_idx
local hp_buff_85_plus_current_idx

local regen_buff_1_45_current_idx
local regen_buff_46_60_current_idx
local regen_buff_61_70_current_idx
local regen_buff_71_84_current_idx
local regen_buff_85_plus_current_idx

local ds_buff_1_45_current_idx
local ds_buff_46_60_current_idx
local ds_buff_61_70_current_idx
local ds_buff_71_84_current_idx
local ds_buff_85_plus_current_idx

local big_ds_buff_1_45_current_idx
local big_ds_buff_46_60_current_idx
local big_ds_buff_61_70_current_idx
local big_ds_buff_71_84_current_idx
local big_ds_buff_85_plus_current_idx

function druid.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Druid v" .. druid.version) then
        ImGui.Text("DRUID:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.Separator()

        --
        -- SoW
        --
        if ImGui.TreeNode('Spirit of Wolf:') then
            ImGui.SameLine()
            druid.druid_settings.sow_Enabled = ImGui.Checkbox('Enable', druid.druid_settings.sow_Enabled)
            if sow_Enabled ~= druid.druid_settings.sow_Enabled then
                sow_Enabled = druid.druid_settings.sow_Enabled
                druid.saveSettings()
            end
            ImGui.Separator()

            druid.druid_settings.sow_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 SoW", druid.sow_Buffs,
                druid.druid_settings.sow_1_45_current_idx);
            if sow_1_45_current_idx ~= druid.druid_settings.sow_1_45_current_idx then
                sow_1_45_current_idx = druid.druid_settings.sow_1_45_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.sow_46_plus_current_idx = GUI.CreateBuffBox:draw("46+ SoW", druid.sow_Buffs,
                druid.druid_settings.sow_46_plus_current_idx);
            if sow_46_plus_current_idx ~= druid.druid_settings.sow_46_plus_current_idx then
                sow_46_plus_current_idx = druid.druid_settings.sow_46_plus_current_idx
                druid.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            druid.druid_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable', druid.druid_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= druid.druid_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = druid.druid_settings.buffs_1_45_Enabled
                druid.saveSettings()
            end
            ImGui.Separator()


            druid.druid_settings.hp_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 HP", druid.hp_Buffs,
                druid.druid_settings.hp_buff_1_45_current_idx);
            if hp_buff_1_45_current_idx ~= druid.druid_settings.hp_buff_1_45_current_idx then
                hp_buff_1_45_current_idx = druid.druid_settings.hp_buff_1_45_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.regen_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 REGEN", druid.regen_Buffs,
                druid.druid_settings.regen_buff_1_45_current_idx);
            if regen_buff_1_45_current_idx ~= druid.druid_settings.regen_buff_1_45_current_idx then
                regen_buff_1_45_current_idx = druid.druid_settings.regen_buff_1_45_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.ds_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 DS", druid.ds_Buffs,
                druid.druid_settings.ds_buff_1_45_current_idx);
            if ds_buff_1_45_current_idx ~= druid.druid_settings.ds_buff_1_45_current_idx then
                ds_buff_1_45_current_idx = druid.druid_settings.ds_buff_1_45_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.big_ds_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 BIG DS",
                druid.big_ds_Buffs,
                druid.druid_settings.big_ds_buff_1_45_current_idx);
            if big_ds_buff_1_45_current_idx ~= druid.druid_settings.big_ds_buff_1_45_current_idx then
                big_ds_buff_1_45_current_idx = druid.druid_settings.big_ds_buff_1_45_current_idx
                druid.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            druid.druid_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable', druid.druid_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= druid.druid_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = druid.druid_settings.buffs_46_60_Enabled
                druid.saveSettings()
            end
            ImGui.Separator()

            druid.druid_settings.hp_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 HP", druid.hp_Buffs,
                druid.druid_settings.hp_buff_46_60_current_idx);
            if hp_buff_46_60_current_idx ~= druid.druid_settings.hp_buff_46_60_current_idx then
                hp_buff_46_60_current_idx = druid.druid_settings.hp_buff_46_60_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.regen_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 REGEN", druid
                .regen_Buffs,
                druid.druid_settings.regen_buff_46_60_current_idx);
            if regen_buff_46_60_current_idx ~= druid.druid_settings.regen_buff_46_60_current_idx then
                regen_buff_46_60_current_idx = druid.druid_settings.regen_buff_46_60_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.ds_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 DS", druid.ds_Buffs,
                druid.druid_settings.ds_buff_46_60_current_idx);
            if ds_buff_46_60_current_idx ~= druid.druid_settings.ds_buff_46_60_current_idx then
                ds_buff_46_60_current_idx = druid.druid_settings.ds_buff_46_60_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.big_ds_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 BIG DS",
                druid.big_ds_Buffs,
                druid.druid_settings.big_ds_buff_46_60_current_idx);
            if big_ds_buff_46_60_current_idx ~= druid.druid_settings.big_ds_buff_46_60_current_idx then
                big_ds_buff_46_60_current_idx = druid.druid_settings.big_ds_buff_46_60_current_idx
                druid.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            druid.druid_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable', druid.druid_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= druid.druid_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = druid.druid_settings.buffs_61_70_Enabled
                druid.saveSettings()
            end
            ImGui.Separator()

            druid.druid_settings.hp_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 HP", druid.hp_Buffs,
                druid.druid_settings.hp_buff_61_70_current_idx);
            if hp_buff_61_70_current_idx ~= druid.druid_settings.hp_buff_61_70_current_idx then
                hp_buff_61_70_current_idx = druid.druid_settings.hp_buff_61_70_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.regen_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 REGEN", druid
                .regen_Buffs,
                druid.druid_settings.regen_buff_61_70_current_idx);
            if regen_buff_61_70_current_idx ~= druid.druid_settings.regen_buff_61_70_current_idx then
                regen_buff_61_70_current_idx = druid.druid_settings.regen_buff_61_70_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.ds_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 DS", druid.ds_Buffs,
                druid.druid_settings.ds_buff_61_70_current_idx);
            if ds_buff_61_70_current_idx ~= druid.druid_settings.ds_buff_61_70_current_idx then
                ds_buff_61_70_current_idx = druid.druid_settings.ds_buff_61_70_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.big_ds_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 BIG DS",
                druid.big_ds_Buffs,
                druid.druid_settings.big_ds_buff_61_70_current_idx);
            if big_ds_buff_61_70_current_idx ~= druid.druid_settings.big_ds_buff_61_70_current_idx then
                big_ds_buff_61_70_current_idx = druid.druid_settings.big_ds_buff_61_70_current_idx
                druid.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            druid.druid_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable', druid.druid_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= druid.druid_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = druid.druid_settings.buffs_71_84_Enabled
                druid.saveSettings()
            end
            ImGui.Separator()

            druid.druid_settings.hp_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 HP", druid.hp_Buffs,
                druid.druid_settings.hp_buff_71_84_current_idx);
            if hp_buff_71_84_current_idx ~= druid.druid_settings.hp_buff_71_84_current_idx then
                hp_buff_71_84_current_idx = druid.druid_settings.hp_buff_71_84_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.regen_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 REGEN", druid
                .regen_Buffs,
                druid.druid_settings.regen_buff_71_84_current_idx);
            if regen_buff_71_84_current_idx ~= druid.druid_settings.regen_buff_71_84_current_idx then
                regen_buff_71_84_current_idx = druid.druid_settings.regen_buff_71_84_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.ds_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 DS", druid.ds_Buffs,
                druid.druid_settings.ds_buff_71_84_current_idx);
            if ds_buff_71_84_current_idx ~= druid.druid_settings.ds_buff_71_84_current_idx then
                ds_buff_71_84_current_idx = druid.druid_settings.ds_buff_71_84_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.big_ds_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 BIG DS",
                druid.big_ds_Buffs,
                druid.druid_settings.big_ds_buff_71_84_current_idx);
            if big_ds_buff_71_84_current_idx ~= druid.druid_settings.big_ds_buff_71_84_current_idx then
                big_ds_buff_71_84_current_idx = druid.druid_settings.big_ds_buff_71_84_current_idx
                druid.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            druid.druid_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                druid.druid_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= druid.druid_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = druid.druid_settings.buffs_85_plus_Enabled
                druid.saveSettings()
            end
            ImGui.Separator()

            druid.druid_settings.hp_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ HP", druid.hp_Buffs,
                druid.druid_settings.hp_buff_85_plus_current_idx);
            if hp_buff_85_plus_current_idx ~= druid.druid_settings.hp_buff_85_plus_current_idx then
                hp_buff_85_plus_current_idx = druid.druid_settings.hp_buff_85_plus_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.regen_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ REGEN", druid
                .regen_Buffs,
                druid.druid_settings.regen_buff_85_plus_current_idx);
            if regen_buff_85_plus_current_idx ~= druid.druid_settings.regen_buff_85_plus_current_idx then
                regen_buff_85_plus_current_idx = druid.druid_settings.regen_buff_85_plus_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.ds_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ DS", druid.ds_Buffs,
                druid.druid_settings.ds_buff_85_plus_current_idx);
            if ds_buff_85_plus_current_idx ~= druid.druid_settings.ds_buff_85_plus_current_idx then
                ds_buff_85_plus_current_idx = druid.druid_settings.ds_buff_85_plus_current_idx
                druid.saveSettings()
            end

            druid.druid_settings.big_ds_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ BIG DS",
                druid.big_ds_Buffs,
                druid.druid_settings.big_ds_buff_85_plus_current_idx);
            if big_ds_buff_85_plus_current_idx ~= druid.druid_settings.big_ds_buff_85_plus_current_idx then
                big_ds_buff_85_plus_current_idx = druid.druid_settings.big_ds_buff_85_plus_current_idx
                druid.saveSettings()
            end
            imgui.TreePop()
        end
        --
        -- Help
        --
        if imgui.CollapsingHeader("Druid Options") then
            Settings.advertise = ImGui.Checkbox('Enable Advertising', Settings.advertise)
            ImGui.SameLine()
            ImGui.HelpMarker('Enables adversing to the player about the bots capabilities.')
            if Advertise ~= Settings.advertise then
                Advertise = Settings.advertise
                SaveSettings(IniPath, Settings)
            end

            Settings.advertiseChat = ImGui.InputText('Advertise Command', Settings.advertiseChat)
            ImGui.SameLine()
            ImGui.HelpMarker('The command used by the Buffer to advertises its capabilities to the player.')
            if AdvertiseChat ~= Settings.advertiseChat then
                AdvertiseChat = Settings.advertiseChat
                SaveSettings(IniPath, Settings)
            end

            Settings.advertiseMessage = ImGui.InputText('Advertise Message', Settings.advertiseMessage)
            ImGui.SameLine()
            ImGui.HelpMarker('The message displayed when the Buffer advertises its capabilities to the player.')
            if AdvertiseMessage ~= Settings.advertiseMessage then
                AdvertiseMessage = Settings.advertiseMessage
                SaveSettings(IniPath, Settings)
            end
            ImGui.Separator()

            Settings.portChat = ImGui.InputText('Port Command', Settings.portChat)
            ImGui.SameLine()
            ImGui.HelpMarker('The command used by the Buffer to advertises its capabilities to the player.')
            if PortChat ~= Settings.portChat then
                PortChat = Settings.portChat
                SaveSettings(IniPath, Settings)
            end

            Settings.portMessage = ImGui.InputText('Port Message', Settings.portMessage)
            ImGui.SameLine()
            ImGui.HelpMarker(
            'The message displayed when the Buffer advertises its capabilities to the player. This text is automatically generated based on the ports the Buffer has.')
            if PortMessage ~= Settings.portMessage then
                PortMessage = Settings.portMessage
                SaveSettings(IniPath, Settings)
            end
            ImGui.Separator()

            if imgui.Button('REBUILD##Save File') then
                SaveSettings(iniPath, druid.druid_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
        ImGui.Separator();
    end
end

return druid
