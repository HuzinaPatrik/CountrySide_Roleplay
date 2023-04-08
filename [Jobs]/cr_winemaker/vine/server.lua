local vineCache = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        for k,v in pairs(vinePositions) do 
            local x,y,z,dim,int,rot1, rot2, rot3 = unpack(v)

            local obj = Object(7048, x, y, z)
            obj.dimension = dim 
            obj.interior = int 
            obj.rotation = Vector3(rot1, rot2, rot3)

            obj:setData("wineMaker >> vine", k)
            obj:setData("wineMaker >> health", 100)

            vineCache[obj] = true
        end 
    end 
)

local respawnTimers = {}
local respawnTime = 15 * 1000 -- 1 * 60 * 1000
local respawnCount = 5

addEvent("respawnVine", true)
addEventHandler("respawnVine", root, 
    function(sourcePlayer, obj)
        if vineCache[obj] then 
            if sourcePlayer:getData("winemaker >> objInHand") then 
                sourcePlayer:setData("winemaker >> objInHand", 7046)

                obj.model = 6882
                obj:setData("wineMaker >> health", 0)
                obj:setData("wineMaker >> doingInteraction", nil)

                if isTimer(respawnTimers[obj]) then 
                    killTimer(respawnTimers[obj]) 
                end 

                respawnTimers = setTimer(
                    function(obj)
                        obj:setData("wineMaker >> health", math.min(100, tonumber(obj:getData("wineMaker >> health" or 0) + respawnCount)))

                        if tonumber(obj:getData("wineMaker >> health" or 0)) == 100 then 
                            obj.model = 7048
                        end 
                    end, respawnTime, 100 / respawnCount, obj
                )
            end 
        end 
    end 
)