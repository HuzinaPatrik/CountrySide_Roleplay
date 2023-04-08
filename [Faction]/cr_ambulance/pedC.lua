local screenX, screenY = guiGetScreenSize()

local ambulancePedCache = {}

function createPeds()
    for i = 1, #ambulancePeds do
        local v = ambulancePeds[i]

        if v then
            local x, y, z, rx, ry, rz = unpack(v["position"])

            local ambulancePed = Ped(v["skinId"], x, y, z)
            ambulancePed:setData("ped.name", v["name"])
            ambulancePed:setData("ped.type", v["tag"])
            ambulancePed:setData("char >> noDamage", true)

            ambulancePed.interior = v["interior"]
            ambulancePed.dimension = v["dimension"]
            ambulancePed.rotation = Vector3(rx, ry, rz)
            ambulancePed.frozen = true

            ambulancePedCache[ambulancePed] = true
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, createPeds)

local alpha = 0
local price = 2500

local start = false;
local hoverAction = false
local clickedPed = false
local forcedClose = false

function renderHealPoint()
    local alpha, progress = exports["cr_dx"]:getFade("healPointPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderHealPoint")

                forcedClose = false
                clickedPed = false
            end
        end
    end

    if clickedPed and isElement(clickedPed) then 
        if getDistanceBetweenPoints3D(localPlayer.position, clickedPed.position) >= 3 or localPlayer:getData("char >> tazed") then 
            if not forcedClose then 
                forcedClose = true

                exports["cr_dx"]:startFade("healPointPanel", 
                    {
                        ["startTick"] = getTickCount(),
                        ["lastUpdateTick"] = getTickCount(),
                        ["time"] = 250,
                        ["animation"] = "InOutQuad",
                        ["from"] = 255,
                        ["to"] = 0,
                        ["alpha"] = 255,
                        ["progress"] = 0,
                    }
                )
            end
        end
    end

    hoverAction = nil

    local w, h = 425, 210
    local _w, _h = w, h
    local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
    local _x, _y = x, y

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    dxDrawImage(x + 10, y + 5, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	dxDrawText("Önellátás", x + 10 + 26 + 10,y+5,x+w,y+5+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    dxDrawImage(x + 30, y + 75, 100, 90, "assets/images/icon.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    dxDrawText("Megszeretnéd gyógyíttatni magadat?\nAz ellátásod #61b15a$" ..price..white.." dollárba fog kerülni.", x + 130, y + 65, x + w, y + 65, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, false, false, true)

    if exports['cr_core']:isInSlot(x + 175, y + 120, 200, 35) then 
        hoverAction = 2

        dxDrawRectangle(x + 175, y + 120, 200, 35, tocolor(97, 177, 90, alpha))
        dxDrawText("Ellátás", x + 175, y + 120, x + 175 + 200, y + 120 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
    else 
        dxDrawRectangle(x + 175, y + 120, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
        dxDrawText("Ellátás", x + 175, y + 120, x + 175 + 200, y + 120 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    end 

    if exports['cr_core']:isInSlot(x + 175, y + 160, 200, 35) then 
        hoverAction = 1

        dxDrawRectangle(x + 175, y + 160, 200, 35, tocolor(255, 59, 59, alpha))
        dxDrawText("Bezárás", x + 175, y + 160, x + 175 + 200, y + 160 + 35 + 4, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
    else 
        dxDrawRectangle(x + 175, y + 160, 200, 35, tocolor(255, 59, 59, alpha * 0.7))
        dxDrawText("Bezárás", x + 175, y + 160, x + 175 + 200, y + 160 + 35 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
    end 
end

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if start then 
                if hoverAction == 1 then 
                    start = false 

                    exports["cr_dx"]:startFade("healPointPanel", 
                        {
                            ["startTick"] = getTickCount(),
                            ["lastUpdateTick"] = getTickCount(),
                            ["time"] = 250,
                            ["animation"] = "InOutQuad",
                            ["from"] = 255,
                            ["to"] = 0,
                            ["alpha"] = 255,
                            ["progress"] = 0,
                        }
                    )

                    hoverAction = nil
                elseif hoverAction == 2 then
                    if exports["cr_core"]:takeMoney(localPlayer, price, false) then 
                        triggerLatentServerEvent("healPed >> giveHealth", 5000, false, localPlayer, localPlayer, 100)
                        localPlayer:setData("char >> bone", {true, true, true, true, true})
                        localPlayer:setData("bulletsInBody", {})
                        localPlayer:setData("bloodData", {})

                        triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 2, price) -- MEDIC MONEY GIVING

                        start = false 

                        exports["cr_dx"]:startFade("healPointPanel", 
                            {
                                ["startTick"] = getTickCount(),
                                ["lastUpdateTick"] = getTickCount(),
                                ["time"] = 250,
                                ["animation"] = "InOutQuad",
                                ["from"] = 255,
                                ["to"] = 0,
                                ["alpha"] = 255,
                                ["progress"] = 0,
                            }
                        )

                        exports["cr_infobox"]:addBox("success", "Sikeres gyógyítás!")
                    else
                        return exports["cr_infobox"]:addBox("error", "Nincs elég pénzed.")
                    end

                    hoverAction = nil
                end
            end
        end
    end
end

function onClick(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
    if state == "down" then 
        if clickedElement then 
            if ambulancePedCache[clickedElement] then 
                if getDistanceBetweenPoints3D(localPlayer.position, clickedElement.position) <= 3 then 
                    if not start then 
                        if exports["cr_network"]:getNetworkStatus() then 
                            return
                        end

                        if localPlayer:getData("char >> tazed") then 
                            return
                        end

                        if localPlayer.vehicle then 
                            return
                        end

                        local bone = localPlayer:getData("char >> bone") or {true, true, true, true, true}
                        if not bone[1] or not bone[2] or not bone[3] or not bone[4] or not bone[5] or localPlayer.health < 100 then 
                            clickedPed = clickedElement

                            createRender("renderHealPoint", renderHealPoint)

                            removeEventHandler("onClientKey", root, onKey)
                            addEventHandler("onClientKey", root, onKey)

                            exports["cr_dx"]:startFade("healPointPanel", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 0,
                                    ["to"] = 255,
                                    ["alpha"] = 0,
                                    ["progress"] = 0,
                                }
                            )

                            start = true
                        else 
                            return exports["cr_infobox"]:addBox("error", "Semmid sincs megsérülve!")
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)