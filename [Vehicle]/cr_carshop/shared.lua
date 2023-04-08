carList = {
	--[[
	{
		brandName = "Típus név",
		brandImage = "logoPng neve.png",
		vehicles = {
			{model = 480, price = 12345, pp = 251, limit = 10},
			{model = 480, price = 12345, pp = 251, limit = 10},
		}
	}
	]]
	{
		brandName = "Bike",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 509, price = 2000, pp = 200, limit = 0},
			{model = 481, price = 2500, pp = 250, limit = 0},
			{model = 510, price = 3000, pp = 300, limit = 0},
		},
	},
	{
		brandName = "BF-400",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 581, price = 25000, pp = 2500, limit = 0},
		},
	},
	{
		brandName = "Buick",
		brandImage = "buick.png",
		vehicles = {
			{model = 507, price = 15000, pp = 1500, limit = 0},
		},
	},
	{
		brandName = "Cadillac",
		brandImage = "cadillac.png",
		vehicles = {
			{model = 458, price = 90000, pp = 9000, limit = 100},
		},
	},
	{
		brandName = "Chevrolet",
		brandImage = "chevrolet.png",
		vehicles = {
			{model = 529, price = 35000, pp = 3500, limit = 0},
			{model = 402, price = 180000, pp = 7000, limit = 5},
			{model = 429, price = 250000, pp = 11000, limit = 3},
		},
	},
	{
		brandName = "Chrysler",
		brandImage = "chrysler.png",
		vehicles = {
			{model = 585, price = 85000, pp = 8500, limit = 150},
		},
	},
	{
		brandName = "Declasse",
		brandImage = "declasse.png",
		vehicles = {
			{model = 536, price = 50000, pp = 5000, limit = 200},
		},
	},
	{
		brandName = "Dodge",
		brandImage = "dodge.png",
		vehicles = {
			{model = 418, price = 30000, pp = 3000, limit = 0},
		},
	},
	{
		brandName = "Ford",
		brandImage = "ford.png",
		vehicles = {
			{model = 551, price = 75000, pp = 7500, limit = 300},
			{model = 479, price = 80000, pp = 8000, limit = 250},
			{model = 404, price = 90000, pp = 6500, limit = 25},
			{model = 475, price = 215000, pp = 9000, limit = 4},
			{model = 491, price = 50000, pp = 3500, limit = 50},
			{model = 502, price = 150000, pp = 7000, limit = 15},
			{model = 505, price = 170000, pp = 7000, limit = 5},
		},
	},
	{
		brandName = "Freeway",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 463, price = 35000, pp = 35000, limit = 0},
		},
	},
	{
		brandName = "Jeep",
		brandImage = "jeep.png",
		vehicles = {
			{model = 579, price = 85000, pp = 8500, limit = 150},
			{model = 500, price = 110000, pp = 7000, limit = 25},
		},
	},
	{
		brandName = "Journey",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 508, price = 30000, pp = 3000, limit = 50},
		},
	},
	{
		brandName = "Mercedes",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 506, price = 220000, pp = 10000, limit = 4},
			{model = 602, price = 205000, pp = 8500, limit = 5},
		},
	},
	{
		brandName = "PCJ-600",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 461, price = 55000, pp = 5500, limit = 200},
		},
	},
	{
		brandName = "Plymouth",
		brandImage = "plymouth.png",
		vehicles = {
			{model = 401, price = 85000, pp = 8500, limit = 150},
		},
	},
	{
		brandName = "Pontiac",
		brandImage = "pontiac.png",
		vehicles = {
			{model = 518, price = 30000, pp = 3000, limit = 0},
		},
	},
	{
		brandName = "Toyota",
		brandImage = "toyotalogo.png",
		vehicles = {
			{model = 547, price = 20000, pp = 2000, limit = 0},
			{model = 559, price = 120000, pp = 12000, limit = 10},
			{model = 516, price = 95000, pp = 6750, limit = 20},
		},
	},
	{
		brandName = "Wayfarer",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 586, price = 40000, pp = 4000, limit = 0},
		},
	},
	{
		brandName = "Egyéb",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 422, price = 70000, pp = 7000, limit = 30},
			{model = 543, price = 20000, pp = 20000, limit = 0},
			{model = 478, price = 70000, pp = 70000, limit = 30},
			{model = 554, price = 40000, pp = 4000, limit = 0},
			{model = 471, price = 50000, pp = 5000, limit = 50},
			{model = 531, price = 500000, pp = 10000, limit = 10},
			{model = 525, price = 999999999, pp = 20000, limit = 1},
		},
	},
	
};

vehiclesBrands = {}
for k,v in pairs(carList) do 
	for k2,v2 in pairs(v.vehicles) do 
		vehiclesBrands[v2.model] = v.brandName
	end 
end 

function getVehicleBrand(vehicle)
	local modelID
	if isElement(vehicle) then 
		modelID = vehicle.model 
	elseif tonumber(vehicle) then 
		modelID = tonumber(vehicle)
	end 

	if modelID then 
		if vehiclesBrands[modelID] then 
			return vehiclesBrands[modelID]
		end 
	end 

	return 'GTA'
end 

vehicleComponents = {
	["door_lf_dummy"] = 2,
	["door_rf_dummy"] = 3,
	["door_lr_dummy"] = 4,
	["door_rr_dummy"] = 5,
	["bonnet_dummy"] = 0,
    ["boot_dummy"] = 1,
}

vehiclePrices = {}
for k,v in pairs(carList) do 
	for k2,v2 in pairs(v.vehicles) do 
		vehiclePrices[v2.model] = {v2.price, v2.pp}
	end 
end 

function getVehiclePrice(vehicle, type)
	if not tonumber(type) then 
		type = 1
	end 

	local modelID
	if isElement(vehicle) then 
		modelID = vehicle.model 
	elseif tonumber(vehicle) then 
		modelID = tonumber(vehicle)
	end 

	if modelID then 
		if vehiclePrices[modelID] then 
			return vehiclePrices[modelID][type]
		end 
	end 

	return 0
end 

maxPerformance = {
	["maximumVelocity"] = 400,
	["maximumAcceleration"] = 40,
	["maximumBrakes"] = 20,
	["maximumTraction"] = 1,
};

function getHandlingProperty(e, property)
    if(isElement(e) and getElementType(e) == "vehicle" and type(property) == "string")then
        local handlingTable = getVehicleHandling(e)
        local value = handlingTable[property]
        if(value) then
            return value
        end
    end
    return false
end