local pos = Vector2(guiGetScreenSize())
local center = Vector2(pos.x/2, pos.y/2)

local levels = {
    --[levelUpMinute] = level
    [0] = 1,
    [5*60] = 2,
    [10*60] = 3,
    [15*60] = 4,
    [20*60] = 5,
    [30*60] = 6,
    [40*60] = 7,
    [50*60] = 8,
    [60*60] = 9,
    [70*60] = 10,
    [90*60] = 11,
    [110*60] = 12,
    [120*60] = 13,
    [140*60] = 14,
    [160*60] = 15,
    [190*60] = 16,
    [220*60] = 17,
    [250*60] = 18,
    [280*60] = 19,
    [310*60] = 20,
    [350*60] = 21,
    [390*60] = 22,
    [430*60] = 23,
    [470*60] = 24,
    [500*60] = 25,
    [550*60] = 26,
    [600*60] = 27,
    [650*60] = 28,
    [700*60] = 29,
    [750*60] = 30,
    [800*60] = 31,
    [850*60] = 32,
    [900*60] = 33,
    [950*60] = 34,
    [1000*60] = 35,
    [1050*60] = 36,
    [1100*60] = 37,
    [1150*60] = 38,
    [1200*60] = 39,
    [1250*60] = 40,
    [1300*60] = 41,
    [1350*60] = 42,
    [1400*60] = 43,
    [1450*60] = 44,
    [1500*60] = 45,
    [1600*60] = 46,
    [1700*60] = 47,
    [1800*60] = 48,
    [1900*60] = 49,
    [2000*60] = 50,
    [2100*60] = 51,
    [2200*60] = 52,
    [2300*60] = 53,
    [2400*60] = 54,
    [2500*60] = 55,
    [2600*60] = 56,
    [2700*60] = 57,
    [2800*60] = 58,
    [2900*60] = 59,
    [3000*60] = 60,
    [3100*60] = 61,
    [3200*60] = 62,
    [3300*60] = 63,
    [3400*60] = 64,
    [3500*60] = 65,
    [3600*60] = 66,
    [3700*60] = 67,
    [3800*60] = 68,
    [3900*60] = 69,
    [4000*60] = 70,
    [4200*60] = 71,
    [4400*60] = 72,
    [4600*60] = 73,
    [4800*60] = 74,
    [5000*60] = 75,
    [5500*60] = 76,
    [6000*60] = 77,
    [6500*60] = 78,
    [7000*60] = 79,
    [7500*60] = 80,
    [8500*60] = 81,
    [9500*60] = 82,
    [10500*60] = 83,
    [11500*60] = 84,
    [12500*60] = 85,
    [13500*60] = 86,
    [14500*60] = 87,
    [15500*60] = 88,
    [16500*60] = 89,
    [17500*60] = 90,
    [18500*60] = 91,
    [19500*60] = 92,
    [20500*60] = 93,
    [21500*60] = 94,
    [22500*60] = 95,
    [23500*60] = 96,
    [24500*60] = 97,
    [25500*60] = 98,
    [30000*60] = 99,
    [35000*60] = 100,
    [100000*60] = 101,
    --további kitöltésre vár
}

levelsConvert = {}
for k,v in pairs(levels) do
    levelsConvert[v] = k
end

function getLevelTime(level)
    return levelsConvert[level]
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if dName == "char >> playedtime" then
            local value = getElementData(source, dName)
            local levelUp = levels[value]
            if levelUp then
                oldState = getElementData(localPlayer, "hudVisible")
                oldState2 = exports['cr_custom-chat']:isChatVisible()
                localPlayer:setData("hudVisible", false)
                exports['cr_custom-chat']:showChat(false)
                font = exports['cr_fonts']:getFont("Poppins-SemiBold", 26)
                font2 = exports['cr_fonts']:getFont("Poppins-Medium", 22)
                green = exports['cr_core']:getServerColor('yellow', true)
                setElementData(source, "char >> level", levelUp)
                if levelUp > 1 then
                    local syntax = exports['cr_core']:getServerSyntax("Level", "success")
                    local hexColor = exports['cr_core']:getServerColor(nil, true)
                    outputChatBox(syntax .. "Szintet léptél! Új szinted: "..hexColor..levelUp, 255,255,255,true)
                    playSound("files/welcomesound.mp3")
                    newLevel = levelUp
                    a = false
                    --addEventHandler("onClientRender", root, drawnLevelUP, true, "low-5")
                    createRender("drawnLevelUP", drawnLevelUP)
                    setTimer(
                        function()
                            a = true
                        end, 4500, 1
                    )
                    alpha = 0
                    multipler = 3
                end
            end
        end
    end
)

function drawnLevelUP()
    font = exports['cr_fonts']:getFont("Poppins-SemiBold", 26)
    font2 = exports['cr_fonts']:getFont("Poppins-Medium", 22)
    green = exports['cr_core']:getServerColor('yellow', true)
    if not a then
        if alpha + multipler <= 255 then
            alpha = alpha + multipler
        elseif alpha >= 255 then
            alpha = 255
        end
    else
        if alpha - multipler >= 0 then
            alpha = alpha - multipler
        elseif alpha <= 0 then
            alpha = 0
            --removeEventHandler("onClientRender", root, drawnLevelUP)
            destroyRender("drawnLevelUP")
            exports['cr_custom-chat']:showChat(oldState2)
            localPlayer:setData("hudVisible", oldState)
        end
    end
    dxDrawRectangle(0, 0, pos.x, pos.y, tocolor(20,20,20,math.min(180, alpha)))
    dxDrawText("Szintet léptél!", center.x, center.y-15, center.x, center.y-15, tocolor(255,255,255,alpha), 1, font, "center", "center", false, false, false, true)
    dxDrawText("Új szinted: "..green..newLevel, center.x, center.y+20, center.x, center.y+20, tocolor(255,255,255,alpha), 1, font2, "center", "center", false, false, false, true)
end