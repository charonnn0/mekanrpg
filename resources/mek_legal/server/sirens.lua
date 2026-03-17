local noSirenLightVehicles = {
	[400] = true,
	[401] = true,
	[402] = true,
	[403] = true,
	[404] = true,
	[405] = true,
	[406] = true,
	[417] = true,
	[420] = true,
	[423] = true,
	[425] = true,
	[430] = true,
	[432] = true,
	[433] = true,
	[435] = true,
	[438] = true,
	[441] = true,
	[446] = true,
	[447] = true,
	[448] = true,
	[452] = true,
	[453] = true,
	[454] = true,
	[460] = true,
	[461] = true,
	[462] = true,
	[463] = true,
	[464] = true,
	[465] = true,
	[468] = true,
	[469] = true,
	[472] = true,
	[473] = true,
	[476] = true,
	[481] = true,
	[484] = true,
	[487] = true,
	[488] = true,
	[493] = true,
	[497] = true,
	[501] = true,
	[509] = true,
	[510] = true,
	[511] = true,
	[512] = true,
	[513] = true,
	[519] = true,
	[520] = true,
	[521] = true,
	[522] = true,
	[523] = true,
	[528] = true,
	[537] = true,
	[538] = true,
	[539] = true,
	[544] = true,
	[548] = true,
	[553] = true,
	[563] = true,
	[564] = true,
	[569] = true,
	[570] = true,
	[577] = true,
	[581] = true,
	[586] = true,
	[590] = true,
	[592] = true,
	[593] = true,
	[595] = true,
	[600] = true,
	[601] = true,
	[602] = true,
	[603] = true,
	[604] = true,
	[605] = true,
	[606] = true,
	[607] = true,
	[608] = true,
	[610] = true,
	[611] = true,
}

addEvent("legal.setSirenState", true)
addEventHandler("legal.setSirenState", root, function(vehicle, sirenID)
	if not isElement(vehicle) or getPedOccupiedVehicle(source) ~= vehicle then
		return
	end

	if not exports.mek_item:hasItem(vehicle, 85) then
		return
	end

	local current = getElementData(vehicle, "legal_siren") or false
	if current == sirenID then
		setElementData(vehicle, "legal_siren", false)
		setVehicleSirensOn(vehicle, false)
	else
		setElementData(vehicle, "legal_siren", sirenID)
		if sirenID ~= 4 then
			setVehicleSirensOn(vehicle, true)
		end
	end
end)

addEventHandler("onElementDestroy", root, function()
	if getElementType(source) == "vehicle" then
		setElementData(source, "legal_siren", false)
		setVehicleSirensOn(source, false)
	end
end)

addEventHandler("onVehicleRespawn", root, function()
	setElementData(source, "legal_siren", false)
	setVehicleSirensOn(source, false)
end)

addEventHandler("onVehicleExit", root, function(player, seat)
	if seat == 0 then
		setElementData(source, "legal_siren", false)
		setVehicleSirensOn(source, false)
	end
end)

addEventHandler("onVehicleEnter", root, function(thePlayer, seat)
	if thePlayer and seat == 0 then
		if exports.mek_item:hasItem(source, 85, 1) then
			local vehicleModel = getElementModel(source)
			if not noSirenLightVehicles[vehicleModel] then
				if vehicleModel == 416 then
					addVehicleSirens(source, 7, 2, false, true, true, true)
					setVehicleSirens(source, 1, 0.5, 0.9, 1.3, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 2, 0, 0.9, 1.3, 255, 255, 255, 255, 255)
					setVehicleSirens(source, 3, -0.5, 0.9, 1.3, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 4, 1.3, 0.2, 1.5, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 5, 1.3, -3.3, 1.5, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 6, -1.3, 0.2, 1.5, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 7, -1.3, -3.3, 1.5, 255, 0, 0, 255, 255)
				elseif vehicleModel == 407 then
					addVehicleSirens(source, 7, 2, false, true, true, true)
					setVehicleSirens(source, 1, 0.6, 3.2, 1.4, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 2, 0, 3.2, 1.4, 255, 255, 255, 255, 255)
					setVehicleSirens(source, 3, -0.6, 3.2, 1.4, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 4, 0.4, -3.7, 0.4, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 5, -0.4, -3.7, 0.4, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 6, 0.6, 4.2, 0.1, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 7, -0.6, 4.2, 0.1, 255, 0, 0, 255, 255)
				elseif vehicleModel == 525 then
					addVehicleSirens(source, 3, 4, false, true, true, true)
					setVehicleSirens(source, 1, -0.7, -0.35, 1.5250904560089, 255, 0, 0, 255, 0)
					setVehicleSirens(source, 2, 0, -0.35, 1.5250904560089, 255, 198, 10, 255, 0)
					setVehicleSirens(source, 3, 0.7, -0.35, 1.5250904560089, 255, 0, 0, 255, 0)
				elseif vehicleModel == 578 then
					addVehicleSirens(source, 6, 4, false, true, true, true)
					setVehicleSirens(source, 1, 0.647, 5.773, -0.179, 255, 128, 0, 255, 255)
					setVehicleSirens(source, 2, -0.532, 5.737, -0.188, 255, 128, 0, 255, 255)
					setVehicleSirens(source, 3, -1.402, -5.193, -0.269, 255, 128, 0, 255, 255)
					setVehicleSirens(source, 4, 1.322, -5.054, -0.269, 255, 128, 0, 255, 255)
					setVehicleSirens(source, 5, 1.150, 5.805, -0.889, 255, 128, 0, 255, 255)
					setVehicleSirens(source, 6, -1.182, 5.801, -0.883, 255, 128, 0, 255, 255)
				else
					addVehicleSirens(source, 8, 2, false, true, true, true)
					setVehicleSirens(source, 1, 0.5, -0.3, 1, 0, 0, 255, 255, 255)
					setVehicleSirens(source, 2, 0, -0.3, 1, 255, 255, 255, 255, 255)
					setVehicleSirens(source, 3, -0.5, -0.3, 1, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 4, -0.3, -1.9, 0.4, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 5, 0.3, -1.9, 0.4, 0, 0, 255, 255, 255)
					setVehicleSirens(source, 6, 0.0, -2.95, -0.1, 255, 215, 0, 100, 100)
					setVehicleSirens(source, 7, -0.3, 2.7, 0.0, 255, 0, 0, 255, 255)
					setVehicleSirens(source, 8, 0.3, 2.7, 0.0, 0, 0, 255, 255, 255)
				end
				return
			end
		end
		removeVehicleSirens(source)
	end
end)
