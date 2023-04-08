local animationStarted, gPed, listed, gMarker, hover, closeHover, buttonHover, makeHover, finishHover, resetHover, creatorData, startTick, oldDatas, h
local buttonInAction = false
local orderData = {}
local pedCache = {}

function createMakingUtils()
    gPed = Ped(121, 622.88336181641, -504.19625854492, 16.453125, 0)
    gPed:setData("ped.name", "Ronald East")
    gPed:setData("ped.type", "Telepvezető")
    gPed:setData("hotdog >> makingPed", true)
    gPed:setData("char >> noDamage", true)
    gPed:setFrozen(true)

    cancelDoingOrder()
    destroyTemporaryList()
    closeHotdogCreator()

    pedCache = {}
end 

function destroyMakingUtils()
    gPed:destroy()

    cancelDoingOrder()
    destroyTemporaryList()
    closeHotdogCreator()

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

    if isElement(gMarker) then 
        gMarker:destroy()
    end 
end 

local function onClick(b, s, _, _, _, _, _, worldElement)
    if isJobStarted then 
        if b == 'left' and s == 'down' then 
            if worldElement and isElement(worldElement) then 
                if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                    if worldElement == gPed then 
                        createCinematicAnimation()
                    end 
                end
            end 
        end 
    end 
end 
addEventHandler('onClientClick', root, onClick)

local orderPedData = {}

