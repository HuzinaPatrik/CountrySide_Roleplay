paintjob = {
    [416] = {
        --1
        {
            --["tex"] = "imagePath",
            ["*remapbody*"] = ":cr_tuning/paintjob/416/1.png",
        },
        --2
        {
            --["tex"] = "imagePath",
            ["*remapbody*"] = ":cr_tuning/paintjob/416/2.png",
        },
    },


}

function getMaximumPaintJob(veh)
    local val = 0
    if paintjob[veh.model] then 
        val = tonumber(#paintjob[veh.model] or 0)
    end 

    return val
end

paintJobData = {}

function applyPaintjob(veh, id, updateTable)
    if paintjob[veh.model] and paintjob[veh.model][id] then 
        destroyPaintjob(veh, updateTable)

        if paintjob[veh.model][id] then 
            for k,v in pairs(paintjob[veh.model][id]) do 
                exports['cr_texturechanger']:replace(veh, k, v, not updateTable)
            end 
        end 
        paintJobData[veh] = id
    end 
end 

function destroyPaintjob(veh, updateTable)
    if paintJobData[veh] then 
        local id = paintJobData[veh]
        if paintjob[veh.model][id] then 
            for k,v in pairs(paintjob[veh.model][id]) do 
                exports['cr_texturechanger']:destroy(veh, k, v, not updateTable)
            end 
        end 

        paintJobData[veh] = nil
        collectgarbage("collect")
    end 
end 

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source and source.type == "vehicle" then 
            local tuningData = source:getData("veh >> tuningData") or {}
            if tonumber(tuningData["paintjob"] or 0) > 0 then 
                applyPaintjob(source, tonumber(tuningData["paintjob"] or 0))
            end 
        end 
    end
)

addEventHandler("onClientElementStreamOut", root, 
    function()
        if source and source.type == "vehicle" then 
            local tuningData = source:getData("veh >> tuningData") or {}
            if tonumber(tuningData["paintjob"] or 0) > 0 then 
                destroyPaintjob(source)
            end 
        end 
    end
)

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "veh >> tuningData" then 
            if tonumber(nValue["paintjob"] or 0) > 0 then 
                applyPaintjob(source, tonumber(nValue["paintjob"] or 0))
            else
                destroyPaintjob(source)
            end 
        end 
    end 
)

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        for k,v in pairs(getElementsByType("vehicle", _, true)) do 
            local tuningData = v:getData("veh >> tuningData") or {}
            if tonumber(tuningData["paintjob"] or 0) > 0 then 
                applyPaintjob(v, tonumber(tuningData["paintjob"] or 0))
            end 
        end 
    end 
)