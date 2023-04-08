local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

local sx,sy = guiGetScreenSize()
local screenSource = dxCreateScreenSource(sx, sy)

blackWhiteShader, blackWhiteTec = dxCreateShader("files/blackwhite.fx")

function black()
    if (blackWhiteShader) then
        dxUpdateScreenSource(screenSource)     
        dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
        dxDrawImage(0, 0, sx, sy, blackWhiteShader)
    end
end

local white = "#ffffff"
local fontsize = 1

local questions = {
    --[id] = {"Válasz?","válasz1","válasz2","válasz3",helyes válasz1-3},
    [1] = {"Mi az a Meta Gaming?","IC információ felhasználása OOC","OOC információ felhasználása IC","IC információ felhasználása PG",2},
    [2] = {"Mit teszel, ha bugot találsz?","Jelentem azonnal egy adminnak.","Szólok egy havernak.","Kihasználom.",1},
    [3] = {"Mit teszel, ha valaki szid téged IC?","Szólok egy adminnak.","Felteszem PK-ra.","IC kezelem a konfliktust.",3},
}

local question = false
local buttonHover
local panel = false
local sound = false
local sound2 = false
local jailTimer = false
local min = 0
local ped = nil
col = createColSphere(2494.3303222656, -1704.5909423828, 1014.7421875,50)

local fucker = {}

local size = {
    ["qBox2"] = {250, 30},
    ["qBox3"] = {160, 30},
}

local buttons = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false
}

function generate_question()
    buttonHover = nil
    local random = math.random(1,#questions)
    question = random
    width,height = 0,300
    left,top = (sx/2)-(width/2),(sy/2)-(height/2)

 	if not panel then
        panel = true
        activeTestID = 0
        --addEventHandler("onClientRender",root,draw_questions)
        exports['cr_dx']:startFade("questionPanel", 
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
        createRender("draw_questions", draw_questions)
   	end
end

function onStart()
    if getElementData(localPlayer,"loggedIn") and getElementData(localPlayer,"char >> ajail") then
        changeJail()
    end
end
addEventHandler("onClientResourceStart",resourceRoot,onStart)

function generate_fucker()
    buttonHover = nil 

    fucker["1"] = math.random(math.random(1,50),math.random(51,99))
    fucker["2"] = math.random(math.random(1,50),math.random(51,99))
    fucker["3"] = math.random(math.random(1,50),math.random(51,99))
    fucker["4"] = math.random(math.random(1,50),math.random(51,99))
    fucker[1] = "Mennyi "..fucker["4"].."+"..fucker["1"].."x"..fucker["2"].."-"..fucker["3"].."?"

    fucker[2] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"] + math.random(1,5)
    fucker[3] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"] - math.random(1,9)
    fucker[4] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"] + math.random(6,9)

    fucker[5] = math.random(1,3)
    fucker[(1+fucker[5])] = fucker["4"]+fucker["1"]*fucker["2"]-fucker["3"]

    width,height = 0,300
    left,top = (sx/2)-(width/2),(sy/2)-(height/2)

    if not panel then
        panel = true
        activeTestID = 0
        exports['cr_dx']:startFade("fuckerPanel", 
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

        createRender("draw_fucker", draw_fucker)
    end
end

function colLeave(theElement)
    if (theElement == localPlayer) and getElementData(localPlayer,"char >> ajail") then
        if source == col then
        	changeJail()
        end
    end
end
addEventHandler("onClientColShapeLeave", root, colLeave)

function runTest()
    if panel then
        panel = false
        --removeEventHandler("onClientRender",root,draw_questions)
        exports['cr_dx']:startFade("questionPanel", 
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
        
        if questions[question][5] == activeTestID then -- ide kell típus szerinti + vagy - percre
            local syntax = exports['cr_core']:getServerSyntax("Jail", "success")
            outputChatBox(syntax.."Jó válasz, ezért 3 percet levonunk a büntetésedből!",0,0,0,true)
            local min1 = tonumber(getElementData(localPlayer,"char >> ajail >> time"))
            if min1 <= 3 then
                unJail(localPlayer)
            else
                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) - 3))
            end
        else
            local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
            outputChatBox(syntax.."Rossz válasz, ezért plusz 5 perc a büntetésed!",0,0,0,true)
            setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 5))
        end
    end