texts = {
    --{'Text', funcOnStart, funcOnEnd},
    {'Ronald: Egy rendelés érkezett szeretnéd elvállalni? (Nyomj Enter-t a Folytatáshoz, Backspace-t a Kilépéshez)'}, 

    {'OrderPedName: CroissantText',
        function()
            local gender = math.random(1, 2)
            local croissant = math.random(1, #orderTabs[1])

            orderPedData = {
                ['gender'] = gender,
                ['name'] = exports['cr_core']:createRandomName(gender),
                ['skinID'] = pedSkins[gender][math.random(1, #pedSkins[gender])],
            }

            table.insert(orderData, {
                ['id'] = croissant,
                ['type'] = 'croissant',
                ['name'] = orderTabs[1][croissant]['name'],
            })

            texts[2][1] = texts[2][1]:gsub('OrderPedName', orderPedData['name'])

            texts[2][1] = texts[2][1]:gsub('CroissantText', 'Szeretnék rendelni egy hotdogot melyen ' .. orderData[1]['name'] .. ' van!')

            createTemporaryList()

            return true
        end 
    },

    {'OrderPedName: SausageText',
        function()
            local sausage = math.random(1, #orderTabs[2])

            table.insert(orderData, {
                ['id'] = sausage,
                ['type'] = 'sausage',
                ['name'] = orderTabs[2][sausage]['name'],
            })

            texts[3][1] = texts[3][1]:gsub('OrderPedName', orderPedData['name'])

            texts[3][1] = texts[3][1]:gsub('SausageText', 'Illetve szeretném a következő kolbászt is: ' .. orderData[2]['name'] .. '!')
        end,
    },

    {'OrderPedName: SauceText',
        function()
            local sauce = math.random(1, #orderTabs[3])

            table.insert(orderData, {
                ['id'] = sauce,
                ['type'] = 'sauce',
                ['name'] = orderTabs[3][sauce]['name'],
            })

            texts[4][1] = texts[4][1]:gsub('OrderPedName', orderPedData['name'])

            texts[4][1] = texts[4][1]:gsub('SauceText', 'És még szeretném a következő szószt is: ' .. orderData[3]['name'] .. '!')
        end,
    },

    {'OrderPedName: DrinkText',
        function()
            local drink = math.random(0, #orderTabs[4])

            table.insert(orderData, {
                ['id'] = drink,
                ['type'] = 'drink',
                ['name'] = drink > 0 and orderTabs[4][drink]['name'] or 'Nincs',
            })

            texts[5][1] = texts[5][1]:gsub('OrderPedName', orderPedData['name'])

            if drink > 0 then 
                texts[5][1] = texts[5][1]:gsub('DrinkText', 'És még szeretném a következő italt is: ' .. orderData[4]['name'] .. '!')
            else 
                texts[5][1] = texts[5][1]:gsub('DrinkText', 'És nem szeretnék italt hozzá!')
            end 
        end,

        function()
            destroyTemporaryList()
        end 
    },
}

function resetText()
    texts[2][1] = 'OrderPedName: CroissantText'
    texts[3][1] = 'OrderPedName: SausageText'
    texts[4][1] = 'OrderPedName: SauceText'
    texts[5][1] = 'OrderPedName: DrinkText'
end 

local oDatas = {}

local startTick, nowText;

local x2, y2, z2, x2t, y2t, z2t = 620.22052001953, -498.64910888672, 17.768100738525, 620.62957763672, -499.52249145508, 17.50378036499 
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

        nowText = 1
        if texts[nowText][2] then 
            texts[nowText][2]()
        end 

        orderData = {}

        resetText()

        oldCameraMatrix = {getCameraMatrix()}

        local x1, y1, z1, x1t, y1t, z1t = unpack(oldCameraMatrix)

        exports['cr_core']:smoothMoveCamera(x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, 500)

        gPed:setAnimation("GHANDS", "gsign3", -1, true, false, false)

        bindKey('enter', 'down', enterInteraction)
        exports['cr_controls']:toggleControl('enter_exit', false, 'high')
        bindKey('backspace', 'down', cancelCinematicAnimation)

        startTick = getTickCount()

        exports['cr_dx']:startFade("hotdog >> cinemation", 
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

        createRender('drawCinematicAnimation2', drawCinematicAnimation2)
    end 
end 

local recoveryTimer, temporaryList

function cancelCinematicAnimation()
    if animationStarted then 
        destroyTemporaryList()

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

        unbindKey('enter', 'down', enterInteraction)
        unbindKey('backspace', 'down', cancelCinematicAnimation)

        exports['cr_dx']:startFade("hotdog >> cinemation", 
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
dxDrawMultipler = math.min(1.25, sx / 1600)

function respc(a)
    return a * dxDrawMultipler
end 

function getRealFontSize(a)
    local a = a * dxDrawMultipler
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end 

local animHeight = 80
function drawCinematicAnimation2()
    local nowTick = getTickCount()

    local alpha, progress = exports['cr_dx']:getFade("hotdog >> cinemation")
    if not animationStarted then 
        if progress >= 1 then 
            destroyRender("drawCinematicAnimation2")

            exports['cr_controls']:toggleControl('enter_exit', true, 'high')

            return 
        end  
    end 

    dxDrawRectangle(0, 0, sx, animHeight, tocolor(23, 23, 23, alpha))
    dxDrawRectangle(0, sy - animHeight, sx, animHeight, tocolor(23, 23, 23, alpha))

    
    local text = texts[nowText][1]
    local font = exports.cr_fonts:getFont("Poppins-Medium", 20)
    local conversationTime = 3000

    local elapsedTime = nowTick - startTick
    local duration = conversationTime
    local progress = elapsedTime / duration

    local animTextWidth = interpolateBetween(0, 0, 0, utf8.len(text), 0, 0, progress, "Linear")

    dxDrawText(utf8.sub(text, 1, animTextWidth), 30, sy - animHeight, sx / 2 + 350, sy, tocolor(242, 242, 242, alpha), 1, font, "left", "center", false, true)
end 

--[[
    Order
]]

local selectedAltMenu = 1

function enterInteraction()
    if nowText + 1 <= #texts then
        if texts[nowText][3] then 
            texts[nowText][3]()
        end  

        startTick = getTickCount()

        nowText = nowText + 1

        if texts[nowText][2] then 
            texts[nowText][2]()
        end 
    else 
        if not listed or temporaryList then 
            cancelCinematicAnimation()

            temporaryList = false

            listed = true
            buttonInAction = false

            exports['cr_infobox']:addBox('success', 'Sikeresen megkaptad a rendelést!')

            exports['cr_dx']:startFade("hotdog >> button", 
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

            createRender('drawList2', drawList2)

            oDatas['dimension'] = localPlayer.dimension

            localPlayer:setData('specialDimension', localPlayer.dimension)
            localPlayer.dimension = tonumber(localPlayer:getData('acc >> id') or math.random(1, 1000))

            if isElement(gMarker) then 
                gMarker:destroy()
            end 

            gMarker = Marker(629.46881103516, -500.99850463867, 15.4, "cylinder", 1.5, 255, 235, 59)
            gMarker:setData("marker >> customMarker", true)
            gMarker:setData("marker >> customIconPath", ":cr_hotdog/assets/images/icon.png")
            gMarker:setData("hotdog >> hotdogCreatorMarker", true)
            gMarker.dimension = localPlayer.dimension 
            gMarker.interior = localPlayer.interior 

            selectedAltMenu = 1

            creatorData = {}
        end 
    end 
end 

function cancelDoingOrder()
    if listed then 
        listed = false 

        exports['cr_interface']:setNode("hotdog >> list", "active", false)

        exports['cr_dx']:startFade("hotdog >> button", 
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

        localPlayer.dimension = oDatas['dimension']
        localPlayer:setData('specialDimension', nil)

        if isElement(gMarker) then 
            gMarker:destroy()
        end 
    end 
end 

--[[
    Temporary List
]]

function createTemporaryList()
    if not listed then 
        listed = true
        buttonInAction = true
        temporaryList = true 

        exports['cr_dx']:startFade("hotdog >> button", 
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

        createRender('drawList2', drawList2)
    end 
end 

function destroyTemporaryList()
    if listed then 
        listed = false 

        exports['cr_dx']:startFade("hotdog >> button", 
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

--[[
    List Drawing
]]

local closeHover, hover, creatorState

function drawList2()
    local alpha, progress = exports['cr_dx']:getFade("hotdog >> button")
    if not listed then 
        if progress >= 1 then 
            destroyRender("drawList2")

            temporaryList = false
            return 
        end  
    end 

    if not temporaryList and not localPlayer:getData('hudVisible') and not creatorState then 
        return 
    elseif creatorState and not buttonInAction then 
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
        local font = exports['cr_fonts']:getFont('FREESCPT', 14)
        local font2 = exports['cr_fonts']:getFont('FREESCPT', 22)

        local w, h = 200, 300
        local x, y = exports['cr_interface']:getNode("hotdog >> list", "x"), exports['cr_interface']:getNode("hotdog >> list", "y")

        if temporaryList then 
            x, y = exports['cr_interface']:getDefaultNode("hotdog >> list", "x"), exports['cr_interface']:getDefaultNode("hotdog >> list", "y")
        end 
        
        dxDrawImage(x, y, w, h, ':cr_pizza/assets/images/makerBG.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Rendelés', x, y + 50, x + w, y + 50, tocolor(23, 23, 23, alpha), 1, font2, 'center', 'center')

        dxDrawText(orderPedData['name']:gsub('_', ' '), x, y + 280, x + w - 15, y + 300 - 5, tocolor(23, 23, 23, alpha), 1, font2, 'right', 'bottom')

        local startX, startY = x, y + 75

        for k, v in ipairs(orderData) do
            local data = v

            if data then
                if data['name'] then 
                    dxDrawText(typeNames[data['type']] .. data['name'], startX + 15, startY, startX + w, startY + 14 + 4, tocolor(23, 23, 23, alpha), 1, font, 'left', 'center')

                    startY = startY + 15 + 2
                elseif type(data) == 'table' then 
                    for k2,v2 in ipairs(data) do 
                        if v2['name'] then 
                            dxDrawText(typeNames[v2['type']] .. v2['name'], startX + 15, startY, startX + w, startY + 14 + 4, tocolor(23, 23, 23, alpha), 1, font, 'left', 'center')

                            startY = startY + 15 + 2
                        end 
                    end 
                end 
            end 
        end 
    end 
end 

local lastClickTick = -5000
addEventHandler('onClientClick', root, 
    function(b, s)
        if b == 'left' and s == 'down' then 
            if listed then 
                if hover then 
                    bindKey('backspace', 'down', cancelListed2)

                    buttonInAction = true

                    exports['cr_interface']:setNode("hotdog >> list", "active", true)

                    hover = nil 

                    return 
                end 
            end 
            
            if creatorState then 
                if closeHover then 
                    closeHotdogCreator()

                    closeHover = nil 

                    return
                end

                if tonumber(buttonHover) then 
                    selectedAltMenu = tonumber(buttonHover)

                    buttonHover = nil 
                elseif tonumber(makeHover) then 
                    if selectedAltMenu == 1 then 
                        creatorData['croissant'] = {
                            ['id'] = tonumber(makeHover),
                            ['type'] = 'croissant',
                            ['name'] = orderTabs[1][tonumber(makeHover)]['name'],
                        }
                    elseif selectedAltMenu == 2 then 
                        creatorData['sausage'] = {
                            ['id'] = tonumber(makeHover),
                            ['type'] = 'sausage',
                            ['name'] = orderTabs[2][tonumber(makeHover)]['name'],
                        }
                    elseif selectedAltMenu == 3 then 
                        creatorData['sauce'] = {
                            ['id'] = tonumber(makeHover),
                            ['type'] = 'sauce',
                            ['name'] = orderTabs[3][tonumber(makeHover)]['name'],
                        }
                    elseif selectedAltMenu == 4 then 
                        creatorData['drink'] = {
                            ['id'] = tonumber(makeHover),
                            ['type'] = 'drink',
                            ['name'] = orderTabs[4][tonumber(makeHover)]['name'],
                        }
                    end 

                    makeHover = nil 
                elseif finishHover then 
                    local croissant = creatorData['croissant'] and creatorData['croissant']['id'] or 0
                    if croissant ~= orderData[1]['id'] then 
                        exports['cr_infobox']:addBox('error', 'Nem megfelelő kiflit választottál!')
                        return 
                    end 

                    local sausage = creatorData['sausage'] and creatorData['sausage']['id'] or 0
                    if sausage ~= orderData[2]['id'] then 
                        exports['cr_infobox']:addBox('error', 'Nem megfelelő kolbászt választottál!')
                        return 
                    end 

                    local sauce = creatorData['sauce'] and creatorData['sauce']['id'] or 0
                    if sauce ~= orderData[3]['id'] then 
                        exports['cr_infobox']:addBox('error', 'Nem megfelelő szószt választottál!')
                        return 
                    end 

                    local drink = creatorData['drink'] and creatorData['drink']['id'] or 0
                    if drink ~= orderData[4]['id'] then 
                        exports['cr_infobox']:addBox('error', 'Nem megfelelő italt választottál!')
                        return 
                    end 

                    if exports['cr_network']:getNetworkStatus() then return end 

                    local now = getTickCount()
                    local a = 5
                    if now <= lastClickTick + a * 1000 then
                        return
                    end
                    lastClickTick = getTickCount()

                    local salaryMultiplier = exports.cr_salary:getMultiplier() or 1

                    exports['cr_core']:giveMoney(localPlayer, 60 * salaryMultiplier)

                    exports['cr_infobox']:addBox('success', 'Sikeresen eladtad a hotdogot, menj és ha szeretnél vegyél fel egy új rendelést!')

                    cancelDoingOrder()
                    destroyTemporaryList()
                    if isElement(gMarker) then 
                        gMarker:destroy()
                    end 
                    closeHotdogCreator()

                    finishHover = nil 
                elseif resetHover then 
                    creatorData = {}

                    resetHover = nil 
                end 
            end 
        end 
    end 
)

function cancelListed2()
    buttonInAction = false 

    exports['cr_interface']:setNode("hotdog >> list", "active", false)

    unbindKey('backspace', 'down', cancelListed2)
end 

--[[
    Hotdog Maker
]]

addEventHandler("onClientMarkerHit", resourceRoot, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("hotdog >> hotdogCreatorMarker") then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 2.5 and localPlayer.onGround then 
                    openHotdogCreator()
                end 
            end 
        end 
    end 
)

addEventHandler("onClientMarkerLeave", resourceRoot,
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("hotdog >> hotdogCreatorMarker") then 
                closeHotdogCreator()
            end 
        end 
    end 
)

local fontsize = {12, 14}

function openHotdogCreator()
    if not creatorState then 
        creatorState = true 

        exports['cr_dx']:startFade("hotdog >> creator", 
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

        if not realFontSize then 
            realFontSize = {}

            for k,v in ipairs(fontsize) do 
                realFontSize[v] = getRealFontSize(v)
            end 
        end 

        h = respc(240)

        createRender('drawHotdogCreator', drawHotdogCreator)

        oldDatas = {
            ['keysDenied'] = localPlayer:getData('keysDenied'),
            ['hudVisible'] = localPlayer:getData('hudVisible'),
            ['chat'] = exports['cr_custom-chat']:isChatVisible(),
        }

        localPlayer:setData('keysDenied', true)
        localPlayer:setData('hudVisible', false)
        exports['cr_custom-chat']:showChat(false)
    end 
end 

function closeHotdogCreator()
    if creatorState then 
        creatorState = false 

        exports['cr_dx']:startFade("hotdog >> creator", 
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

        localPlayer:setData('keysDenied', oldDatas['keysDenied'])
        localPlayer:setData('hudVisible', oldDatas['hudVisible'])
        exports['cr_custom-chat']:showChat(oldDatas['chat'])

        oldDatas = {}
    end 
end 

function drawHotdogCreator()
    local alpha, progress = exports['cr_dx']:getFade("hotdog >> creator")
    if not creatorState then 
        if progress >= 1 then 
            destroyRender("drawHotdogCreator")
            return 
        end  
    end 

    local font2 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[14])
    local font3 = exports['cr_fonts']:getFont('Poppins-SemiBold', realFontSize[12])

    local nowH = respc(15) + respc(30) + respc(15) + respc(22) + respc(5) + respc(15)

    local w = sx
    local x, y = 0, sy - h

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    --[[
        Alt Menus
    ]]
    local startX, startY = x + respc(50), y + respc(15)
    local buttonW, buttonH = respc(180), respc(30)

    buttonHover = nil
    for k,v in ipairs(orderTabs) do 
        local inSlot = exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH)

        if inSlot or selectedAltMenu == k then 
            if inSlot then 
                buttonHover = k
            end 

            dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
            dxDrawText(v['name'], startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(51, 51, 51, alpha), 1, font2, "center", "center")
        else
            dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
            dxDrawText(v['name'], startX, startY, startX + buttonW, startY + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
        end 

        startX = startX + buttonW + respc(10)
    end 

    --[[
        Alt Menu List
    ]]
    local startX, startY = x + respc(100), y + respc(60)
    local _startX = startX
    local data = orderTabs[selectedAltMenu]

    local buttonW, buttonH = respc(180), respc(22)

    makeHover = nil

    local minImageH = 0
    for i = 1, #data do 
        local v = data[i]

        local imageW, imageH, imagePath = unpack(v['imageData'])

        imageW = respc(imageW)
        imageH = respc(imageH)

        exports['cr_dx']:dxDrawImageAsTexture(startX, startY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))

        if imageH > minImageH then 
            minImageH = imageH
        end 

        if exports['cr_core']:isInSlot(startX + imageW/2 - buttonW/2, startY + imageH + respc(5), buttonW, buttonH) then 
            makeHover = i

            dxDrawRectangle(startX + imageW/2 - buttonW/2, startY + imageH + respc(5), buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
            dxDrawText(v['name'], startX, startY + imageH + respc(5), startX + imageW, startY + imageH + respc(5) + buttonH + respc(4), tocolor(51, 51, 51, alpha), 1, font3, "center", "center")
        else
            dxDrawRectangle(startX + imageW/2 - buttonW/2, startY + imageH + respc(5), buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
            dxDrawText(v['name'], startX, startY + imageH + respc(5), startX + imageW, startY + imageH + respc(5) + buttonH + respc(4), tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
        end 

        startX = startX + math.max(buttonW, imageW) + respc(50)
    end 

    nowH = nowH + minImageH

    if nowH > h then 
        h = nowH
    end 

    local imageW, imageH = respc(387), respc(29)

    local _imageW = imageW

    --[[Croissant #1]]
    if creatorData['croissant'] then 
        local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[1][creatorData['croissant']['id']]['overlayImageData'][1])

        imageW = respc(imageW)
        imageH = respc(imageH)

        exports['cr_dx']:dxDrawImageAsTexture(x + w - _imageW - respc(60) + ofsX, y + respc(170) + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    --[[Sausage]]
    if creatorData['sausage'] then 
        local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[2][creatorData['sausage']['id']]['overlayImageData'])

        imageW = respc(imageW)
        imageH = respc(imageH)

        exports['cr_dx']:dxDrawImageAsTexture(x + w - _imageW - respc(60) + ofsX, y + respc(170) + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    --[[Croissant #2]]
    if creatorData['croissant'] then 
        local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[1][creatorData['croissant']['id']]['overlayImageData'][2])

        imageW = respc(imageW)
        imageH = respc(imageH)

        exports['cr_dx']:dxDrawImageAsTexture(x + w - _imageW - respc(60) + ofsX, y + respc(170) + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    --[[Sauce]]
    if creatorData['sauce'] then 
        local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[3][creatorData['sauce']['id']]['overlayImageData'])

        imageW = respc(imageW)
        imageH = respc(imageH)

        exports['cr_dx']:dxDrawImageAsTexture(x + w - _imageW - respc(60) + ofsX, y + respc(170) + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    --[[Drink]]
    if creatorData['drink'] then 
        local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[4][creatorData['drink']['id']]['overlayImageData'])

        imageW = respc(imageW)
        imageH = respc(imageH)

        exports['cr_dx']:dxDrawImageAsTexture(x + w - _imageW - respc(60) + ofsX, y + respc(170) + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    --[[
        Hotdog Overlay
    ]]

    exports['cr_dx']:dxDrawImageAsTexture(x + w - imageW - respc(60), y + respc(170), imageW, imageH, ':cr_hotdog/assets/images/hotdogBG.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

    --[[
        Reset Button
    ]]

    resetHover = nil
    if exports['cr_core']:isInSlot(x + w - respc(40), y + respc(20), respc(20), respc(20)) then 
        resetHover = true 

        exports['cr_dx']:dxDrawImageAsTexture(x + w - respc(40), y + respc(20), respc(20), respc(20), ':cr_pizza/assets/images/reset.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
    else 
        exports['cr_dx']:dxDrawImageAsTexture(x + w - respc(40), y + respc(20), respc(20), respc(20), ':cr_pizza/assets/images/reset.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
    end 

    --[[
        Finish Button
    ]]

    finishHover = nil
    if exports['cr_core']:isInSlot(x + w - respc(40), y + h - respc(40), respc(20), respc(20)) then 
        finishHover = true 

        exports['cr_dx']:dxDrawImageAsTexture(x + w - respc(40), y + h - respc(40), respc(20), respc(20), ':cr_bank/assets/images/exit.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
    else 
        exports['cr_dx']:dxDrawImageAsTexture(x + w - respc(40), y + h - respc(40), respc(20), respc(20), ':cr_bank/assets/images/exit.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
    end 
end 