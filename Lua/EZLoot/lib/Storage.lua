---@type Mq
local mq = require('mq')
local PackageMan = require('mq/PackageMan')
local Utils = require('mq/Utils')
local lfs_check = Utils.Library.Include("lfs")
if not lfs_check then
    if PackageMan.Install("luafilesystem") == 2 then
        print("User canceled the install, cannot proceed")
        mq.exit()
    end
end
local lfs = PackageMan.Require("luafilesystem", "lfs")

local storage = {}

function storage.ReadINI(filename, section, option)
    return mq.TLO.Ini.File(filename).Section(section).Key(option).Value()
end

function storage.SetINI(filename, section, option, value)
	print(filename, section, option, value)
    mq.cmdf('/ini "%s" "%s" "%s" "%s"',filename, section, option, value)
end

storage.dir_exists = function(path)
	if lfs.attributes(path, "mode") == "directory" then
		return true
	end
	return false
end

storage.make_dir = function(base_dir, dir)
    printf('function make_dir(%s, %s) Entry', base_dir, dir)
	if not storage.dir_exists(("%s/%s"):format(base_dir, dir)) then
		local success, error_msg = lfs.chdir(base_dir)
		if not success then
			-- Write.Error("Could not change to config directory: %s", error_msg)
			return false
		end
		success, error_msg = lfs.mkdir(dir)
		if not success then
			-- Write.Error("Could not create config directory: %s", error_msg)
			return false
		end
	end
	return true
end

function storage.SaveSettings(iniFile, settingsList)
    ---@diagnostic disable-next-line: undefined-field
    mq.pickle(iniFile, settingsList)
end

return storage