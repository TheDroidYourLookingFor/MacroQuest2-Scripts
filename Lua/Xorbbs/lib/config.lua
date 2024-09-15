local mq                                 = require('mq')
local Set                                = require("mq.Set")

local Config                             = {
    _ScriptName = 'Xorbbs',
    _version = '1.0 Beta',
    _subVersion = "2024 Raid Addicts Version!",
    _name = "Xorrb Farmer Lua Edition",
    _author = 'TheDroidUrLookingFor',
}
Config.__index                           = Config
Config.settings                          = {}

-- Global State
Config.Globals                           = {}
Config.Globals.ShowUI                    = false
Config.Globals.version                   = Config._version
Config.Globals.Terminate                 = false
Config.Globals.Infinite_Mode             = true
Config.Globals.Use_Bots                  = false
Config.Globals.IMode_Wait_Time           = '5m'
Config.Globals.Summon_Item               = "I don't really play silk classes much these days Mk. II"
Config.Globals.Engage_Command            = "/assistme /all"
Config.Globals.Engage_Command2           = '/quickburn /all'
Config.Globals.Wait_For_Stance           = true
Config.Globals.Combat_Stance             = 'Stance of Klettis (Xorbb)'
Config.Globals.CorpseRadius              = 200
Config.Globals.ZoneWaitTime              = 10000
Config.Globals.spawnSearch               = '%s radius %d zradius 50'
Config.Globals.MainAssist                = ""
Config.Globals.NavStopDistance           = 20
Config.Globals.Last_Boss_Name            = ""
Config.Globals.last_Target_ID            = 0
Config.Globals.Target_Wait_Time          = 5000
Config.Globals.CurLoadedChar             = mq.TLO.Me.DisplayName()
Config.Globals.CurLoadedClass            = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer                 = mq.TLO.EverQuest.Server():gsub(" ", "")

Config.XorbbSettings                     = {}
Config.XorbbZones                        = {
    version = Config._version
}
Config.XorbbZones.DraniksScar            = {}
Config.XorbbZones.DraniksScar.Bosses     = {
    ['Kyv_Targon'] = { Name = "Kyv Targon", Enabled = true, WaitForStance = false },
    ['Ukun_Farnar'] = { Name = "Ukun Farnar", Enabled = true, WaitForStance = false },
}

Config.XorbbZones.Harbingers             = {}
Config.XorbbZones.Harbingers.Bosses      = {
    ['Girplan_Deakan'] = { Name = "Girplan Deakan", Enabled = true, WaitForStance = false },
    ['Girplan_Defah'] = { Name = "Girplan Defah", Enabled = true, WaitForStance = false },
    ['Girplan_Ekaz'] = { Name = "Girplan Ekaz", Enabled = true, WaitForStance = false },
    ['Girplan_Garsz'] = { Name = "Girplan Garsz", Enabled = true, WaitForStance = false },
    ['The_Master_Wizard'] = { Name = "The_Master_Wizard", Enabled = true, WaitForStance = false },
}

Config.XorbbZones.BloodFields            = {}
Config.XorbbZones.BloodFields.Bosses     = {
    ['Feran_Ifkah'] = { Name = "Feran Ifkah", Enabled = true, WaitForStance = false },
    ['Bazu_Crusher'] = { Name = "Bazu Crusher", Enabled = true, WaitForStance = false },
}

Config.XorbbZones.Dranik                 = {}
Config.XorbbZones.Dranik.Bosses          = {
    ['Dragorn_Fendal'] = { Name = "Dragorn Fendal", Enabled = true, WaitForStance = false },
    ['Minotaur_Gurd'] = { Name = "Minotaur Gurd", Enabled = true, WaitForStance = false },
    ['The_Master_Battlemaster'] = { Name = "The Master Battlemaster", Enabled = true, WaitForStance = false },
}

Config.XorbbZones.Causeway               = {}
Config.XorbbZones.Causeway.Bosses        = {
    ['Succubus_Zall'] = { Name = "Succubus Zall", Enabled = true, WaitForStance = false },
    ['Chimera_Alfer'] = { Name = "Chimera Alfer", Enabled = true, WaitForStance = false },
    ['Ixt_Commner'] = { Name = "Ixt Commner", Enabled = true, WaitForStance = false },
}

Config.XorbbZones.WallofSlaughter        = {}
Config.XorbbZones.WallofSlaughter.Bosses = {
    ['Discording_Wazneph'] = { Name = "Discording Wazneph", Enabled = true, WaitForStance = true },
    ['Noc_Betz'] = { Name = "Noc Betz", Enabled = true, WaitForStance = true },
}

