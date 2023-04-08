local lightCache = {}

addEventHandler("onClientObjectBreak", root,
	function()
		if lightObjects[getElementModel(source)] then
			cancelEvent()
		end
	end
)

function trafficlight_sendTicket(element)
	local syntax = exports['cr_core']:getServerSyntax("Jelzőlámpa", "error")
	local green = exports['cr_core']:getServerColor(nil, true)
	local white = "#ffffff"
	outputChatBox(syntax .. "Tilos jelzésen való áthaladás miatt "..green .. "500 $ "..white.." bírságot kaptál.",255,255,255,true)
	exports['cr_core']:takeMoney(element, 500, nil, true)
end

addEventHandler("onClientColShapeHit", root,
	function(vehicleElement)
		if not isElement(source) then 
			return
		 end

		if getElementData(source, "trafficlight >> real") then
			if getElementType(vehicleElement) == "vehicle" then
				local playerElement = getVehicleController(vehicleElement)
				if playerElement and playerElement == localPlayer then
					if not getPedControlState("brake_reverse") then
                        local _, _, a = getElementRotation(lightCache[source])
                        local objRot1 = getRoundedRotation(a)
						if playerElement and getElementType(playerElement) == "player" then
							local vehicleType = getVehicleType(vehicleElement)
							if vehicleType == "Automobile" or vehicleType == "Bike" or vehicleType == "Monster Truck" or vehicleType == "Quad" then
								local _, _, vehRot = getElementRotation(vehicleElement)
								local vehRot1 = getRoundedRotation(vehRot)
								if objRot1 == vehRot1 then
									local lightState = getTrafficLightState()
									if objRot1 == 90 or objRot1 == 270 then
										if lightState == 0 or lightState == 1 or lightState == 2 then
											trafficlight_sendTicket(playerElement)
										end
									elseif objRot1 == 0 or objRot1 == 180 then
										if lightState == 4 or lightState == 3 or lightState == 2 then
											trafficlight_sendTicket(playerElement)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in pairs(getElementsByType("object")) do
			local model = getElementModel(value)
			if lightObjects[model] then
				local lightX, lightY, lightZ = getElementPosition(value)
				local radius, height, offsetX, offsetY, offsetZ = unpack(lightObjects[model])
				local colshape = createColTube(lightX, lightY, lightZ, radius, height)
                value.collisions = true
				attachElements(colshape, value, offsetX, offsetY, offsetZ)
				setElementData(colshape, "trafficlight >> real", true)
				lightCache[colshape] = value
			end
		end
	end
)