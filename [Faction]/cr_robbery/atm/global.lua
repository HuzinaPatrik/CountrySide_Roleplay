function findNearestElement(model, x, y, z, range, elementType)
    local result = false
    local range = range or 5
    local elementType = elementType or "player"
    local elements = getElementsWithinRange(x, y, z, range, elementType)

    if #elements > 0 then 
        for k, v in pairs(elements) do 
            local objectX, objectY, objectZ = getElementPosition(v)
            local elementModel = getElementModel(v)

            if elementModel == model and getDistanceBetweenPoints3D(x, y, z, objectX, objectY, objectZ) <= range then 
                result = v
                break
            end
        end
    end

    return result
end

function getPositionInFrontOfElement(element, meters)
    if not isElement(element) then
        return
    end

    local meters = type(meters) == "number" and meters or 3

    local posX, posY, posZ = getElementPosition(element)
    local rotation = select(3, getElementRotation(element))

    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))

    return posX, posY, posZ, rot
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

function table.count(tbl)
    local length = 0

    for k in pairs(tbl) do 
        length = length + 1
    end

    return length
end

availableOpeningPositions = {
    {position = {2560.0729980469, -1302.6831054688, 1044.125}, interior = 2, dimension = 44},
    {position = {2552.0986328125, -1302.509765625, 1044.125}, interior = 2, dimension = 44},
    {position = {2544.0493164062, -1302.2962646484, 1044.125}, interior = 2, dimension = 44},
    {position = {2544.0625, -1283.9390869141, 1044.125}, interior = 2, dimension = 44},
    {position = {2552.0375976562, -1284.3103027344, 1044.125}, interior = 2, dimension = 44},
    {position = {2560.0454101562, -1283.8277587891, 1044.125}, interior = 2, dimension = 44}
}

function getAvailableOpeningPositions()
    return availableOpeningPositions
end