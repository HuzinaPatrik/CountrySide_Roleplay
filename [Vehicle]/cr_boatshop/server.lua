local conn = exports["cr_mysql"]:getConnection();

addEvent("boatshop>>testDrive", true)
addEventHandler("boatshop>>testDrive", root, function(e, data) 
	local pos, rot = {getElementPosition(e)}, {getElementRotation(e)}
	e:setData("boatshop >> testDrive", {true, pos, rot})
	e:setData('specialDimension', e.dimension)

	e.dimension = tonumber(e:getData("acc >> id"))
	exports["cr_vehicle"]:makeTemporaryVehicle(e, data.model, 2094.9223632812, -13.463489532471, 1.4, e.dimension, e.interior, 0, 0, 15, {0, 0, 0}, {0, 0, 0}, true)
end)

function exitTestDrive(e, s, j, d) 
	if e:getData("boatshop >> testDrive") and e:getData("boatshop >> testDrive")[1] then
		if e.vehicle and tonumber(e.vehicle:getData("veh >> id") or 0) < 0 then 
			if not e:getData("char >> belt") then 
				local pos = e:getData("boatshop >> testDrive")[2]
				local rot = e:getData("boatshop >> testDrive")[3]
				e:setData("boatshop >> testDrive", {false, {}, {}})
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
						triggerLatentClientEvent(e, "toggleBoatshop", 50000, false, e)
					end, 100, 1, e
				)

				cancelEvent()
			end 
		end
	end	
end
addEventHandler("onVehicleStartExit", root, exitTestDrive)

addEvent('boatshop.exitTestDrive', true)
addEventHandler('boatshop.exitTestDrive', root, exitTestDrive)

addEventHandler('onPlayerQuit', root, 
	function()
		if source:getData("boatshop >> testDrive") and source:getData("boatshop >> testDrive")[1] then
			if source.vehicle and tonumber(source.vehicle:getData("veh >> id") or 0) < 0 then 
				source:setData("boatshop >> testDrive", {false, {}, {}})
				source.dimension = 0
				source.vehicle:destroy()
			end
		end	
	end 
)