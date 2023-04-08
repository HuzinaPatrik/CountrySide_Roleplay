bankPeds = {
    --{skinid, x,y,z,dim,int,rot}
    {185, 2313.3972167969, 1.7319320440292, 26.4921875, 0, 0, 178, "Hector Morales"},
    {235, 2315.357421875, 1.7331646680832, 26.4921875, 0, 0, 178, "Brandon Williams"},
}

color = "#F2F2F2"

function formatCardNumber(num)
    local num = tostring(num)
    return num:sub(1, 4) .. " " .. num:sub(5, 8) .. " " .. num:sub(9, 12)
end 

buttons = {
    {{"overview", 20, 20}, "Áttekintés"},
    {{"transfer", 21, 20}, "Utalás"},
    {{"cash-out", 22, 20}, "Pénz felvétel"},
    {{"cash-in", 22, 20}, "Pénz befizetés"},
    {{"settings", 20, 20}, "Kezelés"},
}

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end