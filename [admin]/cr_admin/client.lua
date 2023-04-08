sx, sy = guiGetScreenSize();

local markedLocations = {}

local glue_vehs = {
	[508] = true
}

local white = "#ffffff"
local lastAsDutyTick = 0

function aTitle(player)
    local title = getAdminTitle(localPlayer)

    if title == "Ideiglenes Adminsegéd" then
        title = "IDG.Adminsegéd"
    elseif title == "Admin 1" then
        title = "Admin[1]"
    elseif title == "Admin 2" then
        title = "Admin[2]"
    elseif title == "Admin 3" then
        title = "Admin[3]"
    elseif title == "Admin 4" then
        title = "Admin[4]"
    elseif title == "Admin 5" then
        title = "Admin[5]"
    end

    return title
end

-- /togalog
function jsonGET(file, defValue)
    local defValue = defValue or {["disabled"] = false}
    local fileHandle
    local jsonDATA = {}
    if not fileExists(file) then
        fileHandle = fileCreate(file)
        fileWrite(fileHandle, toJSON(defValue))
        fileClose(fileHandle)
        fileHandle = fileOpen(file)
    else
        fileHandle = fileOpen(file)
    end
    if fileHandle then
        local buffer
        local allBuffer = ""
        while not fileIsEOF(fileHandle) do
            buffer = fileRead(fileHandle, 500)
            allBuffer = allBuffer..buffer
        end
        jsonDATA = fromJSON(allBuffer)
        fileClose(fileHandle)
    end
    return jsonDATA
end
 
function jsonSAVE(file, data)
    if fileExists(file) then
        fileDelete(file)
    end
    local fileHandle = fileCreate(file)
    fileWrite(fileHandle, toJSON(data))
    fileFlush(fileHandle)
    fileClose(fileHandle)
    return true
end

function noOnline()
    local syntax = exports['cr_core']:getServerSyntax(false, "error")
    outputChatBox(syntax..white.."Nincs ilyen játékos!",0,0,0,true)
end

local value = {}
value["disabled"] = false

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        value = jsonGET("files/@alog.json")
        markedLocations = jsonGET("files/@markedLocations.json", {}) or {}

        setElementData(localPlayer, "admin >> alogDisabled", value["disabled"])
    end
)

addEventHandler("onClientResourceStop", resourceRoot, 
    function()
        jsonSAVE("files/@alog.json", value)
        jsonSAVE("files/@markedLocations.json", markedLocations)
    end
)

addEventHandler("onClientVehicleStartEnter", getRootElement(),
    function(thePlayer, seat)
        if thePlayer == getLocalPlayer() then
            if getElementData(localPlayer, "freeze") then
                cancelEvent()
            end
        end
    end
)

function markLocationCommand(cmd, ...)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [név]", 255, 0, 0, true)
            return
        end

        local name = table.concat({...}, " ")

        if markedLocations[name] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Már van lementett pozíciód ezzel a névvel.", 255, 0, 0, true)
            return
        end

        markedLocations[name] = {
            position = {getElementPosition(localPlayer)},
            rotation = {getElementRotation(localPlayer)},

            createdBy = getRealTime().timestamp,
            interior = localPlayer.interior,

            dimension = localPlayer.dimension,
            customInterior = localPlayer:getData("customInterior")
        }

        local syntax = exports.cr_core:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Sikeresen lementetted a pozíciót!", 255, 0, 0, true)
    end
end
addCommandHandler("mark", markLocationCommand, false, false)

function deleteMarkCommand(cmd, ...)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [név]", 255, 0, 0, true)
            return
        end

        local name = table.concat({...}, " ")

        if not markedLocations[name] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nincs lementett pozíciód ezzel a névvel.", 255, 0, 0, true)
            return
        end

        markedLocations[name] = nil

        local syntax = exports.cr_core:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Sikeresen kitörölted a lementett pozíciót!", 255, 0, 0, true)
    end
end
addCommandHandler("deletemark", deleteMarkCommand, false, false)
addCommandHandler("delmark", deleteMarkCommand, false, false)

function gotoMarkCommand(cmd, ...)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [név]", 255, 0, 0, true)
            return
        end

        local name = table.concat({...}, " ")

        if not markedLocations[name] then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Nincs lementett pozíciód ezzel a névvel.", 255, 0, 0, true)
            return
        end

        local locationData = markedLocations[name]
        local x, y, z = unpack(locationData.position)

        local interior = locationData.interior
        local dimension = locationData.dimension
        local customInterior = locationData.customInterior
        
        local vehicle = localPlayer.vehicle
        local elementToTeleport = vehicle and vehicle or localPlayer

        triggerServerEvent("setElementPosition", localPlayer, elementToTeleport, x, y, z, interior, dimension, customInterior)

        local syntax = exports.cr_core:getServerSyntax(false, "success")

        outputChatBox(syntax .. "Sikeresen elteleportáltál a kiválasztott pozícióra!", 255, 0, 0, true)

        local adminSyntax = getAdminSyntax()
        local localName = getAdminName(localPlayer, true)
        local hexColor = exports.cr_core:getServerColor("yellow", true)

        exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " elteleportált egy lementett pozíciójára.", 3)
    end
end
addCommandHandler("gotomark", gotoMarkCommand, false, false)

function getMarkedLocationsCommand(cmd)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        local syntax = exports.cr_core:getServerSyntax(false, "info")
        local hexColor = exports.cr_core:getServerColor("yellow", true)
        local count = 0

        for k, v in pairs(markedLocations) do 
            if v.createdBy then 
                local realTime = getRealTime(v.createdBy)
                local createdBy = ("%i.%.2i.%.2i - %.2i:%.2i:%.2i"):format(realTime.year + 1900, realTime.month + 1, realTime.monthday, realTime.hour, realTime.minute, realTime.second)

                outputChatBox(syntax .. "Név: " .. hexColor .. k .. white .. ", hozzáadva: " .. hexColor .. createdBy, 255, 0, 0, true)
                count = count + 1
            end
        end

        if count == 0 then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Nincs lementve egy pozíció sem.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("getmarkedlocations", getMarkedLocationsCommand, false, false)

--[[
function pressedKey(button, press)
    if not (button == "b") then
    	if not (button == "t") then
	        if getElementData(localPlayer, "freeze") then
	            --local syntax = exports['cr_core']:getServerSyntax(false, "error")
	            --outputChatBox(syntax.."#ffffffLefagyasztva semmit nem csinálhatsz!",255,255,255,true)
	            cancelEvent()
	        end
	    end
    end
end
addEventHandler("onClientKey", root, pressedKey)]]


function togAlog(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "togalog") then
        value["disabled"] = not value["disabled"]
        setElementData(localPlayer, "admin >> alogDisabled", value["disabled"])
        if not value["disabled"] then
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax.. "Sikeresen bekapcsoltad az admin logokat!", 255,255,255,true)
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax.. "Sikeresen kikapcsoltad az admin logokat!", 255,255,255,true)
        end
    end
end
addCommandHandler("togalog", togAlog)

-- /setadminlevel, setalevel

function setAdminLevel(cmd, target, level)
    if exports['cr_permission']:hasPermission(localPlayer, "setadminlevel") then
        if not level or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [szint]", 255,255,255,true)
            return
        elseif tonumber(level) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek egy számnak kell lennie!", 255,255,255,true)
            return    
        elseif tonumber(level) > 10 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek kisebbnek kell lennie 10-nél!", 255,255,255,true)
            return
        elseif tonumber(level) < 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek nagyobbnak kell lennie 0-nál!", 255,255,255,true)
            return    
        end
        
        level = tonumber(math.floor(level))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local newLevel = level + 2
                if newLevel == 2 then
                    newLevel = 0
                end
                local oValue = getAdminLevel(target)
                if target == localPlayer then
                    if newLevel > oValue and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Magadnak nem állíthasz nagyobb adminszintet!", 255,255,255,true)
                        return
                    end
                else
                    local adminlevel = getAdminLevel(localPlayer) - 1
                    local adminlevel2 = getAdminLevel(target)
                    local adminlevel3 = getAdminLevel(localPlayer)
                    if newLevel > adminlevel and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Másnak nem állíthasz nagyobb adminszintet a FőAdminnál!", 255,255,255,true)
                        return
                    elseif adminlevel2 >= adminlevel3 and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Nagyobb admin szintjét nem változtathatod!", 255,255,255,true)
                        return    
                    end
                end
                if newLevel == 0 then
                    setElementData(target, "admin >> duty", false)
                end
                setElementData(target, "admin >> level", newLevel)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target, true)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                local oValue = oValue - 2
                if oValue < 0 then oValue = 0 end
                local newLevel = newLevel - 2
                if newLevel < 0 then newLevel = 0 end
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info") ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." adminisztrátori szintjét "..hexColor..math.max(0, oValue).."#ffffff-ról/ről "..hexColor..math.min(10, newLevel).."#ffffff-ra/re.", 0)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setadminlevel", setAdminLevel)
addCommandHandler("setalevel", setAdminLevel)

-- /setguardlevel

function setGuardLevel(cmd, target, level)
    if exports['cr_permission']:hasPermission(localPlayer, "setguardlevel") then
        if not level or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [szint (1, 2)]", 255,255,255,true)
            return
        elseif tonumber(level) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek egy számnak kell lennie!", 255,255,255,true)
            return    
        elseif tonumber(level) > 2 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek kisebbnek kell lennie 2-nél!", 255,255,255,true)
            return
        elseif tonumber(level) < 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek nagyobbnak kell lennie 0-nál!", 255,255,255,true)
            return    
        end
        
        level = tonumber(math.floor(level))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local newLevel = level * -1
                local oValue = getAdminLevel(target)
                if target == localPlayer then
                    if newLevel > oValue and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Magadnak nem állíthasz nagyobb adminszintet!", 255,255,255,true)
                        return
                    end
                else
                    local adminlevel = getAdminLevel(localPlayer) - 1
                    local adminlevel2 = getAdminLevel(target)
                    local adminlevel3 = getAdminLevel(localPlayer)
                    if newLevel > adminlevel and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Másnak nem állíthasz nagyobb adminszintet a FőAdminnál!", 255,255,255,true)
                        return
                    elseif adminlevel2 >= adminlevel3 and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Nagyobb admin szintjét nem változtathatod!", 255,255,255,true)
                        return    
                    end
                end
                if newLevel == 0 then
                    setElementData(target, "admin >> duty", false)
                end
                setElementData(target, "admin >> level", newLevel)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target, true)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                local oValue = oValue - 2
                if oValue < 0 then oValue = 0 end
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info") ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." guard szintjét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..(newLevel * -1).."#ffffff-ra/re.", 3)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setguardlevel", setGuardLevel)
addCommandHandler("setglevel", setGuardLevel)

