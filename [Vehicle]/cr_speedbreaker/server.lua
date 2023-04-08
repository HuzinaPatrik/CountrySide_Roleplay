local cache = {}

addEventHandler("onResourceStart", resourceRoot, 
    function()
        for index, object in pairs(getElementsByType("object")) do 
            if getElementModel(object) == 16172 then 
                local x, y, z = getElementPosition(object) 
                cache[index] = createColCuboid(x-5, y-5, z-1.0, 10, 10 ,3)
                setElementData(cache[index], "colshape.speedbreaker", index)
                setElementData(cache[index], "colshape.element", object)
            end
        end
    end
)