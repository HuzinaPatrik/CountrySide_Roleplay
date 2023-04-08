local reg = {}

function startRegisterPanel()
    --requestTextBars

    rulesActive, infoActive, rulesFadeOut, infoFadeOut, infoScrolling, rulesScrolling = false, false, false, false, false, false

    alpha = 0
    multipler = 2
    page = "Register"
    addEventHandler("onClientRender", root, drawnRegister, true, "low-5")
    --addEventHandler("onClientRender", root, drawExtraButtons, true, "low-5")
    createTextBars(page)
    --stopLogoAnimation()
    --createLogoAnimation(1, {sx/2, sy/2 - 245})

    bindKey("enter", "down", registerInteraction)
end

function stopRegisterPanel()
    if page == "Register" then
        RemoveBar("Register.Name")
        RemoveBar("Register.Email")
        RemoveBar("Register.Password1")
        RemoveBar("Register.Password2")
        RemoveBar("Register.InviteCode")
        removeEventHandler("onClientRender", root, drawnRegister)

        unbindKey("enter", "down", registerInteraction)
        --stopLogoAnimation()
    end
end

function registerInteraction()
    if lastClickTick + 1550 > getTickCount() then
        --outputChatBox("return > fastClick")
        return
    end

    --outputChatBox("go > Register")
    lastClickTick = getTickCount()
    
    playSound("files/bubble.mp3")

    if exports['cr_network']:getNetworkStatus() then 
        return
    end 
    
    --[[
    if not aszfClicked then
        exports['cr_infobox']:addBox("error", "Ahhoz, hogy regisztrálhass a szerverre elkell fogad az ÁSZF-t!")
        return
    end]]
    
    local username = GetText("Register.Name") -- textbars["Register.Name"][2][2]
    local email = GetText("Register.Email") --textbars["Register.Email"][2][2]
    local password = GetText("Register.Password1") --textbars["Register.Password1"][2][2]
    local password2 = GetText("Register.Password2") --textbars["Register.Password2"][2][2]
    local inviteCode = GetText("Register.InviteCode")
    
    if #username < 6 then
        exports["cr_infobox"]:addBox("error", "Túl rövid a felhasználónév, minimum 6 karakterből kell álljon!")
        return
    end
    
    if #password < 6 or #password2 < 6 then
        exports["cr_infobox"]:addBox("error", "Túl rövid a jelszó, minimum 6 karakterből kell álljon!")
        return
    end
    
    if not email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") then
        exports["cr_infobox"]:addBox("error", "Használj rendes emailcímet (Pld: xyz@gmail.com)!")
        return
    end
    
    if string.lower(password) ~= string.lower(password2) then
        exports["cr_infobox"]:addBox("error", "A 2 jelszó nem egyezik!")
        return
    end

    if saveJSON["Clicked"] then
        --local hashedPassword = hash("sha512", username .. password .. username)
        --local hashedPassword2 = hash("md5", salt .. hashedPassword .. salt)
        saveJSON["Username"] = username
        saveJSON["Password"] = password
    end

    local serial = getElementData(localPlayer, "mtaserial")
    
    -- if tonumber(inviteCode) then
    --     for k,v in pairs(getElementsByType("player")) do
    --         local accID = tonumber(v:getData("acc >> id") or 0) 
    --         if accID == tonumber(inviteCode) then
    --             v:setData("char >> premiumPoints", v:getData("char >> premiumPoints") + 35)
    --             triggerServerEvent("addBox", localPlayer, v, "info", "Mivel igénybe vették a meghívó kódodat ezért jóváírtunk neked 35 prémiumpontot!")
    --             inviteCode = nil
    --             break
    --         end
    --     end
    -- end
    
    triggerServerEvent("reg.goRegister", localPlayer, localPlayer, username, password, email, serial, inviteCode)
end

