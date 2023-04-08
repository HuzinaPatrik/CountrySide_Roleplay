bank_accounts = {}
bankCardNumberToID = {}
function returnBankData(element, id, data, typ)
    if typ == "all" then
        bank_accounts[id] = data 
        bankCardNumberToID[data[3]] = id
    elseif typ == "request" then 
        bank_accounts[id] = data 
        bankCardNumberToID[data[3]] = id
    elseif typ == "clear" then 
        bank_accounts[id] = nil
    end
end
addEvent("returnBankData", true)
addEventHandler("returnBankData", root, returnBankData)

local lastCall = -1
local lastCallTick = -5000
function getBankData(element, id)
    local now = getTickCount()
    if now <= lastCallTick + 1000 then
        cancelLatentEvent(lastCall)
    end 
    if tonumber(id) then 
        triggerLatentServerEvent("getBankData", 1000, false, localPlayer, localPlayer, localPlayer, id, "all")
    else 
        triggerLatentServerEvent("checkPlayerBankAccounts", 1000, false, localPlayer, element)
    end 
    lastCall = getLatentEventHandles()[#getLatentEventHandles()] 
    lastCallTick = getTickCount()
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue, nValue)
        if dName == "loggedIn" then
            if nValue then
                getBankData(localPlayer)
            end
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            getBankData(localPlayer)
        end 

        for k, v in pairs(bankPeds) do 
            local skinid,x,y,z,dim,int,rot,name = unpack(v)
            local ped = Ped(skinid,x,y,z)
            ped.dimension = dim 
            ped.interior = int 
            ped.rotation = Vector3(0,0,rot)
            ped.frozen = true 

            ped:setData("ped.name", name)
            ped:setData("ped.type", "Banki ügyintéző")			
            ped:setData("char >> noDamage", true)		
            ped:setData("bank >> ped", k)
        end 

        backspaceTex = dxCreateTexture("assets/images/backspace.png", "argb", true, 'clamp')
    end 
)

addEventHandler("onClientClick", root, 
    function(b, s, _, _, _, _, _, worldE)
        if b == "left" and s == "down" then 
            if isElement(worldE) and worldE:getData("bank >> ped") then 
                if getDistanceBetweenPoints3D(localPlayer.position, worldE.position) <= 3 then 
                    local player_bank_accounts = 0 
                    for k,v in pairs(bank_accounts) do 
                        if v[2] == localPlayer:getData("acc >> id") then 
                            player_bank_accounts = player_bank_accounts + 1 
                            break 
                        end 
                    end 

                    if player_bank_accounts == 0 then -- igénylés
                        gPed = worldE
                        openRequestPanel(1)
                    end     
                end 
            end 
        end 
    end 
)

function openBank(ped, value)
    local val = bankCardNumberToID[tonumber(value)]
    if val then 
        if bank_accounts[val] then 
            gPed = ped
            openPinPanel(
                {
                    ["ID"] = val, 
                    ["Text"] = "", 
                    ["onEnter"] = function()
                        openBankPanel(pinData["ID"])
                    end 
                }
            )
        end 
    end 
end 

local hover, closeHover, pinHover, isRender, buttonHover, selectedMenu, inSlot, startX, startY, x, y, buttonAnimation

local lastClickTick = -5000
local function enterInteraction()
    if isRender then  
        if selectedMenu == 2 then 
            local now = getTickCount()
            if now <= lastClickTick + 5000 then
                return
            end

            if exports['cr_network']:getNetworkStatus() then 
                return 
            end 

            local cardNumber = tonumber(GetText("bank >> cardNumber")) 
            if not tonumber(cardNumber) or #tostring(cardNumber) ~= 12 then 
                exports['cr_infobox']:addBox("error", "A számlaszámnak egy 12 karakterből álló számnak kell lennie!")
                return 
            end 

            local subjectText = GetText("bank >> subjectText")
            if not subjectText or #subjectText < 1 then 
                exports['cr_infobox']:addBox("error", "A tárgynak egy szövegnek kell lennie mely minimum 1 karakter hosszú!")
                return 
            end 

            local messageText = GetText("bank >> messageText")
            if not messageText or #messageText < 1 then 
                exports['cr_infobox']:addBox("error", "Az üzenetnek egy szövegnek kell lennie mely minimum 1 karakter hosszú!")
                return 
            end 

            if not tonumber(moneyText) or #moneyText < 1 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1 karakterből kell állnia!")
                return 
            end 

            if tonumber(moneyText) <= 0 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1nek kell lennie!")
                return 
            end 

            if tonumber(moneyText) > bank_accounts[gId][4] then 
                exports['cr_infobox']:addBox("error", "Nincs ennyi pénz a bankszámládon!")
                return 
            end 

            SetText("bank >> cardNumber", "")
            SetText("bank >> subjectText", "")        
            SetText("bank >> messageText", "")   
            
            local a = 38
            if messageText then
                messageText = addCharToString(messageText, a, "\n", math.floor(#messageText / a))
            end

            local green = exports['cr_core']:getServerColor('green', true)
            local red = exports['cr_core']:getServerColor('red', true)
            exports['cr_infobox']:addBox('success', 'Sikeresen utaltál '..green..'$ '..moneyText..'#F2F2F2-ot(et)! (Adó: '..red..'$ '..(tonumber(moneyText) * 0.1)..'#F2F2F2)')

            lastClickTick = getTickCount()

            triggerLatentServerEvent("transferMoney", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][4], cardNumber, subjectText, messageText, moneyText)
            moneyText = ""
        elseif selectedMenu == 3 then 
            local now = getTickCount()
            if now <= lastClickTick + 5000 then
                return
            end

            if exports['cr_network']:getNetworkStatus() then 
                return 
            end 

            if not tonumber(moneyText) or #moneyText < 1 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1 karakterből kell állnia!")
                return 
            end 

            if tonumber(moneyText) <= 0 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1nek kell lennie!")
                return 
            end 

            if tonumber(moneyText) > bank_accounts[gId][4] then 
                exports['cr_infobox']:addBox("error", "Nincs ennyi pénz a bankszámládon!")
                return 
            end 

            local green = exports['cr_core']:getServerColor('green', true)
            local red = exports['cr_core']:getServerColor('red', true)
            exports['cr_infobox']:addBox('success', 'Sikeresen kivettél a bankszámládról '..green..'$ '..moneyText..'#F2F2F2-ot(et)! (Adó: '..red..'$ '..(tonumber(moneyText) * 0.05)..'#F2F2F2)')

            lastClickTick = getTickCount()
            triggerLatentServerEvent("takeMoneyFromBank", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][4], moneyText)
            bank_accounts[gId][4] = bank_accounts[gId][4] - tonumber(moneyText)
            moneyText = ""
        elseif selectedMenu == 4 then 
            local now = getTickCount()
            if now <= lastClickTick + 5000 then
                return
            end

            if exports['cr_network']:getNetworkStatus() then 
                return 
            end 

            if not tonumber(moneyText) or #moneyText < 1 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1 karakterből kell állnia!")
                return 
            end 

            if tonumber(moneyText) <= 0 then 
                exports['cr_infobox']:addBox("error", "Az összegnek minimum 1nek kell lennie!")
                return 
            end 

            if not exports['cr_core']:hasMoney(localPlayer, tonumber(moneyText)) then 
                exports['cr_infobox']:addBox("error", "Nincs elég pénzed!")
                return 
            end 

            local green = exports['cr_core']:getServerColor('green', true)
            local red = exports['cr_core']:getServerColor('red', true)
            exports['cr_infobox']:addBox('success', 'Sikeresen beraktál a bankszámládba '..green..'$ ' .. moneyText .. '#F2F2F2-ot(et)! (Adó: '..red..'$ '..(tonumber(moneyText) * 0.05)..'#F2F2F2)')

            lastClickTick = getTickCount()
            triggerLatentServerEvent("addMoneyToBank", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][4], moneyText)
            moneyText = ""
        elseif selectedMenu == 5 then 
            if hover == 1 then 
                local now = getTickCount()
                if now <= lastClickTick + 5000 then
                    return
                end

                if exports['cr_network']:getNetworkStatus() then 
                    return 
                end 

                if not tonumber(logText) or #logText ~= 4 then 
                    exports['cr_infobox']:addBox("error", "A jelszónak 4 karakterből kell állnia!")
                    return 
                end 

                if bank_accounts[gId][6] == tonumber(logText) then
                    exports['cr_infobox']:addBox("error", "A jelszó nem egyezhet meg a régi jelszóval!")
                    return 
                end 

                lastClickTick = getTickCount()
                triggerLatentServerEvent("changeBankAccountPassword", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][6], logText)
                logText = ""
            elseif hover == 2 then 
                local now = getTickCount()
                if now <= lastClickTick + 5000 then
                    return
                end

                if exports['cr_network']:getNetworkStatus() then 
                    return 
                end 

                if bank_accounts[gId][5] == 1 then 
                    exports['cr_infobox']:addBox("error", "Már ez a számla elsődleges!")
                    return 
                end 

                lastClickTick = getTickCount()
                triggerLatentServerEvent("setBankAccountMain", 5000, false, localPlayer, localPlayer, gId, bank_accounts[gId][5])
            elseif hover == 3 then 
                local now = getTickCount()
                if now <= lastClickTick + 5000 then
                    return
                end

                if exports['cr_network']:getNetworkStatus() then 
                    return 
                end 

                lastClickTick = getTickCount()

                local money = #getPlayerBankAccounts(localPlayer) * 2500
                triggerEvent("dashboard.createNewBankCard", localPlayer, money)
            elseif hover == 4 then  
                local now = getTickCount()
                if now <= lastClickTick + 5000 then
                    return
                end

                if exports['cr_network']:getNetworkStatus() then 
                    return 
                end 

                if bank_accounts[gId][4] < 0 then 
                    exports['cr_infobox']:addBox("error", "Mivel hitelben van a bankszámlád míg nem téríted a hitelt nem törölheted!")
                    return 
                end 

                lastClickTick = getTickCount()

                triggerEvent("dashboard.deleteBankCard", localPlayer, localPlayer)
            end 
        end 
    end 
