local sql = exports.cr_mysql:getConnection(getThisResource())

addEventHandler("onResourceStart", root,
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then 
            sql = exports.cr_mysql:getConnection(getThisResource())
            restartResource(getThisResource())
        elseif startedRes == getThisResource() then 
            loadAllTerminal()
        end
    end
)

local availableTerminals = {}
local availableCameras = {}
local availableCameraCodes = {}

function generateCameraCode()
    local code = generateString(5)

    if availableCameraCodes[code] then 
        return generateCameraCode()
    end

    availableCameraCodes[code] = true
    return code
end

function loadTerminal(row)
    local id = tonumber(row.id)
    local position = split(row.position, ", ")

    local x, y, z = unpack(position)
    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)

    local createdAt = tonumber(row.createdAt)
    local createdBy = tostring(row.createdBy)
    local assigned_cameras = split(row.assigned_cameras, ", ")

    local terminalElement = Marker(x, y, z, "cylinder", 1.2, 124, 197, 118)

    terminalElement.interior = interior
    terminalElement.dimension = dimension

    terminalElement:setData("terminal >> id", id)

    terminalElement:setData("marker >> customMarker", true)
    terminalElement:setData("marker >> customIconPath", ":cr_cctv/files/images/cameraicon.png")

    availableTerminals[id] = {
        interior = interior,
        dimension = dimension,
        createdAt = createdAt,
        createdBy = createdBy,
        terminalElement = terminalElement,
        assignedCameras = {},
        cameraObjects = {}
    }

    if #assigned_cameras > 0 then 
        for i = 1, #assigned_cameras do 
            local v = assigned_cameras[i]

            if v ~= "false" then 
                table.insert(availableTerminals[id].assignedCameras, tonumber(v))
            end
        end
    end

    terminalElement:setData("terminal >> data", availableTerminals[id])
end

function loadAllTerminal()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadTerminal(row)
                    end,

                    function()
                        loadAllCamera()
                        outputDebugString("@loadAllTerminal: loaded " .. loaded .. " / " .. query_lines .. " terminal(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM cctv_terminals"
    )
end

function loadCamera(row)
    local id = tonumber(row.id)
    local model = tonumber(row.model)
    local position = split(row.position, ", ")
    local rotation = split(row.rotation, ", ")

    local interior = tonumber(row.interior)
    local dimension = tonumber(row.dimension)

    local createdAt = tonumber(row.createdAt)
    local createdBy = tonumber(row.createdBy)

    local terminal = tonumber(row.terminal)
    local code = tostring(row.code)

    local objectX, objectY, objectZ = unpack(position)
    local rotX, rotY, rotZ = unpack(rotation)

    local cameraElement = Object(model, objectX, objectY, objectZ, rotX, rotY, rotZ)
    
    cameraElement.interior = interior
    cameraElement.dimension = dimension

    cameraElement:setScale(cameraScale)
    cameraElement:setData("camera >> id", id)
    cameraElement:setData("camera >> terminalId", terminal)
    cameraElement:setData("camera >> code", code)

    availableCameras[id] = {
        interior = interior,
        dimension = dimension,
        createdAt = createdAt,
        createdBy = createdBy,
        code = code,
        terminal = terminal,
        cameraElement = cameraElement
    }

    if terminal and terminal > 0 then 
        if availableTerminals[terminal] and availableTerminals[terminal].cameraObjects then 
            table.insert(availableTerminals[terminal].cameraObjects, cameraElement)

            local terminalElement = availableTerminals[terminal].terminalElement

            if isElement(terminalElement) then 
                terminalElement:setData("terminal >> data", availableTerminals[terminal])
            end
        end
    end

    availableCameraCodes[code] = true
end

function loadAllCamera()
    local loaded = 0
    local startTick = getTickCount()

    dbQuery(
        function(queryHandle)
            local query, query_lines = dbPoll(queryHandle, 0)

            if query_lines > 0 then 
                Async:foreach(query,
                    function(row)
                        loaded = loaded + 1

                        loadCamera(row)
                    end,

                    function()
                        outputDebugString("@loadAllCamera: loaded " .. loaded .. " / " .. query_lines .. " camera(s) in " .. getTickCount() - startTick .. " ms.", 0, 255, 50, 255)
                    end
                )
            end
        end, sql, "SELECT * FROM cctv_cameras"
    )
end

