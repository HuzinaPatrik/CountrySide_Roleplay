textbars = {}
local state = false
local oText = "*****************************************************************************************************************************************"
local disabledKey = {
    ["capslock"] = true,
    ["lctrl"] = true,
    ["rctrl"] = true,
    ["lalt"] = true,
    ["ralt"] = true,
    ["home"] = true,
    [";"] = true,
    ["'"] = true,
    ["]"] = true,
    ["["] = true,
    ["="] = true,
    ["_"] = true,
    ["á"] = true,
    ["é"] = true,
    ["ű"] = true,
    ["#"] = true,
    ["\\"] = true,
    ["/"] = true,
    --["."] = true,
    [","] = true,
    ['"'] = true,
    ["_"] = true,
    ["-"] = true,
    ["*"] = true,
    ["-"] = true,
    ["+"] = true,
    ["//"] = true,
    --[" "] = true,
    [""] = true,
}

local subWord = {
    [";"] = "é",
    ["#"] = "á",
    ["["] = "ő",
    ["]"] = "ú",
    ["="] = "ó",
    ["/"] = "ü",
}

local changeKey = {
    ["num_0"] = "0",
    ["num_1"] = "1",
    ["num_2"] = "2",
    ["num_3"] = "3",
    ["num_4"] = "4",
    ["num_5"] = "5",
    ["num_6"] = "6",
    ["num_7"] = "7",
    ["num_8"] = "8",
    ["num_9"] = "9",
}
local guiState = false
now = nil
local tick = 0
 
--[[
Bar felépítése tábla alapján:
textbars["Bar név"] = {{details(x,y,w,h)}, {options(hosszúság, defaultText, onlyNumber, color, font, fontsize, alignX, alingY, secured)}, id}
A defaultText állandóan változik azaz nem kell külön text változó táblába
]]

local gui 

function onGuiBlur2()
    --outputChatBox("asd")
    setTimer(onGuiBlur, 100, 1)
end
--bindKey("F8", "down", onGuiBlur2)

function CreateNewBar(name, details, options, id, refresh)
    textbars[name] = {details, options, id}
    if name == "Desc >> Edit" or name == "FactionMessage >> Edit" or name == "Char-Reg.Name" or name == "Char-Reg.Weight" or name == "Char-Reg.Height" then
        now = name
        --textbars[now][2][2] = ""
        tick = 250

        if isElement(gui) then
            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
            if isTimer(checkTimers) then killTimer(checkTimers) end
            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
            destroyElement(gui)
        end
        gui = GuiEdit(-1, -1, 1, 1, "", true)
        --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
        gui.maxLength = textbars[now][2][1]
        guiSetText(gui, textbars[now][2][2])
        guiEditSetCaretIndex(gui, #guiGetText(gui))
        --guiSetProperty(gui, "AlwaysOnTop", "True")
        if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
        guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)

        addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
        
        checkTimers = setTimer(onGuiBlur, 150, 0)
        addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
        
        --setElementData(localPlayer, "bar >> Use", true)
        guiState = true
        allSelected = false
    end
    
    if not state then
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
        --createRender("DrawnBars", DrawnBars)
        state = true
    end

    if refresh then 
        removeEventHandler("onClientRender", root, DrawnBars)
        addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
    end 
end

function Clear()
    mdcWantedCarsSearchCache = nil
    mdcWantedPersonsSearchCache = nil
    mdcTicketsSearchCache = nil
    mdcWantedWeaponsSearchCache = nil
    mdcRegisteredWeaponsSearchCache = nil
    mdcRegisteredVehiclesSearchCache = nil
    mdcRegisteredAddressesSearchCache = nil
    mdcRegisteredTrafficesSearchCache = nil
    mdcAdminDataSearchCache = nil
    mdcLogsSearchCache = nil
    punishmentMenusSearchCache = nil
    textbars = {}
    --setElementData(localPlayer, "bar >> Use", false)
    if isElement(gui) then
        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
        if isTimer(checkTimers) then killTimer(checkTimers) end
        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
        destroyElement(gui)
        
        guiState = false
        tick = 0
        now = nil
    end
    if now == "Desc >> Edit" or now == "FactionMessage >> Edit" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
        guiState = false
        tick = 0
        now = nil
    end
    if state then
        removeEventHandler("onClientRender", root, DrawnBars)
        state = false
    end
