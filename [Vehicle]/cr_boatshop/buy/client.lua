isBuyRender, buyCache, buyProgress = false, nil, 0

local selected, gSelected
local buttons = {
    {"Készpénz", "green", ":cr_skinshop/assets/images/cashIcon.png", 24, 15},
    {"Bankkártya", "yellow", ":cr_skinshop/assets/images/cardIcon.png", 21, 15},
    {"PP", "orange", ":cr_skinshop/assets/images/ppIcon.png", 15, 15},
    --{"Mégse", "red"}
}

function createBuy(data)
    if data then 
        buyCache = data

        isCursorInPanel = false
        buyProgress = 0
        gSelected = 0
        selected = nil 

        exports['cr_dx']:startFade("buyPanel >> boatshop", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 0,
                ["to"] = 255,
                ["alpha"] = 0,
                ["progress"] = 0,
            }
        )

        if not isBuyRender then 
            isBuyRender = true 
            createRender("drawnBuy", drawnBuy)
            addEventHandler("onClientClick", root, buyClickEvent)
        end 
    end
end 

function destroyBuy()
    if isBuyRender then 
        isCursorInPanel = false
        gSelected = nil 
        selected = nil 
        buyProgress = nil

        removeEventHandler("onClientClick", root, buyClickEvent)
        isBuyRender = false 

        exports['cr_dx']:startFade("buyPanel >> boatshop", 
            {
                ["startTick"] = getTickCount(),
                ["lastUpdateTick"] = getTickCount(),
                ["time"] = 250,
                ["animation"] = "InOutQuad",
                ["from"] = 255,
                ["to"] = 0,
                ["alpha"] = 255,
                ["progress"] = 0,
            }
        )
    end 
end 

function drawnBuy()
    local alpha, progress = exports['cr_dx']:getFade("buyPanel >> boatshop")
    if not isBuyRender then 
        if progress >= 1 then 
            if buyCache["onFinish"] then 
                buyCache["onFinish"]()
            end 
            buyCache = nil
            isCursorInPanel = false
            destroyRender("drawnBuy")
            return 
        end 
    else 
        buyProgress = progress
    end 

    selected = nil

    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 14)
    local font3 = exports['cr_fonts']:getFont('Poppins-Bold', 12)

	local w, h = 350, 180
	local x, y = sx/2 - w/2, sy/2 - h/2

	dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
    isCursorInPanel = false 
    if exports['cr_core']:isInSlot(x, y, w, h) then 
        isCursorInPanel = true
    end 
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

    local subText = ""
    if buyCache["nextLevel"] then 
        subText = buyCache["nextLevel"]
    end 
	dxDrawText(buyCache["tuningName"] .. " vásárlása", x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

	if exports['cr_core']:isInSlot(x + w - 10 - 15, y + 10, 15, 15) then 
		selected = 4

        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha))
    else 
        dxDrawImage(x + w - 10 - 15, y + 10, 15, 15, ":cr_inventory/assets/images/close.png", 0, 0, 0, tocolor(255, 59, 59, alpha * 0.6))
    end 

    dxDrawText(subText .. " vásárlásához kérlek válasz fizetőezközt.", x, y + 40, x + w, y + 40, tocolor(242, 242, 242, alpha), 1, font2, "center", "top", false, true)

    local tuningPrice
    if buyCache["tuningPrice"] then 
        tuningPrice = buyCache["tuningPrice"]

        if tonumber(buyCache["nextLevel"]) then 
            if buyCache["nextLevel"] == 0 then 
                tuningPrice = {0, 0, 0}
            end 
        end
    else 
        tuningPrice = {100, 100, 10}
    end 

    local x, y = x + 30, y + 85

    for k,v in pairs(buttons) do 
        local w2, h2 = 85, 75

        local path, iconW, iconH = v[3], v[4], v[5]

        if exports['cr_core']:isInSlot(x, y, w2, h2) or gSelected == k then
            if exports['cr_core']:isInSlot(x, y, w2, h2) then 
                selected = k
            end 

            dxDrawRectangle(x, y, w2, h2, tocolor(242, 242, 242, alpha * 0.8))
            dxDrawImage(x + w2/2 - iconW/2, y + h2/2 - iconH/2, iconW, iconH, path, 0, 0, 0, tocolor(51, 51, 51, alpha))
            dxDrawText(v[1], x, y + 5, x + w2, y + h2, tocolor(51, 51, 51, alpha), 1, font3, "center", "top", false, false, false, true)
            dxDrawText((k < 3 and "$ " or "") .. tuningPrice[k], x, y, x + w2, y + h2 - 5, tocolor(51, 51, 51, alpha), 1, font3, "center", "bottom", false, false, false, true)
        else 
            local green = exports['cr_core']:getServerColor(v[2], true)

            dxDrawRectangle(x, y, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
            dxDrawImage(x + w2/2 - iconW/2, y + h2/2 - iconH/2, iconW, iconH, path, 0, 0, 0, tocolor(242, 242, 242, alpha))
            dxDrawText(v[1], x, y + 5, x + w2, y + h2, tocolor(242, 242, 242, alpha), 1, font3, "center", "top", false, false, false, true)
            dxDrawText(green .. (k < 3 and "$ " or "") .. tuningPrice[k], x, y, x + w2, y + h2 - 5, tocolor(242, 242, 242, alpha), 1, font3, "center", "bottom", false, false, false, true)
        end 

        x = x + w2 + 15
    end
end

function buyClickEvent(b, s)
    if isBuyRender then 
        if b == "left" and s == "down" then 
            if selected == 1 then 
                if buyCache["onEnter"] then 
                    buyCache["onEnter"](selected)
                end 
                selected = nil 
                return 
            elseif selected == 2 then 
                if buyCache["onEnter"] then 
                    buyCache["onEnter"](selected)
                end 
                selected = nil 
                return 
            elseif selected == 3 then
                if buyCache["onEnter"] then 
                    buyCache["onEnter"](selected)
                end 
                selected = nil 
                return 
            elseif selected == 4 then 
                destroyBuy()
                return 
            end 
        end 
    end 
end 

function buyEnter()
    if gSelected == 1 then 
        if buyCache["onEnter"] then 
            buyCache["onEnter"](gSelected)
        end 
    elseif gSelected == 2 then 
        if buyCache["onEnter"] then 
            buyCache["onEnter"](gSelected)
        end 
    elseif gSelected == 3 then 
        if buyCache["onEnter"] then 
            buyCache["onEnter"](gSelected)
        end 
    elseif gSelected == 4 then 
        destroyBuy()
    end 
end 

function buyUp()
    if gSelected - 1 > 0 then 
        gSelected = gSelected - 1
    end 
end 

function buyDown()
    if gSelected + 1 <= #buttons then 
        gSelected = gSelected + 1
    end 
end 