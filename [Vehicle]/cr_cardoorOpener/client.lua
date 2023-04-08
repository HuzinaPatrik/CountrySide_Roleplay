local components = {
    --[Component Name] = {{x,y,z - offset}}
    ["bonnet_dummy"] = {0,0,0, "y"},
    ["boot_dummy"] = {0,0,0, "y2"},
    ["drovnik_dummy"] = {0,1.5,0},
    ["door_lf_dummy"] = {0,-1,0},
    ["door_rf_dummy"] = {0,-1,0},
    ["door_rr_dummy2"] = {0,-1,0},
    ["door_lr_dummy2"] = {0,-1,0},
    ["door_rr_dummy"] = {-0.5,0,0},
    ["door_lr_dummy"] = {0.5,0,0},
}

local componentDetails = {
    --[Compoent Name] = {DoorID, IcOutput}
    ["bonnet_dummy"] = {0, "motorháztetőt"},
    ["drovnik_dummy"] = {0, "motorháztetőt"},
    ["boot_dummy"] = {1, "csomagtartót"},
    ["door_lf_dummy"] = {2, "bal első ajtót"},
    ["door_rf_dummy"] = {3, "jobb első ajtót"},
    ["door_lr_dummy"] = {4, "bal hátsó ajtót"},
    ["door_rr_dummy"] = {5, "jobb hátsó ajtót"},
}

--[[
addEventHandler("onClientRender", root,
    function()
        for k,v in pairs(getElementsByType("vehicle", _, true)) do
            local rot = v.rotation
            for k2,v2 in pairs(components) do
                k2 = k2:gsub("2", "")
                --outputChatBox(tostring(v))
                local x,y,z = getVehicleComponentPosition(v, k2, "world")
                if x then
                    local sx,sy = getScreenFromWorldPosition(x,y,z)
                    if sx and sy then
                        --dxDrawRectangle(sx - 30, sy - 30, 30, 30)
                        local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(v)
                        local offsets = v2
                        if offsets[4] then
                            x,y,z = getElementPosition(v)
                            if offsets[4] == "y" then
                                offsets[2] = (math.abs(y0)) + offsets[1]
                            elseif offsets[4] == "y2" then
                                offsets[2] = -(math.abs(y0))
                            end
                            --offsets[4] = nil
                        end
                        local vehMatrix = Matrix(x,y,z, rot)
                        local pos = vehMatrix:transformPosition(unpack(offsets))
                        dxDrawLine3D(x,y,z, pos)
                        
                        --Jobb klikkel kinyitom az ajtót genyót gyorsba megírom, utána meg a kocsi kerék kaparást, utána meg az mdc-t optimizálom.
                    end
                end
            end
        end
    end
)]]

local maxDist = 16

function getNearestVehicle()
    local pos = localPlayer.position
    local nearest = 9999
    local nearestE
    for k,v in pairs(getElementsByType("vehicle", _, true)) do
        local pos2 = v.position
        --pos2.z = pos.z
        local dist = getDistanceBetweenPoints3D(pos, pos2)
        if dist <= maxDist then
            if not v.locked then
                --outputChatBox(dist)
                --outputChatBox(nearest)
                if dist <= nearest then
                    nearest = dist
                    nearestE = v
                end
            end
        end
    end
    
    return nearestE
end

local maxDist2 = 0.75

function getNearestComponent()
    local veh = getNearestVehicle()
    local nearest = 9999
    local nearestE
    
    if veh then
        local pos = localPlayer.position
        local rot = veh.rotation
        for k,v in pairs(components) do
            k = k:gsub("2", "")
            local x,y,z = getVehicleComponentPosition(veh, k, "world")
            if x then
                local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(veh)
                local offsets = v
                if offsets[4] then
                    x,y,z = getElementPosition(veh)
                    if offsets[4] == "y" then
                        offsets[2] = (math.abs(y0)) + offsets[1]
                    elseif offsets[4] == "y2" then
                        offsets[2] = -(math.abs(y0))
                    end
                    --offsets[4] = nil
                end
                local vehMatrix = Matrix(x,y,z, rot)
                local pos2 = vehMatrix:transformPosition(unpack(offsets))
                pos2.z = pos.z
                local dist = getDistanceBetweenPoints3D(pos, pos2)
                --dxDrawLine3D(pos2, pos)
                --outputChatBox(dist)
                if dist <= maxDist2 then
                    if dist <= nearest then
                        nearest = dist
                        nearestE = k
                    end
                end
            end
        end
    end
    
    return nearestE, veh
end

lastClickTick = -500
function interactVeh()
    if lastClickTick + 500 >= getTickCount() then 
        return 
    end
    lastClickTick = getTickCount()

    if getPedWeapon(localPlayer) ~= 0 then return end
    if isCursorShowing() then return end
    if not getPedOccupiedVehicle(localPlayer) then
        local nearestComponent, vehicle = getNearestComponent()
        --outputChatBox(tostring(nearestComponent))
        if nearestComponent and vehicle then
            local door, text = unpack(componentDetails[nearestComponent])

            if nearestComponent == "boot_dummy" then 
                if not vehicle:getData("veh >> boot") then return end 
            end 

            local forceAnimation = getElementData(localPlayer, "forceAnimation") or {"", ""}
            if forceAnimation[1] ~= "" or forceAnimation[2] ~= "" then
                return
            end
            
            local newState = getVehicleDoorOpenRatio(vehicle, door)
            newState = newState - 1
            --outputChatBox(newState)
            if newState < 0 then 
                newState = 1 
            end
            
            --vehicle:setDoorOpenRatio(not newState)
            triggerServerEvent("changeDoorState2", localPlayer, vehicle, {door, newState})
            
            if newState == 1 then
                playSound("files/dooropen.mp3")
            else
                playSound("files/doorclose.mp3")
            end
        end
    end
end
bindKey("mouse2", "down", interactVeh)