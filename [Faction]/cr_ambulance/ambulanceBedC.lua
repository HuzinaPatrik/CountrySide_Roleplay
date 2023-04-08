function interactAmbulanceBed(e)
    local obj = e:getData("veh >> ambulanceBedE")
    if e:getData("veh >> ambulanceBed") then -- Kivétel
        triggerServerEvent("Detach&Attach", localPlayer, localPlayer, e, obj)
        --exports['cr_chat']:createMessage(localPlayer, "kivesz majd elkezd tolni egy hordágyat", 1)
    else -- Berakás
        triggerServerEvent("Detach&Attach2", localPlayer, localPlayer, e, obj)
        --exports['cr_chat']:createMessage(localPlayer, "berak egy hordágyat a mentőautóba", 1)
    end
    
    --e:setData("veh >> ambulanceBed", not e:getData("veh >> ambulanceBed")) 
end

function interactAmbulanceBed2(e)
    --outputChatBox("asd")
    local obj = e:getData("veh >> ambulanceBedE")
    triggerServerEvent("Detach&Attach3", localPlayer, localPlayer, e)
end

function toggleMoveControls(val)
    exports['cr_controls']:toggleControl("forwards", value, "instant")
    exports['cr_controls']:toggleControl("backwards", value, "instant")
    exports['cr_controls']:toggleControl("left", value, "instant")
    exports['cr_controls']:toggleControl("right", value, "instant")
    exports['cr_controls']:toggleControl("jump", value, "instant")
    exports['cr_controls']:toggleControl("fire", value, "instant")
    exports['cr_controls']:toggleControl("aim_weapon", value, "instant")
    exports['cr_controls']:toggleControl("enter_exit", value, "instant")
    exports['cr_controls']:toggleControl("action", false, "instant")
end

function setPedDucked(ped, bool)
	local alreadyDucked = isPedDucked(ped)
	if (alreadyDucked and not bool) then
		setPedControlState(ped, "crouch", true)
		setTimer(setPedControlState, 50, 1, ped, "crouch", false)
		return true
	elseif (not alreadyDucked and bool) then
		setPedControlState(ped, "crouch", true)
		setTimer(setPedControlState, 50, 1, ped, "crouch", false)
		return true
	end
	return false
end

addEvent("doAmbulanceBed", true)
addEventHandler("doAmbulanceBed", localPlayer,
    function(ignore)
        setPedDucked(localPlayer, false)
        moveDisable = setTimer(toggleMoveControls, 50, 0, false)
        addEventHandler("onClientRender", root, drawnText, true, "low-5")
        bindKey("x", "down", placeAmbulanceBed)
        if ignore then
            exports['cr_chat']:createMessage(localPlayer, "újra elkezdi tolni a hordágyat", 1)
        else
            exports['cr_chat']:createMessage(localPlayer, "kivesz majd elkezd tolni egy hordágyat", 1)
        end
    end
)

addEvent("stopDoingAmbulanceBed", true)
addEventHandler("stopDoingAmbulanceBed", localPlayer,
    function(ignore)
        if isTimer(moveDisable) then killTimer(moveDisable) end
        toggleMoveControls(true)
        unbindKey("x", "down", placeAmbulanceBed)
        removeEventHandler("onClientRender", root, drawnText)
        exports['cr_death-system']:resetBone()
        if ignore then
            exports['cr_chat']:createMessage(localPlayer, "abbahagyja a hordágy tolását", 1)
        else
            exports['cr_chat']:createMessage(localPlayer, "berak egy hordágyat a mentőautóba", 1)
        end
    end
)

local sx, sy = guiGetScreenSize()
function drawnText()
    font = exports['cr_fonts']:getFont("Roboto", 11)
    green = exports['cr_core']:getServerColor(nil, true)
    local text = "A hordágy lehelyezéséhez használd a "..green.."'X'#ffffff billentyűt"
    local width = dxGetTextWidth(text, 1, font, true) + 20
    local height = dxGetFontHeight(1, font) + 10
    dxDrawRectangle(sx/2 - width/2, 50 - height/2, width, height, tocolor(0,0,0,180))
    dxDrawText(text, sx/2, 50, sx/2, 50, tocolor(255,255,255,255),1, font, "center", "center", false, false, false, true)
    --dxDrawText("A hordágy lehelyezéséhez használd a 'space' billentyűt", sx/2-1, 50, sx/2-1, 50, tocolor(0,0,0,255), 1, font, "center", "center")
    --dxDrawText("A hordágy lehelyezéséhez használd a 'space' billentyűt", sx/2, 50+1, sx/2, 50+1, tocolor(0,0,0,255), 1, font, "center", "center")
    --dxDrawText("A hordágy lehelyezéséhez használd a 'space' billentyűt", sx/2, 50-1, sx/2, 50-1, tocolor(0,0,0,255), 1, font, "center", "center")
    --dxDrawText("A hordágy lehelyezéséhez használd a "..green.."'space'#ffffff billentyűt", sx/2, 50, sx/2, 50, tocolor(255,255,255,255), 1, font, "center", "center", false, false, false, true)
