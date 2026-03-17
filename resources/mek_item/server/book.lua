function startBook(id, slot)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not tonumber(id) then
		return
	end

	dbQuery(function(queryHandle, client)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			for index, row in ipairs(res) do
				if row then
					triggerClientEvent(
						client,
						"playerBook",
						client,
						row.title,
						row.author,
						row.book,
						row.readOnly,
						slot,
						id
					)
				else
					triggerClientEvent(client, "playerBook", client, false, false, "Error")
				end
			end
		end
	end, { client }, mysql:getConnection(), "SELECT title, author, book, readOnly FROM books WHERE id = ?", id)
end
addEvent("books:beginBook", true)
addEventHandler("books:beginBook", root, startBook)

function setData(id, title, author, book, readOnly)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not tonumber(id) then
		return
	end

	if readOnly then
		readOnly = 1
	else
		readOnly = 0
	end

	if readOnly == 1 then
		exports.mek_global:sendLocalMeAction(client, "closes " .. title .. " and clicks his pen.")
	end

	dbExec(
		mysql:getConnection(),
		"UPDATE books SET title = ?, author = ?, book = ?, readOnly = ? WHERE id = ?",
		title,
		author,
		book,
		readOnly,
		id
	)
end
addEvent("books.setData", true)
addEventHandler("books.setData", root, setData)
