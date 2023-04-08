function playSoundServer(element, url)
    triggerClientEvent(element, "playSoundClient", element, element, url)
end
addEvent("playSoundServer", true)
addEventHandler("playSoundServer", root, playSoundServer)

function setElementArmor(element, armor)
    setPedArmor(element, tonumber(armor))
end
addEvent("setElementArmor", true)
addEventHandler("setElementArmor", root, setElementArmor)

function setPlayerAlpha(element, alpha)
    setElementAlpha(element, tonumber(alpha))
end
addEvent("setPlayerAlpha", true)
addEventHandler("setPlayerAlpha", root, setPlayerAlpha)

function setPlayerCol(element, types)
    setElementCollisionsEnabled(element, types)
end
addEvent("setPlayerCol", true)
addEventHandler("setPlayerCol", root, setPlayerCol)

function noOnline(sourcePlayer)
    if isElement(sourcePlayer) then 
        local syntax = exports['cr_core']:getServerSyntax(false, "error")
        outputChatBox(syntax.."Nincs ilyen játékos!", sourcePlayer, 255, 255, 255,true)
    end 
end

--[[
addEvent("glue_attach",true)
addEventHandler("glue_attach",root,
    function(e,x, y, z, rotX, rotY, rotZ)
        attachElements(source, e, x, y, z, rotX, rotY, rotZ)
    end
)

addEvent("glue_deatach",true)
addEventHandler("glue_deatach",root,
    function()
        detachElements(source)
    end
)
--]]

function toName(element, target, name)
	local color = exports['cr_core']:getServerColor('yellow', true)
	local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
	if exports["cr_account"]:getNames(target,name) then
		local syntax = exports['cr_core']:getServerSyntax(false, "success")
		outputChatBox(syntax.."Sikeresen megváltoztattad "..color..jatekosName.."#ffffff nevét!",element,255,255,255,true)
	else
		local syntax = exports['cr_core']:getServerSyntax(false, "error")
		outputChatBox(syntax.."#ffffffA karakter név már foglalt!",element,255,255,255,true)
	end
end
addEvent("toName",true)
addEventHandler("toName",root,toName)

-----|| PARANCSOK ||-----

function isPlayerKnow(sourcePlayer, cmd, target1, target2)
    if exports['cr_permission']:hasPermission(sourcePlayer, "isPlayerKnow") then
        if not target1 or not target2 then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff/"..cmd.." [Név/ID 1] [Név/ID 2]",sourcePlayer,0,0,0,true)
        else
            local target1 = exports['cr_core']:findPlayer(sourcePlayer, target1)
            local target2 = exports['cr_core']:findPlayer(sourcePlayer, target2)

            if target1 and target2 then
                if target1:getData("loggedIn") and target2:getData("loggedIn") then 
                    local friends1 = target1:getData("friends") or {}
                    local aName = getAdminName(target1)
                    local aName2 = getAdminName(target2)
                    local syntax = exports['cr_core']:getServerSyntax("Friend", "info")
                    if friends1[target2:getData("acc >> id")] then 
                        outputChatBox(syntax .. aName .. " ismeri " .. aName2 .. "-ot/et!", sourcePlayer, 255, 255, 255, true)
                    else 
                        outputChatBox(syntax .. aName .. " nem ismeri " .. aName2 .. "-ot/et!", sourcePlayer, 255, 255, 255, true)
                    end 
                else 
                    local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."A játékos nincs bejelentkezve!",sourcePlayer,0,0,0,true)
                end 
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."Nincs ilyen játékos!",sourcePlayer,0,0,0,true)
            end 
        end 
    end 
end 
addCommandHandler("isPlayerKnow", isPlayerKnow)
addCommandHandler("isplayerknow", isPlayerKnow)
addCommandHandler("isKnow", isPlayerKnow)
addCommandHandler("isknow", isPlayerKnow)