end

function RemoveBar(name)
    if textbars[name] then
        if now == name and isElement(gui) then
            removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
            if isTimer(checkTimers) then killTimer(checkTimers) end
            removeEventHandler("onClientGUIChanged", gui, onGuiChange)
            destroyElement(gui)
            
            guiState = false
            tick = 0
            now = nil
        end

        if now == "Desc >> Edit" or now == "FactionMessage >> Edit" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
            guiState = false
            tick = 0
            now = nil
        end

        textbars[name] = nil
        
        for k,v in pairs(textbars) do
            return
        end
        
        if state then
            removeEventHandler("onClientRender", root, DrawnBars)
            --setElementData(localPlayer, "bar >> Use", false)
            state = false
        end
    end
end

function UpdatePos(name, details)
--    outputChatBox(name)
    if textbars[name] then
        --outputChatBox("asd2")
        textbars[name][1] = details
        if not state then
            addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
            state = true
        end
    end
end

function UpdateAlpha(name, newColor)
    if textbars[name] then
        textbars[name][2][4] = newColor
        if not state then
            addEventHandler("onClientRender", root, DrawnBars, true, "low-5")
            state = true
        end
    end
end

function GetText(name)
    return textbars[name][2][2]
end

function SetText(name, val)
    if textbars[name] then
        textbars[name][2][2] = val
        return true
    end
    
    return false
end

function GetEdit(name)
    if textbars[name] then 
        return textbars[name]
    end

    return false
end

local subTexted = {
    ["CharRegisterHeight"] = " kg",
    ["CharRegisterWeight"] = " cm",
    ["CharRegisterAge"] = " év",
    ["FactionBank >> Edit"] = " $",
}

