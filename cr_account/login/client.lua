local login = {}
local hover
f = "files/"
sx, sy = guiGetScreenSize()
lastClickTick = getTickCount()
screen = {guiGetScreenSize()}
s = {guiGetScreenSize()}
box = {250, 145}
pos = {s[1]/2 -box[1]/2,s[2]/2 - box[2]/2}
leftX, downY = (50) , (s[2]/2 - 40/2) * 2 

rulesActive, infoActive, rulesFadeOut, infoFadeOut, infoScrolling, rulesScrolling = false, false, false, false, false, false

local sx, sy = guiGetScreenSize()
panelLogBox = {300,230}
panelLogin = {s[1]/2 -panelLogBox[1]/2,s[2]/2 - panelLogBox[2]/2}
panelRegBox = {300,280}
panelRegis = {s[1]/2 -panelRegBox[1]/2,s[2]/2 - panelRegBox[2]/2}
panelCharRegBox = {300,580}
panelLoginCharBox = {300,300}
panelLoginCharPanel = {s[1]/50.5 -panelLoginCharBox[1]/6.5,s[2]/1 - panelLoginCharBox[2]/2}
banBox = {450,195}

local dxDrawMultiplier = math.min(1, sx / 1280)

function resp(val)
    return val * dxDrawMultiplier
end

function getRealFontSize(a)
    local a = resp(a)
    local val = ((a) - math.floor(a))
    if val < 0.5 then
        return math.floor(a)
    elseif val >= 0.5 then
        return math.ceil(a)
    end
end

function startLoginPanel()
    --requestTextBars

    rulesActive, infoActive, rulesFadeOut, infoFadeOut, infoScrolling, rulesScrolling = false, false, false, false, false, false

    alpha = 0
    multipler = 2
    showCursor(true)
    setElementData(localPlayer, "keysDenied", true)
    setElementData(localPlayer, "hudVisible", false)
    page = "Login"
    addEventHandler("onClientRender", root, drawnLogin, true, "low-5")
    createTextBars(page)
    --setElementData(localPlayer, "playedMinutes", 0, false)
    --setElementData(localPlayer, "playerSkin", 0)
    --setElementData(localPlayer, "visibleName", getPlayerName(localPlayer))
    bindKey("enter", "down", loginInteraction)
    
    if not flashing then
        logoAnim = "összeilleszt";
        logoTick = getTickCount();
        setTimer(function()
            logoAnim = 'moveUP';
            logoTick = getTickCount();

            loginAnim = 'fadeIn';
            loginTick = getTickCount();

            setTimer(function() 
                flashing = true  
                createLogoAnimation(1, {-5000, -5000})
                --startLogoAnimation()
            end, 1000, 1)
        end, 1700, 1)
    end
    
end

function stopLoginPanel()
    --outputChatBox(page)
    if page == "Login" then
        RemoveBar("Login.Name")
        RemoveBar("Login.Password")
        removeEventHandler("onClientRender", root, drawnLogin)
        unbindKey("enter", "down", loginInteraction)
        --stopLogoAnimation()
    end
end

