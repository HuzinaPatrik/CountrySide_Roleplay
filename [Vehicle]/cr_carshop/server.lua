local conn = exports["cr_mysql"]:getConnection();

addEvent("testDrive", true)
addEventHandler("testDrive", root, function(e, data) 
	local pos, rot = {getElementPosition(e)}, {getElementRotation(e)}
	e:setData("carshop >> testDrive", {true, pos, rot})
	e:setData('specialDimension', e.dimension)

	e.dimension = tonumber(e:getData("acc >> id"))
	exports["cr_vehicle"]:makeTemporaryVehicle(e, data.model, 1363.5072021484, 410.49673461914, 19.40625, e.dimension, e.interior, 0, 0, 335, {0, 0, 0}, {0, 0, 0}, true)
end)

function exitTestDrive(e, s, j, d) 
	if e:getData("carshop >> testDrive") and e:getData("carshop >> testDrive")[1] then
		if e.vehicle and tonumber(e.vehicle:getData("veh >> id") or 0) < 0 then 
			if not e:getData("char >> belt") then 
				local pos = e:getData("carshop >> testDrive")[2]
				local rot = e:getData("carshop >> testDrive")[3]
				e:setData("carshop >> testDrive", {false, {}, {}})
				e.dimension = 0

				if e.vehicle.health >= 750 then 
					exports['cr_infobox']:addBox(e, 'info', 'Kaució visszaadva mert az autó állapota jobb mint 75%!')

					exports['cr_core']:giveMoney(e, 100)
				end 

				e.vehicle:destroy()
				e:setData('specialDimension', nil)

				setTimer(
					function(e) 
						setElementPosition(e, unpack(pos))
						setElementRotation(e, unpack(rot))
						triggerLatentClientEvent(e, "toggleCarshop", 50000, false, e)
					end, 100, 1, e
				)

				cancelEvent()
			end 
		end
	end	
end
addEventHandler("onVehicleStartExit", root, exitTestDrive)

addEvent('exitTestDrive', true)
addEventHandler('exitTestDrive', root, exitTestDrive)

addEventHandler('onPlayerQuit', root, 
	function()
		if source:getData("carshop >> testDrive") and source:getData("carshop >> testDrive")[1] then
			if source.vehicle and tonumber(source.vehicle:getData("veh >> id") or 0) < 0 then 
				source:setData("carshop >> testDrive", {false, {}, {}})
				source.dimension = 0
				source.vehicle:destroy()
			end
		end	
	end 
)