local screenX, screenY = guiGetScreenSize()

function govAnnouncement(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        if not ... then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")
            
            outputChatBox(syntax .. "/" .. cmd.. " [szöveg]", 255, 0, 0, true)
            return
        end

        local message = table.concat({...}, " ")
        local dutyFaction = localPlayer:getData("char >> duty")

        if dutyFaction then 
            if exports.cr_dashboard:isPlayerFactionLeader(localPlayer, dutyFaction) then 
                local factionName = exports.cr_dashboard:getFactionName(dutyFaction)
                local redHex = exports.cr_core:getServerColor("red", true)
                local yellowHex = exports.cr_core:getServerColor("yellow", true)

                if factionName then 
                    local adminSyntax = exports.cr_admin:getAdminSyntax()
                    local name = exports.cr_admin:getAdminName(localPlayer)

                    exports.cr_core:sendMessageToAdmin(localPlayer, redHex .. "=-=-=-=-=-=-=-=-=-=-[" .. factionName .. "]-=-=-=-=-=-=-=-=-=-=", 0)
                    exports.cr_core:sendMessageToAdmin(localPlayer, white .. ">>> " .. exports.cr_chat:findSwear(message), 0)

                    exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. yellowHex .. name .. white .. " használta a " .. yellowHex .. "/gov " .. white .. "parancsot.", 3)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")
            
                outputChatBox(syntax .. "Nincs jogosultságod használni a parancsot.", 255, 0, 0, true)
            end
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")
            
            outputChatBox(syntax .. "Nem vagy szolgálatban.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("gov", govAnnouncement, false, false)

function giveBadge(cmd, factionId, ...)
    if localPlayer:getData("loggedIn") then 
        if factionId and tonumber(factionId) then 
            if hasPlayerPermission(localPlayer, cmd, true) then 
                if not ... then 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                    outputChatBox(syntax.."/"..cmd.." [frakció id] [tartalom]", 255, 0, 0, true)
                    return
                else
                    local factionId = tonumber(factionId)
                    local content = table.concat({...}, " ")
                    local yellowHex = exports["cr_core"]:getServerColor("orangeNew", true)

                    factionId = math.floor(factionId)
                    
                    if factionId > 0 then 
                        if factionPrefixes[factionId] and factionPrefixes[factionId]["badgePrefix"] then 
                            local badgeContent = yellowHex.."("..getFactionPrefix(factionId).." "..content..")"

                            exports["cr_inventory"]:giveItem(localPlayer, 36, 1, 1, 100, 0, 0, {["badgeContent"] = badgeContent})

                            local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                            local serverHex = exports["cr_core"]:getServerColor("yellow", true)
                            outputChatBox(syntax.."Sikeresen létrehoztál egy jelvényt. "..serverHex.."("..badgeContent:gsub("#%x%x%x%x%x%x", "")..")", 255, 0, 0, true)
                            
                            exports["cr_core"]:sendMessageToAdmin(localPlayer, exports["cr_admin"]:getAdminSyntax()..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff létrehozott egy jelvényt. "..serverHex..badgeContent:gsub("#%x%x%x%x%x%x", ""), 3)
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                            return outputChatBox(syntax.."A kiválasztott frakciónak nincs beállítva jelvény prefix.", 255, 0, 0, true)
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                        return outputChatBox(syntax.."A frakció id-nek nagyobbnak kell lennie mint 0.", 255, 0, 0, true)
                    end
                end
            end
        else 
            local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
            return outputChatBox(syntax.."/"..cmd.." [frakció id] [tartalom]", 255, 0, 0, true)
        end
    end
end
addCommandHandler("createbadge", giveBadge, false, false)

function unFlipVehicle(cmd, target)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            if not target then 
                local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                return outputChatBox(syntax.."/"..cmd.." [id]", 255, 0, 0, true)
            else 
                local target = exports["cr_core"]:findPlayer(localPlayer, target)

                if target then 
                    if target:getData("loggedIn") then 
                        local vehicle = getNearbyVehicle(525, 5)

                        if vehicle then 
                            local occupiedVehicle = localPlayer.vehicle 

                            if occupiedVehicle ~= vehicle then 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "success")
                                local serverHex = exports["cr_core"]:getServerColor("blue", true)
                                local id = occupiedVehicle:getData("veh >> id")

                                outputChatBox(syntax.."Sikeresen visszaborítottad a járművet. "..serverHex.."("..id..")", 255, 0, 0, true)

                                triggerLatentServerEvent("factionscripts.unFlip", 5000, false, localPlayer, occupiedVehicle)
                            else 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                                return outputChatBox(syntax.."A saját járművedet nem boríthatod vissza.", 255, 0, 0, true)
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                            return outputChatBox(syntax.."Nem található vontató 5 yardos körzetben.", 255, 0, 0, true)
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                        return outputChatBox(syntax.."A játékos nincs bejelentkezve.", 255, 0, 0, true)
                    end
                else 
                    local syntax = exports["cr_core"]:getServerSyntax(false, "error")
                    return outputChatBox(syntax.."A játékos nem található.", 255, 0, 0, true)
                end
            end
        end
    end
end
addCommandHandler("unflipmechanic", unFlipVehicle, false, false)

function giveHealthCard(cmd, target)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd, "medic.giveHealthCard") then 
            if not target then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id]", 255, 0, 0, true)
                return
            end

            local target = exports.cr_core:findPlayer(localPlayer, target)

            if target then 
                if target:getData("loggedIn") then 
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, target.position)

                    if distance > 3 then 
                        local syntax = exports.cr_core:getServerSyntax("Health Card", "error")

                        outputChatBox(syntax .. "Túl messze vagy a játékostól.", 255, 0, 0, true)
                        return
                    end

                    local syntax = exports.cr_core:getServerSyntax("Health Card", "success")
                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                    local adminSyntax = exports.cr_admin:getAdminSyntax()
                    local localName = exports.cr_admin:getAdminName(localPlayer)
                    local targetName = exports.cr_admin:getAdminName(target)
                    
                    outputChatBox(syntax .. "Sikeresen adtál egy egészségügyi kártyát " .. hexColor .. targetName .. white .. " játékosnak.", 255, 0, 0, true)

                    exports.cr_inventory:giveItem(target, 148, 1, 1)
                    exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " adott egy egészségügyi kártyát " .. hexColor .. targetName .. white .. " játékosnak.", 3)
                    triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, 2, hexColor .. localName .. white .. " adott egy egészségügyi kártyát " .. hexColor .. targetName .. white .. " játékosnak.")
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A játékos nincs bejelentkezve.", 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")  

                outputChatBox(syntax .. "Nem található a játékos.", 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("givehealthcard", giveHealthCard, false, false)

function giveGovCard(cmd, target)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd, "gov.giveGovCard") then 
            if not target then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id]", 255, 0, 0, true)
                return
            end

            local target = exports.cr_core:findPlayer(localPlayer, target)

            if target then 
                if target:getData("loggedIn") then 
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, target.position)

                    if distance > 3 then 
                        local syntax = exports.cr_core:getServerSyntax("Gov Card", "error")

                        outputChatBox(syntax .. "Túl messze vagy a játékostól.", 255, 0, 0, true)
                        return
                    end

                    local syntax = exports.cr_core:getServerSyntax("Gov Card", "success")
                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                    local adminSyntax = exports.cr_admin:getAdminSyntax()
                    local localName = exports.cr_admin:getAdminName(localPlayer)
                    local targetName = exports.cr_admin:getAdminName(target)
                    
                    outputChatBox(syntax .. "Sikeresen adtál egy önkormányzati azonosítót " .. hexColor .. targetName .. white .. " játékosnak.", 255, 0, 0, true)

                    exports.cr_inventory:giveItem(target, 149, 1, 1)
                    exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " adott egy önkormányzati azonosítót " .. hexColor .. targetName .. white .. " játékosnak.", 3)
                    triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, 4, hexColor .. localName .. white .. " adott egy önkormányzati azonosítót " .. hexColor .. targetName .. white .. " játékosnak.")
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A játékos nincs bejelentkezve.", 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")  

                outputChatBox(syntax .. "Nem található a játékos.", 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("givegovcard", giveGovCard, false, false)

function giveLicense(cmd, target, typ)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd, "gov.giveLicense") then 
            if not target then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [Névrészlet / id] [típus | 1 = horgász engedély, 2 = vadász engedély]", 255, 0, 0, true)
                return
            end

            local target = exports.cr_core:findPlayer(localPlayer, target)
            local typ = tonumber(typ)

            if target then 
                if target:getData("loggedIn") then 
                    local distance = getDistanceBetweenPoints3D(localPlayer.position, target.position)

                    if distance > 3 then 
                        local syntax = exports.cr_core:getServerSyntax("License", "error")

                        outputChatBox(syntax .. "Túl messze vagy a játékostól.", 255, 0, 0, true)
                        return
                    end

                    if not typ then 
                        local syntax = exports.cr_core:getServerSyntax("License", "error")

                        outputChatBox(syntax .. "Hibás típus.", 255, 0, 0, true)
                        return
                    end

                    local typ = math.floor(tonumber(typ))

                    if typ == 1 then 
                        local syntax = exports.cr_core:getServerSyntax("License", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(localPlayer)
                        local targetName = exports.cr_admin:getAdminName(target)
                        
                        outputChatBox(syntax .. "Sikeresen adtál egy horgász engedélyt " .. hexColor .. targetName .. white .. " játékosnak.", 255, 0, 0, true)

                        exports.cr_inventory:giveItem(target, 28, 1, 1)
                        exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " adott egy horgász engedélyt " .. hexColor .. targetName .. white .. " játékosnak.", 3)
                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, 4, hexColor .. localName .. white .. " adott egy horgász engedélyt " .. hexColor .. targetName .. white .. " játékosnak.")
                    elseif typ == 2 then
                        local syntax = exports.cr_core:getServerSyntax("License", "success")
                        local hexColor = exports.cr_core:getServerColor("yellow", true)

                        local adminSyntax = exports.cr_admin:getAdminSyntax()
                        local localName = exports.cr_admin:getAdminName(localPlayer)
                        local targetName = exports.cr_admin:getAdminName(target)
                        
                        outputChatBox(syntax .. "Sikeresen adtál egy vadász engedélyt " .. hexColor .. targetName .. white .. " játékosnak.", 255, 0, 0, true)

                        exports.cr_inventory:giveItem(target, 82, 1, 1)
                        exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " adott egy vadász engedélyt " .. hexColor .. targetName .. white .. " játékosnak.", 3)
                        triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, 4, hexColor .. localName .. white .. " adott egy vadász engedélyt " .. hexColor .. targetName .. white .. " játékosnak.")
                    else
                        local syntax = exports.cr_core:getServerSyntax("License", "error")
                        outputChatBox(syntax .. "Hibás engedély.", 255, 0, 0, true)
                    end
                else
                    local syntax = exports.cr_core:getServerSyntax(false, "error")

                    outputChatBox(syntax .. "A játékos nincs bejelentkezve.", 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax(false, "error")  

                outputChatBox(syntax .. "Nem található a játékos.", 255, 0, 0, true)
            end
        end
    end
end
addCommandHandler("givelicense", giveLicense, false, false)

function changeVehicleLock(cmd, vehicle)
    if hasPlayerPermission(localPlayer, "changelock", "faction.changelock") then 
        if cmd then 
            vehicle = localPlayer.vehicle
        end

        if isElement(vehicle) then 
            local dutyFaction = localPlayer:getData("char >> duty")

            if dutyFaction then 
                local vehFaction = vehicle:getData("veh >> faction")
                local vehId = vehicle:getData("veh >> id")

                if vehFaction == dutyFaction then 
                    exports.cr_inventory:giveItem(localPlayer, 16, vehId)

                    local syntax = exports.cr_core:getServerSyntax("Changelock", "success")
                    local hexColor = exports.cr_core:getServerColor("yellow", true)

                    outputChatBox(syntax .. "Sikeresen lemásoltad a jármű kulcsát. " .. hexColor .. "(" .. vehId .. ")", 255, 0, 0, true)

                    local adminSyntax = exports.cr_admin:getAdminSyntax()
                    local localName = exports.cr_admin:getAdminName(localPlayer)

                    exports.cr_core:sendMessageToAdmin(localPlayer, adminSyntax .. hexColor .. localName .. white .. " kulcsot adott egy frakció járműhöz. " .. hexColor .. "(" .. vehId .. ")", 8)
                    exports.cr_logs:addLog(localPlayer, "Factionscripts", "changelock", localName .. " kulcsot adott egy frakció járműhöz. (" .. vehId .. ")")

                    triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, vehFaction, hexColor .. localName .. white .. " kulcsot adott egy frakció járműhöz. " .. hexColor .. "(" .. vehId .. ")")
                else
                    local syntax = exports.cr_core:getServerSyntax("Changelock", "error")
                    outputChatBox(syntax .. "Ennek a járműnek nem tudod lemásolni a kulcsát.", 255, 0, 0, true)
                end
            else
                local syntax = exports.cr_core:getServerSyntax("Changelock", "error")
                outputChatBox(syntax .. "Ezt a parancsot csak szolgálatban lehet használni.", 255, 0, 0, true)
            end
        else
            local syntax = exports.cr_core:getServerSyntax("Changelock", "error")
            outputChatBox(syntax .. "Nem ülsz járműben.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("changelock", changeVehicleLock, false, false)