function drawnRegister()
    hover = nil
    if regAnim == 'fadeInReg' then
        defSize = {250, 28}
        defaultt = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        defMid = {interpolateBetween(defaultt[1] - (defSize[1] + 10),defaultt[2],0, defaultt[1],defaultt[2],0, (getTickCount() - regTick) / 2400, 'OutQuad')}

        regPos = {interpolateBetween(defMid[2],0,0, defMid[2],220,255, (getTickCount() - regTick) / 1700, 'OutQuad')}
        regAlpha = {interpolateBetween(0,0,0, 40,0,0, (getTickCount() - regTick) / 1700, 'OutQuad')}
        
        if (getTickCount() - regTick) / 2400 >= 1 then
            updateLogoPos({defMid[1] + (defSize[1]/2), regPos[1] - 120})
        end
        
    elseif regAnim == 'fadeIn2' then

    elseif regAnim == 'fadeOut' then
        defSize = {250, 28}
        defaultt = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        defMid = {interpolateBetween(defaultt[1],defaultt[2],0, defaultt[1] - (defSize[1] + 10), defaultt[2],0, (getTickCount() - regTick) / 2400, 'OutQuad')}

        regPos = {interpolateBetween(defMid[2],220,255, defMid[2],0,0, (getTickCount() - regTick) / 1700, 'OutQuad')}
        regAlpha = {interpolateBetween(40,0,0, 0,0,0, (getTickCount() - regTick) / 1700, 'OutQuad')}
    else

    end
    
    if (moveProgress) then
        local font = exports['cr_fonts']:getFont("Poppins-Medium", 13)
        local font2 = exports['cr_fonts']:getFont("Poppins-Medium", 12)

        UpdatePos("Register.Name", {defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] - 35, 300, 35})
        UpdatePos("Register.Password1", {defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 10, 300, 35})
        UpdatePos("Register.Password2", {defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 55, 300, 35})
        UpdatePos("Register.Email", {defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 100, 300, 35})
        UpdatePos("Register.InviteCode", {defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 145, 300, 35})

        UpdateAlpha("Register.Name", tocolor(51,51,51, regPos[3] * 0.6))
        UpdateAlpha("Register.Password1", tocolor(51,51,51, regPos[3] * 0.6))
        UpdateAlpha("Register.Password2", tocolor(51,51,51, regPos[3] * 0.6))
        UpdateAlpha("Register.Email", tocolor(51,51,51, regPos[3] * 0.6))
        UpdateAlpha("Register.InviteCode", tocolor(51,51,51, regPos[3] * 0.6))

        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] - 35, 300, 35, tocolor(242, 242, 242, regPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, regPos[1] + defSize[2] - 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, regPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 16/2, regPos[1] + defSize[2] - 35/2 - 16/2, 16, 16, "files/login-username.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3] * 0.60))

        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 10, 300, 35, tocolor(242, 242, 242, regPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, regPos[1] + defSize[2] + 10 + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, regPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 16/2, regPos[1] + defSize[2] + 10 + 35/2 - 12/2, 16, 12, "files/login-password.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3] * 0.60))

        if isInSlot(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12) then
            dxDrawImage(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12, "files/login-password-show.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3]))
        else
            dxDrawImage(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12, "files/login-password-show.png", 0, 0, 0, tocolor(120, 120, 120, regPos[3]))
        end
        
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 55, 300, 35, tocolor(242, 242, 242, regPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, regPos[1] + defSize[2] + 55 + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, regPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 16/2, regPos[1] + defSize[2] + 55 + 35/2 - 12/2, 16, 12, "files/login-password.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3] * 0.60))

        if isInSlot(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 55 + 35/2 - 12/2, 13, 12) then
            dxDrawImage(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 55 + 35/2 - 12/2, 13, 12, "files/login-password-show.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3]))
        else
            dxDrawImage(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, regPos[1] + defSize[2] + 55 + 35/2 - 12/2, 13, 12, "files/login-password-show.png", 0, 0, 0, tocolor(120, 120, 120, regPos[3]))
        end

        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 100, 300, 35, tocolor(242, 242, 242, regPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, regPos[1] + defSize[2] + 100 + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, regPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 22/2, regPos[1] + defSize[2] + 100 + 35/2 - 17/2, 22, 17, "files/register-email.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3] * 0.60))

        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, regPos[1] + defSize[2] + 145, 300, 35, tocolor(242, 242, 242, regPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, regPos[1] + defSize[2] + 145 + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, regPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 23/2, regPos[1] + defSize[2] + 145 + 35/2 - 20/2, 23, 20, "files/register-invite.png", 0, 0, 0, tocolor(51, 51, 51, regPos[3] * 0.60))

        if isInSlot(defMid[1] + defSize[1]/2 - 200/2, regPos[1] + defSize[2] + 195, 200, 35) then
            hover = "Register"
            dxDrawRectangle(defMid[1] + defSize[1]/2 - 200/2, regPos[1] + defSize[2] + 195, 200, 35, tocolor(97, 177, 90, regPos[3]))
            dxDrawText("Regisztráció", defMid[1] + defSize[1]/2 - 200/2, regPos[1] + defSize[2] + 195 + 4, defMid[1] + defSize[1]/2 - 200/2 + 200, regPos[1] + defSize[2] + 195 + 35, tocolor(51, 51, 51, regPos[3]), 1, font, 'center', 'center')
        else 
            dxDrawRectangle(defMid[1] + defSize[1]/2 - 200/2, regPos[1] + defSize[2] + 195, 200, 35, tocolor(97, 177, 90, regPos[3] * 0.7))
            dxDrawText("Regisztráció", defMid[1] + defSize[1]/2 - 200/2, regPos[1] + defSize[2] + 195 + 4, defMid[1] + defSize[1]/2 - 200/2 + 200, regPos[1] + defSize[2] + 195 + 35, tocolor(51, 51, 51, regPos[3] * 0.42), 1, font, 'center', 'center')
        end

        if isInSlot(defMid[1] + defSize[1]/2 - 180/2, regPos[1] + defSize[2] + 250 - 20/2, 180, 20) then 
            hover = "Login"
            exports['cr_dx']:dxDrawImageWithText(":cr_account/files/register-left-arrow.png", "Vissza a bejelentkezéshez", defMid[1] + defSize[1]/2, regPos[1] + defSize[2] + 250, defMid[1] + defSize[1]/2, regPos[1] + defSize[2] + 250, tocolor(242, 242, 242, regPos[3]), tocolor(242, 242, 242, regPos[3]), 10, 20, 1, font2, 5)
        else 
            exports['cr_dx']:dxDrawImageWithText(":cr_account/files/register-left-arrow.png", "Vissza a bejelentkezéshez", defMid[1] + defSize[1]/2, regPos[1] + defSize[2] + 250, defMid[1] + defSize[1]/2, regPos[1] + defSize[2] + 250, tocolor(242, 242, 242, regPos[3] * 0.8), tocolor(242, 242, 242, regPos[3] * 0.8), 10, 20, 1, font2, 5)
        end 

        if isInSlot(defMid[1] + defSize[1]/2 - 60, regPos[1] + defSize[2] + 280, 30, 30) then 
            hover = "Info"
            dxDrawImage(defMid[1] + defSize[1]/2 - 60, regPos[1] + defSize[2] + 280, 30, 30, "files/login-info.png", 0, 0, 0, tocolor(242, 242, 242, regPos[3] * 0.8))
        else 
            dxDrawImage(defMid[1] + defSize[1]/2 - 60, regPos[1] + defSize[2] + 280, 30, 30, "files/login-info.png", 0, 0, 0, tocolor(242, 242, 242, regPos[3] * 0.5))
        end 
        dxDrawText("Infó", defMid[1] + defSize[1]/2 - 60, regPos[1] + defSize[2] + 280, defMid[1] + defSize[1]/2 - 60 + 30, regPos[1] + defSize[2] + 280 + 50, tocolor(242, 242, 242, regPos[3] * 0.8), 1, font, 'center', 'bottom')

        if isInSlot(defMid[1] + defSize[1]/2 + 30, regPos[1] + defSize[2] + 280, 30, 30) then 
            hover = "Rules"
            dxDrawImage(defMid[1] + defSize[1]/2 + 30, regPos[1] + defSize[2] + 280, 30, 30, "files/login-rules.png", 0, 0, 0, tocolor(242, 242, 242, regPos[3] * 0.8))
        else 
            dxDrawImage(defMid[1] + defSize[1]/2 + 30, regPos[1] + defSize[2] + 280, 30, 30, "files/login-rules.png", 0, 0, 0, tocolor(242, 242, 242, regPos[3] * 0.5))
        end 
        dxDrawText("Szabályzat", defMid[1] + defSize[1]/2 + 30, regPos[1] + defSize[2] + 280, defMid[1] + defSize[1]/2 + 30 + 30, regPos[1] + defSize[2] + 280 + 50, tocolor(242, 242, 242, regPos[3] * 0.8), 1, font, 'center', 'bottom')

        if infoActive or infoFadeOut then 
            drawInfoPanel()
        end 

        if rulesActive or rulesFadeOut then 
            drawRulesPanel()
        end 

        --[[
        local a = 32 + 80 + 60 + 32 + 30
        dxDrawText('Elfogadom az ÁSZF-t',  defMid[1] + 10 + 25, regPos[1] + a + 6, 0,0, tocolor(200, 200, 200,regPos[3]),0.8, font)
        if isInSlot(defMid[1], regPos[1] + a + 2, 25, 25) then
            hover = "aszfClick"
        end
        if aszfClicked then
            dxDrawImage(defMid[1], regPos[1] + a + 2, 25, 25, "files/toggleon.png",0,0,0, tocolor(255,255,255,regPos[2]))
        else
            dxDrawImage(defMid[1], regPos[1] + a + 2, 25, 25, "files/toggleoff.png",0,0,0, tocolor(255,255,255,regPos[2]))
        end]]
    end
end

function reg.onClick(b, s)
    if page == "Register" then
        if b == "left" and s == "down" then
            if infoActive and infoHover and isInSlot(info_sX, info_sY, info_sW, info_sH) then
                infoScrolling = true
            elseif rulesActive and rulesHover and isInSlot(rules_sX, rules_sY, rules_sW, rules_sH) then 
                rulesScrolling = true 
            elseif hover == "aszfClick" then
                if lastClickTick + 500 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end
                lastClickTick = getTickCount()
                
                playSound("files/bubble.mp3")
                
                aszfClicked = not aszfClicked
            elseif hover == "Login" then
                if lastClickTick + 1700 > getTickCount() then
                    --outputChatBox("return > fastClick")
                    return
                end
                playSound("files/bubble.mp3")
                
                loginAnim = 'fadeIn2';
                loginTick = getTickCount();

                regTick = getTickCount();
                regAnim = 'fadeOut';
                --stopLogoAnimation()
                
                --updateLogoPos({defMid[1] + (defSize[1]/2), loginPos[1] - 90})
                startLoginPanel()
                --Clear()
                --page = "IDGOUT"

                setTimer(function()
                    page = "Register"
                    stopRegisterPanel()
                    page = "Login"
                    createTextBars(page)
                end, 1700, 1)
                
                lastClickTick = getTickCount()
            elseif hover == "Register" then
                return registerInteraction()
            elseif hover == "Info" then 
                if infoActive then 
                    infoFadeOut = true 
                end 

                infoActive = not infoActive

                if infoActive then 
                    exports['cr_dx']:startFade("login >> infopanel", 
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
                else 
                    exports['cr_dx']:startFade("login >> infopanel", 
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
            elseif hover == "Rules" then 
                if rulesActive then 
                    rulesFadeOut = true 
                end 

                rulesActive = not rulesActive

                if rulesActive then 
                    exports['cr_dx']:startFade("login >> rulespanel", 
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
                else 
                    exports['cr_dx']:startFade("login >> rulespanel", 
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
        elseif b == "left" and s == "up" then 
            if infoScrolling then
                infoScrolling = false
            end

            if rulesScrolling then 
                rulesScrolling = false
            end 
        end
    end
end
addEventHandler("onClientClick", root, reg.onClick)

addEvent("goBackToLogin", true)
addEventHandler("goBackToLogin", localPlayer,
    function()
        playSound("files/bubble.mp3")
                
        loginAnim = 'fadeIn2';
        loginTick = getTickCount();

        regTick = getTickCount();
        regAnim = 'fadeOut';
        --stopLogoAnimation()

        --updateLogoPos({defMid[1] + (defSize[1]/2), loginPos[1] - 90})
        startLoginPanel()
        Clear()
        --page = "IDGOUT"

        setTimer(function()
            page = "Register"
            stopRegisterPanel()
            page = "Login"
            createTextBars(page)
        end, 1700, 1)

        lastClickTick = getTickCount()
    end
)