treeCache = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        for k,v in pairs(treePositions) do 
            local x,y,z,dim,int,rot1, rot2, rot3, type, fallData = unpack(v)

            local modelid = treeDatas[type]['bigModelID']

            local obj = Object(modelid, x, y, z)
            obj.dimension = dim 
            obj.interior = int 
            obj.rotation = Vector3(rot1, rot2, rot3)

            obj:setData("lumberjack >> tree", k)
            obj:setData("lumberjack >> treeType", type)
            obj:setData("lumberjack >> health", 100)

            obj.frozen = true

            treeCache[obj] = k
        end 
    end 
)