local screenX, screenY = guiGetScreenSize()

local barAnimation = {
    startTick = false,
    state = "down",
    duration = 1500,

    stopped = false,
    rammingValue = false,

    width = 0,
    height = 0,

    defaultWidth = 25,
    defaultHeight = 250,
    barY = 0,

    arrowHeight = 20,
    arrowY = false,

    oldData = {},
    animRGB = {}
}

local startTimer = false

function renderRamming()
    local alpha, progress = exports.cr_dx:getFade("renderRamming")

    if alpha and progress then 
        if progress >= 1 and alpha <= 0 then 
            destroyRender("renderRamming")

            barAnimation = {
                startTick = false,
                state = "down",
                duration = 1500,
                stopped = false,
            
                width = 0,
                height = 0,
            
                defaultWidth = 25,
                defaultHeight = 250,
                barY = 0,
            
                arrowHeight = 20,
                arrowY = false,
            
                oldData = {},
                animRGB = {}
            }

            if isTimer(startTimer) then 
                killTimer(startTimer)
                startTimer = nil
            end
        end
    end

    local nowTick = getTickCount()
    local redR, redG, redB = exports.cr_core:getServerColor("red", false)
    local greenR, greenG, greenB = exports.cr_core:getServerColor("green", false)
    local yellowR, yellowG, yellowB = exports.cr_core:getServerColor("yellow", false)

    local barW, barH = barAnimation.defaultWidth, barAnimation.defaultHeight
    local barX, barY = screenX - barW - 15, screenY / 2 - barH / 2

    if barAnimation.startTick then 
        if barAnimation.state == "down" then 
            local elapsedTime = nowTick - barAnimation.startTick
            local duration = barAnimation.duration
            local progress = elapsedTime / duration

            barAnimation.height = interpolateBetween(0, 0, 0, (barAnimation.defaultHeight - 4), 0, 0, progress, "InOutQuad")
            barAnimation.animRGB = {interpolateBetween(redR, redG, redB, greenR, greenG, greenB, progress, "InOutQuad")}

            if progress >= 1 then 
                if not barAnimation.stopped then 
                    barAnimation.stopped = true
                    barAnimation.startTick = false
                    manageRamming("close")

                    local barY, barH = barAnimation.barY, barAnimation.height
                    local arrowY, arrowHeight = barAnimation.arrowY, barAnimation.arrowHeight
                    local barY = barY + barH

                    if barIntersect(barY, arrowY, arrowHeight) then 
                        miniGameSuccess()
                    else
                        miniGameFailed()
                    end
                end
            end
        end
    end

    dxDrawRectangle(barX, barY, barW, barH, tocolor(51, 51, 51, alpha * 0.8))

    local barAnimWidth, barAnimHeight = barW - 4, barAnimation.height
    local barAnimX, barAnimY = barX + 2, barY + 2
    barAnimation.barY = barAnimY

    local r, g, b = barAnimation.animRGB[1], barAnimation.animRGB[2], barAnimation.animRGB[3]
    dxDrawRectangle(barAnimX, barAnimY, barAnimWidth, barAnimHeight, tocolor(r, g, b, alpha))

    local arrowHeight = barAnimation.arrowHeight
    local arrowY = barAnimation.arrowY

    local arrowWidth = barW - 8
    local arrowX = barX + 4

    if not arrowY and arrowHeight then
        math.randomseed(getTickCount())
        barAnimation.arrowY = barY + 4 + math.min((barAnimation.defaultHeight - 4), math.random(50, (barAnimation.defaultHeight - arrowHeight - 4)))
        -- barAnimation.arrowY = barY + 4 + 80
    else
        local r, g, b = yellowR, yellowG, yellowB

        if arrowX and arrowY and arrowWidth and arrowHeight then 
            dxDrawRectangle(arrowX, arrowY, arrowWidth, arrowHeight, tocolor(r, g, b, alpha))
        end
    end
end

