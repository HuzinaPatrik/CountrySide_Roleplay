addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(markers) do 
            local x,y,z,dim,int,pedPosition = unpack(v)
            local marker = Marker(x, y, z, "cylinder", 1.5, 255, 59, 59)
            marker.interior = int 
            marker.dimension = dim
            marker:setData("skinshop >> id", k)
            marker:setData("skinshop >> pedPosition", pedPosition)
            marker:setData("marker >> customMarker", true)
            marker:setData("marker >> customIconPath", ":cr_skinshop/assets/images/icon.png")
        end 
    end 
)

local protectedSkins = {
    [0] = true,
}

local skins = {}

function leftMove()
    if isBuyRender then 
        buyUp()
    else
        now = math.max(1, now - 1)
        gPed:setData("ped >> skin", skins[now])
    end 
end 

function rightMove()
    if isBuyRender then 
        buyDown()
    else 
        now = math.min(#skins, now + 1)
        gPed:setData("ped >> skin", skins[now])
    end 
end 

function upMove()
    --[[
    if isBuyRender then 
        buyUp()
    end ]]
end 

function downMove()
    --[[
    if isBuyRender then 
        buyDown()
    end ]]
end

local tuningPrice = {50, 50, 5}

function enterInteraction()
    if isBuyRender then 
        buyEnter()
    elseif isRender then 
        createBuy({
            ["tuningName"] = "Kinézet",
            ["tuningType"] = "skin",
            ["tuningPrice"] = tuningPrice,
            ["nextLevel"] = skins[now],
            ["onEnter"] = function(type)
                if type == 1 then 
                    if tuningPrice[1] == 0 or exports['cr_core']:takeMoney(localPlayer, tuningPrice[1]) then 
                        localPlayer:setData("char >> skin", buyCache["nextLevel"])

                        if localPlayer:getData("char >> dutyskin") then 
                            localPlayer:setData("char >> dutyskin", buyCache["nextLevel"])
                        end

                        exports['cr_infobox']:addBox("success", "Sikeres vásárlás!")
                        
                        destroyBuy()
                        closeSkinShop()
                    else 
                        exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                    end 
                elseif type == 2 then 
                    if tuningPrice[2] == 0 or exports['cr_core']:takeMoney(localPlayer, tuningPrice[2], true) then 
                        localPlayer:setData("char >> skin", buyCache["nextLevel"])

                        if localPlayer:getData("char >> dutyskin") then 
                            localPlayer:setData("char >> dutyskin", buyCache["nextLevel"])
                        end

                        exports['cr_infobox']:addBox("success", "Sikeres vásárlás!")
                        
                        destroyBuy()
                        closeSkinShop()
                    else 
                        exports['cr_infobox']:addBox("error", "Nincs elég pénzed a bankkártyán!")
                    end 
                elseif type == 3 then 
                    if tuningPrice[3] == 0 or localPlayer:getData("char >> premiumPoints") >= tuningPrice[3] then 
                        localPlayer:setData("char >> premiumPoints", localPlayer:getData("char >> premiumPoints") - tuningPrice[3])
                        localPlayer:setData("char >> skin", buyCache["nextLevel"])

                        if localPlayer:getData("char >> dutyskin") then 
                            localPlayer:setData("char >> dutyskin", buyCache["nextLevel"])
                        end

                        exports['cr_infobox']:addBox("success", "Sikeres vásárlás!")
                        
                        destroyBuy()
                        closeSkinShop()
                    else 
                        exports['cr_infobox']:addBox("error", "Nincs elég pp-d!")
                    end 
                end 
            end 
        })
    end 
end 

addEventHandler("onClientMarkerHit", root, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension and not localPlayer.vehicle then 
            if source:getData("skinshop >> id") then 
                if getDistanceBetweenPoints3D(source.position, localPlayer.position) <= 3 then 
                    if not isRender then 
                        isRender = true 
                        bindKey("backspace", "down", closeSkinShop)
                        bindKey("arrow_l", "down", leftMove)
                        bindKey("arrow_r", "down", rightMove)
                        bindKey("enter", "down", enterInteraction)
                        bindKey("arrow_u", "down", upMove)
                        bindKey("arrow_d", "down", downMove)

                        exports['cr_dx']:startFade("skinshop >> panel", 
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

                        createRender("drawnSkinShop", drawnSkinShop)

                        oDatas = {
                            ["hudVisible"] = localPlayer:getData("hudVisible"),
                            ["keysDenied"] = localPlayer:getData("keysDenied"),
                            ["isChatVisible"] = exports['cr_custom-chat']:isChatVisible(),
                            ["frozen"] = localPlayer.frozen,
                        }

                        localPlayer.frozen = true
                        localPlayer:setData("hudVisible", false)
                        localPlayer:setData("keysDenied", true)
                        exports['cr_custom-chat']:showChat(false)

                        local x,y,z,rot = unpack(source:getData("skinshop >> pedPosition"))
                        local a = localPlayer:getData("char >> details")
                        local nationality = a["nationality"]
                        local typ = a["neme"]
                        local data = exports['cr_skinprotection']:getAvailableSkins(nationality, typ)

                        skins = {}
                        for k,v in ipairs(data) do 
                            if not protectedSkins[v] then 
                                table.insert(skins, v)
                            end 
                        end 
                        now = 1 

                        setupViewer(Vector3(x,y,z))
                        cameraInit(true)

                        gPed = Ped(107, x,y,z)
                        gPed:setData("ped >> skin", skins[now])
                        gPed.interior = source.interior 
                        gPed.dimension = source.dimension 
                    end 
                end 
            end 
        end 
    end 
)

function closeSkinShop()
    if isBuyRender then 
        destroyBuy()
    elseif isRender then 
        isRender = false 
        unbindKey("backspace", "down", closeSkinShop)        
        unbindKey("arrow_l", "down", leftMove)
        unbindKey("arrow_r", "down", rightMove)
        unbindKey("enter", "down", enterInteraction)
        unbindKey("arrow_u", "down", upMove)
        unbindKey("arrow_d", "down", downMove)

        if isElement(gPed) then 
            gPed:destroy()
        end 

        exports['cr_dx']:startFade("skinshop >> panel", 
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

        localPlayer.frozen = oDatas["frozen"]
        localPlayer:setData("hudVisible", oDatas["hudVisible"])
        localPlayer:setData("keysDenied", oDatas["keysDenied"])
        exports['cr_custom-chat']:showChat(oDatas["isChatVisible"])

        cameraInteraction = false
        cameraInit(false)
    end 
end 

sx, sy = guiGetScreenSize()
function drawnSkinShop()
    local alpha, progress = exports['cr_dx']:getFade("skinshop >> panel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("drawnSkinShop")
            return 
        end  
    end 

    isCursorInPanel = false

    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 16)
    local font2 = exports.cr_fonts:getFont("Poppins-Medium", 16)
    local font3 = exports.cr_fonts:getFont("Poppins-Medium", 14)

    local hexColor = exports.cr_core:getServerColor("yellow", true)
    local hexColor2 = exports.cr_core:getServerColor("green", true)
    local hexColor3 = exports.cr_core:getServerColor("red", true)

    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local white = "#F2F2F2"

    local panelW, panelH = 400, 150
    local panelX, panelY = sx / 2 - panelW / 2, sy - panelH - 10

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 26, 30
    local logoX, logoY = panelX + 10, panelY + 8

    dxDrawImage(logoX, logoY, logoW, logoH, "assets/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Ruhabolt", logoX + logoW + 10, logoY + 4, logoX + logoW, logoY + logoH, tocolor(255, 255, 255, alpha), 1, font, "left", "center")

    dxDrawText("Ruha azonosító: " .. hexColor .. skins[now], panelX, panelY - 17, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)
    dxDrawText("Ruha ára: " .. hexColor2 .. "$" .. tuningPrice[1], panelX, panelY + 24, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, false, false, true)
    dxDrawText("A megvételhez használd az " .. hexColor .. "enter" .. white .. " billentyűt.", panelX, panelY + 74, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, false, false, true)
    dxDrawText("A kilépéshez pedig a " .. hexColor3 .. "backspace" .. white .. " billentyűt.", panelX, panelY + 114, panelX + panelW, panelY + panelH, tocolor(242, 242, 242, alpha), 1, font3, "center", "center", false, false, false, true)
end 