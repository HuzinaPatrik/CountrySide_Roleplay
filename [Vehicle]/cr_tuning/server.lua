addEventHandler("onResourceStart", resourceRoot, 
    function()
        for k,v in pairs(markerPositions) do 
            local x,y,z,dim,int,rot = unpack(v)
            local marker = Marker(x,y,z,"cylinder",4,255, 59, 59)
            marker.dimension = dim 
            marker.interior = int 
            marker:setData("tuning.marker", true)
            marker:setData("tuning.marker.vehicle.rotation", rot)
        end 
    end
)

local markerEnterData = {}
local playerEnterData = {}

function enterTuningMarker(player, marker)
    if isElement(player) and isElement(marker) then 
        if not markerEnterData[marker] then 
            markerEnterData[marker] = player
            playerEnterData[player] = marker
            marker:setData("marker.tuning.inPlayer", player)
            player.vehicle.position = Vector3(marker.position.x, marker.position.y, marker.position.z + 3) 
            player.vehicle.rotation = Vector3(0, 0, tonumber(marker:getData("tuning.marker.vehicle.rotation") or 0))
            player.vehicle.velocity = Vector3(0,0,0)
            marker.position = Vector3(marker.position.x, marker.position.y, marker.position.z - 100)
            triggerLatentClientEvent(player, "enterTuningMarker", 50000, false, player, marker)
        end 
    end 
end 
addEvent("enterTuningMarker", true)
addEventHandler("enterTuningMarker", root, enterTuningMarker)

addEventHandler("onPlayerQuit", root, 
    function()
        exitTuningMarker(source)
    end 
)

function exitTuningMarker(player)
    if playerEnterData[player] then 
        local marker = playerEnterData[player]
        markerEnterData[marker] = nil 
        playerEnterData[player] = nil 
        marker:setData("marker.tuning.inPlayer", nil)
        collectgarbage("collect")
        marker.position = Vector3(marker.position.x, marker.position.y, marker.position.z + 100)
    end 
end 
addEvent("exitTuningMarker", true)
addEventHandler("exitTuningMarker", root, exitTuningMarker)

function addOpticalTuning(e, id, slot)
    if e then 
        if slot == 0 then 
            local oldVal = tonumber((e:getData("veh >> tuningData") or {})["optical." .. id] or 0)
            local upgrades = e:getCompatibleUpgrades(id)
            if upgrades[oldVal] then 
                removeVehicleUpgrade(e, upgrades[oldVal])
            end 
        else 
            local upgrades = e:getCompatibleUpgrades(id)
            if upgrades[slot] then 
                addVehicleUpgrade(e, upgrades[slot])
            end 
        end

        local tuningData = e:getData("veh >> tuningData") or {}
        tuningData["optical." .. id] = slot
        e:setData("veh >> tuningData", tuningData)
    end
end 
addEvent("addOpticalTuning", true)
addEventHandler("addOpticalTuning", root, addOpticalTuning)

function updateVehicleColor(veh, type, newVal)
    if veh then 
        local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(veh, true)
        if type == "color1" then 
            setVehicleColor(veh, newVal[1], newVal[2], newVal[3], r2, g2, b2, r3, g3, b3, r4, g4, b4)
        elseif type == "color2" then 
            setVehicleColor(veh, r1, g1, b1, newVal[1], newVal[2], newVal[3], r3, g3, b3, r4, g4, b4)
        elseif type == "color3" then 
            setVehicleColor(veh, r1, g1, b1, r2, g2, b2, newVal[1], newVal[2], newVal[3], r4, g4, b4)
        elseif type == "color4" then 
            setVehicleColor(veh, r1, g1, b1, r2, g2, b2, r3, g3, b3, newVal[1], newVal[2], newVal[3])
        elseif type == "headlight" then 
            setVehicleHeadLightColor(veh, unpack(newVal))
        elseif type == "km" then 
            setElementData(veh, "veh >> KM/H Color", newVal)
        end 
    end 
end 
addEvent("updateVehicleColor", true)
addEventHandler("updateVehicleColor", root, updateVehicleColor)

function setVehicleHandlingFlags(vehicle, byte, value)
    --3 = front, 4 = rear, 6 = offroad
    if byte == 3 or byte == 4 or byte == 6 then 
        if value == "verynarrow" then 
            value = 1
        elseif value == "narrow" then 
            value = 2
        elseif value == "wide" then 
            value = 4
        elseif value == "verywide" then 
            value = 8
        elseif value == "default" then 
            value = 0
        end

        if value == "dirt" then
			value = 1
		elseif value == "sand" then
			value = 2
		elseif value == "default" then
			value = 0
		end

        if vehicle then 
            local handlingFlags = string.format("%X", getVehicleHandling(vehicle)["handlingFlags"])
            local reversedFlags = string.reverse(handlingFlags) .. string.rep("0", 8 - string.len(handlingFlags))
            local currentByte, flags = 1, ""
            
            for values in string.gmatch(reversedFlags, ".") do
                if type(byte) == "table" then
                    for _, v in ipairs(byte) do
                        if currentByte == v then
                            values = string.format("%X", tonumber(value))
                        end
                    end
                else
                    if currentByte == byte then
                        values = string.format("%X", tonumber(value))
                    end
                end
                
                flags = flags .. values
                currentByte = currentByte + 1
            end
            
            setVehicleHandling(vehicle, "handlingFlags", tonumber("0x" .. string.reverse(flags)))
            return tonumber("0x" .. string.reverse(flags))
        end
	end
end
addEvent("setVehicleHandlingFlags", true)
addEventHandler("setVehicleHandlingFlags", root, setVehicleHandlingFlags)

_setVehicleHandling = setVehicleHandling
function setVehicleHandling(vehicle, property, val)
    if vehicle and property and val then 
        _setVehicleHandling(vehicle, property, val)
    end
end
addEvent("setVehicleHandling", true)
addEventHandler("setVehicleHandling", root, setVehicleHandling)

function addVariantTuning(vehicle, val)
    if vehicle and val then 
        vehicle:setVariant(val, val)
    end
end
addEvent("addVariantTuning", true)
addEventHandler("addVariantTuning", root, addVariantTuning)

function syncHorn(players, e, state)
    triggerLatentClientEvent(players, "playHornSound", 50000, false, e, e, state)
end 
addEvent("syncHorn", true)
addEventHandler("syncHorn", root, syncHorn)