function createCameraTrigger(data)
    if isElement(client) then 
        local model = cameraObjectId
        local concatenatedPosition = table.concat(data.position, ", ")
        local concatenatedRotation = table.concat(data.rotation, ", ")

        local interior = data.interior
        local dimension = data.dimension

        local createdAt = os.time()
        local createdBy = exports.cr_admin:getAdminName(client)
        local code = generateCameraCode()

        dbExec(sql, "INSERT INTO cctv_cameras SET model = ?, position = ?, rotation = ?, interior = ?, dimension = ?, createdAt = ?, createdBy = ?, code = ?", model, concatenatedPosition, concatenatedRotation, interior, dimension, createdAt, createdBy, code)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadCamera(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("CCTV", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztad a kamerát. " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)
                        outputChatBox(syntax .. "Kód: " .. hexColor .. row.code, thePlayer, 255, 0, 0, true)
                    end
                end
            end, {client}, sql, "SELECT * FROM cctv_cameras WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addEvent("cctv.createCamera", true)
addEventHandler("cctv.createCamera", root, createCameraTrigger)

function assignCameraToTerminal(terminalId, element)
    if isElement(client) and terminalId and isElement(element) then 
        local terminalData = availableTerminals[terminalId]

        if not terminalData then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nem létezik terminál ezzel az id-vel.", client, 255, 0, 0, true)
            return
        end

        local assignedCameras = terminalData.assignedCameras
        local cameraId = element:getData("camera >> id")

        table.insert(assignedCameras, cameraId)
        element:setData("camera >> terminalId", terminalId)

        local concatenatedCameras = table.concat(assignedCameras, ", ")

        dbExec(sql, "UPDATE cctv_terminals SET assigned_cameras = ? WHERE id = ?", concatenatedCameras, terminalId)
        dbExec(sql, "UPDATE cctv_cameras SET terminal = ? WHERE id = ?", terminalId, cameraId)

        availableCameras[cameraId].terminal = terminalId
        availableTerminals[terminalId].assignedCameras = assignedCameras

        if terminalId and terminalId > 0 then 
            if availableTerminals[terminalId] and availableTerminals[terminalId].cameraObjects then 
                table.insert(availableTerminals[terminalId].cameraObjects, element)
    
                local terminalElement = availableTerminals[terminalId].terminalElement
    
                if isElement(terminalElement) then 
                    terminalElement:setData("terminal >> data", availableTerminals[terminalId])
                end
            end
        end

        local syntax = exports.cr_core:getServerSyntax("CCTV", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen hozzárendelted a kamerát a(z) " .. hexColor .. terminalId .. white .. " id-vel rendelkező terminálhoz.", client, 255, 0, 0, true)
    end
end
addEvent("cctv.assignCameraToTerminal", true)
addEventHandler("cctv.assignCameraToTerminal", root, assignCameraToTerminal)

function removeCameraFromTerminal(terminalId, element)
    if isElement(client) and terminalId and isElement(element) then 
        local terminalData = availableTerminals[terminalId]

        if not terminalData then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nem létezik terminál ezzel az id-vel.", client, 255, 0, 0, true)
            return
        end

        local assignedCameras = terminalData.assignedCameras
        local cameraObjects = terminalData.cameraObjects
        local cameraId = element:getData("camera >> id")

        if not availableCameras[cameraId] then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nem létezik kamera ezzel az id-vel.", client, 255, 0, 0, true)
            return
        end

        for i = 1, #assignedCameras do 
            local v = assignedCameras[i]

            if v == cameraId then 
                table.remove(availableTerminals[terminalId].assignedCameras, i)
                break
            end
        end

        for i = 1, #cameraObjects do 
            local v = cameraObjects[i]

            if v == cameraElement then 
                table.remove(availableTerminals[terminalId].cameraObjects, i)
                break
            end
        end

        if terminalId and terminalId > 0 then 
            if availableTerminals[terminalId] then 
                local terminalElement = availableTerminals[terminalId].terminalElement
    
                if isElement(terminalElement) then 
                    terminalElement:setData("terminal >> data", availableTerminals[terminalId])
                end
            end
        end

        if isElement(availableCameras[cameraId].cameraElement) then 
            availableCameras[cameraId].cameraElement:setData("camera >> terminalId", 0)
        end

        local concatenatedCameras = table.concat(assignedCameras, ", ")

        dbExec(sql, "UPDATE cctv_terminals SET assigned_cameras = ? WHERE id = ?", concatenatedCameras, terminalId)
        dbExec(sql, "UPDATE cctv_cameras SET terminal = ? WHERE id = ?", 0, cameraId)

        local syntax = exports.cr_core:getServerSyntax("CCTV", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen eltávolítottad a kamerát a terminálból. " .. hexColor .. "(" .. cameraId .. ")", client, 255, 0, 0, true)
    end
end
addEvent("cctv.removeCameraFromTerminal", true)
addEventHandler("cctv.removeCameraFromTerminal", root, removeCameraFromTerminal)

function createTerminalCommand(thePlayer, cmd)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        local playerX, playerY, playerZ = getElementPosition(thePlayer)
        playerZ = playerZ - 1.15

        local concatenatedPosition = table.concat({playerX, playerY, playerZ}, ", ")
        local interior = thePlayer.interior
        local dimension = thePlayer.dimension

        local createdAt = os.time()
        local createdBy = exports.cr_admin:getAdminName(thePlayer, true)

        dbExec(sql, "INSERT INTO cctv_terminals SET position = ?, interior = ?, dimension = ?, createdAt = ?, createdBy = ?", concatenatedPosition, interior, dimension, createdAt, createdBy)

        dbQuery(
            function(queryHandle, thePlayer)
                local query, query_lines = dbPoll(queryHandle, 0)

                if query_lines > 0 then 
                    local row = query[1]

                    loadTerminal(row)

                    if isElement(thePlayer) then 
                        local syntax = exports.cr_core:getServerSyntax("CCTV", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        outputChatBox(syntax .. "Sikeresen létrehoztál egy terminált. " .. hexColor .. "(" .. row.id .. ")", thePlayer, 255, 0, 0, true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(thePlayer, true)

                        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " létrehozott egy terminált. " .. hexColor .. "(" .. row.id .. ")", 3)
                    end
                end
            end, {thePlayer}, sql, "SELECT * FROM cctv_terminals WHERE createdAt = ? AND id = LAST_INSERT_ID()", createdAt
        )
    end
end
addCommandHandler("createterminal", createTerminalCommand, false, false)

function deleteTerminalCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")
            
            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        local id = math.floor(tonumber(id))

        if not availableTerminals[id] then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nem létezik terminál ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        dbExec(sql, "DELETE FROM cctv_terminals WHERE id = ?", id)

        if isElement(availableTerminals[id].terminalElement) then 
            availableTerminals[id].terminalElement:destroy()
            availableTerminals[id].terminalElement = nil
        end

        for k, v in pairs(availableCameras) do 
            if v.terminal == id then 
                if isElement(v.cameraElement) then 
                    v.cameraElement:destroy()
                    v.cameraElement = nil
                end

                dbExec(sql, "DELETE FROM cctv_cameras WHERE id = ?", k)
                availableCameras[k] = nil
            end
        end

        availableTerminals[id] = nil

        local syntax = exports.cr_core:getServerSyntax("CCTV", "success")
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        outputChatBox(syntax .. "Sikeresen törölted a terminált. " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)

        local adminSyntax = exports.cr_admin:getAdminSyntax()
        local localName = exports.cr_admin:getAdminName(thePlayer, true)

        exports.cr_core:sendMessageToAdmin(thePlayer, adminSyntax .. hexColor .. localName .. white .. " kitörölt egy terminált. " .. hexColor .. "(" .. id .. ")", 3)
    end
end
addCommandHandler("deleteterminal", deleteTerminalCommand, false, false)
addCommandHandler("delterminal", deleteTerminalCommand, false, false)

function deleteCameraCommand(thePlayer, cmd, id)
    if exports.cr_permission:hasPermission(thePlayer, "deletecamera") then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [id]", thePlayer, 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Csak szám.", thePlayer, 255, 0, 0, true)
            return
        end

        if not availableCameras[id] then 
            local syntax = exports.cr_core:getServerSyntax("CCTV", "error")

            outputChatBox(syntax .. "Nem létezik kamera ezzel az id-vel.", thePlayer, 255, 0, 0, true)
            return
        end

        local data = availableCameras[id]

        if isElement(data.cameraElement) then 
            local terminalId = data.cameraElement:getData("camera >> terminalId")

            if availableTerminals[terminalId] then 
                local terminalElement = availableTerminals[terminalId].terminalElement
                local assignedCameras = availableTerminals[terminalId].assignedCameras
                local cameraObjects = availableTerminals[terminalId].cameraObjects

                for i = 1, #assignedCameras do 
                    local v = assignedCameras[i]

                    if v == id then 
                        table.remove(availableTerminals[terminalId].assignedCameras, i)
                        break
                    end
                end

                for i = 1, #cameraObjects do 
                    local v = cameraObjects[i]

                    if v == cameraElement then 
                        table.remove(availableTerminals[terminalId].cameraObjects, i)
                        break
                    end
                end

                data.cameraElement:destroy()
                availableCameras[id] = nil

                if isElement(terminalElement) then 
                    terminalElement:setData("terminal >> data", availableTerminals[terminalId])
                end
            else
                data.cameraElement:destroy()
                availableCameras[id] = nil
            end

            dbExec(sql, "DELETE FROM cctv_cameras WHERE id = ?", id)

            local syntax = exports.cr_core:getServerSyntax("CCTV", "success")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            outputChatBox(syntax .. "Sikeresen kitörölted a kamerát. " .. hexColor .. "(" .. id .. ")", thePlayer, 255, 0, 0, true)
        end
    end
end
addCommandHandler("deletecamera", deleteCameraCommand, false, false)