white = "#ffffff"

jailDatas = {
    ["outsidePositions"] = {
        {266.99963378906, 86.663803100586, 1001.0390625, 6, 33}, -- x, y, z, int, dim
        {267.04223632813, 82.136672973633, 1001.0390625, 6, 33}, -- x, y, z, int, dim
        {267.29153442383, 77.571281433105, 1001.0390625, 6, 33}, -- x, y, z, int, dim
    },

    ["cellPositions"] = {
        {264.7008972168, 86.54711151123, 1001.0390625, 6, 33}, -- x, y, z, int, dim
        {264.49722290039, 81.839157104492, 1001.0390625, 6, 33}, -- x, y, z, int, dim
        {264.64364624023, 77.615348815918, 1001.0390625, 6, 33}, -- x, y, z, int, dim
    },

    ["cellDoors"] = {
        {1495, 266.29653930664, 86.907960510254, 1000.0390625, 90, 6, 33}, -- objectId, x, y, z, rot, int, dim
        {1495, 266.29653930664, 82.407960510254, 1000.0390625, 90, 6, 33}, -- objectId, x, y, z, rot, int, dim
    },
}

jailReleasePoint = Vector3(626.64733886719, -559.22106933594, 17.025318145752)
jailReleaseRotationPoint = Vector3(0, 0, 180.02235412598)
jailReleaseInterior = 0
jailReleaseDimension = 0

factionPrefixes = {
    [1] = {
        ["prefix"] = "LSSD",
        ["badgePrefix"] = "LSSD",
    },

    [2] = {
        ["prefix"] = "RCMD",
        ["badgePrefix"] = "RCMD",
    },

    [8] = {
        ["prefix"] = "RMN",
        ["badgePrefix"] = "RMN",
    },

    [9] = {
        prefix = "Wiley Ranch",
        badgePrefix = "Wiley Ranch"
    }
}

factionIdsByPrefixes = {}
allFactionPrefixes = {}

for k, v in pairs(factionPrefixes) do 
    factionIdsByPrefixes[v.prefix] = k
    table.insert(allFactionPrefixes, v.prefix)
end

permissions = {
    -- [command] = {fraki id, fraki id}
    ["gov"] = {1, 2, 3, 4, 5, 8},
    ["arrest"] = {1},
    ["jail"] = {1},
    ["release"] = {1},
    ["trackplayer"] = {1},
    ["alnev"] = {1},
    ["backup"] = {1, 2, 4},
    ["rbs"] = {1, 4},
    ["nearbyrbs"] = {1, 4},
    ["delrb"] = {1, 4},
    ["editrb"] = {1, 4},
    ["delallrb"] = {1, 4},
    -- ["lefoglal"] = {1, 2, 5},
    -- ["impound"] = {1, 2, 5},
    ["createbadge"] = {1, 2, 4, 8},
    ["unflipmechanic"] = {3},
    ["mdc"] = {1},
    i = {8},
    inviteinterview = {8},
    endinterview = {8},
    spike = {1},
    nearbyspikes = {1},
    ticket = {1, 2},
    prisoners = {1},
    getlegalfactions = {4},
    getfactiondata = {4},
    givehealthcard = {2},
    givegovcard = {4},
    givelicense = {4},
    changelock = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
}

ticketPedData = {
    {
        position = Vector3(0, 0, 3),
        rotation = Vector3(0, 0, 270),
        interior = 0,
        dimension = 0,
        skinId = 259,
        name = "Jeremiah Wade",
        typ = "Büntetés befizetés"
    }
}

function getTicketPedData(id)
    return ticketPedData[id] or ticketPedData
end

function getFactionPrefix(id)
    if factionPrefixes[id] then 
        return factionPrefixes[id]["prefix"]
    end

    return "Ismeretlen"
end

function getFactionIdByPrefix(prefix)
    if factionIdsByPrefixes[prefix] then 
        return factionIdsByPrefixes[prefix], allFactionPrefixes
    end

    return false, allFactionPrefixes
end

function getFactionPrefixes()
    return factionPrefixes
end

function hasFactionPermission(thePlayer, factionId, permName)
    if factionId and permName then 
        if exports.cr_dashboard:hasPlayerPermission(thePlayer, factionId, permName) or exports.cr_dashboard:isPlayerFactionLeader(thePlayer, factionId) then 
            return true
        end
    end

    return false
end

function hasPlayerPermission(thePlayer, cmd, leaderOrPerm)
    local leaderOrPerm = leaderOrPerm or false

    if isElement(thePlayer) then 
        if permissions[cmd] then 
            for k, v in pairs(permissions[cmd]) do 
                if leaderOrPerm == true then 
                    if exports["cr_dashboard"]:isPlayerFactionLeader(thePlayer, v) then 
                        return true 
                    end
                elseif type(leaderOrPerm) == "string" then
                    if hasFactionPermission(thePlayer, v, leaderOrPerm) then 
                        return true
                    end
                else
                    if exports["cr_dashboard"]:isPlayerInFaction(thePlayer, v) then 
                        return true 
                    end
                end
            end
        end
    end

    return false
end

function getClosestCell(dist)
	local a, jail = 9999, false
    
	for key, value in pairs(getElementsByType("object", resourceRoot, true)) do
        if value:getData("jail >> cell") then
            local dist = getDistanceBetweenPoints3D(value.position, localPlayer.position)
            if dist <= a then
                local enabled = true
                
                if enabled then
                    jail = value
                    a = dist
                    break
                end
            end
        end
	end
    
	if a <= dist then
		return jail
	end
    
	return false
end

function getNearbyVehicle(model, dist)
    local model = model or false 
    local dist = dist or false
    local vehicle = false

    for key, value in pairs(getElementsByType("vehicle", root, true)) do 
        if (value:getData("veh >> id") or 0) > 0 then 
            if value.model == model then 
                local distance = getDistanceBetweenPoints3D(value.position, localPlayer.position)
                if distance <= dist then 
                    vehicle = value 
                    break 
                end
            end
        end
    end

    return vehicle
end

function getVehicleInRange(thePlayer, model, range)
    if isElement(thePlayer) and model then 
        range = range or 5

        local result = false
        local elements = getElementsWithinRange(thePlayer.position, range, "vehicle")

        if elements and #elements > 0 then 
            for k, v in pairs(elements) do 
                if v.interior == thePlayer.interior and v.dimension == thePlayer.dimension and v.model == model then 
                    local distance = getDistanceBetweenPoints3D(thePlayer.position, v.position)

                    if distance <= range then 
                        result = v
                        break
                    end
                end
            end
        end

        return result
    end
end

function table.count(tbl)
    local length = 0

    for k in pairs(tbl) do 
        length = length + 1
    end

    return length
end