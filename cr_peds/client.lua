addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(cache) do
            local name, nokill, type, nametagType, pos, texturechange = unpack(v)
            if type == "client" then
                local skin, x,y,z,rx,ry,rz,dim,int = unpack(pos)
                local e = Ped(skin, x,y,z, rz)
                e.rotation = Vector3(rx,ry,rz)
                e.position = Vector3(x,y,z)
                e.dimension = dim
                e.interior = int
                e.model = skin
                
                e.frozen = true
                e:setData("ped.name", name)
                e:setData("ped.type", nametagType)			
                e:setData("char >> noDamage", nokill)			
                pedCache[k] = e
                
                --outputChatBox("asd")
                if texturechange then
                    --outputChatBox("asd2")
                    setTimer(
                        function()
                            --outputChatBox("asd3: "..texturechange[1])
                            --outputChatBox("asd4: "..texturechange[2])
                            exports['cr_texturechanger']:replace(e, texturechange[1], texturechange[2], true, "dxt1")
                        end, 300, 1
                    )
                end
            end
        end
    end
)