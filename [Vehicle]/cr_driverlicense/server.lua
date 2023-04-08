local npc = {}
local actor = {}
local veh = {}

function loadLicensePeds()
	local palominoCol = createColRectangle(2110.9689941406, -150.68051147461, 480, 400)
	setElementData(palominoCol,"colShape.routin",true)

    for k,v in pairs(licensePed) do
        npc[k] = createPed(v[1], v[2], v[3], v[4], v[5])
        setElementInterior(npc[k],v[6])
        setElementDimension(npc[k],v[7])
        setElementFrozen(npc[k],true)
        setElementData(npc[k],"ped.driveLicense",true)
        setElementData(npc[k],"ped.name",exports["cr_core"]:createRandomMaleName())
        setElementData(npc[k],"ped.type","Oktató (Jogosítvány - ".. licenseType[v[9]][1] .. ")")
        setElementData(npc[k],"ped.drivingShop.name",v[8])
        setElementData(npc[k],"ped.driveLicense.shopType",v[9])
        setElementData(npc[k],"ped.driveStartPos",{v[10],v[11],v[12],v[13],v[14],v[15]})
        setElementData(npc[k],"ped.traficStartPos",{v[18],v[19],v[20],v[21],v[22],v[23]})
        setElementData(npc[k],"ped.driveRoutin",v[16])
        setElementData(npc[k],"ped.driveTraffic",v[17])
		setElementData(npc[k],"char >> noDamage",true)
		
    	for i,v in pairs(licenseShop[licensePed[k][9]]) do
			local minPrice,maxPrice = priceSetting[v][1],priceSetting[v][2]
			local price = math.random(minPrice,maxPrice)
			setElementData(npc[k],"ped.driving.category."..i..".price",price)
		end
    end
end
loadLicensePeds()

function newRandomPrice()
	local pedRand = math.random(1,#licensePed)
	local schoolName = licensePed[pedRand][8] or "Unknow Driving School"
	local syntax = exports['cr_core']:getServerSyntax(schoolName, 'info')

	for k,v in pairs(licenseShop[licensePed[pedRand][9]]) do
		local minPrice,maxPrice = priceSetting[v][1],priceSetting[v][2]
		local price = math.random(minPrice,maxPrice)
		setElementData(npc[pedRand],"ped.driving.category."..v..".price",price)
	end

	outputChatBox(syntax.."Az árak megváltoztak!",root,255,255,255,true)
end
setTimer(newRandomPrice,1 * 60*60*1000,0)


--------------------------------------------------------------------------------------


function createTeacherVehicle(player,car,skin,x,y,z,rz,int,dim, spec)
	if not(veh[player]) and not(actor[player]) then
		veh[player] = exports["cr_vehicle"]:makeTemporaryVehicle(player, car, x, y, z, 0, 0, 0, 0, rz, {255, 255, 255}, {255, 255}, true)

		actor[player] = createPed(skin,0,0,0)
		actor[player]:setData("ped.name", exports["cr_core"]:createRandomMaleName())
		actor[player]:setData("ped.type","Oktató (Vizsgabiztos)")
		actor[player]:setData("char >> noDamage",true)
		actor[player]:setData("ped >> attachedToPlayer", player)

        if spec and spec == "dontDelete" then 
            veh[player]:setData("driverVehDontDelete", true)
        end

		player:setData("driverPed", actor[player])
		player:setData("driverVehicle", veh[player])
        veh[player]:setData("licenseDriverPed", actor[player])

		warpPedIntoVehicle(actor[player],veh[player],1)
		actor[player]:setData("char >> belt",true)
		triggerEvent("ghostMode", player, player.vehicle, "on")
		setElementAlpha(veh[player],255)
		fixVehicle(veh[player])
	end
end
addEvent("createTeacherVehicle",true)
addEventHandler("createTeacherVehicle",root,createTeacherVehicle)

function deleteTeacherVehicle(player,respawn,x,y,z)
	triggerEvent("ghostMode", player, player.vehicle, "off")
	if (veh[player]) then
		exports["cr_vehicle"]:destroyTemporaryVehicle(veh[player]:getData("veh >> id"))
		player:setData("char >> belt",false)
		veh[player] = false
	end
	if (actor[player]) then
		destroyElement(actor[player])
		actor[player] = false
		player:removeData("driverPed")
        player:removeData("driverVehicle")
	end
	if (respawn) then
		setTimer(function()
			setElementPosition(player,x,y,z)
            setElementInterior(player, 3)
            setElementDimension(player, 35)
		end,700,1)
	end
end
addEvent("deleteTeacherVehicle",true)
addEventHandler("deleteTeacherVehicle",root,deleteTeacherVehicle)

function resourceStopServer_License()
	--Oktató kocsik törlése
	for k,v in pairs(veh) do
		if isElement(v) then 
			exports["cr_vehicle"]:destroyTemporaryVehicle(v:getData("veh >> id"))
		end 
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStopServer_License)

function onDestroy()
    if source.type == "vehicle" and source:getData("licenseDriverPed") and not source:getData("driverVehDontDelete") then 
        local driverPed = source:getData("licenseDriverPed")

        if isElement(driverPed) then 
            local playerElement = driverPed:getData("ped >> attachedToPlayer")

            driverPed:destroy()

            if actor[playerElement] then 
                actor[playerElement] = nil
            end

            if veh[playerElement] then 
                veh[playerElement] = nil
            end

            if isElement(playerElement) then 
                triggerClientEvent(playerElement, "driverLicense.resetLicense", playerElement)
            end
        end
    end
end
addEventHandler("onElementDestroy", root, onDestroy)

function onQuit()
    if source:getData("driverVehicle") then 
        local driverVehicle = source:getData("driverVehicle")

        if isElement(driverVehicle) then 
            local vehId = driverVehicle:getData("veh >> id")

            exports.cr_vehicle:destroyTemporaryVehicle(vehId)

            if actor[source] then 
                actor[source]:destroy()
                actor[source] = nil
            end

            if veh[source] then 
                veh[source] = nil
            end
        end
    end
end
addEventHandler("onPlayerQuit", root, onQuit)