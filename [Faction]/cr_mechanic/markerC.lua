local positions = {
    --{Vector(x,y,z),Vector(dim,int)},
    {Vector3(209.54410522461, -248.88467407227, -6.621875), Vector3(0, 0)},
    {Vector3(153.71076965332, -247.65684509277, -6.621875), Vector3(0, 0)},
}

local elementCache = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(positions) do
            local pos, pos2 = unpack(v)
            local mark = Marker(pos, "cylinder", 2, 255, 255, 0)

            mark:setData("marker >> customMarker", true)
            mark:setData("marker >> customIconPath", ":cr_mechanic/files/images/fixcomponent.png")

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
                        local k = doingState -- gVeh:getData("hide")
                        --outputChatBox(k)
                        if isComponentDamaged(element, k) then
                            local convertData = getConvertData(element, k)
                            --convertData[1] = 

                            setElementData(localPlayer, "forceAnimation", {"SP", "SP"})
                            triggerServerEvent("applyAnimation", localPlayer, localPlayer, "CARRY", "crry_prtial", 0, true, false, false)
                            offControls()
                            --Innen folytatom: jobb oldalra még rakd be, hogy olajszint megvizsgálása
                            triggerServerEvent("fixVehicleComponent", localPlayer, element, convertData)

                            triggerServerEvent("applyAnimation", localPlayer, localPlayer, "MISC", "pickup_box")
                            setElementData(localPlayer, "forceAnimation", {"MISC", "pickup_box"})
                            if element.alpha <= 255 then
                                triggerServerEvent("toggleAlpha", localPlayer, localPlayer, element, 255)
                            end
                            --setPedAnimation(localPlayer, "MISC", "pickup_box")
                            setTimer(
                                function()
                                    setElementData(localPlayer, "forceAnimation", {"", ""})
                                    setElementData(localPlayer, "forceAnimation", {"SP", "SP"})
                                end, 300, 1
                            )

                            local syntax = exports['cr_core']:getServerSyntax("Mechanic", "success")
                            outputChatBox(syntax .. "Sikeresen megjavítottad az alkatrészt!",255,255,255,true)
                        else
                            local syntax = exports['cr_core']:getServerSyntax("Mechanic", "error")
                            outputChatBox(syntax .. "Ez az alkatrész nem törött!",255,255,255,true)
                        end
                    end
                end
            end
        end
    end
)