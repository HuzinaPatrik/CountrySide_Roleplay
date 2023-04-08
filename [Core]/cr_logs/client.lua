function addLog(sourceElement, saveType, type, text)
    triggerServerEvent("addLog", localPlayer, sourceElement, saveType, type, text)
    return true
end

function createLog(sourceElement, saveType, type, text)
    triggerServerEvent("createLog", localPlayer, sourceElement, saveType, type, text)
    return true
end

function clearLog(type)
    triggerServerEvent("clearLog", localPlayer, type)
    return true
end

function deleteLog(type)
    triggerServerEvent("deleteLog", localPlayer, type)
    return true
end

function getLogType(tbl, text)
    local data = {
        hoverText = text,
        minLines = 1,
        maxLines = 10
    }

    data.texts = tbl
    exports.cr_dx:openInformationsPanel(data)
end
addEvent("logs.getLogType", true)
addEventHandler("logs.getLogType", root, getLogType)