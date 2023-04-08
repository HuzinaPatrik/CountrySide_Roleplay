local grinderCache = {}
local unavailableAtms = {}
local renderCache = {}
local grindCache = {}

local rangeToObject = 0.6
atmModelId = 2942
destroyedAtmModelId = atmModelId
local grinderObjectId = 1329

local maxDistance = 20
local checkRenderCacheTimer = false

local lastGrindTick = 0
local atmElement = false
local atmHealthTimer = false
local hasAccess = false

local oldFactions = {}
local factionCheckTimer = false

local canSeeAtmBlips = {1}
local canRobAtms = {6, 7, 9, 10, 11, 12, 13, 14}

function hasPermission(factionId, permName)
    if factionId and permName then 
        if exports.cr_dashboard:hasPlayerPermission(localPlayer, factionId, permName) or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, factionId) then 
            return true
        end
    end

    return false
end

function hasPermissionToRob(robType)
    local robType = robType or "atmRob"
    local result = false

    for i = 1, #canRobAtms do 
        local v = canRobAtms[i]

        if v then 
            if hasPermission(v, robType) then 
                result = true
                break
            end
        end
    end

    return result
end

function getActiveLawMembers()
    local result = 0
    local players = getElementsByType("player")

    for i = 1, #players do 
        local v = players[i]

        for k = 1, #canSeeAtmBlips do 
            local v2 = canSeeAtmBlips[k]

            if v:getData("char >> duty") and v:getData("char >> duty") == v2 then 
                result = result + 1
            end
        end
    end

    return result
end

function createGrinder()
    local flexState = localPlayer:getData("grinderInHand")
    local newState = not flexState

    localPlayer:setData("grinderInHand", newState)
    
    if newState then 
        exports.cr_chat:createMessage(localPlayer, "elővesz egy flexet", 1)
    else
        exports.cr_chat:createMessage(localPlayer, "elrak egy flexet", 1)

        if isElement(atmElement) then 
            local id = atmElement:getData("bank >> atm")
            triggerServerEvent("atmRobbery.stopGrinding", localPlayer, id, atmElement)

            atmElement = nil
        end
    end

    return newState
end

function onKey(button, state)
    if button == "mouse1" then 
        if state then 
            if localPlayer:getData("loggedIn") then 
                if localPlayer:getData("grinderInHand") then 
                    cancelEvent()

                    if lastGrindTick + 1000 > getTickCount() then 
                        return
                    end

                    if localPlayer:getData("char >> chat") or localPlayer:getData("keysDenied") or isCursorShowing() then 
                        return
                    end

                    if not hasPermissionToRob("atmRob") then 
                        exports.cr_infobox:addBox("warning", "Neked ehhez nincs jogosultságod.")
                        return
                    end

                    local posX, posY, posZ = getPositionInFrontOfElement(localPlayer, rangeToObject)
                    local atmObject = findNearestElement(atmModelId, posX, posY, posZ, rangeToObject, "object")

                    if isElement(atmObject) then 
                        local activeLaw = getActiveLawMembers()

                        if activeLaw >= 3 then 
                            if atmObject:getData("bank >> atm") and (atmObject:getData("atm >> health") or 100) > 0 then 
                                local id = atmObject:getData("bank >> atm")

                                triggerServerEvent("atmRobbery.startGrinding", localPlayer, id, atmObject)
                            end
                        else 
                            exports.cr_infobox:addBox("error", "A rablás elkezdéséhez minimum 3 rendvédelmisre van szükség.")
                        end
                    end

                    lastGrindTick = getTickCount()
                end
            end
        else
            if isElement(atmElement) then 
                local id = atmElement:getData("bank >> atm")
                triggerServerEvent("atmRobbery.stopGrinding", localPlayer, id, atmElement)

                if isTimer(atmHealthTimer) then 
                    killTimer(atmHealthTimer)
                    atmHealthTimer = nil
                end

                atmElement = nil
            end
        end
    end
end
addEventHandler("onClientKey", root, onKey)

function syncPlayer(element)
    if not grinderCache[element] then 
        grinderCache[element] = Object(grinderObjectId, 0, 0, 0)

        grinderCache[element].interior = element.interior
        grinderCache[element].dimension = element.dimension
        exports.cr_bone_attach:attachElementToBone(grinderCache[element], element, 12, -0.1, 0.05, 0.08, 180, 0, 0)
    end
end