function drawnLogin()
    hover = nil
    --generateFonts()
    
    if logoAnim == 'összeilleszt' then
        logoSize = {125, 125};
        logoDef = {screen[1]/2 - logoSize[1]/2, screen[2]/2 - logoSize[2]/2}
        defLeft = {interpolateBetween(logoDef[1] - 50, logoDef[2] + 50,0, logoDef[1], logoDef[2],255, (getTickCount() - logoTick) / 1700, 'OutQuad')}
        defRight = {interpolateBetween(logoDef[1] + 50, logoDef[2] - 50,0, logoDef[1], logoDef[2],255, (getTickCount() - logoTick) / 1700, 'OutQuad')}
    elseif logoAnim == 'moveUP' then
        logoSize = {125, 125};
        logoDef = {screen[1]/2 - logoSize[1]/2, screen[2]/2 - logoSize[2]/2}
        moveProgress = (getTickCount() - loginTick) / 1200;
        defLeft = {interpolateBetween(logoDef[1], logoDef[2],255, logoDef[1], logoDef[2] - 110,255, (getTickCount() - logoTick) / 1200, 'OutQuad')}
        defRight = {interpolateBetween(logoDef[1], logoDef[2],255, logoDef[1], logoDef[2] - 110,255, (getTickCount() - logoTick) / 1200, 'OutQuad')}
        
        --updateLogoPos({defMid[1] + (defSize[1]/2), loginPos[1] - 50})
    elseif logoAnim == 'hide' then
        logoSize = {125, 125};
        logoDef = {screen[1]/2 - logoSize[1]/2, screen[2]/2 - logoSize[2]/2}
        moveProgress = (getTickCount() - loginTick) / 1200;
        defLeft = {interpolateBetween(logoDef[1], logoDef[2] - 110,255, logoDef[1], logoDef[2],0, (getTickCount() - logoTick) / 1500, 'OutQuad')}
        defRight = {interpolateBetween(logoDef[1], logoDef[2] - 110,255, logoDef[1], logoDef[2],0, (getTickCount() - logoTick) / 1500, 'OutQuad')}
    end

    if loginAnim == 'fadeIn' then
        defSize = {250, 28}
        defMid = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}

        loginPos = {interpolateBetween(defMid[2] + 50,0,0, defMid[2],220,255, (getTickCount() - loginTick) / 1200, 'OutQuad')}
        loginAlpha = {interpolateBetween(0,0,0, 40,0,0, (getTickCount() - loginTick) / 1200, 'OutQuad')}
        
        if (getTickCount() - loginTick) / 1200 >= 1 then
            updateLogoPos({defMid[1] + (defSize[1]/2), loginPos[1] - 120})
        end
    elseif loginAnim == 'fadeIn2' then
        defSize = {250, 28}
        defaultt = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        defMid = {interpolateBetween(defaultt[1] + (defSize[1] + 10),defaultt[2],0, defaultt[1],defaultt[2],0, (getTickCount() - loginTick) / 2400, 'OutQuad')}

        loginPos = {interpolateBetween(defMid[2],0,0, defMid[2],220,255, (getTickCount() - loginTick) / 1700, 'OutQuad')}
        loginAlpha = {interpolateBetween(0,0,0, 40,0,0, (getTickCount() - loginTick) / 1700, 'OutQuad')}
        
        if (getTickCount() - loginTick) / 2400 >= 1 then
            updateLogoPos({defMid[1] + (defSize[1]/2), loginPos[1] - 120})
        end
    elseif loginAnim == 'fadeOut' then
        defSize = {250, 28}
        defaultt = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        defMid = {interpolateBetween(defaultt[1],defaultt[2],0, defaultt[1] + (defSize[1] + 10),defaultt[2],0, (getTickCount() - loginTick) / 2400, 'OutQuad')}

        loginPos = {interpolateBetween(defMid[2],220,255, defMid[2],0,0, (getTickCount() - loginTick) / 1700, 'OutQuad')}
        loginAlpha = {interpolateBetween(40,0,0, 0,0,0, (getTickCount() - loginTick) / 1700, 'OutQuad')}
    else

    end

    if (moveProgress) then
        local font = exports['cr_fonts']:getFont("Poppins-Medium", 13)
        local font2 = exports['cr_fonts']:getFont("Poppins-Medium", 12)

        UpdatePos("Login.Name", {defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] - 35, 300, 35})
        UpdatePos("Login.Password", {defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] + 10, 300, 35})
        UpdateAlpha("Login.Name", tocolor(51,51,51, loginPos[3] * 0.6))
        UpdateAlpha("Login.Password", tocolor(51,51,51, loginPos[3] * 0.6))
        
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] - 35, 300, 35, tocolor(242, 242, 242, loginPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, loginPos[1] + defSize[2] - 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, loginPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 16/2, loginPos[1] + defSize[2] - 35/2 - 16/2, 16, 16, "files/login-username.png", 0, 0, 0, tocolor(51, 51, 51, loginPos[3] * 0.60))

        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] + 10, 300, 35, tocolor(242, 242, 242, loginPos[3] * 0.8))
        dxDrawRectangle(defMid[1] + defSize[1]/2 - 300/2 + 41, loginPos[1] + defSize[2] + 10 + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, loginPos[3] * 0.29))
        dxDrawImage(defMid[1] + defSize[1]/2 - 300/2 + 41/2 - 16/2, loginPos[1] + defSize[2] + 10 + 35/2 - 12/2, 16, 12, "files/login-password.png", 0, 0, 0, tocolor(51, 51, 51, loginPos[3] * 0.60))

        if isInSlot(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, loginPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12) then
            dxDrawImage(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, loginPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12, "files/login-password-show.png", 0, 0, 0, tocolor(51, 51, 51, loginPos[3]))
        else
            dxDrawImage(defMid[1] + defSize[1]/2 + 300/2 - 41/2 - 13/2, loginPos[1] + defSize[2] + 10 + 35/2 - 12/2, 13, 12, "files/login-password-show.png", 0, 0, 0, tocolor(120, 120, 120, loginPos[3]))
        end

        if isInSlot(defMid[1] + defSize[1]/2 - 200/2, loginPos[1] + defSize[2] + 60, 200, 35) then
            hover = "Login"
            dxDrawRectangle(defMid[1] + defSize[1]/2 - 200/2, loginPos[1] + defSize[2] + 60, 200, 35, tocolor(242, 0, 0, loginPos[3]))
            dxDrawText("Bejelentkezés", defMid[1] + defSize[1]/2 - 200/2, loginPos[1] + defSize[2] + 60 + 4, defMid[1] + defSize[1]/2 - 200/2 + 200, loginPos[1] + defSize[2] + 60 + 35, tocolor(51, 51, 51, loginPos[3]), 1, font, 'center', 'center')
        else 
            dxDrawRectangle(defMid[1] + defSize[1]/2 - 200/2, loginPos[1] + defSize[2] + 60, 200, 35, tocolor(255, 59, 59, loginPos[3] * 0.7))
            dxDrawText("Bejelentkezés", defMid[1] + defSize[1]/2 - 200/2, loginPos[1] + defSize[2] + 60 + 4, defMid[1] + defSize[1]/2 - 200/2 + 200, loginPos[1] + defSize[2] + 60 + 35, tocolor(51, 51, 51, loginPos[3] * 0.42), 1, font, 'center', 'center')
        end

        if isInSlot(defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] + 110, 12, 12) then
            hover = "Bubble"
        end

        if saveJSON["Clicked"] then
            dxDrawImage(defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] + 110, 12, 12, "files/login-password-save-enabled.png", 0, 0, 0, tocolor(230, 230, 230, loginPos[3]))
        else 
            dxDrawImage(defMid[1] + defSize[1]/2 - 300/2, loginPos[1] + defSize[2] + 110, 12, 12, "files/login-password-save-disabled.png", 0, 0, 0, tocolor(230, 230, 230, loginPos[3] * 0.8))
        end 

        dxDrawText("Jelszó megjegyzése", defMid[1] + defSize[1]/2 - 300/2 + 12 + 5, loginPos[1] + defSize[2] + 112.5, defMid[1] + defSize[1]/2 + 300/2, loginPos[1] + defSize[2] + 112.5 + 12, tocolor(242, 242, 242, loginPos[3]), 1, font2, 'left', 'center')

        if isInSlot(defMid[1] + defSize[1]/2 + 300/2 - 145, loginPos[1] + defSize[2] + 110, 145, 12) then 
            hover = "forgetPass"
            dxDrawText("Elfelejtetted a jelszavad?", defMid[1] + defSize[1]/2 - 300/2 + 12 + 10, loginPos[1] + defSize[2] + 112.5, defMid[1] + defSize[1]/2 + 300/2, loginPos[1] + defSize[2] + 112.5 + 12, tocolor(242, 242, 242, loginPos[3]), 1, font2, 'right', 'center')
        else 
            dxDrawText("Elfelejtetted a jelszavad?", defMid[1] + defSize[1]/2 - 300/2 + 12 + 10, loginPos[1] + defSize[2] + 112.5, defMid[1] + defSize[1]/2 + 300/2, loginPos[1] + defSize[2] + 112.5 + 12, tocolor(242, 242, 242, loginPos[3] * 0.8), 1, font2, 'right', 'center')
        end 

        dxDrawText("Nincs még felhasználód?", defMid[1] + defSize[1]/2 - 300/2 + 12 + 15, loginPos[1] + defSize[2] + 140, defMid[1] + defSize[1]/2 + 300/2, loginPos[1] + defSize[2] + 140 + 12, tocolor(242, 242, 242, loginPos[3]), 1, font2, 'left', 'center')

        if isInSlot(defMid[1] + defSize[1]/2 + 300/2 - 80 - 35, loginPos[1] + defSize[2] + 140, 80, 12) then 
            hover = "Register"
            dxDrawText("Regisztrálj itt!", defMid[1] + defSize[1]/2 - 300/2 + 12 + 10, loginPos[1] + defSize[2] + 140, defMid[1] + defSize[1]/2 + 300/2 - 35, loginPos[1] + defSize[2] + 140 + 12, tocolor(242, 242, 242, loginPos[3]), 1, font2, 'right', 'center')
        else 
            dxDrawText("Regisztrálj itt!", defMid[1] + defSize[1]/2 - 300/2 + 12 + 10, loginPos[1] + defSize[2] + 140, defMid[1] + defSize[1]/2 + 300/2 - 35, loginPos[1] + defSize[2] + 140 + 12, tocolor(242, 242, 242, loginPos[3] * 0.8), 1, font2, 'right', 'center')
        end 

        if isInSlot(defMid[1] + defSize[1]/2 - 60, loginPos[1] + defSize[2] + 170, 30, 30) then 
            hover = "Info"
            dxDrawImage(defMid[1] + defSize[1]/2 - 60, loginPos[1] + defSize[2] + 170, 30, 30, "files/login-info.png", 0, 0, 0, tocolor(242, 242, 242, loginPos[3] * 0.8))
        else 
            dxDrawImage(defMid[1] + defSize[1]/2 - 60, loginPos[1] + defSize[2] + 170, 30, 30, "files/login-info.png", 0, 0, 0, tocolor(242, 242, 242, loginPos[3] * 0.5))
        end 
        dxDrawText("Infó", defMid[1] + defSize[1]/2 - 60, loginPos[1] + defSize[2] + 170, defMid[1] + defSize[1]/2 - 60 + 30, loginPos[1] + defSize[2] + 170 + 50, tocolor(242, 242, 242, loginPos[3] * 0.8), 1, font, 'center', 'bottom')

        if isInSlot(defMid[1] + defSize[1]/2 + 30, loginPos[1] + defSize[2] + 170, 30, 30) then 
            hover = "Rules"
            dxDrawImage(defMid[1] + defSize[1]/2 + 30, loginPos[1] + defSize[2] + 170, 30, 30, "files/login-rules.png", 0, 0, 0, tocolor(242, 242, 242, loginPos[3] * 0.8))
        else 
            dxDrawImage(defMid[1] + defSize[1]/2 + 30, loginPos[1] + defSize[2] + 170, 30, 30, "files/login-rules.png", 0, 0, 0, tocolor(242, 242, 242, loginPos[3] * 0.5))
        end 
        dxDrawText("Szabályzat", defMid[1] + defSize[1]/2 + 30, loginPos[1] + defSize[2] + 170, defMid[1] + defSize[1]/2 + 30 + 30, loginPos[1] + defSize[2] + 170 + 50, tocolor(242, 242, 242, loginPos[3] * 0.8), 1, font, 'center', 'bottom')

        if infoActive or infoFadeOut then 
            drawInfoPanel()
        end 

        if rulesActive or rulesFadeOut then 
            drawRulesPanel()
        end 
    end
