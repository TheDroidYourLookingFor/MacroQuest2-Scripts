---@type Mq
local mq = require('mq')
local PackageMan = require("mq/PackageMan")
local lfs = PackageMan.Require("luafilesystem", "lfs")

local storage = {}

function storage.ReadINI(filename, section, option)
    return (mq.TLO.Ini(filename, section, option))
end

function storage.SetINI(filename, section, option, value)
    mq.cmd('/ini ' .. filename .. ' ' .. section .. ' ' .. option .. ' ' .. value)
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

return storage