function freeze_sc(player, cmd, target)
    if exports['cr_permission']:hasPermission(player, "freeze") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Admin ID/Név]",player,0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(player, target)
            if target then
                local color = exports['cr_core']:getServerColor('yellow', true)
                local adminName = getAdminName(player, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")

                local veh = getPedOccupiedVehicle(target)
                if (veh) then
                    setElementFrozen(veh, true)
                    toggleAllControls(target, false, true, false)
                    setElementData(target, "freeze", true)
                    outputChatBox(color..adminName.."#ffffff lefagysztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen lefagyasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                else
                    setElementFrozen(target, true)
                    setPedWeaponSlot(target, 0)
                    setElementData(target, "freeze", true)
                    outputChatBox(color..adminName.."#ffffff lefagysztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen lefagyasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."#ffffffNincs ilyen játékos!",player,0,0,0,true)
            end
        end
    end
end
addCommandHandler("freeze", freeze_sc)

function unfreeze_sc(player, cmd, target)
    if exports['cr_permission']:hasPermission(player, "unfreeze") then
        if not (target) then
            local syntax = exports['cr_core']:getServerSyntax(false, "warning")
            outputChatBox(syntax.."#ffffff /"..cmd.." [Admin ID/Név]",player,0,0,0,true)
        else
            local target = exports['cr_core']:findPlayer(player, target)
            if target then
                local adminName = getAdminName(player, true)
                local jatekosName = getElementData(target,"char >> name"):gsub("_"," ")
                local color = exports['cr_core']:getServerColor('yellow', true)
                local veh = getPedOccupiedVehicle(target)
                if (veh) then
                    setElementFrozen(veh, false)
                    toggleAllControls(target, true, true, true)
                    setElementData(target, "freeze", false)
                    outputChatBox(color..adminName.."#ffffff felolvasztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen felolvasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                else
                    setElementFrozen(target, false)
                    setElementData(target, "freeze", false)
                    outputChatBox(color..adminName.."#ffffff felolvasztott!", target, 255, 255, 255, true)
                    outputChatBox("#ffffffSikeresen felolvasztottad "..color..jatekosName.."#ffffff játékost!", player, 255, 255, 255, true)
                end
            else
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax.."#ffffffNincs ilyen játékos!",player,0,0,0,true)
            end
        end
    end
end
addCommandHandler("unfreeze", unfreeze_sc)

local killLogs = {}
local deathLogs = {}
local playerKillLogs = {}
local playerDeathLogs = {}
local maxLogs = 250

function killLog(sourcePlayer, attacker, text)
    if isElement(attacker) and attacker:getData("acc >> id") and attacker:getData("loggedIn") then 
        local logs = killLogs
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        table.insert(logs, 1, text)
    end 

    if isElement(sourcePlayer) and sourcePlayer:getData("acc >> id") and sourcePlayer:getData("loggedIn") then 
        local logs = deathLogs
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        table.insert(logs, 1, text)
    end 

    if isElement(attacker) and attacker:getData("acc >> id") and attacker:getData("loggedIn") then 
        if not playerKillLogs[attacker:getData("acc >> id")] then 
            playerKillLogs[attacker:getData("acc >> id")] = {}
        end
        local logs = playerKillLogs[attacker:getData("acc >> id")]
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        table.insert(logs, 1, text)
    end 

    if isElement(sourcePlayer) and sourcePlayer:getData("acc >> id") and sourcePlayer:getData("loggedIn") then 
        if not playerDeathLogs[sourcePlayer:getData("acc >> id")] then 
            playerDeathLogs[sourcePlayer:getData("acc >> id")] = {}
        end 
        local logs = playerDeathLogs[sourcePlayer:getData("acc >> id")]
        if #logs + 1 > maxLogs then 
            table.remove(logs, #logs)
        end 

        table.insert(logs, 1, text)
    end 
end 
addEvent("killLog", true)
addEventHandler("killLog", root, killLog)

function getKillLog(sourcePlayer, cmd, target)
    if exports['cr_permission']:hasPermission(sourcePlayer, "getkilllog") then
        if target then 
            local target = exports['cr_core']:findPlayer(sourcePlayer, target)
            if not target then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nem található.", sourcePlayer, 255, 255, 255, true)
                return
            end

            if target:getData("loggedIn") then 
                if not playerKillLogs[target:getData("acc >> id")] or #playerKillLogs[target:getData("acc >> id")] <= 0 then 
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "A játékos még nem követett el gyilkosságot!", sourcePlayer, 255, 255, 255, true)
                    return 
                end 

                local blue = exports['cr_core']:getServerColor('yellow', true)
                local white = "#ffffff"
                local gray = "#f2f2f2"
                local playerName = getAdminName(target)
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen lekérdezted ".. blue .. playerName .. white .. " killlogjait!", sourcePlayer, 255, 255, 255, true)

                local headerText = blue .. playerName .. gray .. " (#" .. blue .. target:getData("acc >> id") .. gray .. ") ölés logok:"

                triggerLatentClientEvent(sourcePlayer, "killLogResult", 50000, false, sourcePlayer, sourcePlayer, headerText, playerKillLogs[target:getData("acc >> id")])
            else
                noOnline(sourcePlayer) 
            end 
        else 
            if not killLogs or #killLogs <= 0 then 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "A szerveren még nem történt gyilkosság!", sourcePlayer, 255, 255, 255, true)
                return 
            end 

            local blue = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"
            local gray = "#f2f2f2"
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Sikeresen lekérdezted a " .. blue .. "szerver" .. white .. " killlogjait!", sourcePlayer, 255, 255, 255, true)

            local headerText = blue .. "Szerver" .. gray .. " ölés logok:"

            triggerLatentClientEvent(sourcePlayer, "killLogResult", 50000, false, sourcePlayer, sourcePlayer, headerText, killLogs)
        end 
    end 
end 
addCommandHandler("getkilllog",getKillLog)
addCommandHandler("killlog",getKillLog)

function getDeathLog(sourcePlayer, cmd, target)
    if exports['cr_permission']:hasPermission(sourcePlayer, "getdeathlog") then
        if target then 
            local target = exports['cr_core']:findPlayer(sourcePlayer, target)
            if not target then
                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                outputChatBox(syntax .. "A játékos nem található.", sourcePlayer, 255, 255, 255, true)
                return
            end

            if target:getData("loggedIn") then 
                if not playerDeathLogs[target:getData("acc >> id")] or #playerDeathLogs[target:getData("acc >> id")] <= 0 then 
                    local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                    outputChatBox(syntax .. "A játékos még nem halt meg egyszer sem!", sourcePlayer, 255, 255, 255, true)
                    return 
                end 

                local blue = exports['cr_core']:getServerColor('yellow', true)
                local white = "#ffffff"
                local gray = "#f2f2f2"
                local playerName = getAdminName(target)
                local syntax = exports['cr_core']:getServerSyntax(nil, "success")
                outputChatBox(syntax .. "Sikeresen lekérdezted ".. blue .. playerName .. white .. " deathlogjait!", sourcePlayer, 255, 255, 255, true)

                local headerText = blue .. playerName .. gray .. " (#" .. blue .. target:getData("acc >> id") .. gray .. ") halál logok:"

                triggerLatentClientEvent(sourcePlayer, "killLogResult", 50000, false, sourcePlayer, sourcePlayer, headerText, playerDeathLogs[target:getData("acc >> id")])
            else
                noOnline(sourcePlayer) 
            end 
        else 
            if not deathLogs or #deathLogs <= 0 then 
                local syntax = exports['cr_core']:getServerSyntax(nil, "error")
                outputChatBox(syntax .. "A szerveren még nem történt halál!", sourcePlayer, 255, 255, 255, true)
                return 
            end 

            local blue = exports['cr_core']:getServerColor('yellow', true)
            local white = "#ffffff"
            local gray = "#f2f2f2"
            local syntax = exports['cr_core']:getServerSyntax(nil, "success")
            outputChatBox(syntax .. "Sikeresen lekérdezted a " .. blue .. "szerver" .. white .. " deathlogjait!", sourcePlayer, 255, 255, 255, true)

            local headerText = blue .. "Szerver" .. gray .. " halál logok:"

            triggerLatentClientEvent(sourcePlayer, "killLogResult", 50000, false, sourcePlayer, sourcePlayer, headerText, deathLogs)
        end 
    end 
end 
addCommandHandler("getdeathlog",getDeathLog)
addCommandHandler("deathlog",getDeathLog)

addEvent("handleSound", true)
addEventHandler("handleSound", root,
    function(filePath)
        triggerLatentClientEvent(root, "handleSound", 50000, false, getRandomPlayer(), filePath)
    end
)

addEventHandler("onPlayerChangeNick", root,
    function()
        if source:getData("loggedIn") then 
            cancelEvent()
        end
    end
)