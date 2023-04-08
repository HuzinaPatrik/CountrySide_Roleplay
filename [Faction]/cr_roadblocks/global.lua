roadblocks = {
	{
        ["name"] = "Bólya",
        ["objectId"] = 1238,
        ["restricted"] = false,
        ["imagePath"] = "files/images/1238.png"
    },
	
	{
        ["name"] = "Figyelmeztető kerítés",
        ["objectId"] = 1459,
        ["restricted"] = false,
        ["imagePath"] = "files/images/1459.png"
    },
	
    {
        ["name"] = "Beton terelő",
        ["objectId"] = 1422,
        ["restricted"] = true,
        ["imagePath"] = "files/images/1422.png"
    },

    {
        ["name"] = "Elterelő #1",
        ["objectId"] = 1427,
        ["restricted"] = true,
        ["imagePath"] = "files/images/1427.png"
    },

    {
        ["name"] = "Elterelő #2",
        ["objectId"] = 1425,
        ["restricted"] = true,
        ["imagePath"] = "files/images/1425.png"
    },

    {
        ["name"] = "Kis útzár",
        ["objectId"] = 978,
        ["restricted"] = true,
        ["imagePath"] = "files/images/978.png"
    },

    {
        ["name"] = "Nagy útzár",
        ["objectId"] = 981,
        ["restricted"] = true,
        ["imagePath"] = "files/images/981.png"
    },

    {
        ["name"] = "Sárga útzár",
        ["objectId"] = 3578,
        ["restricted"] = true,
        ["imagePath"] = "files/images/3578.png"
    },

    {
        ["name"] = "Járda blokk",
        ["objectId"] = 1424,
        ["restricted"] = true,
        ["imagePath"] = "files/images/1424.png"
    },

    {
        ["name"] = "Útterelő tábla",
        ["objectId"] = 1425,
        ["restricted"] = true,
        ["imagePath"] = "files/images/1425.png"
    },

    {
        ["name"] = "Jármű terelő",
        ["objectId"] = 3091,
        ["restricted"] = true,
        ["imagePath"] = "files/images/3091.png"
    },
}

minLines = 1
maxLines = 11
_maxLines = maxLines

white = "#FFFFFF"

function getVehicleInRange(thePlayer, range)
    local vehicles = exports.cr_mdc:getAllowedVehicles() or {}
    vehicles[552] = true

    if isElement(thePlayer) then 
        range = range or 5

        local result = {}
        local elements = getElementsWithinRange(thePlayer.position, range, "vehicle")

        if elements and #elements > 0 then 
            for k, v in pairs(elements) do 
                if v.interior == thePlayer.interior and v.dimension == thePlayer.dimension and vehicles[v.model] then 
                    local distance = getDistanceBetweenPoints3D(thePlayer.position, v.position)

                    if distance <= range then 
                        result = {v, v.model}
                        break
                    end
                end
            end
        end

        return unpack(result)
    end
end

function getTableKey(array, key)
    local result = false 

    for index = 1, #array do 
        local value = array[index]

        if value then 
            if value["id"] == key then 
                result = index 
                break 
            end
        end
    end

    return result
end