end 

addEvent("createNewBankCard", true)
addEventHandler("createNewBankCard", localPlayer, 
    function(money)
        if isRender then 
            if selectedMenu == 5 then 
                if tonumber(money) then 
                    if exports['cr_core']:takeMoney(localPlayer, money) then 
                        closeBankPanel()
                        openRequestPanel(0)
                    else 
                        exports['cr_infobox']:addBox("error", "Nincs elég pénzed")
                    end 
                end 
            end 
        end 
    end 
)

addEvent("deleteBankCard", true)
addEventHandler("deleteBankCard", localPlayer, 
    function()
        if isRender then 
            if selectedMenu == 5 then 
                if bank_accounts[gId][4] < 0 then 
                    exports['cr_infobox']:addBox("error", "Mivel hitelben van a bankszámlád míg nem téríted a hitelt nem törölheted!")
                    return 
                end 

                closeBankPanel()
                triggerLatentServerEvent("deleteBankAccount", 5000, false, localPlayer, localPlayer, gId)
                local cardNumber = bank_accounts[gId][3]
                bankCardNumberToID[cardNumber] = nil 
                bank_accounts[gId] = nil 
                collectgarbage("collect")

                local items = exports['cr_inventory']:getItems(localPlayer, 2) 
                for slot, data in pairs(items) do 
                    local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(data)
                    if itemid == 97 then 
                        if tonumber(value) == tonumber(cardNumber) then 
                            exports['cr_inventory']:deleteItem(localPlayer, slot, itemid)
                            break 
                        end 
                    end 
                end 
            end 
        end 
    end 
)

