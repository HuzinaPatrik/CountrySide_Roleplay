local screenX, screenY = guiGetScreenSize()

local editState = false

local collision = false
local hikerPed = false

local colWidth, colDepth, colHeight = 7, 3, 2

local cache = {}

function createHitchHiker(cmd)
    if exports["cr_permission"]:hasPermission(localPlayer, cmd) then 
        if not editState then 
            processEditor("init")
        else
            processEditor("exit")
        end
    end
end
addCommandHandler("createhiker", createHitchHiker, false, false)

function processEditor(state)
    if state == "init" then 
        editState = true

        setDevelopmentMode(true)

        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
        local serverHex = exports["cr_core"]:getServerColor("blue", true)

        outputChatBox(syntax.."Stoppos létrehozás bekapcsolva! Ahhoz hogy lásd a collision-öket használd a "..serverHex.."/showcol"..white.." parancsot.", 255, 0, 0, true)
        outputChatBox(syntax.."A stoppos collision-jét egy zöld téglalap jelzi, a lerakásához használd a "..serverHex.."/finishcol"..white.." parancsot.", 255, 0, 0, true)
        outputChatBox(syntax.."Az npc lerakásához használd a "..serverHex.."/placehiker"..white.." parancsot.", 255, 0, 0, true)
        outputChatBox(syntax.."A szerkesztés véglegesítéséhez használd a "..serverHex.."/finishedit"..white.." parancsot.", 255, 0, 0, true)

        local playerPoint = localPlayer.position
        local colPoint = Vector3(playerPoint.x, playerPoint.y, playerPoint.z)

        collision = createColCuboid(playerPoint, colWidth, colDepth, colHeight)

        collision:attach(localPlayer, 0, 0, -1)

        addCommandHandler("finishcol", finishColCommand, false, false)
        addCommandHandler("placehiker", placeHikerCommand, false, false)
        addCommandHandler("finishedit", finishEditCommand, false, false)
    elseif state == "exit" then 
        editState = false

        setDevelopmentMode(false)

        local syntax = exports["cr_core"]:getServerSyntax(false, "error")
        local serverHex = exports["cr_core"]:getServerColor("blue", true)

        if isElement(collision) then 
            collision:detach()
            collision:destroy()

            collision = nil
        end

        if isElement(hikerPed) then 
            hikerPed:destroy()

            hikerPed = nil
        end

        removeCommandHandler("finishcol", finishColCommand)
        removeCommandHandler("placehiker", placeHikerCommand)
        removeCommandHandler("finishedit", finishEditCommand)

        collectgarbage("collect")

        outputChatBox(syntax.."Stoppos létrehozás kikapcsolva.", 255, 0, 0, true)
    end
end

function finishColCommand()
    if editState then 
        if isElement(collision) then 
            collision:detach()

            local syntax = exports["cr_core"]:getServerSyntax(false, "success")
            outputChatBox(syntax.."Collision sikeresen lehelyezve.", 255, 0, 0, true)
        end
    end
end

