detailLocations = {
	{ icon = 29, text = "Dominos Pizza", position = { 2114.4599609375, -1804.642578125, 22.21875 } },

	{ icon = 52, text = "Merkez Bankası", position = { 1310.212890625, -1390.3388671875, 13.490280151367 } },
	{ icon = 24, text = "Anahtarcı", position = { 2292.220703125, -1722.6875, 13.546875 } },
	{ icon = 26, text = "Elektronik Mağazası", position = { 1845.130859375, -1871.572265625, 13.389747619629 } },

	{ icon = 13, text = "Türkiye Radyo ve Televizyon Kurumu", position = { 649.2841796875, -1360.7314453125, 14.135152816772 } },
	{ icon = 22, text = "İstanbul Devlet Hastanesi", position = { 1189.421875, -1323.0869140625, 13.56667327880 } },
	{ icon = 30, text = "İstanbul Emniyet Müdürlüğü", position = { 1540.08984375, -1675.6943359375, 13.549913406372 } },
	{ icon = 15, text = "İstanbul Büyükşehir Belediyesi", position = { 1480.97265625, -1768.302734375, 18.795755386353 } },

	{ icon = 36, text = "Sürücü Kursu", position = { 1094.5849609375, -1796.4521484375, 13.60395526886 } },
	{ icon = 55, text = "Motor Kiralama", position = { 1675.7080078125, -2310.490234375, 13.542570114136 } },

	{ icon = 69, text = "Araç Parçalatma", position = { 2412.5517578125, -2089.787109375, 13.399438858032 } },

	{ icon = 55, text = "Galeri | Grotti Cars", position = { 561.1796875, -1290.103515625, 17.248237609863 } },
	{ icon = 55, text = "Galeri | Jefferson Auto", position = { 2131.419921875, -1150.005859375, 24.20029258728 } },
	{ icon = 55, text = "Galeri | Bike Shop", position = { 1869.7666015625, -1863.609375, 13.580817222595 } },
	{ icon = 55, text = "Galeri | Sandro Cars", position = { 2113.2236328125, -2135.380859375, 13.6328125 } },
	{ icon = 55, text = "Galeri | Taco Cars", position = { 2113.927734375, -2088.6015625, 13.554370880127 } },
	{ icon = 55, text = "Galeri | Boat Shop", position = { 160.123046875, -1921.3486328125, 3.7734375 } },

	{ icon = 74, text = "Kıyafet Mağazası", position = { 2246.2646484375, -1659.013671875, 15.28614616394 } },
	{ icon = 75, text = "Hediye Ağacı", position = { 1324.6015625, -2328.8310546875, 13.3828125 } },

	{ icon = 18, text = "Ammu Nation (Mermici)", position = { 1424.6162109375, -1292.080078125, 13.97812461853 } },

	{ icon = 72, text = "Balıkçı", position = { 369.9951171875, -2027.5537109375, 7.671875 } },

	{ icon = 35, text = "Kenevir Toplama Bölgesi", position = { 1953.57421875, 206.6494140625, 30.77165222168 } },
	{ icon = 35, text = "Kenevir İşleme Bölgesi", position = { 2161.5830078125, -101.6474609375, 2.75 } },

	{ icon = 34, text = "Teslimat Şöförlüğü", position = { -87.44921875, -1127.2353515625, 1.078125 } },
	{ icon = 71, text = "Taksi Durağı", position = { 1812.6162109375, -1855.04296875, 13.4140625 } },
	{ icon = 67, text = "Otobüs Şöförlüğü", position = { 1811.923828125, -1889.7138671875, 13.4140625 } },

	{ icon = 18, text = "Silah Siparişi", position = { -33.798828125, -1120.7197265625, 4.6812515258789 } },
}

for i = 1, #detailLocations do
	local location = detailLocations[i]
	if location then
		local blip =
			createBlip(location.position[1], location.position[2], location.position[3], 0, 2, 255, 0, 0, 255, 0, 300)
		blip:setData("icon", location.icon)
		blip:setData("text", location.text)
	end
end
