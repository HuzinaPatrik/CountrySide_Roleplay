function createCellDoors()
    for key, value in pairs(jailDatas["cellDoors"]) do 
        local objectId, x, y, z, rot, interior, dimension = unpack(value)

        local object = Object(objectId, x, y, z, 0, 0, rot)
        object:setData("jail >> cell", true)
        object:setData("jail >> id", key)

        object.frozen = true
        object.interior = interior 
        object.dimension = dimension
    end

    if localPlayer:getData("jail >> data") then 
        jailPlayer()
    end
end
addEventHandler("onClientResourceStart", resourceRoot, createCellDoors)

local jailTimer = false

function arrestPlayer(cmd, target, min, ticket, ...)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            if not target or not min or not ticket or not ... then 
                local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                return outputChatBox(syntax.."/"..cmd.." [id / név] [perc] [bírság] [indok]", 255, 0, 0, true)
            else 
                local target = exports["cr_core"]:findPlayer(localPlayer, target)
                local min = tonumber(min)
                local ticket = tonumber(ticket)
                local reason = table.concat({...}, " ")
                
                if target then 
                    if target:getData("loggedIn") then 
                        if getDistanceBetweenPoints3D(localPlayer.position, target.position) <= 2 then 
                            if min ~= nil and ticket ~= nil then 
                                if reason:len() > 0 then 
                                    if not target:getData("jail >> data") then 
                                        if min <= 300 then 
                                            if ticket <= 10000 then 
                                                local cell = getClosestCell(2)

                                                if cell and isElement(cell) or getDistanceBetweenPoints3D(localPlayer.position, Vector3(267.29153442383, 77.571281433105, 1001.0390625)) <= 2 then 
                                                    local syntax = exports["cr_core"]:getServerSyntax(false, "green")
                                                    local syntax2 = exports["cr_core"]:getServerSyntax("Jail", "red")
                                                    local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                                                    if target:getData("char >> follow") then 
                                                        target:setData("char >> follow", nil)
                                                    end

                                                    outputChatBox(syntax.."Sikeresen őrizetbe vetted "..serverHex..exports["cr_admin"]:getAdminName(target).."#ffffff játékost.", 255, 0, 0, true)
                                                    exports["cr_dashboard"]:sendMessageToFaction(2, syntax2..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff őrizetbe vette "..serverHex..exports["cr_admin"]:getAdminName(target).."#ffffff játékost.")
                                                    exports["cr_dashboard"]:sendMessageToFaction(2, syntax2..serverHex.."Idő:#ffffff "..min.."#ffffff perc.")

                                                    if ticket > 0 then 
                                                        exports["cr_dashboard"]:sendMessageToFaction(2, syntax2..serverHex.."Bírság:#ffffff "..ticket.."#ffffff dollár.")
                                                        exports["cr_core"]:takeMoney(target, ticket, nil, true)
                                                    end

                                                    exports["cr_dashboard"]:sendMessageToFaction(2, syntax2..serverHex.."Indok:#ffffff "..reason)

                                                    target:setData("jail >> data", {exports["cr_admin"]:getAdminName(localPlayer), min, ticket, reason, localPlayer:getData("acc >> id")})

                                                    triggerLatentServerEvent("faction.arrestPlayer", 5000, false, localPlayer, localPlayer, target, math.floor(min), math.floor(ticket), reason, (not cell and 3 or tonumber(cell:getData("jail >> id"))))
                                                    triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, 1, serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff őrizetbe vette "..serverHex..exports["cr_admin"]:getAdminName(target).."#ffffff játékost. Idő: "..serverHex..min.."#ffffff perc.")
                                                else 
                                                    local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                                    return outputChatBox(syntax.."Nincs a közeledben cella.", 255, 0, 0, true)
                                                end
                                            else 
                                                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                                return outputChatBox(syntax.."Maximum 10.000 dollárra büntethetsz.", 255, 0, 0, true)
                                            end
                                        else 
                                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                            return outputChatBox(syntax.."Maximum 300 percre börtönözhetsz.", 255, 0, 0, true)
                                        end
                                    else 
                                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                        return outputChatBox(syntax.."A kiválasztott személy már börtönben van.", 255, 0, 0, true)
                                    end
                                else 
                                    local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                    return outputChatBox(syntax.."Az indoknak legalább 1 karakter hosszúnak kell lennie.", 255, 0, 0, true)
                                end
                            else 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                return outputChatBox(syntax.."Csak szám.", 255, 0, 0, true)
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            return outputChatBox(syntax.."A kiválasztott személy túl messze van tőled.", 255, 0, 0, true)
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        return outputChatBox(syntax.."A játékos nincs bejelentkezve.", 255, 0, 0, true)
                    end
                end
            end
        end
    end
end
addCommandHandler("arrest", arrestPlayer, false, false)
addCommandHandler("jail", arrestPlayer, false, false)

function releasePlayer(cmd, target)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) or exports["cr_permission"]:hasPermission(localPlayer, "forceRelease") then 
            if not target then 
                local syntax = exports["cr_core"]:getServerSyntax(false, "lightyellow")
                return outputChatBox(syntax.."/"..cmd.." [id / név]", 255, 0, 0, true)
            else 
                local target = exports["cr_core"]:findPlayer(localPlayer, target)

                if target then 
                    if target:getData("loggedIn") then 
                        if getDistanceBetweenPoints3D(localPlayer.position, target.position) <= 2 then 
                            if target:getData("jail >> data") then 
                                local data = target:getData("jail >> data")
                                local syntax = exports["cr_core"]:getServerSyntax("Jail", "green")
                                local syntax2 = exports["cr_core"]:getServerSyntax("Jail", "red")
                                local serverHex = exports["cr_core"]:getServerColor("yellow", true)

                                if data then 
                                    if data[5] then 
                                        if tonumber(data[5]) == tonumber(localPlayer:getData("acc >> id")) or exports["cr_permission"]:hasPermission(localPlayer, "forceRelease") then 
                                            outputChatBox(syntax.."Sikeresen kivetted "..serverHex..exports["cr_admin"]:getAdminName(target).."#ffffff játékost a börtönből.", 255, 0, 0, true)
                                            exports["cr_dashboard"]:sendMessageToFaction(2, syntax2..serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff kivette "..serverHex..exports["cr_admin"]:getAdminName(target).."#ffffff játékost a börtönből.")

                                            triggerLatentServerEvent("faction.releasePlayer", 5000, false, localPlayer, target)
                                            triggerLatentServerEvent("addFactionLog", 5000, false, localPlayer, 1, serverHex..exports["cr_admin"]:getAdminName(localPlayer).."#ffffff kivette "..serverHex..exports["cr_admin"]:getAdminName(target).."#ffffff játékost a börtönből.")
                                        else 
                                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                            return outputChatBox(syntax.."Nem te raktad be a játékost.", 255, 0, 0, true)
                                        end
                                    end
                                end
                            else 
                                local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                                return outputChatBox(syntax.."A játékos nincs letartóztatva.", 255, 0, 0, true)
                            end
                        else 
                            local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                            return outputChatBox(syntax.."A kiválasztott személy túl messze van tőled.", 255, 0, 0, true)
                        end
                    else 
                        local syntax = exports["cr_core"]:getServerSyntax(false, "red")
                        return outputChatBox(syntax.."A játékos nincs bejelentkezve.", 255, 0, 0, true)
                    end
                end
            end
        end
    end
end
addCommandHandler("release", releasePlayer, false, false)

function prisonersCommand(cmd)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) then 
            local players = getElementsByType("player")
            local syntax = exports.cr_core:getServerSyntax("Prisoners", "info")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            local data = {
                hoverText = "Letartóztatott játékosok",
                minLines = 1,
                maxLines = 10
            }

            local texts = {}

            local count = 0
            for i = 1, #players do 
                local v = players[i]
                local jailData = v:getData("jail >> data")

                if jailData then 
                    local name = exports.cr_admin:getAdminName(v)
                    local arrestedBy = jailData[1]
                    local minutes = jailData[2]
                    local ticket = jailData[3]
                    local reason = jailData[4]

                    if ticket > 0 then
                        table.insert(texts, {name .. white .. " (" .. hexColor .. minutes .. white .. " perc, általa: " .. hexColor .. arrestedBy .. white .. ", bírság: " .. hexColor .. "$" .. ticket .. white ..")", "Indok: " .. hexColor .. reason})
                    else
                        table.insert(texts, {name .. white .. " (" .. hexColor .. minutes .. white .. " perc, általa: " .. hexColor .. arrestedBy .. white .. ")", "Indok: " .. hexColor .. reason})
                    end

                    count = count + 1
                end
            end

            if count <= 0 then 
                local syntax = exports.cr_core:getServerSyntax("Prisoners", "error")

                outputChatBox(syntax .. "Nincs egy játékos sem letartóztatva!", 255, 0, 0, true)
                return
            end

            data.texts = texts 
            exports.cr_dx:openInformationsPanel(data)
        end
    end
