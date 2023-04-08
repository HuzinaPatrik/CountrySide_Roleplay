white = "#ffffff"

objectDatas = {
    ["models"] = {976, 971, 2933, 975, 969, 980, 2909, 968, 2959, 1493, 1495, 3029, 1569, 1493, 1495, 3029, 1569, 5856, 1491, 16775},
}

moveTime = 2000

function getClosestGate(dist)
	local a, gate = 9999, false
    
	for key, value in pairs(getElementsByType("object", _, true)) do
        if value:getData("object >> data") and value:getData("object >> data")["startPosition"] then
            local dist = getDistanceBetweenPoints3D(value.position, localPlayer.position)
            if dist <= a then
                gate = value
                a = dist
            end
        end
	end
    
	if a <= dist then
		return gate
	end
    
	return false
end

function calculateDifferenceBetweenAngles(firstAngle, secondAngle) 
    local difference = secondAngle - firstAngle

    while (difference < -180) do 
        difference = difference + 360 
    end 

    while (difference > 180) do 
        difference = difference - 360 
    end 

    return difference 
end 