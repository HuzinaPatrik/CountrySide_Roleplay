minMultiplier = 1
maxMultiplier = 2
deleteAfter = 168 * 3600 -- 1 hét

function copyTable(tbl)
    local array = {}

    for k, v in pairs(tbl) do 
        if type(v) == "table" then 
            array[k] = copyTable(v)
        else
            array[k] = v
        end
    end

    return array
end