end
--[[
function drawExtraButtons()
    specHover = nil
    local text = " Elfelejtett jelszó"

    local font = exports['cr_fonts']:getFont("FontAwesome", 12)
    local width = dxGetTextWidth(text, 0.8, font, true)
    local height = dxGetFontHeight(0.8, font)
    roundedRectangle(sx - 10 - width - 10, sy - 10 - height*1 - 5, width + 10, height + 5, tocolor(32, 32, 32, 220))
    if isInSlot(sx - 10 - width, sy - 10 - height*1, width, height) then
        specHover = "forgetPass"
        local r,g,b = exports['cr_core']:getServerColor("blue")
        roundedRectangle(sx - 10 - width - 10, sy - 10 - height*1 - 5, width + 10, height + 5, tocolor(r, g, b, 40))
        dxDrawText(text, sx - 10 - width - 10, sy - 10 - height*1 - 5, sx - 10 - width - 10 + width + 10, sy - 10 - height*1 - 5 + height + 5, tocolor(200, 200, 200, 255), 0.8, font, 'center', 'center')
    else
        dxDrawText(text, sx - 10 - width - 10, sy - 10 - height*1 - 5, sx - 10 - width - 10 + width + 10, sy - 10 - height*1 - 5 + height + 5, tocolor(200, 200, 200, 255), 0.8, font, 'center', 'center')
    end 

    local text = " ÁSZF"
    local width = dxGetTextWidth(text, 0.8, font, true)
    local height = dxGetFontHeight(0.8, font)
    roundedRectangle(sx - 10 - width - 10, sy - 10 - height*2.5 - 5, width + 10, height + 5, tocolor(32, 32, 32, 220))
    if isInSlot(sx - 10 - width, sy - 10 - height*2.5, width, height) then
        specHover = "aszf"
        local r,g,b = exports['cr_core']:getServerColor("red")
        roundedRectangle(sx - 10 - width - 10, sy - 10 - height*2.5 - 5, width + 10, height + 5, tocolor(r, g, b, 40))
        dxDrawText(text, sx - 10 - width - 10, sy - 10 - height*2.5 - 5, sx - 10 - width - 10 + width + 10, sy - 10 - height*2.5 - 5 + height + 5, tocolor(200, 200, 200, 255), 0.8, font, 'center', 'center')
    else
        dxDrawText(text, sx - 10 - width - 10, sy - 10 - height*2.5 - 5, sx - 10 - width - 10 + width + 10, sy - 10 - height*2.5 - 5 + height + 5, tocolor(200, 200, 200, 255), 0.8, font, 'center', 'center')
    end
end

--aszf
local aszfUrl = "project.bluemta.com"
requestBrowserDomains({aszfUrl})

addEventHandler("onClientBrowserWhitelistChange", root,
   function(newDomains)
        if page == "aszf" then
            for k,v in pairs(newDomains) do
                if v == aszfUrl then
                    createAszfBrowser()
                end
            end
        end
    end
)

local webBrowser
function createAszfBrowser()
    if page == "aszf" then
        if not isElement(webBrowser) then
            webBrowser = guiCreateBrowser(50, 50, sx-100, sy-100, false, false, false)
            local theBrowser = guiGetBrowser(webBrowser)

            addEventHandler( "onClientBrowserCreated", theBrowser, 
                function()
                    loadBrowserURL(source, "https://" .. aszfUrl)
                end
            )

            addEventHandler("onClientBrowserResourceBlocked", theBrowser, 
                function(url, domain, reason)
                    local source = source
                    if (reason == 0) then
                        requestBrowserDomains({domain}, false, 
                            function(accepted, newDomains)
                                  if (accepted) then
                                        reloadBrowserPage(source)
                                  end
                            end
                        )
                    end
                end
            )
        else
            loadBrowserURL(guiGetBrowser(webBrowser), "https://" .. aszfUrl)
        end
    end
end

function destroyAszfBrowser()
    if isElement(webBrowser) then
        page = oPage
        destroyElement(webBrowser)
    end
end
bindKey("backspace", "down", destroyAszfBrowser)--]]

