function createFurniturePed(skinId, x, y, z, rot, interior, dimension, name)
    local pedElement = Ped(skinId, x, y, z, rot)

    pedElement.frozen = true
    pedElement.interior = interior
    pedElement.dimension = dimension
    pedElement.rotation = Vector3(0, 0, rot)

    pedElement:setData("furniturePed", true)
    pedElement:setData("ped.name", name)
    pedElement:setData("ped.type", "Bútorbolt")
end

function onStart()
    createFurniturePed(21, 2309.0922851562, 64.56908416748, 26.484375, 179.77510070801, 0, 0, "Marco Shirt")
end
addEventHandler("onResourceStart", resourceRoot, onStart)