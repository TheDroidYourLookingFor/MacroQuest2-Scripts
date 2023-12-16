---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local magician = {}
magician.version = '1.0.0'

magician.ds_Buffs = {
    'Circle of Forgefire Coat',
    'Forgefire Coat',
    'Circle of Emberweave Coat',
    'Emberweave Coat',
    'Circle of Igneous Skin',
    'Igneous Coat',
    'Circle of the Inferno',
    'Inferno Coat',
    'Circle of Flameweaving',
    'Flameweave Coat',
    'Circle of Flameskin',
    'Flameskin',
    'Circle of Embers',
    'Embercoat',
    'Circle of Dreamfire',
    'Dreamfire Coat',
    'Circle of Brimstoneskin',
    'Brimstoneskin',
    'Circle of Lavaskin',
    'Lavaskin',
    'Circle of Magmaskin',
    'Magmaskin',
    'Circle of Fireskin',
    'Fireskin',
    'Maelstrom of Ro',
    'Flameshield of Ro',
    'Aegis of Ro',
    'Cadeau of Flame',
    'Boon of Immolation',
    'Shield of Lava',
    'Barrier of Combustion',
    'Inferno Shield',
    'Shield of Flame',
    'Shield of Fire'
}
magician.big_ds_Buffs = {
    'Boiling Skin',
    'Scorching Skin',
    'Burning Skin',
    'Blistering Skin',
    'Coronal Skin',
    'Infernal Skin',
    'Famished Flames',
    'Molten Skin',
    'Voracious Flames',
    'Blazing Skin',
    'Ravenous Flames',
    'Torrid Skin',
    'Hungry Flames',
    'Searing Skin',
    'Scorching Skin',
    'Ancient Veil of Pyrilonus',
    'Pyrilen Skin'
}
magician.surge_Buffs = {
    'Surge of Shadow',
    'Surge of Arcanum',
    'Surge of Shadowflares',
    'Surge of Thaumacretion'
}
magician.visor = {
    'Grant Visor of Shoen',
    'Grant Visor of Gobeker',
    'Grant Visor of Vabtik'
}
magician.weapon = {
    'Grant Goliath\'s Armaments',
    'Grant Shak Dathor\'s Armaments',
    'Grant Yalrek\'s Armaments',
    'Grant Wirn\'s Armaments',
    'Grant Thassis\' Armaments',
    'Grant Frightforged Armaments',
    'Grant Manaforged Armaments',
    'Grant Spectral Armaments'
}
magician.armor = {
    'Grant the Alloy\'s Plate',
    'Grant the Centien\'s Plate',
    'Grant Ocoenydd\'s Plate',
    'Grant Wirn\'s Plate',
    'Grant Thassis\' Plate',
    'Grant Frightforged Plate',
    'Grant Manaforged Plate',
    'Grant Spectral Plate'
}
magician.heirloom = {
    'Grant Ankexfen\'s Heirlooms',
    'Grant the Diabo\'s Heirlooms',
    'Grant Crystasia\'s Heirlooms',
    'Grant Ioulin\'s Heirlooms',
    'Grant Calix\'s Heirlooms',
    'Grant Nint\'s Heirlooms',
    'Grant Atleris\' Heirlooms',
    'Grant Enibik\'s Heirlooms'
}
magician.arrows = {
    'Grant Quiver of Kalkek'
}
magician.invis = {
    'Gift of Dawnlight',
    'Gift of Daybreak',
    'Grant Sphere of Air'
}
magician.lev = {
    'Grant Ring of Levitation'
}
magician.modrod = {
    'Modulating Shard VIII',
    'Rod of Courageous Modulation',
    'Wand of Frozen Modulation',
    'Wand of Burning Modulation',
    'Mass Dark Transvergence',
    'Wand of Dark Modulation',
    'Mass Phantasmal Transvergence',
    'Wand of Phantasmal Modulation',
    'Wand of Arcane Transvergence',
    'Wand of Spectral Transvergence',
    'Wand of Ethereal Transvergence',
    'Wand of Prime Transvergence',
    'Mass Elemental Transvergence',
    'Wand of Elemental Transvergence'
}
magician.paradox = {
    'Grant Voidfrost Paradox',
    'Grant Frostbound Paradox',
    'Grant Icebound Paradox',
    'Grant Frostrift Paradox',
    'Grant Glacial Paradox'
}

