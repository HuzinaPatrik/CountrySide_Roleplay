local sql = exports["cr_mysql"]:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports["cr_mysql"]:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadHitchHikers()
        end
    end
)

local cache = {}

function loadHitchHikers()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(query)
            local query, query_lines = dbPoll(query, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        local id = tonumber(row["id"])
                        local createdBy = tostring(row["createdBy"])
                        local createDate = tostring(row["createDate"])
                        local pedData = fromJSON(row["pedData"])
                        local colData = fromJSON(row["colData"])

                        local pedX, pedY, pedZ, pedRx, pedRy, pedRz, pedInterior, pedDimension, pedSkin, pedName = unpack(pedData)
                        local colX, colY, colZ, colWidth, colDepth, colHeight, colInterior, colDimension = unpack(colData)

                        local pedPoint = Vector3(pedX, pedY, pedZ)
                        local hiker = Ped(pedSkin, pedPoint)

                        hiker.interior = pedInterior
                        hiker.dimension = pedDimension
                        hiker.frozen = true
                        hiker:setData("ped.name", pedName)
                        hiker:setData("ped.type", "Stoppos")
                        hiker:setData("char >> noDamage", true)
                        hiker:setData("hiker >> id", id)
                        hiker:setData("hiker >> createdBy", createdBy)
                        hiker:setData("hiker >> createDate", createDate)

                        local col = createColCuboid(colX, colY, colZ, colWidth, colDepth, colHeight)
                        col.interior = colInterior
                        col.dimension = colDimension

                        col:setData("pedParent", hiker)

                        cache[id] = {hiker, col}
                    end,

                    function()
                        collectgarbage("collect")
                        outputDebugString("@loadHitchHikers: loaded "..loaded.." / "..query_lines.." hitchhiker(s) in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM hitchhikers"
    )
end

function createHiker(thePlayer, pedData, colData)
    if client and client == thePlayer and pedData and colData then 
        local startTick = getTickCount()

        local pedX, pedY, pedZ, pedRx, pedRy, pedRz, pedInterior, pedDimension, pedSkin, pedName = unpack(pedData)
        local colX, colY, colZ, colWidth, colDepth, colHeight, colInterior, colDimension = unpack(colData)

        local createdBy = exports["cr_admin"]:getAdminName(thePlayer)

        dbExec(sql, "INSERT INTO hitchhikers SET createdBy = ?, createDate = NOW(), pedData = ?, colData = ?", createdBy, toJSON(pedData), toJSON(colData))

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)

                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            local id = tonumber(row["id"])
                            local createdBy = tostring(row["createdBy"])
                            local createDate = tostring(row["createDate"])
                            local pedData = fromJSON(row["pedData"])
                            local colData = fromJSON(row["colData"])

                            local pedX, pedY, pedZ, pedRx, pedRy, pedRz, pedInterior, pedDimension, pedSkin, pedName = unpack(pedData)
                            local colX, colY, colZ, colWidth, colDepth, colHeight, colInterior, colDimension = unpack(colData)

                            local pedPoint = Vector3(pedX, pedY, pedZ)
                            local hiker = Ped(pedSkin, pedPoint)

                            hiker.interior = pedInterior
                            hiker.dimension = pedDimension
                            hiker.frozen = true
                            hiker:setData("ped.name", pedName)
                            hiker:setData("ped.type", "Stoppos")
                            hiker:setData("char >> noDamage", true)
                            hiker:setData("hiker >> id", id)
                            hiker:setData("hiker >> createdBy", createdBy)
                            hiker:setData("hiker >> createDate", createDate)

                            local col = createColCuboid(colX, colY, colZ, colWidth, colDepth, colHeight)
                            col.interior = colInterior
                            col.dimension = colDimension

                            col:setData("pedParent", hiker)

                            cache[id] = {hiker, col}
                        end,

                        function()
                            collectgarbage("collect")
                            outputDebugString("@createHiker: created 1 hiker in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                        end
                    )
                end
            end, sql, "SELECT * FROM hitchhikers WHERE id = LAST_INSERT_ID()"
        )
    end
