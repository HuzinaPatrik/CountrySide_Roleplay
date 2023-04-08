local positions = {
    ["marker"] = Vector3(124.58835601807, -240.19152832031, 0.4),
    ["craneObj"] = Vector3(124.58835601807, -240.19152832031, 89.5),
    ["crObj"] = Vector3(124.55990600586, -289.67059326172, 85.65),
    ["crObj2"] = Vector3(124.55990600586, -289.67059326172, 33.1),
}

function loadScript()
    makeMarker()
    craneObj = createObject(1381, positions["craneObj"])
    crObj = createObject(1384, positions["crObj"], 0, 0, 0)

    --230 ledobásnál, 0 alapból
    crObj2 = createObject(1395, positions["crObj2"], 0, 0, 90)
end
addEventHandler("onResourceStart", resourceRoot, loadScript)

function playerAcceptOffer(thePlayer, z)
    if cp:getData("using") then 
        return
    end
    
    local pveh = getPedOccupiedVehicle(thePlayer)
    setElementPosition(pveh, 124.58835601807, -240.19152832031, 0.4 + 1.15)
    setElementFrozen(pveh, true)
    removePedFromVehicle(thePlayer)
    local newPosition = cp.position
    newPosition.z = newPosition.z - 50
    cp.position = newPosition
    cp:setData("using", true)
    stepOne(pveh, z)
end
addEvent("acceptOffer", true)
addEventHandler("acceptOffer", root, playerAcceptOffer)

function makeMarker()
    cp = createMarker(positions["marker"], "cylinder", 2, 210,49,49)
    cp:setData("marker >> customMarker", true)
    cp:setData("marker >> customIconPath", ":cr_junkyard/files/image.png")
    cp.alpha = 0
    setElementData(cp, "junkyard", true)
end

function resetMarker()
    local newPosition = cp.position
    newPosition.z = newPosition.z + 50
    cp.position = newPosition
    cp:setData("using", false)
end

mpS = math.random(2, 8) / 10
function changeMultipler(first)
    mpS = math.random(2, 8) / 10
    outputChatBox(exports['cr_core']:getServerSyntax("Zúzda", "info") .. "Az árak megváltoztak!", root, 255, 255, 255, true)
    if not first then
        triggerClientEvent(root, "changeMultipler", root, mpS)
    end
end
changeMultipler(true)
setTimer(changeMultipler,1 * 60 * 60 * 1000, 0)

function requestMultipler(e)
    triggerClientEvent(e, "changeMultipler", e, mpS)
    triggerClientEvent(e, "getData", e, {cp, craneObj, crObj})
end
addEvent("requestMultipler", true)
addEventHandler("requestMultipler", root, requestMultipler)
--setTimer(changeMultipler, 10000, 0)

function stepOne(veh, z)
    local veh = veh
    local x, y, z2 = getElementPosition(craneObj)
    setElementData(craneObj, "startPos", {x, y, z2})
    local _, _, vz = getElementPosition(veh)
    moveObject(craneObj, 15000, 124.58835601807, -240.19152832031, vz + z + 0.15)
    craneObj.collisions = false
    --craneObj:setData("doing", true)
    veh.collisions = false
    setTimer(
        function(veh, z)
            attachElements(veh, craneObj, 0, 0, (z + 0.15) * -1)
            stepTwo(veh, z)
        end, 17000, 1, veh, z
    )
end
--setTimer(stepOne, 1500, 1, createVehicle(470, -1884.1428222656, -1663.1616210938, 21.5), math.abs(-1.05) + math.abs(1.65))

function stepTwo(veh, z)
    local veh = veh
    moveObject(craneObj, 15000, 124.58835601807, -240.19152832031, 89.5)
    setTimer(
        function()
            craneObj:setData("startPos", nil)
            attachElements(craneObj, crObj, 0, 48, 4)
            --outputChatBox("asd")
            detachElements(veh, craneObj)
            attachElements(veh, craneObj, 0, 0, (z + 0.15) * -1)
            moveObject(crObj, 10000, positions["crObj"], 0, 0, -130)
            stepThree(veh, z)
        end, 17000, 1
    )
    --[[
    setTimer(function()
        local x,y,z = getElementPosition(veh)
        outputChatBox(x .. "|" .. y .. "|" .. z)
    end, 20000, 1)]]
end

function stepThree(veh, z)
    local veh = veh -- 1973.1378173828|-2635.9921875|78
    setTimer(function()
        veh.collisions = true
        detachElements(veh, crObj)
        detachElements(veh, craneObj)
        setElementFrozen(veh, false)
        stepFour(veh, z)
    end, 12000, 1)
end

function stepFour(veh, z)
    local veh = veh
    setTimer(function()
        --destroyElement(veh)
        exports['cr_vehicle']:deleteVehicle(veh:getData("veh >> id"), veh.model)
        --destroyVehicle(veh)
        stepFive(veh, z)
    end, 5000, 1)
end

function stepFive(veh, z)
    local veh = veh
    attachElements(craneObj, crObj, 0, 48, 4)
    moveObject(crObj, 12000, positions["crObj"], 0, 0, 130)
    stepSix(veh, z)
end

function stepSix(veh, z)
    local veh = veh
    setTimer(function()
        detachElements(craneObj, crObj)
        setElementPosition(craneObj, 124.58835601807, -240.19152832031, 89.5)
        resetMarker()
        veh = nil
    end, 12000, 1)
end

function destroyVehicle(veh)
    exports['cr_vehicle']:deleteVehicle(veh)
end
