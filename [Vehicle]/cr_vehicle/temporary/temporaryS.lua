local last_temp_id = 1
local temporaryCache = {}

function convertTemporaryType(id)
	return temporaryTitles[id]
end 

function makeTemporaryVehicle(e, model, x, y, z, dim, int, rx, ry, rz, color, variants, warp, groupID, type)
	if not type then 
		type = 1 
	end 

	local chassis = generateChassisNumber()
	local plateText = "TEMP-"..last_temp_id
    
	local veh = createVehicle(model <= 611 and model or 411, x, y, z, rx, ry, rz)

	if model > 611 then 
		veh:setData('veh >> virtuaModellID', model)
	end 

	veh.dimension = dim 
	veh.interior = int
    
	veh:setColor(unpack(color))
	veh:setVariant(unpack(variants))
    
	if(warp) then
		veh:setData("warp", e)
		--e.vehicle = veh
	end

	local handling = getModelHandling(veh.model)
	local fueltype = getHandlingProperty(veh, "engineType")
	
	veh:setData("veh >> fueltype", fueltype)
	veh:setData("veh >> oldfueltype", fueltype)
    
	local dataTable = {
		["veh >> id"] = last_temp_id * -1,
		["veh >> owner"] = tonumber(e:getData("acc >> id")),
		["veh >> fuel"] = 100,
		["veh >> chassis"] = chassis,
		["veh >> engineBroken"] = false,
		["veh >> engine"] = false,
		["veh >> handbrake"] = true,
		["veh >> damageProof"] = false,
		["veh >> odometer"] = 0,
		["veh >> lastOilRecoil"] = 0,
		["veh >> locked"] = false,
		["veh >> KM/H Color"] = 0,
		["veh >> protect"] = false,
		["veh >> faction"] = 0,
		["veh >> light"] = false,
		["veh >> plateText"] = plateText,
		["veh >> group"] = groupID,
		["veh >> KM/H Color"] = {244, 8, 8},
		["veh >> temporaryType"] = type,
		["veh >> createTime"] = exports['cr_core']:getTime(),
	}
    
	veh.plateText = plateText
    
	for i, v in pairs(dataTable) do
		veh:setData(i, v)
	end
    
    temporaryCache[last_temp_id * -1] = veh
    
	veh:setData("needLoad", true) --setTimer(setElementData, 1000, 1, veh, "needLoad", true)
	
	veh.collisions = true
	veh.frozen = false
    
    last_temp_id = last_temp_id + 1
    
	return veh, e, (last_temp_id * -1)
end

function destroyTemporaryVehicle(id)
    if isElement(id) then
        id = id:getData("veh >> id")
    end
	
	if temporaryCache[id] then 
		temporaryCache[id]:destroy()
		temporaryCache[id] = nil
		collectgarbage("collect")
	end 
end