end
addEvent("hiker.createHiker", true)
addEventHandler("hiker.createHiker", root, createHiker)

function deleteHiker(thePlayer, id)
    if client and client == thePlayer and id then 
        if cache[id] then 
            local hiker, col = unpack(cache[id])

            if isElement(hiker) then 
                hiker:destroy()
            end

            if isElement(col) then 
                col:destroy()
            end

            cache[id] = nil

            local syntax = exports["cr_core"]:getServerSyntax(false, "success")
            local serverHex = exports["cr_core"]:getServerColor("yellow", true)

            dbExec(sql, "DELETE FROM hitchhikers WHERE id = ?", id)

            outputChatBox(syntax.."Sikeresen kitörölted a stoppost. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
            exports["cr_core"]:sendMessageToAdmin(thePlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(thePlayer, true)..white.." kitörölt egy stoppost. "..serverHex.."("..id..")", 3)

            collectgarbage("collect")
        else
            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem található stoppos ezzel az id-vel.", thePlayer, 255, 0, 0, true)
        end
    end
end
addEvent("hiker.deleteHiker", true)
addEventHandler("hiker.deleteHiker", root, deleteHiker)

function warpHikerIntoVehicle(thePlayer, hiker, vehicle, seat)
    if client and client == thePlayer and hiker and vehicle and seat then 
        local id = hiker:getData("hiker >> id")
        vehicle:setData("hikerParent", hiker)
        thePlayer:setData("hikerParent", hiker)
        hiker:setData("hikerParent", thePlayer)

        local hikerPoint = hiker.position
        local hikerRotation = hiker.rotation

        local x, y, z = hikerPoint.x, hikerPoint.y, hikerPoint.z
        local rx, ry, rz = hikerRotation.x, hikerRotation.y, hikerRotation.z

        cache[id][3] = {x, y, z, rx, ry, rz}

        hiker:warpIntoVehicle(vehicle, seat)
        hiker:setData("char >> belt", true)
    end
end
addEvent("hiker.warpHikerIntoVehicle", true)
addEventHandler("hiker.warpHikerIntoVehicle", root, warpHikerIntoVehicle)

function resetHikerPosition(hiker, id, vehicle)
    if hiker and isElement(hiker) and cache[id] then 
        if cache[id][3] then 
            local x, y, z, rx, ry, rz = unpack(cache[id][3])
            local hikerPoint = Vector3(x, y, z)
            local hikerRotation = Vector3(rx, ry, rz)

            hiker:removeFromVehicle()

            if isElement(thePlayer) then 
                thePlayer:removeData("hikerParent")
            end

            if isElement(vehicle) then 
                vehicle:removeData("hikerParent")
            end

            local thePlayer = hiker:getData("hikerParent")

            if isElement(thePlayer) then 
                thePlayer:removeData("hikerParent")
            end

            hiker.position = hikerPoint
            hiker.rotation = hikerRotation
            hiker.frozen = true
            hiker:removeData("hikerParent")

            cache[id][3] = nil
        end
    end
end
addEvent("hiker.resetHikerPosition", true)
addEventHandler("hiker.resetHikerPosition", root, resetHikerPosition)

function onElementDestroy()
    if source.type == "vehicle" and source:getData("hikerParent") then 
        local hiker = source:getData("hikerParent")

        if isElement(hiker) then 
            local id = hiker:getData("hiker >> id")
            
            resetHikerPosition(hiker, id, source)
        end
    end
end
addEventHandler("onElementDestroy", root, onElementDestroy)

function onQuit()
    if source:getData("hikerParent") then 
        local hiker = source:getData("hikerParent")

        if isElement(hiker) then 
            local id = hiker:getData("hiker >> id")

            resetHikerPosition(hiker, id, hiker.vehicle)
        end
    end
end
addEventHandler("onPlayerQuit", root, onQuit)