end

function runFucker()
    if panel then
        panel = false
        exports['cr_dx']:startFade("fuckerPanel", 
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

        if fucker[5] == activeTestID then
            local syntax = exports['cr_core']:getServerSyntax("Jail", "success")
            outputChatBox(syntax.."Jó válasz!",0,0,0,true)
        else
            local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
            outputChatBox(syntax.."Rossz válasz, ezért plusz 5 perc a büntetésed!",0,0,0,true)
            setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 5))
        end
    end
end

function draw_timer()
    local font1 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    local font2 = exports['cr_fonts']:getFont("Poppins-Medium", 14)
    
    local minutesS = getElementData(localPlayer,"char >> ajail >> time")
    local reason = getElementData(localPlayer,"char >> ajail >> reason")
    local admin = getElementData(localPlayer,"char >> ajail >> admin")
    
    local red = exports['cr_core']:getServerColor("red", true)
    local blue = exports['cr_core']:getServerColor('yellow', true)
    local white = "#F2F2F2"
    local x, y = sx - 20, sy - 70
    local timeText = minutesS.." perc"
    local timeText2 = red..minutesS..white.." perc"
    if minutesS <= 0 then
        timeText = "Örökre"
        timeText2 = red .. "Örökre"
    end
    
    dxDrawText(timeText,x,y+1,x,y+1,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Fent
    dxDrawText(timeText,x,y-1,x,y-1,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Lent
    dxDrawText(timeText,x-1,y,x-1,y,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Bal
    dxDrawText(timeText,x+1,y,x+1,y,tocolor(0,0,0,245),1, font1, "right", "top", false, false, false, true) -- Jobb
    dxDrawText(timeText2, x, y, x, y, tocolor(255,255,255,255),1, font1, "right", "top",false,false,false,true)
    local x, y = sx - 20, sy - 40
    dxDrawText(reason.." ("..admin..")",x,y+1,x,y+1,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Fent
    dxDrawText(reason.." ("..admin..")",x,y-1,x,y-1,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Lent
    dxDrawText(reason.." ("..admin..")",x-1,y,x-1,y,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Bal
    dxDrawText(reason.." ("..admin..")",x+1,y,x+1,y,tocolor(0,0,0,245),1, font2, "right", "top", false, false, false, true) -- Jobb
    dxDrawText(reason.." ("..blue..admin..white..")", x, y, x, y, tocolor(255,255,255,255),1, font2, "right", "top", false, false, false, true)
end

function draw_reason()
    local font1 = exports['cr_fonts']:getFont("Poppins-Medium", 16)
    
    local reason = getElementData(localPlayer,"char >> ajail >> reason")
    local time = getElementData(localPlayer,"char >> ajail >> time")
    local x, y = sx/2, sy/2
    
    local red = exports['cr_core']:getServerColor("red", true)
    local timeText = time .. " percre!"
    local timeText2 = red .. time .. " percre!" .. white
    
    if time <= 0 then
        timeText = "Örökre!"
        timeText2 = red .. "Örökre!" .. white
    end
    
    local blue = exports['cr_core']:getServerColor('yellow', true)
    local white = "#F2F2F2"
    
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..timeText,x,y+1,x,y+1,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Fent
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..timeText,x,y-1,x,y-1,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Lent
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..timeText,x-1,y,x-1,y,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Bal
    dxDrawText("Adminjail-ba kerültél "..getElementData(localPlayer,"char >> ajail >> admin").." által "..timeText,x+1,y,x+1,y,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Jobb
    dxDrawText(red.."Adminjail"..white.."-ba kerültél "..blue..getElementData(localPlayer,"char >> ajail >> admin")..white.." által "..timeText2, x, y, x, y, tocolor(255,255,255,255,255),1, font1, "center","center",false,false,false,true)
    local x, y = sx/2, sy/2 + 50
    dxDrawText("Indok: "..reason,x,y+1,x,y+1,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Fent
    dxDrawText("Indok: "..reason,x,y-1,x,y-1,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Lent
    dxDrawText("Indok: "..reason,x-1,y,x-1,y,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Bal
    dxDrawText("Indok: "..reason,x+1,y,x+1,y,tocolor(0,0,0,245),1, font1, "center", "center", false, false, false, true) -- Jobb
    dxDrawText(white .. "Indok: "..red..reason, x, y, x, y, tocolor(255,255,255,255),1, font1, "center","center",false,false,false,true)
end

function draw_questions()
    local alpha, progress = exports['cr_dx']:getFade("questionPanel")
    if not panel then 
        if progress >= 1 then 
            activeTestID = 0 
            buttonHover = nil 

            destroyRender("draw_questions")
            return 
        end  
    end 

    font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    font2 = exports['cr_fonts']:getFont("Poppins-Medium", 14)
    font3 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    font4 = exports['cr_fonts']:getFont("Poppins-Medium", 12)
    font5 = exports['cr_fonts']:getFont("Poppins-SemiBold", 36)

    dxDrawRectangle(left,top,width,height,tocolor(51,51,51,alpha * 0.8))
    dxDrawImage(left + 10, top + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Börtön Teszt (RP Teszt)",left + 10 + 26 + 10,top+10,left+width,top+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    dxDrawText(questions[question][1], left + 35, top + 50, left + width - 35, top + 50, tocolor(242, 242, 242, alpha), 1, font3, "center", "top", false, true)

    local tWidth = dxGetTextWidth(questions[question][1], 1, font3, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    dxDrawText('1/1', left + 25, top + 105, left + 25 + (width - 50), top + 105 - 5 + 4, tocolor(242, 242, 242, alpha), 1, font4, "right", "bottom")
    dxDrawRectangle(left + 25,top + 105,(width - 50),5,tocolor(242, 242, 242, alpha * 0.6))
    dxDrawRectangle(left + 25,top + 105,(width - 50) * (1),5,tocolor(255, 59, 59, alpha))

    local startX, startY = left + 25, top + 120
    buttonHover = nil 

    local tWidth = dxGetTextWidth(questions[question][2], 1, font4, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 1 then 
        if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
            buttonHover = 1
        end 

        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawText("A", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questions[question][2], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
    else 
        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
        dxDrawText("A", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questions[question][2], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
    end 

    startY = startY + 50 + 5

    local tWidth = dxGetTextWidth(questions[question][3], 1, font3, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 2 then 
        if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
            buttonHover = 2
        end 

        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawText("B", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questions[question][3], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
    else 
        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
        dxDrawText("B", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questions[question][3], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
    end 

    startY = startY + 50 + 5

    local tWidth = dxGetTextWidth(questions[question][4], 1, font3, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 3 then 
        if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
            buttonHover = 3
        end 

        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawText("C", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questions[question][4], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
    else 
        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
        dxDrawText("C", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questions[question][4], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
    end 
end

function draw_fucker()
    local alpha, progress = exports['cr_dx']:getFade("fuckerPanel")
    if not panel then 
        if progress >= 1 then 
            activeTestID = 0 
            buttonHover = nil 

            destroyRender("draw_fucker")
            return 
        end  
    end 

    font = exports['cr_fonts']:getFont("Poppins-SemiBold", 16)
    font2 = exports['cr_fonts']:getFont("Poppins-Medium", 14)
    font3 = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    font4 = exports['cr_fonts']:getFont("Poppins-Medium", 12)
    font5 = exports['cr_fonts']:getFont("Poppins-SemiBold", 36)

    dxDrawRectangle(left,top,width,height,tocolor(51,51,51,alpha * 0.8))
    dxDrawImage(left + 10, top + 10, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("Börtön Teszt (Számolós)",left + 10 + 26 + 10,top+10,left+width,top+10+30 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    dxDrawText(fucker[1], left + 35, top + 50, left + width - 35, top + 50, tocolor(242, 242, 242, alpha), 1, font3, "center", "top", false, true)

    local tWidth = dxGetTextWidth(fucker[1], 1, font3, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    dxDrawText('1/1', left + 25, top + 105, left + 25 + (width - 50), top + 105 - 5 + 4, tocolor(242, 242, 242, alpha), 1, font4, "right", "bottom")
    dxDrawRectangle(left + 25,top + 105,(width - 50),5,tocolor(242, 242, 242, alpha * 0.6))
    dxDrawRectangle(left + 25,top + 105,(width - 50) * (1),5,tocolor(255, 59, 59, alpha))

    local startX, startY = left + 25, top + 120
    buttonHover = nil 

    local tWidth = dxGetTextWidth(fucker[2], 1, font4, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 1 then 
        if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
            buttonHover = 1
        end 

        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawText("A", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(fucker[2], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
    else 
        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
        dxDrawText("A", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(fucker[2], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
    end 

    startY = startY + 50 + 5

    local tWidth = dxGetTextWidth(fucker[3], 1, font3, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 2 then 
        if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
            buttonHover = 2
        end 

        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawText("B", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(fucker[3], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
    else 
        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
        dxDrawText("B", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(fucker[3], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
    end 

    startY = startY + 50 + 5

    local tWidth = dxGetTextWidth(fucker[4], 1, font3, true) + 75
    if tWidth > width then 
        width = tWidth
        left = (sx/2)-(width/2)
    end 

    if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) or activeTestID == 3 then 
        if exports['cr_core']:isInSlot(startX, startY, (width - 50), 50) then 
            buttonHover = 3
        end 

        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawText("C", startX, startY, startX + 50, startY + 50 + 4, tocolor(51, 51, 51, alpha), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(fucker[4], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, true)
    else 
        dxDrawRectangle(startX, startY, 50, 50, tocolor(242, 242, 242, alpha * 0.6))
        dxDrawText("C", startX, startY, startX + 50, startY + 50 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font5, "center", "center")
        dxDrawRectangle(startX + 50, startY, (width - 100), 50, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(fucker[4], startX + 50 + 20, startY, startX + 50 + (width - 100), startY + 50, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "left", "center", true, true)
    end 
end

function onClick(b, s, aX, aY, wX, wY, wZ, e)
    if panel then 
        if b == "left" and s == "down" then
            if buttonHover then 
                activeTestID = tonumber(buttonHover)

				if not question then
                    runFucker()
                else
                    runTest()
                end

				buttonHover = nil 
				return 
			end 
            
        end
    end 
end
addEventHandler("onClientClick", root,onClick)

function changeJail(skip)
    local aj = getElementData(localPlayer,"char >> ajail")
    if aj then
        if isElement(localPlayer.vehicle) then
        end
        if skip then
        	if not sound then
            	sound = playSound("files/sadmusic.mp3",true)
            end
            setSoundVolume(sound, 0.5)
            addEventHandler("onClientRender",root,draw_timer)
            addEventHandler("onClientPreRender",root,black)
            setTimer(function()
                triggerServerEvent("preparePlayerToJail",localPlayer,localPlayer)
            end,1000,1)
        else
            oldData = {
                ["hudVisible"] = localPlayer:getData("hudVisible"),
                ["isChatVisible"] = exports['cr_custom-chat']:isChatVisible(),
            }
            setElementData(localPlayer, "hudVisible", false)
            exports['cr_custom-chat']:showChat(false)
            fadeCamera(false)
            addEventHandler("onClientRender",root,draw_reason)
            if not sound2 then
                sound2 = playSound("files/bebortonozve.mp3")
            end
            setTimer(function ()
                fadeCamera(true)
                removeEventHandler("onClientRender",root,draw_reason)
                exports['cr_custom-chat']:showChat(oldData["isChatVisible"])
                setElementData(localPlayer, "hudVisible", oldData["hudVisible"])
                if getElementData(localPlayer,"char >> ajail") then
                    if not sound then
                        sound = playSound("files/sadmusic.mp3",true)
                    end
                    setSoundVolume(sound, 0.5)
                    addEventHandler("onClientRender",root,draw_timer)
                    addEventHandler("onClientPreRender",root,black)
                end
            end,6000,1)
            setTimer(function()
                triggerServerEvent("preparePlayerToJail",localPlayer,localPlayer)
            end,2000,1)
        end
        if isTimer(jailTimer) then
            killTimer(jailTimer)
        end
        min = 0
        jailTimer = setTimer(
            function ()
                if (tonumber(getElementData(localPlayer,"char >> ajail >> time") or 0) - 1) < 0 then
                    return
                end
                
                if (localPlayer:getData("char >> afk")) then
                    return
                end
                
                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time") or 0) - 1))
                local time2 = tonumber(getElementData(localPlayer,"char >> ajail >> time") or 0)

                if not isElementWithinColShape(localPlayer, col) then
                    changeJail()
                end
                
                if time2 <= 1 then
                    unJail(localPlayer)
                    if isTimer(jailTimer) then
                        killTimer(jailTimer)
                    end
                else
                    min = min + 1
                    if min == 3 then
                        if tonumber(getElementData(localPlayer,"char >> ajail >> type")) == 1 then
                            playSound("files/jailtext.mp3")
                            if not panel then
                                generate_question()
                            else
                                --generate_question()
                                exports['cr_dx']:startFade("questionPanel", 
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
                                local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                                outputChatBox(syntax.."Nem válaszoltál a kérdésre! Ezért plusz 3 perc a büntetésed!",0,0,0,true)
                                panel = false
                                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 4))    
                            end
                        elseif tonumber(getElementData(localPlayer,"char >> ajail >> type")) == 2 then
                            playSound("files/jailtext.mp3")
                            if not panel then
                                generate_fucker()
                            else
                                --generate_fucker()
                                exports['cr_dx']:startFade("fuckerPanel", 
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
                                local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                                outputChatBox(syntax.."Nem válaszoltál a kérdésre! Ezért plusz 3 perc a büntetésed!",0,0,0,true)
                                panel = false
                                setElementData(localPlayer,"char >> ajail >> time", (tonumber(getElementData(localPlayer,"char >> ajail >> time")) + 4))    
                            end
                         end
                        min = 0
                    end
                end
            end,60000,0
        )
    elseif not aj then
        --Output kiszabadultál a börtönből... blabla bal
        if isElement(sound) then
            destroyElement(sound)
            sound = false
        end
        if isTimer(jailTimer) then
            killTimer(jailTimer)
        end
        panel = false
        min = 0
        local syntax = exports['cr_core']:getServerSyntax("Jail", "success")
        outputChatBox(syntax.."Kiszabadultál a jailból! Máskor vigyázz magadra!",0,0,0,true)
        removeEventHandler("onClientPreRender",root,black)
        destroyRender("draw_fucker")
        destroyRender("draw_questions")
        removeEventHandler("onClientRender",root,draw_timer)
        triggerServerEvent("releasePlayer",localPlayer,localPlayer)
    end
end

addEventHandler("onClientElementDataChange",localPlayer,
    function (dname)
        if source == localPlayer then
            if dname == "char >> ajail" then
                --outputChatBox("eDataChange")
                changeJail()
            end
        end
    end
)

function setJail(target,time,reason,type,admin)
    --outputChatBox("asd1")
    
    setElementData(target,"char >> ajail >> time", time)
    setElementData(target,"char >> ajail >> admin",getElementData(admin,"admin >> name"))
    setElementData(target,"char >> ajail >> type",type)
    setElementData(target,"char >> ajail", true)
    setElementData(target,"char >> ajail >> aLevel", getElementData(admin,"admin >> level"))
    setElementData(target,"char >> ajail >> reason", tostring(reason))

    triggerServerEvent("saveLog",localPlayer,target)

    target:setData("inInterior", nil)
    --output.....
end

function unJail(target)
    if isTimer(jailTimer) then
        killTimer(jailTimer)
    end
    setElementData(target,"char >> ajail >> admin",nil)
    setElementData(target,"char >> ajail >> type",0)
    setElementData(target,"char >> ajail", false)
    setElementData(target,"char >> ajail >> time", 0)
    setElementData(target,"char >> ajail >> aLevel", nil)
    setElementData(target,"char >> ajail >> reason", nil)

    target:setData("inInterior", nil)
end

function jailed_sc(cmd,target)
    if exports['cr_permission']:hasPermission(localPlayer, "ajail") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target,"char >> ajail") then
                    local white = "#f2f2f2"
                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    local jailed = {
                        ["hoverText"] = "Börtönben lévő játékosok listája",
                        ["minLines"] = 1,
                        ["maxLines"] = 10,
                        ["texts"] = {},
                    }
                    local reason = target:getData("char >> ajail >> reason") or ""
                    local byAdmin = target:getData("char >> ajail >> admin") or ""
                    local minute = (target:getData("char >> ajail >> time") or "0").. " perc"
                    if tonumber(target:getData("char >> ajail >> time") or 0) <= 0 then
                        minute = "Örökre"
                    end
                    table.insert(jailed["texts"], {exports['cr_admin']:getAdminName(target) .. " (" .. blue .. byAdmin .. white .. ")", reason .. " (" .. blue ..  minute .. white .. ")"})
                    
                    exports['cr_dx']:openInformationsPanel(jailed)
                else
                    local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                    outputChatBox(syntax.."#ffffffNincs a játékos adminjailban!",255,255,255,true)
                end
            else noOnline() end
            return
        end
        local null = false
        local max = 0

        local white = "#f2f2f2"
        local blue = exports['cr_core']:getServerColor('yellow', true)
        local jailed = {
            ["hoverText"] = "Börtönben lévő játékosok listája",
            ["minLines"] = 1,
            ["maxLines"] = 10,
            ["texts"] = {},
        }
        for k,v in pairs(getElementsByType("player")) do
            if getElementData(v,"char >> ajail") then
                local reason = v:getData("char >> ajail >> reason") or ""
                local byAdmin = v:getData("char >> ajail >> admin") or ""
                local minute = (v:getData("char >> ajail >> time") or "0").. " perc"
                if tonumber(v:getData("char >> ajail >> time") or 0) <= 0 then
                    minute = "Örökre"
                end
                table.insert(jailed["texts"], {exports['cr_admin']:getAdminName(v) .. " (" .. blue .. byAdmin .. white .. ")", reason .. " (" .. blue ..  minute .. white .. ")"})

                null = true
            end
        end
        if not null then
            local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
            outputChatBox(syntax.."#ffffffNincs egy játékos sem adminjailban!",255,255,255,true)
        else 
            exports['cr_dx']:openInformationsPanel(jailed)
        end
    end
end
addCommandHandler("jailed",jailed_sc)

function unjail_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "ajail") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                if not getElementData(target, "loggedIn") then outputChatBox(syntax..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                    
                if getElementData(target, "char >> ajail") then
                    if exports['cr_permission']:hasPermission(localPlayer, "forceajail") or tonumber(getElementData(target, "char >> ajail >> aLevel") or 2) <= getAdminLevel(localPlayer) then
                        unJail(target)
                        local syntax = exports['cr_core']:getServerSyntax("Jail", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)
                        outputChatBox(syntax.."Sikeresen kivetted az adminjailből. " .. hexColor .. "("..getAdminName(target)..")",0,0,0,true)

                        local targetName = getAdminName(target)
                        local localName = getAdminName(localPlayer, true)
                        local adminSyntax = getAdminSyntax()

                        exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. "#ffffff kivette " .. hexColor .. targetName .. "#ffffff játékost az adminjailből.", 3)
                    else
                        local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                        outputChatBox(syntax.."Nincs meg a szükséges adminszinted a kivételhez!",0,0,0,true)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                    outputChatBox(syntax..getAdminName(target).." nincs adminjailben.",0,0,0,true)
                    --nincs jailba
                end
            else noOnline() end
        end
    end
end
addCommandHandler("unjail", unjail_sc)

function ajail_sc(cmd, target, time,type,...)
    if exports['cr_permission']:hasPermission(localPlayer, "ajail") then
    	if not (target) or not (time) or not (...) or not(type) then
    		local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos] [Idő] [Típus(0-sima,1-kérdegetős,2-szívatós)] [Indok]",0,0,0,true)
    	else
    		local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
    			if not getElementData(target, "loggedIn") then outputChatBox(syntax..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local time = tonumber(time)
                if time >= 0 then
                	if not getElementData(target, "char >> ajail")then
                        local tALevel = target:getData("admin >> level")
                        local p = localPlayer
                        local pALevel = p:getData("admin >> level") 

                        if pALevel < 0 then 
                            if tAlevel > 0 and tALevel >= pALevel then
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                outputChatBox(syntax .. "Magadnál csak kisebb admint jailezhetsz!", 255,255,255,true)
                                return
                            end
                        else 
                            if tALevel >= pALevel then
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                outputChatBox(syntax .. "Magadnál csak kisebb admint jailezhetsz!", 255,255,255,true)
                                return
                            end
                        end

                        if target:getData("char >> follow") then 
                            target:setData("char >> follow", nil)
                        end

                        if target:getData("char >> cuffed") then 
                            target:setData("char >> cuffed", false)
                            target:setData("char >> cuffedID", false)
                        end

                        local reason = table.concat({...}, " ")
                        triggerServerEvent("vehCheck", target, target)
                        setJail(target,math.floor(time),reason,type,localPlayer)
                        local syntax = exports['cr_core']:getServerSyntax("Jail", "success")
                        outputChatBox(syntax.."Sikeresen berakva adminjailbe. ("..getAdminName(target)..")",0,0,0,true)
                        local maxHasFix = getMaxJailCount() or 0
                        local thePlayer = localPlayer
                        local hasFIX = getElementData(thePlayer, "jail >> using") or 0
                        local hasFIX = hasFIX + 1
                        setElementData(thePlayer, "jail >> using", hasFIX)
                        if hasFIX > maxHasFix then
                            local green = exports['cr_core']:getServerColor("orange", true)
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            --local vehicleName = getVehicleName(target)
                            outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Jail limitet! (Limit: "..green..maxHasFix..white..") (Jailek száma: "..green..hasFIX..white..")", 255,255,255,true)
                        end
                        local adminName = getAdminName(localPlayer, true)
                        local jatekosName = getAdminName(target)
                        local jailTime = math.floor(time) .." perc"
                        
                        if math.floor(time) <= 0 then
                            jailTime = "Örökre"
                        end
                        
                        local red = exports['cr_core']:getServerColor("red", true)
                        local blue = exports['cr_core']:getServerColor('yellow', true)
                        local white = "#F2F2F2"
                        triggerServerEvent("showAdminBox",localPlayer, blue..adminName..white.." bebörtönözte "..red..jatekosName..white.." játékost\nIdőtartam: "..red..jailTime..white.."\nIndok: "..red..reason, "info", {adminName.." bebörtönözte "..jatekosName .. " játékost", "Időtartam: "..jailTime, "Indok: "..reason})                        
                    else
                        local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
                	    outputChatBox(syntax..white.."A játékos már adminjailben van!",255,255,255,true)
                	end
                else
                    local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
            		outputChatBox(syntax..white.."Az idő nem lehet 0 vagy kevesebb!",255,255,255,true)
            	end
    		else noOnline() end
    	end
    end
end
addCommandHandler("ajail", ajail_sc)

function offlineJailCommand(cmd, target, time, typ, ...)
    if exports.cr_permission:hasPermission(localPlayer, "offjail") then 
        if not target or not time or not typ or not utf8.find(target, "_") then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")

            outputChatBox(syntax .. "/" .. cmd .. " [Karakter név alsó vonallal] [Idő] [Típus | 0 = sima, 1 = kérdezgetős, 2 = szivatós] [Indok]", 255, 0, 0, true)
            return
        end

        local time = tonumber(time)
        local typ = tonumber(typ)
        local reason = table.concat({...}, " ")

        if not time or not typ then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak szám.", 255, 0, 0, true)
            return
        end

        time = math.floor(tonumber(time))
        typ = math.floor(tonumber(typ))

        if time <= 0 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az időnek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
            return
        end

        if typ ~= 0 and typ ~= 1 and typ ~= 2 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Hibás típus.", 255, 0, 0, true)
            return
        end

        if utf8.len(reason) <= 0 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Az indoknak legalább 1 karaktert kell tartalmaznia.", 255, 0, 0, true)
            return
        end

        local players = getElementsByType("player")
        local foundPlayer = false

        for i = 1, #players do 
            local v = players[i]

            if getAdminName(v) == tostring(target):gsub("_", " ") then 
                foundPlayer = v
                break
            end
        end

        if not foundPlayer then 
            local jailedBy = getAdminName(localPlayer, true)
            local jailedByLevel = getAdminLevel(localPlayer)
            local data = {true, reason, typ, jailedBy, time, jailedByLevel}
            -- local data = {time = time, jailedBy = jailedBy, jailType = typ, jailedByLevel = jailedByLevel, reason = reason}

            triggerServerEvent("offJail", localPlayer, target, data)
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "A játékos online, használd a /ajail parancsot.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("offjail", offlineJailCommand, false, false)
addCommandHandler("ojail", offlineJailCommand, false, false)

-- function offjail_sc(cmd, id, time, type,...)
--     if exports['cr_permission']:hasPermission(localPlayer, "offjail") then
--         if not (id) or not (time) or not (...) or not(type) then
--             local syntax = exports['cr_core']:getServerSyntax(false, "warning")
--             outputChatBox(syntax.."#ffffff /"..cmd.." [Karakter Név] [Idő] [Típus(0-sima,1-kérdegetős,2-szívatós)] [Indok]",0,0,0,true)
--         else
--             local canJail = true

--             for k,v in pairs(getElementsByType("player")) do
--                 if getElementData(v,"char >> name") == tostring(id) or getElementData(v, "acc >> id") == tonumber(id) then
--                     local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
--                     outputChatBox(syntax..white.."A játékos online! Használd a /ajail-t!",255,255,255,true)

--                     canJail = false
--                     break 
--                 end
--             end

--             if not canJail then 
--                 return
--             end

--             local time = tonumber(time)
--             if time > 0 then
--                 local reason = table.concat({...}, " ")
--                 --local id = tonumber(id)
--                 local data = {true,reason,type,getAdminName(localPlayer, true),math.floor(time), localPlayer:getData("admin >> level")}
--                 local data = toJSON(data)
--                 local perm = false
-- 	        	if exports['cr_permission']:hasPermission(localPlayer, "forceajail") then
-- 	        		perm = true
-- 	        	end
--                 triggerServerEvent("offJail",localPlayer,localPlayer,id,data,"jail")
--                 local maxHasFix = getMaxJailCount() or 0
--                 local thePlayer = localPlayer
--                 local hasFIX = getElementData(thePlayer, "jail >> using") or 0
--                 local hasFIX = hasFIX + 1
--                 local adminName = getAdminName(localPlayer, true)
--                 local jatekosName = tostring(id):gsub("_", " ")
--                 local jailTime = math.floor(time)
--                 --triggerServerEvent("showAdminBox",localPlayer,"#ff751a"..adminName.."#ffffff bebörtönözte#ff751a "..jatekosName.."#ffffff játékost #ff751a[Offline]#ffffff\n#ff751aIndok:#ffffff "..reason.."\n#ff751aIdő:#ffffff "..jailTime.." perc", "info", {adminName.." bebörtönözte "..jatekosName .. " játékost [Offline]", "Indok: "..reason, "Idő: "..jailTime .. " perc"})
--             else
--                 local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
--                 outputChatBox(syntax..white.."Az idő nem lehet 0 vagy kevesebb!",255,255,255,true)
--             end
--         end
--     end
-- end
-- addCommandHandler("offjail", offjail_sc)
-- addCommandHandler("ojail", offjail_sc)

-- function offunjail_sc(cmd, id)
--     if exports['cr_permission']:hasPermission(localPlayer, "offjail") then
--         if not (id)  then
--             local syntax = exports['cr_core']:getServerSyntax(false, "warning")
--             outputChatBox(syntax.."#ffffff /"..cmd.." [Játékos Név _-al]",0,0,0,true)
--         else
--             for k,v in pairs(getElementsByType("player")) do
--                 if getElementData(v,"acc >> id") == tonumber(id) then
--                     local syntax = exports['cr_core']:getServerSyntax("Jail", "error")
--                     outputChatBox(syntax..white.."A játékos online! Használd a /unjail-t!",255,255,255,true)
--                     return 
--                 end
--             end
--             local data = {true,"Míg nem voltál fenn, ki lettél véve a jailból!","0","",1, 0}
--             local data = toJSON(data)
--             local id = tostring(id)
--             triggerServerEvent("offJail",localPlayer,localPlayer,id,data, "unjail")
--         end
--     end 
-- end
-- addCommandHandler("offunjail", offunjail_sc)
-- addCommandHandler("ounjail", offunjail_sc)

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function createAnimate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end
end)