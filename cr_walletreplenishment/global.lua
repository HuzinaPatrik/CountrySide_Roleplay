white = "#ffffff"

serviceMinLine = 1
serviceMaxLine = 3

keyPad = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "X", "0", "icon"}
keyPadIndexed = {}

keyPadMinLine = 0
keyPadMaxLine = #keyPad

historyMinLine = 1
_historyMaxLine = 5
historyMaxLine = _historyMaxLine

maxKeyInARow = 3
maxKeyInAColumn = 3

for k, v in pairs(keyPad) do 
    keyPadIndexed[v] = true
end

local services = exports.cr_phone:getAvailableShops()

availableServices = {}

for k, v in pairs(services) do 
    table.insert(availableServices, {
        name = k,
        data = v
    })
end

function getServiceIndex(serviceName)
    local result = false

    for i = 1, #availableServices do 
        local v = availableServices[i]

        if v.name == serviceName then 
            result = i
            break
        end
    end

    return result
end

walletPedData = {
    {
        position = Vector3(1389.1893310547, 463.22015380859, 20.468042373657),
        rotation = Vector3(0, 0, 333.03646850586),
        interior = 0,
        dimension = 0,
        skinId = 259,
        name = "Ronald Pearson",
        typ = "Egyenleg feltöltés"
    },

    {
        position = Vector3(250.85275268555, -54.82767868042, 1.5776442289352),
        rotation = Vector3(0, 0, 179.23516845703),
        interior = 0,
        dimension = 0,
        skinId = 22,
        name = "Jeremy Vincent",
        typ = "Egyenleg feltöltés"
    }
}