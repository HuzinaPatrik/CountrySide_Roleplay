local gPed, temporaryObj, temporaryObjScaleTimer, startTick;

localPlayer:setData('wineMaker >> barrel >> playerOwn', nil)

addEventHandler("onClientClick", root, 
    function(b, s, _, _, _, _, _, worldElement)
        if isJobStarted then 
            if b == "left" and s == "down" then 
                if worldElement and isElement(worldElement) and worldElement:getData("wineMaker >> barrel") then 
                    if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                        if not localPlayer:getData('wineMaker >> barrel >> playerOwn') or localPlayer:getData('wineMaker >> barrel >> playerOwn') == worldElement then 
                            if not worldElement:getData('wineMaker >> barrel >> playerOwn') then 
                                if localPlayer:getData("winemaker >> objInHand") and tonumber(localPlayer:getData("winemaker >> objInHand") or 7251) == 7046 then 
                                    if not worldElement:getData("wineMaker >> doingBarrelInteraction") then 
                                        if exports['cr_network']:getNetworkStatus() then return end 

                                        worldElement:setData("wineMaker >> doingBarrelInteraction", localPlayer)
                                    end 
                                end 
                            else 
                                if worldElement:getData('wineMaker >> barrel >> playerOwn') == localPlayer then 
                                    if exports['cr_inventory']:hasItem(localPlayer, 142) then 
                                        if not localPlayer:getData('inMinigame') then 
                                            gPed = worldElement 

                                            exports['cr_minigame']:createMinigame(localPlayer, 1, 'WineMaker >> Barrel', {['max'] = 50, ['needed'] = 25, ['multipler'] = 8})
                                        end 
                                    else 
                                        exports['cr_infobox']:addBox('error', 'Szükséged lesz egy présre!')
                                    end 
                                else 
                                    exports['cr_infobox']:addBox('error', 'Ez nem a te hordód!')
                                end 
                            end 
                        else 
                            exports['cr_infobox']:addBox('error', 'Elsőnek fejezd be a műveletet azon a hordón amin már elkezdtél dolgozni!')
                        end 
                    end 
                elseif worldElement and isElement(worldElement) and worldElement:getData("wineMaker >> packedBarrel") then 
                    if getDistanceBetweenPoints3D(localPlayer.position, worldElement.position) <= 2 then
                        if localPlayer:getData('wineMaker >> barrel >> playerOwn') == worldElement then 
                            if worldElement:getData('wineMaker >> ripe') then 
                                if not localPlayer:getData("winemaker >> objInHand") then 
                                    triggerLatentServerEvent("respawnBarrel", 5000, false, localPlayer, localPlayer, worldElement)
                                    triggerLatentServerEvent("giveChestToHand", 5000, false, localPlayer, localPlayer, worldElement.model)
                                end 
                            else 
                                exports['cr_infobox']:addBox('error', 'Várj ameddig a hordó teljesen megérik!')
                            end 
                        else 
                            exports['cr_infobox']:addBox('error', 'Ez nem a te hordód!')
                        end 
                    end 
                end 
            end 
        end 
    end 
)

addEventHandler('[Minigame - StopMinigame]', localPlayer,
    function(e, data)
        if e == localPlayer then 
            local minigame, nowMinigame, success, failed, needed = unpack(data)

            if nowMinigame == 'WineMaker >> Barrel' then 
                if success >= needed then 
                    exports['cr_infobox']:addBox('success', 'Sikeresen elvégezted a minigame-t, várj pár percet majd vidd el a hordót a pincébe!')
                    triggerLatentServerEvent("finishBarrel", 5000, false, localPlayer, localPlayer, gPed)
                else
                    exports['cr_infobox']:addBox('error', 'Mivel elrontottad a minigamet teljesen előről kell kezd a folyamatot!')
                    triggerLatentServerEvent("resetBarrel", 5000, false, localPlayer, localPlayer, gPed)
                end 
            end 
        end 
    end
)