function deSyncPlayer(element)
    if isElement(grinderCache[element]) then 
        exports.cr_bone_attach:detachElementFromBone(grinderCache[element])

        grinderCache[element].collisions = false
        grinderCache[element]:destroy()
        grinderCache[element] = nil
    end
end

function onStreamIn()
    if source.type == "player" then 
        if source:getData("grinderInHand") and not grinderCache[source] then 
            syncPlayer(source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, onStreamIn)

function onStreamOut()
    if source.type == "player" then 
        if grinderCache[source] then 
            deSyncPlayer(source)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, onStreamOut)

function createATMBlip(element)
    if isElement(element) and not unavailableAtms[element] then 
        for k, v in pairs(canSeeAtmBlips) do 
            if exports.cr_dashboard:isPlayerInFaction(localPlayer, v) then 
                hasAccess = v
                break
            end
        end

        if hasAccess then 
            local id = element:getData("bank >> atm") or "Ismeretlen"

            unavailableAtms[element] = {}
            unavailableAtms[element].theBlip = Blip(element.position, 0, 2, 255, 0, 0, 255, 0, 0)
            unavailableAtms[element].theBlip.interior = element.interior
            unavailableAtms[element].theBlip.dimension = element.dimension
            unavailableAtms[element].blipName = "Üzemen kívüli bankautomata #" .. id

            exports.cr_radar:createStayBlip(unavailableAtms[element].blipName, unavailableAtms[element].theBlip, 0, "target", 24, 24, 242, 201, 76)
        end
    end
end

function destroyATMBlip(element)
    if isElement(element) and unavailableAtms[element] then 
        local blipName = unavailableAtms[element].blipName

        if isElement(unavailableAtms[element].theBlip) then 
            unavailableAtms[element].theBlip:destroy()
            unavailableAtms[element].theBlip = nil
        end

        unavailableAtms[element] = nil
        exports.cr_radar:destroyStayBlip(blipName)
    end
end

function destroyATMBlips()
    for k, v in pairs(unavailableAtms) do 
        destroyATMBlip(k)
    end
end

function createATMBlips()
    destroyATMBlips()

    local objects = getElementsByType("object")

    for i = 1, #objects do 
        local v = objects[i]
        local modelId = getElementModel(v)

        if modelId == destroyedAtmModelId and v:getData("bank >> atm") and v:getData("atm >> unavailable") then 
            if unavailableAtms[v] then 
                unavailableAtms[v] = nil
            end

            createATMBlip(v)
        end
    end
end
addEvent("atmRobbery.createATMBlips", true)
addEventHandler("atmRobbery.createATMBlips", root, createATMBlips)

function onClientStart()
    local players = getElementsByType("player", root, true)

    for i = 1, #players do 
        local v = players[i]

        if v:getData("grinderInHand") and not grinderCache[v] then 
            syncPlayer(v)
        end
    end

    local objects = getElementsByType("object")
    for i = 1, #objects do 
        local v = objects[i]

        if v:getData("atm >> unavailable") and not unavailableAtms[v] then 
            createATMBlip(v)
        end
    end

    if isTimer(checkRenderCacheTimer) then 
        killTimer(checkRenderCacheTimer)
        checkRenderCacheTimer = nil
    end

    if isTimer(factionCheckTimer) then 
        killTimer(factionCheckTimer)
        factionCheckTimer = nil
    end

    checkRenderCacheTimer = setTimer(createRenderCache, 50, 0)

    factionCheckTimer = setTimer(
        function()
            local resource = getResourceFromName("cr_dashboard")

            if resource and getResourceState(resource) == "running" then 
                local currentFactions = exports.cr_dashboard:getPlayerFactions(localPlayer)

                if #currentFactions ~= #oldFactions then 
                    oldFactions = currentFactions

                    createATMBlips()
                end
            end
        end, 1000, 0
    )
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function onClientStop()
    for k, v in pairs(unavailableAtms) do 
        local blipName = v.blipName

        exports.cr_radar:destroyStayBlip(blipName)
    end
end
addEventHandler("onClientResourceStop", resourceRoot, onClientStop)

function handleDataChange(dataName, oldValue, newValue)
    if source.type == "player" then 
        if dataName == "grinderInHand" then 
            if newValue then 
                syncPlayer(source)
            else 
                if grinderCache[source] then 
                    deSyncPlayer(source)
                end
            end
        end
    elseif source.type == "object" then
        if dataName == "atm >> unavailable" then
            if newValue then 
                if not unavailableAtms[source] then 
                    createATMBlip(source)
                end
            else
                if unavailableAtms[source] then 
                    destroyATMBlip(source)
                end
            end
        end
    end
