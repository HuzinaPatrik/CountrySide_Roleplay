white = "#ffffff"
cameraObjectId = 2921
cameraScale = 0.8

allowed = {{ 48, 57 }, { 65, 90 }, { 97, 122 }}

function generateString(len, onlyNumber, onlyString)
    if tonumber(len) then 
        local result = ""
        
        for i = 1, len do 
            local charList = allowed[math.random(1, 3)]

            if onlyNumber then 
                charList = allowed[1]
            end

            if onlyString then 
                charList = allowed[3]
            end

            result = result .. utf8.upper(utf8.char(math.random(charList[1], charList[2])))
        end

        return result
    end

    return false
end

function getPositionInFront(x, y, z, rot, meters)
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = x, y, z

    posX = posX - math.sin(math.rad(rot)) * meters
    posY = posY + math.cos(math.rad(rot)) * meters
    rot = rot + math.cos(math.rad(rot))

    return posX, posY, posZ, rot
end

function rotateAround(angle, x, y, x2, y2)
    local targetX = x2 or 0
    local targetY = y2 or 0
    local centerX = x
    local centerY = y

    local radians = math.rad(angle)
    local rotatedX = targetX + (centerX - targetX) * math.cos(radians) - (centerY - targetY) * math.sin(radians)
    local rotatedY = targetY + (centerX - targetX) * math.sin(radians) + (centerY - targetY) * math.cos(radians)

    return rotatedX, rotatedY
end