-- /auncuff
function adminUnCuff(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "auncuff") then 
        if not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target]", 255,255,255,true)
            return
        end

        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if target then
            if getElementData(target, "loggedIn") then
                if target:getData("char >> cuffed") then 
                    target:setData("char >> cuffed", false)
                    target:setData("char >> cuffedID", false)

                    if target:getData("char >> follow") then 
                        target:setData("char >> follow", nil)
                    end

                    local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                    local blue = exports['cr_core']:getServerColor('yellow', true)
                    local white = "#ffffff"
                    local aName = getAdminName(target)
                    local aName2 = getAdminName(localPlayer, true)
                    outputChatBox(syntax .. "Levetted " .. blue .. aName .. white .. "-ról a bilincset!",0,0,0,true)
                    local message = syntax .. blue .. aName2 .. white .. " levette rólad a bilincset!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                    exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax() .. blue .. aName2 .. white .. " levette ".. blue .. aName .. white .. "-ról a bilincset!", 3)
                else 
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs megbilincselve!", 255,255,255,true)
                end 
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end 
end 
addCommandHandler("auncuff", adminUnCuff)
addCommandHandler("uncuff", adminUnCuff)

-- /setanick, setadminname

function setAdminNick(cmd, target, nick)
    if exports['cr_permission']:hasPermission(localPlayer, "setadminnick") then
        if not nick or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [Nick]", 255,255,255,true)
            return
        end
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local adminlevel = getAdminLevel(localPlayer)
                local adminlevel2 = getAdminLevel(target)
                if adminlevel2 > adminlevel then
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "Nagyobb adminnak nem állíthatsz adminnevet!", 255,255,255,true)
                    return 
                end
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target, true)
                setElementData(target, "admin >> name", nick)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info") ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." adminisztrátori nevét "..hexColor..nick.."#ffffff-ra/re.", 0)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setanick", setAdminNick)
addCommandHandler("setadminnick", setAdminNick)

-- /sethelperlevel, sethlevel, setaslevel

function setHelperLevel(cmd, target, level)
    if exports['cr_permission']:hasPermission(localPlayer, "sethelperlevel") then
        if not level or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [szint ([1] = Ideiglenes, [2] = Örök)]", 255,255,255,true)
            return
        elseif tonumber(level) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek egy számnak kell lennie!", 255,255,255,true)
            return    
        elseif tonumber(level) == 2 then
            local adminlevel = getAdminLevel(localPlayer)
            if adminlevel < 8 and not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Te nem adhatsz örök adminsegédet!", 255,255,255,true)
                return
            end
        elseif tonumber(level) > 2 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek kisebbnek kell lennie 2-nél!", 255,255,255,true)
            return
        elseif tonumber(level) < 0 then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A szintnek nagyobbnak kell lennie 0-nál!", 255,255,255,true)
            return    
        end
        
        level = tonumber(math.floor(level))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local newLevel = level
                local oValue = getAdminLevel(target)
                if target == localPlayer then
                    if oValue > 2 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Adminnak nem állíthasz AdminSegéd szintet!", 255,255,255,true)
                        return
                    end
                else
                    if oValue > 2 then
                        local syntax = exports['cr_core']:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "Adminnak nem állíthasz AdminSegéd szintet!", 255,255,255,true)
                        return
                    end
                end
                setElementData(target, "admin >> level", newLevel)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, exports['cr_core']:getServerSyntax(false, "info")..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." adminsegéd szintjét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..newLevel.."#ffffff-ra/re.", 0)
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("sethelperlevel", setHelperLevel)
addCommandHandler("sethlevel", setHelperLevel)
addCommandHandler("setaslevel", setHelperLevel)

-- /adminduty, aduty
function adminDuty(cmd, target)
    if isTimer(adutyTimer) then return end
    if exports['cr_permission']:hasPermission(localPlayer, "aduty") then
        local hasPerm = true
        local t = exports['cr_core']:findPlayer(localPlayer, target)
        if t and isElement(t) and t == localPlayer then
            hasPerm = false
        end
        if target and hasPerm then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            
            if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
            
            if target and exports['cr_permission']:hasPermission(localPlayer, "forceaduty") then
                if getElementData(target, "loggedIn") then
                    local oValue = getElementData(target, "admin >> duty")
                    local aName1 = getAdminName(localPlayer, true)
                    local aName2 = getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    
                    if target:getData("admin >> level") >= localPlayer:getData("admin >> level") then
                        outputChatBox(exports['cr_core']:getServerSyntax(false, "error").."Nálad nagyobb szintű admint nem léptethetsz szolgálatba!",255,255,255,true)
                        local message = exports['cr_core']:getServerSyntax(false, "warning")..hexColor..aName1..white.." beakart léptetni adminszolgálatba!"
                        triggerServerEvent("outputChatBox", localPlayer, target, message)
                        return
                    end
                    
                    setElementData(target, "admin >> duty", not oValue)
                    
                    local newValue = not oValue
                    if newValue then
                        if not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                            adutyTimer = setTimer(function() end, 60 * 1000, 1)
                        end
                        exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." beléptette "..hexColor..aName2..white.."-t az adminszolgálatba", 8)
                    else
                        exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." kiléptette "..hexColor..aName2..white.."-t az adminszolgálatból", 8)
                    end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        else
            target = localPlayer
            local oValue = getElementData(target, "admin >> duty")
            setElementData(target, "admin >> duty", not oValue)
            local newValue = not oValue
            if newValue then
                if not exports['cr_core']:getPlayerDeveloper(localPlayer) then
                    adutyTimer = setTimer(function() end, 60 * 1000, 1)
                end
            end
            local aName1 = getAdminName(localPlayer, true)
            local aName2 = getAdminName(target, true)
            local hexColor = exports['cr_core']:getServerColor('yellow', true)
        end
    end
end
addCommandHandler("aduty", adminDuty)
addCommandHandler("adminduty", adminDuty)

function asDuty(cmd, target)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if lastAsDutyTick + 60000 > getTickCount() then 
            return
        end

        if target then 
            if exports.cr_permission:hasPermission(localPlayer, "forceasduty") then 
                local target = exports.cr_core:findPlayer(localPlayer, target)

                if target then 
                    if target:getData("loggedIn") then 
                        local adminLevel = getAdminLevel(target)
                        local adminDutyState = getAdminDuty(target)
                        local newAdminDutyState = not adminDutyState

                        if adminLevel ~= 1 and adminLevel ~= 2 then 
                            local syntax = exports.cr_core:getServerSyntax(false, "error")

                            outputChatBox(syntax .. "Csak adminsegédeknek állíthatod a dutyját!", 255, 0, 0, true)
                            return
                        end

                        target:setData("admin >> duty", newAdminDutyState)

                        local adminSyntax = getAdminSyntax()
                        local localName = getAdminName(localPlayer, true)
                        local targetName = getAdminName(target)
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        if newAdminDutyState then 
                            if not exports.cr_core:getPlayerDeveloper(localPlayer) then 
                                lastAsDutyTick = getTickCount()
                            end

                            exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " adminsegéd szolgálatba léptette " .. hexColor .. targetName .. white .. " játékost.", 8)
                        else
                            exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " kiléptette " .. hexColor .. targetName .. white .. " játékost az adminsegéd szolgálatból.", 8)
                        end
                    else
                        local syntax = exports.cr_core:getServerSyntax(false, "error")
                        outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255, 255, 255, true)
                    end
                else
                    noOnline()
                end
            end
        else
            if getAdminLevel(localPlayer) <= 0 then 
                local adminDutyState = getAdminDuty(localPlayer)
                local newAdminDutyState = not adminDutyState

                localPlayer:setData("admin >> duty", newAdminDutyState)

                if not exports.cr_core:getPlayerDeveloper(localPlayer) then 
                    lastAsDutyTick = getTickCount()
                end
            end
        end
    end
end
addCommandHandler("asduty", asDuty, false, false)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "admin >> duty") then
            adminTimer = setTimer(
                function()
                    if not getElementData(localPlayer, "char->afk") then
                        local oAdminTime = getElementData(localPlayer, "admin >> time")
                        setElementData(localPlayer, "admin >> time", oAdminTime + 1)
                    end
                end, 60 * 1000, 0
            )
        end
    end
)

addEventHandler("onClientElementDataChange", root,
    function(dName)
        if source == localPlayer then
            if dName == "admin >> duty" then
                local value = getElementData(source, dName)
                if value then
                    adminTimer = setTimer(
                        function()
                            if not getElementData(localPlayer, "char->afk") then
                                local oAdminTime = getElementData(localPlayer, "admin >> time") or 0
                                setElementData(localPlayer, "admin >> time", oAdminTime + 1)
                            end
                        end, 60 * 1000, 0
                    )
                else
                    if isTimer(adminTimer) then
                        killTimer(adminTimer)
                    end
                end
            end
        end
        if dName == "admin >> duty" then
            local value = getElementData(source, dName)
            local adminlevel = getElementData(source, "admin >> level") or 0
            if adminlevel > 2 and adminlevel < 13 then
                if value then
                    --Belépés
                    local id = getElementData(source, "char >> id") or 0
                    exports['cr_infobox']:addBox("aduty", getAdminColor(source, nil, true) .. '[' .. getAdminTitle(source) .. '] #f2f2f2' .. getAdminName(source, true) .. " adminszolgálatba lépett! /pm "..id)
                else
                    --Kilépés
                    exports['cr_infobox']:addBox("aduty", getAdminColor(source, nil, true) .. '[' .. getAdminTitle(source) .. '] #f2f2f2' .. getAdminName(source, true) .. " kilépett az adminszolgálatból!")
                end
            end
        end
    end
)