addEventHandler("onClientElementDataChange", resourceRoot, 
    function(dName, oValue, nValue)
        if dName == "wineMaker >> doingBarrelInteraction" then 
            if nValue then 
                if oValue and isElement(oValue) and nValue == localPlayer then 
                    source:setData(dName, oValue)

                    if exports['cr_dx']:isProgressBarActive('wineMakerBarelProgress') then 
                        exports['cr_dx']:endProgressBar('wineMakerBarelProgress')
        
                        localPlayer:setData("forceAnimation", {"", ""})

                        if isTimer(temporaryObjScaleTimer) then 
                            killTimer(temporaryObjScaleTimer)
                        end 

                        if isElement(temporaryObj) then 
                            temporaryObj:destroy()
                        end 
                    end 

                    return 
                end 

                if nValue == localPlayer then 
                    if not exports['cr_dx']:isProgressBarActive('wineMakerBarelProgress') then 
                        gPed = source

                        local matrix = gPed.matrix
                        local newPosition = matrix:transformPosition(0, 0.07, 0)

                        temporaryObj = Object(7344, newPosition.x, newPosition.y, newPosition.z)
                        temporaryObj.rotation = gPed.rotation
                        temporaryObj.dimension = gPed.dimension
                        temporaryObj.interior = gPed.interior
                        temporaryObj.scale = Vector3(1, 1, 0)

                        temporaryObjScaleTimer = setTimer(
                            function(temporaryObj)
                                local x, y, z = getObjectScale(temporaryObj)
                                setObjectScale(temporaryObj, 1, 1, math.min(1, z + (1 / 20)))
                            end, (20 * 1000) / 20, 20, temporaryObj
                        )
                        
                        localPlayer.rotation = Vector3(0, 0, findRotation(localPlayer.position.x, localPlayer.position.y, source.position.x, source.position.y))
                        localPlayer:setData("forceAnimation", {"bd_fire", "wash_up"})

                        exports['cr_dx']:startProgressBar('wineMakerBarelProgress', {{'Elkezded beönteni a szőlőt...', 10000}, {'A hordó lassan megtelik', 10000}})
                    end 
                end 
            end 
        elseif dName == 'wineMaker >> packedBarrel' then 
            if nValue then 
                if localPlayer:getData('wineMaker >> barrel >> playerOwn') and localPlayer:getData('wineMaker >> barrel >> playerOwn') == source then 
                    gPed = source
                    startTick = getTickCount()

                    if isTimer(updateBarrelStatusTimer) then 
                        killTimer(updateBarrelStatusTimer)
                    end 

                    updateBarrelStatus()
                    updateBarrelStatusTimer = setTimer(updateBarrelStatus, 250, 0)

                    createRender('renderBarrelStatus', renderBarrelStatus)
                end 
            end 
        end 
    end 
)

local zAxis = 0.5
local renderCache 

function updateBarrelStatus()
    if not isJobStarted then 
        checkRender("off")
        return 
    end
    
    renderCache = {}
    
    local cameraX, cameraY, cameraZ = getElementPosition(localPlayer)
    
    if isElement(gPed) and gPed.dimension == localPlayer.dimension and gPed.interior == localPlayer.interior  then
        local boneX, boneY, boneZ = getElementPosition(gPed)
        boneZ = boneZ + zAxis
        local dist = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
        if dist <= maxDistance then
            local sightLine = isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, gPed)
            if sightLine then
                local v = {}

                v["sightLine"] = true
                v["distance"] = dist
                
                renderCache = v
            end
        end
    end
end

function renderBarrelStatus()
    if renderCache and renderCache['sightLine'] then 
        local nowTick = getTickCount()
        local font = exports['cr_fonts']:getFont("Poppins-Regular", 12)
        local r,g,b = 255,59,59
        
        local v = renderCache

        local boneX, boneY, boneZ = getElementPosition(gPed)
        local distance = v["distance"]
        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + zAxis)
            if screenX and screenY then
                local alpha = 255 * size
                local w, h = 150 * size, 15 * size

                local elapsedTime = nowTick - startTick
                local duration = 2 * 60 * 1000
                local progress = elapsedTime / duration
                local alph = interpolateBetween(
                    0, 0, 0,
                    100, 0, 0,
                    progress, startAnimation
                )

                if progress > 1 then 
                    destroyRender('renderBarrelStatus')

                    if isTimer(updateBarrelStatusTimer) then 
                        killTimer(updateBarrelStatusTimer)
                    end 

                    gPed:setData('wineMaker >> ripe', true)
                    gPed = nil 

                    exports['cr_infobox']:addBox('Kattins bal klikkel a hordóra majd vidd a leadó cpbe!')
                    return 
                end 

                hp = alph

                dxDrawRectangle(screenX - w/2, screenY- h/2, w, h, tocolor(242, 242, 242, alpha * 0.6))
                dxDrawRectangle(screenX - w/2, screenY - h/2, w * (hp / 100), h, tocolor(r,g,b, alpha))
                dxDrawText(math.floor(hp) .. "%", screenX, screenY, screenX, screenY + 4, tocolor(242, 242, 242, alpha), size, font, "center", "center", false, false, false, true)
            end
        end
    end 
end 

addEventHandler('ProgressBarEnd', localPlayer, 
    function(id, data)
        if id == 'wineMakerBarelProgress' then 
            if localPlayer:getData("winemaker >> objInHand") then
                triggerLatentServerEvent("destroyChestFromHand", 5000, false, localPlayer, localPlayer)
            end 

            localPlayer:setData("forceAnimation", {"", ""})

            if isTimer(temporaryObjScaleTimer) then 
                killTimer(temporaryObjScaleTimer)
            end 

            if isElement(temporaryObj) then 
                temporaryObj:destroy()
            end 

            triggerLatentServerEvent("ownBarrel", 5000, false, localPlayer, localPlayer, gPed)
        end 
    end 
)

addEventHandler('onClientPlayerQuit', localPlayer, 
    function()
        local obj = localPlayer:getData('wineMaker >> barrel >> playerOwn') 

        if obj then 
            if isElement(obj) then 
                triggerLatentServerEvent("resetBarrel", 5000, false, localPlayer, localPlayer, obj)
            end 
        end 
    end 
)