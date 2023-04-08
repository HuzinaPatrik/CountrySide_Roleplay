addEventHandler("onResourceStart", resourceRoot,
    function()
        for k,v in pairs(cache) do
            local name, nokill, type, nametagType, pos = unpack(v)
            if type == "server" then
                local skin, x,y,z,rx,ry,rz,dim,int = unpack(pos)
                local e = Ped(skin, x,y,z, rz)
                e.rotation = Vector3(rx,ry,rz)
                e.position = Vector3(x,y,z)
                e.dimension = dim
                e.interior = int
                e.model = skin
                
                e:setData("ped.name", name)
                e:setData("ped.type", nametagType)			
                e:setData("char >> noDamage", nokill)			
                pedCache[k] = e
            end
        end
    end
)