end

function placeAmbulanceBed()
    triggerServerEvent("placeAmbulanceBed", localPlayer, localPlayer)
end

--localPlayer:setData("objInHand", nil)

function hasPermissionToDoAmbulanceBedPlacePlayer(e)
    if not e:getData("char >> inAmbulanceBed") then
        local fAnim = e:getData("forceAnimation") or {"", ""}
        if getPedAnimation(e) or fAnim[1] ~= "" and fAnim[2] ~= "" then
            return true
        end
    end
    return false
end

function doAmbulanceBedPlacePlayer(e)
    if not e:getData("char >> inAmbulanceBed") then
        local fAnim = e:getData("forceAnimation") or {"", ""}
        if getPedAnimation(e) or fAnim[1] ~= "" and fAnim[2] ~= "" then
            local nearest = 99999
            local nearestE = nil
            local valid = false
            for k,v in pairs(getElementsByType("object")) do
                if v.model == 11625 then
                    local dist = getDistanceBetweenPoints3D(e.position, v.position)
                    if dist <= 3 then
                        if dist <= nearest then
                            if not v:getData("isPlayerInBed") then
                                nearestE = v
                                nearest = dist
                                valid = true
                            end
                        end
                    end
                end
            end
            if valid then
                triggerServerEvent("doAmbulanceBedPlacePlayer", e, e, nearestE)
                exports['cr_chat']:createMessage(localPlayer, "ráhelyez egy embert a hordágyra ("..exports['cr_admin']:getAdminName(e)..")", 1)
            else
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "Nincs a közeledben 1 hordágy sem!", 255,255,255,true)
            end
        else
            local syntax = exports['cr_core']:getServerSyntax(nil, "error")
            outputChatBox(syntax .. "A célpontnak animációban kell lennie!", 255,255,255,true)
        end    
    else
        triggerServerEvent("stopDoingAmbulanceBedPlacePlayer", e, e)
        --e:setData("char >> inAmbulanceBed", nil)
        --e:setData("char >> inAmbulanceBedE", nil)
        exports['cr_chat']:createMessage(localPlayer, "lehelyez egy embert a hordágyról ("..exports['cr_admin']:getAdminName(e)..")", 1)
    end
end

--AttachSync
addEventHandler("onClientElementDataChange", root,
    function(dName)
        if dName == "char >> inAmbulanceBedE" then
            local value = source:getData(dName)
            if value then
                startSync(source, value)
            else
                stopSync(source)
            end
        end
    end
)

local syncCache = {}

function startSync(e, e2)
    if not syncCache[e] then
        syncCache[e] = e2
        --setPedAnimation(player, "CRACK", "crckidle1", -1, true, false, false)
    end
end

function stopSync(e)
    if syncCache[e] then
        syncCache[e] = nil
    end
end    
addEventHandler("onClientPlayerQuit", root,
    function()
        stopSync(source)
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(getElementsByType("player")) do
            if v:getData("char >> inAmbulanceBedE") then
                local value = v:getData("char >> inAmbulanceBedE")
                startSync(v, value)
            end
        end
    end
)

setTimer(
    function()
        for k,v in pairs(syncCache) do
            local player = k
            --local desiredRelativePosition = Vector3(0, -1.5, 1)
            --local matrix = v.matrix
            --local newPosition = matrix:transformPosition(desiredRelativePosition)
            --player.position = newPosition
            player.rotation = v.rotation
            local anim1, anim2 = getPedAnimation(player)
            if not getPedAnimation(player) then
                --outputChatBox("asd")
                setPedAnimation(player, "CRACK", "crckidle1", -1, true, false, false)
            elseif anim1 ~= "crack" or anim2 ~= "crckidle1" then
                --outputChatBox(anim1)
                setPedAnimation(player, "CRACK", "crckidle1", -1, true, false, false)
            end
        end
    end, 50, 0
)