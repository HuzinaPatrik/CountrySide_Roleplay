local positions = {
    --{Vector(x,y,z),Vector(dim,int)},
    {Vector3(209.54410522461, -258.20727539062, -6.621875), Vector3(0, 0)},
    {Vector3(154.1012878418, -241.40918579102, -6.621875), Vector3(0, 0)},
}

local elementCache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(positions) do
            local pos, pos2 = unpack(v)
            local mark = Marker(pos, "cylinder", 2, 255, 0, 0)

            mark:setData("marker >> customMarker", true)
            mark:setData("marker >> customIconPath", ":cr_mechanic/files/images/deletecomponent.png")

            mark.interior = pos2.y
            mark.dimension = pos2.x
            elementCache[mark] = true
        end
    end
)

addEventHandler("onClientMarkerHit", resourceRoot,
    function(hitPlayer, matchingDimension)
        if elementCache[source] then
            if hitPlayer == localPlayer and matchingDimension and doingState then
                if gVeh and isElement(gVeh) and gVeh:getData(doingState.."->parent") and isElement(gVeh:getData(doingState.."->parent")) then
                    if doingState then
                        local element = gVeh:getData(doingState.."->parent")
                        local k = doingState
                        --local k = gVeh:getData("hide")
                        if k then
                            gVeh:setData(k.."->hide", 1)
                            triggerServerEvent("destroyClonedVehicle", localPlayer, localPlayer, gVeh, k)
                            onControls()
                            setElementData(localPlayer, "forceAnimation", {"", ""})
                            triggerServerEvent("removeAnimation", localPlayer, localPlayer)
                            doingState = nil
                            gVeh:setData(k.."->doing", false)
                            gVeh:setData(k.."->parent", nil)
                            gVeh = nil
                            
                            local syntax = exports['cr_core']:getServerSyntax("Mechanic", "success")
                            outputChatBox(syntax .. "Sikeresen törölted az alkatrészt!",255,255,255,true)
                        end
                    end
                end
            end
        end
    end
)