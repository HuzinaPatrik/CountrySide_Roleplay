function saveVehicle(vehicle, ignore)
    local id = vehicle:getData("veh >> id")
    if id and id >= 1 and cache[id] then
		local d = {
			["veh >> loaded"] = vehicle:getData("veh >> loaded"),
			["veh >> id"] = vehicle:getData("veh >> id"),
			["veh >> owner"] = vehicle:getData("veh >> owner"),
			["veh >> fuel"] = vehicle:getData("veh >> fuel"),
			["veh >> oldfueltype"] = vehicle:getData("veh >> oldfueltype"),
			["veh >> fueltype"] = vehicle:getData("veh >> fueltype"),
			["veh >> chassis"] = vehicle:getData("veh >> chassis"),
			["veh >> engineBroken"] = vehicle:getData("veh >> engineBroken"),
			["veh >> engine"] = vehicle:getData("veh >> engine"),
			["veh >> handbrake"] = vehicle:getData("veh >> handbrake"),
			["veh >> damageProof"] = vehicle:getData("veh >> damageProof"),
			["veh >> odometer"] = vehicle:getData("veh >> odometer"),
			["veh >> lastOilRecoil"] = vehicle:getData("veh >> lastOilRecoil"),
			["veh >> locked"] = vehicle:getData("veh >> locked"),
			["veh >> KM/H Color"] = vehicle:getData("veh >> KM/H Color"),
			["veh >> park"] = vehicle:getData("veh >> park"),
			["veh >> protect"] = vehicle:getData("veh >> protect"),
			["veh >> faction"] = vehicle:getData("veh >> faction"),
			["veh >> light"] = vehicle:getData("veh >> light"),
            ["veh >> plateText"] = vehicle:getData("veh >> plateText"),
            ["veh >> tuningData"] = vehicle:getData("veh >> tuningData") or {},
            ['veh >> taxiPlate'] = vehicle:getData('veh >> taxiPlate'),
		}
		
		local a1 = {getVehicleColor(vehicle, true)};
        local colors = toJSON(a1);
        local a1 = {};
        for i = 1, 4 do
            local num = i + 1;
            a1[i] = tostring(vehicle:getData("veh >> window"..num.."State"));
        end
        local windows = toJSON(a1);
        local a1 = {};
        for i = 0, 6 do
            local num = i + 1;
            a1[num] = getVehiclePanelState(vehicle, i);
        end
        local panels = toJSON(a1);
        local a1 = {getVehicleWheelStates(vehicle)};
        local wheels = toJSON(a1);
        local a1 = {};
        for i = 0, 3 do
            local num = i + 1
            a1[num] = getVehicleLightState(vehicle, i);
        end
        local lights = toJSON(a1);
        local a1 = {};
        for i = 0, 5 do
            local num = i + 1;
            a1[num] = getVehicleDoorState(vehicle, i);
        end
        local doors = toJSON(a1);
		local vehPos = toJSON({vehicle.position.x, vehicle.position.y, vehicle.position.z, vehicle.rotation.x, vehicle.rotation.y, vehicle.rotation.z, vehicle.interior, vehicle.dimension})
		local model = vehicle:getData('veh >> virtuaModellID') or vehicle.model
		local owner = d["veh >> owner"]
		local fuel = d["veh >> fuel"]
		local engine = tostring(d["veh >> engine"])
		local engineBroken = tostring(d["veh >> engineBroken"])
		local light = tostring(d["veh >> light"])
		local plate = tostring(d["veh >> plateText"])
		local odometer = tonumber(d["veh >> odometer"])
		local locked = tostring(d["veh >> locked"])
		local health = tonumber(vehicle.health)
		local handbrake = tostring(d["veh >> handbrake"])
		local damageProof = tostring(d["veh >> damageProof"])
        local lastOilRecoil = tonumber(d["veh >> lastOilRecoil"])
        local tuningData = toJSON(d["veh >> tuningData"])
		local variants = toJSON({vehicle:getVariant()})
		local r,g,b = getVehicleHeadLightColor(vehicle);
        local headlight = toJSON({r,g,b});
        local kmColor = toJSON(vehicle:getData("veh >> KM/H Color") or {255,255,255});
        local parkPos = toJSON(vehicle:getData("veh >> park") or {x,y,z,rx,ry,rz,int,dim});
        local protect = tostring(vehicle:getData("veh >> protect"));
        local faction = vehicle:getData("veh >> faction");
		local fueltype = tostring(vehicle:getData("veh >> fueltype"));
		local chassis = tostring(vehicle:getData("veh >> chassis"));
        local taxiPlate = tostring(d["veh >> taxiPlate"]);
        
		dbExec(connection, "UPDATE vehicle SET modelid=?, pos=?, owner=?, fuel=?, engine=?, engineBroken=?, light=?, plate=?, odometer=?, locked=?, health=?, colors=?, windows=?, panels=?, wheels=?, lights=?, doors=?, handbrake=?, damageProof=?, lastOilRecoil=?, variant=?, headlight=?, kmColor=?, parkPos=?, protect=?, faction=?, fueltype=?, chassis=?, tuningData=?, taxiPlate=? WHERE id=?", model, vehPos, owner, fuel, engine, engineBroken, light, plate, odometer, locked, health, colors, windows, panels, wheels, lights, doors, handbrake, damageProof, lastOilRecoil, variants, headlight, kmColor, parkPos, protect, faction, fueltype, chassis, tuningData, taxiPlate, id)
        
        if not ignore then
            outputDebugString("Veh: ID: "..id.." despawned & spawned!")
            triggerEvent("onVehicleDestroy", vehicle, id)
        end
    end
end

addEventHandler("onPlayerQuit", root,
    function()
        local veh = source.vehicle 
        if veh then 
            if source.vehicleSeat == 0 then 
                setElementData(veh, "veh >> locked", true)
                setElementData(veh, "veh >> handbrake", true)
                setElementData(veh, "veh >> engine", false)
            end 
        end 

        local vehs = getPlayerVehicles(source)
        for k, vehID in pairs(vehs) do
            if cache[vehID] then
                saveVehicle(cache[vehID])
                
                if not cache[vehID]:getData("veh >> protect") then
                    cache[vehID]:destroy()
                    cache[vehID] = nil
                end
            end
        end
    end
)

function saveAllVehicles()
    local count = 0
    local tick = getTickCount()
    for k,v in pairs(getElementsByType("vehicle")) do
        local id = v:getData("veh >> id")
        if id and id >= 1 and cache[id] then
            local co = coroutine.create(saveVehicle)
            coroutine.resume(co, v, true)
            count = count + 1
            --saveVehicle(v, true)
        end
    end
    outputDebugString("Saved "..count.." vehicles in "..(getTickCount()-tick).."ms!", 0, 255, 50, 255)
end
setTimer(saveAllVehicles, 60 * 60 * 1000, 0) -- 1 óránként menti az összes kocsit

addEventHandler("onResourceStop", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("vehicle")) do
            saveVehicle(v)
        end
    end
)