local animationStarted, gPed, listed, hover, closeHover, buttonHover

local pedCache = {}

function createListUtils()
    gPed = Ped(204, 1362.7694091797, 238.79440307617, 19.5625, 30)
    gPed:setData("ped.name", "Jordan Macaulay")
    gPed:setData("ped.type", "Telepvezető")
    gPed:setData("pizza >> listPed", true)
    gPed:setData("char >> noDamage", true)
    gPed:setFrozen(true)

    closeOrders()

    pedCache = {}
end 

function destroyListUtils()
    gPed:destroy()

    closeOrders()

    for k,v in pairs(pedCache) do 
        if isElement(k) then 
            k:destroy()

            exports['cr_radar']:destroyStayBlip(v['name'])
        end 

        if isElement(v['arrow']) then 
            v['arrow']:destroy()
        end 
    end 

    pedCache = {}
end 

local function onClick(b, s, _, _, _, _, _, worldElement)
    if isJobStarted then 
        if b == 'left' and s == 'down' then 
            if worldElement and isElement(worldElement) then 
                if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                    if worldElement == gPed then 
                        createCinematicAnimation()
                    elseif worldElement:getData('pizza >> orderPed') then 
                        doOrder(worldElement)
                    end 
                end
            end 
        end 
    end 
end 
addEventHandler('onClientClick', root, onClick)

local oDatas = {}

local startTick;

local x2, y2, z2, x2t, y2t, z2t = 1361.4854736328, 245.24099731445, 20.636199951172, 1362.7694091797, 238.79440307617, 19.5625
function createCinematicAnimation()
    if not animationStarted and not listed then 
        animationStarted = true 

        oDatas = {
            ["hudVisible"] = localPlayer:getData("hudVisible"),
            ["keysDenied"] = localPlayer:getData("keysDenied"),
            ["chat"] = exports['cr_custom-chat']:isChatVisible(),
            ['frozen'] = localPlayer.frozen,
            ['alpha'] = localPlayer.alpha,
        }
        
        localPlayer:setData("hudVisible", false)
        localPlayer:setData("keysDenied", true)
        exports['cr_custom-chat']:showChat(false)
        localPlayer.frozen = true
        localPlayer.alpha = 0

        oldCameraMatrix = {getCameraMatrix()}

        local x1, y1, z1, x1t, y1t, z1t = unpack(oldCameraMatrix)

        exports['cr_core']:smoothMoveCamera(x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, 500)

        gPed:setAnimation("GHANDS", "gsign3", -1, true, false, false)

        bindKey('enter', 'down', createOrders)
        exports['cr_controls']:toggleControl('enter_exit', false, 'high')
        bindKey('backspace', 'down', cancelCinematicAnimation)

        startTick = getTickCount()

        exports['cr_dx']:startFade("pizza >> cinemation", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 500,
                ["animation"] = "InOutQuad",
                ["from"] = 0,
                ["to"] = 255,
                ["alpha"] = 0,
                ["progress"] = 0,
            }
        )

        createRender('drawCinematicAnimation', drawCinematicAnimation)
    end 
end 