function DrawnBars()
    for k,v in pairs(textbars) do
        local details = v[1]
        local x,y,w,h = unpack(details)
        --dxDrawRectangle(x,y,w,h,tocolor(0,0,0,180))
        local w,h = x + w, y + h
        --outputChatBox("x:"..x)
        --outputChatBox("y:"..y)
        --outputChatBox("w:"..w)
        --outputChatBox("h:"..h)
        --outputChatBox("k:"..k)
        local options = v[2]
        local text = options[2]
        local color = options[4]
        local font = options[5]
        local fontsize = options[6]
        local alignX = options[7]
        local alignY = options[8]
        local secured = options[9]
        local clip = options[10]
        local wordBreak = options[11]
        --local rot1,rot2,rot3 = unpack(options[10])
        
        if secured then
            text = utfSub(oText, 1, #options[2])
        end
        
        if now == k then
            tick = tick + 5
            if tick >= 425 then
                tick = 0
            elseif tick >= 250 then
                text = text .. "|"
            end 
        end

        if subTexted[k] then
            text = text .. subTexted[k]
        end

        if k == "R" then
            text = "R: " .. text
        end
        
        if k == "G" then
            text = "G: " .. text
        end
        
        if k == "B" then
            text = "B: " .. text 
        end

        if k == "hex" then
            text = "#" .. text 
        end

        --dxDrawRectangle(x,y,w - x,h - y, tocolor(0,0,0,120))
        local font = exports['cr_fonts']:getFont(font[1], font[2])
        dxDrawText(text, x,y, w,h, color, fontsize, font, alignX, alignY, clip, wordBreak)
        --outputChatBox(text)
    end
end

local allSelected = false
local specBox = {
    ["ppBuyBox"] = true,
    ["shopBuyBox"] = true,
    ["invBox"] = true,
    ["PPCodeBox"] = true,
    ["GroupNameBox"] = true,
    ["RankNameBox"] = true,
    ["RankMoneyBox"] = true,
    ["FactionNameBox"] = true,
    ["PetNameBox"] = true,
    ["PetNumberBox"] = true,
    ["R"] = true,
    ["G"] = true, 
    ["B"] = true,
    ["hex"] = true,
}

addEventHandler("onClientClick", root,
    function(b, s)
        local screen = {guiGetScreenSize()}
        local defSize = {250, 28}
        local defMid = {screen[1]/2 - defSize[1]/2, screen[2]/2 - defSize[2]/2}
        if s == "down" then
            if now == "Desc >> Edit" or now == "FactionMessage >> Edit" or now == "Char-Reg.Name" or now == "Char-Reg.Weight" or now == "Char-Reg.Height" then
                return
            end
            for k,v in pairs(textbars) do
                local x,y,w,h = unpack(v[1])
                if exports["cr_core"]:isInSlot(x,y,w,h, specBox[k]) and not adminCheckHover then
                    now = k
                    textbars[now][2][2] = ""
                    
                    if now == "mdc.search" then
                        mdcWantedCarsSearchCache = nil
                        mdcWantedPersonsSearchCache = nil
                        mdcTicketsSearchCache = nil
                        mdcWantedWeaponsSearchCache = nil
                        mdcRegisteredWeaponsSearchCache = nil
                        mdcRegisteredVehiclesSearchCache = nil
                        mdcRegisteredAddressesSearchCache = nil
                        mdcRegisteredTrafficesSearchCache = nil
                        mdcAdminDataSearchCache = nil
                        mdcLogsSearchCache = nil
                        punishmentMenusSearchCache = nil
                    end

                    tick = 250
                    
                    if isElement(gui) then
                        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                        if isTimer(checkTimers) then killTimer(checkTimers) end
                        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                        destroyElement(gui)
                    end
                    gui = GuiEdit(-1, -1, 1, 1, textbars[now][2][2], true)
                    
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    --guiEditSetCaretIndex(gui, 1)
                    --guiSetProperty(gui, "AlwaysOnTop", "True")
                    if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                    guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)
                    
                    addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                    checkTimers = setTimer(onGuiBlur, 150, 0)
                    addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                    return
                end
            end
            --setElementData(localPlayer, "bar >> Use", false)
            guiState = false
            tick = 0
            now = nil
            
            if isElement(gui) then
                removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                if isTimer(checkTimers) then killTimer(checkTimers) end
                removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                destroyElement(gui)
            end
        end
    end
)

function onGuiBlur()
    if isElement(gui) then
        guiBringToFront(gui)
    end
end