-- /fly

addCommandHandler("fly", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            toggleFly()
        end
    end
)

-- /getpos

addCommandHandler("getpos", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            local x,y,z = getElementPosition(localPlayer)
            local dim, int = getElementDimension(localPlayer), getElementInterior(localPlayer)
            local a, a, rot = getElementRotation(localPlayer)
            setClipboard(x .. ", " .. y .. ", " .. z)
            local syntax = exports['cr_core']:getServerSyntax("Position", "warning")
            local green = exports['cr_core']:getServerColor("green", true)
            --outputChatBox(syntax .. ": ",255,255,255,true)
            outputChatBox(syntax .. "XYZ" .. ": ".. green .. x .. white ..", " .. green .. y .. white .. ", " .. green .. z,255,255,255,true)
            outputChatBox(syntax .. "Interior" .. ": ".. green .. int,255,255,255,true)
            outputChatBox(syntax .. "Dimension" .. ": ".. green .. dim,255,255,255,true)
            outputChatBox(syntax .. "Rotation" .. ": ".. green .. rot,255,255,255,true)
        end
    end
)

local flyingState = false
local keys = {}
keys.up = "up"
keys.down = "up"
keys.f = "up"
keys.b = "up"
keys.l = "up"
keys.r = "up"
keys.a = "up"
keys.s = "up"
keys.m = "up"

function toggleFly()
	flyingState = not flyingState	
	if flyingState then
		addEventHandler("onClientRender",getRootElement(),flyingRender, true, "low-5")
		bindKey("lshift","both",keyH)
		bindKey("rshift","both",keyH)
		bindKey("lctrl","both",keyH)
		bindKey("rctrl","both",keyH)
		
        bindKey("forwards","both",keyH)
        bindKey("accelerate","both",keyH)
        bindKey("brake_reverse","both",keyH)
        bindKey("backwards","both",keyH)
        bindKey("vehicle_left","both",keyH)
        bindKey("vehicle_right","both",keyH)
		bindKey("left","both",keyH)
		bindKey("right","both",keyH)
		
		bindKey("lalt","both",keyH)
		bindKey("space","both",keyH)
		bindKey("ralt","both",keyH)
		bindKey("mouse1","both",keyH)
        if localPlayer.vehicle then
            localPlayer.vehicle.frozen = true
		    localPlayer.vehicle.collisions = false 
        else 
            localPlayer.collisions = false 
        end 
        setElementData(localPlayer, "keysDenied", true)
	else
		removeEventHandler("onClientRender",getRootElement(),flyingRender)
		unbindKey("mouse1","both",keyH)
		unbindKey("lshift","both",keyH)
		unbindKey("rshift","both",keyH)
		unbindKey("lctrl","both",keyH)
		unbindKey("rctrl","both",keyH)
		
        unbindKey("forwards","both",keyH)
        unbindKey("accelerate","both",keyH)
        unbindKey("brake_reverse","both",keyH)
        unbindKey("backwards","both",keyH)
        unbindKey("vehicle_left","both",keyH)
        unbindKey("vehicle_right","both",keyH)
		unbindKey("left","both",keyH)
		unbindKey("right","both",keyH)
		
		unbindKey("space","both",keyH)
		
		keys.up = "up"
		keys.down = "up"
		keys.f = "up"
		keys.b = "up"
		keys.l = "up"
		keys.r = "up"
		keys.a = "up"
		keys.s = "up"
        if localPlayer.vehicle then
            localPlayer.vehicle.frozen = false  
            localPlayer.vehicle.collisions = true  
        else 
            localPlayer.collisions = true
        end
        setElementData(localPlayer, "keysDenied", false)
	end
end

function flyingRender()
	local x,y,z = getElementPosition(localPlayer.vehicle or getLocalPlayer())
	local speed = 10
    --outputChatBox(speed)
	if keys.a=="down" then
		speed = 3
	elseif keys.s=="down" then
		speed = 50
	elseif keys.m=="down" then
		speed = 300
	end
	
	if keys.f=="down" then
		local a = rotFromCam(0)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	elseif keys.b=="down" then
		local a = rotFromCam(180)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	end
	
	if keys.l=="down" then
		local a = rotFromCam(-90)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	elseif keys.r=="down" then
		local a = rotFromCam(90)
		setElementRotation(localPlayer.vehicle or getLocalPlayer(),0,0,a)
		local ox,oy = dirMove(a)
		x = x + ox * 0.1 * speed
		y = y + oy * 0.1 * speed
	end
	
	if keys.up=="down" then
		z = z + 0.1*speed
	elseif keys.down=="down" then
		z = z - 0.1*speed
	end
	
    --outputChatBox(inspect(localPlayer.vehicle or getLocalPlayer()))
    --outputChatBox(x..y..z)
	setElementPosition(localPlayer.vehicle or getLocalPlayer(),x,y,z)
end

function keyH(key,state)
	if key=="lshift" or key=="rshift" then
		keys.s = state
	end	
	if key=="lctrl" or key=="rctrl" then
		keys.down = state
    end	
    if key == "forwards" or key == "accelerate" then
		keys.f = state
	end	
	if key == "backwards" or key == "brake_reverse" then
		keys.b = state
	end	
	if key=="left" or key == "vehicle_left" then
		keys.l = state
	end	
	if key=="right" or key == "vehicle_right" then
		keys.r = state
	end	
	if key=="lalt" or key=="ralt" then
		keys.a = state
	end	
	if key=="space" then
		keys.up = state
	end	
	if key=="mouse1" then
		keys.m = state
	end	
end

function rotFromCam(rzOffset)
	local cx,cy,_,fx,fy = getCameraMatrix(getLocalPlayer())
	local deltaY,deltaX = fy-cy,fx-cx
	local rotZ = math.deg(math.atan((deltaY)/(deltaX)))
	if deltaY >= 0 and deltaX <= 0 then
		rotZ = rotZ+180
	elseif deltaY <= 0 and deltaX <= 0 then
		rotZ = rotZ+180
	end
	return -rotZ+90 + rzOffset
end

function dirMove(a)
	local x = math.sin(math.rad(a))
	local y = math.cos(math.rad(a))
	return x,y
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "keysDenied" and flyingState then
            local value = getElementData(source, dName)
            if not value then
                setElementData(source, dName, true)
            end
        elseif dName == "admin >> duty" and flyingState then
            local value = getElementData(source, dName)
            if not value then
                toggleFly()
            end
        end
    end
)

-- // Hallhatatlanság (God)
addEventHandler("onClientPlayerDamage", root,
    function()
        local adminduty = getAdminDuty(source)
        local adminlevel = getElementData(source, "admin >> level")
        if adminduty and adminlevel >= 3 then
            cancelEvent()
        end
    end
)

addEventHandler("onClientPlayerStealthKill", localPlayer,
    function(target)
        local adminduty = getAdminDuty(target)
        local adminlevel = getAdminLevel(target)
        if adminduty and adminlevel >= 3 then
            cancelEvent()
        end
    end
)

function playSoundClient(player, music)
    if player == localPlayer then
        playSound(music)
    end    
end
addEvent("playSoundClient", true)
addEventHandler("playSoundClient", root, playSoundClient)


--KURVA ANYÁD TE DEBIL MOCSKOS IDIÓTA AKI EZT íRTA!
setElementData(localPlayer, "admin >> togvá", true)
function valaszAdmin(message)
    local pair = {}
    for k,v in pairs(getElementsByType("player")) do
        local adminlevel = getElementData(v, "admin >> level") or 0
        if adminlevel >= 3 then
            if getElementData(v, "admin >> togvá") then
                pair[v] = true
            end
        end
    end
    
    for k,v in pairs(pair) do
        triggerServerEvent("outputChatBox", localPlayer, k, message)
    end
end

--------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------[[ Parancsok ]]--------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

local lastPMTick = -15000
function pm_sc(cmd, target, ...)
    if not (target) or not (...) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Admin ID/Név] [Üzenet]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "pm") then
            if getElementData(target, "loggedIn") then
                if localPlayer == target then 
                    exports['cr_infobox']:addBox("error", "Magadnak nem írhatsz pm-et!")
                    return 
                end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(target)
                local jatekosName = getAdminName(localPlayer) --getElementData(localPlayer,"char >> name"):gsub("_", " ")
                local adminID = getElementData(target, "char >> id")
                local localID = getElementData(localPlayer, "char >> id")
                local adminDuty = exports['cr_admin']:getAdminDuty(target)
                local forcePM = exports['cr_permission']:hasPermission(localPlayer, "forcepm")
                local text = table.concat({...}, " ")

                if not forcePM then 
                    if lastPMTick + 15000 > getTickCount() then
                        exports['cr_infobox']:addBox('error', '15 másodpercenként használhatod ezt a parancsot!')
                        return
                    end
                    
                    lastPMTick = getTickCount()
                end 

                if not adminDuty then
                	if not forcePM then
	                    exports['cr_infobox']:addBox("error", "Csak szolgálatban lévő adminnak írhatsz!")
	                    return
	                end
                end

                outputChatBox(color.."[PM - Tőled]#ffffff "..adminName..color.." ["..adminID.."]:#ffffff "..text,0,0,0,true)
                playSound("files/enter.mp3")
                local message = color.."[PM - Neked]#ffffff "..jatekosName..color.." ["..localID.."]:#ffffff "..text
                triggerServerEvent("outputChatBox", localPlayer, target, message)
                triggerServerEvent("playSoundServer", localPlayer, target, "files/pm.mp3")
            end
        else noOnline() end
    end
end
addCommandHandler("pm", pm_sc)