function placeHikerCommand(cmd, skinId, ...)
    if editState then 
        if not skinId or not ... then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [skinid] [név]", 255, 0, 0, true)

            return
        else
            local skinId = tonumber(skinId)
            local name = table.concat({...}, " ")

            if skinId ~= nil then 
                skinId = math.floor(skinId)

                if skinId > 0 then 
                    local pedPoint = localPlayer.position

                    hikerPed = Ped(skinId, pedPoint)

                    if hikerPed and isElement(hikerPed) then 
                        hikerPed.interior = localPlayer.interior
                        hikerPed.dimension = localPlayer.dimension
                        hikerPed.rotation = localPlayer.rotation
                        hikerPed.frozen = true

                        hikerPed:setData("ped.name", name)
                        hikerPed:setData("ped.type", "Stoppos")

                        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                        outputChatBox(syntax.."Stoppos npc sikeresen lehelyezve.", 255, 0, 0, true)
                    end
                else
                    local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                    outputChatBox(syntax.."A skinId-nek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
                end
            else
                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
            end
        end
    end
end

function finishEditCommand()
    if editState then 
        if not isElement(collision) or collision:isAttached() then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem tudod véglegesíteni a szerkesztést ha nincs lerakva a collision.", 255, 0, 0, true)

            return
        end

        if not isElement(hikerPed) then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nem tudod véglegesíteni a szerkesztést ha nincs lerakva a stoppos npc.", 255, 0, 0, true)

            return
        end

        local pedPoint = hikerPed.position
        local pedX, pedY, pedZ = pedPoint.x, pedPoint.y, pedPoint.z

        local pedRotation = hikerPed.rotation
        local pedRx, pedRy, pedRz = pedRotation.x, pedRotation.y, pedRotation.z

        local pedInterior, pedDimension = hikerPed.interior, hikerPed.dimension
        local pedSkin = hikerPed.model
        local pedName = hikerPed:getData("ped.name")

        local pedData = {pedX, pedY, pedZ, pedRx, pedRy, pedRz, pedInterior, pedDimension, pedSkin, pedName}

        local colPoint = collision.position
        local colX, colY, colZ = colPoint.x, colPoint.y, colPoint.z

        local colInterior, colDimension = collision.interior, collision.dimension

        local colData = {colX, colY, colZ, colWidth, colDepth, colHeight, colInterior, colDimension}

        triggerLatentServerEvent("hiker.createHiker", 5000, false, localPlayer, localPlayer, pedData, colData)

        processEditor("exit")
    end
end

function deleteHiker(cmd, id)
    if exports["cr_permission"]:hasPermission(localPlayer, "deletehiker") then 
        if not id then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [id]", 255, 0, 0, true)
        else
            local id = tonumber(id)

            if id ~= nil then 
                id = math.floor(id)

                if id > 0 then 
                    triggerLatentServerEvent("hiker.deleteHiker", 5000, false, localPlayer, localPlayer, id)
                else
                    local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                    outputChatBox(syntax.."Az id-nek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
                end
            else
                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("deletehiker", deleteHiker, false, false)
addCommandHandler("delhiker", deleteHiker, false, false)

function getNearbyHikers(cmd)
    if exports["cr_permission"]:hasPermission(localPlayer, cmd) then 
        local count = 0
        local peds = getElementsByType("ped", resourceRoot)

        local syntax = exports["cr_core"]:getServerSyntax(false, "info")
        local serverHex = exports["cr_core"]:getServerColor("yellow", true)
        for i = 1, #peds do 
            local v = peds[i]

            if v then 
                local id = v:getData("hiker >> id")

                if id and id > 0 then 
                    local name = v:getData("ped.name")
                    local createdBy = v:getData("hiker >> createdBy")
                    local createDate = v:getData("hiker >> createDate")
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, v.position)

                    if distance <= 15 then 
                        count = count + 1

                        outputChatBox(syntax.."ID: "..serverHex..id..white.." | Név: "..serverHex..name..white.." | Létrehozta: "..serverHex..createdBy..white.." | Mikor: "..serverHex..createDate:gsub("-", "."), 255, 0, 0, true)
                    end
                end
            end
        end

        if count == 0 then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
            outputChatBox(syntax.."Nincs 15 yardos körzetben stoppos npc.", 255, 0, 0, true)

            return
        end
    end
end
addCommandHandler("nearbyhikers", getNearbyHikers, false, false)

local alpha = 0
local sourceCollision = false
local isRender = false

function processInteractionPanel(state)
    if state == "init" then 
        isRender = true

        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local text = "#ffffffA stoppos felvételéhez nyomd meg az '".. hexColor .. "E#ffffff' gombot."
        exports.cr_dx:startInfoBar(text)
        -- createRender("renderInteraction", renderInteraction)

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)

        -- exports["cr_dx"]:startFade("hitchHikerPanel", 
        --     {
        --         ["startTick"] = getTickCount(),
        --         ["lastUpdateTick"] = getTickCount(),
        --         ["time"] = 250,
        --         ["animation"] = "InOutQuad",
        --         ["from"] = 0,
        --         ["to"] = 255,
        --         ["alpha"] = 0,
        --         ["progress"] = 0,
        --     }
        -- )
    elseif state == "exit" then 
        isRender = false
        removeEventHandler("onClientKey", root, onKey)

        exports.cr_dx:closeInfoBar()
        -- exports["cr_dx"]:startFade("hitchHikerPanel", 
        --     {
        --         ["startTick"] = getTickCount(),
        --         ["lastUpdateTick"] = getTickCount(),
        --         ["time"] = 250,
        --         ["animation"] = "InOutQuad",
        --         ["from"] = 255,
        --         ["to"] = 0,
        --         ["alpha"] = 255,
        --         ["progress"] = 0,
        --     }
        -- )
    end