local toon = mq.TLO.Me.Name() or ''
local class = mq.TLO.Me.Class() or ''
local iniPath = mq.configDir .. '\\BuffBot\\Settings\\' .. 'BuffBot_' .. toon .. '_' .. class .. '.ini'

magician.magician_settings = {
    version = magician.version,
    runDebug = DEBUG,
    dsBuffs = magician.ds_Buffs,
    bigDSBuffs = magician.big_ds_Buffs,
    visorSummons = magician.visor,
    weaponSummons = magician.weapon,
    armorSummons = magician.armor,
    heirloomSummons = magician.heirloom,
    arrowSummons = magician.arrows,
    invisSummons = magician.invis,
    levSummons = magician.lev,
    modrodSummons = magician.modrod,
    paradoxSummons = magician.paradox,

    summonModShard = false,
    mod_shard = 'Small Modulation Shard',

    buffs_1_45_Enabled = false,
    ds_buff_1_45_current_idx = 1,
    big_ds_buff_1_45_current_idx = 1,

    buffs_46_60_Enabled = false,
    ds_buff_46_60_current_idx = 1,
    big_ds_buff_46_60_current_idx = 1,

    buffs_61_70_Enabled = false,
    ds_buff_61_70_current_idx = 1,
    big_ds_buff_61_70_current_idx = 1,

    buffs_71_84_Enabled = false,
    ds_buff_71_84_current_idx = 1,
    big_ds_buff_71_84_current_idx = 1,

    buffs_85_plus_Enabled = false,
    ds_buff_85_plus_current_idx = 1,
    big_ds_buff_85_plus_current_idx = 1,

    enable_visor = false,
    enable_weapon = false,
    enable_armor = false,
    enable_heirloom = false,
    enable_arrows = false,
    enable_invis = false,
    enable_lev = false,
    enable_paradox = false,
    enable_modrod1 = false,
    enable_modrod2 = false,
    enable_modrod3 = false,
    enable_modrod4 = false,
    visor_current_idx = 1,
    weapon_current_idx = 1,
    armor_current_idx = 1,
    heirloom_current_idx = 1,
    arrows_current_idx = 1,
    invis_current_idx = 1,
    lev_current_idx = 1,
    paradox_current_idx = 1,
    modrod1_current_idx = 1,
    modrod2_current_idx = 1,
    modrod3_current_idx = 1,
    modrod4_current_idx = 1,
}

function magician.saveSettings()
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniPath, magician.magician_settings)
end

function magician.Setup()
    local conf
    local configData, err = loadfile(iniPath)
    if err then
        magician.saveSettings()
    elseif configData then
        conf = configData()
        if conf.version ~= magician.version then
            magician.saveSettings()
            magician.Setup()
        else
        magician.magician_settings = conf
        magician.big_ds_Buffs = magician.magician_settings.bigDSBuffs
        magician.ds_Buffs = magician.magician_settings.dsBuffs
        end
    end
end

function magician.MemorizeSpells()
    if magician.magician_settings.buffs_1_45_Enabled then
        Casting.MemSpell(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_1_45_current_idx], 1)
        Casting.MemSpell(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_1_45_current_idx],
            2)
    end

    if magician.magician_settings.buffs_46_60_Enabled then
        Casting.MemSpell(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_46_60_current_idx], 3)
        Casting.MemSpell(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_46_60_current_idx],
            4)
    end

    if magician.magician_settings.buffs_61_70_Enabled then
        Casting.MemSpell(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_61_70_current_idx], 5)
        Casting.MemSpell(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_61_70_current_idx],
            6)
    end

    if magician.magician_settings.buffs_71_84_Enabled then
        Casting.MemSpell(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_71_84_current_idx], 7)
        Casting.MemSpell(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_71_84_current_idx],
            8)
    end

    if magician.magician_settings.buffs_85_plus_Enabled then
        Casting.MemSpell(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_85_plus_current_idx], 9)
        Casting.MemSpell(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_85_plus_current_idx], 10)
    end