function valasz_sc(cmd, target, ...)
    if not (target) or not (...) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Üzenet]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "vá") then
            if getElementData(target, "loggedIn") then
                if localPlayer == target then 
                    exports['cr_infobox']:addBox("error", "Magadnak nem bírsz választ adni!")
                    return 
                end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local color2 = exports['cr_core']:getServerColor('red', true)
                local adminName = getAdminName(localPlayer)
                local jatekosName = getAdminName(target) --getElementData(target,"char >> name"):gsub("_", " ")
                local adminID = getElementData(localPlayer, "char >> id")
                local playerID = getElementData(target, "char >> id")
                local text = table.concat({...}, " ")

                valaszAdmin(color2.."[Segítségnyújtás] "..color..adminName.."#ffffff válaszolt "..color..jatekosName.."#ffffff-nak")
                valaszAdmin(color2.."[Segítségnyújtás] "..color.."szöveg:#ffffff "..text)

                local message = color.."[Segítség]#ffffff "..adminName..color.." ("..adminID.."):#ffffff "..text
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                outputChatBox(color.."[Válasz]#ffffff "..jatekosName..color.." ("..playerID.."):#ffffff "..text,0,0,0,true)
            else
                exports['cr_infobox']:addBox("error", "Nincs belépve a játékos!")
            end
        else noOnline() end
    end
end
addCommandHandler("va", valasz_sc)
addCommandHandler("vá", valasz_sc)
addCommandHandler("valasz", valasz_sc)
addCommandHandler("válasz", valasz_sc)


function togva_sc(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "togvá") then
        if getElementData(localPlayer, "admin >> togvá") then
            setElementData(localPlayer, "admin >> togvá", false)
            local colorTag = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(colorTag.."#ffffff Kikapcsoltad az admin válaszokat!",0,0,0,true)
        else
            setElementData(localPlayer, "admin >> togvá",true)
            local colorTag = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(colorTag.."#ffffff Bekapcsoltad az admin válaszokat!",0,0,0,true)
        end
    end
end
addCommandHandler("togva",togva_sc)
addCommandHandler("togvá",togva_sc)


function asChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "asChat") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = "Ismeretlen"
            
            if getAdminLevel(localPlayer) <= 2 then
                adminName = getElementData(localPlayer, "char >> name")
            else
                adminName = getAdminName(localPlayer, true)
            end
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getAdminLevel(localPlayer), true)
            local title = getAdminTitle(localPlayer)
            title = aTitle(localPlayer)
            
            local blue = exports['cr_core']:getServerColor('blue', true)
            exports['cr_core']:sendMessageToAdmin(localPlayer,blue .. "[AS] "..adminColor..'['..title.."] "..adminName.."#ffffff: "..text, 1)
        end
    end
end
addCommandHandler("as",asChat_sc)

function adminChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "adminChat") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getAdminLevel(localPlayer), true)
            local title = getAdminTitle(localPlayer)
            title = aTitle(localPlayer)

            local yellow = exports['cr_core']:getServerColor('yellow', true)
            exports['cr_core']:sendMessageToAdmin(localPlayer, yellow .. "[AdminChat] "..adminColor..'['..title.."] "..adminName.."#ffffff: "..text, 3)
			--triggerServerEvent("addNewAdminText", localPlayer, localPlayer:getData("acc >> id"), adminName, text, getAdminLevel(localPlayer), 0)
        end
    end
end
addCommandHandler("a",adminChat_sc)

function staffChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "staffChat") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getAdminLevel(localPlayer), true)
            local title = getAdminTitle(localPlayer)
            title = aTitle(localPlayer)

            local red = exports['cr_core']:getServerColor('red', true)
            exports['cr_core']:sendMessageToAdmin(localPlayer, red .. "[Staff] "..adminColor..'['..title.."] "..adminName.."#ffffff: "..text, 8)
			--triggerServerEvent("addNewAdminText", localPlayer, localPlayer:getData("acc >> id"), adminName, text, getAdminLevel(localPlayer), 0)
        end
    end
end
addCommandHandler("staff",staffChat_sc)

function vhspawn_sc(cmd, target, types)
    if not exports.cr_permission:hasPermission(localPlayer, "vhSpawn") then 
        return
    end

    if not (target) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "vhSpawn") then
            if getElementData(target, "loggedIn") then
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local adminName = getAdminName(localPlayer, true)
                local color = exports['cr_core']:getServerColor('yellow', true)

                if getPedOccupiedVehicle(target) then
	                triggerServerEvent("setElementPosition", localPlayer, getPedOccupiedVehicle(target), 2269.58203125, -105.2508392334, 26.477659225464, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
	            else
	            	triggerServerEvent("setElementPosition", localPlayer, target, 2269.58203125, -105.2508392334, 26.477659225464, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
                end
                
                target:setData("inInterior", nil)

                local message = color..adminName.."#ffffff a városházára teleportált!"
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..jatekosName.."#ffffff VH spawn-t kapott "..color..adminName.."#ffffff által!", 3)
            end
        else noOnline() end
    end
end
addCommandHandler("vhspawn",vhspawn_sc)

function mdspawn_sc(cmd, target, types)
    if not exports.cr_permission:hasPermission(localPlayer, "mdspawn") then 
        return
    end

    if not (target) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "mdspawn") then
            if getElementData(target, "loggedIn") then
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local adminName = getAdminName(localPlayer, true)
                local color = exports['cr_core']:getServerColor('yellow', true)

                if getPedOccupiedVehicle(target) then
	                triggerServerEvent("setElementPosition", localPlayer, getPedOccupiedVehicle(target), 1258.6268310547, 346.35501098633, 19.5546875, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
	            else
	            	triggerServerEvent("setElementPosition", localPlayer, target, 1258.6268310547, 346.35501098633, 19.5546875, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
                end
                
                target:setData("inInterior", nil)

                local message = color..adminName.."#ffffff az mdhez teleportált!"
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..jatekosName.."#ffffff MD spawn-t kapott "..color..adminName.."#ffffff által!", 3)
            end
        else noOnline() end
    end
end
addCommandHandler("mdspawn",mdspawn_sc)

function bberryspawn_sc(cmd, target, types)
    if not exports.cr_permission:hasPermission(localPlayer, "bberryspawn") then 
        return
    end

    if not (target) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "bberryspawn") then
            if getElementData(target, "loggedIn") then
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local adminName = getAdminName(localPlayer, true)
                local color = exports['cr_core']:getServerColor('yellow', true)

                if getPedOccupiedVehicle(target) then
	                triggerServerEvent("setElementPosition", localPlayer, getPedOccupiedVehicle(target), 101.957862854, -221.50387573242, 1.5841461420059, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
	            else
	            	triggerServerEvent("setElementPosition", localPlayer, target, 101.957862854, -221.50387573242, 1.5841461420059, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
                end
                
                target:setData("inInterior", nil)

                local message = color..adminName.."#ffffff blueberrybe teleportált!"
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..jatekosName.."#ffffff BlueBerry spawn-t kapott "..color..adminName.."#ffffff által!", 3)
            end
        else noOnline() end
    end
end
addCommandHandler("bberryspawn",bberryspawn_sc)
addCommandHandler("bbspawn",bberryspawn_sc)

function pdspawn_sc(cmd, target, types)
    if not exports.cr_permission:hasPermission(localPlayer, "pdspawn") then 
        return
    end

    if not (target) then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
    else
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target and exports['cr_permission']:hasPermission(localPlayer, "pdspawn") then
            if getElementData(target, "loggedIn") then
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local adminName = getAdminName(localPlayer, true)
                local color = exports['cr_core']:getServerColor('yellow', true)

                if getPedOccupiedVehicle(target) then
	                triggerServerEvent("setElementPosition", localPlayer, getPedOccupiedVehicle(target), 647.69390869141, -572.10845947266, 16.213834762573, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
	            else
	            	triggerServerEvent("setElementPosition", localPlayer, target, 647.69390869141, -572.10845947266, 16.213834762573, 0, 0, -1)
	                setElementRotation(target, 0.0, 0.0, 360)
                end
                
                target:setData("inInterior", nil)

                local message = color..adminName.."#ffffff a pdhez teleportált!"
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..jatekosName.."#ffffff pd spawn-t kapott "..color..adminName.."#ffffff által!", 3)
            end
        else noOnline() end
    end
end
addCommandHandler("pdspawn",pdspawn_sc)

function recon_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "recon") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
            local color = exports['cr_core']:getServerColor('yellow', true)
            local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")

            if target then
                if getElementData(target,"loggedIn") then
                    if not getElementData(target, "player >> recon") then
                        if getElementData(localPlayer, "player >> recon") then
                            local x,y,z = getElementPosition(localPlayer)
                            local dim = getElementDimension(localPlayer)
                            local int = getElementInterior(localPlayer)
                            setElementData(localPlayer,"recon >> tarX", x)
                            setElementData(localPlayer,"recon >> tarY", y)
                            setElementData(localPlayer,"recon >> tarZ", z)
                            setElementData(localPlayer,"recon >> dim", dim)
                            setElementData(localPlayer,"recon >> int", int)
                        end
                        triggerServerEvent("setPlayerCol", localPlayer, localPlayer, false)
                        triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 0)
                        setElementData(localPlayer, "player >> recon", true)
                        setElementData(localPlayer, "player >> recon >> target", target)
                        setElementFrozen(localPlayer, true)
                        setCameraTarget(target)   
                        setElementInterior(localPlayer, target.interior)
                        setElementDimension(localPlayer, target.dimension)
                        exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megfigyeli "..color..jatekosName.."#ffffff játékost!", 8)  

                        -- local customInterior = target:getData("customInterior")

                        -- if customInterior then 
                        --     if customInterior > 0 then 
                        --         localPlayer:setData("player >> recon >> targetInCustomInterior", true)
                        --         exports.cr_interior:loadCustomInterior(customInterior, target)
                        --     else 
                        --         exports.cr_interior:destroyCustomInterior(customInterior)
                        --     end
                        -- end
                    else
                        exports["cr_infobox"]:addBox("error","A játékos már reconol valakit!");
                    end
                end
            else noOnline() end
        end
    end
end
addCommandHandler("recon", recon_sc)