end

function renderInteraction()
    local alpha, progress = exports["cr_dx"]:getFade("hitchHikerPanel")
    -- if alpha and progress then 
    --     if progress >= 1 then 
    --         if alpha <= 0 then 
    --             destroyRender("renderInteraction")
    --             collectgarbage("collect")
    --         end
    --     end
    -- end

    local font = exports["cr_fonts"]:getFont("Roboto", 11)

    local serverHex = exports["cr_core"]:getServerColor("blue", true)
    local text = "#9c9c9cA stoppos felvételéhez nyomd meg az '"..serverHex.."E#9c9c9c' gombot."

    local w = dxGetTextWidth(text, 1, font, true) + 20
    local h = dxGetFontHeight(1, font) + 10

    local x, y = exports["cr_interface"]:getNode("Actionbar", "x"), exports["cr_interface"]:getNode("Actionbar", "y")
    local acType = exports["cr_interface"]:getNode("Actionbar", "type")

    if acType == 1 then 
        x, y = x - w / 6, y - h - 5
    elseif acType == 2 then
        x, y = x - w / 2 + w / 14, y - h - 5
    end

    dxDrawOuterBorder(x, y, w, h, 2, tocolor(30, 30, 30, math.min(alpha, 255 - 135)))
    dxDrawRectangle(x, y, w, h, tocolor(30, 30, 30, math.min(alpha, 255 - 25)))

    dxDrawText(text, x, y, x + w, y + h, tocolor(130, 130, 130, alpha), 1, font, "center", "center", false, false, false, true)
end

function getFreeSeat(vehicle)
    local result = false

    local maxPassengers = vehicle:getMaxPassengers()

    for i = 0, maxPassengers do 
        local occupant = vehicle:getOccupant(i)

        if not occupant then 
            result = i
            break
        end
    end

    return result
end

function hasHitchHiker(vehicle)
    local result = false

    local occupants = vehicle:getOccupants()

    for k, v in pairs(occupants) do 
        if v:getData("hiker >> id") then 
            result = k
            break
        end
    end

    return result
end

function onKey(button, state)
    if isRender then 
        if button == "e" then 
            if state then 
                cancelEvent()

                local vehicle = localPlayer.vehicle
                -- local occupants = vehicle:getOccupants()

                -- local count = 0
                -- for k, v in pairs(occupants) do 
                --     count = count + 1
                -- end

                -- local maxPassengers = vehicle:getMaxPassengers()
                
                -- if count + 1 < maxPassengers then 
                    if sourceCollision and isElement(sourceCollision) then 
                        local ped = sourceCollision:getData("pedParent")
                        local seat = getFreeSeat(vehicle)

                        if seat then 
                            if localPlayer.vehicleSeat == 0 then 
                                if ped and isElement(ped) then 
                                    if hasHitchHiker(vehicle) then 
                                        local syntax = exports.cr_core:getServerSyntax(false, "error")

                                        outputChatBox(syntax .. "Csak egy stoppost vihetsz.", 255, 0, 0, true)
                                        return
                                    end

                                    local id = ped:getData("hiker >> id")
                                    local name = ped:getData("ped.name")

                                    if not ped:isInVehicle() then 
                                        triggerLatentServerEvent("hiker.warpHikerIntoVehicle", 5000, false, localPlayer, localPlayer, ped, vehicle, seat)

                                        generateRandomWay(ped, name)
                                        processInteractionPanel("exit")
                                    end
                                end
                            else
                                local syntax = exports.cr_core:getServerSyntax(false, "error")

                                outputChatBox(syntax .. "Csak a sofőr ülésről vehetsz fel stoppost.", 255, 0, 0, true)
                            end
                        else
                            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                            outputChatBox(syntax.."A járműben nincs szabad ülés ahova a stoppos le tudna ülni.", 255, 0, 0, true)
                        end
                    end
                -- else
                --     local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                --     outputChatBox(syntax.."A járműben nincs szabad ülés ahova a stoppos le tudna ülni.", 255, 0, 0, true)
                -- end
            end
        end
    end