end
addEventHandler("onClientElementDataChange", root, handleDataChange)

function onClientElementDestroy()
    if unavailableAtms[source] then 
        destroyATMBlip(source)
    end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)

function startGrinding(element)
    if not element:getData("atm >> health") then 
        element:setData("atm >> health", 100)
    end

    if not element:getData("atm >> cashBoxes") then 
        local cashBoxes = createCashBoxes()

        element:setData("atm >> cashBoxes", cashBoxes)
    end

    if not grindCache[source] then 
        grindCache[source] = {}
        
        local newRotation = exports.cr_core:findRotation(source.position.x, source.position.y, element.position.x, element.position.y)
        source.rotation = Vector3(0, 0, newRotation)

        local grinderRot = select(3, getElementRotation(grinderCache[source]))
        local effectX, effectY, effectZ = getPositionFromElementOffset(source, 0.02, 0.60, 0.05)

        local effectElement = createEffect("prt_spark", effectX, effectY, effectZ, 0, 0, -grinderRot + 90)
        setEffectDensity(effectElement, 2)

        grindCache[source].effectElement = effectElement

        local soundElement = playSound3D("atm/files/sounds/grinder.mp3", source.position, true)
        soundElement.interior = source.interior
        soundElement.dimension = source.dimension

        setSoundMaxDistance(soundElement, 50)
        grindCache[source].soundElement = soundElement

        setPedAnimation(source, "sword", "sword_IDLE", -1, true, true, false)
    end

    if source == localPlayer then 
        if not element:getData("atm >> alreadyNotified") then 
            local syntax = exports.cr_core:getServerSyntax(false, "red")
            local hexColor = "#f2c94c"
            local zoneName = getZoneName(element.position)
    
            element:setData("atm >> alreadyNotified", true)
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Egy ATM üzemképtelenné vált, helyszín: " .. hexColor .. zoneName)
        end

        atmElement = element

        if isTimer(atmHealthTimer) then 
            killTimer(atmHealthTimer)
            atmHealthTimer = nil
        end

        atmHealthTimer = setTimer(
            function()
                if isElement(atmElement) then 
                    local health = atmElement:getData("atm >> health") or 100
                    local newHealth = math.max(0, health - 1)

                    atmElement:setData("atm >> health", newHealth)

                    if newHealth <= 0 then 
                        local id = atmElement:getData("bank >> atm")
                        triggerServerEvent("atmRobbery.stopGrinding", localPlayer, id, atmElement)

                        if isTimer(atmHealthTimer) then 
                            killTimer(atmHealthTimer)
                            atmHealthTimer = nil
                        end

                        triggerServerEvent("atmRobbery.openATMPanel", localPlayer, id, atmElement)
                    end
                end
            end, 800, 0
        )
    end
end
addEvent("atmRobbery.startGrinding", true)
addEventHandler("atmRobbery.startGrinding", root, startGrinding)

function stopGrinding(thePlayer)
    local sourcePlayer = thePlayer or source

    if isElement(sourcePlayer) then 
        if grindCache[sourcePlayer] then 
            if isElement(grindCache[sourcePlayer].effectElement) then 
                grindCache[sourcePlayer].effectElement:destroy()
                grindCache[sourcePlayer].effectElement = nil
            end

            if isElement(grindCache[sourcePlayer].soundElement) then 
                grindCache[sourcePlayer].soundElement:destroy()
                grindCache[sourcePlayer].soundElement = nil
            end

            grindCache[sourcePlayer] = nil
            setPedAnimation(sourcePlayer, false)
        end
    end
end
addEvent("atmRobbery.stopGrinding", true)
addEventHandler("atmRobbery.stopGrinding", root, stopGrinding)

function onQuit()
    if grindCache[source] then 
        stopGrinding(source)
    end

    if grinderCache[source] then 
        deSyncPlayer(source)
    end
end
addEventHandler("onClientPlayerQuit", root, onQuit)