end

function magician.Buff()
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 45 then
        Casting.CastBuff(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_1_45_current_idx], 'gem1')
        Casting.CastBuff(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_1_45_current_idx],
            'gem2')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 46 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 60 then
        Casting.CastBuff(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_46_60_current_idx], 'gem4')
        Casting.CastBuff(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_46_60_current_idx],
            'gem5')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 61 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 70 then
        Casting.CastBuff(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_61_70_current_idx], 'gem7')
        Casting.CastBuff(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_61_70_current_idx],
            'gem8')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 71 and mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() <= 84 then
        Casting.CastBuff(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_71_84_current_idx],
            'gem10')
        Casting.CastBuff(magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_71_84_current_idx],
            'gem11')
    end
    if mq.TLO.Spawn('ID ' .. mq.TLO.Target.ID()).Level() >= 85 then
        Casting.CastBuff(magician.magician_settings.dsBuffs[magician.magician_settings.ds_buff_85_plus_current_idx],
            'gem1')
        Casting.CastBuff(
            magician.magician_settings.bigDSBuffs[magician.magician_settings.big_ds_buff_85_plus_current_idx], 'gem2')
    end
end

local buffs_1_45_Enabled
local ds_buff_1_45_current_idx
local big_ds_buff_1_45_current_idx

local buffs_46_60_Enabled
local ds_buff_46_60_current_idx
local big_ds_buff_46_60_current_idx

local buffs_61_70_Enabled
local ds_buff_61_70_current_idx
local big_ds_buff_61_70_current_idx

local buffs_71_84_Enabled
local ds_buff_71_84_current_idx
local big_ds_buff_71_84_current_idx

local buffs_85_plus_Enabled
local ds_buff_85_plus_current_idx
local big_ds_buff_85_plus_current_idx

