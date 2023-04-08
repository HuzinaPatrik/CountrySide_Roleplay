local reasons = {
    ["Unknown"] = "Ismeretlen",
    ["Quit"] = "Kilépett",
    ["Kicked"] = "Kirúgva",
    ["Banned"] = "Kitiltva",
    ["Bad Connection"] = "Rossz kapcsolat",
    ["Timed out"] = "Időtúllépés",
}

local maxDist = 80

addEventHandler("onClientPlayerQuit", root,
    function(reason)
        local x1, y1, z1 = getElementPosition(localPlayer)
        local x2, y2, z2 = getElementPosition(source)
        local dim1 = getElementDimension(localPlayer)
        local dim2 = getElementDimension(source)
        if dim1 ~= dim2 then return end
        local int1 = getElementInterior(localPlayer)
        local int2 = getElementInterior(source)
        if int1 ~= int2 then return end
        local dist = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)

        if dist <= maxDist then
            local name = exports['cr_admin']:getAdminName(source)

            local reason = reasons[reason]
            if not reason then
                reason = "Időtúllépés"
            end

            local low = exports['cr_core']:getServerSyntax("Quit", "warning")
            local red = exports['cr_core']:getServerColor("red", true)
            local white = "#f2f2f2"
            if reason == "Kicked" and getElementData(source, "specialKick") then
                if tostring(getElementData(source, "specialKickReason") or "") == "Floodolás" or tostring(getElementData(source, "specialKickReason") or "") == "Floodolás miatt!" then
                    outputChatBox(low .. name.." "..red.."kilépett"..white.." a közeledben ("..red..math.floor(dist)..white.." yard) ["..red..reason" - Floodolás miatt"..white.."]", 255,255,255,true)

                    local time = exports['cr_core']:getTime()
                    exports['cr_core']:add3DText(name, 
                        {
                            ['text'] = time .. ' ' .. name.." "..red.."kilépett"..white.." a közeledben ["..red..reason" - Floodolás miatt"..white.."]",
                            ['color'] = {242, 242, 242},
                            ['position'] = {x2, y2, z2, dim2, int2},
                            ['maxDistance'] = maxDist,
                            ['fadeWithDistance'] = true, 
                            ['checkSightLine'] = true,
                            ['fontDetails'] = {'Poppins-Medium', 12, 1},
                            ['background'] = {51, 51, 51, 0.8},
                        }
                    )

                    setTimer(
                        function(id)
                            exports['cr_core']:delete3DText(id)
                        end, 5 * 60 * 1000, 1, name
                    )
                end
            else
                outputChatBox(low .. name.." "..red.."kilépett"..white.." a közeledben ("..red..math.floor(dist)..white.." yard) ["..red..reason..white.."]", 255,255,255,true)

                local time = exports['cr_core']:getTime()
                exports['cr_core']:add3DText(name, 
                    {
                        ['text'] = time .. ' ' .. name.." "..red.."kilépett"..white.." a közeledben ["..red..reason..white.."]",
                        ['color'] = {242, 242, 242},
                        ['position'] = {x2, y2, z2, dim2, int2},
                        ['maxDistance'] = maxDist,
                        ['fadeWithDistance'] = true, 
                        ['checkSightLine'] = true,
                        ['fontDetails'] = {'Poppins-Medium', 12, 1},
                        ['background'] = {51, 51, 51, 0.8},
                    }
                )

                setTimer(
                    function(id)
                        exports['cr_core']:delete3DText(id)
                    end, 5 * 60 * 1000, 1, name
                )
            end
        end
    end
)