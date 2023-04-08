local sql = exports["cr_mysql"]:getConnection(getThisResource())
addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports["cr_mysql"]:getConnection(getThisResource())
        elseif startedRes == getThisResource() then 
            loadGates()
        end
    end
)

local cache = {}

function loadGates()
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
                        local createdBy = tostring(row["createdBy"])
                        local createdDate = tonumber(row["createdDate"])
                        local startPosition = fromJSON(row["startPosition"])
                        local endPosition = fromJSON(row["endPosition"])

                        local x, y, z, rx, ry, rz, interior, dimension = unpack(startPosition)

                        local gateObject = Object(modelId, x, y, z, rx, ry, rz)
                        gateObject.interior = interior
                        gateObject.dimension = dimension
                        gateObject.frozen = true

                        gateObject:setData("object >> data", {
                            ["id"] = id,
                            ["startPosition"] = startPosition,
                            ["endPosition"] = endPosition,
                            ["state"] = false,
                            ["moving"] = false,
                            ["createdBy"] = createdBy,
                            ["createdDate"] = createdDate,
                        })

                        cache[id] = gateObject
                    end,

                    function()
                        outputDebugString("@loadGates: loaded "..loaded.." / "..query_lines.." gates(s) in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM gates"
    )
end

addEvent("gate >> createGate", true)
addEventHandler("gate >> createGate", root,
    function(data)
        local startTick = getTickCount()
        local modelId = data["modelId"]
        local createdBy = data["createdBy"]
        local createdDate = getRealTime()["timestamp"]
        local startPosition = data["startPosition"]
        local endPosition = data["endPosition"]

        dbExec(sql, "INSERT INTO gates SET modelId = ?, createdBy = ?, createdDate = ?, startPosition = ?, endPosition = ?", modelId, createdBy, createdDate, startPosition, endPosition)

        dbQuery(
            function(query)
                local query, query_lines = dbPoll(query, 0)

                if query_lines > 0 then 
                    Async:foreach(query,
                        function(row)
                            local id = tonumber(row["id"])
                            local modelId = tonumber(row["modelId"])
                            local createdBy = tostring(row["createdBy"])
                            local createdDate = tonumber(row["createdDate"])
                            local startPosition = fromJSON(row["startPosition"])
                            local endPosition = fromJSON(row["endPosition"])
    
                            local x, y, z, rx, ry, rz, interior, dimension = unpack(startPosition)
    
                            local gateObject = Object(modelId, x, y, z, rx, ry, rz)
                            gateObject.interior = interior
                            gateObject.dimension = dimension
                            gateObject.frozen = true
    
                            gateObject:setData("object >> data", {
                                ["id"] = id,
                                ["startPosition"] = startPosition,
                                ["endPosition"] = endPosition,
                                ["state"] = false,
                                ["moving"] = false,
                                ["createdBy"] = createdBy,
                                ["createdDate"] = createdDate,
                            })

                            cache[id] = gateObject
                        end,

                        function()
                            outputDebugString("@createGate: created 1 gate in "..getTickCount() - startTick.." ms.", 0, 255, 50, 255)
                        end
                    )
                end
            end, sql, "SELECT * FROM gates WHERE id = LAST_INSERT_ID()"
        )
    end
)

addEvent("gate >> handleGate", true)
addEventHandler("gate >> handleGate", root,
    function(obj, values)
        if client and isElement(client) then 
            if obj and values then 
                local data = obj:getData("object >> data")
                local openPosition = data["startPosition"]
                local closePosition = data["endPosition"]

                local calculatedRz = values["calculatedRz"]
                local calculatedRy = values["calculatedRy"]

                if not data["moving"] then 
                    local openX, openY, openZ, openRx, openRy, openRz, openInterior, openDimension = unpack(openPosition)
                    local closeX, closeY, closeZ, closeRx, closeRy, closeRz, closeInterior, closeDimension = unpack(closePosition)

                    if not data["state"] then
                        obj:move(moveTime, closeX, closeY, closeZ, 0, calculatedRy, calculatedRz, "InOutQuad")

                        data["state"] = true
                        data["moving"] = true

                        obj:setData("object >> data", data)
                    else
                        obj:move(moveTime, openX, openY, openZ, 0, calculatedRy, calculatedRz, "InOutQuad")

                        data["state"] = false
                        data["moving"] = true

                        obj:setData("object >> data", data)
                    end

                    setTimer(
                        function(element)
                            local data = element:getData("object >> data")

                            data["moving"] = false

                            element:setData("object >> data", data)
                        end, moveTime, 1, obj
                    )
                end
            end
        end
    end
)

addEvent("gate >> deleteGate", true)
addEventHandler("gate >> deleteGate", root,
    function(thePlayer, id)
        if client and client == thePlayer and isElement(thePlayer) then 
            if id then 
                if cache[id] then 
                    dbExec(sql, "DELETE FROM gates WHERE id = ?", id)

                    cache[id]:destroy()
                    cache[id] = nil 

                    local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                    local serverHex = exports["cr_core"]:getServerColor("blue", true)

                    outputChatBox(syntax.."Sikeresen kitöröltél egy kaput. "..serverHex.."("..id..")", thePlayer, 255, 0, 0, true)
                    exports["cr_core"]:sendMessageToAdmin(thePlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(thePlayer, true)..white.." kitörölt egy kaput. "..serverHex.."("..id..")", 3)
                else
                    local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                    return outputChatBox(syntax.."Nem létezik ilyen kapu.", thePlayer, 255, 0, 0, true)
                end
            end
        end
    end
)