local enable_visor
local visor_current_idx
local enable_armor
local armor_current_idx
local enable_weapon
local weapon_current_idx
local enable_heirloom
local heirloom_current_idx
local enable_arrows
local arrows_current_idx
local enable_invis
local invis_current_idx
local enable_lev
local lev_current_idx
local enable_paradox
local paradox_current_idx
local enable_modrod1
local modrod1_current_idx
local enable_modrod2
local modrod2_current_idx
local enable_modrod3
local modrod3_current_idx
local enable_modrod4
local modrod4_current_idx
function magician.ShowClassBuffBotGUI()
    --
    -- Help
    --
    if imgui.CollapsingHeader("Magician v" .. magician.version) then
        ImGui.Text("MAGICIAN:")
        ImGui.BulletText("Hail for level appropriate buffs.")
        ImGui.BulletText("Magician: Will summon pet toys for a player when it hears \"toys\"")
        ImGui.BulletText("Magician: Will summon pet toys 1-20 for a player when it hears \"toys #\"")
        ImGui.BulletText("Magician: Will summon invis item for a player when it hears \"invis\"")
        ImGui.BulletText("Magician: Will summon arrows for a player when it hears \"arrows\"")
        ImGui.BulletText("Magician: Will summon a paradox for a player when it hears \"drod\"")
        ImGui.BulletText("Magician: Will summon mod rods for a player when it hears \"rod\"")
        ImGui.BulletText("Magician: Will summon everything but arrows for a player when it hears \"other\"")
        ImGui.Separator()
        --
        -- Buffs 1-45
        --
        if ImGui.TreeNode('1-45 Spells:') then
            ImGui.SameLine()
            magician.magician_settings.buffs_1_45_Enabled = ImGui.Checkbox('Enable',
                magician.magician_settings.buffs_1_45_Enabled)
            if buffs_1_45_Enabled ~= magician.magician_settings.buffs_1_45_Enabled then
                buffs_1_45_Enabled = magician.magician_settings.buffs_1_45_Enabled
                magician.saveSettings()
            end
            ImGui.Separator()


            magician.magician_settings.ds_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 DS", magician.ds_Buffs,
                magician.magician_settings.ds_buff_1_45_current_idx);
            if ds_buff_1_45_current_idx ~= magician.magician_settings.ds_buff_1_45_current_idx then
                ds_buff_1_45_current_idx = magician.magician_settings.ds_buff_1_45_current_idx
                magician.saveSettings()
            end

            magician.magician_settings.big_ds_buff_1_45_current_idx = GUI.CreateBuffBox:draw("1-45 BIG DS",
                magician.big_ds_Buffs,
                magician.magician_settings.big_ds_buff_1_45_current_idx);
            if big_ds_buff_1_45_current_idx ~= magician.magician_settings.big_ds_buff_1_45_current_idx then
                big_ds_buff_1_45_current_idx = magician.magician_settings.big_ds_buff_1_45_current_idx
                magician.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 46-60
        --
        if ImGui.TreeNode('46-60 Spells:') then
            ImGui.SameLine()

            magician.magician_settings.buffs_46_60_Enabled = ImGui.Checkbox('Enable',
                magician.magician_settings.buffs_46_60_Enabled)
            if buffs_46_60_Enabled ~= magician.magician_settings.buffs_46_60_Enabled then
                buffs_46_60_Enabled = magician.magician_settings.buffs_46_60_Enabled
                magician.saveSettings()
            end
            ImGui.Separator()

            magician.magician_settings.ds_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 DS",
                magician.ds_Buffs,
                magician.magician_settings.ds_buff_46_60_current_idx);
            if ds_buff_46_60_current_idx ~= magician.magician_settings.ds_buff_46_60_current_idx then
                ds_buff_46_60_current_idx = magician.magician_settings.ds_buff_46_60_current_idx
                magician.saveSettings()
            end

            magician.magician_settings.big_ds_buff_46_60_current_idx = GUI.CreateBuffBox:draw("46-60 BIG DS",
                magician.big_ds_Buffs,
                magician.magician_settings.big_ds_buff_46_60_current_idx);
            if big_ds_buff_46_60_current_idx ~= magician.magician_settings.big_ds_buff_46_60_current_idx then
                big_ds_buff_46_60_current_idx = magician.magician_settings.big_ds_buff_46_60_current_idx
                magician.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 61-70
        --
        if ImGui.TreeNode('61-70 Spells:') then
            ImGui.SameLine()
            magician.magician_settings.buffs_61_70_Enabled = ImGui.Checkbox('Enable',
                magician.magician_settings.buffs_61_70_Enabled)
            if buffs_61_70_Enabled ~= magician.magician_settings.buffs_61_70_Enabled then
                buffs_61_70_Enabled = magician.magician_settings.buffs_61_70_Enabled
                magician.saveSettings()
            end
            ImGui.Separator()

            magician.magician_settings.ds_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 DS",
                magician.ds_Buffs,
                magician.magician_settings.ds_buff_61_70_current_idx);
            if ds_buff_61_70_current_idx ~= magician.magician_settings.ds_buff_61_70_current_idx then
                ds_buff_61_70_current_idx = magician.magician_settings.ds_buff_61_70_current_idx
                magician.saveSettings()
            end

            magician.magician_settings.big_ds_buff_61_70_current_idx = GUI.CreateBuffBox:draw("61-70 BIG DS",
                magician.big_ds_Buffs,
                magician.magician_settings.big_ds_buff_61_70_current_idx);
            if big_ds_buff_61_70_current_idx ~= magician.magician_settings.big_ds_buff_61_70_current_idx then
                big_ds_buff_61_70_current_idx = magician.magician_settings.big_ds_buff_61_70_current_idx
                magician.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 71-84
        --
        if ImGui.TreeNode('71-84 Spells:') then
            ImGui.SameLine()
            magician.magician_settings.buffs_71_84_Enabled = ImGui.Checkbox('Enable',
                magician.magician_settings.buffs_71_84_Enabled)
            if buffs_71_84_Enabled ~= magician.magician_settings.buffs_71_84_Enabled then
                buffs_71_84_Enabled = magician.magician_settings.buffs_71_84_Enabled
                magician.saveSettings()
            end
            ImGui.Separator()

            magician.magician_settings.ds_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 DS",
                magician.ds_Buffs,
                magician.magician_settings.ds_buff_71_84_current_idx);
            if ds_buff_71_84_current_idx ~= magician.magician_settings.ds_buff_71_84_current_idx then
                ds_buff_71_84_current_idx = magician.magician_settings.ds_buff_71_84_current_idx
                magician.saveSettings()
            end

            magician.magician_settings.big_ds_buff_71_84_current_idx = GUI.CreateBuffBox:draw("71-84 BIG DS",
                magician.big_ds_Buffs,
                magician.magician_settings.big_ds_buff_71_84_current_idx);
            if big_ds_buff_71_84_current_idx ~= magician.magician_settings.big_ds_buff_71_84_current_idx then
                big_ds_buff_71_84_current_idx = magician.magician_settings.big_ds_buff_71_84_current_idx
                magician.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        --
        -- Buffs 85+
        --
        if ImGui.TreeNode('85+ Spells:') then
            ImGui.SameLine()
            magician.magician_settings.buffs_85_plus_Enabled = ImGui.Checkbox('Enable',
                magician.magician_settings.buffs_85_plus_Enabled)
            if buffs_85_plus_Enabled ~= magician.magician_settings.buffs_85_plus_Enabled then
                buffs_85_plus_Enabled = magician.magician_settings.buffs_85_plus_Enabled
                magician.saveSettings()
            end
            ImGui.Separator()

            magician.magician_settings.ds_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ DS",
                magician.ds_Buffs,
                magician.magician_settings.ds_buff_85_plus_current_idx);
            if ds_buff_85_plus_current_idx ~= magician.magician_settings.ds_buff_85_plus_current_idx then
                ds_buff_85_plus_current_idx = magician.magician_settings.ds_buff_85_plus_current_idx
                magician.saveSettings()
            end

            magician.magician_settings.big_ds_buff_85_plus_current_idx = GUI.CreateBuffBox:draw("85+ BIG DS",
                magician.big_ds_Buffs,
                magician.magician_settings.big_ds_buff_85_plus_current_idx);
            if big_ds_buff_85_plus_current_idx ~= magician.magician_settings.big_ds_buff_85_plus_current_idx then
                big_ds_buff_85_plus_current_idx = magician.magician_settings.big_ds_buff_85_plus_current_idx
                magician.saveSettings()
            end
            imgui.TreePop()
        end
        ImGui.Separator();

        local summonWidth = 400
        --
        -- Summon Items
        --
        if ImGui.TreeNode('Summon:') then
            if ImGui.TreeNode('Toys:') then
                magician.magician_settings.enable_visor = ImGui.Checkbox('Enable##Visor',
                    magician.magician_settings.enable_visor)
                if enable_visor ~= magician.magician_settings.enable_visor then
                    enable_visor = magician.magician_settings.enable_visor
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.visor_current_idx = GUI.CreateBuffBox:draw("Visor",
                    magician.visor,
                    magician.magician_settings.visor_current_idx);
                if visor_current_idx ~= magician.magician_settings.visor_current_idx then
                    visor_current_idx = magician.magician_settings.visor_current_idx
                    magician.saveSettings()
                end

                magician.magician_settings.enable_weapon = ImGui.Checkbox('Enable##Weapons',
                    magician.magician_settings.enable_weapon)
                if enable_weapon ~= magician.magician_settings.enable_weapon then
                    enable_weapon = magician.magician_settings.enable_weapon
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.weapon_current_idx = GUI.CreateBuffBox:draw("Weapon",
                    magician.weapon,
                    magician.magician_settings.weapon_current_idx);
                if weapon_current_idx ~= magician.magician_settings.weapon_current_idx then
                    weapon_current_idx = magician.magician_settings.weapon_current_idx
                    magician.saveSettings()
                end

                magician.magician_settings.enable_armor = ImGui.Checkbox('Enable##Armor',
                    magician.magician_settings.enable_armor)
                if enable_armor ~= magician.magician_settings.enable_armor then
                    enable_armor = magician.magician_settings.enable_armor
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.armor_current_idx = GUI.CreateBuffBox:draw("Armor",
                    magician.armor,
                    magician.magician_settings.armor_current_idx);
                if armor_current_idx ~= magician.magician_settings.armor_current_idx then
                    armor_current_idx = magician.magician_settings.armor_current_idx
                    magician.saveSettings()
                end

                magician.magician_settings.enable_heirloom = ImGui.Checkbox('Enable##Heirlooms',
                    magician.magician_settings.enable_heirloom)
                if enable_heirloom ~= magician.magician_settings.enable_heirloom then
                    enable_heirloom = magician.magician_settings.enable_heirloom
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.heirloom_current_idx = GUI.CreateBuffBox:draw("Heirloom",
                    magician.heirloom,
                    magician.magician_settings.heirloom_current_idx);
                if heirloom_current_idx ~= magician.magician_settings.heirloom_current_idx then
                    heirloom_current_idx = magician.magician_settings.heirloom_current_idx
                    magician.saveSettings()
                end
                imgui.TreePop()
            end
            if ImGui.TreeNode('Arrows:') then
                magician.magician_settings.enable_arrows = ImGui.Checkbox('Enable##Arrows',
                    magician.magician_settings.enable_arrows)
                if enable_arrows ~= magician.magician_settings.enable_arrows then
                    enable_arrows = magician.magician_settings.enable_arrows
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.arrows_current_idx = GUI.CreateBuffBox:draw("Arrows",
                    magician.arrows,
                    magician.magician_settings.arrows_current_idx);
                if arrows_current_idx ~= magician.magician_settings.arrows_current_idx then
                    arrows_current_idx = magician.magician_settings.arrows_current_idx
                    magician.saveSettings()
                end
                imgui.TreePop()
            end
            if ImGui.TreeNode('Invis:') then
                magician.magician_settings.enable_invis = ImGui.Checkbox('Enable##Invis',
                    magician.magician_settings.enable_invis)
                if enable_invis ~= magician.magician_settings.enable_invis then
                    enable_invis = magician.magician_settings.enable_invis
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.invis_current_idx = GUI.CreateBuffBox:draw("Invis",
                    magician.invis,
                    magician.magician_settings.invis_current_idx);
                if invis_current_idx ~= magician.magician_settings.invis_current_idx then
                    invis_current_idx = magician.magician_settings.invis_current_idx
                    magician.saveSettings()
                end
                imgui.TreePop()
            end
            if ImGui.TreeNode('Lev:') then
                magician.magician_settings.enable_lev = ImGui.Checkbox('Enable##Lev',
                    magician.magician_settings.enable_lev)
                if enable_lev ~= magician.magician_settings.enable_lev then
                    enable_lev = magician.magician_settings.enable_lev
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.lev_current_idx = GUI.CreateBuffBox:draw("Lev",
                    magician.lev,
                    magician.magician_settings.lev_current_idx);
                if lev_current_idx ~= magician.magician_settings.lev_current_idx then
                    lev_current_idx = magician.magician_settings.lev_current_idx
                    magician.saveSettings()
                end
                imgui.TreePop()
            end
            if ImGui.TreeNode('Paradox:') then
                magician.magician_settings.enable_paradox = ImGui.Checkbox('Enable##Paradox',
                    magician.magician_settings.enable_paradox)
                if enable_paradox ~= magician.magician_settings.enable_paradox then
                    enable_paradox = magician.magician_settings.enable_paradox
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.paradox_current_idx = GUI.CreateBuffBox:draw("Paradox",
                    magician.paradox,
                    magician.magician_settings.paradox_current_idx);
                if paradox_current_idx ~= magician.magician_settings.paradox_current_idx then
                    paradox_current_idx = magician.magician_settings.paradox_current_idx
                    magician.saveSettings()
                end
                imgui.TreePop()
            end
            if ImGui.TreeNode('Mod Rod:') then
                magician.magician_settings.enable_modrod1 = ImGui.Checkbox('Enable##ModRod1',
                    magician.magician_settings.enable_modrod1)
                if enable_modrod1 ~= magician.magician_settings.enable_modrod1 then
                    enable_modrod1 = magician.magician_settings.enable_modrod1
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.modrod1_current_idx = GUI.CreateBuffBox:draw("ModRod1",
                    magician.modrod,
                    magician.magician_settings.modrod1_current_idx);
                if modrod1_current_idx ~= magician.magician_settings.modrod1_current_idx then
                    modrod1_current_idx = magician.magician_settings.modrod1_current_idx
                    magician.saveSettings()
                end

                magician.magician_settings.enable_modrod2 = ImGui.Checkbox('Enable##ModRod2',
                    magician.magician_settings.enable_modrod2)
                if enable_modrod2 ~= magician.magician_settings.enable_modrod2 then
                    enable_modrod2 = magician.magician_settings.enable_modrod2
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.modrod2_current_idx = GUI.CreateBuffBox:draw("ModRod2",
                    magician.modrod,
                    magician.magician_settings.modrod2_current_idx);
                if modrod2_current_idx ~= magician.magician_settings.modrod2_current_idx then
                    modrod2_current_idx = magician.magician_settings.modrod2_current_idx
                    magician.saveSettings()
                end

                magician.magician_settings.enable_modrod3 = ImGui.Checkbox('Enable##ModRod3',
                    magician.magician_settings.enable_modrod3)
                if enable_modrod3 ~= magician.magician_settings.enable_modrod3 then
                    enable_modrod3 = magician.magician_settings.enable_modrod3
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.modrod3_current_idx = GUI.CreateBuffBox:draw("ModRod3",
                    magician.modrod,
                    magician.magician_settings.modrod3_current_idx);
                if modrod3_current_idx ~= magician.magician_settings.modrod3_current_idx then
                    modrod3_current_idx = magician.magician_settings.modrod3_current_idx
                    magician.saveSettings()
                end

                magician.magician_settings.enable_modrod4 = ImGui.Checkbox('Enable##ModRod4',
                    magician.magician_settings.enable_modrod4)
                if enable_modrod4 ~= magician.magician_settings.enable_modrod4 then
                    enable_modrod4 = magician.magician_settings.enable_modrod4
                    magician.saveSettings()
                end
                ImGui.SameLine()
                ImGui.PushItemWidth(summonWidth)
                magician.magician_settings.modrod4_current_idx = GUI.CreateBuffBox:draw("ModRod4",
                    magician.modrod,
                    magician.magician_settings.modrod4_current_idx);
                if modrod4_current_idx ~= magician.magician_settings.modrod4_current_idx then
                    modrod4_current_idx = magician.magician_settings.modrod4_current_idx
                    magician.saveSettings()
                end
                imgui.TreePop()
            end
            ImGui.PushItemWidth(425)
            imgui.TreePop()
        end

        --
        -- Help
        --
        if imgui.CollapsingHeader("Magician Options") then
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

            if imgui.Button('REBUILD##Save File') then
                SaveSettings(iniPath, magician.magician_settings)
            end
            ImGui.SameLine()
            ImGui.Text('Class File')
            ImGui.SameLine()
            ImGui.HelpMarker('Overwrites the current ' .. iniPath)
            ImGui.Separator();
        end
    end
end

return magician
