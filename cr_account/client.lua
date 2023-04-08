sx, sy = guiGetScreenSize()
screenSize = {sx, sy}
saveJSON = {}

function onLoginStart()
    local data = exports['cr_json']:jsonGET("login/data.json", true, {["Username"] = base64Encode("Felhasználónév"), ["Password"] = base64Encode("Jelszó"), ["Clicked"] = false, ["haveRPTest"] = false, ["haveFirstTour"] = false, ["soundVolume"] = 1, ["canSeePassword"] = false}) or {["Username"] = base64Encode("Felhasználónév"), ["Password"] = base64Encode("Jelszó"), ["Clicked"] = false, ["haveRPTest"] = false, ["haveFirstTour"] = false, ["soundVolume"] = 1, ['soundActive'] = true, ["canSeePassword"] = false}

    saveJSON = data
    if saveJSON["Username"] ~= "" and saveJSON["Username"] ~= " " then
        saveJSON["Username"] = base64Decode(saveJSON["Username"] or "")
    end
    
    if saveJSON["Password"] ~= "" and saveJSON["Password"] ~= " " then
        saveJSON["Password"] = base64Decode(saveJSON["Password"] or "")
    end
    --Fontok, színek lekérdezése és táblába foglalása, Szituáció elkezdése, login beindítása
    if language == "Unknown" then
        language = getElementData(localPlayer, "language") or "HU"
    end
    
    setTimer(
        function()
            triggerServerEvent("player.banCheck", localPlayer, localPlayer)
        end, 5000, 1
    )
end
addEventHandler("onClientResourceStart", resourceRoot, onLoginStart)