end
addCommandHandler("prisoners", prisonersCommand, false, false)

function getJailTime(cmd)
    if localPlayer:getData("loggedIn") then 
        if localPlayer:getData("jail >> data") then 
            local jailData = localPlayer:getData("jail >> data") or {}

            local syntax = exports.cr_core:getServerSyntax("Jail", "red")
            local hexColor = exports.cr_core:getServerColor("yellow", true)

            outputChatBox(syntax .. "Hátralévő börtönidő: " .. hexColor .. jailData[2] .. white .. " perc.", 255, 0, 0, true)
            outputChatBox(syntax .. "Börtönbe rakott: " .. hexColor .. jailData[1], 255, 0, 0, true)
            outputChatBox(syntax .. "Indok: " .. hexColor .. jailData[4], 255, 0, 0, true)
        end
    end
end
addCommandHandler("börtönidő", getJailTime, false, false)
addCommandHandler("bortonido", getJailTime, false, false)
addCommandHandler("jailtime", getJailTime, false, false)
addCommandHandler("getjailtime", getJailTime, false, false)

function jailPlayer()
    if isTimer(jailTimer) then 
        killTimer(jailTimer)
    end

    jailTimer = setTimer(
        function()
            local data = localPlayer:getData("jail >> data")

            if data then 
                local minutes = tonumber(data[2])
                
                if localPlayer:getData("char >> afk") then
                    return
                end
                
                minutes = minutes - 1
                localPlayer:setData("jail >> data", {data[1], minutes, data[3], data[4], data[5]})
                
                if minutes <= 0 then
                    triggerLatentServerEvent("faction.releasePlayer", 5000, false, localPlayer, localPlayer)

                    if isTimer(jailTimer) then
                        killTimer(jailTimer)
                    end
                end
            end
        end, 60000, 0
    )
end
addEvent("faction.startJailTimer", true)
addEventHandler("faction.startJailTimer", root, jailPlayer)

function destroyJailTimer()
    if isTimer(jailTimer) then 
        killTimer(jailTimer)
    end
end
addEvent("faction.destroyJailTimer", true)
addEventHandler("faction.destroyJailTimer", root, destroyJailTimer)