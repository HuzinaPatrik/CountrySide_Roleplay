addEventHandler('onPlayerQuit', root, 
    function()
        if source:getData('lumberjack >> tree >> hit') then 
            local obj = source:getData('lumberjack >> tree >> hit')

            source:setData('lumberjack >> tree >> hit', nil)
            
            if obj:getData('lumberjack >> tree >> hit') == source then 
                obj:setData('lumberjack >> tree >> hit', nil)
                obj:setData("lumberjack >> health", 100)
            end 
        end 
    end 
)

local treeTimers = {}

local treeRespawnTimers = {}

addEvent('treeFalls', true)
addEventHandler('treeFalls', root, 
    function(sourcePlayer, obj)
        if treeCache[obj] then 
            if sourcePlayer:getData('lumberjack >> tree >> hit') and sourcePlayer:getData('lumberjack >> tree >> hit') == obj then 
                if not obj:getData('lumberjack >> tree >> fallen') then 
                    obj:setData('lumberjack >> tree >> fallen', sourcePlayer)

                    local id = treeCache[obj] 
                    local typ = treePositions[id][9]

                    local cuttingCount = treeDatas[typ]['cuttingCount']

                    if type(cuttingCount) == 'table' then 
                        cuttingCount = math.random(cuttingCount[1], cuttingCount[2])
                    end 

                    if tonumber(cuttingCount) then 
                        obj:setData('lumberjack >> tree >> cuttingCount', cuttingCount)
                        obj:setData('lumberjack >> tree >> maxCuttingCount', cuttingCount)
                    end 

                    local fallData = treePositions[id][10]

                    if fallData then 
                        obj.collisions = false 

                        moveObject(obj, fallData['time'], obj.position.x, obj.position.y, obj.position.z, fallData['rotX'], fallData['rotY'], fallData['rotZ'])

                        if isTimer(treeTimers[obj]) then 
                            killTimer(treeTimers[obj]) 
                        end 

                        treeTimers[obj] = setTimer(
                            function(sourcePlayer, obj, typ, fallData, id)
                                obj:setData('lumberjack >> tree >> falled', true)
                                obj:setData('lumberjack >> tree >> ownerName', exports['cr_admin']:getAdminName(sourcePlayer))

                                local modelid = treeDatas[typ]['fallenModelID']

                                local x,y,z = getElementPosition(obj)
                                local minX, minY, minZ = unpack(fallData['FallenObjPosition'])

                                local newX, newY, newZ = x + minX, y + minY, z + minZ

                                obj.position = Vector3(newX, newY, newZ)

                                obj.rotation = Vector3(unpack(fallData['FallenObjRotation']))

                                obj.model = modelid
                                obj.scale = 1
                                obj.collisions = true 

                                if isTimer(treeRespawnTimers[obj]) then 
                                    killTimer(treeRespawnTimers[obj])
                                end 

                                treeRespawnTimers[obj] = setTimer(
                                    function(sourcePlayer, obj, typ, fallData, id)
                                        obj:setData('lumberjack >> tree >> fallen', false)
                                        obj:setData('lumberjack >> tree >> falled', false)
                                        obj:setData('lumberjack >> tree >> hit', false)

                                        local modelid = treeDatas[typ]['bigModelID']

                                        obj.model = modelid
                                        obj.scale = 1
                                        obj.collisions = true 

                                        local x,y,z,_,_,rot1, rot2, rot3, _, _ = unpack(treePositions[id])

                                        obj.position = Vector3(x, y, z)
                                        obj.rotation = Vector3(rot1, rot2, rot3)

                                        if isElement(sourcePlayer) then 
                                            sourcePlayer:setData('lumberjack >> tree >> hit', nil)

                                            exports['cr_infobox']:addBox(sourcePlayer, 'warning', 'Mivel nem dolgoztad fel teljesen a fát ezért az respawnolódott!')
                                        end 
                                    end, 5 * 60 * 1000, 1, sourcePlayer, obj, typ, fallData, id
                                )
                            end, fallData['time'] + 50, 1, sourcePlayer, obj, typ, fallData, id
                        )
                    end 
                end 
            end 
        end 
    end 
)

local respawnTimers = {}

function respawnTree(sourcePlayer, obj)
    if treeCache[obj] then 
        if isTimer(treeRespawnTimers[obj]) then 
            killTimer(treeRespawnTimers[obj])
        end 

        local id = treeCache[obj] 
        local typ = treePositions[id][9]

        sourcePlayer:setData('lumberjack >> tree >> hit', nil)

        obj:setData('lumberjack >> tree >> fallen', false)
        obj:setData('lumberjack >> tree >> falled', false)
        obj:setData('lumberjack >> tree >> hit', false)

        obj.collisions = false

        local modelid = treeDatas[typ]['smallModelID']

        obj.model = modelid
        obj.scale = 0

        local x,y,z,_,_,rot1, rot2, rot3, _, _ = unpack(treePositions[id])

        obj.position = Vector3(x, y, z)
        obj.rotation = Vector3(rot1, rot2, rot3)

        obj:setData("lumberjack >> health", 0)
        obj:setData("lumberjack >> doingInteraction", nil)

        local respawnTime = treeDatas[typ]['respawnTime']
        local respawnCount = treeDatas[typ]['respawnCount']

        if isTimer(respawnTimers[obj]) then 
            killTimer(respawnTimers[obj]) 
        end 

        respawnTimers = setTimer(
            function(obj, typ)
                obj:setData("lumberjack >> health", math.min(100, tonumber(obj:getData("lumberjack >> health" or 0) + respawnCount)))

                local scale = math.min(100, tonumber(obj:getData("lumberjack >> health" or 0))) / 100

                obj.scale = Vector3(scale, scale, scale)

                if tonumber(obj:getData("lumberjack >> health" or 0)) == 100 then 
                    local modelid = treeDatas[typ]['bigModelID']

                    obj.model = modelid

                    obj.collisions = true
                end 
            end, respawnTime, 100 / respawnCount, obj, typ
        )
    end 
end 
addEvent('respawnTree', true)
addEventHandler('respawnTree', root, respawnTree)