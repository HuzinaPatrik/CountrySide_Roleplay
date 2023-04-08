local positions = {
    --{Vector(x,y,z),Vector(dim,int, 50)},
    {Vector3(151.99600219727, -274.42797851562, -6.421875), Vector3(0, 0, 20), Vector3(59, 60.5, 5)},
}

local elementCache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(positions) do
            local pos, pos2, pos3 = unpack(v)
            -- local mark = createColSphere(pos, pos2.z)

            local mark = createColCuboid(pos, pos3.x, pos3.y, pos3.z)

            mark.interior = pos2.y
            mark.dimension = pos2.x
            elementCache[mark] = true
        end
    end
)

function inAnyColShape()
    for k,v in pairs(elementCache) do
        if isElementWithinColShape(localPlayer, k) then
            return true
        end
    end
    
    return false
end