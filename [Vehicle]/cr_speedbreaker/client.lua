local vehicleElement = nil 
addEventHandler("onClientColShapeHit", getRootElement(), 
    function(player)
	    if player == localPlayer then 
            if not isElement(getElementData(source, "colshape.element")) then return end
	        if getVehicleSpeed() <= 30 and tonumber(getElementData(source, "colshape.speedbreaker") or 0) > 0 then 
		       setElementCollisionsEnabled(getElementData(source, "colshape.element"), false)	
	        end
        end
    end
)
addEventHandler("onClientColShapeLeave", root, 
    function(player)
	    if player == localPlayer then	
            if not isElement(getElementData(source, "colshape.element")) then return end
            if tonumber(getElementData(source, "colshape.speedbreaker") or 0) > 0 then 
                setElementCollisionsEnabled(getElementData(source, "colshape.element"), true)
            end
        end
    end
)

function getVehicleSpeed()
	local vehicle = getPedOccupiedVehicle(localPlayer)
    if isPedInVehicle(localPlayer) then
        local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(localPlayer))
        return math.sqrt(vx^2 + vy^2 + vz^2) * 161		
	end
    return 0
end