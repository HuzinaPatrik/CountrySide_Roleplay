local animationStarted, gPed, listed, gMarker, hover, closeHover, buttonHover, buttonHover2, makeHover, finishHover, resetHover, creatorData, creatorType, startTick, selectedDrink
local buttonInAction = false
local orderData = {}
local pedCache = {}

function createMakingUtils()
    gPed = Ped(121, 1380.1343994141, 234.85386657715, 19.59375, 152)
    gPed:setData("ped.name", "Jasper Beil")
    gPed:setData("ped.type", "Telepvezető")
    gPed:setData("pizza >> makingPed", true)
    gPed:setData("char >> noDamage", true)
    gPed:setFrozen(true)

    cancelDoingOrder()
    destroyTemporaryList()
    closePizzaCreator()

    pedCache = {}
end 

function destroyMakingUtils()
    gPed:destroy()

    cancelDoingOrder()
    destroyTemporaryList()
    closePizzaCreator()

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
                        createCinematicAnimation2()
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
    {'Jasper: Egy rendelés érkezett szeretnéd elvállalni? (Nyomj Enter-t a Folytatáshoz, Backspace-t a Kilépéshez)'}, 

    {'OrderPedName: SauceText',
        function()
            local gender = math.random(1, 2)
            local sauce = math.random(0, #orderTabs[1])

            orderPedData = {
                ['gender'] = gender,
                ['name'] = exports['cr_core']:createRandomName(gender),
                ['skinID'] = pedSkins[gender][math.random(1, #pedSkins[gender])],
            }

            table.insert(orderData, {
                ['id'] = sauce,
                ['type'] = 'sauce',
                ['name'] = sauce > 0 and orderTabs[1][sauce]['name'] or 'Nincs',
            })

            texts[2][1] = texts[2][1]:gsub('OrderPedName', orderPedData['name'])

            if sauce > 0 then 
                texts[2][1] = texts[2][1]:gsub('SauceText', 'Szeretnék rendelni egy pizzát melyen ' .. orderData[1]['name'] .. ' szósz szerepel!')
            else 
                texts[2][1] = texts[2][1]:gsub('SauceText', 'Szeretnék rendelni egy pizzát melyen nincs szósz!')
            end 

            createTemporaryList()

            return true
        end 
    },

    {'OrderPedName: ToppingsText',
        function()
            local toppings = {}

            local num = math.random(0, 3)

            if num > 0 then 
                for i = 1, num do 
                    local typeID = math.random(1, #orderTabs[2])
                    local id = math.random(1, #orderTabs[2][typeID])

                    table.insert(toppings, {
                        ['id'] = id,
                        ['typeID'] = typeID,
                        ['type'] = 'topping',
                        ['name'] = orderTabs[2][typeID][id]['name'],
                    })
                end 
            else 
                toppings = {
                    ['id'] = 0, 
                    ['typeID'] = 0,
                    ['type'] = 'topping',
                    ['name'] = 'Nincs',
                }
            end 

            table.insert(orderData, toppings)

            texts[3][1] = texts[3][1]:gsub('OrderPedName', orderPedData['name'])

            if num > 0 then 
                local text = ''

                for k, v in ipairs(toppings) do 
                    text = text .. v['name'] .. (toppings[k + 1] and ' , ' or '')
                end 

                texts[3][1] = texts[3][1]:gsub('ToppingsText', 'Illetve szeretném a következő feltéteket is: ' .. text .. '!')
            else
                texts[3][1] = texts[3][1]:gsub('ToppingsText', 'Illetve nem szeretnék semmilyen feltétet!')
            end 
        end,
    },

    {'OrderPedName: CheeseText',
        function()
            local cheese = math.random(0, #orderTabs[3])

            table.insert(orderData, {
                ['id'] = cheese,
                ['type'] = 'cheese',
                ['name'] = cheese > 0 and orderTabs[3][cheese]['name'] or 'Nincs',
            })

            texts[4][1] = texts[4][1]:gsub('OrderPedName', orderPedData['name'])

            if cheese > 0 then 
                texts[4][1] = texts[4][1]:gsub('CheeseText', 'És még szeretném a következő sajtot is: ' .. orderData[3]['name'] .. '!')
            else 
                texts[4][1] = texts[4][1]:gsub('CheeseText', 'És nem szeretném ha lenne rajta sajt!')
            end 
        end,
    },

    {'OrderPedName: DrinkText',
        function()
            local drink = math.random(0, #drinks)

            table.insert(orderData, {
                ['id'] = drink,
                ['type'] = 'drink',
                ['name'] = drink > 0 and drinks[drink]['name'] or 'Nincs',
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
    texts[2][1] = 'OrderPedName: SauceText'
    texts[3][1] = 'OrderPedName: ToppingsText'
    texts[4][1] = 'OrderPedName: CheeseText'
    texts[5][1] = 'OrderPedName: DrinkText'
end 

local oDatas = {}

local startTick, nowText;

local x2, y2, z2, x2t, y2t, z2t = 1375.9682617188, 234.31440734863, 20.2672996521, 1380.1343994141, 234.85386657715, 19.59375
function createCinematicAnimation2()
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
        bindKey('backspace', 'down', cancelCinematicAnimation2)

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

        createRender('drawCinematicAnimation2', drawCinematicAnimation2)
    end 
end 

local recoveryTimer, temporaryList

function cancelCinematicAnimation2()
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
        unbindKey('backspace', 'down', cancelCinematicAnimation2)

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
function drawCinematicAnimation2()
    local nowTick = getTickCount()

    local alpha, progress = exports['cr_dx']:getFade("pizza >> cinemation")
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
local selectedAltMenu2 = 1

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
            cancelCinematicAnimation2()

            temporaryList = false

            listed = true
            buttonInAction = false

            exports['cr_infobox']:addBox('success', 'Sikeresen megkaptad a rendelést!')

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

            createRender('drawList2', drawList2)

            oDatas['dimension'] = localPlayer.dimension

            localPlayer:setData('specialDimension', localPlayer.dimension)
            localPlayer.dimension = tonumber(localPlayer:getData('acc >> id') or math.random(1, 1000))

            if isElement(gMarker) then 
                gMarker:destroy()
            end 

            gMarker = Marker(1384.0250244141, 247.89553833008, 18.4, "cylinder", 1.5, 255, 235, 59)
            gMarker:setData("marker >> customMarker", true)
            gMarker:setData("marker >> customIconPath", ":cr_pizza/assets/images/icon.png")
            gMarker:setData("pizza >> pizzaCreatorMarker", true)
            gMarker.dimension = localPlayer.dimension 
            gMarker.interior = localPlayer.interior 

            selectedAltMenu = 1
            selectedAltMenu2 = 1

            creatorData = {}
            creatorType = 1
        end 
    end 
end 

function cancelDoingOrder()
    if listed then 
        listed = false 

        exports['cr_interface']:setNode("pizza >> list2", "active", false)

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

        createRender('drawList2', drawList2)
    end 
end 

function destroyTemporaryList()
    if listed then 
        listed = false 

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

--[[
    List Drawing
]]

local closeHover, hover, creatorState

function drawList2()
    local alpha, progress = exports['cr_dx']:getFade("pizza >> button")
    if not listed then 
        if progress >= 1 then 
            destroyRender("drawList2")

            temporaryList = false
            return 
        end  
    end 

    if not temporaryList and not localPlayer:getData('hudVisible') then 
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
        local x, y = exports['cr_interface']:getNode("pizza >> list2", "x"), exports['cr_interface']:getNode("pizza >> list2", "y")

        if temporaryList then 
            x, y = exports['cr_interface']:getDefaultNode("pizza >> list2", "x"), exports['cr_interface']:getDefaultNode("pizza >> list2", "y")
        end 
        
        dxDrawImage(x, y, w, h, 'assets/images/makerBG.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

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

                    exports['cr_interface']:setNode("pizza >> list2", "active", true)

                    hover = nil 

                    return 
                end 
            end 
            
            if creatorState then 
                if closeHover then 
                    closePizzaCreator()

                    closeHover = nil 

                    return
                end

                if creatorType == 1 then 
                    if tonumber(buttonHover) then 
                        selectedAltMenu = tonumber(buttonHover)

                        buttonHover = nil 
                    elseif tonumber(buttonHover2) then 
                        selectedAltMenu2 = tonumber(buttonHover2)

                        buttonHover2 = nil 
                    elseif tonumber(makeHover) then 
                        if selectedAltMenu == 1 then 
                            creatorData['sauce'] = {
                                ['id'] = tonumber(makeHover),
                                ['type'] = 'sauce',
                                ['name'] = orderTabs[1][tonumber(makeHover)]['name'],
                            }
                        elseif selectedAltMenu == 2 then 
                            local typeID = selectedAltMenu2
                            local id = tonumber(makeHover)

                            if not creatorData['toppings'] then 
                                creatorData['toppings'] = {}
                            end 

                            if #creatorData['toppings'] < 3 then 
                                table.insert(creatorData['toppings'], {
                                    ['id'] = id,
                                    ['typeID'] = typeID,
                                    ['type'] = 'topping',
                                    ['name'] = orderTabs[2][typeID][id]['name'],
                                })
                            end 
                        elseif selectedAltMenu == 3 then 
                            creatorData['cheese'] = {
                                ['id'] = tonumber(makeHover),
                                ['type'] = 'cheese',
                                ['name'] = orderTabs[3][tonumber(makeHover)]['name'],
                            }
                        end 

                        makeHover = nil 
                    elseif finishHover then 
                        local sauce = creatorData['sauce'] and creatorData['sauce']['id'] or 0
                        if sauce ~= orderData[1]['id'] then 
                            exports['cr_infobox']:addBox('error', 'Nem megfelelő szószt választottál!')
                            return 
                        end 

                        local toppings = ''
                        for k,v in ipairs(creatorData['toppings'] or {}) do 
                            toppings = toppings .. tostring(v['typeID']) .. '-' .. tostring(v['id']) .. (creatorData['toppings'][k + 1] and ' , ' or '')
                        end 

                        local realToppings = ''
                        for k,v in ipairs(orderData[2]) do 
                            realToppings = realToppings .. tostring(v['typeID']) .. '-' .. tostring(v['id']) .. (orderData[2][k + 1] and ' , ' or '')
                        end 

                        if toppings:lower() ~= realToppings:lower() then 
                            exports['cr_infobox']:addBox('error', 'Nem megfelelő feltéteket választottál!')
                            return 
                        end 

                        local cheese = creatorData['cheese'] and creatorData['cheese']['id'] or 0
                        if cheese ~= orderData[3]['id'] then 
                            exports['cr_infobox']:addBox('error', 'Nem megfelelő sajtot választottál!')
                            return 
                        end 

                        exports['cr_infobox']:addBox('success', 'Sikeresen elkezdted sütni a pizzát!')

                        creatorType = 2
                        startTick = getTickCount()

                        finishHover = nil 
                    elseif resetHover then 
                        creatorData = {}

                        resetHover = nil 
                    end 
                elseif creatorType == 2 then 
                    if finishHover then 
                        creatorType = 3
                        selectedDrink = 0

                        finishHover = nil 
                    end 
                elseif creatorType == 3 then 
                    if tonumber(makeHover) then 
                        if selectedDrink and selectedDrink == tonumber(makeHover) then 
                            selectedDrink = 0
                        else 
                            selectedDrink = tonumber(makeHover)
                        end 

                        makeHover = nil
                    elseif resetHover then 
                        selectedDrink = 0

                        resetHover = nil  
                    elseif finishHover then 
                        if selectedDrink ~= orderData[4]['id'] then 
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

                        exports['cr_core']:giveMoney(localPlayer, 80 * salaryMultiplier)

                        exports['cr_infobox']:addBox('success', 'Sikeresen eladtad a pizzát, menj és ha szeretnél vegyél fel egy új rendelést!')

                        cancelDoingOrder()
                        destroyTemporaryList()
                        if isElement(gMarker) then 
                            gMarker:destroy()
                        end 
                        closePizzaCreator()

                        finishHover = nil 
                    end 
                end 
            end 
        end 
    end 
)

function cancelListed2()
    buttonInAction = false 

    exports['cr_interface']:setNode("pizza >> list2", "active", false)

    unbindKey('backspace', 'down', cancelListed2)
end 

--[[
    Pizza Maker
]]

addEventHandler("onClientMarkerHit", resourceRoot, 
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("pizza >> pizzaCreatorMarker") then 
                if getDistanceBetweenPoints3D(localPlayer.position, source.position) <= 2.5 and localPlayer.onGround then 
                    openPizzaCreator()
                end 
            end 
        end 
    end 
)

addEventHandler("onClientMarkerLeave", resourceRoot,
    function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then 
            if source:getData("pizza >> pizzaCreatorMarker") then 
                closePizzaCreator()
            end 
        end 
    end 
)

function openPizzaCreator()
    if not creatorState then 
        creatorState = true 

        exports['cr_dx']:startFade("pizza >> creator", 
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

        createRender('drawPizzaCreator', drawPizzaCreator)
    end 
end 

function closePizzaCreator()
    if creatorState then 
        creatorState = false 

        exports['cr_dx']:startFade("pizza >> creator", 
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

function drawPizzaCreator()
    local alpha, progress = exports['cr_dx']:getFade("pizza >> creator")
    if not creatorState then 
        if progress >= 1 then 
            destroyRender("drawPizzaCreator")
            return 
        end  
    end 

    if creatorType == 1 then -- // Készítés
        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-SemiBold', 12)
        local font3 = exports['cr_fonts']:getFont('Poppins-SemiBold', 8)
        local font4 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
        local font5 = exports['cr_fonts']:getFont('Poppins-SemiBold', 10)

        local w, h = 900, 400
        local x, y = sx/2 - w/2, sy/2 - h/2

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Pizzakészítő', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        closeHover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            closeHover = true 

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        dxDrawRectangle(x + 260, y + 100, 1, 200, tocolor(196, 196, 196, alpha))

        --[[
            Alt Menus
        ]]
        local startX, startY = x + 285, y + 40
        local buttonW, buttonH = 180, 22

        buttonHover = nil
        for k,v in ipairs(orderTabs) do 
            local inSlot = exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH)

            if inSlot or selectedAltMenu == k then 
                if inSlot then 
                    buttonHover = k
                end 

                dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
                dxDrawText(v['name'], startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(51, 51, 51, alpha), 1, font2, "center", "center")
            else
                dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText(v['name'], startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
            end 

            startX = startX + buttonW + 10
        end 

        --[[
            List BG
        ]]
        dxDrawRectangle(x + 286, y + 95, 590, 250, tocolor(41, 41, 41, alpha * 0.9))

        --[[
            Alt Menu List
        ]]
        local startX, startY = x + 286 + 30, y + 95 + 20
        local _startX = startX
        local data = orderTabs[selectedAltMenu]

        buttonHover2 = nil
        if data['altTabs'] then 
            startX, startY = x + 286 + 30, y + 95 + 55

            local startX, startY = x + 286 + 15, y + 95 + 10
            local buttonW, buttonH = 180, 22

            for k,v in ipairs(data['altTabs']) do 
                local inSlot = exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH)

                if inSlot or selectedAltMenu2 == k then 
                    if inSlot then 
                        buttonHover2 = k
                    end 

                    dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
                    dxDrawText(v, startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(51, 51, 51, alpha), 1, font2, "center", "center")
                else
                    dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                    dxDrawText(v, startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center")
                end 

                startX = startX + buttonW + 10
            end 

            data = orderTabs[selectedAltMenu][selectedAltMenu2]
        end 

        local buttonW, buttonH = 90, 15

        makeHover = nil
        for i = 1, #data do 
            local v = data[i]

            local imageW, imageH, imagePath = unpack(v['imageData'])

            if (startX + imageW + 30) > (x + 286 + 590) then 
                startX = _startX

                local imageH = data[1]['imageData'][2]
                startY = startY + imageH + 15 + buttonH + 20
            end 

            dxDrawImage(startX, startY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))

            if exports['cr_core']:isInSlot(startX + imageW/2 - buttonW/2, startY + imageH + 15, buttonW, buttonH) then 
                makeHover = i

                dxDrawRectangle(startX + imageW/2 - buttonW/2, startY + imageH + 15, buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
                dxDrawText(v['name'], startX, startY + imageH + 15, startX + imageW, startY + imageH + 15 + buttonH + 4, tocolor(51, 51, 51, alpha), 1, font3, "center", "center")
            else
                dxDrawRectangle(startX + imageW/2 - buttonW/2, startY + imageH + 15, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText(v['name'], startX, startY + imageH + 15, startX + imageW, startY + imageH + 15 + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
            end 

            startX = startX + math.max(buttonW, imageW) + 10
        end 

        --[[
            Finish Button
        ]]

        local startX, startY = x + 580, y + 360
        local buttonW, buttonH = 300, 20

        finishHover = nil
        if exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH) then 
            finishHover = true

            dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
            dxDrawText('Elkészítés', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else
            dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
            dxDrawText('Elkészítés', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end 

        --[[
            Pizza Overlay
        ]]

        local imageW, imageH = 200, 200
        dxDrawImage(x + 30, y + 95, imageW, imageH, 'assets/images/pizzaBG.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        --[[Sauce]]
        if creatorData['sauce'] then 
            local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[1][creatorData['sauce']['id']]['overlayImageData'])

            dxDrawImage(x + 30 + ofsX, y + 95 + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
        end 

        --[[Toppings]]
        if creatorData['toppings'] then 
            for k,v in ipairs(creatorData['toppings']) do 
                local typeID = v['typeID']
                local id = v['id']

                local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[2][typeID][id]['overlayImageData'])

                dxDrawImage(x + 30 + ofsX, y + 95 + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
            end 
        end 

        --[[Cheese]]
        if creatorData['cheese'] then 
            local ofsX, ofsY, imageW, imageH, imagePath = unpack(orderTabs[3][creatorData['cheese']['id']]['overlayImageData'])

            dxDrawImage(x + 30 + ofsX, y + 95 + ofsY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))
        end 

        --[[
            Reset Button
        ]]

        resetHover = nil
        if exports['cr_core']:isInSlot(x + 15, y + 75, 20, 20) then 
            resetHover = true 

            dxDrawImage(x + 15, y + 75, 20, 20, 'assets/images/reset.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            dxDrawImage(x + 15, y + 75, 20, 20, 'assets/images/reset.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 

        --[[
            Information Texts
        ]]
        local breaked = false
        local toppingText = ''

        if creatorData['toppings'] then 
            for k,v in ipairs(creatorData['toppings']) do 
                toppingText = toppingText .. v['name'] .. (creatorData['toppings'][k + 1] and ' , ' or '')
                breaked = true 
            end 
        end 

        if not breaked then 
            toppingText = 'Nincs'
        end 

        local text = 'Szósz: ' .. (creatorData['sauce'] and creatorData['sauce']['name'] or 'Nincs') .. '\nFeltétek: ' .. toppingText .. '\nSajt: ' .. (creatorData['cheese'] and creatorData['cheese']['name'] or 'Nincs')
        dxDrawText(text, x + 30, y + 320, x + 30, y + 320, tocolor(242, 242, 242, alpha), 1, font5, 'left', 'top')
    elseif creatorType == 2 then -- // Sütés
        local nowTick = getTickCount()

        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-Bold', 20)
        local font3 = exports['cr_fonts']:getFont('Poppins-SemiBold', 12)
        local font4 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

        local w, h = 400, 250
        local x, y = sx/2 - w/2, sy/2 - h/2

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Sütőkemence', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        closeHover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            closeHover = true 

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        local elapsedTime = nowTick - startTick
        local duration = 60 * 1000
        local progress = elapsedTime / duration
        local alph = interpolateBetween(
            -0.3335, 0, 0,
            1, 0, 0,
            progress, 'Linear'
        )

        dxDrawCircle(x + w/2, y + h/2, 50, 0, 360, tocolor(242, 242, 242, alpha * 0.2), tocolor(242, 242, 242, 0), 250, 1)
        dxDrawCircle(x + w/2, y + h/2, 50, -90, 270 * alph, tocolor(255, 59, 59, alpha), tocolor(242, 242, 242, 0), 250, 1)

        if math.max(0, 60 - math.floor(60 * progress)) > 0 then 
            dxDrawText(math.max(0, 60 - math.floor(60 * progress)) .. ' mp', x,y,x+w,y+h + 4,tocolor(242, 242, 242, alpha),1,font2,"center","center")
        end

        local status = 'Sütés alatt'
        if math.max(0, 60 - math.floor(60 * progress)) <= 0 then 
            status = 'Megsütve'
        end 
        dxDrawText('Státusz: #ff3b3b'..status, x,y+190,x+w,y+190,tocolor(242, 242, 242, alpha),1,font3,"center","center", false, false, false, true)

        if math.max(0, 60 - math.floor(60 * progress)) <= 0 then 
            local buttonW, buttonH = 300, 20
            local startX, startY = x + w/2 - buttonW/2, y + 210

            finishHover = nil
            if exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH) then 
                finishHover = true

                dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
                dxDrawText('Kivesz', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
            else
                dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText('Kivesz', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
            end 
        end
    elseif creatorType == 3 then -- // Ital + Kiadás
        local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
        local font2 = exports['cr_fonts']:getFont('Poppins-SemiBold', 12)
        local font3 = exports['cr_fonts']:getFont('Poppins-SemiBold', 8)
        local font4 = exports['cr_fonts']:getFont('Poppins-Medium', 14)

        local w, h = 900, 400
        local x, y = sx/2 - w/2, sy/2 - h/2

        dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

        dxDrawText('Pizzakészítő', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

        closeHover = nil
        if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
            closeHover = true 

            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
        else 
            dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
        end 

        dxDrawRectangle(x + 260, y + 100, 1, 200, tocolor(196, 196, 196, alpha))

        --[[
            Alt Menus
        ]]
        local startX, startY = x + 285, y + 40
        local buttonW, buttonH = 180, 22

        dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
        dxDrawText('Italok', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(51, 51, 51, alpha), 1, font2, "center", "center")

        --[[
            List BG
        ]]
        dxDrawRectangle(x + 286, y + 95, 590, 250, tocolor(41, 41, 41, alpha * 0.9))

        --[[
            Alt Menu List
        ]]
        local startX, startY = x + 286 + 50, y + 95 + 20
        local _startX = startX
        local data = drinks

        local buttonW, buttonH = 90, 15

        makeHover = nil
        for i = 1, #data do 
            local v = data[i]

            local imageW, imageH, imagePath = unpack(v['imageData'])

            if (startX + imageW + 50) > (x + 286 + 590) then 
                startX = _startX

                local imageH = data[1]['imageData'][2]
                startY = startY + imageH + 15 + buttonH + 20
            end 

            dxDrawImage(startX, startY, imageW, imageH, imagePath, 0, 0, 0, tocolor(255, 255, 255, alpha))

            local inSlot = exports['cr_core']:isInSlot(startX + imageW/2 - buttonW/2, startY + imageH + 15, buttonW, buttonH)
            if inSlot or selectedDrink == i then 
                if inSlot then 
                    makeHover = i
                end

                dxDrawRectangle(startX + imageW/2 - buttonW/2, startY + imageH + 15, buttonW, buttonH, tocolor(242, 242, 242, alpha)) 
                dxDrawText(v['name'], startX, startY + imageH + 15, startX + imageW, startY + imageH + 15 + buttonH + 4, tocolor(51, 51, 51, alpha), 1, font3, "center", "center")
            else
                dxDrawRectangle(startX + imageW/2 - buttonW/2, startY + imageH + 15, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
                dxDrawText(v['name'], startX, startY + imageH + 15, startX + imageW, startY + imageH + 15 + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
            end 

            startX = startX + math.max(buttonW, imageW) + 10
        end 

        --[[
            Finish Button
        ]]

        local startX, startY = x + 580, y + 360
        local buttonW, buttonH = 300, 20

        finishHover = nil
        if exports['cr_core']:isInSlot(startX, startY, buttonW, buttonH) then 
            finishHover = true

            dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(97, 177, 90, alpha)) 
            dxDrawText('Kiadás', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else
            dxDrawRectangle(startX, startY, buttonW, buttonH, tocolor(23, 23, 23, alpha * 0.9)) 
            dxDrawText('Kiadás', startX, startY, startX + buttonW, startY + buttonH + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end 

        --[[
            Pizza Overlay
        ]]
        local imageW, imageH = 200, 200
        dxDrawImage(x + 30, y + 95, imageW, imageH, 'assets/images/pizzaBox.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        --[[
            Reset Button
        ]]

        resetHover = nil
        if exports['cr_core']:isInSlot(x + 15, y + 75, 20, 20) then 
            resetHover = true 

            dxDrawImage(x + 15, y + 75, 20, 20, 'assets/images/reset.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
        else 
            dxDrawImage(x + 15, y + 75, 20, 20, 'assets/images/reset.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
        end 
    end 
end 