function stopRecon_sc(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "recon") then
        local color = exports['cr_core']:getServerColor('yellow', true)
        local wasInCustomInterior = localPlayer:getData("player >> recon >> targetInCustomInterior")

        if wasInCustomInterior then 
            exports.cr_interior:destroyCustomInterior(wasInCustomInterior)
        end

        local tarX = getElementData(localPlayer,"recon >> tarX")
        local tarY = getElementData(localPlayer,"recon >> tarY")
        local tarZ = getElementData(localPlayer,"recon >> tarZ")
        local dim = getElementData(localPlayer,"recon >> dim")
        local int = getElementData(localPlayer,"recon >> int")

        setCameraTarget(localPlayer)
        if tarX and tarY and tarZ and int and dim then 
            setElementPosition(localPlayer,tarX,tarY,tarZ)
            setElementDimension(localPlayer, dim)
            setElementInterior(localPlayer, int)
        end
        setElementData(localPlayer, "player >> recon", false)
        setElementData(localPlayer, "player >> recon >> target", nil)
        setElementData(localPlayer, "player >> recon >> targetInCustomInterior", nil)
        setElementFrozen(localPlayer, false)

        triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 255)
        triggerServerEvent("setPlayerCol", localPlayer, localPlayer, true)

        exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff befejezte a megfigyelést!", 8)
    end
end
addCommandHandler("stoprecon", stopRecon_sc)


function goto_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "goto") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local x,y,z
	            local dim
                local int
                local elementToTeleport = (localPlayer:isInVehicle() and localPlayer.vehicle or localPlayer)
                if getElementData(target,"clone") then
                    local target = target:getData("clone") or target
                	x,y,z = getElementPosition(target)
	                dim = getElementDimension(target)
	                int = getElementInterior(target)
                else
	                x,y,z = getElementPosition(target)
	                dim = getElementDimension(target)
	                int = getElementInterior(target)
	            end

                triggerServerEvent("setElementPosition", localPlayer, elementToTeleport, x,y,z, dim, int)

                outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz!",0,0,0,true)
                local message = color..adminName.."#ffffff hozzád teleportált!"
                triggerServerEvent("outputChatBox", localPlayer, target, message)

                localPlayer:setData("inInterior", target:getData("inInterior"))
                localPlayer:setData("customInterior", target:getData("customInterior"))

                local customInterior = localPlayer:getData("customInterior")

                if customInterior then 
                    if customInterior > 0 then 
                        exports.cr_interior:loadCustomInterior(customInterior, target)
                    else 
                        exports.cr_interior:destroyCustomInterior(customInterior)
                    end
                end
            else noOnline() end
        end
    end
end
addCommandHandler("goto",goto_sc)

function gotopos(cmd, x, y, z, dim, int)
    if exports['cr_permission']:hasPermission(localPlayer, "gotopos") then
        x = tonumber(x)
        y = tonumber(y)
        z = tonumber(z)
        dim = tonumber(dim or 0)
        int = tonumber(int or 0)
        if not x or not y or not z then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [X] [Y] [Z] [Dim] [Int]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            triggerServerEvent("setElementPosition", localPlayer, localPlayer, x,y,z, dim, int)

            outputChatBox(white.."#ffffffOdateleportáltál a kijelölt helyre!",0,0,0,true)
        end
    end
end
addCommandHandler("gotopos",gotopos)

function gethere_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "gethere") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local x,y,z = getElementPosition(localPlayer)
                local dim = getElementDimension(localPlayer)
                local int = getElementInterior(localPlayer)

                target:setData("customInterior", localPlayer:getData("customInterior"))
                local customInterior = localPlayer:getData("customInterior")

                if getPedOccupiedVehicle(target) then
                    local veh = getPedOccupiedVehicle(target)
                    triggerServerEvent("setElementPosition", localPlayer, veh, x,y+1,z, dim, int, customInterior)
                    outputChatBox(white.."#ffffff Sikeresen magadhoz teleportáltad "..color..jatekosName.."#ffffff játékost!",0,0,0,true)
                    local message = color..adminName.."#ffffff magához teleportált!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                	if getElementData(target,"char >> death") then
                        triggerServerEvent("setElementPosition", localPlayer, getElementData(target,"clone"), x,y+1,z, dim, int, customInterior)
                        return 
                    else
                    	triggerServerEvent("setElementPosition", localPlayer, target, x,y+1,z, dim, int, customInterior)
                    end
                    outputChatBox(white.."#ffffff Sikeresen magadhoz teleportáltad "..color..jatekosName.."#ffffff játékost!",0,0,0,true)
                    local message = color..adminName.."#ffffff magához teleportált!"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                end

                target:setData("inInterior", localPlayer:getData("inInterior"))
            else noOnline() end
        end
    end
end
addCommandHandler("gethere",gethere_sc)
addCommandHandler("get",gethere_sc)

function sethp_sc(cmd,target,health)
    if exports['cr_permission']:hasPermission(localPlayer, "sethp") then
        if not (target) or not (health) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Élet]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                health = tonumber(health)
                if(health >= 0 and health <= 100)then
                	if getAdminLevel(localPlayer) >= getAdminLevel(target) then
	                    triggerServerEvent("setElementHealth", localPlayer, target, health)
	                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff életét. ("..color..health.."#ffffff)", 3)
	                    local message = color..adminName.."#ffffff megváltoztatta az életerőd! ("..color..health.."#ffffff)"
	                    triggerServerEvent("outputChatBox", localPlayer, target, message)
	                else
	                	outputChatBox(getAdminSyntax().."#ffffffNagyobb admin életét nem változtathatod meg!",0,0,0,true)
	                end
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("sethp",sethp_sc)
addCommandHandler("sethealth",sethp_sc)

function setarmor_sc(cmd,target,armor)
    if exports['cr_permission']:hasPermission(localPlayer, "setarmor") then
        if not (target) or not (armor) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Armor]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                armor = tonumber(armor)
                if(armor >= 0 and armor <= 100)then
                    triggerServerEvent("setElementArmor", localPlayer, target, armor)
                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff páncélszintjét. ("..color..armor.."#ffffff)", 3)
                    local message = color..adminName.."#ffffff megváltoztatta az páncélszinted! ("..color..armor.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
        end
    end
end
addCommandHandler("setarmor",setarmor_sc)

setElementData(localPlayer, "player >> vanish", false) -- Ha újraindítsuk a resourcet akkor újra láthatatlan legyen!
triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 255) -- ez is azért xD
function vanish_sc()
    if exports['cr_permission']:hasPermission(localPlayer, "vanish") then
        if not getElementData(localPlayer, "player >> vanish") then
            triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 0)
            setElementData(localPlayer, "player >> vanish", true)
        else
            triggerServerEvent("setPlayerAlpha", localPlayer, localPlayer, 255)
            setElementData(localPlayer, "player >> vanish", false)
        end
    end
end
addCommandHandler("vanish", vanish_sc)
addCommandHandler("disappear", vanish_sc)


function hunger_sc(cmd, target, hunger)
	if exports['cr_permission']:hasPermission(localPlayer, "sethunger") then
		if not (target) or not (hunger) then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Hunger]",0,0,0,true)
		else
			local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                hunger = tonumber(hunger)
                if(hunger >= 0 and hunger <= 100)then
                    setElementData(target, "char >> food", hunger)

                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff éhség szintjét. ("..color..hunger.."#ffffff)", 3)
                    local message = color..adminName.."#ffffff megváltoztatta az éhség szintedet! ("..color..hunger.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
		end
	end
end
addCommandHandler("sethunger", hunger_sc)
addCommandHandler("setfood", hunger_sc)

function water_sc(cmd, target, water)
	if exports['cr_permission']:hasPermission(localPlayer, "setwater") then
		if not (target) or not (water) then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Water]",0,0,0,true)
		else
			local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                water = tonumber(water)
                if(water >= 0 and water <= 100)then
                    setElementData(target, "char >> drink", water)

                    exports['cr_core']:sendMessageToAdmin(localPlayer,getAdminSyntax()..color..getAdminName(localPlayer, true).."#ffffff megváltoztatta "..color..jatekosName.."#ffffff szomjúság szintjét. ("..color..water.."#ffffff)", 3)
                    local message = color..adminName.."#ffffff megváltoztatta az szomjúság szintedet! ("..color..water.."#ffffff)"
                    triggerServerEvent("outputChatBox", localPlayer, target, message)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax.."#ffffff Minimum "..color.."0#ffffff, maximum "..color.."100#ffffff lehet az érték!",0,0,0,true)
                end
            else noOnline() end
		end
	end
end
addCommandHandler("setwater", water_sc)
addCommandHandler("setwaterlevel", water_sc)
addCommandHandler("setthirsty", water_sc)
addCommandHandler("setthirst", water_sc)
addCommandHandler("setdrink", water_sc)


function kick_sc(cmd,target,...)
	if exports['cr_permission']:hasPermission(localPlayer, "kick") then
		if not (target) or not (...) then
			local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Indok]",0,0,0,true)
		else
			local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local text = table.concat({...}, " ")
                local color = exports['cr_core']:getServerColor('yellow', true)
                
                if localPlayer == target then 
                    return 
                end
                
                if tonumber(getAdminLevel(localPlayer) or 0) < 0 then 
                    if tonumber(getAdminLevel(target) or 0) > 0 and tonumber(getAdminLevel(localPlayer) or 0) < tonumber(getAdminLevel(target) or 0) then
                        outputChatBox(getAdminSyntax().."#ffffffNagyobb admin-t nem kickelhetsz!",0,0,0,true)
                        return 
                    end
                else 
                    if tonumber(getAdminLevel(localPlayer) or 0) < tonumber(getAdminLevel(target) or 0) then
                        outputChatBox(getAdminSyntax().."#ffffffNagyobb admin-t nem kickelhetsz!",0,0,0,true)
                        return 
                    end
                end 

                triggerServerEvent("kickedPlayer",localPlayer,target,adminName,text)
                local maxHasFix = getMaxKickCount() or 0
                local thePlayer = localPlayer
                local hasFIX = getElementData(thePlayer, "kick >> using") or 0
                local hasFIX = hasFIX + 1
                setElementData(thePlayer, "kick >> using", hasFIX)
                if hasFIX > maxHasFix then
                    local green = exports['cr_core']:getServerColor("orange", true)
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    --local vehicleName = getVehicleName(target)
                    outputChatBox(syntax .. "Figyelem! Átlépted a megengedett Kick limitet! (Limit: "..green..maxHasFix..white..") (Kickek száma: "..green..hasFIX..white..")", 255,255,255,true)
                end
                --triggerServerEvent("showInfo",localPlayer,target,"kick",text, "#ff751a"..adminName.."#ffffff kickelte#ff751a "..jatekosName.."#ffffff játékost.")
                
                local red = exports['cr_core']:getServerColor("red", true)
                local blue = exports['cr_core']:getServerColor('yellow', true)
                local white = "#F2F2F2"
                triggerServerEvent("showAdminBox",localPlayer, blue..adminName..white.." kirúgta "..red..jatekosName..white.." játékost"..white.."\nIndok: "..red..text, "warning", {adminName.." kirúgta "..jatekosName .. " játékost", "Indok: "..text})
			else noOnline() end
		end
	end
