local rpTest = {}

function startRPTest()
    if maxQuestions > #questions then
        maxQuestions = #questions
        neededToComplete = math.floor(#questions * 0.8)
    end
    
    exports['cr_dx']:startFade("rptest", 
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


    stopLoginPanel()
    stopLogoAnimation()
    oldPosLogoX, oldPosLogoY = getLogoPosition()
    updateLogoPos({sx/2, sy/2-250/2 - 80})
    --requestTextBars
    hasQuestions = {}
    page = "RPTest"
    selected = 5
    questionsQuested = 0
    successQuestions = 0
    nextQuestion()
    addEventHandler("onClientRender", root, drawnRPTest, true, "low-5")
    --createLogoAnimation(1, {sx/2, sy/2 - 225})
    --exports['cr_infobox']:addBox("info", "Az interakcióhoz használd az 'Enter' billentyűt!")
    exports["cr_infobox"]:addBox("info", "Ahhoz, hogy regisztrálhass szükséges, hogy kitölts egy RP tesztet!")
    exports["cr_infobox"]:addBox("warning", "Minimum "..100*rtMultipler.."%-t kell elérj!")
    bindKey("enter", "down", interactToEnter)
end

function stopRPTest()
    hasQuestions = {}
    page = "RPTest"
    selected = 5
    questionsQuested = 0
    successQuestions = 0
    removeEventHandler("onClientRender", root, drawnRPTest, true, "low-5")
    unbindKey("enter", "down", interactToEnter)

    createLogoAnimation(1, {-5000, -5000})
    --stopLogoAnimation()
end

function interactToEnter()
    if selected == 5 then
        exports["cr_infobox"]:addBox("error", "Válasz ki egy lehetőséget!")
        return
    end
    local correctAnswer = questions[nowQuestion][6]
    if correctAnswer == selected then
        successQuestions = successQuestions + 1
    end
    
    if questionsQuested + 1 > maxQuestions then
        finishRPTest()
        return
    else
        nextQuestion()
        return
    end
end

function finishRPTest()
    if successQuestions >= neededToComplete then
        local theMultipler = math.floor((successQuestions/maxQuestions) * 100)
        if theMultipler == inf or tostring(theMultipler) == "inf" then
            theMultipler = 0
        end
        exports["cr_infobox"]:addBox("success", "Sikeresen teljesítetted a tesztet! Most már regisztrálhatsz (".. theMultipler .."%-t értél el)")
        stopRPTest()
        
        loginAnim = 'fadeOut';
        loginTick = getTickCount();

        regTick = getTickCount();
        regAnim = 'fadeInReg';
        --stopLogoAnimation()
        updateLogoPos({oldPosLogoX, oldPosLogoY})
        startRegisterPanel()
        Clear()
        --page = "IDGOUT"

        setTimer(function()
            page = "Login"    
            stopLoginPanel()
            page = "Register"   
            createTextBars(page)
        end, 1700, 1)
        
        saveJSON["haveRPTest"] = true
        --GoToReg
    else
        local theMultipler = math.floor((successQuestions/maxQuestions) * 100)
        if theMultipler == inf or tostring(theMultipler) == "inf" then
            theMultipler = 0
        end
        --outputChatBox(neededToComplete/successQuestions)
        exports["cr_infobox"]:addBox("error", "Mivel nem érted el a "..100*rtMultipler.."%-t (".. theMultipler .."%-t értél el) ezért újra kell kezd a tesztet")
        restartRPTest()
    end
end

function restartRPTest()
    exports["cr_infobox"]:addBox("warning", "Minimum "..100*rtMultipler.."%-t kell elérj!")
    hasQuestions = {}
    page = "RPTest"
    selected = 5
    questionsQuested = 0
    successQuestions = 0
    nextQuestion()
end

function nextQuestion()
    local newQuestionID = math.random(1, #questions)
    if hasQuestions[newQuestionID] then
        nextQuestion()
        return
    end
    
    nowQuestion = newQuestionID
    hasQuestions[nowQuestion] = true
    questionsQuested = questionsQuested + 1
    selected = 5
end

function drawnRPTest()
    local alpha = exports['cr_dx']:getFade("rptest")
    
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    local font2 = exports['cr_fonts']:getFont("Poppins-SemiBold", 12)
    local font3 = exports['cr_fonts']:getFont("Poppins-SemiBold", 14)
    
    local w,h = 645, 280
    local x, y = sx/2 - w/2, sy/2 - h/2
    dxDrawRectangle(x, y, w, h, tocolor(51,51,51,alpha * 0.8))

    local logoW, logoH = 78, 90
    dxDrawImage(sx/2 - logoW/2, y + 10, logoW, logoH, "files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local question = questions[nowQuestion][1]
    dxDrawText(question, x + 5, y + logoH + 40, x + w - 10, y + logoH + 40, tocolor(229, 229, 229, alpha), 1, font, "center", "center", false, true)

    local questionAnswerOne = questions[nowQuestion][2]
    local boxW, boxH = 300, 40
    if selected == 1 or isInSlot(x + 20, y + logoH + 70, boxW, boxH) then
        dxDrawRectangle(x + 20, y + logoH + 70, boxW, boxH, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questionAnswerOne, x + 20 + 5, y + logoH + 70, x + 20 + boxW - 10, y + logoH + 70 + boxH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, true)
    else 
        dxDrawRectangle(x + 20, y + logoH + 70, boxW, boxH, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questionAnswerOne, x + 20 + 5, y + logoH + 70, x + 20 + boxW - 10, y + logoH + 70 + boxH, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center", false, true)
    end 

    local questionAnswerTwo = questions[nowQuestion][3]
    local boxW, boxH = 300, 40
    if selected == 2 or isInSlot(x + 20 + boxW + 5, y + logoH + 70, boxW, boxH) then
        dxDrawRectangle(x + 20 + boxW + 5, y + logoH + 70, boxW, boxH, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questionAnswerTwo, x + 20 + boxW + 5 + 5, y + logoH + 70, x + 20 + boxW + 5 + boxW - 10, y + logoH + 70 + boxH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, true)
    else 
        dxDrawRectangle(x + 20 + boxW + 5, y + logoH + 70, boxW, boxH, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questionAnswerTwo, x + 20 + boxW + 5 + 5, y + logoH + 70, x + 20 + boxW + 5 + boxW - 10, y + logoH + 70 + boxH, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center", false, true)
    end 

    local questionAnswerThree = questions[nowQuestion][4]
    local boxW, boxH = 300, 40
    if selected == 3 or isInSlot(x + 20, y + logoH + 70 + boxH + 5, boxW, boxH) then
        dxDrawRectangle(x + 20, y + logoH + 70 + boxH + 5, boxW, boxH, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questionAnswerThree, x + 20 + 5, y + logoH + 70 + boxH + 5, x + 20 + boxW - 10, y + logoH + 70 + boxH + 5 + boxH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, true)
    else 
        dxDrawRectangle(x + 20, y + logoH + 70 + boxH + 5, boxW, boxH, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questionAnswerThree, x + 20 + 5, y + logoH + 70 + boxH + 5, x + 20 + boxW - 10, y + logoH + 70 + boxH + 5 + boxH, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center", false, true)
    end 

    local questionAnswerFour = questions[nowQuestion][5]
    local boxW, boxH = 300, 40
    if selected == 4 or isInSlot(x + 20 + boxW + 5, y + logoH + 70 + boxH + 5, boxW, boxH) then
        dxDrawRectangle(x + 20 + boxW + 5, y + logoH + 70 + boxH + 5, boxW, boxH, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(questionAnswerFour, x + 20 + boxW + 5 + 5, y + logoH + 70 + boxH + 5, x + 20 + boxW + 5 + boxW - 10, y + logoH + 70 + boxH + 5 + boxH, tocolor(242, 242, 242, alpha), 1, font2, "center", "center", false, true)
    else 
        dxDrawRectangle(x + 20 + boxW + 5, y + logoH + 70 + boxH + 5, boxW, boxH, tocolor(51, 51, 51, alpha * 0.6))
        dxDrawText(questionAnswerFour, x + 20 + boxW + 5 + 5, y + logoH + 70 + boxH + 5, x + 20 + boxW + 5 + boxW - 10, y + logoH + 70 + boxH + 5 + boxH, tocolor(242, 242, 242, alpha * 0.6), 1, font2, "center", "center", false, true)
    end 

    local percent = questionsQuested / maxQuestions

    local progressW, progressH = 600, 5
    dxDrawRectangle(sx/2 - progressW/2, y + h - 7 - progressH, progressW, progressH, tocolor(242, 242, 242, alpha * 0.6))
    dxDrawRectangle(sx/2 - progressW/2, y + h - 7 - progressH, progressW * percent, progressH, tocolor(255, 59, 59, alpha))
    dxDrawText(questionsQuested .. "/" .. maxQuestions, sx/2 - progressW/2 + 5, y + h - 7 - progressH - 10, sx/2 + progressW/2 - 5, y + h - 7 - progressH - 10, tocolor(242, 242, 242, alpha), 1, font3, "right", "center")
end

function rpTest.onClick(b, s)
--    outputChatBox(page)
    if page == "RPTest" then
        if b == "left" and s == "down" then
            local w,h = 645, 280
            local x, y = sx/2 - w/2, sy/2 - h/2
            local logoW, logoH = 78, 90
            local boxW, boxH = 300, 40
            
            if isInSlot(x + 20, y + logoH + 70, boxW, boxH) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 1 then
                    selected = 1
                elseif selected == 1 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            elseif isInSlot(x + 20 + boxW + 5, y + logoH + 70, boxW, boxH) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 2 then
                    selected = 2
                elseif selected == 2 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            elseif isInSlot(x + 20, y + logoH + 70 + boxH + 5, boxW, boxH) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 3 then
                    selected = 3
                elseif selected == 3 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            elseif isInSlot(x + 20 + boxW + 5, y + logoH + 70 + boxH + 5, boxW, boxH) then
                if lastClickTick + 500 > getTickCount() then
                    return
                end
                
                if selected ~= 4 then
                    selected = 4
                elseif selected == 4 then
                    selected = 5
                end
                lastClickTick = getTickCount()
            end
        end
    end
end
addEventHandler("onClientClick", root, rpTest.onClick)