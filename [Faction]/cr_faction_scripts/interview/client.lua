local canSeeInterviewMessages = true

local function onClientStart()
    if fileExists("@interviewSave.txt") then 
        local file = fileOpen("@interviewSave.txt")

        if file then 
            local count = fileGetSize(file)
            local data = fileRead(file, count)

            if data then 
                canSeeInterviewMessages = data == "true"
            end

            fileClose(file)
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

local function onClientStop()
    if fileExists("@interviewSave.txt") then 
        fileDelete("@interviewSave.txt")
    end

    local file = fileCreate("@interviewSave.txt")
    fileWrite(file, tostring(canSeeInterviewMessages))
    fileFlush(file)
    fileClose(file)
end
addEventHandler("onClientResourceStop", resourceRoot, onClientStop)

function speakInInterview(cmd, ...)
    if localPlayer:getData("loggedIn") then 
        if hasPlayerPermission(localPlayer, cmd) or localPlayer:getData("inInterview") then 
            if not ... then 
                local syntax = exports.cr_core:getServerSyntax(false, "yellow")

                outputChatBox(syntax .. "/" .. cmd .. " [szöveg]", 255, 0, 0, true)
                return
            end

            local message = table.concat({...}, " ")

            if utf8.len(message) <= 0 then 
                local syntax = exports.cr_core:getServerSyntax("Interview", "error")

                outputChatBox(syntax .. "A szöveg túl rövid.", 255, 0, 0, true)
                return
            end

            local prefix = "Híradós"

            if localPlayer:getData("inInterview") then 
                prefix = "Vendég"
            end

            local localName = exports.cr_admin:getAdminName(localPlayer)
            local syntax = "#B266FF[Híradó]: " .. prefix .. " " .. localName .. ": " .. message

            if canSeeInterviewMessages then 
                exports.cr_core:sendMessageToAdmin(localPlayer, syntax, 0)
            end
        end
    end
end
addCommandHandler("i", speakInInterview, false, false)

function toggleInterviewMessages()
    if localPlayer:getData("loggedIn") then 
        canSeeInterviewMessages = not canSeeInterviewMessages

        if canSeeInterviewMessages then 
            local syntax = exports.cr_core:getServerSyntax(false, "success")

            outputChatBox(syntax .. "Sikeresen bekapcsoltad az interjú üzenetek megjelenítését.", 255, 0, 0, true)
        else
            local syntax = exports.cr_core:getServerSyntax(false, "error")

            outputChatBox(syntax .. "Sikeresen kikapcsoltad az interjú üzenetek megjelenítését.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("toginterview", toggleInterviewMessages, false, false)