end
addCommandHandler("kick",kick_sc)
addCommandHandler("akick",kick_sc)

function simgoto_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "sgoto") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(localPlayer, target)
			if target then
        		if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(localPlayer, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local x,y,z = getElementPosition(target)
                local dim = getElementDimension(target)
                local int = getElementInterior(target)

                if not getPedOccupiedVehicle(localPlayer) then
                    triggerServerEvent("setElementPosition", localPlayer, localPlayer, x,y+1,z, dim, int)
                    outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz! ("..color.."Rejtett#ffffff)",0,0,0,true)
                else
                    local veh = getPedOccupiedVehicle(localPlayer)
                    setElementInterior(veh, int)
                    setElementDimension(veh, dim)
                    setElementPosition(veh, x+2, y, z+1)

                    setElementInterior(localPlayer, int)
                    setElementDimension(localPlayer, dim)

                    warpPedIntoVehicle(localPlayer, veh)

                    outputChatBox(white.."#ffffffOdateleportáltál "..color..jatekosName.."#ffffff játékoshoz! ("..color.."Rejtett#ffffff)",0,0,0,true)
                end

                local adminSyntax = getAdminSyntax()
                local localName = getAdminName(localPlayer, true)
                local white = "#ffffff"

                exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. color .. localName .. white .. " titokban elteleportált " .. color .. targetName .. white .. " játékoshoz.", 8)

                localPlayer:setData("inInterior", target:getData("inInterior"))
                localPlayer:setData("customInterior", target:getData("customInterior"))

                local customInterior = localPlayer:getData("customInterior")

                if customInterior then 
                    if customInterior > 0 then 
                        exports.cr_interior:loadCustomInterior(customInterior, target)
                    else 
                        exports.cr_interior:destroyCustomInterior(customInterior)
                    end
                end
            else noOnline() end
        end
    end
end
addCommandHandler("sgoto",simgoto_sc)

--[[
local glue = false
local glue_e = false
function glue_sc(cmd)
	local entry = false
	if getPedOccupiedVehicle(localPlayer) then return end
	local e = getPlayerContactElement(localPlayer)
	if exports['cr_permission']:hasPermission(localPlayer, "glue") then
		entry = true
	else
		if isElement(e) then
			local mID = getElementModel(e)
			if glue_vehs[mID] then
				entry = true
			end
		end
	end
	if not glue then
		if not isElement(e) then return end
		if not entry then return end
		if getElementType(e) == "vehicle" then
			local px, py, pz = getElementPosition(localPlayer)
			local vx, vy, vz = getElementPosition(e)
			local sx = px - vx
			local sy = py - vy
			local sz = pz - vz
			
			local rotpX = 0
			local rotpY = 0
			local a,b,rotpZ = getElementRotation(localPlayer)     
				
			local rotvX,rotvY,rotvZ = getElementRotation(e)
			
			local t = math.rad(rotvX)
			local p = math.rad(rotvY)
			local f = math.rad(rotvZ)
				
			local ct = math.cos(t)
			local st = math.sin(t)
			local cp = math.cos(p)
			local sp = math.sin(p)
			local cf = math.cos(f)
			local sf = math.sin(f)
				
			local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
			local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
			local y = st*sz - sf*ct*sx + cf*ct*sy
			
			local rotX = rotpX - rotvX
			local rotY = rotpY - rotvY
			local rotZ = rotpZ - rotvZ

			glue = true
			glue_e = e

			triggerServerEvent("glue_attach",localPlayer,e,x, y, z, rotX, rotY, rotZ)
		end
	else
		glue = false
		glue_e = false

		triggerServerEvent("glue_deatach",localPlayer)
	end
end
addCommandHandler("glue",glue_sc)

addEventHandler("onClientElementDestroy",root,
	function()
		if glue_e == source then
			glue = false
			glue_e = false
			triggerServerEvent("glue_deatach",localPlayer)
		end
	end
)

addEventHandler("onClientElementDataChange",root,
	function(dName)
		if getElementType(source) == "vehicle" and dName == "veh >> loaded" then
			if glue_e == source then
				local bool = getElementData(source,dName)
				if not bool then
					glue = false
					glue_e = false
					triggerServerEvent("glue_deatach",localPlayer)
				end
			end
		end
	end
)

function accinfo_sc(cmd, target)
    if exports['cr_permission']:hasPermission(localPlayer, "accinfo") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név]",0,0,0,true)
        else
            local color = exports['cr_core']:getServerColor('yellow', true)
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
            if target then
            	local username = getElementData(target, "acc >> username")
            	local accid = getElementData(target, "acc >> id")
                local serial = getElementData(target, "mtaserial")

                --local ip level 9admin felett + kellenek a targeteg

            	local gamename = getElementData(target, "char >> name")
            	--local regdate
            	--local lastplayed
            	local playedtime = getElementData(target, "char >> playedtime")
            	--local ajk
            	--local bannok
            	local money = getElementData(target, "char >> money")
            	local bankmoney = getElementData(target, "char >> bankmoney")
            	local pp = getElementData(target, "char >> premiumPoints")
            	local health = getElementHealth(target)
        		local armor = getPedArmor(target)
            	local food = getElementData(target, "char >> food")
        		local drink = getElementData(target, "char >> drink")
        		local level = getElementData(target, "char >> level")
            	local skinid = getElementData(target, "char >> skin")
            	--local hazakidk
            	local vehicles = "Jármű ID-k: "
            	for k,v in pairs(getElementsByType("vehicle"))do
            		local vid = getElementData(v,"veh >> owner")
            		if vid == accid then
            			vehicles = getElementData(v,"veh >> id")..", "
            		end
            	end
            	--local fraki

            else noOnline() end
        end
    end
end
addCommandHandler("accinfo", accinfo_sc)]]

function faChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "af") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getAdminLevel(localPlayer), true)

            exports['cr_core']:sendMessageToAdmin(localPlayer,"#3385ff[FAChat]#7cc576 "..getAdminTitle(localPlayer).." "..adminName.."#ffffff : "..text, 8)
        end
    end
end
addCommandHandler("fc",faChat_sc)

function devChat_sc(cmd, ...)
    if exports['cr_permission']:hasPermission(localPlayer, "dev") then
        if not (...) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."/"..cmd.." [Üzenet]",0,0,0,true)
        else
            local adminName = getAdminName(localPlayer, true)
            local text = table.concat({...}, " ")
            local adminColor = getAdminColor(localPlayer, getAdminLevel(localPlayer), true)

            exports['cr_core']:sendMessageToAdmin(localPlayer,"#D35400[Developer]#7cc576 "..getAdminTitle(localPlayer).." "..adminName.."#ffffff: "..text, 11)
        end
    end
end
addCommandHandler("dc",devChat_sc)

function player_Wasted(attacker, weapon, bodypart)
    local time = exports['cr_core']:getTime()

    local white = "#dcdcdc"
    local text = white .. time .. " "
    local blue = exports['cr_core']:getServerColor('yellow', true)
    if attacker then
        if getElementType(attacker) == "player" then
        	if(bodypart == 9) then
				if not getElementData(localPlayer, "char >> headless") then
            	    setElementData(localPlayer, "char >> headless", true)
                end
                
            	local weaponName = getWeaponNameFromID(weapon)
                weaponName = exports['cr_death-system']:getWeaponNameTranslated(weaponName) or weaponName
            	local killerName = exports['cr_admin']:getAdminName(attacker)
            	text = text .. blue .. killerName .. white .. " fejbelőtte " .. blue .. exports['cr_admin']:getAdminName(localPlayer) .. white .. " játékost! (Fegyver: " .. blue .. weaponName .. white .. " - FEJLÖVÉS)"
            	exports['cr_core']:sendMessageToAdmin(localPlayer,text,3)
        	elseif (bodypart == 4) then
        		local weaponName = getWeaponNameFromID(weapon)
                weaponName = exports['cr_death-system']:getWeaponNameTranslated(weaponName) or weaponName
	            local killerName = exports['cr_admin']:getAdminName(attacker)
	            text = text .. blue .. killerName .. white .. " megölte " .. blue .. exports['cr_admin']:getAdminName(localPlayer) .. white .. " játékost! (Fegyver: " .. blue .. weaponName .. white .. " - SEGGBELŐTTÉK)"
	            exports['cr_core']:sendMessageToAdmin(localPlayer,text,3)
        	else
	            local weaponName = getWeaponNameFromID(weapon)
                weaponName = exports['cr_death-system']:getWeaponNameTranslated(weaponName) or weaponName
	            local killerName = exports['cr_admin']:getAdminName(attacker)
	            text = text .. blue .. killerName .. white .. " megölte " .. blue .. exports['cr_admin']:getAdminName(localPlayer) .. white .. " játékost! (Fegyver: " .. blue .. weaponName .. white .. " )"
	            
	            exports['cr_core']:sendMessageToAdmin(localPlayer,text,3)
        	end
        elseif getElementType(attacker) == "vehicle" then
            local killerName = "Ismeretlen, Kocsi id: " .. tonumber(getElementData(attacker, "veh >> id") or -1)
            local killer = getVehicleController(attacker)
            if killer then
                killerName = exports['cr_admin']:getAdminName(killer)
            end
            text = text .. blue .. killerName .. white .. " elütötte ".. blue .. exports['cr_admin']:getAdminName(localPlayer) .. white .. " játékost! [DB gyanúja]"
            exports['cr_core']:sendMessageToAdmin(localPlayer,text,3)
        end

        if getWeaponNameFromID(weapon) == "Explosion" then
            local killerName = exports['cr_admin']:getAdminName(attacker)
            text = text .. blue .. killerName .. white .. " felrobbantotta " .. blue .. exports['cr_admin']:getAdminName(localPlayer) .. white .. " játékost!"
            exports['cr_core']:sendMessageToAdmin(localPlayer,text,3)
        end
    else
    	text = text .. blue .. exports['cr_admin']:getAdminName(localPlayer) .. white .. " meghalt!"
        exports['cr_core']:sendMessageToAdmin(localPlayer,text,3)
    end

    triggerLatentServerEvent("killLog", 5000, false, localPlayer, localPlayer, attacker, text)
