carList = {
	{
		brandName = "Általános",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 473, price = 65000, pp = 6500, limit = 0},
			{model = 453, price = 90000, pp = 9000, limit = 100},
		},
	},
	{
		brandName = "Luxus",
		brandImage = "caselogo.png",
		vehicles = {
			{model = 493, price = 150000, pp = 15000, limit = 30},
			{model = 452, price = 175000, pp = 17500, limit = 25},
			{model = 446, price = 200000, pp = 20000, limit = 20},
			{model = 484, price = 250000, pp = 25000, limit = 10},
			{model = 454, price = 300000, pp = 30000, limit = 5},
		},
	},
};

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
	["maximumVelocity"] = 300,
	["maximumAcceleration"] = 40,
	["maximumBrakes"] = 0.1,
	["maximumTraction"] = 30,
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