forgotState = "Search>1"
forgotMatch = nil
forgotCode = nil
forgetAttempts = 0
function createForgotPanel()
    forgetAttempts = 0
    forgotState = "Search>1"
    forgotMatch = nil
    forgotCode = nil

    createRender("drawForgotPanel", drawForgotPanel)

    exports['cr_dx']:startFade("login >> passwordReminder", 
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
end

function destroyForgetPanel()
    exports['cr_dx']:startFade("login >> passwordReminder", 
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

    page = oPage
    oPage = nil
end

function drawForgotPanel()
    local alpha, progress = exports['cr_dx']:getFade("login >> passwordReminder")

    if page ~= "passwordForget" then
        if progress >= 1 then
            destroyRender("drawForgotPanel")

            if forgotCode then
                triggerServerEvent("destroyCode", localPlayer, localPlayer, nil, true)

                forgotCode = nil 
            end 

            RemoveBar("ForgetPass")
            RemoveBar("ForgetCode")
            RemoveBar("ChangePass")
            return
        end
    end
    
    local font = exports['cr_fonts']:getFont("Poppins-Medium", 13)
    local font2 = exports['cr_fonts']:getFont("Poppins-Medium", 12)

    specHover = nil
    
    if forgotState == "Search>1" then
        local x, y = sx/2, sy/2 + 250

        dxDrawRectangle(x - 300/2, y, 300, 35, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawRectangle(x - 300/2 + 41, y + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, alpha * 0.29))
        dxDrawImage(x - 300/2 + 41/2 - 23/2, y + 35/2 - 20/2, 23, 20, "files/register-invite.png", 0, 0, 0, tocolor(51, 51, 51, alpha * 0.60))
        UpdatePos("ForgetPass", {x - 300/2, y, 300, 35})
        UpdateAlpha("ForgetPass", tocolor(51,51,51, alpha * 0.6))

        if isInSlot(x - 200/2, y + 50, 200, 35) then
            specHover = "Search"
            dxDrawRectangle(x - 200/2, y + 50, 200, 35, tocolor(97, 177, 90, alpha))
            dxDrawText("Keresés", x - 200/2, y + 50, x - 200/2 + 200, y + 50 + 35, tocolor(51, 51, 51, alpha), 1, font, 'center', 'center')
        else 
            dxDrawRectangle(x - 200/2, y + 50, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText("Keresés", x - 200/2, y + 50, x - 200/2 + 200, y + 50 + 35, tocolor(51, 51, 51, alpha * 0.42), 1, font, 'center', 'center')
        end
    
        local r,g,b = exports['cr_core']:getServerColor("blue")
        local text = "Találat:"
        local blue = exports['cr_core']:getServerColor("blue", true)
        if forgotMatch then
            if type(forgotMatch) == "string" then -- nincs
                text = "Nincs találat "..blue..forgotMatch.."#F2F2F2-ra/re"
            elseif type(forgotMatch) == "table" then -- van
                local accName, emailName = unpack(forgotMatch)
                text = "Találat: " .. blue .. accName
            end
        end

        dxDrawText(text, x, y + 100, x, y + 100 + 35, tocolor(242, 242, 242, alpha), 1, font2, 'center', 'center', false, false, false, true)
    elseif forgotState == "Send" then
        local x, y = sx/2, sy/2 + 250

        if isInSlot(x - 200/2, y, 200, 35) then
            specHover = "Send"
            dxDrawRectangle(x - 200/2, y, 200, 35, tocolor(97, 177, 90, alpha))
            dxDrawText("Email küldése", x - 200/2, y, x - 200/2 + 200, y + 35, tocolor(51, 51, 51, alpha), 1, font, 'center', 'center')
        else 
            dxDrawRectangle(x - 200/2, y, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText("Email küldése", x - 200/2, y, x - 200/2 + 200, y + 35, tocolor(51, 51, 51, alpha * 0.42), 1, font, 'center', 'center')
        end
    
        local r,g,b = exports['cr_core']:getServerColor("blue")
        local text = "Találat:"
        local blue = exports['cr_core']:getServerColor("blue", true)
        if forgotMatch then
            if type(forgotMatch) == "string" then -- nincs
                text = "Nincs találat "..blue..forgotMatch.."#F2F2F2-ra/re"
            elseif type(forgotMatch) == "table" then -- van
                local accName, emailName = unpack(forgotMatch)
                text = "Találat: " .. blue .. accName
            end
        end

        dxDrawText(text, x, y + 50, x, y + 50 + 35, tocolor(242, 242, 242, alpha), 1, font2, 'center', 'center', false, false, false, true)
    elseif forgotState == "Code" then
        local x, y = sx/2, sy/2 + 250

        dxDrawRectangle(x - 300/2, y, 300, 35, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawRectangle(x - 300/2 + 41, y + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, alpha * 0.29))
        dxDrawImage(x - 300/2 + 41/2 - 23/2, y + 35/2 - 20/2, 23, 20, "files/register-invite.png", 0, 0, 0, tocolor(51, 51, 51, alpha * 0.60))
        UpdatePos("ForgetCode", {x - 300/2, y, 300, 35})
        UpdateAlpha("ForgetCode", tocolor(51,51,51, alpha * 0.6))

        if isInSlot(x - 200/2, y + 50, 200, 35) then
            specHover = "Send"
            dxDrawRectangle(x - 200/2, y + 50, 200, 35, tocolor(97, 177, 90, alpha))
            dxDrawText("Kód ellenőrzése", x - 200/2, y + 50, x - 200/2 + 200, y + 50 + 35, tocolor(51, 51, 51, alpha), 1, font, 'center', 'center')
        else 
            dxDrawRectangle(x - 200/2, y + 50, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText("Kód ellenőrzése", x - 200/2, y + 50, x - 200/2 + 200, y + 50 + 35, tocolor(51, 51, 51, alpha * 0.42), 1, font, 'center', 'center')
        end
    elseif forgotState == "Password" then
        local x, y = sx/2, sy/2 + 250

        dxDrawRectangle(x - 300/2, y, 300, 35, tocolor(242, 242, 242, alpha * 0.8))
        dxDrawRectangle(x - 300/2 + 41, y + 35/2 - 31/2, 1, 31, tocolor(51, 51, 51, alpha * 0.29))
        dxDrawImage(x - 300/2 + 41/2 - 23/2, y + 35/2 - 20/2, 23, 20, "files/register-invite.png", 0, 0, 0, tocolor(51, 51, 51, alpha * 0.60))
        UpdatePos("ChangePass", {x - 300/2, y, 300, 35})
        UpdateAlpha("ChangePass", tocolor(51,51,51, alpha * 0.6))

        if isInSlot(x - 200/2, y + 50, 200, 35) then
            specHover = "Send"
            dxDrawRectangle(x - 200/2, y + 50, 200, 35, tocolor(97, 177, 90, alpha))
            dxDrawText("Jelszó megváltoztatása", x - 200/2, y + 50, x - 200/2 + 200, y + 50 + 35, tocolor(51, 51, 51, alpha), 1, font, 'center', 'center')
        else 
            dxDrawRectangle(x - 200/2, y + 50, 200, 35, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText("Jelszó megváltoztatása", x - 200/2, y + 50, x - 200/2 + 200, y + 50 + 35, tocolor(51, 51, 51, alpha * 0.42), 1, font, 'center', 'center')
        end
    end
end

addEvent("ForgetPass>Search", true)
addEventHandler("ForgetPass>Search", localPlayer,
    function(e, val)
        forgotMatch = val
        
        if type(forgotMatch) == "table" then -- van
            forgotState = "Send"
            RemoveBar("ForgetPass")
            RemoveBar("ForgetCode")
            RemoveBar("ChangePass")
        end
    end
)

addEvent("ForgetPass>Send", true)
addEventHandler("ForgetPass>Send", localPlayer,
    function(e, val)
        forgetAttempts = 0
        forgotCode = val
        forgotState = "Code"
        CreateNewBar("ForgetCode", {0,0,0,0}, {10, "Kódom", false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center"}, -10)
    end
)

function login.onClick(b, s)
    if page == "passwordForget" then
        if b == "left" and s == "down" then
            if specHover then
                --[[
                if specHover == "close" then
                    if lastClickTick + 500 > getTickCount() then
                        -- outputChatBox("return > fastClick")
                        return
                    end
                    lastClickTick = getTickCount()
                    destroyForgetPanel()
                end]]
                
                if forgotState == "Search>1" then
                    if specHover == "Search" then
                        if lastClickTick + 1000 > getTickCount() then
                            -- outputChatBox("return > fastClick")
                            return
                        end
                        lastClickTick = getTickCount()

                        if GetText("ForgetPass") then
                            if #GetText("ForgetPass") >= 6 then
                                triggerServerEvent("ForgetPass>Search", localPlayer, localPlayer, GetText("ForgetPass"))
                            else
                                exports['cr_infobox']:addBox("error", "Minimum 6 karakter!")
                            end
                        end
                    end
                elseif forgotState == "Send" then
                    if specHover == "Send"  then
                        if lastClickTick + 1000 > getTickCount() then
                            -- outputChatBox("return > fastClick")
                            return
                        end
                        lastClickTick = getTickCount()
                        triggerServerEvent("ForgetPass>Send", localPlayer, localPlayer, forgotMatch)
                    end
                elseif forgotState == "Code" then
                    if specHover == "Send" then
                        if lastClickTick + 500 > getTickCount() then
                            -- outputChatBox("return > fastClick")
                            return
                        end
                        lastClickTick = getTickCount()
                        
                        if GetText("ForgetCode") then
                            if #GetText("ForgetCode") == 10 then
                                if GetText("ForgetCode") == forgotCode then
                                    triggerServerEvent("destroyCode", localPlayer, localPlayer, nil, true)
                                    forgotState = "Password"
                                    RemoveBar("ForgetPass")
                                    RemoveBar("ForgetCode")
                                    RemoveBar("ChangePass")
                                    exports['cr_infobox']:addBox("success", "A kód helyes. Gépeld be az új jelszavad!")
                                    CreateNewBar("ChangePass", {0,0,0,0}, {25, "Új jelszavad...", false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center", not saveJSON["canSeePassword"]}, -10)
                                else
                                    forgetAttempts = forgetAttempts + 1
                                    if forgetAttempts < 3 then
                                        exports['cr_infobox']:addBox("error", "A kód helytelen. Maradt "..(3 - forgetAttempts).." próbálkozásod!")
                                    elseif forgetAttempts >= 3 then
                                        forgotState = "Send"
                                        RemoveBar("ForgetPass")
                                        RemoveBar("ForgetCode")
                                        RemoveBar("ChangePass")
                                        exports['cr_infobox']:addBox("error", "Mivel 3 alkalommal helytelenül adtad meg a kódot ezért újrakell igényelj egyet!")
                                    end
                                end
                            else
                                exports['cr_infobox']:addBox("error", "A kódnak 10 karakternek kell lennie!")
                            end
                        end
                    end
                elseif forgotState == "Password" then
                    if specHover == "Send" then
                        if lastClickTick + 500 > getTickCount() then
                            -- outputChatBox("return > fastClick")
                            return
                        end
                        lastClickTick = getTickCount()
                        
                        if GetText("ChangePass") then
                            if #GetText("ChangePass") >= 6 then
                                triggerServerEvent("change.accpw", localPlayer, forgotMatch[1], GetText("ChangePass"))
                                SetText("Login.Name", forgotMatch[1])
                                SetText("Register.Name", forgotMatch[1])
                                SetText("Register.Email", forgotMatch[2])
                                SetText("Login.Password", GetText("ChangePass"))
                                SetText("Register.Password1", GetText("ChangePass"))
                                SetText("Register.Password2", GetText("ChangePass"))
                                exports['cr_infobox']:addBox("success", "Sikeres jelszó változtatás!")
                                destroyForgetPanel()
                            else
                                exports['cr_infobox']:addBox("error", "A jelszónak minimum 6 karakternek kell lennie!")
                            end
                        end
                    end
                end
            end
        end
    end
    
    if page == "Login" or page == "passwordForget" then
        if b == "left" and s == "down" then
            if hover then
                if lastClickTick + 500 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end

                if hover == "forgetPass" then
                    lastClickTick = getTickCount()

                    if page ~= "aszf" and page ~= "passwordForget" then
                        createForgotPanel()
                        CreateNewBar("ForgetPass", {0,0,0,0}, {30, "Email cím / Felhasználónév", false, tocolor(255,255,255,255), {"Poppins-Medium", 13}, 0.8, "center", "center"}, -10)
                        oPage = page
                        page = "passwordForget"
                    elseif page == "passwordForget" then 
                        destroyForgetPanel()
                    end
                --[[
                elseif specHover == "aszf" then
                    if page ~= "aszf" and page ~= "passwordForget" then
                        oPage = page
                        page = "aszf"
                        requestBrowserDomains({aszfUrl})
                        createAszfBrowser()
                    end]]

                    hover = nil

                    return
                end
            end
        end
    end
    
    if page == "Login" then
        if b == "left" and s == "down" then
            if infoActive and infoHover and isInSlot(info_sX, info_sY, info_sW, info_sH) then
                infoScrolling = true
            elseif rulesActive and rulesHover and isInSlot(rules_sX, rules_sY, rules_sW, rules_sH) then 
                rulesScrolling = true 
            elseif hover == "Bubble" then
                if lastClickTick + 500 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end
                lastClickTick = getTickCount()
                
                playSound("files/bubble.mp3")
                
                saveJSON["Clicked"] = not saveJSON["Clicked"]
                if not saveJSON["Clicked"] then
                    saveJSON["Username"] = ""
                    saveJSON["Password"] = ""
                end 
            elseif hover == "Login" then
                return loginInteraction()
            elseif hover == "Register" then
                if lastClickTick + 1700 > getTickCount() then
                    -- outputChatBox("return > fastClick")
                    return
                end
                lastClickTick = getTickCount()
                playSound("files/bubble.mp3")
                
                if not localPlayer:getData("modsLoaded") or isTransferBoxActive() then 
                    exports['cr_infobox']:addBox("warning", "Míg a szerver nem töltött be addig nem tudsz regisztrálni!")
                    return
                end
                
                --local time = 2500
                --changeCameraPos(1, 1, 2, 2500)
                
                --smoothMoveCamera(2075.4697265625, -1220.9239501953, 23.4, 2256.162109375, -1220.7332763672, 31.479625701904, 2084.0437011719, -1224.5490722656, 32.802700042725, 2084.8530273438, -1224.9874267578, 32.411842346191, 2500)
                
                if not saveJSON["haveRPTest"] then
                    -- outputChatBox("go > RPTest")
                    startRPTest()
                    lastClickTick = getTickCount()
                    return
                end

                infoActive = nil 
                infoFadeOut = nil 
                rulesActive = nil
                rulesFadeOut = nil
                
                loginAnim = 'fadeOut';
                loginTick = getTickCount();

                regTick = getTickCount();
                regAnim = 'fadeInReg';
                --stopLogoAnimation()
                startRegisterPanel()
                --page = "IDGOUT"

                setTimer(function()
                    page = "Login"    
                    stopLoginPanel()
                    page = "Register"   
                    createTextBars(page)
                end, 1700, 1)
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
addEventHandler("onClientClick", root, login.onClick)

function idgLoading()
    stopLoginPanel()
    stopLogoAnimation()
    stopLoginSound()
    page = "InGame"
    startLoadingScreen("Login", 1)
    lastClickTick = getTickCount()
end
addEvent("idgLoading", true)
addEventHandler("idgLoading", root, idgLoading)

function loginInteraction()
    if page == "Login" then
        if lastClickTick + 1550 > getTickCount() then
            -- outputChatBox("return > fastClick")
            return
        end
        
        lastClickTick = getTickCount()

        if exports['cr_network']:getNetworkStatus() then 
            return
        end 
        
        if not localPlayer:getData("modsLoaded") or isTransferBoxActive() then 
            exports['cr_infobox']:addBox("warning", "Míg a szerver nem töltött be addig nem tudsz bejelentkezni!")
            return
        end
        
        playSound("files/bubble.mp3")
        
        local username = GetText("Login.Name") --textbars["Login.Name"][2][2]
        local password = GetText("Login.Password") --textbars["Login.Password"][2][2]
        
        if #username < 6 then
            exports["cr_infobox"]:addBox("error", "Túl rövid a felhasználónév, minimum 6 karakterből kell álljon!")
            return
        end
        
        if #password < 6 then
            exports["cr_infobox"]:addBox("error", "Túl rövid a jelszó, minimum 6 karakterből kell álljon!")
            return
        end

        if saveJSON["Clicked"] then
            --local hashedPassword = hash("sha512", username .. password .. username)
            --local hashedPassword2 = hash("md5", salt .. hashedPassword .. salt)
            saveJSON["Username"] = username
            saveJSON["Password"] = password
        end
        
        --outputChatBox(password)
        
        --outputChatBox("Login")
        triggerServerEvent("login.goLogin", localPlayer, localPlayer, username, password)
    end 
end 

function cameraSpawn(hp, bones)
    --showCursor(false)
    exports['cr_blur']:removeBlur("Loginblur")
    stopLoadingScreen()
    --triggerServerEvent("idg.login", localPlayer, localPlayer)
    --toggleAllControls(true, true)
    setCameraTarget(localPlayer, localPlayer)
    --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
    fadeCamera(true, 0)
    
    resetFarClipDistance()

    if hp > 0 then
        local x1, y1, z1 = getElementPosition(localPlayer)
        local x2, y2, z2 = x1, y1, z1
        z1 = z1 + 150
        local x3, y3, z3 = getElementPosition(localPlayer)
        z3 = z3 + 1.5
        local x4, y4, z4 = x3, y3, z3
        local time = 6500
        setCameraMatrix(x1, y1, z1, x2, y2, z2)
        setTimer(
            function()
                exports['cr_core']:smoothMoveCamera(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, time)
                fadeCamera(true, 0)
                setTimer(
                    function()
                        exports['cr_controls']:toggleAllControls(true, "low")
                        exports['cr_custom-chat']:showChat(true)
                        --showChat(true)
                        setElementData(localPlayer, "keysDenied", false)
                        setElementData(localPlayer, "hudVisible", true)
                        page = "InGame"
                        triggerServerEvent("unFreeze", localPlayer, localPlayer, hp, bones)
                        setCameraTarget(localPlayer, localPlayer)
                        setTimer(setCameraTarget, 500, 2, localPlayer, localPlayer)
                        accID = getElementData(localPlayer, "acc >> id")
                        version = exports['cr_core']:getServerData('version')
                        datum = exports['cr_core']:getTime()
                        fps = exports['cr_interface']:getFPS():gsub(" FPS", "")
                        ping = getPlayerPing(localPlayer)
                        createRender("drawnDetails", drawnDetails)
                    end, time, 1
                )
            end, 500, 1
        )
    else 
        triggerServerEvent("unFreeze", localPlayer, localPlayer, hp, bones)
        setCameraTarget(localPlayer, localPlayer)
        accID = getElementData(localPlayer, "acc >> id")
        version = exports['cr_core']:getServerData('version')
        datum = exports['cr_core']:getTime()
        fps = exports['cr_interface']:getFPS():gsub(" FPS", "")
        ping = getPlayerPing(localPlayer)
        createRender("drawnDetails", drawnDetails)
    end 
end
addEvent("cameraSpawn", true)
addEventHandler("cameraSpawn", root, cameraSpawn)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if farclip then
            setFarClipDistance(farclip)
        end
    end
)

addEvent("loadScreen", true)
addEventHandler("loadScreen", root,
    function()
        stopSituations()
        stopLogoAnimation()
        stopLoginPanel()
        stopLoginSound()
        startLoadingScreen("Login", 1)
    end
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if getElementData(localPlayer, "loggedIn") then
            accID = getElementData(localPlayer, "acc >> id")
            version = exports['cr_core']:getServerData('version')
            datum = exports['cr_core']:getTime()
            fps = exports['cr_interface']:getFPS():gsub(" FPS", "")
            ping = getPlayerPing(localPlayer)
            createRender("drawnDetails", drawnDetails)
        end
    end
)

local datum, fps, ping 
setTimer(
    function()
        datum = exports['cr_core']:getTime()
    end, (30 * 1000), 0
)

setTimer(
    function()
        fps = exports['cr_interface']:getFPS():gsub(" FPS", "")
        ping = getPlayerPing(localPlayer)
    end, (1 * 1000), 0
)

local playerInAfk = localPlayer:getData('char >> afk')
local playerInAfkShowing = false 

function drawnDetails()
    --dxDrawRectangle(sx - 85, sy - 14, 85, 14) , clear
    local datum, fps, ping = datum, fps, ping

    if not datum then 
        datum = "Betöltés alatt..."
    end 

    if not fps then 
        fps = "Betöltés alatt..."
    end 

    if not ping then 
        ping = "Betöltés alatt..."
    end 
    
    dxDrawText("CountrySide ["..version.."] - Account ID: "..accID.." - FPS: "..fps.." - Ping: "..ping.." - "..datum, sx - 90, sy - 6, sx - 90, sy - 6, tocolor(255, 255, 255, 110), 1, "ariel", "right", "center", false, false, false, true)

    if playerInAfkShowing then 
        if exports['cr_dashboard']:getOption('afkWarning') == 1 then 
            local alpha, progress = exports['cr_dx']:getFade("afkWarning")

            if tonumber(alpha) and tonumber(progress) then 
                if not playerInAfk then 
                    if progress >= 1 then 
                        playerInAfkShowing = false
                        return 
                    end  
                end 
                
                local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 21)
                local red = exports['cr_core']:getServerColor('red', true)

                dxDrawText('Jelenleg '..red..'AFKOLSZ!#ffffff\n(Ez azt jelenti, hogy '..red..'nem gyűlik a játszott perced#ffffff\nilletve '..red..'nem csökken a börtönidőd #ffffffha börtönben vagy!)', 0, 20, sx, sy, tocolor(255, 255, 255, alpha), 1, font, 'center', 'top', false, false, false, true)
            end
        end
    end 
end

addEventHandler('onClientElementDataChange', localPlayer, 
    function(dName, oValue, nValue)
        if dName == 'char >> afk' then 
            playerInAfk = nValue

            if playerInAfk then 
                if not playerInAfkShowing then 
                    playerInAfkShowing = true 

                    exports['cr_dx']:startFade("afkWarning", 
                        {
                            ["startTick"] = getTickCount(),
                            ["lastUpdateTick"] = getTickCount(),
                            ["time"] = 250,
                            ["animation"] = "InOutQuad",
                            ["from"] = 0,
                            ["to"] = 180,
                            ["alpha"] = 0,
                            ["progress"] = 0,
                        }
                    )
                end
            else 
                if playerInAfkShowing then 
                    exports['cr_dx']:startFade("afkWarning", 
                        {
                            ["startTick"] = getTickCount(),
                            ["lastUpdateTick"] = getTickCount(),
                            ["time"] = 250,
                            ["animation"] = "InOutQuad",
                            ["from"] = 180,
                            ["to"] = 0,
                            ["alpha"] = 180,
                            ["progress"] = 0,
                        }
                    )
                end 
            end 
        end 
    end 
)

infoMinLines = 1
infoMaxLines = 24
_infoMaxLines = infoMaxLines

function drawInfoPanel()
    local alpha, progress = exports['cr_dx']:getFade("login >> infopanel")
    
    if infoFadeOut then     
        if progress >= 1 then 
            infoFadeOut = false
            return 
        end  
    end 

    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", getRealFontSize(18))

    local w, h = resp(400), resp(550)
    local x, y = sx/2 - w - resp(200), sy/2 - h/2
    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    infoHover = isInSlot(x, y, w, h)

    dxDrawImage(x + resp(20), y + resp(20), resp(30), resp(30), "files/login-info.png", 0, 0, 0, tocolor(47,118,215,alpha))
    dxDrawText("Információk", x + resp(65), y + resp(20), x + resp(65), y + resp(50), tocolor(242, 242, 242, alpha * 0.8), 1, font, 'left', 'center')

    local startX, startY = x + resp(35), y + resp(70)
    local _startY = startY

    for i = infoMinLines, infoMaxLines do
        local data = informationTexts[i]
        if data then
            local text, fontName, fontSize = unpack(data)

            local font = exports['cr_fonts']:getFont(fontName, getRealFontSize(fontSize))
            local fontHeight = dxGetFontHeight(1, font) - 5

            dxDrawText(text, startX, startY, startX, startY + fontHeight, tocolor(242, 242, 242, alpha * 0.8), 1, font, 'left', 'top', false, false, false, true)

            startY = startY + fontHeight
        end 
    end 

    --scrollboard
    
    local percent = #informationTexts
    
    if percent >= 1  then
        local gW, gH = resp(3), resp(450)
        local gX, gY = x + w - gW, _startY
        info_sX, info_sY, info_sW, info_sH = gX - resp(2), gY, gW + resp(4), gH
        
        if infoScrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local cy = math.min(math.max(cy, info_sY), info_sY + info_sH)
                    local y = (cy - info_sY) / (info_sH)
                    local num = percent * y
                    infoMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _infoMaxLines) + 1)))
                    infoMaxLines = infoMinLines + (_infoMaxLines - 1)
                end
            else
                infoScrolling = false
            end
        end
        
        dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))

        local multiplier = math.min(math.max((infoMaxLines - (infoMinLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((infoMinLines - 1) / percent, 0), 1)

        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
    end
end 

rulesMinLines = 1
rulesMaxLines = 24
_rulesMaxLines = rulesMaxLines

function drawRulesPanel()
    local alpha, progress = exports['cr_dx']:getFade("login >> rulespanel")
    
    if rulesFadeOut then     
        if progress >= 1 then 
            rulesFadeOut = false
            return 
        end  
    end 

    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", getRealFontSize(18))

    local w, h = resp(400), resp(550)
    local x, y = sx/2 + resp(200), sy/2 - h/2
    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))

    rulesHover = isInSlot(x, y, w, h)

    dxDrawImage(x + resp(20), y + resp(20), resp(30), resp(30), "files/login-rules.png", 0, 0, 0, tocolor(255,59,59,alpha))
    dxDrawText("Szabályzat", x + resp(65), y + resp(20), x + resp(65), y + resp(50), tocolor(242, 242, 242, alpha * 0.8), 1, font, 'left', 'center')

    local startX, startY = x + resp(35), y + resp(70)
    local _startY = startY

    for i = rulesMinLines, rulesMaxLines do
        local data = rulesTexts[i]
        if data then
            local text, fontName, fontSize = unpack(data)

            local font = exports['cr_fonts']:getFont(fontName, getRealFontSize(fontSize))
            local fontHeight = dxGetFontHeight(1, font) - 5

            dxDrawText(text, startX, startY, startX, startY + fontHeight, tocolor(242, 242, 242, alpha * 0.8), 1, font, 'left', 'top', false, false, false, true)

            startY = startY + fontHeight
        end 
    end 

    --scrollboard
    
    local percent = #rulesTexts
    
    if percent >= 1  then
        local gW, gH = resp(3), resp(450)
        local gX, gY = x + w - gW, _startY
        rules_sX, rules_sY, rules_sW, rules_sH = gX - resp(2), gY, gW + resp(4), gH
        
        if rulesScrolling then
            if isCursorShowing() then
                if getKeyState("mouse1") then
                    local cx, cy = exports['cr_core']:getCursorPosition()
                    local cy = math.min(math.max(cy, rules_sY), rules_sY + rules_sH)
                    local y = (cy - rules_sY) / (rules_sH)
                    local num = percent * y
                    rulesMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - _rulesMaxLines) + 1)))
                    rulesMaxLines = rulesMinLines + (_rulesMaxLines - 1)
                end
            else
                rulesScrolling = false
            end
        end
        
        dxDrawRectangle(gX,gY,gW,gH, tocolor(242,242,242,alpha * 0.6))

        local multiplier = math.min(math.max((rulesMaxLines - (rulesMinLines - 1)) / percent, 0), 1)
        local multiplier2 = math.min(math.max((rulesMinLines - 1) / percent, 0), 1)

        local gY = gY + ((gH) * multiplier2)
        local gH = gH * multiplier

        dxDrawRectangle(gX, gY, gW, gH, tocolor(255, 59, 59, alpha))
    end
end 

bindKey("mouse_wheel_up", "down",
    function()
        if infoActive and infoHover then
            if infoMinLines - 1 >= 1 then
                playSound(":cr_scoreboard/files/wheel.wav")
                infoMinLines = infoMinLines - 1
                infoMaxLines = infoMaxLines - 1
            end
        elseif rulesActive and rulesHover then
            if rulesMinLines - 1 >= 1 then
                playSound(":cr_scoreboard/files/wheel.wav")
                rulesMinLines = rulesMinLines - 1
                rulesMaxLines = rulesMaxLines - 1
            end
        end
    end
)

bindKey("mouse_wheel_down", "down",
    function()
        if infoActive and infoHover then
            local count = #informationTexts
            
            if infoMaxLines + 1 <= count then
                playSound(":cr_scoreboard/files/wheel.wav")
                infoMinLines = infoMinLines + 1
                infoMaxLines = infoMaxLines + 1
            end
        elseif rulesActive and rulesHover then
            local count = #rulesTexts
            
            if rulesMaxLines + 1 <= count then
                playSound(":cr_scoreboard/files/wheel.wav")
                rulesMinLines = rulesMinLines + 1
                rulesMaxLines = rulesMaxLines + 1
            end
        end
    end
)