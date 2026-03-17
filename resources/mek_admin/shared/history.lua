local actions = {
	[0] = "Jail",
	[1] = "Kick",
	[2] = "Ban",
	[3] = "ROL+",
	[4] = "ROL-",
}

function getHistoryAction(input)
	if tonumber(input) then
		if actions[tonumber(input)] then
			return actions[tonumber(input)]
		else
			return "Diğer"
		end
	end
	return "Diğer"
end

function getHistoryRecordFromID(records, id)
	for _, record in pairs(records) do
		if tonumber(record[7]) == tonumber(id) then
			return record
		end
	end
end