end
addEventHandler("onClientPlayerWasted", localPlayer, player_Wasted)

-- /setmoney, /setpp, /givemoney, /givepp

function setMoney(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setmoney") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> money")
                setElementData(target, "char >> money", amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax() ..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." pénzének mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..amount.."#ffffff-ra/re.", 3)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "Money", "setmoney", time .. aName1.." megváltoztatta "..aName2.." pénzének mennyiségét "..oValue.."-ról/ről "..amount.."-ra/re.")
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setmoney", setMoney)

function setPP(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setpp") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> premiumPoints")
                setElementData(target, "char >> premiumPoints", amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax()..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." prémium pontjainak mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..amount.."#ffffff-ra/re.", 3)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "PP", "setpp", time .. aName1.." megváltoztatta "..aName2.." prémium pontjainak mennyiségét "..oValue.."-ról/ről "..amount.."-ra/re.")
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("setpp", setPP)

function giveMoney(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setmoney") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> money")
                setElementData(target, "char >> money", oValue + amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax()..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." pénzének mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..oValue+amount.."#ffffff-ra/re.", 3)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "Money", "givemoney", time .. aName1.." megváltoztatta "..aName2.." pénzének mennyiségét "..oValue.."-ról/ről "..oValue+amount.."-ra/re.")
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("givemoney", giveMoney)

function givePP(cmd, target, amount)
    if exports['cr_permission']:hasPermission(localPlayer, "setpp") then
        if not amount or not target then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax .. "/"..cmd.." [target] [amount]", 255,255,255,true)
            return
        elseif tonumber(amount) == nil then
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "A mennyiségnek egy számnak kell lennie!", 255,255,255,true)
            return    
        end
        
        amount = tonumber(math.floor(amount))
        local target = exports['cr_core']:findPlayer(localPlayer, target)
        if not getElementData(target, "loggedIn") then outputChatBox(exports['cr_core']:getServerSyntax(false, "error")..white.."A játékos nincs bejelentkezve!",255,255,255,true) return end
        if target then
            if getElementData(target, "loggedIn") then
                local oValue = getElementData(target, "char >> premiumPoints")
                setElementData(target, "char >> premiumPoints", oValue + amount)
                local aName1 = getAdminName(localPlayer, true)
                local aName2 = getAdminName(target)
                local hexColor = exports['cr_core']:getServerColor('yellow', true)
                exports['cr_core']:sendMessageToAdmin(localPlayer, getAdminSyntax()..hexColor..aName1..white.." megváltoztatta "..hexColor..aName2..white.." prémium pontjának mennyiségét "..hexColor..oValue.."#ffffff-ról/ről "..hexColor..oValue+amount.."#ffffff-ra/re.", 3)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(localPlayer, "PP", "givepp", time .. aName1.." megváltoztatta "..aName2.." prémium pontjának mennyiségét "..oValue.."-ról/ről "..oValue+amount.."-ra/re.")
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("givepp", givePP)

addCommandHandler("setskin",
    function(cmd, target, skin)
        if exports['cr_permission']:hasPermission(localPlayer, "setskin") then
            if (not target or not tonumber(skin)) then
                local syntax = exports['cr_core']:getServerSyntax(false, "warning")
                outputChatBox(syntax.."/"..cmd.." [Játékos ID/Név] [Skin]", 0, 0, 0, true)
            else
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    if not getElementData(target, "loggedIn") then 
                        outputChatBox(exports['cr_core']:getServerSyntax(false, "error").."#ffffffA játékos nincs bejelentkezve!", 0, 0, 0, true) 
                        return; 
                    end

                    local adminName = exports.cr_admin:getAdminName(localPlayer, true)
                    local targetName = getElementData(target,"char >> name"):gsub("_"," ")
                    local color = exports['cr_core']:getServerColor('yellow', true)

                    skin = tonumber(skin)

                    if exports['cr_skins']:isSkinValid(skin) then
                        setElementData(target, "char >> skin", skin);

                        if target:getData("char >> dutyskin") then 
                            target:setData("char >> dutyskin", skin)
                        end

                        outputChatBox("#ffffffSikeresen megváltoztattad "..color..targetName.."#ffffff kinézetét! ("..color..skin.."#ffffff)", 0, 0, 0, true)
                        triggerServerEvent("outputChatBox", localPlayer, target, color..adminName.."#ffffff megváltoztatta a kinézeted! (Új skin ID:"..color..skin.."#ffffff)")
                    end 
                else 
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax..white.."Nincs ilyen játékos!", 0, 0, 0, true)
                end
            end
        end
    end,
false, false)