function createRenderCache()
    renderCache = {}

    local objects = getElementsByType("object", root, true)
    local cameraX, cameraY, cameraZ = getCameraMatrix()

    if not localPlayer:getData("hudVisible") then 
        return
    end

    for i = 1, #objects do 
        local v = objects[i]
        local modelId = getElementModel(v)

        if modelId == destroyedAtmModelId and v:getData("bank >> atm") and v:getData("atm >> unavailable") then 
            local objectX, objectY, objectZ = getElementPosition(v)

            if isLineOfSightClear(cameraX, cameraY, cameraZ, objectX, objectY, objectZ, true, false, false, false, false, false, false, localPlayer) then 
                local distance = math.sqrt((cameraX - objectX) ^ 2 + (cameraY - objectY) ^ 2 + (cameraZ - objectZ))

                local id = v:getData("bank >> atm")
                local health = v:getData("atm >> health") or 100

                table.insert(renderCache, {
                    id = id,
                    element = v,
                    distance = distance,
                    health = health
                })
            end
        end
    end
end

local animationDetails = {}

function updateAnimationDetails()
    for i = 1, #renderCache do 
        local v = renderCache[i]

        if not animationDetails[v.id] then 
            animationDetails[v.id] = 0
        end

        if not animationDetails["real" .. v.id] then
            animationDetails["real" .. v.id] = 0
        end

        if animationDetails[v.id] ~= v.health then
            animationDetails[v.id] = v.health
            animationDetails[v.id .. "Animation"] = true
            animationDetails[v.id .. "AnimationTick"] = getTickCount()
        end
    end   
end
setTimer(updateAnimationDetails, 250, 0)

startAnimation = "InOutQuad"
startAnimationTime = 250

function renderAtms()
    local nowTick = getTickCount()
    local font = exports.cr_fonts:getFont("Poppins-SemiBold", 20)

    for i = 1, #renderCache do 
        local v = renderCache[i]

        local id = v.id
        local element = v.element
        local distance = v.distance
        local health = v.health

        if isElement(element) then 
            local objectX, objectY, objectZ = getElementPosition(element)
            local theX, theY = getScreenFromWorldPosition(objectX, objectY, objectZ + 1, 1)

            if theX and theY then 
                local scale = 1 - (distance / maxDistance)
                local alpha = scale * 255

                local imageW, imageH = 105 * scale, 99 * scale
                local imageX, imageY = theX - imageW / 2, theY - imageH

                if scale > 0 then 
                    dxDrawImage(imageX, imageY, imageW, imageH, "atm/files/images/warning.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                    shadowedText("Üzemen kívüli bankautomata", imageX, imageY, imageX + imageW, imageY + imageH + (35 * scale), tocolor(235, 87, 87, alpha), scale, font, "center", "bottom", math.min(100, alpha))
                    dxDrawText("Üzemen kívüli bankautomata", imageX, imageY, imageX + imageW, imageY + imageH + (35 * scale), tocolor(235, 87, 87, alpha), scale, font, "center", "bottom")

                    if health > 0 then
                        local k = id

                        if k then 
                            if animationDetails[k .. "Animation"] then
                                local startTick = animationDetails[k .. "AnimationTick"]
                
                                local elapsedTime = nowTick - startTick
                                local duration = startAnimationTime
                                local progress = elapsedTime / duration
                                local alph = interpolateBetween(
                                    animationDetails["real" .. k], 0, 0,
                                    animationDetails[k], 0, 0,
                                    progress, startAnimation
                                )
                
                                animationDetails["real" .. k] = alph
                
                                if progress >= 1 then
                                    animationDetails[k .. "Animation"] = false
                                end
                            end
                        end

                        local barW, barH = 250 * scale, 20 * scale
                        local barX, barY = theX - barW / 2, theY - barH / 2 + (60 * scale)
                        local animHealth = animationDetails["real" .. k] or 0

                        dxDrawRectangle(barX - (3 * scale), barY - (3 * scale), barW + (6 * scale), barH + (6 * scale), tocolor(51, 51, 51, alpha * 0.8))
                        dxDrawRectangle(barX, barY, barW * (animHealth / 100), barH, tocolor(235, 87, 87, alpha))
                    end
                end
            end
        end
    end
end
createRender("renderAtms", renderAtms)

function shadowedText(text,x,y,w,h,color,fontsize,font,alignX,alignY, alpha)
    dxDrawText(text, x, y + 1, w, h + 1, tocolor(0, 0, 0, alpha), fontsize, font, alignX, alignY)
    dxDrawText(text, x, y - 1, w, h - 1, tocolor(0, 0, 0, alpha), fontsize, font, alignX, alignY)
    dxDrawText(text, x - 1, y, w - 1, h, tocolor(0, 0, 0, alpha), fontsize, font, alignX, alignY)
    dxDrawText(text, x + 1, y, w + 1, h, tocolor(0, 0, 0, alpha), fontsize, font, alignX, alignY)
end