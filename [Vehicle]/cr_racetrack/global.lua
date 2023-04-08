sectorDetails = {
    --{x,y,z}
    --{433.93240356445, 630.63024902344, 8.3458108901978},
    {463.49212646484, 654.49005126953, 8.3749084472656},
    {465.87170410156, 690.60998535156, 8.7993412017822},
    {473.39993286133, 744.05059814453, 9.5569591522217},
    {526.89135742188, 831.36212158203, 9.4994516372681},
    {465.4362487793, 957.97564697266, 10.612937927246},
    {339.33575439453, 1081.6552734375, 11.377447128296},
    {242.53588867188, 1049.8558349609, 11.954565048218},
    {203.95176696777, 1002.7155761719, 13.114400863647},
    {217.73463439941, 959.65191650391, 15.01749420166},
    {234.07890319824, 913.58129882813, 15.976149559021},
    {183.19915771484, 859.00421142578, 15.195516586304},
    {86.34838104248, 890.10949707031, 11.261108398438},
    {16.089323043823, 907.03924560547, 6.1517162322998},
    {13.000076293945, 844.35229492188, 6.6766004562378},
    {68.269012451172, 813.16424560547, 10.183782577515},
    {131.34759521484, 785.18634033203, 12.661069869995},
    {176.98731994629, 723.68255615234, 12.234060287476},
    {230.95375061035, 592.31884765625, 9.2198066711426},
    {329.98541259766, 577.56567382813, 8.4675846099854},
    {418.36206054688, 620.53448486328, 8.3416204452515},
    --{433.93240356445, 630.63024902344, 8.3458108901978},
    {463.49212646484, 654.49005126953, 8.3749084472656},
    {465.87170410156, 690.60998535156, 8.7993412017822},
    {473.39993286133, 744.05059814453, 9.5569591522217},
    {526.89135742188, 831.36212158203, 9.4994516372681},
    {465.4362487793, 957.97564697266, 10.612937927246},
    {339.33575439453, 1081.6552734375, 11.377447128296},
    {242.53588867188, 1049.8558349609, 11.954565048218},
    {203.95176696777, 1002.7155761719, 13.114400863647},
    {217.73463439941, 959.65191650391, 15.01749420166},
    {234.07890319824, 913.58129882813, 15.976149559021},
    {183.19915771484, 859.00421142578, 15.195516586304},
    {86.34838104248, 890.10949707031, 11.261108398438},
    {16.089323043823, 907.03924560547, 6.1517162322998},
    {13.000076293945, 844.35229492188, 6.6766004562378},
    {68.269012451172, 813.16424560547, 10.183782577515},
    {131.34759521484, 785.18634033203, 12.661069869995},
    {176.98731994629, 723.68255615234, 12.234060287476},
    {230.95375061035, 592.31884765625, 9.2198066711426},
    {329.98541259766, 577.56567382813, 8.4675846099854},
    {418.36206054688, 620.53448486328, 8.3416204452515},
    --{433.93240356445, 630.63024902344, 8.3458108901978},
    {463.49212646484, 654.49005126953, 8.3749084472656},
    {465.87170410156, 690.60998535156, 8.7993412017822},
    {473.39993286133, 744.05059814453, 9.5569591522217},
    {526.89135742188, 831.36212158203, 9.4994516372681},
    {465.4362487793, 957.97564697266, 10.612937927246},
    {339.33575439453, 1081.6552734375, 11.377447128296},
    {242.53588867188, 1049.8558349609, 11.954565048218},
    {203.95176696777, 1002.7155761719, 13.114400863647},
    {217.73463439941, 959.65191650391, 15.01749420166},
    {234.07890319824, 913.58129882813, 15.976149559021},
    {183.19915771484, 859.00421142578, 15.195516586304},
    {86.34838104248, 890.10949707031, 11.261108398438},
    {16.089323043823, 907.03924560547, 6.1517162322998},
    {13.000076293945, 844.35229492188, 6.6766004562378},
    {68.269012451172, 813.16424560547, 10.183782577515},
    {131.34759521484, 785.18634033203, 12.661069869995},
    {176.98731994629, 723.68255615234, 12.234060287476},
    {230.95375061035, 592.31884765625, 9.2198066711426},
    {329.98541259766, 577.56567382813, 8.4675846099854},
    {418.36206054688, 620.53448486328, 8.3416204452515},
}

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end   

function formatIntoTime(a, isPlus)
    local string = ""
    --outputChatBox(a)
    if tonumber(a) <= 0 then
        a = a * -1
        if math.floor(a / 1000 / 60) >= 1 then -- Perces szitu
            local a1 = math.floor(a / 1000 / 60)
            local a2 = math.floor((a / 1000 - (a1 * 60)))
            local a3 = math.round(a - ((a2 + (a1 * 60)) * 1000), 3)
            if a1 < 10 then
                a1 = "0" .. a1
            end
            if a2 < 10 then
                a2 = "0" .. a2
            end
            string = "-" .. a1 .. ":" .. a2 .. ".".. a3
        else -- Másodperces szitu
            local a1 = math.floor(a / 1000)
            local a2 = math.round(a - (a1 * 1000), 3)
            if a1 < 10 then
                a1 = "0" .. a1
            end
            string = "-" .. a1 .. "." .. a2
        end
    else
        if math.floor(a / 1000 / 60) >= 1 then -- Perces szitu
            local a1 = math.floor(a / 1000 / 60)
            local a2 = math.floor((a / 1000 - (a1 * 60)))
            local a3 = math.round(a - ((a2 + (a1 * 60)) * 1000), 3)
            if a1 < 10 then
                a1 = "0" .. a1
            end
            if a2 < 10 then
                a2 = "0" .. a2
            end
            string = (isPlus and "+" or "") .. a1 .. ":" .. a2 .. ".".. a3
        else -- Másodperces szitu
            local a1 = math.floor(a / 1000)
            local a2 = math.round(a - (a1 * 1000), 3)
            if a1 < 10 then
                a1 = "0" .. a1
            end
            string = (isPlus and "+" or "") .. a1 .. "." .. a2
        end
    end

    return string
end

for k,v in pairs(sectorDetails) do
    local v = v
    v[3] = v[3] - 0.4
    sectorDetails[k] = v
end