ModelType = {
	Ped = "ped",
	Vehicle = "vehicle",
	Object = "object",
}

ModelStatus = {
	Loaded = 0,
	Failed = 1,
	Unloaded = 2,
	Downloading = 3,
}

PedGender = {
	Male = 0,
	Female = 1,
	Both = 2,
}

PedRace = {
	White = 1,
	Black = 2,
	Asian = 3,
}

PedStatus = {
	Private = 0,
	Public = 1,
}

models = {
	[ModelType.Ped] = {},
	[ModelType.Vehicle] = {},
	[ModelType.Object] = {},
}
