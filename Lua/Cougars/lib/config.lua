local mq                        = require('mq')
local Set                       = require("mq.Set")

local Config                    = {
    _ScriptName = 'Cougars',
    _version = '1.0 Beta',
    _subVersion = "2024 Raid Addicts Version!",
    _name = "Cougar Farmer Lua Edition",
    _author = 'TheDroidUrLookingFor',
}
Config.__index                  = Config
Config.settings                 = {}


-- Global State
Config.Globals                  = {}
Config.Globals.debug            = false
Config.Globals.Loot_Character   = 'Winli'
Config.Globals.Do_Med           = true
Config.Globals.Med_At           = 95
Config.Globals.Use_Horse        = false
Config.Globals.Horse_Item       = 'Horsie'
Config.Globals.Name_EventEnder  = ''
Config.Globals.Name_Boss        = 'npc'
Config.Globals.Chat_Command     = '/dgt'
Config.Globals.Home_Command     = '/say #peqzone barren'
Config.Globals.Home_ZoneID      = 422
Config.Globals.Drop_Off_Command = '/lua run GTM ' .. Config.Globals.Loot_Character

Config.Globals.Summon_Item      = "Summon Companion"
Config.Globals.Engage_Command   = "/assistme"
Config.Globals.Engage_Command2  = '/quickburn'
Config.Globals.CorpseRadius     = 200
Config.Globals.ZoneWaitTime     = 10000
Config.Globals.spawnSearch      = '%s radius %d zradius 50'
Config.Globals.MainAssist       = ""
Config.Globals.NavStopDistance  = 125
Config.Globals.Last_Boss_Name   = ""
Config.Globals.last_Target_ID   = 0
Config.Globals.Target_Wait_Time = 5000
Config.Globals.CurLoadedChar    = mq.TLO.Me.DisplayName()
Config.Globals.CurLoadedClass   = mq.TLO.Me.Class.ShortName()
Config.Globals.CurServer        = mq.TLO.EverQuest.Server():gsub(" ", "")

Config.Globals.Heal_Name        = ''
Config.Globals.Heal_Pet_Pct     = 60
Config.Globals.Cast_Pet_Haste   = false
Config.Globals.Pet_Haste        = ''
if mq.TLO.Me.Class.Name() == 'Magician' then
    Config.Globals.Heal_Name = 'Renewal of Pegeen'
    Config.Globals.Pet_Haste = 'Happy Burnout (Xorbb)'
end
if mq.TLO.Me.Class.Name() == 'Necromancer' then
    Config.Globals.Heal_Name = 'Mending of Kesu'
    Config.Globals.Pet_Haste = 'Glyph of Death'
end
if mq.TLO.Me.Class.Name() == 'Beastlord' then
    Config.Globals.Heal_Name = 'Shower of Clawd'
    Config.Globals.Pet_Haste = 'Arag\'s Celerity'
end

Config.Boss                     = {}
Config.Boss.Safe_Locations      = {
    [1] = { Name = 'Lord Vyemm', X = -89.19, Y = 153.38, Z = 45.16 },
    [2] = { Name = 'Lord Koi`Doken', X = -49.54, Y = 727.41, Z = 98.09 },
}
-- Defaults
Config.DefaultConfig            = {
    -- [ UTILITIES ] --
    ['NavStopDistance'] = { DisplayName = "Navigation Stop Distance", Category = "Misc", Tooltip = "Distance to stop from the boss", Type = "Int", Default = 20, ConfigType = "Normal", },
}

-- Define color codes
-- Define color codes
Config.Colors                   = {
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

Config.DefaultCategories        = Set.new({})
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
