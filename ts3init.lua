--
-- TeamSpeak 3 init
--

-- Global table with all registered modules
-- Module authors should not modify this table directly, use ts3RegisterModule to register your module
ts3RegisteredModules = {}

-- Each Lua module should call ts3RegisterModule once with a unique module name
-- and a table with those TeamSpeak 3 callbacks the module wants to receive.
-- See testmodule/init.lua as an example
function ts3RegisterModule(moduleName, registeredEvents)
	print("Lua loading: " .. moduleName)
	ts3RegisteredModules[moduleName] = registeredEvents
end

function isServerGroupID( idlist, id )
	local splitGroupID = string.split(idlist, ",")
	for _, v in pairs(splitGroupID) do
		if tonumber(v) == id then
			return true
		end
	end
	return false
end

function FormatSecondsToTime( secondsArg )
   local weeks = math.floor(secondsArg / 604800)
   local remainder = secondsArg % 604800
   local days = math.floor(remainder / 86400)
   local remainder = remainder % 86400
   local hours = math.floor(remainder / 3600)
   local remainder = remainder % 3600
   local minutes = math.floor(remainder / 60)
   local seconds = remainder % 60
   
   return weeks, days, hours, minutes, seconds
end

function SaveTextToLog( text, file )
	local date = os.date( "*t" )
	local line = string.format( "[%04d/%02d/%02d %02d:%02d:%02d] %s", date.year, date.month, date.day, date.hour, date.min, date.sec, text )
	local file = io.open( file, "a" )
	file:write( line.."\n" )
	file:close()
	print( line )
end