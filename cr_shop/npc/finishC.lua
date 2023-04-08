local cache = {}
local renderState, selected, gData, datum
local sx, sy = guiGetScreenSize()

function createFinishPage(data)
    if not renderState then 
        renderState = true 

        exports['cr_dx']:startFade("buyFinish >> panel", 
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

        gData = data
        datum = exports['cr_core']:getDatum(".")
        id = 1
        selected = 0
        gSelected = nil 

        bindKey("enter", "down", finishInteract)
        bindKey("backspace", "down", destroyFinishPage)
        bindKey("arrow_l", "down", leftInteract)
        bindKey("arrow_r", "down", rightInteract)

        addEventHandler("onClientClick", root, onClick)

        createRender("renderPanel", renderPanel)
    end 
end 

function destroyFinishPage()
    if renderState then 
        renderState = false 

        exports['cr_dx']:startFade("buyFinish >> panel", 
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

        unbindKey("enter", "down", finishInteract)
        unbindKey("backspace", "down", destroyFinishPage)
        unbindKey("arrow_l", "down", leftInteract)
        unbindKey("arrow_r", "down", rightInteract)

        removeEventHandler("onClientClick", root, onClick)
    end 
end 

function renderPanel()
    local alpha, progress = exports['cr_dx']:getFade("buyFinish >> panel")
    if not renderState then 
        if progress >= 1 then 
            destroyRender("renderPanel")
            return 
        end  
    end 

    local font = exports['cr_fonts']:getFont("Poppins-Bold", 20)
    local font2 = exports['cr_fonts']:getFont("Poppins-Regular", 13)
    local font3 = exports['cr_fonts']:getFont("Poppins-Bold", 13)

    local w, h = 214, 330
    dxDrawImage(sx/2 - w/2, sy/2 - h/2, w, h, "npc/bg.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
    dxDrawText("#"..gData["ID"], sx/2 - w/2, sy/2 - h/2 + 55, sx/2 + w/2, sy/2 + h/2 + 55, tocolor(51, 51, 51, alpha), 1, font, "center", "top")
    dxDrawText(datum, sx/2 - w/2 + 195, sy/2 - h/2 + 101, sx/2 - w/2 + 195, sy/2 - h/2 + 101, tocolor(51, 51, 51, alpha), 1, font2, "right", "top")
    dxDrawText(getPed():getData('ped.name'):gsub("_", " "), sx/2 - w/2 + 195, sy/2 - h/2 + 119, sx/2 - w/2 + 195, sy/2 - h/2 + 119, tocolor(51, 51, 51, alpha), 1, font2, "right", "top")

    dxDrawText(exports['cr_inventory']:getItemName(unpack(gData["ItemData"])), sx/2 - w/2 + 20, sy/2 - h/2 + 144, sx/2 - w/2 + 20, sy/2 - h/2 + 144 + 33 + 4, tocolor(51, 51, 51, alpha), 1, font2, "left", "center")
    dxDrawText(gData["count"] .. 'db', sx/2 - w/2 + 15, sy/2 - h/2 + 144, sx/2 - w/2 + 15 + 180, sy/2 - h/2 + 144 + 33 + 4, tocolor(51, 51, 51, alpha), 1, font2, "center", "center")
    dxDrawText('$ '.. gData["price"] .. '/db', sx/2 - w/2 + 195, sy/2 - h/2 + 144, sx/2 - w/2 + 195, sy/2 - h/2 + 144 + 33 + 4, tocolor(51, 51, 51, alpha), 1, font2, "right", "center")
    dxDrawText('$ '.. math.round(gData["count"] * gData["price"], 2), sx/2 - w/2 + 195, sy/2 - h/2 + 176, sx/2 - w/2 + 195, sy/2 - h/2 + 176 + 40, tocolor(51, 51, 51, alpha), 1, font3, "right", "center")

    local x, y = sx/2 - w/2 + 15, sy/2 - h/2 + 285
    local w2, h2 = 90, 25

    gSelected = nil 
    if exports['cr_core']:isInSlot(x, y, w2, h2) or selected == 1 then 
        if exports['cr_core']:isInSlot(x, y, w2, h2) then 
            gSelected = 1
        end

        dxDrawRectangle(x, y, w2, h2, tocolor(229, 229, 229, alpha))
        dxDrawText("Készpénz", x, y, x + w2, y + h2 + 4, tocolor(97, 177, 90, alpha), 1, font3, "center", "center")
    else 
        dxDrawRectangle(x, y, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText("Készpénz", x, y, x + w2, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    end 

    x = x + w2 + 5

    if exports['cr_core']:isInSlot(x, y, w2, h2) or selected == 2 then 
        if exports['cr_core']:isInSlot(x, y, w2, h2) then 
            gSelected = 2
        end

        dxDrawRectangle(x, y, w2, h2, tocolor(229, 229, 229, alpha))
        dxDrawText("Bankkártya", x, y, x + w2, y + h2 + 4, tocolor(97, 177, 90, alpha), 1, font3, "center", "center")
    else 
        dxDrawRectangle(x, y, w2, h2, tocolor(51, 51, 51, alpha * 0.8))
        dxDrawText("Bankkártya", x, y, x + w2, y + h2 + 4, tocolor(242, 242, 242, alpha * 0.6), 1, font3, "center", "center")
    end 
end 

function finishInteract()
    if selected == 1 then 
        triggerEvent("shop.buyItem2", localPlayer, 1, gData)

        destroyFinishPage()
    elseif selected == 2 then 
        triggerEvent("shop.buyItem2", localPlayer, 2, gData)

        destroyFinishPage()
    end 
end 

function leftInteract()
    selected = math.max(selected - 1, 0)
end 

function rightInteract()
    selected = math.min(selected + 1, 2)
end 

function onClick()
    if renderState then 
        if tonumber(gSelected) then 
            triggerEvent("shop.buyItem2", localPlayer, tonumber(gSelected), gData)

            destroyFinishPage()
            gSelected = nil 
        end 
    end 
end 

--[[
addCommandHandler("asd",
    function(cmd)
        createFinishPage(
            {
                ["ID"] = 1,
                ["ItemData"] = {1}, 
                ["count"] = 5,
                ["price"] = 25.5,
            }
        )
    end 
)]]

--
function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end