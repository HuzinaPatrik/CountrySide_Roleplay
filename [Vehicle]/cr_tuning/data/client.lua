datas = {}

function getPlayerDatas()
    datas = {
        ["char >> money"] = true,
        ["char >> premiumPoints"] = true,
        ["char >> bankmoney"] = true,
    }

    for k,v in pairs(datas) do 
        if localPlayer:getData(k) ~= v then 
            datas[k] = tonumber(localPlayer:getData(k) or 0)
        end 
    end 

    addEventHandler("onClientElementDataChange", localPlayer, checkPlayerDatas)
end 

function destroyPlayerDatas()
    datas = {}

    removeEventHandler("onClientElementDataChange", localPlayer, checkPlayerDatas)
end 

function checkPlayerDatas(dName, oValue, nValue)
    if source == localPlayer then 
        if datas[dName] then 
            if datas[dName] ~= nValue then 
                datas[dName] = tonumber(nValue or 0)
            end 
        end 
    end 
end