--
-- /resetfix
function resetFix(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetfix") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "fix >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." FIX számait", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetfix", time .. aName1.." nullázta "..aName2.." FIX számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetfix", resetFix)

-- /resetrtc
function resetRTC(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetrtc") then
        if target then
            if getElementData(target, "loggedIn") then
                local target = exports['cr_core']:findPlayer(localPlayer, target)
                if target then
                    setElementData(target, "rtc >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." RTC számait", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetrtc", time .. aName1.." nullázta "..aName2.." RTC számait")
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("resetrtc", resetRTC)

-- /resetfuel
function resetFUEL(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetfuel") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "fuel >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." FUEL számait", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetfuel", time .. aName1.." nullázta "..aName2.." FUEL számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetfuel", resetFUEL)



-- /getAdminStats
function getAdminStats(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "getadminstats") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local white = "#f2f2f2"
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    local time = exports['cr_core']:getTime() .. " "
                    local fix = getElementData(target, "fix >> using") or 0
                    local fuel = getElementData(target, "fuel >> using") or 0
                    local rtc = getElementData(target, "rtc >> using") or 0
                    local ban = getElementData(target, "ban >> using") or 0
                    local kick = getElementData(target, "kick >> using") or 0
                    local jail = getElementData(target, "jail >> using") or 0
                    local dutyMinutes = getElementData(target, "admin >> time") or 0
                    local dutyMinutes = math.floor(dutyMinutes / 60)
                    local maxJail = exports['cr_admin']:getMaxJailCount() or 0
                    local maxKick = exports['cr_admin']:getMaxKickCount() or 0
                    local maxBan = exports['cr_admin']:getMaxBanCount() or 0
                    local maxHasRTC = exports['cr_admin']:getMaxRTCCount() or 0
                    local maxHasFuel = exports['cr_admin']:getMaxFuelCount() or 0
                    local maxHasFix = exports['cr_admin']:getMaxFixCount() or 0
                    stats = {
                        ["hoverText"] = white .. "Admin Statisztika",
                        ["altText"] = white .. aName2,
                        ["minLines"] = 1,
                        ["maxLines"] = 5,
                        ["texts"] = {}
                    }
                    table.insert(stats["texts"], {white .. "AdminDutyban töltött órák: ", hexColor..dutyMinutes})
                    table.insert(stats["texts"], {white .. "AdminDutyban töltött percek: ", hexColor..math.floor(dutyMinutes*60)})
                    table.insert(stats["texts"], {white .. "Fixek: ", hexColor..fix..white.."/"..hexColor..maxHasFix})
                    table.insert(stats["texts"], {white .. "RTC-k: ", hexColor..rtc..white.."/"..hexColor..maxHasRTC})
                    table.insert(stats["texts"], {white .. "Fuelek: ", hexColor..fuel..white.."/"..hexColor..maxHasFuel})
                    table.insert(stats["texts"], {white .. "Jailek: ", hexColor..jail..white.."/"..hexColor..maxJail})
                    table.insert(stats["texts"], {white .. "Kickek: ", hexColor..kick..white.."/"..hexColor..maxKick})
                    table.insert(stats["texts"], {white .. "Bannok: ", hexColor..ban..white.."/"..hexColor..maxBan})
                    exports['cr_dx']:openInformationsPanel(stats)
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("getadminstats", getAdminStats)

-- /resetadminstats
function resetAdminStats(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetadminstats") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "fuel >> using", 0)
                    setElementData(target, "rtc >> using", 0)
                    setElementData(target, "fix >> using", 0)
                    setElementData(target, "jail >> using", 0)
                    setElementData(target, "ban >> using", 0)
                    setElementData(target, "kick >> using", 0)
                    setElementData(target, "jail >> using", 0)
                    setElementData(target, "admin >> time", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." összes statisztikáját", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetadminstats", time .. aName1.." nullázta "..aName2.." összes statisztikáját")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetadminstats", resetAdminStats)

-- /resetjail
function resetJail(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetjail") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "jail >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." Jail számait", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetjail", time .. aName1.." nullázta "..aName2.." Jail számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetjail", resetJail)

-- /resetkick
function resetKick(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetkick") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "kick >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." Kick számait", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetkick", time .. aName1.." nullázta "..aName2.." Kick számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetkick", resetKick)

-- /resetban
function resetBan(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetkick") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "ban >> using", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." Ban számait", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetban", time .. aName1.." nullázta "..aName2.." Ban számait")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetban", resetBan)

-- /resetatime
function resetAtime(cmd, target)
    if not target then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [Target]", 255,255,255,true)
        return
    end
    if exports['cr_permission']:hasPermission(localPlayer, "resetkick") then
        if target then
            local target = exports['cr_core']:findPlayer(localPlayer, target)
            if target then
                if getElementData(target, "loggedIn") then
                    setElementData(target, "admin >> time", 0)
                    local aName1 = exports['cr_admin']:getAdminName(localPlayer, true)
                    local aName2 = exports['cr_admin']:getAdminName(target, true)
                    local hexColor = exports['cr_core']:getServerColor('yellow', true)
                    local syntax = exports['cr_admin']:getAdminSyntax()
                    local time = exports['cr_core']:getTime() .. " "
                    exports['cr_core']:sendMessageToAdmin(localPlayer, syntax ..""..hexColor..aName1..white.." nullázta "..hexColor..aName2..white.." AdminDuty perceit", 8)
                    exports['cr_logs']:addLog(localPlayer, "Admin", "resetatime", time .. aName1.." nullázta "..aName2.." AdminDuty perceit")
                else
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                    outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255,255,255,true)
                end
            end
        end
    end
end
addCommandHandler("resetatime", resetAtime)

function adminSay(cmd, ...)
    if exports["cr_permission"]:hasPermission(localPlayer, "asay") then 
        if not ... then 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax.."/"..cmd.." [szöveg]", 255, 0, 0, true)
            return 
        else 
            local message = table.concat({...}, " ")
            local level = localPlayer:getData("admin >> level")
            local colorCode = exports["cr_core"]:getServerColor("red", true)

            exports["cr_core"]:sendMessageToAdmin(localPlayer, colorCode.."[Admin felhívás]: "..getAdminColorByLevel(level, true)..getAdminTitle(localPlayer).." - "..getAdminName(localPlayer, true)..":#ffffff "..exports["cr_chat"]:findSwear(message), 0)
            triggerLatentServerEvent("handleSound", 5000, false, localPlayer, "files/asay.ogg")
        end
    end
end
addCommandHandler("asay", adminSay, false, false)

addEvent("handleSound", true)
addEventHandler("handleSound", root,
    function(filePath)
        Sound(filePath)
    end
)

function getVehicleStats(cmd, id)
    if not id then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "/"..cmd.." [ID]", 255,255,255,true)
        return
    elseif tonumber(id) == nil and id ~= "*" then
        local syntax = exports['cr_core']:getServerSyntax(false, "warning")
        outputChatBox(syntax .. "Az ID-nek egy számnak kell lennie!", 255,255,255,true)
        return
    end
    local target = false
    if exports['cr_permission']:hasPermission(localPlayer, "getvehiclestats") then
        if id then
            for k,v in pairs(getElementsByType("vehicle")) do
                local id2 = getElementData(v, "veh >> id") or 0
                if id2 == tonumber(id) then
                    target = v
                end
            end
            if target then
                local green = exports['cr_core']:getServerColor('yellow', true)
                local white = "#f2f2f2"
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                local vehicleName = exports['cr_vehicle']:getVehicleName(target)
                local health = math.floor(getElementHealth(target))
                local a1, a2, a3 = getElementRotation(target)
                local text1 = green..(math.floor(a1))..white..", "..green..(math.floor(a2))..white..", "..green..(math.floor(a3))..white
                local odometer = math.floor(getElementData(target, "veh >> odometer"))
                local lastOilRecoil = math.floor(getElementData(target, "veh >> lastOilRecoil"))
                local fuel = math.floor(getElementData(target, "veh >> fuel"))
                local engine = getElementData(target, "veh >> engine")
                local engineColor = exports['cr_core']:getServerColor("red", true)
                local engineString = "Nincs elindítva"
                if engine then
                    engineColor = exports['cr_core']:getServerColor("green", true)
                    engineString = "Elindítva"
                end
                local light = getElementData(target, "veh >> light")
                local lightColor = exports['cr_core']:getServerColor("red", true)
                local lightString = "Nincs elindítva"
                if light then
                    lightColor = exports['cr_core']:getServerColor("green", true)
                    lightString = "Elindítva"
                end
                local ownerID = getElementData(target, "veh >> owner")
                stats = {
                    ["hoverText"] = "ID ".. green .. id .. white .. " ("..green..vehicleName..white..") Statisztikái",
                    ["minLines"] = 1,
                    ["maxLines"] = 10,
                    ["texts"] = {},
                }
                table.insert(stats["texts"], {"Állapot: ", green..health..white.."/"..green.."1000"..white.." ("..green..math.floor(health/10).." %"..white..")"})
                table.insert(stats["texts"], {"Rotáció: ", text1})
                table.insert(stats["texts"], {"Megtett út: ", green..odometer..white.." KM"})
                table.insert(stats["texts"], {"Utolsó Olajcsere: ", green..lastOilRecoil..white.." KMnél"})
                table.insert(stats["texts"], {"Motor: ", engineColor..engineString})
                local maxFuel = exports['cr_vehicle']:getMaxFuel()
                table.insert(stats["texts"], {"Benzin: ", green..fuel..white.."/"..green..maxFuel[getElementModel(target)].." liter"})
                local ownerText = "@4 ("..green..ownerID..white..")"
                triggerServerEvent("receiveOwnerNameForStats.server", localPlayer, localPlayer, ownerText, ownerID, green, white)
            else
                local green = exports['cr_core']:getServerColor("orange", true)
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "Hibás jármű ID (ID: "..green..id..white..")", 255,255,255,true)
            end
        end
    end
end
addCommandHandler("getvehiclestats", getVehicleStats)

function getCharDetails(cmd, target)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if not target then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id]", 255, 0, 0, true)
            return
        end

        local target = exports.cr_core:findPlayer(localPlayer, target)

        if target then 
            if target:getData("loggedIn") then 
                local charDetails = target:getData("char >> details") or {}
                local syntax = exports.cr_core:getServerSyntax(false, "info")
                local hexColor = exports.cr_core:getServerColor("yellow", true)
                
                local localName = getAdminName(localPlayer, true)
                local targetName = getAdminName(target)
                local adminSyntax = getAdminSyntax()

                exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " lekérte " .. hexColor .. targetName .. white .. " karakter adatait.", 3)

                local data = {
                    hoverText = hexColor .. targetName .. white .. " karakter adatai",
                    minLines = 1,
                    maxLines = 10
                }
        
                local texts = {}

                for k, v in pairs(charDetails) do 
                    table.insert(texts, {k, hexColor .. v})
                end

                data.texts = texts
                exports.cr_dx:openInformationsPanel(data)
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255, 255, 255, true)
            end
        else
            noOnline()
        end
    end
end
addCommandHandler("getchardetails", getCharDetails, false, false)

function setCharDetail(cmd, target, detail, value)
    if exports.cr_permission:hasPermission(localPlayer, cmd) then 
        if not target or not detail or not value then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")

            outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id] [Adat] [Érték]", 255, 0, 0, true)
            return
        end

        local target = exports.cr_core:findPlayer(localPlayer, target)
        local detail = tostring(detail)
        local value = (detail == "born" or detail == "description") and tostring(value) or tonumber(value)

        if target then 
            if target:getData("loggedIn") then 
                local charDetails = target:getData("char >> details") or {}

                if not charDetails[detail] then 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "Nem létezik karakter adat az alábbi kulcsszó alatt.", 255, 0, 0, true)
                    return
                end

                if type(charDetails[detail]) ~= type(value) then 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "Hibás adattípus.", 255, 0, 0, true)
                    return
                end

                if detail == "nationality" then 
                    if value <= 0 or value > 4 then 
                        local syntax = exports.cr_core:getServerSyntax(false, "error")

                        outputChatBox(syntax .. "Ennél az adatnál a minimum érték 1, a maximum érték pedig 4.", 255, 0, 0, true)
                        return
                    end
                elseif detail == "neme" then
                    if value <= 0 or value > 2 then 
                        local syntax = exports.cr_core:getServerSyntax(false, "error")

                        outputChatBox(syntax .. "Ennél az adatnál a minimum érték 1, a maximum érték pedig 2.", 255, 0, 0, true)
                        return
                    end
                end

                local oldValue = charDetails[detail]

                if oldValue == value then 
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A régi érték nem lehet ugyanaz mint az új.", 255, 0, 0, true)
                    return
                end

                charDetails[detail] = value
                target:setData("char >> details", charDetails)

                local syntax = exports.cr_core:getServerSyntax(false, "success")
                local hexColor = exports.cr_core:getServerColor("yellow", true)

                local localName = getAdminName(localPlayer, true)
                local targetName = getAdminName(target)
                local adminSyntax = getAdminSyntax()

                outputChatBox(syntax .. "Sikeresen megváltoztattad " .. hexColor .. targetName .. white .. " karakter adatát.", 255, 0, 0, true)
                outputChatBox(syntax .. "Adat név: " .. hexColor .. detail .. white .. ", régi érték: " .. hexColor .. oldValue .. white .. ", új érték: " .. hexColor .. value, 255, 0, 0, true)

                exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " megváltoztatta " .. hexColor .. targetName .. white .. " játékos karakter adatát. Adat név: " .. hexColor .. detail .. white .. ", régi érték: " .. hexColor .. oldValue .. white .. ", új érték: " .. hexColor .. value, 3)
            else 
                local syntax = exports.cr_core:getServerSyntax(false, "error")

                outputChatBox(syntax .. "A játékos nincs bejelentkezve!", 255, 255, 255, true)
            end
        else
            noOnline()
        end
    end
end
addCommandHandler("setchardetail", setCharDetail, false, false)

addEvent("receiveOwnerNameForStats.client", true)
addEventHandler("receiveOwnerNameForStats.client", root,
    function(sourceE, text)
        if sourceE == localPlayer then
            table.insert(stats["texts"], {"Tulajdonos: ", text})
            exports['cr_dx']:openInformationsPanel(stats)
        end
    end
)

addEvent("killLogResult", true)
addEventHandler("killLogResult", root, 
    function(sourcePlayer, headerText, logs)
        if sourcePlayer == localPlayer then 
            local data = {
                ["hoverText"] = headerText,
                ["minLines"] = 1,
                ["maxLines"] = 10,
                ["texts"] = logs,
            }
            exports['cr_dx']:openInformationsPanel(data)
        end 
    end 
)