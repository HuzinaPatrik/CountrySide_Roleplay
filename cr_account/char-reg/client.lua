local charReg = {}
local font, tWidth, selected, cSelected, altPageSelected, altPageFading
local se = 0
local iState = "?"

pSkins = {
    --[[
    [Nemzetiség (A panel sorrendje alapján)] = {
        [1 = FÉRFI] = {Skinek pld: 107, 109},
        [2 = NŐ] = {Skinek pld: 107, 109},
    },
    ]]
    [1] = { -- európai
        [1] = {29, 23, 27},
        [2] = {11, 31, 41},
    },
    [2] = { -- amerikai
        [1] = {7, 2, 1},
        [2] = {10, 40, 69},
    },
    [3] = { -- ázsiai
        [1] = {57, 58, 49},
        [2] = {169, 56, 141},
    },
    [4] = { -- afrikai
        [1] = {17, 21, 22},
        [2] = {13,  195, 245},
    },
}

anims = {
    {"DANCING", "DAN_Right_A", -1, true, false, false},
    {"DANCING", "DAN_Down_A", -1, true, false, false},
    {"DANCING", "dnce_M_d", -1, true, false, false},
    {"DANCING", "dance_loop", -1, true, false, false},
    {"DANCING", "dnce_m_c", -1, true, false, false},
    {"DANCING", "dnce_m_e", -1, true, false, false},
    {"DANCING", "dnce_m_a", -1, true, false, false},
    {"DANCING", "dan_up_a", -1, true, false, false},
    {"DANCING", "dan_left_a", -1, true, false, false},
}

