spikeData = {
    [2892] = {length = 10.04, width = 1.23}
}

maxDistance = 30

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

function rotateAround(angle, offsetX, offsetY, baseX, baseY)
	angle = math.rad(angle)

	offsetX = offsetX or 0
	offsetY = offsetY or 0

	baseX = baseX or 0
	baseY = baseY or 0

	return baseX + offsetX * math.cos(angle) - offsetY * math.sin(angle), baseY + offsetX * math.sin(angle) + offsetY * math.cos(angle)
end

function table.count(tbl)
    local length = 0

    for k, v in pairs(tbl) do 
        length = length + 1
    end

    return length
end