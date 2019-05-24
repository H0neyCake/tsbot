require("Modules_NyllCore/NyllCore")

--options
local chanelAltisId		= 781;
local chanelStratisId	= -1;
local chanelUnknownId	= 0;

function NyllCoreEventHandler.onTextMessageEvent( serverConnectionHandlerID, targetMode, toID, fromID, fromName, fromUniqueIdentifier, message, ffIgnored )
	-- body
end

function SaveToLog( text, logname )
	local date = os.date( "*t" )
	local line = string.format( "[%04d/%02d/%02d %02d:%02d:%02d] %s", date.year, date.month, date.day, date.hour, date.min, date.sec, text )
	local file = io.open( ts3.getPluginPath().."lua_plugin/"..logname..".log", "a" )
	file:write( line.."\n" )
	file:close()
	print( line )
end

local playerNameData = {}
local playerSpy = {}--

function CheckForRules( serverConnectionHandlerID, clientID, kostil )
	local channelID, channelError = ts3.getChannelOfClient(serverConnectionHandlerID, clientID)
	local serverGroupID, serverGroupError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_SERVERGROUPS)


	if ( channelID == chanelAltisId or channelID == chanelStratisId or channelID == chanelUnknownId ) and channelError == 0 then
		local tsName = {}
		local serverName = {}

		local name = ts3.getClientDisplayName(serverConnectionHandlerID, clientID)
		local inputStatus, inputError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_INPUT_MUTED)
		local outputStatus, outputError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_OUTPUT_MUTED)

		local _inputStatus, _inputError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_INPUT_HARDWARE)
		local _outputStatus, _outputError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_OUTPUT_HARDWARE)

		local awayStatus, awayError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_AWAY)

		if (tonumber(inputStatus) == 1 and inputError == 0) or (tonumber(_inputStatus) == 0 and _inputError == 0) then
			SaveToLog(string.format("[CLIENT_INPUT_MUTED] Kick: %s", name), "Kick")
			ts3.requestClientKickFromChannel(serverConnectionHandlerID, clientID, "Включи микрофон!")
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, string.format("Уважаемый %s. Вы нарушили правила использования TeamSpeak! ( [url]http://forum.extremo.club/topic/940-pravila-povedeniia-na-igrovom-servere-extremo/[/url] ) Во время пребывания на сервере ЗАПРЕЩЕНО выключать микрофон!", name), clientID)
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Для входа в игровую комнату зайдите в раздел Плагинов/Аддонов TeamSpeak, и нажмите кнопку <Обновить>.", clientID)
		end

		if (tonumber(outputStatus) == 1 and outputError == 0) or (tonumber(_outputStatus) == 0 and _outputError == 0) then
			SaveToLog(string.format("[CLIENT_OUTPUT_MUTED] Kick: %s", name), "Kick")
			ts3.requestClientKickFromChannel(serverConnectionHandlerID, clientID, "Включи динамики!")
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, string.format("Уважаемый %s. Вы нарушили правила использования TeamSpeak! ( [url]http://forum.extremo.club/topic/940-pravila-povedeniia-na-igrovom-servere-extremo/[/url] ) Во время пребывания на сервере ЗАПРЕЩЕНО выключать звук!", name), clientID)
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Для входа в игровую комнату зайдите в раздел Плагинов/Аддонов TeamSpeak, и нажмите кнопку <Обновить>.", clientID)
		end

		if tonumber(awayStatus) == 1 and awayError == 0 then
			SaveToLog(string.format("[CLIENT_AWAY] Kick: %s", name), "Kick")
			ts3.requestClientKickFromChannel(serverConnectionHandlerID, clientID, "Выключи режим АФК!")
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, string.format("Уважаемый %s. Вы нарушили правила использования TeamSpeak! ( [url]http://forum.extremo.club/topic/940-pravila-povedeniia-na-igrovom-servere-extremo/[/url] ) Во время пребывания на сервере ЗАПРЕЩЕНО включать режим AFK!", name), clientID)
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "Для входа в игровую комнату зайдите в раздел Плагинов/Аддонов TeamSpeak, и нажмите кнопку <Обновить>.", clientID)
		end

		if playerNameData and playerNameData[clientID] then
			for clientName in string.gmatch(playerNameData[clientID], "([a-zA-Z]+)") do
				table.insert(tsName, clientName)
			end

			for servName in string.gmatch(name, "([a-zA-Z]+)") do
				table.insert(serverName, servName)
			end

			for i = 1, #serverName do
				if tsName and serverName then
					if playerNameData[clientID] and (not tsName[i] or not serverName[i]) or (string.upper(tsName[i]) ~= string.upper(serverName[i])) then
						local uid = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_UNIQUE_IDENTIFIER)
						SaveToLog(string.format("[%s] Kick Server name: %s TS name: %s", uid, name, playerNameData[clientID]), "Name")
						ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, string.format("Вы были кикнуты за нарушение правил TS. При входе в TS, ник должен совпадать с игровым. Ваш игровой ник \"%s\" ваш ник при заходе в TS \"%s\"", name, playerNameData[clientID]), clientID)
						playerNameData[clientID] = nil
						ts3.requestClientKickFromServer(serverConnectionHandlerID, clientID, "имя ПРИ ВХОДЕ в тимспик должно совпадать с игровым!!!")
					end
				end
			end
		end
	elseif ( not kostil ) and ( channelID ~= chanelAltisId or channelID ~= chanelStratisId or channelID ~= chanelUnknownId ) and channelError == 0 then
		local name, nameError = ts3.getClientDisplayName(serverConnectionHandlerID, clientID)
		if name and name ~= "" and nameError == 0 then
			playerNameData[clientID] = name
		end
	end
