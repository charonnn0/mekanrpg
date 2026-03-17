local _getZoneName = getZoneName

local zoneMap = {
	["Commerce"] = "Kapalıçarşı",
	["Downtown Los Santos"] = "Taksim Meydanı",
	["Market"] = "İstiklal Caddesi",
	["Market Station"] = "Taksim Metro İstasyonu",
	["Pershing Square"] = "Galatasaray Meydanı",
	["Rodeo"] = "Nişantaşı",
	["Vinewood"] = "Levent",
	["Richman"] = "Bebek",
	["Temple"] = "Cihangir",
	["Mulholland"] = "Etiler",
	["Mulholland Intersection"] = "Etiler Kavşağı",
	["Conference Center"] = "Lütfi Kırdar Kongre Merkezi",
	["Marina"] = "Ataköy Marina",
	["Santa Maria Beach"] = "Caddebostan Sahili",
	["Verona Beach"] = "Kuruçeşme Sahili",
	["Playa del Seville"] = "Bakırköy Sahili",
	["Ocean Docks"] = "Ambarlı Limanı",
	["Los Santos International"] = "İstanbul Havalimanı",
	["Glen Park"] = "Maçka Parkı",
	["Verdant Bluffs"] = "Polonezköy Tabiat Parkı",
	["Idlewood"] = "Fatih",
	["Ganton"] = "Gaziosmanpaşa",
	["Willowfield"] = "Küçükçekmece",
	["East Los Santos"] = "Gazi Mahallesi",
	["Las Colinas"] = "Ataşehir",
	["Los Flores"] = "Sultanbeyli",
	["Jefferson"] = "Eyüpsultan",
	["Little Mexico"] = "Zeytinburnu",
	["El Corona"] = "Esenler",
	["Unity Station"] = "Sirkeci Tren Garı",
}

function getZoneName(x, y, z)
	local originalZone = _getZoneName(x, y, z)
	return zoneMap[originalZone] or "İstanbul"
end