end

addEventHandler("onClientColShapeHit", root,
    function(hitElement, mDim)
        if hitElement == localPlayer then 
            if mDim then 
                local parent = source:getData("pedParent")

                if parent and isElement(parent) then 
                    if not isRender then 
                        if localPlayer:isInVehicle() then 
                            if not parent:isInVehicle() then 
                                processInteractionPanel("init")

                                sourceCollision = source
                            end
                        end
                    end
                end
            end
        end
    end
)

addEventHandler("onClientColShapeLeave", root,
    function(hitElement, mDim)
        if hitElement == localPlayer then 
            if mDim then 
                local parent = source:getData("pedParent")

                if parent and isElement(parent) then 
                    if isRender then 
                        processInteractionPanel("exit")

                        sourceCollision = nil
                    end
                end
            end
        end
    end
)

function generateRandomWay(ped, name)
    local id = ped:getData("hiker >> id")
    local randomValue = math.random(1, #hikerPositions)

    local x, y, z = unpack(hikerPositions[randomValue]["position"])
    local interior, dimension = hikerPositions[randomValue]["interior"], hikerPositions[randomValue]["dimension"]

    local markerPoint = Vector3(x, y, z)
    local r, g, b = exports["cr_core"]:getServerColor("green", false)

    local marker = Marker(markerPoint, "checkpoint", 1.5, r, g, b)
    marker:setData("hiker >> markerId", id)

    local zoneName = getZoneName(x, y, z)
    local blipName = "Stoppos - "..zoneName.." ("..name:gsub("_", " ")..")"

    exports["cr_radar"]:createStayBlip(blipName, Blip(markerPoint, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, r, g, b)

    cache[id] = {ped, blipName, name}

    local greeting = "Jónapot"
    local rt = getRealTime()

    if rt["hour"] >= 19 then 
        greeting = "Jóestét"
    end

    outputChatBox(name:gsub("_", " ").." mondja: "..greeting..", "..zoneName.." felé megyek, megköszönném ha elvinne.", 255, 255, 255)

    addEventHandler("onClientMarkerHit", marker,    
        function(hitElement, mDim)
            if hitElement == localPlayer then 
                if mDim then 
                    local id = source:getData("hiker >> markerId")
                    local vehicle = localPlayer.vehicle

                    if id and id > 0 and vehicle and vehicle == ped.vehicle then 
                        local hiker, blipName, name = unpack(cache[id])

                        exports["cr_radar"]:destroyStayBlip(blipName)
                        source:destroy()

                        outputChatBox(name:gsub("_", " ").." mondja: Köszönöm hogy elvitt, itt van egy kis borravaló.", 255, 255, 255, true)

                        local randomMoney = math.random(50, 200)
                        exports["cr_core"]:giveMoney(localPlayer, randomMoney, false)

                        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                        local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                        outputChatBox(syntax.."A stoppos "..serverHex..randomMoney..white.." dollárt adott neked a fuvarért.", 255, 0, 0, true)

                        triggerLatentServerEvent("hiker.resetHikerPosition", 5000, false, localPlayer, hiker, id, localPlayer.vehicle)

                        collectgarbage("collect")
                    end
                end
            end
        end
    )
end

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end