local lightCache = {}

addEventHandler("onClientObjectBreak", root,
	function()
		if lightObjects[getElementModel(source)] then
			cancelEvent()
		end
	end
)

addEventHandler("onClientColShapeLeave", root,
	function(element)
        if not isElement(source) then return end
        --outputChatBox("asd4")
		if getElementData(source, "trafficlight >> real") then
            --outputChatBox("asd3")
			if getElementType(element) == "vehicle" then
                --outputChatBox("asd2")
				local playerElement = getVehicleController(element)
				if playerElement and playerElement == localPlayer then
                    --outputChatBox("asd2.1")
					if not getControlState("brake_reverse") then
                        --outputChatBox("asd2.2")
                        local _, _, a = getElementRotation(lightCache[source])
                        local rot = getRoundedRotation(a)
						triggerServerEvent("tralightCheck", localPlayer, localPlayer, element, rot)
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
            --outputChatBox("asd")
			if lightObjects[model] then
                --outputChatBox("asd")
				local lightX, lightY, lightZ = getElementPosition(value)
				local radius, height, offsetX, offsetY, offsetY = unpack(lightObjects[model])
				local colshape = createColTube(lightX, lightY, lightZ, radius, height)
                value.collisions = true
				attachElements(colshape, value, offsetX, offsetY, offsetY)
				setElementData(colshape, "trafficlight >> real", true)
				lightCache[colshape] = value
			end
		end
	end
)