function checkTurkishCharacters(text)
	local turkishCharacters = { "ı", "İ", "ş", "Ş", "ğ", "Ğ", "ü", "Ü", "ö", "Ö", "ç", "Ç", "ə", "Ə" }
	for _, char in ipairs(turkishCharacters) do
		if text:find(char) then
			return true
		end
	end
	return false
end

function checkCharacterName(name)
	if #name < 3 or #name > 22 then
		return false, "Karakter adı 3 ila 22 karakter arasında olmalıdır."
	end

	if checkTurkishCharacters(name) then
		return false, "Karakter adı türkçe karakterler içeremez."
	end

	if name == name:upper() then
		return false, "Karakter adı tamamen büyük harf olamaz. Sadece baş harfler büyük olmalı."
	end

	local words = {}
	for word in name:gmatch("[^%s]+") do
		table.insert(words, word)
	end

	if #words < 2 then
		return false, "Karakter adı en az iki kelimeden oluşmalıdır."
	end

	for _, word in ipairs(words) do
		if #word < 2 then
			return false, "Her kelime en az 2 karakter olmalıdır."
		end

		local first = word:sub(1, 1)
		if not first:match("%u") then
			return false, "Her kelimenin ilk harfi büyük harf olmalıdır."
		end

		local rest = word:sub(2)
		if rest:find("[^a-z']") then
			return false,
				"Her kelimenin ilk harfi dışındaki karakterler küçük harf veya tek tırnak (') olmalıdır."
		end
	end

	return true
end

function checkAccountUsername(text)
	if #text < 3 then
		return false, "Kullanıcı adı minimum 3 karakter uzunluğunda olmalıdır."
	end

	if #text >= 32 then
		return false, "Kullanıcı adı maksimum 32 karakter uzunluğunda olmalıdır."
	end

	if text:match("%W") then
		return false, "Kullanıcı adı uygunsuz karakterler içermemelidir."
	end

	if checkTurkishCharacters(text) then
		return false, "Kullanıcı adı Türkçe karakterler içeremez."
	end

	return true
end

function checkMail(email)
	if type(email) ~= "string" or not email:find("@") then
		return false
	end

	local atStart, atEnd = email:find("@")

	local username = email:sub(1, atStart - 1)
	local domain = email:sub(atEnd + 1)

	if username == "" then
		return false
	end

	if domain == "" or not domain:find("%.") then
		return false
	end

	if domain:find("%.%.") then
		return false
	end

	return true
end

function convertMusicTime(time)
	local minutes = math.floor(math.modf(time, 3600) / 60)
	local seconds = math.floor(math.fmod(time, 60))
	return string.format("%02d:%02d", minutes, seconds)
end
