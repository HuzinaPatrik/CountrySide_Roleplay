local createdElements = {
    object = {}
}

function createRocks()
    for i = 1, #jobData.rockPositions do 
        local v = jobData.rockPositions[i]

        if v.x and v.y and v.z then 
            local x, y, z = v.x, v.y, v.z
            local interior, dimension = v.interior, v.dimension
            local objectId = v.objectId

            local obj = Object(objectId, x, y, z)

            obj.interior = interior
            obj.dimension = dimension
            
            obj:setData("rock >> id", i)
            obj:setData("rock >> health", 100)

            createdElements.object[obj] = true
        end
    end
end

function onStart()
    createRocks()
end
addEventHandler("onResourceStart", resourceRoot, onStart)