local function onClick(b, s)
    if isRender then 
        if b == "left" and s == "down" then 
            if closeHover then 
                closeBankPanel()
                closeHover = nil 
                return 
            elseif LogsScrollingHover then
                LogsScrolling = true
                LogsScrollingHover = false
            elseif MoneyTakeLogsScrollingHover then 
                MoneyTakeLogsScrolling = true 
                MoneyTakeLogsScrollingHover = false 
            elseif MoneyAddLogsScrollingHover then 
                MoneyAddLogsScrolling = true 
                MoneyAddLogsScrollingHover = false 
            elseif PasswordChangeLogsScrollingHover then 
                PasswordChangeLogsScrolling = true 
                PasswordChangeLogsScrollingHover = false 
            elseif tonumber(buttonHover) then 
                if selectedMenu ~= tonumber(buttonHover) then 
                    local oldSelectedMenu = tonumber(selectedMenu)
                    selectedMenu = tonumber(buttonHover)
                    Clear()
                    if selectedMenu == 1 then 
                        LogsMinLines = 1
                        LogsMaxLines = 9
                    elseif selectedMenu == 2 then 
                        CreateNewBar("bank >> cardNumber", {0, 0, 0, 0}, {12, "", true, tocolor(242, 242, 242, 255), {"Poppins-Medium", 14}, 1, "left", "center", false, true}, 1, true)
                        CreateNewBar("bank >> subjectText", {0, 0, 0, 0}, {26, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 14}, 1, "left", "center", false, true}, 2, true)
                        CreateNewBar("bank >> messageText", {0, 0, 0, 0}, {130, "", false, tocolor(242, 242, 242, 255), {"Poppins-Medium", 14}, 1, "left", "top", false, false, true}, 3, true)
                        moneyText = ""
                    elseif selectedMenu == 3 then 
                        moneyText = ""
                        MoneyTakeLogsScrolling = false 
                        MoneyTakeLogsMinLines = 1 
                        MoneyTakeLogsMaxLines = 7
                    elseif selectedMenu == 4 then  
                        moneyText = ""
                        MoneyAddLogsScrolling = false 
                        MoneyAddLogsMinLines = 1 
                        MoneyAddLogsMaxLines = 7
                    elseif selectedMenu == 5 then  
                        logText = ""
                        PasswordChangeLogsScrolling = false 
                        PasswordChangeLogsMinLines = 1 
                        PasswordChangeLogsMaxLines = 7
                    end 

                    buttonAnimation[selectedMenu] = {getTickCount(), 1}
                    buttonAnimation[oldSelectedMenu] = {getTickCount(), 2}
                end 

                buttonHover = nil 
            elseif selectedMenu == 2 and not now or selectedMenu == 3 and not now or selectedMenu == 4 and not now then
                if tonumber(hover) then 
                    if hover == 1 then
                        enterInteraction()
                    end 
                    hover = nil 
                elseif pinHover then 
                    if pinHover == "backspace" then 
                        if #moneyText >= 1 then
                            moneyText = utfSub(moneyText, 0, #moneyText - 1)
                            playSound(":cr_account/files/key.mp3")
                        end
                    elseif tonumber(pinHover) then 
                        local text = tonumber(pinHover) 
                        if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "*" end
                        if tonumber(text) then
                            if #moneyText <= 9 then 
                                moneyText = moneyText .. text
                                playSound(":cr_account/files/key.mp3")
                            end 
                        elseif text == 'X' then 
                            moneyText = ''
                        end 
                    end 
                    pinHover = nil 
                end 
            elseif selectedMenu == 5 and not now then 
                if tonumber(hover) then 
                    if hover == 1 or hover == 2 or hover == 3 or hover == 4 then 
                        enterInteraction()
                    end 
                    hover = nil 
                elseif pinHover then 
                    if pinHover == "backspace" then 
                        if #logText >= 1 then
                            logText = utfSub(logText, 0, #logText - 1)
                            playSound(":cr_account/files/key.mp3")
                        end
                    elseif tonumber(pinHover) then 
                        local text = tonumber(pinHover) 
                        if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "*" end
                        if tonumber(text) then
                            if #logText <= 3 then 
                                logText = logText .. text
                                playSound(":cr_account/files/key.mp3")
                            end 
                        elseif text == 'X' then 
                            logText = ''
                        end 
                    end 
                    pinHover = nil 
                end 
            end 
        elseif b == "left" and s == "up" then 
            if LogsScrolling then 
                LogsScrolling = false 
            end 

            if MoneyTakeLogsScrolling then 
                MoneyTakeLogsScrolling = false 
            end 

            if MoneyAddLogsScrolling then 
                MoneyAddLogsScrolling = false 
            end 

            if PasswordChangeLogsScrolling then 
                PasswordChangeLogsScrolling = false 
            end 
        end 
    end 
end 

local function backspaceInteraction()
    if selectedMenu == 2 and #moneyText >= 1 and not now or selectedMenu == 3 and #moneyText >= 1 and not now or selectedMenu == 4 and #moneyText >= 1 and not now then
        moneyText = utfSub(moneyText, 0, #moneyText - 1)
        playSound(":cr_account/files/key.mp3")
    elseif selectedMenu == 5 and #logText >= 1 and not now then 
        logText = utfSub(logText, 0, #logText - 1)
        playSound(":cr_account/files/key.mp3")
    else 
        closeBankPanel()
    end 
end 

local function onKey(b, s)
    if b == "enter" and s then 
        enterInteraction()
        cancelEvent()
    elseif tonumber(b:sub(#b, #b)) and s and b:sub(1, 5):lower() ~= ("mouse"):lower() and b:sub(1, 1):lower() ~= ("F"):lower() then 
        if selectedMenu == 2 and #moneyText <= 9 and not now or selectedMenu == 3 and #moneyText <= 9 and not now or selectedMenu == 4 and #moneyText <= 9 and not now then 
            moneyText = moneyText .. b:sub(#b, #b)
            playSound(":cr_account/files/key.mp3")
        end 

        if selectedMenu == 5 and #logText <= 3 and not now then 
            logText = logText .. b:sub(#b, #b)
            playSound(":cr_account/files/key.mp3")
        end 
        cancelEvent()
    elseif b:lower() == ('X'):lower() and s then 
        if selectedMenu == 2 and not now or selectedMenu == 3 and not now or selectedMenu == 4 and not now then 
            moneyText = ''
            playSound(":cr_account/files/key.mp3")
        end 

        if selectedMenu == 5 and not now then 
            logText = ''
            playSound(":cr_account/files/key.mp3")
        end 
        
        cancelEvent()
    end 
end 

local function ScrollBarUP()
    if LogsScrollBarHover then
        if LogsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            LogsMinLines = LogsMinLines - 1
            LogsMaxLines = LogsMaxLines - 1
        end
    end

    if MoneyTakeLogsScrollBarHover then
        if MoneyTakeLogsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            MoneyTakeLogsMinLines = MoneyTakeLogsMinLines - 1
            MoneyTakeLogsMaxLines = MoneyTakeLogsMaxLines - 1
        end
    end

    if MoneyAddLogsScrollBarHover then
        if MoneyAddLogsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            MoneyAddLogsMinLines = MoneyAddLogsMinLines - 1
            MoneyAddLogsMaxLines = MoneyAddLogsMaxLines - 1
        end
    end

    if PasswordChangeLogsScrollBarHover then
        if PasswordChangeLogsMinLines - 1 >= 1 then
            playSound(":cr_scoreboard/files/wheel.wav")
            PasswordChangeLogsMinLines = PasswordChangeLogsMinLines - 1
            PasswordChangeLogsMaxLines = PasswordChangeLogsMaxLines - 1
        end
    end
end 

local function ScrollBarDown()
    if LogsScrollBarHover then
        local logs = bank_accounts[gId][7]

        if LogsMaxLines + 1 <= #logs then
            playSound(":cr_scoreboard/files/wheel.wav")
            LogsMinLines = LogsMinLines + 1
            LogsMaxLines = LogsMaxLines + 1
        end
    end

    if MoneyTakeLogsScrollBarHover then
        local logs = bank_accounts[gId][8]

        if MoneyTakeLogsMaxLines + 1 <= #logs then
            playSound(":cr_scoreboard/files/wheel.wav")
            MoneyTakeLogsMinLines = MoneyTakeLogsMinLines + 1
            MoneyTakeLogsMaxLines = MoneyTakeLogsMaxLines + 1
        end
    end

    if MoneyAddLogsScrollBarHover then
        local logs = bank_accounts[gId][9]

        if MoneyAddLogsMaxLines + 1 <= #logs then
            playSound(":cr_scoreboard/files/wheel.wav")
            MoneyAddLogsMinLines = MoneyAddLogsMinLines + 1
            MoneyAddLogsMaxLines = MoneyAddLogsMaxLines + 1
        end
    end

    if PasswordChangeLogsScrollBarHover then
        local logs = bank_accounts[gId][10]

        if PasswordChangeLogsMaxLines + 1 <= #logs then
            playSound(":cr_scoreboard/files/wheel.wav")
            PasswordChangeLogsMinLines = PasswordChangeLogsMinLines + 1
            PasswordChangeLogsMaxLines = PasswordChangeLogsMaxLines + 1
        end
    end
end 

function openBankPanel(id)
    if bank_accounts[id] then 
        if not isRender then 
            buttonAnimation = {} 

            isRender = true 

            exports['cr_dx']:startFade("bank >> bankPanel", 
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

            gId = id
            selectedMenu = 1
            LogsMinLines = 1
            LogsMaxLines = 9
            LogsScrolling = false 
            
            createRender("renderBankPanel", renderBankPanel)

            bindKey("enter", "down", enterInteraction)
            bindKey("backspace", "down", backspaceInteraction)
            addEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientClick", root, onClick)
            bindKey("mouse_wheel_up", "down", ScrollBarUP)
            bindKey("mouse_wheel_down", "down", ScrollBarDown)
        end 
    end 
end 

function closeBankPanel()
    if isRender then 
        exports['cr_dashboard']:clearAlerts()
        
        isRender = false 

        exports['cr_dx']:startFade("bank >> bankPanel", 
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
        
        unbindKey("enter", "down", enterInteraction)
        unbindKey("backspace", "down", backspaceInteraction)
        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientClick", root, onClick)
        unbindKey("mouse_wheel_up", "down", ScrollBarUP)
        unbindKey("mouse_wheel_down", "down", ScrollBarDown)
    end 
end 

function renderBankPanel()
    local alpha, progress = exports['cr_dx']:getFade("bank >> bankPanel")
    if not isRender then 
        if progress >= 1 then 
            destroyRender("renderBankPanel")
            return 
        end  
    end 

    if getDistanceBetweenPoints3D(gPed.position, localPlayer.position) > 3 then 
        closeBankPanel()
    end 

    local nowTick = getTickCount()
    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Bold', 12)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    local font4 = exports['cr_fonts']:getFont('Poppins-Regular', 12)

    --[[
        BG
    ]]
    local w, h = 650, 550 
    local x, y = sx/2 - w/2, sy/2 - h/2
    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.9))

    --[[
        Header
    ]]
    dxDrawRectangle(x, y, w, 40, tocolor(41, 41, 41, alpha * 0.9))
    dxDrawImage(x + 13, y + 5, 26, 30, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    closeHover = nil
    if exports['cr_core']:isInSlot(x + 616, y + 12, 15, 16) then 
        closeHover = true

        dxDrawImage(x + 616, y + 12, 15, 16, "assets/images/exit.png", 0, 0, 0, tocolor(242, 242, 242, alpha))
    else 
        dxDrawImage(x + 616, y + 12, 15, 16, "assets/images/exit.png", 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
    end 

    --[[
        Header buttons
    ]]
    local startX = x + 56
    
    buttonHover = nil 
    for k,v in ipairs(buttons) do 
        if selectedMenu == k or buttonAnimation[k] then 
            local icon, iconW, iconH = unpack(v[1])

            local tWidth = dxGetTextWidth(v[2], 1, font)

            local w2 = 15 + iconW + tWidth

            if buttonAnimation[k] then 
                local startTick, type = unpack(buttonAnimation[k])
                local progress = (nowTick - startTick) / 250

                if progress > 1 then 
                    buttonAnimation[k] = nil
                end 

                w2 = interpolateBetween(
                    type == 1 and (5 + iconW + 5) or w2, 0, 0,
                    type == 1 and w2 or (5 + iconW + 5), 0, 0,
                    progress, "InOutQuad"
                )
            end

            dxDrawImage(startX, y, w2, 40, 'assets/images/gradient.png', 0, 0, 0, tocolor(255, 255, 255, alpha * 0.6))
            dxDrawRectangle(startX, y + 38, w2, 2, tocolor(255, 59, 59, alpha))

            dxDrawImage(startX + 5, y + 40/2 - iconH/2, iconW, iconH, 'assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, alpha))
            dxDrawText(v[2], startX + 5 + iconW + 5, y, startX + w2, y + 40 + 4, tocolor(242, 242, 242, alpha), 1, font, "left", "center", true)

            startX = startX + w2 + 10
        else 
            local icon, iconW, iconH = unpack(v[1])
            if exports['cr_core']:isInSlot(startX, y + 40/2 - iconH/2, iconW, iconH) then 
                buttonHover = k 

                dxDrawImage(startX, y + 40/2 - iconH/2, iconW, iconH, 'assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.85))
            else 
                dxDrawImage(startX, y + 40/2 - iconH/2, iconW, iconH, 'assets/images/' .. icon .. '.png', 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
            end 

            startX = startX + iconW + 15
        end 
    end 

    y = y + 40

    if selectedMenu == 1 then 
        local awesomeFont = exports['cr_fonts']:getFont("FontAwesome", 9)

        local w2, h2 = 620, 193

        --[[
            Details
        ]]
        dxDrawRectangle(x + 15, y + 15, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Banki információk', x + 15 + 15, y + 15 + 12, x + 15 + 15, y + 15 + 12, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawImage(x + 15 + 40, y + 15 + 40, 113, 113, 'assets/images/safeIcon.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        local colorCode = exports['cr_core']:getServerColor("red", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local yellow = exports['cr_core']:getServerColor("yellow", true)

        local playerName = exports['cr_admin']:getAdminName(localPlayer)
        dxDrawText(color .. "Üdvözöllek a kezelőfelületen kedves ".. colorCode .. playerName .. color .. "!", x + 15 + 181, y + 15 + 28, x + 15 + 181, y + 15 + 28, tocolor(242, 242, 242, alpha), 1, font2, "left", "top", false, false, false, true)

        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 56, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 56, 430, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Számla tulajdonos: ".. playerName, x + 15 + 171 + 10, y + 15 + 56, x + 15 + 171 + 10 + 430, y + 15 + 56 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 56, 430, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Számla tulajdonos: ".. colorCode .. playerName, x + 15 + 171 + 10, y + 15 + 56, x + 15 + 171 + 10 + 430, y + 15 + 56 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 79, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 79, 430, 20, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawText("Elsődleges számla: " .. (bank_accounts[gId][5] == 1 and "Igen" or "Nem"), x + 15 + 171 + 10, y + 15 + 79, x + 15 + 171 + 10 + 430, y + 15 + 79 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 79, 430, 20, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawText(color .. "Elsődleges számla: ".. colorCode .. (bank_accounts[gId][5] == 1 and green .. "Igen" or "Nem"), x + 15 + 171 + 10, y + 15 + 79, x + 15 + 171 + 10 + 430, y + 15 + 79 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 102, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 102, 430, 20, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawText("Számlaszám: " .. formatCardNumber(bank_accounts[gId][3]), x + 15 + 171 + 10, y + 15 + 102, x + 15 + 171 + 10 + 430, y + 15 + 102 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 102, 430, 20, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawText(color .. "Számlaszám: " .. yellow .. formatCardNumber(bank_accounts[gId][3]), x + 15 + 171 + 10, y + 15 + 102, x + 15 + 171 + 10 + 430, y + 15 + 102 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        local moneyColorCode = colorCode
        if tonumber(bank_accounts[gId][4] or 0) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 125, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 125, 430, 20, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawText("Egyenleg: " .. "$ " .. bank_accounts[gId][4], x + 15 + 171 + 10, y + 15 + 125, x + 15 + 171 + 10 + 430, y + 15 + 125 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 125, 430, 20, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawText(color .. "Egyenleg: ".. moneyColorCode .. "$ " .. bank_accounts[gId][4], x + 15 + 171 + 10, y + 15 + 125, x + 15 + 171 + 10 + 430, y + 15 + 125 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 
        
        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 148, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 148, 430, 20, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawText("Pinkód: " .. bank_accounts[gId][6], x + 15 + 171 + 10, y + 15 + 148, x + 15 + 171 + 10 + 430, y + 15 + 148 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 148, 430, 20, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawText(color.."Pinkód: " .. colorCode .. bank_accounts[gId][6], x + 15 + 171 + 10, y + 15 + 148, x + 15 + 171 + 10 + 430, y + 15 + 148 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        y = y + 15 + h2 + 14

        --[[
            Center Line
        ]]
        dxDrawRectangle(x + 35, y, 580, 2, tocolor(153, 153, 153, alpha * 0.6))

        y = y + 2 + 14

        --[[
            Logs
        ]]

        dxDrawRectangle(x + 15, y, w2, 245, tocolor(41, 41, 41, alpha * 0.9))

        dxDrawText('Tevékenység', x + 15 + 15, y + 12, x + 15 + 15, y + 12, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        local logs = bank_accounts[gId][7]

        LogsScrollBarHover = exports['cr_core']:isInSlot(x + 15, y, w2, 245)
        
        --scrollbar
        local scrollx, scrolly = x + 15 + 612, y + 31
        local scrollh = 203
        dxDrawRectangle(scrollx, scrolly, 3, scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #logs

        if percent >= 1 then
            local gW, gH = 3, scrollh
            local gX, gY = scrollx, scrolly

            LogsScrollingHover = exports['cr_core']:isInSlot(gX, gY, gW, gH)

            if LogsScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        LogsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 9) + 1)))
                        LogsMaxLines = LogsMinLines + (9 - 1)
                    end
                else
                    LogsScrolling = false
                end
            end

            local multiplier = math.min(math.max((LogsMaxLines - (LogsMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((LogsMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            local r,g,b = 255, 59, 59
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        end
        --

        local startX, startY = x + 15 + 10, y + 30
        for i = LogsMinLines, LogsMaxLines do 
            local w, h = 595, 20

            local inSlot = exports['cr_core']:isInSlot(startX, startY, w, h)
            if inSlot then 
                dxDrawRectangle(startX, startY, w, h, tocolor(242, 242, 242, alpha * 0.8))
            else 
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.8))
            end 

            local data = logs[i]
            if type(data) == "table" then 
                text = data[1]
            else 
                text = data
            end 

            if text then 
                if inSlot then 
                    dxDrawText(string.gsub(text, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + 6, startY, startX + w, startY + h + 4, tocolor(51, 51, 51, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText("", startX, startY, startX + w - 6, startY + h, tocolor(51, 51, 51,alpha), 1, awesomeFont, "right", "center", false, false, false, true)

                        local textWidth = dxGetTextWidth("", 1, awesomeFont, false)
                        if exports['cr_core']:isInSlot(startX + w - 6 - textWidth, startY, textWidth, h) then 
                            exports['cr_dx']:drawTooltip(2, data[2])
                        end 
                    end 
                else 
                    dxDrawText(color .. text, startX + 6, startY, startX + w, startY + h + 4, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText(color .. "", startX, startY, startX + w - 6, startY + h, tocolor(242, 242, 242,alpha), 1, awesomeFont, "right", "center", false, false, false, true)
                    end 
                end 
            end 

            startY = startY + h + 3
        end 
    elseif selectedMenu == 2 then 
        local w2, h2 = 620, 193

        --[[
            Details
        ]]
        dxDrawRectangle(x + 15, y + 15, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Egyenleg', x + 15 + 15, y + 15 + 12, x + 15 + 15, y + 15 + 12, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawImage(x + 15 + 40, y + 15 + 40, 113, 113, 'assets/images/transferIcon.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        local colorCode = exports['cr_core']:getServerColor("red", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local money = tonumber(localPlayer:getData("char >> money") or 0)
        local moneyColorCode = colorCode
        if tonumber(money) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 39, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 39, 430, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Készpénz: $ ".. money, x + 15 + 171 + 10, y + 15 + 39, x + 15 + 171 + 10 + 430, y + 15 + 39 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 39, 430, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Készpénz: ".. moneyColorCode .. "$ ".. money, x + 15 + 171 + 10, y + 15 + 39, x + 15 + 171 + 10 + 430, y + 15 + 39 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        local money = tonumber(bank_accounts[gId][4] or 0)
        local moneyColorCode = colorCode
        if tonumber(money) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 171, y + 15 + 62, 430, 20) then 
            dxDrawRectangle(x + 15 + 171, y + 15 + 62, 430, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Banki egyenleg: $ ".. money, x + 15 + 171 + 10, y + 15 + 62, x + 15 + 171 + 10 + 430, y + 15 + 62 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 171, y + 15 + 62, 430, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Banki egyenleg: ".. moneyColorCode .. "$ ".. money, x + 15 + 171 + 10, y + 15 + 62, x + 15 + 171 + 10 + 430, y + 15 + 62 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        y = y + 15 + h2 + 14

        --[[
            Center Line
        ]]
        dxDrawRectangle(x + 35, y, 580, 2, tocolor(153, 153, 153, alpha * 0.6))

        y = y + 2 + 14

        --[[
            Logs
        ]]

        dxDrawRectangle(x + 15, y, w2, 245, tocolor(41, 41, 41, alpha * 0.9))

        dxDrawText('Utalás', x + 15 + 15, y + 12, x + 15 + 15, y + 12, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        dxDrawText('Számlaszám:', x + 15 + 15, y + 33, x + 15 + 15, y + 33 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 116, y + 33, 250, 20, tocolor(51, 51, 51, alpha * 0.8))
        UpdatePos("bank >> cardNumber", {x + 15 + 116 + 5, y + 33, 250 - 10, 20 + 4})
        UpdateAlpha("bank >> cardNumber", tocolor(242, 242, 242,alpha))

        dxDrawText('Tárgy:', x + 15 + 15, y + 56, x + 15 + 15, y + 56 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 116, y + 56, 250, 20, tocolor(51, 51, 51, alpha * 0.8))
        UpdatePos("bank >> subjectText", {x + 15 + 116 + 5, y + 56, 250 - 10, 20 + 4})
        UpdateAlpha("bank >> subjectText", tocolor(242, 242, 242,alpha))

        dxDrawText('Üzenet:', x + 15 + 15, y + 79, x + 15 + 15, y + 79 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 116, y + 79, 250, 125, tocolor(51, 51, 51, alpha * 0.8))
        UpdatePos("bank >> messageText", {x + 15 + 116 + 5, y + 79 + 2.5, 250 - 10, 125 - 10})
        UpdateAlpha("bank >> messageText", tocolor(242, 242, 242,alpha))

        dxDrawText('Összeg:', x + 15 + 391, y + 33, x + 15 + 391, y + 33 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 451, y + 33, 150, 20, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(moneyText, x + 15 + 451 + 5, y + 33, x + 15 + 451 + 5, y + 33 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")

        --[[
            Pinpanel
        ]]

        local w2, h2 = 58, 50
        local rw2, rh2 = 38, 30

        pinHover = nil 
        local count = 1
        local startX, startY = x + 15 + 462, y + 60
        local _startX = startX

        for i = 1, 12 do 
            local text = i 
            if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "backspace" end

            local inSlot = exports['cr_core']:isInSlot(startX, startY, rw2, rh2)
            if inSlot or getKeyState(text) then 
                if inSlot then 
                    pinHover = text == 'backspace' and 'backspace' or i
                end 

                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                end
            else 
                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                end 
            end 

            count = count + 1
            startX = startX + rw2 + 10
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + rh2 + 10
            end 
        end 

        --[[
            Finish Button
        ]]

        local startX = startX

        local w2, h2 = 155, 44
        local rw2, rh2 = 134, 22

        hover = nil 
        if exports['cr_core']:isInSlot(startX, y + 215, rw2, rh2) then 
            hover = 1

            dxDrawImage(startX + rw2/2 - w2/2, y + 215 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Utalás', startX, y + 215, startX + rw2, y + 215 + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        else 
            dxDrawImage(startX + rw2/2 - w2/2, y + 215 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Utalás', startX, y + 215, startX + rw2, y + 215 + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "center", "center")
        end 
    elseif selectedMenu == 3 then 
        local w2, h2 = 620, 245

        --[[
            Details
        ]]
        dxDrawRectangle(x + 15, y + 15, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Készpénz felvétel', x + 15 + 15, y + 15 + 12, x + 15 + 15, y + 15 + 12, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawImage(x + 15 + 34, y + 15 + 53, 98, 113, 'assets/images/cashOutIcon.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        local colorCode = exports['cr_core']:getServerColor("red", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local money = tonumber(localPlayer:getData("char >> money") or 0)
        local moneyColorCode = colorCode
        if tonumber(money) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 10, y + 15 + 185, 350, 20) then 
            dxDrawRectangle(x + 15 + 10, y + 15 + 185, 350, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Készpénz: $ ".. money, x + 15 + 10 + 10, y + 15 + 185, x + 15 + 10 + 10 + 350, y + 15 + 185 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 10, y + 15 + 185, 350, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Készpénz: ".. moneyColorCode .. "$ ".. money, x + 15 + 10 + 10, y + 15 + 185, x + 15 + 10 + 10 + 350, y + 15 + 185 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        local money = tonumber(bank_accounts[gId][4] or 0)
        local moneyColorCode = colorCode
        if tonumber(money) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 10, y + 15 + 208, 350, 20) then 
            dxDrawRectangle(x + 15 + 10, y + 15 + 208, 350, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Banki egyenleg: $ ".. money, x + 15 + 10 + 10, y + 15 + 208, x + 15 + 10 + 10 + 350, y + 15 + 208 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 10, y + 15 + 208, 350, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Banki egyenleg: ".. moneyColorCode .. "$ ".. money, x + 15 + 10 + 10, y + 15 + 208, x + 15 + 10 + 10 + 350, y + 15 + 208 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        dxDrawText('Összeg:', x + 15 + 170, y + 15 + 30, x + 15 + 170, y + 15 + 30 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 230, y + 15 + 30, 150, 20, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(moneyText, x + 15 + 230 + 5, y + 15 + 30, x + 15 + 230 + 5, y + 15 + 30 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")

        --[[
            Pinpanel
        ]]

        local _w2, _h2 = w2, h2

        local w2, h2 = 66, 58
        local rw2, rh2 = 43, 35

        pinHover = nil 
        local count = 1
        local startX, startY = x + 15 + 420, y + 15 + 30
        local _startX = startX

        for i = 1, 12 do 
            local text = i 
            if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "backspace" end

            local inSlot = exports['cr_core']:isInSlot(startX, startY, rw2, rh2)
            if inSlot or getKeyState(text) then 
                if inSlot then 
                    pinHover = text == 'backspace' and 'backspace' or i
                end 

                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                end
            else 
                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                end 
            end 

            count = count + 1
            startX = startX + rw2 + 10
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + rh2 + 10
            end 
        end 

        --[[
            Finish Button
        ]]

        local startX = startX

        local w2, h2 = 173, 49
        local rw2, rh2 = 150, 26

        hover = nil 
        if exports['cr_core']:isInSlot(startX, y + 15 + 205, rw2, rh2) then 
            hover = 1

            dxDrawImage(startX + rw2/2 - w2/2, y + 15 + 205 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Pénz felvétel', startX, y + 15 + 205, startX + rw2, y + 15 + 205 + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        else 
            dxDrawImage(startX + rw2/2 - w2/2, y + 15 + 205 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Pénz felvétel', startX, y + 15 + 205, startX + rw2, y + 15 + 205 + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "center", "center")
        end 

        w2, h2 = _w2, _h2

        y = y + 15 + h2 + 17

        --[[
            Center Line
        ]]
        dxDrawRectangle(x + 35, y, 580, 2, tocolor(153, 153, 153, alpha * 0.6))

        y = y + 2 + 16

        --[[
            Logs
        ]]

        dxDrawRectangle(x + 15, y, w2, 193, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Tevékenység', x + 15 + 15, y + 8, x + 15 + 15, y + 8, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        local logs = bank_accounts[gId][8]

        MoneyTakeLogsScrollBarHover = exports['cr_core']:isInSlot(x + 15, y, w2, 245)
        
        --scrollbar
        local scrollx, scrolly = x + 15 + 612, y + 31
        local scrollh = 157
        dxDrawRectangle(scrollx, scrolly, 3, scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #logs

        if percent >= 1 then
            local gW, gH = 3, scrollh
            local gX, gY = scrollx, scrolly

            MoneyTakeLogsScrollingHover = exports['cr_core']:isInSlot(gX, gY, gW, gH)

            if MoneyTakeLogsScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        MoneyTakeLogsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        MoneyTakeLogsMaxLines = MoneyTakeLogsMinLines + (7 - 1)
                    end
                else
                    MoneyTakeLogsScrolling = false
                end
            end

            local multiplier = math.min(math.max((MoneyTakeLogsMaxLines - (MoneyTakeLogsMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((MoneyTakeLogsMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            local r,g,b = 255, 59, 59
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        end
        --

        local startX, startY = x + 15 + 10, y + 30
        for i = MoneyTakeLogsMinLines, MoneyTakeLogsMaxLines do 
            local w, h = 595, 20

            local inSlot = exports['cr_core']:isInSlot(startX, startY, w, h)
            if inSlot then 
                dxDrawRectangle(startX, startY, w, h, tocolor(242, 242, 242, alpha * 0.8))
            else 
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.8))
            end 

            local data = logs[i]
            if type(data) == "table" then 
                text = data[1]
            else 
                text = data
            end 

            if text then 
                if inSlot then 
                    dxDrawText(string.gsub(text, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + 6, startY, startX + w, startY + h + 4, tocolor(51, 51, 51, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText("", startX, startY, startX + w - 6, startY + h, tocolor(51, 51, 51,alpha), 1, awesomeFont, "right", "center", false, false, false, true)

                        local textWidth = dxGetTextWidth("", 1, awesomeFont, false)
                        if exports['cr_core']:isInSlot(startX + w - 6 - textWidth, startY, textWidth, h) then 
                            exports['cr_dx']:drawTooltip(2, data[2])
                        end 
                    end 
                else 
                    dxDrawText(color .. text, startX + 6, startY, startX + w, startY + h + 4, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText(color .. "", startX, startY, startX + w - 6, startY + h, tocolor(242, 242, 242,alpha), 1, awesomeFont, "right", "center", false, false, false, true)
                    end 
                end 
            end 

            startY = startY + h + 3
        end
    elseif selectedMenu == 4 then 
        local w2, h2 = 620, 245

        --[[
            Details
        ]]
        dxDrawRectangle(x + 15, y + 15, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Készpénz felvétel', x + 15 + 15, y + 15 + 12, x + 15 + 15, y + 15 + 12, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawImage(x + 15 + 40, y + 15 + 53, 74, 113, 'assets/images/cashInIcon.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        local colorCode = exports['cr_core']:getServerColor("red", true)
        local green = exports['cr_core']:getServerColor("green", true)
        local money = tonumber(localPlayer:getData("char >> money") or 0)
        local moneyColorCode = colorCode
        if tonumber(money) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 10, y + 15 + 185, 350, 20) then 
            dxDrawRectangle(x + 15 + 10, y + 15 + 185, 350, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Készpénz: $ ".. money, x + 15 + 10 + 10, y + 15 + 185, x + 15 + 10 + 10 + 350, y + 15 + 185 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 10, y + 15 + 185, 350, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Készpénz: ".. moneyColorCode .. "$ ".. money, x + 15 + 10 + 10, y + 15 + 185, x + 15 + 10 + 10 + 350, y + 15 + 185 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        local money = tonumber(bank_accounts[gId][4] or 0)
        local moneyColorCode = colorCode
        if tonumber(money) >= 0 then 
            moneyColorCode = green
        end 

        if exports['cr_core']:isInSlot(x + 15 + 10, y + 15 + 208, 350, 20) then 
            dxDrawRectangle(x + 15 + 10, y + 15 + 208, 350, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Banki egyenleg: $ ".. money, x + 15 + 10 + 10, y + 15 + 208, x + 15 + 10 + 10 + 350, y + 15 + 208 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 10, y + 15 + 208, 350, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Banki egyenleg: ".. moneyColorCode .. "$ ".. money, x + 15 + 10 + 10, y + 15 + 208, x + 15 + 10 + 10 + 350, y + 15 + 208 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end 

        dxDrawText('Összeg:', x + 15 + 170, y + 15 + 30, x + 15 + 170, y + 15 + 30 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 230, y + 15 + 30, 150, 20, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(moneyText, x + 15 + 230 + 5, y + 15 + 30, x + 15 + 230 + 5, y + 15 + 30 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")

        --[[
            Pinpanel
        ]]

        local _w2, _h2 = w2, h2

        local w2, h2 = 66, 58
        local rw2, rh2 = 43, 35

        pinHover = nil 
        local count = 1
        local startX, startY = x + 15 + 420, y + 15 + 30
        local _startX = startX

        for i = 1, 12 do 
            local text = i 
            if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "backspace" end

            local inSlot = exports['cr_core']:isInSlot(startX, startY, rw2, rh2)
            if inSlot or getKeyState(text) then 
                if inSlot then 
                    pinHover = text == 'backspace' and 'backspace' or i
                end 

                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                end
            else 
                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                end 
            end 

            count = count + 1
            startX = startX + rw2 + 10
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + rh2 + 10
            end 
        end 

        --[[
            Finish Button
        ]]

        local startX = startX

        local w2, h2 = 173, 49
        local rw2, rh2 = 150, 26

        hover = nil 
        if exports['cr_core']:isInSlot(startX, y + 15 + 205, rw2, rh2) then 
            hover = 1

            dxDrawImage(startX + rw2/2 - w2/2, y + 15 + 205 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Pénz berakása', startX, y + 15 + 205, startX + rw2, y + 15 + 205 + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        else 
            dxDrawImage(startX + rw2/2 - w2/2, y + 15 + 205 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Pénz berakása', startX, y + 15 + 205, startX + rw2, y + 15 + 205 + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "center", "center")
        end 

        w2, h2 = _w2, _h2

        y = y + 15 + h2 + 17

        --[[
            Center Line
        ]]
        dxDrawRectangle(x + 35, y, 580, 2, tocolor(153, 153, 153, alpha * 0.6))

        y = y + 2 + 16

        --[[
            Logs
        ]]

        dxDrawRectangle(x + 15, y, w2, 193, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Tevékenység', x + 15 + 15, y + 8, x + 15 + 15, y + 8, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        local logs = bank_accounts[gId][9]

        MoneyAddLogsScrollBarHover = exports['cr_core']:isInSlot(x + 15, y, w2, 245)
        
        --scrollbar
        local scrollx, scrolly = x + 15 + 612, y + 31
        local scrollh = 157
        dxDrawRectangle(scrollx, scrolly, 3, scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #logs

        if percent >= 1 then
            local gW, gH = 3, scrollh
            local gX, gY = scrollx, scrolly

            MoneyAddLogsScrollingHover = exports['cr_core']:isInSlot(gX, gY, gW, gH)

            if MoneyAddLogsScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        MoneyAddLogsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        MoneyAddLogsMaxLines = MoneyAddLogsMinLines + (7 - 1)
                    end
                else
                    MoneyAddLogsScrolling = false
                end
            end

            local multiplier = math.min(math.max((MoneyAddLogsMaxLines - (MoneyAddLogsMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((MoneyAddLogsMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            local r,g,b = 255, 59, 59
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        end
        --

        local startX, startY = x + 15 + 10, y + 30
        for i = MoneyAddLogsMinLines, MoneyAddLogsMaxLines do 
            local w, h = 595, 20

            local inSlot = exports['cr_core']:isInSlot(startX, startY, w, h)
            if inSlot then 
                dxDrawRectangle(startX, startY, w, h, tocolor(242, 242, 242, alpha * 0.8))
            else 
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.8))
            end 

            local data = logs[i]
            if type(data) == "table" then 
                text = data[1]
            else 
                text = data
            end 

            if text then 
                if inSlot then 
                    dxDrawText(string.gsub(text, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + 6, startY, startX + w, startY + h + 4, tocolor(51, 51, 51, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText("", startX, startY, startX + w - 6, startY + h, tocolor(51, 51, 51,alpha), 1, awesomeFont, "right", "center", false, false, false, true)

                        local textWidth = dxGetTextWidth("", 1, awesomeFont, false)
                        if exports['cr_core']:isInSlot(startX + w - 6 - textWidth, startY, textWidth, h) then 
                            exports['cr_dx']:drawTooltip(2, data[2])
                        end 
                    end 
                else 
                    dxDrawText(color .. text, startX + 6, startY, startX + w, startY + h + 4, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText(color .. "", startX, startY, startX + w - 6, startY + h, tocolor(242, 242, 242,alpha), 1, awesomeFont, "right", "center", false, false, false, true)
                    end 
                end 
            end 

            startY = startY + h + 3
        end
    elseif selectedMenu == 5 then 
        local w2, h2 = 620, 245

        --[[
            Details
        ]]
        dxDrawRectangle(x + 15, y + 15, w2, h2, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Számla kezelés', x + 15 + 10, y + 15 + 13, x + 15 + 10, y + 15 + 13 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")
        dxDrawImage(x + 15 + 40, y + 15 + 53, 113, 113, 'assets/images/settingsIcon.png', 0, 0, 0, tocolor(255, 255, 255, alpha))

        local colorCode = exports['cr_core']:getServerColor("red", true)

        if exports['cr_core']:isInSlot(x + 15 + 136, y + 15 + 13, 225, 20) then 
            dxDrawRectangle(x + 15 + 136, y + 15 + 13, 225, 20, tocolor(242, 242, 242, alpha * 0.8)) 
            dxDrawText("Jelenlegi pinkód: ".. bank_accounts[gId][6], x + 15 + 136 + 10, y + 15 + 13, x + 15 + 136 + 10 + 225, y + 15 + 13 + 20 + 4, tocolor(51, 51, 51, alpha), 1, font3, "left", "center", false, false, false, true)
        else 
            dxDrawRectangle(x + 15 + 136, y + 15 + 13, 225, 20, tocolor(51, 51, 51, alpha * 0.8)) 
            dxDrawText(color .. "Jelenlegi pinkód: ".. colorCode .. bank_accounts[gId][6], x + 15 + 136 + 10, y + 15 + 13, x + 15 + 136 + 10 + 225, y + 15 + 13 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center", false, false, false, true)
        end

        dxDrawText('Új pinkód:', x + 15 + 371, y + 15 + 13, x + 15 + 371, y + 15 + 13 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")
        dxDrawRectangle(x + 15 + 445, y + 15 + 13, 150, 20, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText(logText, x + 15 + 445 + 5, y + 15 + 13, x + 15 + 445 + 5, y + 15 + 13 + 20 + 4, tocolor(242, 242, 242, alpha), 1, font3, "left", "center")

        --[[
            Pinpanel
        ]]

        local _w2, _h2 = w2, h2

        local w2, h2 = 58, 50
        local rw2, rh2 = 38, 30

        pinHover = nil 
        local count = 1
        local startX, startY = x + 15 + 456, y + 15 + 40
        local _startX = startX

        for i = 1, 12 do 
            local text = i 
            if text == 10 then text = "X" elseif text == 11 then text = "0" elseif text == 12 then text = "backspace" end

            local inSlot = exports['cr_core']:isInSlot(startX, startY, rw2, rh2)
            if inSlot or getKeyState(text) then 
                if inSlot then 
                    pinHover = text == 'backspace' and 'backspace' or i
                end 

                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(255, 59, 59, alpha * 0.7))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font3, "center", "center")
                end
            else 
                dxDrawImage(startX + rw2/2 - w2/2, startY + rh2/2 - h2/2, w2, h2, 'assets/images/pin-button.png', 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
                if text == 'backspace' then 
                    dxDrawImage(startX + rw2/2 - 17/2, startY + rh2/2 - 12/2, 17, 12, backspaceTex, 0, 0, 0, tocolor(242, 242, 242, alpha * 0.6))
                else 
                    dxDrawText(text, startX, startY, startX + rw2, startY + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
                end 
            end 

            count = count + 1
            startX = startX + rw2 + 10
            if count > 3 then 
                count = 1 
                startX = _startX 
                startY = startY + rh2 + 10
            end 
        end 

        --[[
            Finish Button
        ]]

        local startX = startX

        local w2, h2 = 155, 44
        local rw2, rh2 = 134, 22

        hover = nil 
        if exports['cr_core']:isInSlot(startX, y + 15 + 200, rw2, rh2) then 
            hover = 1

            dxDrawImage(startX + rw2/2 - w2/2, y + 15 + 200 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(97, 177, 90, alpha * 0.7))
            dxDrawText('Új pinkód', startX, y + 15 + 200, startX + rw2, y + 15 + 200 + rh2 + 4, tocolor(242, 242, 242, alpha), 1, font, "center", "center")
        else 
            dxDrawImage(startX + rw2/2 - w2/2, y + 15 + 200 + rh2/2 - h2/2, w2, h2, "assets/images/pin-finish-button.png", 0, 0, 0, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Új pinkód', startX, y + 15 + 200, startX + rw2, y + 15 + 200 + rh2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font, "center", "center")
        end 

        w2, h2 = _w2, _h2

        --[[
            Buttons
        ]]
        if exports['cr_core']:isInSlot(x + 15 + 183, y + 15 + 75, 230, 22) then 
            hover = 2 

            dxDrawRectangle(x + 15 + 183, y + 15 + 75, 230, 22, tocolor(97, 177, 90, alpha))
            dxDrawText('Elsődleges számla beállítása', x + 15 + 183, y + 15 + 75, x + 15 + 183 + 230, y + 15 + 75 + 22 + 4, tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else 
            dxDrawRectangle(x + 15 + 183, y + 15 + 75, 230, 22, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Elsődleges számla beállítása', x + 15 + 183, y + 15 + 75, x + 15 + 183 + 230, y + 15 + 75 + 22 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end

        if exports['cr_core']:isInSlot(x + 15 + 183, y + 15 + 102, 230, 22) then 
            hover = 3
            
            dxDrawRectangle(x + 15 + 183, y + 15 + 102, 230, 22, tocolor(97, 177, 90, alpha))
            dxDrawText('Új bankkártya igénylése', x + 15 + 183, y + 15 + 102, x + 15 + 183 + 230, y + 15 + 102 + 22 + 4, tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else 
            dxDrawRectangle(x + 15 + 183, y + 15 + 102, 230, 22, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Új bankkártya igénylése', x + 15 + 183, y + 15 + 102, x + 15 + 183 + 230, y + 15 + 102 + 22 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end

        if exports['cr_core']:isInSlot(x + 15 + 183, y + 15 + 129, 230, 22) then 
            hover = 4
            
            dxDrawRectangle(x + 15 + 183, y + 15 + 129, 230, 22, tocolor(255, 59, 59, alpha))
            dxDrawText('Számla megszüntetése', x + 15 + 183, y + 15 + 129, x + 15 + 183 + 230, y + 15 + 129 + 22 + 4, tocolor(242, 242, 242, alpha), 1, font4, "center", "center")
        else 
            dxDrawRectangle(x + 15 + 183, y + 15 + 129, 230, 22, tocolor(23, 23, 23, alpha * 0.9))
            dxDrawText('Számla megszüntetése', x + 15 + 183, y + 15 + 129, x + 15 + 183 + 230, y + 15 + 129 + 22 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font4, "center", "center")
        end

        y = y + 15 + h2 + 17

        --[[
            Center Line
        ]]
        dxDrawRectangle(x + 35, y, 580, 2, tocolor(153, 153, 153, alpha * 0.6))

        y = y + 2 + 16

        --[[
            Logs
        ]]

        dxDrawRectangle(x + 15, y, w2, 193, tocolor(41, 41, 41, alpha * 0.9))
        dxDrawText('Tevékenység', x + 15 + 15, y + 8, x + 15 + 15, y + 8, tocolor(242, 242, 242, alpha), 1, font2, "left", "top")

        local logs = bank_accounts[gId][10]

        PasswordChangeLogsScrollBarHover = exports['cr_core']:isInSlot(x + 15, y, w2, 245)
        
        --scrollbar
        local scrollx, scrolly = x + 15 + 612, y + 31
        local scrollh = 157
        dxDrawRectangle(scrollx, scrolly, 3, scrollh, tocolor(242, 242, 242, alpha * 0.6))
    
        local percent = #logs

        if percent >= 1 then
            local gW, gH = 3, scrollh
            local gX, gY = scrollx, scrolly

            PasswordChangeLogsScrollingHover = exports['cr_core']:isInSlot(gX, gY, gW, gH)

            if PasswordChangeLogsScrolling then
                if isCursorShowing() then
                    if getKeyState("mouse1") then
                        local cx, cy = exports['cr_core']:getCursorPosition()
                        local cy = math.min(math.max(cy, gY), gY + gH)
                        local y = (cy - gY) / (gH)
                        local num = percent * y
                        PasswordChangeLogsMinLines = math.max(1, math.floor(math.min(math.max(num, 1), (percent - 7) + 1)))
                        PasswordChangeLogsMaxLines = PasswordChangeLogsMinLines + (7 - 1)
                    end
                else
                    PasswordChangeLogsScrolling = false
                end
            end

            local multiplier = math.min(math.max((PasswordChangeLogsMaxLines - (PasswordChangeLogsMinLines - 1)) / percent, 0), 1)
            local multiplier2 = math.min(math.max((PasswordChangeLogsMinLines - 1) / percent, 0), 1)
            local gY = gY + ((gH) * multiplier2)
            local gH = gH * multiplier

            local r,g,b = 255, 59, 59
            dxDrawRectangle(gX, gY, gW, gH, tocolor(r,g,b, alpha))
        end
        --

        local startX, startY = x + 15 + 10, y + 30
        for i = PasswordChangeLogsMinLines, PasswordChangeLogsMaxLines do 
            local w, h = 595, 20

            local inSlot = exports['cr_core']:isInSlot(startX, startY, w, h)
            if inSlot then 
                dxDrawRectangle(startX, startY, w, h, tocolor(242, 242, 242, alpha * 0.8))
            else 
                dxDrawRectangle(startX, startY, w, h, tocolor(51, 51, 51, alpha * 0.8))
            end 

            local data = logs[i]
            if type(data) == "table" then 
                text = data[1]
            else 
                text = data
            end 

            if text then 
                if inSlot then 
                    dxDrawText(string.gsub(text, "#"..(6 and string.rep("%x", 6) or "%x+"), ""), startX + 6, startY, startX + w, startY + h + 4, tocolor(51, 51, 51, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText("", startX, startY, startX + w - 6, startY + h, tocolor(51, 51, 51,alpha), 1, awesomeFont, "right", "center", false, false, false, true)

                        local textWidth = dxGetTextWidth("", 1, awesomeFont, false)
                        if exports['cr_core']:isInSlot(startX + w - 6 - textWidth, startY, textWidth, h) then 
                            exports['cr_dx']:drawTooltip(2, data[2])
                        end 
                    end 
                else 
                    dxDrawText(color .. text, startX + 6, startY, startX + w, startY + h + 4, tocolor(242, 242, 242, alpha), 1, font4, "left", "center", true, false, false, true)

                    if type(data) == "table" then 
                        dxDrawText(color .. "", startX, startY, startX + w - 6, startY + h, tocolor(242, 242, 242,alpha), 1, awesomeFont, "right", "center", false, false, false, true)
                    end 
                end 
            end 

            startY = startY + h + 3
        end
    end 
end 

--
function getPlayerBankAccounts(e)
    local player_bank_accounts = {} 
    for k,v in pairs(bank_accounts) do 
        if v[2] == e:getData("acc >> id") then 
            if v[5] == 1 then 
                table.insert(player_bank_accounts, 1, v)
            else 
                table.insert(player_bank_accounts, #player_bank_accounts, v)
            end 
        end 
    end 

    return player_bank_accounts
end 

function getPlayerMainAccount(e)
    for k,v in pairs(bank_accounts) do 
        if v[2] == e:getData("acc >> id") then 
            if v[5] == 1 then 
                return k
            end 
        end 
    end 

    return false
end 

function getBankAccountMoney(sourcePlayer, id)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            return bank_accounts[id][4]
        end
    end 

    return -1
end 

function hasMoney(sourcePlayer, id, money)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) and tonumber(money) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            if bank_accounts[id][4] >= money then 
                return true 
            end 
        end
    end 

    return false 
end 

function takeMoney(sourcePlayer, id, money)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) and tonumber(money) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            triggerLatentServerEvent("bank >> takeMoney", 5000, false, localPlayer, sourcePlayer, id, bank_accounts[id][4], money)
            bank_accounts[id][4] = bank_accounts[id][4] - money

            return true 
        end
    end 

    return false 
end 

function giveMoney(sourcePlayer, id, money)
    if not tonumber(id) then 
        id = getPlayerMainAccount(sourcePlayer)
    end 

    if tonumber(id) and tonumber(money) then 
        if bankCardNumberToID[id] then 
            id = bankCardNumberToID[id]
        end 

        if bank_accounts[id] then 
            triggerLatentServerEvent("bank >> giveMoney", 5000, false, localPlayer, sourcePlayer, id, bank_accounts[id][4], money)
            return true 
        end
    end 

    return false 
end 

function addCharToString(str, pos, chr, howMany, origPos)
    if howMany == 0 then return str end
    if not origPos then origPos = pos end
    local stringVariation = str:sub(1, pos) .. chr .. str:sub(pos + 1)
    howMany = howMany - 1
    return addCharToString(stringVariation, pos + origPos, chr, howMany, origPos)
end