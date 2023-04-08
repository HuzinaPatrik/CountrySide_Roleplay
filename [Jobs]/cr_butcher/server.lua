local createdElements = {
    object = {}
}

function createCarcasses()
    for i = 1, #jobData.carcassPositions do 
        local v = jobData.carcassPositions[i]
        local x, y, z = v.x, v.y, v.z
        local position = Vector3(x, y, z)

        local obj = Object(jobData.carcassObjectId, position)
        obj:setData("carcass >> id", i)
        obj:setData("carcass >> health", 100)

        obj.frozen = true
        obj.interior = jobData.carcassInterior
        obj.dimension = jobData.carcassDimension
        createdElements.object[obj] = true
    end
end

function destroyCarcasses()
    for k, v in pairs(createdElements.object) do 
        if isElement(k) then 
            k:destroy()
        end
    end

    createdElements.object = {}

    collectgarbage("collect")
end

function onStart()
    createCarcasses()
end
addEventHandler("onResourceStart", resourceRoot, onStart)