function banResult(boolean)
    --boolean = true
    if boolean then
        --CreateBan
        if not localPlayer:getData("loggedIn") then
            --localPlayer:setData("destroyLV", true)
            exports['cr_blur']:createBlur("Loginblur", 5)
            showCursor(true)
            fadeCamera(true)
            --toggleAllControls(false, false)
            exports['cr_controls']:toggleAllControls(false, "low")
            --exports['cr_custom-chat']:showChat(false)
            showChat(false)
            startBanPanel()
            playSound(":cr_death-system/sounds/backgroundSound.mp3", true)

            createSituation(math.random(1, #cameraPos), true)
        else
            triggerServerEvent("acheat:kick", localPlayer, localPlayer)
        end
    else
        if not localPlayer:getData("loggedIn") then
            --localPlayer:setData("destroyLV", true)
            exports['cr_blur']:createBlur("Loginblur", 5)
            startLoginSound()
            startLoginPanel()
            fadeCamera(true)
            --toggleAllControls(false, false)
            exports['cr_controls']:toggleAllControls(false, "low")
            --exports['cr_custom-chat']:showChat(false)
            showChat(false)
            --createLogoAnimation(1, {sx/2, sy/2 - 190})
            createSituation(math.random(1, #cameraPos), true)
        else
            setTimer(
                function()
                    if not getElementData(localPlayer, "char >> afk") then
                        local oPlayTime = getElementData(localPlayer, "char >> playedtime")
                        setElementData(localPlayer, "char >> playedtime", oPlayTime + 1)
                    end
                end, 60 * 1000, 0
            )
        end
    end
end
addEvent("banResult", true)
addEventHandler("banResult", root, banResult)

function onLoginStop()
    if saveJSON["Username"] ~= "" and saveJSON["Username"] ~= " " then
        saveJSON["Username"] = base64Encode(saveJSON["Username"])
    end
    
    if saveJSON["Password"] ~= "" and saveJSON["Password"] ~= " " then
        saveJSON["Password"] = base64Encode(saveJSON["Password"])
    end
    exports['cr_json']:jsonSAVE("login/data.json", saveJSON, true)
    exports['cr_blur']:removeBlur("Loginblur")
end
addEventHandler("onClientResourceStop", resourceRoot, onLoginStop)

screenSize = {guiGetScreenSize()}
getCursorPos = getCursorPosition
function getCursorPosition()
    if isCursorShowing() then
        local x,y = getCursorPos()
        x, y = x * screenSize[1], y * screenSize[2] 
        return x,y
    else
        return -5000, -5000
    end
end

cursorState = isCursorShowing()
cursorX, cursorY = getCursorPosition()

function isInBox(dX, dY, dSZ, dM, eX, eY)
    if eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM then
        return true
    else
        return false
    end
end

function isInSlot(xS,yS,wS,hS)
    if isCursorShowing() then
        local cursorX, cursorY = getCursorPosition()
        if isInBox(xS,yS,wS,hS, cursorX, cursorY) then
            return true
        else
            return false
        end
    end 
end

function createTextBars(type)
    if type == "Login" then
        local text = saveJSON["Username"]
        if text:gsub(" ", "") == "" then
            text = "Felhasználónév / E-mail cím"
        end
        CreateNewBar("Login.Name", {0,0,0,0}, {29, text, false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", false}, 1)
        
        local text = saveJSON["Password"]
        if text:gsub(" ", "") == "" then
            text = "Jelszó"
        end
        CreateNewBar("Login.Password", {0,0,0,0}, {29, text, false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", not saveJSON["canSeePassword"]}, 2, true)
    elseif type == "Register" then
        local screen = {guiGetScreenSize()}
        local defSize = {0,0}
        local defMid = {0,0}
        
        local text = saveJSON["Username"]
        if text:gsub(" ", "") == "" then
            text = "Felhasználónév"
        end
        CreateNewBar("Register.Name", {defMid[1], defMid[2], defSize[1], defSize[2]}, {29, text, false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", false}, 1)
        
        local text = ""
        if text:gsub(" ", "") == "" then
            text = "E-mail cím"
        end
        CreateNewBar("Register.Email", {defMid[1], defMid[2] + 32, defSize[1], defSize[2]}, {29, text, false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", false}, 2)
        
        local text = saveJSON["Password"]
        if text:gsub(" ", "") == "" then
            text = "Jelszó"
        end
        CreateNewBar("Register.Password1", {defMid[1], defMid[2] + 64, defSize[1], defSize[2]}, {29, text, false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", not saveJSON["canSeePassword"]}, 3)
        
        local text = saveJSON["Password"]
        if text:gsub(" ", "") == "" then
            text = "Jelszó"
        end
        CreateNewBar("Register.Password2", {defMid[1], defMid[2] + 96, defSize[1], defSize[2]}, {29, text, false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", not saveJSON["canSeePassword"]}, 4)
        
        local text = ""
        if text:gsub(" ", "") == "" then
            text = "Meghívó kód"
        end
        CreateNewBar("Register.InviteCode", {defMid[1], defMid[2] + 128, defSize[1], defSize[2]}, {29, text, true, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center"}, 4, true)
    elseif type == "Age" then
        CreateNewBar("Char-Reg.Age", {sx/2 - 300/2, sy/2 - 40/2, 300, 40}, {2, "", true, tocolor(255,255,255,255), {"FontAwesome", 12}, 1, "center", "center", false}, 1, true)
    end
end

function dxDrawBorder(x, y, w, h, radius, color)
	dxDrawRectangle(x - radius, y, radius, h, color)
	dxDrawRectangle(x + w, y, radius, h, color)
	dxDrawRectangle(x - radius, y - radius, w + (radius * 2), radius, color)
	dxDrawRectangle(x - radius, y + h, w + (radius * 2), radius, color)
end

function dxCreateBorder(x,y,w,h,color)
	dxDrawRectangle(x,y-1,w+1,1,color) -- Fent
	dxDrawRectangle(x,y+1,1,h,color) -- Bal Oldal
	dxDrawRectangle(x+1,y+h,w,1,color) -- Lent Oldal
	dxDrawRectangle(x+w,y-1,1,h+1,color) -- Jobb Oldal
end

local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil

local function removeCamHandler()
    if(sm.moov == 1)then
	   sm.moov = 0
       showLoginChar = true  
    end
end

local function camRender()
    if (sm.moov == 1) then
	   local x1,y1,z1 = getElementPosition(sm.object1)
	   local x2,y2,z2 = getElementPosition(sm.object2)
	   setCameraMatrix(x1,y1,z1,x2,y2,z2)
    end
end
addEventHandler("onClientPreRender",root,camRender)

function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
    if(sm.moov == 1)then return false end
        sm.object1 = createObject(1337,x1,y1,z1)
        setElementData(sm.object1,"camObj",true)
        sm.object2 = createObject(1337,x1t,y1t,z1t)
        setElementAlpha(sm.object1,0)
        setElementAlpha(sm.object2,0)
        setObjectScale(sm.object1,0.01)
        setObjectScale(sm.object2,0.01)
        moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
        moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
        sm.moov = 1
        setTimer(removeCamHandler,time,1)
        setTimer(destroyElement,time,1,sm.object1)
        setTimer(destroyElement,time,1,sm.object2)
    return true
end

function dxCreateBorder(x, y, w, h, radius, color)
	dxDrawRectangle(x - radius, y, radius, h, color)
	dxDrawRectangle(x + w, y, radius, h, color)
	dxDrawRectangle(x - radius, y - radius, w + (radius * 2), radius, color)
	dxDrawRectangle(x - radius, y + h, w + (radius * 2), radius, color)
end

function playVideo (posX, posY, width, height, url, duration, canClose, postGUI)
    if not posX or not posY or not width or not height or not url then
        return false
    end
    local webBrowser = false
    if not isElement (webBrowser) then
        webBrowser = createBrowser (width, height, false, false)
        addEventHandler("onClientBrowserCreated", webBrowser, function()
            loadBrowserURL (source, url)
            addEventHandler ( "onClientBrowserDocumentReady" , source , function (url) 
                function webBrowserRender ()
                    dxDrawImage (posX, posY, width, height, webBrowser, 0, 0, 0, tocolor(255,255,255,255), postGUI)
                end
                addEventHandler ("onClientRender", getRootElement(), webBrowserRender)
            end)
        end)    
    end
end