local recoveryTimer
function cancelCinematicAnimation()
    if animationStarted then 
        animationStarted = false

        localPlayer:setData("hudVisible", oDatas["hudVisible"])
        localPlayer:setData("keysDenied", oDatas["keysDenied"])
        exports['cr_custom-chat']:showChat(oDatas["chat"])
        localPlayer.frozen = oDatas['frozen']
        localPlayer.alpha = oDatas['alpha']

        local x1, y1, z1, x1t, y1t, z1t = unpack(oldCameraMatrix)

        exports['cr_core']:smoothMoveCamera(x2, y2, z2, x2t, y2t, z2t, x1, y1, z1, x1t, y1t, z1t, 500)

        if isTimer(recoveryTimer) then 
            killTimer(recoveryTimer)
        end 

        recoveryTimer = setTimer(
            function()
                exports['cr_core']:stopSmoothMoveCamera()

                setCameraTarget(localPlayer, localPlayer)
            end, 500, 1
        )

        gPed:setAnimation()

        unbindKey('enter', 'down', createOrders)
        unbindKey('backspace', 'down', cancelCinematicAnimation)

        exports['cr_dx']:startFade("pizza >> cinemation", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 500,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
    end 
end 

local sx, sy = guiGetScreenSize()
local animHeight = 80
function drawCinematicAnimation()
    local nowTick = getTickCount()

    local alpha, progress = exports['cr_dx']:getFade("pizza >> cinemation")
    if not animationStarted then 
        if progress >= 1 then 
            destroyRender("drawCinematicAnimation")

            exports['cr_controls']:toggleControl('enter_exit', true, 'high')

            return 
        end  
    end 

    dxDrawRectangle(0, 0, sx, animHeight, tocolor(23, 23, 23, alpha))
    dxDrawRectangle(0, sy - animHeight, sx, animHeight, tocolor(23, 23, 23, alpha))

    
    local text = "Jordan: A kutya fenét te a rendeléseket megakarod kapni? (Nyomj Enter-t a Rendelések lekéréséhez, Backspace-t a Kilépéshez)"
    local font = exports.cr_fonts:getFont("Poppins-Medium", 20)
    local conversationTime = 3000

    local elapsedTime = nowTick - startTick
    local duration = conversationTime
    local progress = elapsedTime / duration

    local animTextWidth = interpolateBetween(0, 0, 0, utf8.len(text), 0, 0, progress, "Linear")

    dxDrawText(utf8.sub(text, 1, animTextWidth), 30, sy - animHeight, sx / 2 + 350, sy, tocolor(242, 242, 242, alpha), 1, font, "left", "center", false, true)
end 

--[[
    Orders
]]
local buttonInAction = false
local orderData = {}
function createOrders()
    if not listed then 
        cancelCinematicAnimation()

        listed = true
        buttonInAction = false

        exports['cr_infobox']:addBox('success', 'Sikeresen megkaptad a rendeléseket!')

        exports['cr_dx']:startFade("pizza >> button", 
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

        createRender('drawList', drawList)

        local pizzaCount = 0
        orderData = {}

        while true do 
            local pizzaOrders = math.random(1, 7)

            if pizzaCount + pizzaOrders <= 7 then 
                local gender = math.random(1,2)
                local name = exports['cr_core']:createRandomName(gender)
                local typ = 1

                local skinid = pedSkins[gender][math.random(1, #pedSkins[gender])]
                local x, y, z, rot = unpack(pedPositions[math.random(1, #pedPositions)])
                
                table.insert(orderData, {name = name, pizzaOrders = pizzaOrders, location = getZoneName(x,y,z)})

                local ped = Ped(skinid, x, y, z, rot)
                ped:setData("ped.name", name)
                ped:setData("ped.type", "Rendelő")
                ped:setData("pizza >> orderPed", #orderData)
                ped:setData("char >> noDamage", true)
                ped:setFrozen(true)

                local r, g, b = exports.cr_core:getServerColor("lightyellow", false)
                exports['cr_radar']:createStayBlip("#" .. #orderData .. " - " .. name, Blip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 0), 0, "target", 24, 24, r, g, b)

                local arrow = Marker(x, y, z + 1.7, "arrow", 0.5, r, g, b)

                pedCache[ped] = {arrow = arrow, name = "#" .. #orderData .. " - " .. name}

                pizzaCount = pizzaCount + pizzaOrders
            end

            if pizzaCount == 7 then 
                break
            end 
        end 
    end 
end 

function closeOrders()
    if listed then 
        listed = false 

        exports['cr_interface']:setNode("pizza >> list1", "active", false)

        exports['cr_dx']:startFade("pizza >> button", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 0,
                ["progress"] = 0,
            }
        )
    end 
end 

local closeHover, hover
function drawList()
    local alpha, progress = exports['cr_dx']:getFade("pizza >> button")
    if not listed then 
        if progress >= 1 then 
            destroyRender("drawList")
            return 
        end  
    end 

    if not localPlayer:getData('hudVisible') then 
        return 
    end 
    
    if not buttonInAction then 
        if not exports['cr_minigame']:getMinigameStatus(4) then 
            local font = exports['cr_fonts']:getFont('Poppins-Regular', 12)

            local enabled, ax,ay,aw,ah,sizable,turnable, sizeDetails, acType, columns = exports['cr_interface']:getDetails("Actionbar")

            local buttonW, buttonH = 200, 20
            local startY = ay - buttonH - 20

            hover = nil
            if exports['cr_core']:isInSlot(ax + aw/2 - buttonW/2, startY, buttonW, buttonH) then 
                hover = true

                dxDrawRectangle(ax + aw/2 - buttonW/2, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                dxDrawText('Lista megnyitása', ax, startY, ax + aw, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
            else
                dxDrawRectangle(ax + aw/2 - buttonW/2, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText('Lista megnyitása', ax, startY, ax + aw, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "center", "center")
            end 
        end
    else 
        local font = exports['cr_fonts']:getFont('Poppins-Medium', 9)
        local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)

        local w, h = 219, 310
        local x, y = exports['cr_interface']:getNode("pizza >> list1", "x"), exports['cr_interface']:getNode("pizza >> list1", "y")
        
        dxDrawImage(x, y, w, h, 'assets/images/bg.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Rendelések', x, y + 55, x + w, y + 72, tocolor(23, 23, 23, alpha), 1, font2, 'center', 'center')

        local startX, startY = x, y + 72
        for i = 1, #orderData do 
            local data = orderData[i]

            dxDrawText(data['name'] .. ' - ' .. data['location'] .. ' (' .. data['pizzaOrders'] .. ' db)', startX, startY, startX + w, startY + 14 + 4, tocolor(23, 23, 23, alpha), 1, font, 'center', 'center')

            if data['delivered'] then 
                dxDrawRectangle(startX + w/2 - 190/2, startY + 14/2 - 2/2, 190, 2, tocolor(255, 59, 59, alpha * 0.8))
            end 

            startY = startY + 14 + 2
        end 
    end 
end 

addEventHandler('onClientClick', root, 
    function(b, s)
        if b == 'left' and s == 'down' then 
            if listed then 
                if hover then 
                    bindKey('backspace', 'down', cancelListed)

                    buttonInAction = true

                    exports['cr_interface']:setNode("pizza >> list1", "active", true)

                    hover = nil 
                end 
            end 
        end 
    end 
)

function cancelListed()
    buttonInAction = false 

    exports['cr_interface']:setNode("pizza >> list1", "active", false)

    unbindKey('backspace', 'down', cancelListed)
end 

local lastClickTick = -5000
function doOrder(gPed)
    if gPed then 
        local id = gPed:getData('pizza >> orderPed')
        if id then 
            if localPlayer:getData('pizza >> objInHand') then 
                local data = orderData[id]

                if localPlayer:getData('pizza >> objInHand') == 1582 then 
                    if exports['cr_network']:getNetworkStatus() then return end 

                    local now = getTickCount()
                    local a = 5
                    if now <= lastClickTick + a * 1000 then
                        return
                    end
                    lastClickTick = getTickCount()

                    triggerLatentServerEvent("destroyPizzaFromHand", 5000, false, localPlayer, localPlayer)

                    local salaryMultiplier = exports.cr_salary:getMultiplier() or 1

                    exports['cr_core']:giveMoney(localPlayer, 100 * salaryMultiplier)

                    outputChatBox(gPed:getData('ped.name'):gsub('_', ' ') .. ' mondja: Köszönöm szépen!', 255, 255, 255, true)

                    if isTimer(localAnimationTimer) then 
                        killTimer(localAnimationTimer)
                    end 
                    localAnimationTimer = setTimer(setPedAnimation, 500, 1, localPlayer,"DEALER","DEALER_DEAL",3000,false,false,false,false)
                    pedAnimationTimer = setTimer(setPedAnimation, 500, 1, gPed,"DEALER","DEALER_DEAL",3000,false,false,false,false)

                    local pedPizzaCount = tonumber(gPed:getData('pizza >> pizzaCount') or 0)
                    if pedPizzaCount + 1 >= data['pizzaOrders'] then 
                        orderData[id]['delivered'] = true

                        exports['cr_radar']:destroyStayBlip(pedCache[gPed]['name'])
                
                        if isElement(pedCache[gPed]['arrow']) then 
                            pedCache[gPed]['arrow']:destroy()
                        end 

                        gPed:destroy()

                        if isTimer(pedAnimationTimer) then 
                            killTimer(pedAnimationTimer)
                        end 

                        for k,v in pairs(orderData) do 
                            if not v['delivered'] then 
                                return 
                            end
                        end 

                        exports['cr_infobox']:addBox('success', 'Sikeresen kézbesítetted az összes megrendelést!')

                        cancelCinematicAnimation()
                        closeOrders()
                    else
                        gPed:setData('pizza >> pizzaCount', tonumber(gPed:getData('pizza >> pizzaCount') or 0) + 1)
                    end 
                else 
                    exports['cr_infobox']:addBox('error', 'Nem a megfelelő fa típust szeretnéd odaadni a rendelőnek!')
                end 
            end 
        end 
    end 
end 