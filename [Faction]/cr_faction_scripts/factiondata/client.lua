local lastUse = 0
local lastDataUse = 0

function getLegalFactionsCommand(cmd)
    if hasPlayerPermission(localPlayer, cmd, "gov.getFactionData") then 
        if getTickCount() - lastUse >= 1000 then 
            triggerLatentServerEvent("getLegalFactionsHandler", 5000, false, localPlayer)
            lastUse = getTickCount()
        end
    end
end
addCommandHandler("getlegalfactions", getLegalFactionsCommand, false, false)

function getFactionDataCommand(cmd, id)
    if hasPlayerPermission(localPlayer, cmd, "gov.getFactionData") then 
        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "yellow")
            
            outputChatBox(syntax .. "/" .. cmd .. " [frakció id]", 255, 0, 0, true)
            return
        end

        local id = tonumber(id)

        if not id then 
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Csak szám.", 255, 0, 0, true)
            return
        end

        id = math.floor(tonumber(id))

        if getTickCount() - lastDataUse >= 1000 then 
            triggerLatentServerEvent("getFactionDataHandler", 5000, false, localPlayer, cmd, id)
            lastDataUse = getTickCount()
        end
    end
end
addCommandHandler("getfactiondata", getFactionDataCommand, false, false)