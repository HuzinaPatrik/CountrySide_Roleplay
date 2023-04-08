local screenX, screenY = guiGetScreenSize()

local alpha = 0

local currentItem = 1
local itemToGet = false

local caseOpening = false
local openButtonHover = false

function renderSpinner()
    local alpha, progress = exports["cr_dx"]:getFade("weaponSpinnerPanel")
    if alpha and progress then 
        if progress >= 1 then 
            if alpha <= 0 then 
                destroyRender("renderSpinner")

                currentItem = 1
                itemToGet = false
            end
        end
    end

    local font = exports["cr_fonts"]:getFont("Roboto", 10)

    local w, h = 400, 270
    local _w, _h = w, h
    local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2
    local _x, _y = x, y

    dxDrawRectangle(x, y, w, h, tocolor(44, 44, 44, alpha))

    local h = 30
    dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, alpha * 0.3))
    dxDrawText("Fegyverláda nyitása", x, y, x + w, y + h, tocolor(130, 130, 130, alpha), 1, font, "center", "center")

    local w, h = 44, 44
    local x, y = x + _w / 2 - w / 2, y + h - 5

    dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, alpha * 0.3))
    
    local realW, realH = 40, 40
    local x, y = x + 2, y + 2

    local serverHex = exports["cr_core"]:getServerColor("blue", true)
    local r, g, b = exports["cr_core"]:getServerColor("blue", false)

    if currentItem then 
        if items[currentItem] then 
            local itemId = items[currentItem]["itemId"]
            local itemName = exports["cr_inventory"]:getItemName(itemId)

            dxDrawImage(x, y, realW, realH, exports["cr_inventory"]:getItemPNG(itemId), 0, 0, 0, tocolor(255, 255, 255, alpha))

            local y = y + realH - 2
            dxDrawText("A láda tartalma: "..serverHex..itemName, x, y, x + w, y + h, tocolor(130, 130, 130, alpha), 1, font, "center", "center", false, false, false, true)
        end
    end

    local w, h = _w - 60, 30
    local x, y = _x + 30, _y + _h - h - 10
    local inSlot = exports["cr_core"]:isInSlot(x, y, w, h)

    openButtonHover = nil
    if inSlot then 
        openButtonHover = true
    end

    dxDrawRectangle(x, y, w, h, (inSlot and tocolor(r, g, b, alpha) or tocolor(0, 0, 0, alpha * 0.3)))
    dxDrawText((caseOpening and "Láda nyitása folyamatban..." or "Láda kinyitása"), x, y, x + w, y + h, (inSlot and tocolor(0, 0, 0, alpha) or tocolor(130, 130, 130, alpha)), 1, font, "center", "center")

    local w, h = 40, 40
    local y = _y
    local maxItems = #items

    local realW, realH = 44, 44
    for i = 0, maxItems - 1 do 
        local v = items[i + 1]

        local startX = x + (_w / 10 - realW / 5) + (realW + 4) * (i % maxRow)
        local startY = y + (h + 80) + (realH + 4) * math.floor(i / maxColumn)

        dxDrawRectangle(startX, startY, realW, realH, tocolor(0, 0, 0, alpha * 0.3))

        if v then 
            local itemId = v["itemId"]

            local startX, startY = startX + 2, startY + 2
            dxDrawImage(startX, startY, w, h, exports["cr_inventory"]:getItemPNG(itemId), 0, 0, 0, tocolor(255, 255, 255, alpha))
        end
    end
end

function onKey(button, state)
    if checkRender("renderSpinner") then 
        if button == "mouse1" then 
            if state then 
                if openButtonHover then 
                    if not caseOpening then 
                        caseOpening = true

                        openCase()
                    end

                    openButtonHover = nil
                end
            end
        end
    end
end

function openCase()
    local maxItems = #items
    local breaked = false

    itemToGet = math.random(1, maxItems)

    for i = 0, maxItems - 1 do 
        local i = i + 1

        setTimer(
            function()
                if not breaked then 
                    currentItem = currentItem + 1

                    if currentItem == maxItems then 
                        currentItem = 1
                    end

                    if i == itemToGet then 
                        currentItem = itemToGet
            
                        local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                        local serverHex = exports["cr_core"]:getServerColor("blue", true)

                        outputChatBox(syntax.."A láda tartalma: "..serverHex..exports["cr_inventory"]:getItemName(itemToGet), 255, 0, 0, true)
                        exports["cr_inventory"]:giveItem(localPlayer, itemToGet)

                        breaked = true

                        setTimer(
                            function()
                                processSpinner("exit")

                                caseOpening = false
                            end, 500, 1
                        )
                    end
                end
            end, i * 150, 1
        )
    end
end

function processSpinner(state)
    if state == "init" then 
        createRender("renderSpinner", renderSpinner)

        exports["cr_dx"]:startFade("weaponSpinnerPanel", 
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

        removeEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientKey", root, onKey)
    elseif state == "exit" then 
        removeEventHandler("onClientKey", root, onKey)

        exports["cr_dx"]:startFade("weaponSpinnerPanel", 
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

addEvent("playShipHornSound", true)
addEventHandler("playShipHornSound", root,
    function()
        local soundElement = Sound3D("files/sounds/shiphorn.mp3", shipEndPoint)

        soundElement.interior = soundInterior
        soundElement.dimension = soundDimension
        soundElement:setMaxDistance(maxSoundDistance)
    end
)

addEventHandler("onClientClick", root,
    function(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
        if button == "left" then 
            if state == "down" then 
                if isElement(clickedElement) and clickedElement.type == "object" then 
                    if clickedElement:getData("weaponcrate >> id") then 
                        triggerLatentServerEvent("weaponship.pickupCrate", 5000, false, localPlayer, localPlayer, clickedElement)
                    end
                end
            end
        end
    end
)

function initMarker()
    local r, g, b = exports["cr_core"]:getServerColor("lightyellow", false)
    local weaponMarker = Marker(weaponMarkerPoint, "cylinder", 2, r, g, b, 150)
    weaponMarker:setData("marker >> customMarker", true)
    weaponMarker:setData("marker >> customIconPath", ":cr_weaponboat/files/images/weapon.png")

    addEventHandler("onClientMarkerHit", weaponMarker,
        function(hitElement, mDim)
            if hitElement == localPlayer then 
                if mDim then 
                    local crate = localPlayer:getData("weaponcrate >> inHand")

                    if crate and isElement(crate) then 
                        processSpinner("init")

                        triggerLatentServerEvent("weaponship.detachCrateFromPlayer", 5000, false, localPlayer, localPlayer)
                    end
                end
            end
        end
    )
end
initMarker()

local valueTimer
function carryRestriction(value)
    if isTimer(valueTimer) then killTimer(valueTimer) end
    valueTimer = setTimer(
        function()
            toggleControl("jump", value)
            toggleControl("fire", value)
            toggleControl("action", value)
            toggleControl("crouch", value)
            toggleControl("sprint", value)
        end, 200, 1
    )
end
addEvent("carryRestriction", true)
addEventHandler("carryRestriction", root, carryRestriction)