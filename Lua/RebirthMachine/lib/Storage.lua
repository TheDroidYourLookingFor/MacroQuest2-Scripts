---@type Mq
local mq = require('mq')

local storage = {}

function storage.ReadINI(filename, section, option)
	return mq.TLO.Ini.File(filename).Section(section).Key(option).Value()
end

function storage.SetINI(filename, section, option, value)
	print(filename, section, option, value)
	mq.cmdf('/ini "%s" "%s" "%s" "%s"', filename, section, option, value)
end

storage.dir_exists = function(path)
	printf('function dir_exists(%s) Entry', path)
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
	printf('function make_dir(%s) Entry', path)
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
