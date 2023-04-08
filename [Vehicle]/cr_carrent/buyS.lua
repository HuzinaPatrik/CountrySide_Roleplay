veh_rent_timer = {}
create_veh = {}
rent_id = 0
minutes = {}
notify = {}

random_rent_pos = {
	{694.93646240234, -473.21810913086, 16, 0, 0, 270},
	{695.052734375, -470.34567260742, 16.3359375, 0, 0, 270},
	{694.96752929688, -466.88757324219, 16.3359375, 0, 0, 270},
	{694.84326171875, -464.13595581055, 16.3359375, 0, 0, 270},
	{694.80511474609, -460.74877929688, 16.3359375, 0, 0, 270},
	{708.77893066406, -458.16665649414, 16.3359375, 0, 0, 90},
	{707.05114746094, -470.77252197266, 16.3359375, 0, 0, 90},
}

function randomPlateNumbers()
	local temp = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	return temp[math.random(1, #temp)]..temp[math.random(1, #temp)]..temp[math.random(1, #temp)]
end

function spawnRentedVehicle(player, vehid, rent_time, bail)
    if player:getData("carrent >> on_rent") then
        exports['cr_infobox']:addBox(player, "error", "Már van egy bérelt járműved!")
        return
    end
	local random_pos = math.random(1,#random_rent_pos)
	local rented_veh_pos = random_rent_pos[random_pos]
	local accountID = getElementData(player, "acc >> id")
	local rot = {rented_veh_pos[4], rented_veh_pos[5], rented_veh_pos[6]}
	
	-- create_veh[rent_id] = exports['cr_vehicle']:createTemporaryVehicle(tonumber(vehid), player, rented_veh_pos[1], rented_veh_pos[2], rented_veh_pos[3], 0, 0, rot, false, false, false, 1000)
	-- local plate = "RENT-"..randomString()
	--create_veh[rent_id] = exports['cr_vehicle']:createTemporaryVehicle(player, tonumber(vehid), rented_veh_pos[1], rented_veh_pos[2], rented_veh_pos[3], rot[1], rot[2], rot[3], 255, 255, true)
	local veh, _, rent_id = exports['cr_vehicle']:makeTemporaryVehicle(player, tonumber(vehid), rented_veh_pos[1], rented_veh_pos[2], rented_veh_pos[3], 0, 0, rot[1], rot[2], rot[3], {math.random(0, 255),math.random(0, 255),math.random(0, 255)}, {255, 255}, true, nil, 2)
	create_veh[rent_id] = veh
    
	if isElement(player) then 
		setElementData(player,"carrent >> on_rent", true)
		setElementData(player,"carrent >> rent_id", rent_id)
	end

	-- start Timer
	veh_rent_timer[rent_id] = setTimer(function(player, r_id, bail)
		notify[create_veh[rent_id]] = true

		if isElement(player) then 
			exports['cr_infobox']:addBox(player, "warning", "Figyelem. 5 perc múlva lejár a bérelt jármű bérleti ideje!")
		end 
	
		setTimer(function(player, r_id, bail)
			if isTimer(veh_rent_timer[r_id]) then 
				killTimer(veh_rent_timer[r_id])
			end 
			
			if create_veh[r_id] then
				setElementData(create_veh[r_id], "veh >> engine", false)
				notify[create_veh[rent_id]] = false
			end

			if isElement(player) then 
				exports['cr_infobox']:addBox(player, "warning", "A bérleti időd lejárt a járműre. A jármű 1 percen belül törlésre kerül.")
			end
			
			setTimer(function(player, r_id, bail)
				if create_veh[r_id] then
					if isElement(player) then 
						if getElementHealth(create_veh[r_id]) >= 1000/100*80 then
							exports['cr_infobox']:addBox(player, "error", "A bérelt járműved törlésre került! Mivel sérülés nélkül adtad vissza, így a kaució visszajár.")
							exports['cr_core']:giveMoney(player, bail)
						else
							exports['cr_infobox']:addBox(player, "error", "A bérelt járműved törlésre került! Sajnos a jármű sérült, így a kauciót elbuktad.")
						end
						
						setElementData(player,"carrent >> on_rent", false)
						setElementData(player,"carrent >> rent_id", nil)
					end 

					exports['cr_vehicle']:destroyTemporaryVehicle(create_veh[r_id])
				end				
			end, 1000*60*1, 1, player, rent_id, bail)
		end, 1000*60*5, 1, player, rent_id, bail)
	end, rent_time * 1000 * 60, 1, player, rent_id, bail)
end
addEvent("carrent >> giveRentCar", true)
addEventHandler("carrent >> giveRentCar", resourceRoot, spawnRentedVehicle)

addEventHandler ("onResourceStop", resourceRoot, 
    function (resource)
		for k, v in ipairs(getElementsByType("player")) do
			if getElementData(v,"carrent >> on_rent") then
				setElementData(v,"carrent >> on_rent", false)
				local id = getElementData(v, "carrent >> rent_id")
				setElementData(v,"carrent >> rent_id", nil)
				exports['cr_vehicle']:destroyTemporaryVehicle(create_veh[id])
				create_veh[id] = nil 
				if isTimer(veh_rent_timer[id]) then 
					killTimer(veh_rent_timer[id])
				end 
				veh_rent_timer[id] = nil 
				collectgarbage("collect")
			end
		end
   end 
)

addEventHandler("onPlayerQuit", root, 
	function()
		if getElementData(source,"carrent >> on_rent") then
			setElementData(source,"carrent >> on_rent", false)
			local id = getElementData(source, "carrent >> rent_id")
			setElementData(source,"carrent >> rent_id", nil)
			exports['cr_vehicle']:destroyTemporaryVehicle(create_veh[id])
			create_veh[id] = nil 
			if isTimer(veh_rent_timer[id]) then 
				killTimer(veh_rent_timer[id])
			end 
			veh_rent_timer[id] = nil 
			collectgarbage("collect")
		end
	end 
)

addCommandHandler('lemond', 
	function(thePlayer, cmd)
		if getElementData(thePlayer,"carrent >> on_rent") then
			setElementData(thePlayer,"carrent >> on_rent", false)
			local id = getElementData(thePlayer, "carrent >> rent_id")
			setElementData(thePlayer,"carrent >> rent_id", nil)
			exports['cr_vehicle']:destroyTemporaryVehicle(create_veh[id])
			create_veh[id] = nil 
			if isTimer(veh_rent_timer[id]) then 
				killTimer(veh_rent_timer[id])
			end 
			veh_rent_timer[id] = nil 
			collectgarbage("collect")

			exports['cr_infobox']:addBox(thePlayer, 'success', 'Sikeresen lemondtad a bérlésed!')
		end
	end 
)