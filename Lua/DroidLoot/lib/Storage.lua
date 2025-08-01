---@type Mq
local mq = require('mq')

local storage = {}

storage.Debug = false

function storage.ReadINIValue(filename, section, option)
	return mq.TLO.Ini.File(filename).Section(section).Key(option).Value()
end

function storage.ReadINISection(filename, section)
	return mq.TLO.Ini.File(filename).Section(section)
end

function storage.SetINIValue(filename, section, option, value)
	mq.cmdf('/ini "%s" "%s" "%s" "%s"', filename, section, option, value)
end

storage.dir_exists = function(path)
	if storage.Debug then printf('function dir_exists(%s) Entry', path) end
	local ok, err, code = os.rename(path, path)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end

storage.make_dir = function(path)
	if storage.Debug then printf('function make_dir(%s) Entry', path) end
	local success, errorMsg = os.execute("mkdir \"" .. path .. "\"")
	if success then
		return true
	else
		return false, errorMsg
	end
end

function storage.SaveSettings(iniFile, settingsList)
	---@diagnostic disable-next-line: undefined-field
	mq.pickle(iniFile, settingsList)
end

return storage
