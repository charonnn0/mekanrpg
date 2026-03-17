local _getPlayerCount = getPlayerCount

function getPlayerCount()
	return _getPlayerCount()
end

function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function sendGacMessage(adminTitle, message)
	exports.mek_chat:sendGacMessage(adminTitle, message)
end

function fetchCDPCount()
	fetchRemote("http://185.34.101.183:22005/mek_api/call/getPlayerCount", function(body, err)
		if err == 0 and body then
			local data = fromJSON(body)
            if data then
                setElementData(root, "total_cdp", data)
			else
				setElementData(root, "total_cdp", 0)
			end
		end
	end)
end

fetchCDPCount()
setTimer(fetchCDPCount, 10000, 0)