function onGuiChange()
    playSound(":cr_account/files/key.mp3")
    
    --outputChatBox(now)
    --outputChatBox(guiGetText(gui):gsub(" ", ""))

    if textbars[now][2][3] then
        if tonumber(guiGetText(gui)) then
            if now == "R" then 
                pickerData["selectedColor"][1] = tonumber(guiGetText(gui))
				pickerData["color"][1] = tonumber(guiGetText(gui))
            elseif now == "G" then 
                pickerData["selectedColor"][2] = tonumber(guiGetText(gui))
				pickerData["color"][2] = tonumber(guiGetText(gui))
            elseif now == "B" then 
                pickerData["selectedColor"][3] = tonumber(guiGetText(gui))
				pickerData["color"][3] = tonumber(guiGetText(gui))
            end 
            SetText(now, guiGetText(gui))
        else
            guiSetText(gui, "")
            SetText(now, guiGetText(gui))
            guiEditSetCaretIndex(gui, #GetText(now))
        end
        
        return
    end
    
    if now == "hex" then 
        if #guiGetText(gui) == 6 then 
            local color = {getColorFromString("#" .. guiGetText(gui))}

            pickerData["selectedColor"] = {color[1], color[2], color[3]}
            pickerData["color"] = {color[1], color[2], color[3]}
            
            SetText("R", pickerData["color"][1])
            SetText("G", pickerData["color"][2])
            SetText("B", pickerData["color"][3])
        end
    end
    
    if now == "VehSlot >> buy" or now == "IntSlot >> buy" or now == "ppBuyBox" or now == "invBox" then
        if tonumber(guiGetText(gui)) then
            textbars[now][2][2] = guiGetText(gui)
        else
            guiSetText(gui, "")
            textbars[now][2][2] = guiGetText(gui)
            guiEditSetCaretIndex(gui, #textbars[now][2][2])
        end
        
        return
    end
    
    --[[
    if now ~= "Char-Reg.Name" and now ~= "Register.Email" then
        local st = ""
        for k in string.gmatch(guiGetText(gui), "%w+") do
            st = st .. k
        end
        guiSetText(gui, st)
        guiEditSetCaretIndex(gui, #guiGetText(gui))
        textbars[now][2][2] = guiGetText(gui)
    end    
    --guiSetText(gui, guiGetText(gui):gsub("%s", ""))
    --guiSetText(gui, guiGetText(gui):gsub("%z", ""))
    --guiSetText(gui, guiGetText(gui):gsub("%x", ""))
    --guiSetText(gui, guiGetText(gui):gsub("%w", ""))
    --guiSetText(gui, string.gsub(guiGetText(gui), "%p", ""))
    --guiSetText(gui, string.gsub(guiGetText(gui), "[^0-9]", ""))
    --outputChatBox("a"..utfSub(guiGetText(gui), #guiGetText(gui), #guiGetText(gui)) )
    if now == "Char-Reg.Name" then
        local st = ""
        for k in string.gmatch(guiGetText(gui), "[%a+%s]") do
            st = st .. k
        end
        guiSetText(gui, st)
        guiEditSetCaretIndex(gui, #guiGetText(gui))
        textbars[now][2][2] = guiGetText(gui)
        
        if utfSub(guiGetText(gui), #guiGetText(gui), #guiGetText(gui)) == "_" then
            guiSetText(gui, utfSub(guiGetText(gui), 1, #guiGetText(gui) - 1))
            guiEditSetCaretIndex(gui, #guiGetText(gui))
            exports['cr_infobox']:addBox("warning", "Használj space-t a(z) '_' - helyett")
        end
        
        if utfSub(guiGetText(gui), #guiGetText(gui), #guiGetText(gui)) == " " and utfSub(guiGetText(gui), #guiGetText(gui) - 1, #guiGetText(gui) - 1) == " " then
            --outputChatBox("asd2")
            --outputChatBox("asd2")
            guiSetText(gui, utfSub(guiGetText(gui), 1, #guiGetText(gui) - 1))
            guiEditSetCaretIndex(gui, #guiGetText(gui))
            --exports['cr_infobox']:addBox("warning", "Használj space-t a(z) '_' - helyett")
        end
        
        textbars[now][2][2] = guiGetText(gui)
    else
        textbars[now][2][2] = guiGetText(gui):gsub(" ", "")
    end]]
    textbars[now][2][2] = guiGetText(gui)
    guiSetText(gui, textbars[now][2][2])
    guiEditSetCaretIndex(gui, #textbars[now][2][2])

    if now == "mdc.search" then
        if textbars[now][2][2]:gsub(" ", "") ~= "" then
            if selectedMenu == 1 then 
                mdcWantedCarsSearchCache = {}
                
                --edit
                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcWantedCars do 
                    local v = mdcWantedCars[i]

                    if v then 
                        local text1 = v["vehicleType"]
                        local text2 = v["vehiclePlateText"]

                        if string.lower(tostring(text1)):gsub("-", " "):find(text:gsub("-", " ")) or string.lower(tostring(text2)):gsub("-", " "):find(text:gsub("-", " ")) then
                            table.insert(mdcWantedCarsSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 2 then 
                mdcWantedPersonsSearchCache = {}
                
                --edit
                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcWantedPersons do 
                    local v = mdcWantedPersons[i]

                    if v then 
                        local text1 = v["name"]
                        local text2 = v["race"]

                        if string.lower(tostring(text1)):find(text) or string.lower(tostring(text2)):find(text) then
                            table.insert(mdcWantedPersonsSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 3 then 
                mdcTicketsSearchCache = {}
                
                --edit
                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcTickets do 
                    local v = mdcTickets[i]

                    if v then 
                        local text1 = v["name"]

                        if string.lower(tostring(text1)):find(text) then
                            table.insert(mdcTicketsSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 4 then 
                mdcWantedWeaponsSearchCache = {}
                
                --edit
                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcWantedWeapons do 
                    local v = mdcWantedWeapons[i]

                    if v then 
                        local text1 = v["weaponType"]
                        local text2 = v["weaponSerial"]

                        if string.lower(tostring(text1)):find(text) or string.lower(tostring(text2)):find(text) then
                            table.insert(mdcWantedWeaponsSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 5 then 
                mdcRegisteredWeaponsSearchCache = {}

                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcRegisteredWeapons do 
                    local v = mdcRegisteredWeapons[i]

                    if v then 
                        local ownerName = v.ownerName
                        local weaponSerial = v.weaponSerial

                        if string.lower(tostring(ownerName)):find(text) or string.lower(tostring(weaponSerial)):find(text) then 
                            table.insert(mdcRegisteredWeaponsSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 6 then 
                mdcRegisteredVehiclesSearchCache = {}

                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcRegisteredVehicles do 
                    local v = mdcRegisteredVehicles[i]

                    if v then 
                        local ownerName = v.ownerName
                        local vehiclePlateText = v.vehiclePlateText
                        local vehicleChassis = v.vehicleChassis

                        if string.lower(tostring(ownerName)):find(text) or string.lower(tostring(vehiclePlateText)):find(text) or string.lower(tostring(vehicleChassis)):find(text) then 
                            table.insert(mdcRegisteredVehiclesSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 7 then 
                mdcRegisteredAddressesSearchCache = {}

                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcRegisteredAddresses do 
                    local v = mdcRegisteredAddresses[i]

                    if v then 
                        local ownerName = v.ownerName
                        local actualAddress = v.actualAddress

                        if string.lower(tostring(ownerName)):find(text) or string.lower(tostring(actualAddress)):find(text) then 
                            table.insert(mdcRegisteredAddressesSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 8 then 
                mdcRegisteredTrafficesSearchCache = {}

                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcRegisteredTraffices do 
                    local v = mdcRegisteredTraffices[i]

                    if v then 
                        local ownerName = v.ownerName
                        local vehiclePlateText = v.vehiclePlateText
                        local vehicleChassis = v.vehicleChassis

                        if string.lower(tostring(ownerName)):find(text) or string.lower(tostring(vehiclePlateText)):find(text) or string.lower(tostring(vehicleChassis)):find(text) then 
                            table.insert(mdcRegisteredTrafficesSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 9 then 
                mdcAdminDataSearchCache = {}
                
                --edit
                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcAdminData do 
                    local v = mdcAdminData[i]

                    if v then 
                        local username = v.username

                        if string.lower(tostring(username)):find(text) then
                            table.insert(mdcAdminDataSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 10 then 
                mdcLogsSearchCache = {}
                
                --edit
                local text = string.lower(tostring(textbars[now][2][2]))

                for i = 1, #mdcLogs do 
                    local v = mdcLogs[i]

                    if v then 
                        local text1 = v["text"]

                        if string.lower(tostring(text1:gsub("#%x%x%x%x%x%x", ""))):find(text) then
                            table.insert(mdcLogsSearchCache, v)
                        end
                    end
                end
            elseif selectedMenu == 11 and selectedSubMenu > 0 then 
                punishmentMenusSearchCache = {}

                --edit
                local text = string.lower(tostring(textbars[now][2][2]))
                local array = punishmentMenus[selectedSubMenu].subMenu

                for i = 1, #array do 
                    local v = array[i]

                    if v then 
                        local penaltyName = v.penaltyName
                        local other = v.other

                        if string.lower(tostring(penaltyName)):find(text) or string.lower(tostring(other)):find(text) then 
                            table.insert(punishmentMenusSearchCache, v)
                        end
                    end
                end
            end
        else
            mdcWantedCarsSearchCache = nil 
            mdcWantedPersonsSearchCache = nil 
            mdcTicketsSearchCache = nil 
            mdcWantedWeaponsSearchCache = nil 
            mdcRegisteredWeaponsSearchCache = nil
            mdcRegisteredVehiclesSearchCache = nil
            mdcRegisteredAddressesSearchCache = nil
            mdcRegisteredTrafficesSearchCache = nil
            mdcAdminDataSearchCache = nil
            mdcLogsSearchCache = nil
            punishmentMenusSearchCache = nil
        end
    end
    
    --[[
    local b = utfSub(textbars[now][2][2], #textbars[now][2][2], #textbars[now][2][2])
    local a2 = utfSub(textbars[now][2][2], 1, #textbars[now][2][2] - 1)
    if changeKey[b] then 
        b = changeKey[b] 
    end

    if disabledKey[b] then
        local b2 = " " .. b .. " "
        if subWord[b] or b2 == " \ " then
            --exports["pb_infobox"]:addBox("warning", "A nevedben nem szerepelhet ékezet!")
            textbars[now][2][2] = a2
            return
        elseif tonumber(b) then
            textbars[now][2][2] = a2
            return
        end
    end]]
end

addEventHandler("onClientKey", root,
    function(b, s)
        if isElement(gui) and s and now and tostring(now) ~= "" and tostring(now) ~= " " then
            if b == "enter" then
                if now == "R" or now == "G" or now == "B" or now == "hex" then 
                    if pickerData["onEnter"] then 
                        pickerData["onEnter"]()
                    end 
                end 
            elseif b == "tab" then
                local idTable = {}
                --idTable[k] = i
                for k,v in pairs(textbars) do
                    local i = textbars[k][3]
                    idTable[k] = i
                    idTable[i] = k
                end
                local newNum = idTable[now] + 1
                if idTable[newNum] then
                    now = idTable[newNum]
                    
                    if isElement(gui) then
                        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                        if isTimer(checkTimers) then killTimer(checkTimers) end
                        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                        destroyElement(gui)
                    end
                    gui = GuiEdit(-1, -1, 1, 1, textbars[now][2][2], true)
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #textbars[now][2][2])
                    --guiSetProperty(gui, "AlwaysOnTop", "True")
                    if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                    guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)
                    
                    addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                    checkTimers = setTimer(onGuiBlur, 150, 0)
                    addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                else    
                    now = idTable[1]
                    
                    if isElement(gui) then
                        removeEventHandler("onClientGUIBlur", gui, onGuiBlur)
                        if isTimer(checkTimers) then killTimer(checkTimers) end
                        removeEventHandler("onClientGUIChanged", gui, onGuiChange)
                        destroyElement(gui)
                    end
                    gui = GuiEdit(-1, -1, 1, 1, textbars[now][2][2], true)
                    --setTimer(function() gui:setProperty("AlwaysOnTop", "True") end, 100, 1)
                    gui.maxLength = textbars[now][2][1]
                    guiEditSetCaretIndex(gui, #textbars[now][2][2])
                    --guiSetProperty(gui, "AlwaysOnTop", "True")
                    if isTimer(guiBringToFrontTimer) then killTimer(guiBringToFrontTimer) end
                    guiBringToFrontTimer = setTimer(guiBringToFront, 50, 1, gui)
                    
                    addEventHandler("onClientGUIBlur", gui, onGuiBlur, true)
                    checkTimers = setTimer(onGuiBlur, 150, 0)
                    addEventHandler("onClientGUIChanged", gui, onGuiChange, true)
                end
                return
            end
        end
    end
)