Config.XorbbZones.ProvingGrounds         = {}
Config.XorbbZones.ProvingGrounds.Bosses  = {
    ['Ratuk_Zoord'] = { Name = "Ratuk Zoord", Enabled = true, WaitForStance = true },
}

Config.XorbbZones.RiftSeekers            = {}
Config.XorbbZones.RiftSeekers.Bosses     = {
    ['The_Master_Cold_Bringer'] = { Name = "The Master Cold Bringer", Enabled = true, WaitForStance = true },
    ['The_Master_Heat_Bringer'] = { Name = "The Master Heat Bringer", Enabled = true, WaitForStance = true },
}

Config.BossZones                         = {
    ['DraniksScar'] = { Name = 'draniksscar', Enabled = true, BossList = Config.XorbbZones.DraniksScar.Bosses },
    ['Harbingers'] = { Name = 'harbingers', Enabled = true, BossList = Config.XorbbZones.Harbingers.Bosses },
    ['Bloodfields'] = { Name = 'bloodfields', Enabled = true, BossList = Config.XorbbZones.BloodFields.Bosses },
    ['Dranik'] = { Name = 'dranik', Enabled = true, BossList = Config.XorbbZones.Dranik.Bosses },
    ['Causeway'] = { Name = 'causeway', Enabled = true, BossList = Config.XorbbZones.Causeway.Bosses },
    ['WallofSlaughter'] = { Name = 'wallofslaughter', Enabled = true, BossList = Config.XorbbZones.WallofSlaughter.Bosses },
    ['ProvingGrounds'] = { Name = 'provinggrounds', Enabled = true, BossList = Config.XorbbZones.ProvingGrounds.Bosses },
    ['RiftSeekers'] = { Name = 'riftseekers', Enabled = true, BossList = Config.XorbbZones.RiftSeekers.Bosses },
}

-- Defaults
Config.DefaultConfig                     = {
    -- [ UTILITIES ] --
    ['NavStopDistance'] = { DisplayName = "Navigation Stop Distance", Category = "Misc", Tooltip = "Distance to stop from the boss", Type = "Int", Default = 20, ConfigType = "Normal", },
}

-- Define color codes
-- Define color codes
Config.Colors                            = {
    b = "\ab",  -- black
    B = "\a-b", -- black (dark)

    g = "\ag",  -- green
    G = "\a-g", -- green (dark)

    m = "\am",  -- magenta
    M = "\a-m", -- magenta (dark)

    o = "\ao",  -- orange
    O = "\a-o", -- orange (dark)

    p = "\ap",  -- purple
    P = "\a-p", -- purple (dark)

    r = "\ar",  -- red
    R = "\a-r", -- red (dark)

    t = "\at",  -- cyan
    T = "\a-t", -- cyan (dark)

    u = "\au",  -- blue
    U = "\a-u", -- blue (dark)

    w = "\aw",  -- white
    W = "\a-w", -- white (dark)

    y = "\ay",  -- yellow
    Y = "\a-y", -- yellow (dark)

    x = "\ax"   -- previous color
}

Config.DefaultCategories                 = Set.new({})
for _, v in pairs(Config.DefaultConfig) do
    if v.Type ~= "Custom" then
        Config.DefaultCategories:add(v.Category)
    end
end

Config.CommandHandlers = {}

function Config:GetConfigFileName()
    return mq.configDir .. '/Harbingers_' .. self.Globals.CurServer .. "_" .. self.Globals.CurLoadedChar .. '.lua'
end

function Config:SaveSettings(doBroadcast)
    mq.pickle(self:GetConfigFileName(), self.settings)
end

function Config:LoadSettings()
    self.Globals.CurLoadedChar  = mq.TLO.Me.DisplayName()
    self.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    self.Globals.CurServer      = mq.TLO.EverQuest.Server():gsub(" ", "")

    local needSave              = false

    local config, err           = loadfile(self:GetConfigFileName())
    if err or not config then
        self.settings = {}
        needSave = true
    else
        self.settings = config()
    end

    self.settings = ResolveDefaults(Config.DefaultConfig, self.settings)

    if needSave then
        self:SaveSettings(false)
    end

    return true
end

---@param defaults table
---@param settings table
---@return table
function ResolveDefaults(defaults, settings)
    -- Setup Defaults
    for k, v in pairs(defaults) do
        if settings[k] == nil then settings[k] = v.Default end

        if type(settings[k]) ~= type(v.Default) then
            settings[k] = v.Default
        end
    end

    -- Remove Deprecated options
    for k, _ in pairs(settings) do
        if not defaults[k] then
            settings[k] = nil
        end
    end

    return settings
end

function Config:GetSettings()
    return self.settings
end

function Config:SettingsLoaded()
    return self.settings ~= nil
end

return Config
