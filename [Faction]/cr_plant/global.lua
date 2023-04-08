white = "#ffffff"

potObjectId = 2203
canObjectId = 3385
witheredPlantItemId = 187

minMoisture = 45
minMoistureLevel = 35
minStatus = 45

plantTypes = {
    [3277] = {name = "Kokain", itemId = 185},
    [3267] = {name = "Mák", itemId = 186},
    [3259] = {name = "Marihuana", itemId = 184}
}

function findRotation(x1, y1, x2, y2) 
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
    return t < 0 and t + 360 or t
end

function getPositionFromElementOffset(element, offX, offY, offZ)
	if element and isElement(element) then
		local m = getElementMatrix(element)

		local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
		local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
		local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]

		return x, y, z
	end
end