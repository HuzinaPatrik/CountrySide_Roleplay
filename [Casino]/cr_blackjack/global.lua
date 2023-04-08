white = "#ffffff"

availableCoins = {
    {value = 1, count = 0},
    {value = 5, count = 0},
    {value = 10, count = 0},
    {value = 50, count = 0},
    {value = 100, count = 0},
    {value = 500, count = 0},
}

function table.copy(tbl)
    local array = {}

    for k, v in pairs(tbl) do 
        if type(v) == "table" then 
            array[k] = table.copy(v)
        else
            array[k] = v
        end
    end

    return array
end

function getPositionInFront(x, y, z, rot, meters)
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = x, y, z

    posX = posX - math.sin(math.rad(rot)) * meters
    posY = posY + math.cos(math.rad(rot)) * meters
    rot = rot + math.cos(math.rad(rot))

    return posX, posY, posZ, rot
end