function barIntersect(y, ty, th)
    if y and ty and th then 
        return y >= ty and y <= ty + th
    end

    return false
end

function onRammingKey(button, state)
    if button == "space" and state then 
        -- cancelEvent()

        local barY, barH = barAnimation.barY, barAnimation.height
        local arrowY, arrowHeight = barAnimation.arrowY, barAnimation.arrowHeight
        local barY = barY + barH

        if not barAnimation.stopped then 
            barAnimation.stopped = true
            barAnimation.startTick = false
            manageRamming("close")

            if barIntersect(barY, arrowY, arrowHeight) then 
                miniGameSuccess()
            else
                miniGameFailed()
            end
        end
    end
end

function manageRamming(state, value)
    if state == "init" then 
        if not checkRender("renderRamming") then 
            barAnimation.rammingValue = value
            barAnimation.oldData = {
                freezeState = localPlayer.frozen
            }

            localPlayer.frozen = true

            if isTimer(startTimer) then 
                killTimer(startTimer)
                startTimer = nil
            end

            local syntax = exports.cr_core:getServerSyntax("Battering Ram", "warning")
            outputChatBox(syntax .. "A MiniGame 2 másodpercen belül kezdődni fog, állítsd meg a csúszkát a sárga mezőben, a SPACE gomb lenyomásával.", 255, 0, 0, true)

            startTimer = setTimer(
                function()
                    exports.cr_dx:startFade("renderRamming", 
                        {
                            startTick = getTickCount(),
                            lastUpdateTick = getTickCount(),
                            time = 250,
                            animation = "InOutQuad",
                            from = 0,
                            to = 255,
                            alpha = 0,
                            progress = 0
                        }
                    )
    
                    barAnimation.startTick = getTickCount()
                    barAnimation.state = "down"
        
                    createRender("renderRamming", renderRamming)
                    addEventHandler("onClientKey", root, onRammingKey)
                end, 2000, 1
            )
        end
    elseif state == "close" then
        if isTimer(startTimer) then 
            killTimer(startTimer)
            startTimer = nil
        end

        exports.cr_dx:startFade("renderRamming", 
            {
                startTick = getTickCount(),
                lastUpdateTick = getTickCount(),
                time = 250,
                animation = "InOutQuad",
                from = 255,
                to = 0,
                alpha = 255,
                progress = 0
            }
        )

        removeEventHandler("onClientKey", root, onRammingKey)
    end
end

function miniGameSuccess()
    local syntax = exports.cr_core:getServerSyntax("Battering Ram", "success")
    outputChatBox(syntax .. "Sikeresen betörted az ajtót.", 255, 0, 0, true)

    localPlayer.frozen = barAnimation.oldData.freezeState

    local markerElement = exports.cr_interior:getActiveInterior()
    if isElement(markerElement) then 
        local markerData = markerElement:getData("marker >> data") or {}

        if markerData.locked then 
            markerData.locked = false
        end

        markerElement:setData("marker >> data", markerData)
        exports.cr_chat:createMessage(localPlayer, "betörte egy ingatlan ajtaját.", 1)
    end

    localPlayer:setData("rammingState", "success")
    exports.cr_inventory:findAndUseItemByIDAndValue(33, barAnimation.rammingValue)
end

function miniGameFailed()
    local syntax = exports.cr_core:getServerSyntax("Battering Ram", "error")
    outputChatBox(syntax .. "Nem sikerült betörnöd az ajtót.", 255, 0, 0, true)

    localPlayer:setData("rammingState", "failed")
    localPlayer.frozen = barAnimation.oldData.freezeState

    exports.cr_inventory:findAndUseItemByIDAndValue(33, barAnimation.rammingValue)
    exports.cr_chat:createMessage(localPlayer, "Nem sikerült betörnie az ingatlan ajtaját.", "do")
end

-- setTimer(
--     function()
--         if localPlayer.name == "Hugh_Wiley" then 
--             manageRamming("init")
--         end
--     end, 250, 1
-- )