end

function NyllCoreEventHandler.onConnectStatusChangeEvent()
	playerNameData = {}
	playerSpy = {}
end

function NyllCoreEventHandler.onUpdateClientEvent( serverConnectionHandlerID, clientID )
	CheckForRules(serverConnectionHandlerID, clientID, true)
	CheckForSpy(serverConnectionHandlerID)
end

local gameRoomID = {271, 171, 250, 284, 78, 79, 174, 207, 200, 201, 202, 286, 206, 265, 266, 268, 269, 294, 293, 283, 285, 77}

local function tContains(table, item)
	local index = 1;
	while table[index] do
		if (item and item == table[index] ) then
			return true;
		end
		index = index + 1;
	end
	return false;
end

function NyllCoreEventHandler.onClientMoveEvent( serverConnectionHandlerID, clientID, oldChannelID, newChannelID )
	CheckForRules(serverConnectionHandlerID, clientID)

	if playerSpy[clientID] and oldChannelID == chanelAltisId or oldChannelID == chanelStratisId or oldChannelID == chanelUnknownId or newChannelID == 0 then
		playerSpy[clientID] = nil
	end

	CheckForSpy(serverConnectionHandlerID)

	local overWolfStatus, overWolfError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, 60)

	if overWolfStatus and overWolfError == 0 then
		local name = ts3.getClientDisplayName(serverConnectionHandlerID, clientID)
		if string.find(overWolfStatus, "Overwolf=1") then
			local serverGroupID, serverGroupError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_SERVERGROUPS)

			if serverGroupID and serverGroupError == 0 then
				local clientGroupList = strsplit(serverGroupID, ",")
				for _, v in pairs(clientGroupList) do
					if tonumber(v) == 6 or tonumber(v) == 76 then
						return
					end
				end
			end

			SaveToLog(string.format("Kick: %s", name), "Overwolf")
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, string.format("Уважаемый %s. Вы нарушили правила использования TeamSpeak! ( [url]http://forum.extremo.club/topic/940-pravila-povedeniia-na-igrovom-servere-extremo/[/url] ) Во время пребывания в нашем TeamSpeak ЗАПРЕЩЕНО включать программу Overwolf!", name), clientID)
			ts3.requestClientKickFromServer(serverConnectionHandlerID, clientID, "Выключи Overwolf!")
		end
	end

	if clientID and newChannelID then
		if tContains(gameRoomID, tonumber(newChannelID)) then
			local serverGroupID, serverGroupError = ts3.getClientVariableAsString(serverConnectionHandlerID, clientID, ts3defs.ClientProperties.CLIENT_SERVERGROUPS)

			if serverGroupID and serverGroupError == 0 then
				local clientGroupList = strsplit(serverGroupID, ",")
				for _, v in pairs(clientGroupList) do
					if tonumber(v) == 6 or tonumber(v) == 76 or tonumber(v) == 24 then
						return
					end
				end
			end

			ts3.requestClientKickFromChannel(serverConnectionHandlerID, clientID, "Отказано в доступе!")
			ts3.requestSendPrivateTextMsg(serverConnectionHandlerID, "У вас нет доступа к данной комнате! Доступ есть только у членов клуба \"EX\", за подробностями обратитесь к Администрации.", clientID)
		end
	end
end

function NyllCoreEventHandler.onServerGroupClientDeletedEvent(serverConnectionHandlerID, clientID, clientName, clientUniqueIdentity, serverGroupID, invokerClientID, invokerName, invokerUniqueIdentity)
	if clientID then
		SaveToLog(string.format("[REMOVE] Admin %s [%s] remove server group %d from %s [%s]", invokerName, invokerUniqueIdentity, serverGroupID, clientName, clientUniqueIdentity), "Group")
	end
end
function NyllCoreEventHandler.onServerGroupClientAddedEvent(serverConnectionHandlerID, clientID, clientName, clientUniqueIdentity, serverGroupID, invokerClientID, invokerName, invokerUniqueIdentity)
	if clientID then
		SaveToLog(string.format("[ADDED] Admin %s [%s] added server group %d from %s [%s]", invokerName, invokerUniqueIdentity, serverGroupID, clientName, clientUniqueIdentity), "Group")
	end
end