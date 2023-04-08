local vehicleCache = {}
local vehicleToIDCache = {}

local _createVehicle = createVehicle
function createVehicle(data)
    if data["id"] then
        local e = _createVehicle(data["model"], data["x"], data["y"], data["z"], data["rx"], data["ry"], data["rz"], data["plate"], false, data["variant1"], data["variant2"])
        
	    vehicleCache[data["id"]] = e
        vehicleToIDCache[e] = data["id"]
        
        return e
    end
    
    return false
end

function getVehicleByID(id)
    return vehicleCache[id]
end

local pickupCache = {}
local pickupToIDCache = {}

local _createPickup = createPickup
function createPickup(data)
	if data["id"] then
        local e = _createPickup(data["x"], data["y"], data["z"], data["type"], data["extra"])
        
	    pickupCache[data["id"]] = e
        pickupToIDCache[e] = data["id"]
        return e
    end
    
    return false
end

function getPickupByID(id)
    return pickupCache[id]
end

local markerCache = {}
local markerToIDCache = {}

local _createMarker = createMarker
function createMarker(data)
	if data["id"] then
        local e = _createMarker(data["x"], data["y"], data["z"], data["type"], data["size"], data["r"], data["g"], data["b"], data["a"], data["visibleTo"])
        
	    markerCache[data["id"]] = e
        markerToIDCache[e] = data["id"]
        return e
    end
    
    return false
end

function getMarkerByID(id)
    return markerCache[id]
end

local pedCache = {}
local pedToIDCache = {}

local _createPed = createPed
function createPed(data)
	if data["id"] then
        local e = _createPed(data["model"], data["x"], data["y"], data["z"], data["rot"], data["synced"])
        
	    pedCache[data["id"]] = e
        pedToIDCache[e] = data["id"]
        return e
    end
    
    return false
end

function getPedByID(id)
    return pedCache[id]
end

local objecctCache = {}
local objecctToIDCache = {}

local _createObject = createObject
function createObject(data)
	if data["id"] then
        local e = _createObject(data["model"], data["x"], data["y"], data["z"], data["rx"], data["ry"], data["rz"], data["isLowLOD"])
        
	    objecctCache[data["id"]] = e
        objecctToIDCache[e] = data["id"]
        return e
    end
    
    return false
end

function getObjectByID(id)
    return objecctCache[id]
end

addEventHandler("onElementDestroy", resourceRoot,
    function()
        if vehicleToIDCache[source] then
            vehicleCache[vehicleToIDCache[source]] = nil
            vehicleToIDCache[source] = nil
            collectgarbage("collect")
        elseif pickupToIDCache[source] then
            pickupCache[pickupToIDCache[source]] = nil
            pickupToIDCache[source] = nil
            collectgarbage("collect")
        elseif markerToIDCache[source] then
            markerCache[markerToIDCache[source]] = nil
            markerToIDCache[source] = nil
            collectgarbage("collect")
        elseif pedToIDCache[source] then
            pedCache[pedToIDCache[source]] = nil
            pedToIDCache[source] = nil
            collectgarbage("collect")
        elseif objecctToIDCache[source] then
            objecctCache[objecctToIDCache[source]] = nil
            objecctToIDCache[source] = nil
            collectgarbage("collect")    
        end
    end
)