function startCharReg()
    --requestTextBars
    setCameraMatrix(2265.8088378906, -99.119003295898, 30.728500366211, 2265.7829589844, -98.142280578613, 30.51554107666)
    stopSituations()
    details = {}
    stopLoginPanel()
    stopLoginSound()
    stopLogoAnimation()
    localPlayer:setData("keysDenied", true)
    localPlayer:setData("hudVisible", false)
    page = "CharReg"
    iState = "start"
    exports['cr_blur']:removeBlur("Loginblur")

    id = 1
    local skin = pSkins[1][1][id]
    skinPed = createPed(skin, 2265.6577148438, -88.479804992676, 26.484375, 179.60049438477)
    skinPed:setFrozen(true)
    skinPed:setDimension(localPlayer:getDimension())
    skinPed:setInterior(localPlayer:getInterior())
    --local anim = (anims[math.random(1,#anims)])
    --skinPed:setAnimation(unpack(anim))

    exports['cr_infobox']:addBox('info', 'Mivel nincs karaktered, hozz létre egyet!')

    setTimer(startCharRegPanel, 1500, 1)
end
addEvent("Start.Char-Register", true)
addEventHandler("Start.Char-Register", root, startCharReg)

function stopCharacterRegistration()
    Clear()
    destroyRender("drawnCharRegPanel")

    details["skin"] = pSkins[details["nationality"]][cSelected][id] --skinPed.model
    skinPed:destroy()
    exports['cr_infobox']:addBox("success", "Sikeres karakterkészítés!")

    unbindKey("mouse_wheel_up", "down", selectorUp)
    unbindKey("mouse_wheel_down", "down", selectorDown)

    local t = {getElementData(localPlayer, "acc >> username"), getElementData(localPlayer, "acc >> id")}
    triggerServerEvent("character.Register", localPlayer, localPlayer, details, t)
    --startTour()
    startVideo()
end

local isRender
function startCharRegPanel()
    nationality = 1
    details["nationality"] = nationality
    age = 22
    details["age"] = age
    weight = 65
    details["weight"] = weight
    height = 175
    details["height"] = height

    id = 1
    local skin = pSkins[nationality][1][id]
    skinPed:setModel(skin)

    cHover = nil
    cSelected = 1
    iState = "Char-Reg>Panel"
    exports["cr_blur"]:removeBlur("boxBlur")

    bindKey("mouse_wheel_up", "down", selectorUp)
    bindKey("mouse_wheel_down", "down", selectorDown)

    isRender = true

    createRender("drawnCharRegPanel", drawnCharRegPanel)

    exports['cr_dx']:startFade("drawnCharRegPanel", 
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

    font = exports['cr_fonts']:getFont("RobotoB", 10)
    tWidth = math.floor(dxGetTextWidth("Kinézet választása", 1, font, true) + 10)

    local font = exports['cr_fonts']:getFont("Roboto", 11)
    CreateNewBar("Char-Reg.Name", {0,0,0,0}, {30, "Karakter név", false, tocolor(255,255,255,255), {"Poppins-Medium", 14}, 1, "center", "center", false}, 1)
end

function stopCharRegPanel()
    local height = tonumber(details["height"]) or 0
    local age = tonumber(details["age"]) or 0
    local weight = tonumber(details["weight"]) or 0
    local name = (GetText("Char-Reg.Name")) or ""

    if height < 150 or height > 220  then
        exports['cr_infobox']:addBox("error", "A magasságodnak egy számnak kell lennie mely 150 - 220 között van!")
        return
    end

    if weight < 60 or weight > 120  then
        exports['cr_infobox']:addBox("error", "A súlyodnak egy számnak kell lennie mely 60 - 120 között van!")
        return
    end

    if age < 18 or age > 80 then
        exports['cr_infobox']:addBox("error", "Az életkorodnak egy számnak kell lennie mely 18 - 80 között van!")
        return
    end

    name = name:gsub("_", " ")
    name = name:gsub("%p", " ")
    local fullName = ""
    local count = 1

    while true do
        local a = gettok(name, count, string.byte(' '))
        if a then
            if #a <= 2 then
                exports['cr_infobox']:addBox("error", "A név amit megadtál hibás!")
                return
            end
            count = count + 1
            a = a .. "_"
            a = string.upper(utfSub(a, 1, 1)) .. string.lower(utfSub(a, 2, #a))
            fullName = fullName .. a
        else
            break
        end
    end

    if utfSub(fullName, #fullName, #fullName) == "_" then
        fullName = utfSub(fullName, 1, #fullName - 1)
    end


    if count < 3 then
        exports['cr_infobox']:addBox("error", "A névnek minimum 2 részletből kell álljon!")
        return
    end

    if name ~= exports['cr_chat']:findSwear(name) then
        exports['cr_infobox']:addBox("error", "A nevedben tiltott szavak találhatóak!")
        return
    end

    if lastClickTick + 1000 > getTickCount() then
        return
    end
    lastClickTick = getTickCount()

    details["neme"] = cSelected
    details["age"] = age
    local time = getBornTime(age)
    details["born"] = time
    details["height"] = height
    details["weight"] = weight

    local b = fullName
    --outputChatBox(b)
    triggerServerEvent("checkNameRegistered", localPlayer, localPlayer, b)

    --start = false
    --statTick = getTickCount()
end

addEvent("receiveNameRegisterable", true)
addEventHandler("receiveNameRegisterable", root,
    function(a, b)
        if a then
            details["name"] = b
            
            isRender = false 

            exports['cr_dx']:startFade("drawnCharRegPanel", 
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
        else
            exports['cr_infobox']:addBox("error", "A név amit megadtál már foglalt!")
            return
        end
    end
)

function drawnCharRegPanel()
    local alpha, progress = exports['cr_dx']:getFade("drawnCharRegPanel")

    if not isRender then 
        if progress >= 1 then
            stopCharacterRegistration()
            return
        end
    end

    cHover = nil

    local w, h, animProgress = 400, 300
    if altPageSelected or altPageFading then 
        h, animProgress = exports['cr_dx']:getFade("charRegPanel >> animState")

        if altPageFading then 
            if animProgress >= 1 then 
                altPageFading = false
            end 
        end 
    end  

    local x, y = 100, 100
    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    local logoW, logoH = 39, 45
    dxDrawImage(x + 20, y + 20, logoW, logoH, "files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 18)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    dxDrawText("Karakter testreszabása", x + 95, y + 20, x + 95, y + 20 + logoH, tocolor(229, 229, 229, alpha), 1, font, "left", "center")

    local w2, h2 = 320, 2
    dxDrawRectangle(x + w/2 - w2/2, y + 120, w2, h2, tocolor(165, 165, 165, alpha))
    UpdatePos("Char-Reg.Name", {x + w/2 - w2/2, y + 120 - 20, w2, 22})
    UpdateAlpha("Char-Reg.Name", tocolor(229, 229, 229, alpha * 0.5))

    dxDrawText("Nem:", x + w/2 - w2/2, y + 140, x + w/2 - w2/2, y + 140, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")

    dxDrawText("Nő", x + w/2 - w2/2 + 70, y + 140, x + w/2 - w2/2 + 70, y + 140, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")
    if isInSlot(x + w/2 - w2/2 + 55, y + 140 - 7, 10, 10) or cSelected == 2 then
        if isInSlot(x + w/2 - w2/2 + 55, y + 140 - 7, 10, 10) then
            cHover = "woman"
        end

        dxDrawImage(x + w/2 - w2/2 + 55, y + 140 - 7, 10, 10, "files/circle-selected.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    else 
        dxDrawImage(x + w/2 - w2/2 + 55, y + 140 - 7, 10, 10, "files/circle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    dxDrawText("Férfi", x + w/2 - w2/2 + 115, y + 140, x + w/2 - w2/2 + 115, y + 140, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")
    if isInSlot(x + w/2 - w2/2 + 100, y + 140 - 7, 10, 10) or cSelected == 1 then
        if isInSlot(x + w/2 - w2/2 + 100, y + 140 - 7, 10, 10) then
            cHover = "man"
        end

        dxDrawImage(x + w/2 - w2/2 + 100, y + 140 - 7, 10, 10, "files/circle-selected.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    else 
        dxDrawImage(x + w/2 - w2/2 + 100, y + 140 - 7, 10, 10, "files/circle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    dxDrawText("Rassz:", x + w/2 - w2/2, y + 170, x + w/2 - w2/2, y + 170, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")

    dxDrawText("Europid", x + w/2 - w2/2 + 70, y + 170, x + w/2 - w2/2 + 70, y + 170, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")
    if isInSlot(x + w/2 - w2/2 + 55, y + 170 - 7, 10, 10) or nationality == 1 then
        if isInSlot(x + w/2 - w2/2 + 55, y + 170 - 7, 10, 10) then
            cHover = "nationality.1"
        end

        dxDrawImage(x + w/2 - w2/2 + 55, y + 170 - 7, 10, 10, "files/circle-selected.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    else 
        dxDrawImage(x + w/2 - w2/2 + 55, y + 170 - 7, 10, 10, "files/circle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    dxDrawText("Mongoloid", x + w/2 - w2/2 + 150, y + 170, x + w/2 - w2/2 + 150, y + 170, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")
    if isInSlot(x + w/2 - w2/2 + 135, y + 170 - 7, 10, 10) or nationality == 2 then
        if isInSlot(x + w/2 - w2/2 + 135, y + 170 - 7, 10, 10) then
            cHover = "nationality.2"
        end

        dxDrawImage(x + w/2 - w2/2 + 135, y + 170 - 7, 10, 10, "files/circle-selected.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    else 
        dxDrawImage(x + w/2 - w2/2 + 135, y + 170 - 7, 10, 10, "files/circle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    dxDrawText("Negrid", x + w/2 - w2/2 + 250, y + 170, x + w/2 - w2/2 + 250, y + 170, tocolor(229, 229, 229, alpha), 1, font2, "left", "center")
    if isInSlot(x + w/2 - w2/2 + 235, y + 170 - 7, 10, 10) or nationality == 3 then
        if isInSlot(x + w/2 - w2/2 + 235, y + 170 - 7, 10, 10) then
            cHover = "nationality.3"
        end

        dxDrawImage(x + w/2 - w2/2 + 235, y + 170 - 7, 10, 10, "files/circle-selected.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    else 
        dxDrawImage(x + w/2 - w2/2 + 235, y + 170 - 7, 10, 10, "files/circle.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    end 

    if isInSlot(x + w/2 - w2/2, y + 190, 44, 20) or altPageSelected == 1 then 
        if isInSlot(x + w/2 - w2/2, y + 190, 44, 20) then 
            cHover = "age"
        end 
        dxDrawRectangle(x + w/2 - w2/2, y + 190, 44, 20, tocolor(255, 59, 59, alpha))
    else 
        dxDrawRectangle(x + w/2 - w2/2, y + 190, 44, 20, tocolor(242, 242, 242, alpha * 0.6))
    end 
    dxDrawText("Kor", x + w/2 - w2/2, y + 190, x + w/2 - w2/2 + 44, y + 190 + 20, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")

    if isInSlot(x + w/2 - w2/2 + 54, y + 190, 95, 20) or altPageSelected == 2 then 
        if isInSlot(x + w/2 - w2/2 + 54, y + 190, 95, 20) then 
            cHover = "height"
        end 
        dxDrawRectangle(x + w/2 - w2/2 + 54, y + 190, 95, 20, tocolor(255, 59, 59, alpha))
    else 
        dxDrawRectangle(x + w/2 - w2/2 + 54, y + 190, 95, 20, tocolor(242, 242, 242, alpha * 0.6))
    end 
    dxDrawText("Magasság", x + w/2 - w2/2 + 54, y + 190, x + w/2 - w2/2 + 54 + 95, y + 190 + 20, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")

    if isInSlot(x + w/2 - w2/2 + 54 + 105, y + 190, 50, 20) or altPageSelected == 3 then
        if isInSlot(x + w/2 - w2/2 + 54 + 105, y + 190, 50, 20) then 
            cHover = "weight"
        end 
        dxDrawRectangle(x + w/2 - w2/2 + 54 + 105, y + 190, 50, 20, tocolor(255, 59, 59, alpha))
    else 
        dxDrawRectangle(x + w/2 - w2/2 + 54 + 105, y + 190, 50, 20, tocolor(242, 242, 242, alpha * 0.6))
    end 
    dxDrawText("Súly", x + w/2 - w2/2 + 54 + 105, y + 190, x + w/2 - w2/2 + 54 + 105 + 50, y + 190 + 20, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")

    if altPageSelected then 
        if animProgress >= 1 then 
            if altPageSelected == 1 then -- Kor
                local selectorW, selectorH = 320, 45
                dxDrawImage(x + w/2 - selectorW/2, y + h - 95 - selectorH, selectorW, selectorH, "files/selector-frame.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                if isInSlot(x + w/2 - selectorW/2, y + h - 95 - selectorH, selectorW, selectorH) then 
                    cHover = "selector"
                end 
                dxDrawText(age .. " év", x + w/2, y + h - 95 - selectorH - 20, x + w/2, y + h - 95 - selectorH - 20, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
                dxDrawText(age - 2, x + w/2 - selectorW/2 + 55, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 55, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(age - 1, x + w/2 - selectorW/2 + 125, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 125, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(age + 1, x + w/2 - selectorW/2 + 195, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 195, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(age + 2, x + w/2 - selectorW/2 + 265, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 265, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
            elseif altPageSelected == 2 then -- Magasság
                local selectorW, selectorH = 320, 45
                dxDrawImage(x + w/2 - selectorW/2, y + h - 95 - selectorH, selectorW, selectorH, "files/selector-frame.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                if isInSlot(x + w/2 - selectorW/2, y + h - 95 - selectorH, selectorW, selectorH) then 
                    cHover = "selector"
                end 
                dxDrawText(height .. " cm", x + w/2, y + h - 95 - selectorH - 20, x + w/2, y + h - 95 - selectorH - 20, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
                dxDrawText(height - 10, x + w/2 - selectorW/2 + 55, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 55, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(height - 5, x + w/2 - selectorW/2 + 125, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 125, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(height + 5, x + w/2 - selectorW/2 + 195, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 195, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(height + 10, x + w/2 - selectorW/2 + 265, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 265, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
            elseif altPageSelected == 3 then -- Súly
                local selectorW, selectorH = 320, 45
                dxDrawImage(x + w/2 - selectorW/2, y + h - 95 - selectorH, selectorW, selectorH, "files/selector-frame.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
                if isInSlot(x + w/2 - selectorW/2, y + h - 95 - selectorH, selectorW, selectorH) then 
                    cHover = "selector"
                end 
                dxDrawText(weight .. " kg", x + w/2, y + h - 95 - selectorH - 20, x + w/2, y + h - 95 - selectorH - 20, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
                dxDrawText(weight - 10, x + w/2 - selectorW/2 + 55, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 55, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(weight - 5, x + w/2 - selectorW/2 + 125, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 125, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(weight + 5, x + w/2 - selectorW/2 + 195, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 195, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
                dxDrawText(weight + 10, x + w/2 - selectorW/2 + 265, y + h - 95 - selectorH, x + w/2 - selectorW/2 + 265, y + h - 95, tocolor(242, 242, 242, alpha), 1, font2, "center", "top")
            end 
        end 
    end  

    if isInSlot(x + w/2 - 200/2, y + h - 60, 200, 35) then 
        cHover = "finishCharCreate"
        dxDrawRectangle(x + w/2 - 200/2, y + h - 60, 200, 35, tocolor(255, 59, 59, alpha))
    else 
        dxDrawRectangle(x + w/2 - 200/2, y + h - 60, 200, 35, tocolor(255, 59, 59, alpha * 0.7))
    end 
    dxDrawText("Létrehozás", x + w/2 - 200/2, y + h - 60, x + w/2 - 200/2 + 200, y + h - 60 + 35, tocolor(242, 242, 242, alpha), 1, font2, "center", "center")
end

function selectorDown()
    if cHover == "selector" then 
        if altPageSelected then  
            if altPageSelected == 1 then 
                age = math.max(18, age - 1)
                details["age"] = age
            elseif altPageSelected == 2 then 
                height = math.max(150, height - 5)
                details["height"] = height
            elseif altPageSelected == 3 then 
                weight = math.max(60, weight - 5)
                details["weight"] = weight
            end 
        end 
    end
end 

function selectorUp()
    if cHover == "selector" then 
        if altPageSelected then  
            if altPageSelected == 1 then 
                age = math.min(80, age + 1)
                details["age"] = age
            elseif altPageSelected == 2 then 
                height = math.min(220, height + 5)
                details["height"] = height
            elseif altPageSelected == 3 then 
                weight = math.min(120, weight + 5)
                details["weight"] = weight 
            end 
        end 
    end
end 

addEventHandler("onClientClick", root,
    function(b,s)
        if page == "CharReg" then
            if iState == "Char-Reg>Panel" then
                if b == "left" and s == "down" then
                    if cHover == "age" then 
                        if altPageSelected and altPageSelected == 1 then 
                            altPageSelected = nil 
                            altPageFading = true 

                            exports['cr_dx']:startFade("charRegPanel >> animState", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 400,
                                    ["to"] = 300,
                                    ["alpha"] = 400,
                                    ["progress"] = 0,
                                }
                            )
                        elseif not altPageFading and not altPageSelected then 
                            altPageSelected = 1 

                            exports['cr_dx']:startFade("charRegPanel >> animState", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 300,
                                    ["to"] = 400,
                                    ["alpha"] = 300,
                                    ["progress"] = 0,
                                }
                            )
                        end 
                    elseif cHover == "height" then 
                        if altPageSelected and altPageSelected == 2 then 
                            altPageSelected = nil 
                            altPageFading = true 

                            exports['cr_dx']:startFade("charRegPanel >> animState", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 400,
                                    ["to"] = 300,
                                    ["alpha"] = 400,
                                    ["progress"] = 0,
                                }
                            )
                        elseif not altPageFading and not altPageSelected then 
                            altPageSelected = 2

                            exports['cr_dx']:startFade("charRegPanel >> animState", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 300,
                                    ["to"] = 400,
                                    ["alpha"] = 300,
                                    ["progress"] = 0,
                                }
                            )
                        end 
                    elseif cHover == "weight" then 
                        if altPageSelected and altPageSelected == 3 then 
                            altPageSelected = nil 
                            altPageFading = true 

                            exports['cr_dx']:startFade("charRegPanel >> animState", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 400,
                                    ["to"] = 300,
                                    ["alpha"] = 400,
                                    ["progress"] = 0,
                                }
                            )
                        elseif not altPageFading and not altPageSelected then 
                            altPageSelected = 3 

                            exports['cr_dx']:startFade("charRegPanel >> animState", 
                                {
                                    ["startTick"] = getTickCount(),
                                    ["lastUpdateTick"] = getTickCount(),
                                    ["time"] = 250,
                                    ["animation"] = "InOutQuad",
                                    ["from"] = 300,
                                    ["to"] = 400,
                                    ["alpha"] = 300,
                                    ["progress"] = 0,
                                }
                            )
                        end 
                    elseif cHover == "nationality.1" then 
                        nationality = 1 
                        details["nationality"] = nationality

                        local newSkin = pSkins[details["nationality"]][cSelected][id]
                        if not newSkin then
                            id = 1
                            newSkin = pSkins[details["nationality"]][cSelected][id]
                        end
                        skinPed:setModel(newSkin)
                    elseif cHover == "nationality.2" then 
                        nationality = 2
                        details["nationality"] = nationality

                        local newSkin = pSkins[details["nationality"]][cSelected][id]
                        if not newSkin then
                            id = 1
                            newSkin = pSkins[details["nationality"]][cSelected][id]
                        end
                        skinPed:setModel(newSkin)
                    elseif cHover == "nationality.3" then 
                        nationality = 3
                        details["nationality"] = nationality

                        local newSkin = pSkins[details["nationality"]][cSelected][id]
                        if not newSkin then
                            id = 1
                            newSkin = pSkins[details["nationality"]][cSelected][id]
                        end
                        skinPed:setModel(newSkin)
                    elseif cHover == "woman" then
                        cSelected = 2
                        local newSkin = pSkins[details["nationality"]][cSelected][id]
                        if not newSkin then
                            id = 1
                            newSkin = pSkins[details["nationality"]][cSelected][id]
                        end
                        skinPed:setModel(newSkin)
                        --local anim = (anims[math.random(1,#anims)])
                        --skinPed:setAnimation(unpack(anim))
                    elseif cHover == "man" then
                        cSelected = 1
                        local newSkin = pSkins[details["nationality"]][cSelected][id]
                        if not newSkin then
                            id = 1
                            newSkin = pSkins[details["nationality"]][cSelected][id]
                        end
                        skinPed:setModel(newSkin)
                        --local anim = (anims[math.random(1,#anims)])
                        --skinPed:setAnimation(unpack(anim))
                    elseif cHover == "finishCharCreate" then
                        stopCharRegPanel()
                    end

                    cHover = nil 
                end
            end
        end
    end
)

-------------------------------------------------------------------------------------------------------------------------------------------------
addEvent("loadCharacter", true)
addEventHandler("loadCharacter", localPlayer,
    function(data)
        --[[đexports['cr_blur']:removeBlur("Loginblur")
        stopLoadingScreen()
        --triggerServerEvent("idg.login", localPlayer, localPlayer)
        toggleAllControls(true, true)
        setCameraTarget(localPlayer, localPlayer)
        --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
        fadeCamera(true, 0)--]]
        local position = data[3]
        if type(position) == "string" then
            position = fromJSON(position)
        end
        local x,y,z, dim,int,rot = unpack(position)
        x = tonumber(x)
        y = tonumber(y)
        z = tonumber(z)
        dim = tonumber(dim)
        int = tonumber(int)
        rot = tonumber(rot)

        local details = data[4]
        if type(details) == "string" then
            details = fromJSON(details)
        end

        local Health = tonumber(details['health'] or 100)
        local Armor = tonumber(details['armor'] or 0)
        local SkinID = tonumber(details['skin'])
        local Money = tonumber(details['money'])
        local PlayedTime = tonumber(details['playedTime'])
        local Level = tonumber(details['level'])
        local premiumPoints = tonumber(details['pp'])
        local job = tonumber(details['job'])
        local food = tonumber(details['food'])
        local drink = tonumber(details['drink'])
        local vehicleLimit = tonumber(details['vehicleLimit'])
        local interiorLimit = tonumber(details['interiorLimit'])
        local avatar = tonumber(details['avatar'])
        local isKnow = details['isKnow'] or {{["-5000"] = true}, {["-5000"] = true}}
        local Bones = details['bones'] or {true, true, true, true, true}
        local isHidden = details['isHidden'] or {}
        local BloodData = details['bloodData'] or {}
        local crosshair = tonumber(details['crosshair'] or 1)
        local crosshairColor = details['crosshairColor'] or {255, 255, 255}
        local stats = details['stats'] or {}
        local dutyDatas = details['dutyDatas'] or {false, nil}
        local cuffed = stringToBoolean(details['cuffed'])
        local bondage = stringToBoolean(details['bondage'])
        local blinded = stringToBoolean(details['blinded'])
        local jailData = details['jailData'] or {}
        local customInterior = details["customInterior"] or 0
        local blackJackCoins = details["blackJackCoins"] or {}
        
        local dutyState, dutySkin = unpack(dutyDatas)
        localPlayer:setData("char >> duty", dutyState)
        localPlayer:setData("char >> dutyskin", dutySkin)

        if tonumber(dutySkin) then 
            SkinID = tonumber(dutySkin)
        end 

        if not stats then 
            stats = {
                [69] = 0,
                [70] = 0,
                [71] = 0,
                [72] = 0,
                [73] = 0,
                [74] = 0,
                [75] = 0,
                [76] = 0,
                [77] = 0,
                [78] = 0,
                [79] = 0,
            }
        end 

        localPlayer:setData("char >> crosshair", crosshair)
        localPlayer:setData("char >> crosshairColor", crosshairColor)

        localPlayer:setData("char >> interiorLimit", interiorLimit)
        localPlayer:setData("char >> vehicleLimit", vehicleLimit)
        localPlayer:setData("char >> avatar", avatar)

        if Bones and type(Bones) == "string" then Bones = fromJSON(Bones) end
        if not Bones then
            Bones = {true, true, true, true, true}
        end
        --localPlayer:setData("char >> bone", Bones)

        if BloodData and type(BloodData) == "string" then BloodData = fromJSON(BloodData) end
        if not BloodData then
            BloodData = {}
        end
        localPlayer:setData("bloodData", BloodData)

        if isHidden and type(isHidden) == "string" then isHidden = fromJSON(isHidden) end
        if not isHidden then
            isHidden = {}
        end
        localPlayer:setData("weapons >> hidden", isHidden)

        --outputChatBox(tostring(isKnow) .. "-asd-" .. inspect(isKnow))
        if isKnow and type(isKnow) == "string" then isKnow = fromJSON(isKnow) end
        if not isKnow then
            isKnow = {{["-5000"] = true}, {["-5000"] = true}}
        end
        local debuts, friends = unpack(isKnow)

        local friend = {}
        if not friends then friends = {} end
        for k,v in pairs(friends) do
            friend[tonumber(k)] = v
        end

        local debut = {}
        if not debuts then debuts = {} end
        for k,v in pairs(debuts) do
            debut[tonumber(k)] = v
        end

        localPlayer:setData("friends", friend)
        localPlayer:setData("debuts", debut)

        localPlayer.position = Vector3(x,y,z)
        localPlayer:setDimension(dim)
        localPlayer:setInterior(int)

        local a = data[5]
        if type(a) == "string" then
            a = fromJSON(a)
        end
        if not a then
            a = {}
            a["neme"] = 1
            a["nationality"] = 1
            a["age"] = 18
            a["born"] = "2000.06.18"
            a["height"] = 180
            a["weight"] = 80
            a["fightStyle"] = 5
            a["walkStyle"] = 121
        end
        localPlayer:setData("char >> details", a)
        localPlayer:setData("char >> skin", SkinID)

        local neme, nationality, age, born, height, weight, fightStyle, walkStyle, description = a["neme"], a["nationality"], a["age"], a["born"], a["height"], a["weight"], a["fightStyle"], a["walkStyle"], a["description"]
        if not description then
            local a = "Ő egy XX cm magas, XY kg súlyú, XZ éves, XO nemzetiségű ember!"
            a = a:gsub("XX", height)
            a = a:gsub("XY", weight)
            a = a:gsub("XZ", age)
            a = a:gsub("XO", nationalityNumToString(nationality))
            description = a
        end
        localPlayer:setData("char >> description", description)

        local name = data[2]
        name = tostring(name)

        local deathDetails = data[6]
        if type(deathDetails) == "string" then
            deathDetails = fromJSON(deathDetails)
        end

        local dead = stringToBoolean(deathDetails['dead'])
        local reason = deathDetails['reason'] or {}
        local headless = stringToBoolean(deathDetails['headless'])
        local bulletsInBody = deathDetails['bulletsInBody'] or {}

        local adminDetails = data[7]
        if type(adminDetails) == "string" then
            adminDetails = fromJSON(adminDetails)
        end

        local alevel = tonumber(adminDetails['alevel'] or 0)
        local nick = adminDetails['nick'] or ''
        local aTime = tonumber(adminDetails['adutyTime'] or 0)
        local usedCmds = adminDetails['usedCmds'] or {}
        local ajail = adminDetails['ajail'] or {}

        alevel = tonumber(alevel)
        nick = tostring(nick)
        aTime = tonumber(aTime)

        if usedCmds then 
            for k, v in pairs(usedCmds) do 
                localPlayer:setData(k .. ' >> using', tonumber(v or 0))
            end 
        end 

        local groupID = tonumber(data[9] or 0)
        localPlayer:setData("char >> groupId", groupID)

        if ajail and #ajail > 0 then
            if ajail[1] and type(ajail[1]) == "boolean" then
                setElementData(localPlayer,"char >> ajail >> admin",ajail[4])
                setElementData(localPlayer,"char >> ajail >> type",ajail[3])
                setElementData(localPlayer,"char >> ajail >> time", ajail[5])
                setElementData(localPlayer,"char >> ajail >> aLevel", ajail[6])
                if ajail[1] then
                    setElementData(localPlayer,"char >> ajail", ajail[1])
                end
                setElementData(localPlayer,"char >> ajail >> reason", ajail[2])
            end
        end

        if jailData and #jailData > 0 then 
            localPlayer:setData("jail >> data", jailData)

            triggerEvent("faction.startJailTimer", localPlayer)
        end 

        localPlayer:setData("customInterior", customInterior)

        if customInterior and customInterior > 0 then 
            exports.cr_interior:loadCustomInterior(customInterior, localPlayer)
        end

        local newCoins = {}

        for k, v in pairs(blackJackCoins) do 
            newCoins[tonumber(k)] = v
        end

        localPlayer:setData("char >> blackJackCoins", newCoins)

        triggerServerEvent("spawnPl", localPlayer, localPlayer, SkinID, x,y,z, rot, dim,int, Health, Armor, fightStyle, walkStyle, reason, stats, Bones)

        localPlayer:setData("loggedIn", false)
        localPlayer:setData("char >> money", Money)
        localPlayer:setData("char >> playedtime", PlayedTime)
        localPlayer:setData("char >> level", Level)
        localPlayer:setData("char >> premiumPoints", premiumPoints)
        localPlayer:setData("char >> job", job)
        localPlayer:setData("char >> food", food)
        localPlayer:setData("char >> drink", drink)

        local fullName = ""
        local count = 1
        name = name:gsub("_", " ")

        while true do
            local a = gettok(name, count, string.byte(' '))
            if a then
                count = count + 1
                if gettok(name, count, string.byte(' ')) then
                    a = a .. "_"
                end
                a = string.upper(utfSub(a, 1, 1)) .. string.lower(utfSub(a, 2, #a))
                fullName = fullName .. a
            else
                break
            end
        end

        localPlayer:setData("char >> name", fullName)
        localPlayer:setData("destroyLV", true)

        setTimer(
            function()
                if not getElementData(localPlayer, "char >> afk") then
                    local oPlayTime = getElementData(localPlayer, "char >> playedtime")
                    localPlayer:setData("char >> playedtime", oPlayTime + 1)
                end
            end, 60 * 1000, 0
        )

        exports['cr_core']:setElementData(localPlayer, "admin >> level", alevel)
        localPlayer:setData("admin >> name", nick)
        localPlayer:setData("admin >> time", aTime)

        localPlayer:setData("char >> bondage", bondage)
        localPlayer:setData("char >> blinded", blinded)
        localPlayer:setData("char >> cuffed", cuffed)

        local deathReasons = reason
        localPlayer:setData("char >> death", dead)
        localPlayer:setData("deathReason", deathReasons[1])
        localPlayer:setData("deathReason >> admin", deathReasons[2])
        localPlayer:setData("char >> headless", headless)
        localPlayer:setData("bulletsInBody", bulletsInBody)
    end
)

local state, cache = false, {}

function exist(e)
    for k,v in pairs(cache) do
        if v[1] == e then
            return true
        end
    end

    return false
end

function loadPlayer(e)
    if exist(e) then
        return
    end

    local start = getTickCount()
    table.insert(cache, {e, start, start + 7500})
    setElementAlpha(e, 50)

    if not state then
        state = true
        addEventHandler("onClientRender", root, loadPlayers, true, "low-5")
    end
end

function loadPlayers()
    if #cache == 0 then
        state = false
        removeEventHandler("onClientRender", root, loadPlayers)
    end

    local now = getTickCount()
    for k,v in pairs(cache) do
        local e, startTime, endTime= unpack(v)
        if isElement(e) then
            local elapsedTime = now - startTime
            local duration = endTime - startTime
            local progress = elapsedTime / duration

            local a = interpolateBetween(
                50, 0, 0,
                255, 0, 0,
                progress, "Linear"
            )

            setElementAlpha(e, a)

            if progress >= 1 then
                if e == localPlayer then
                    setElementData(e, "loading", false)
                    triggerServerEvent("playerAlpha", localPlayer, localPlayer)
                end
                --szerooldali trigger
                table.remove(cache, k)
            end
        else
            table.remove(cache, k)
        end
    end
end

addEventHandler("onClientElementDataChange", root,
    function(dName, oValue, nValue)
        if dName == "loading" then
            if nValue then
                if isElementStreamedIn(source) then
                    loadPlayer(source)
                end
            end
        end
    end
)
