local sql = exports["cr_mysql"]:getConnection(getThisResource())

local cache = {}

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports["cr_mysql"]:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadRoadblocks()
        end
    end
)

function loadRoadblocks()
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
                        local modelId = tonumber(row["modelId"])
                        local position = fromJSON(row["position"])
                        local interior = tonumber(row["interior"])
                        local dimension = tonumber(row["dimension"])
                        local sourcePlayer = tostring(row["sourcePlayer"])
                        local createdDate = tonumber(row["createdDate"])

                        local posX, posY, posZ, rotX, rotY, rotZ = unpack(position)

                        local object = Object(modelId, posX, posY, posZ, rotX, rotY, rotZ)
                        object.interior = interior 
                        object.dimension = dimension 

                        object:setFrozen(true)
                        object:setData("roadblock >> id", id)
                        object:setData("roadblock >> sourcePlayer", sourcePlayer)
                        object:setData("roadblock >> createdDate", createdDate)

                        cache[id] = object
                    end,

                    function()
                        outputDebugString("@loadRoadblocks: loaded "..loaded.." / "..query_lines.." roadblock(s) in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM roadblocks"
    )
end

function createNewRoadblock(thePlayer, data)
    if isElement(thePlayer) and data then  
        dbExec(sql, "INSERT INTO roadblocks SET modelId = ?, position = ?, interior = ?, dimension = ?, sourcePlayer = ?, createdDate = ?", data["modelId"], toJSON(data["position"]), data["interior"], data["dimension"], data["sourcePlayer"], getRealTime()["timestamp"])

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)
                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            local id = tonumber(row["id"])
                            local modelId = tonumber(row["modelId"])
                            local position = fromJSON(row["position"])
                            local interior = tonumber(row["interior"])
                            local dimension = tonumber(row["dimension"])
                            local sourcePlayer = tostring(row["sourcePlayer"])
                            local createdDate = tonumber(row["createdDate"])

                            local posX, posY, posZ, rotX, rotY, rotZ = unpack(position)

                            local object = Object(modelId, posX, posY, posZ, rotX, rotY, rotZ)
                            object.interior = interior 
                            object.dimension = dimension 
                            
                            object:setFrozen(true)
                            object:setData("roadblock >> id", id)
                            object:setData("roadblock >> sourcePlayer", sourcePlayer)
                            object:setData("roadblock >> createdDate", createdDate)

                            cache[id] = object

                            local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "success")
                            local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                            outputChatBox(syntax.."Sikeresen létrehoztad az útzárat. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                        end
                    )
                end
            end, sql, "SELECT * FROM roadblocks WHERE id = LAST_INSERT_ID()"
        )
    end
end
addEvent("roadblocks.createNewRoadblock", true)
addEventHandler("roadblocks.createNewRoadblock", root, createNewRoadblock)

function updateRoadblock(thePlayer, data)
    if isElement(thePlayer) and data then 
        local id = data["id"]
        local element = data["element"]
        local posX, posY, posZ, rotX, rotY, rotZ = unpack(data["position"])
        local interior = data["interior"]
        local dimension = data["dimension"]

        if element and isElement(element) then 
            element.position = Vector3(posX, posY, posZ)
            element.rotation = Vector3(rotX, rotY, rotZ)
            element.interior = interior 
            element.dimension = dimension 

            local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "success")
            local serverHex = exports["cr_core"]:getServerColor("yellow", true)
            outputChatBox(syntax.."Sikeresen megváltoztattad az útzár pozícióját. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)

            local position = toJSON({posX, posY, posZ, rotX, rotY, rotZ})
            dbExec(sql, "UPDATE roadblocks SET position = ? WHERE id = ?", position, id)
        end
    end
end
addEvent("roadblocks.updateRoadblock", true)
addEventHandler("roadblocks.updateRoadblock", root, updateRoadblock)

function destroyRoadblock(thePlayer, id)
    if isElement(thePlayer) and cache[id] and isElement(cache[id]) then 
        dbExec(sql, "DELETE FROM roadblocks WHERE id = ?", id)

        cache[id]:destroy()
        cache[id] = nil 

        local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "success")
        local serverHex = exports["cr_core"]:getServerColor("yellow", true)
        outputChatBox(syntax.."Sikeresen kitörölted az útzárat. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)

        collectgarbage("collect")
    end
end
addEvent("roadblocks.destroyRoadblock", true)
addEventHandler("roadblocks.destroyRoadblock", root, destroyRoadblock)

function destroyAllRoadblock(thePlayer)
    if isElement(thePlayer) then 
        local result = false 
        for key, value in pairs(cache) do 
            if value and isElement(value) then 
                result = true 
                break 
            end
        end

        if result then 
            for key, value in pairs(cache) do 
                if isElement(value) then 
                    local id = tonumber(value:getData("roadblock >> id") or 0)

                    if id > 0 then 
                        dbExec(sql, "DELETE FROM roadblocks WHERE id = ?", id)
                        value:destroy()
                    end
                end
            end

            cache = {}

            collectgarbage("collect")

            local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "success")
            outputChatBox(syntax.."Sikeresen kitörölted az összes útzárat.", thePlayer, 255, 0, 0, true)
        else 
            local syntax = exports["cr_core"]:getServerSyntax("Roadblock", "error")
            return outputChatBox(syntax.."Nincs létrehozva egy darab útzár sem.", thePlayer, 255, 0, 0, true)
        end
    end
end
addEvent("roadblocks.destroyAllRoadblock", true)
addEventHandler("roadblocks.destroyAllRoadblock", root, destroyAllRoadblock)