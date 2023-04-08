local ban = {}
lastClickTick = getTickCount()

local w, h

function startBanPanel()
    --requestTextBars
    page = "Ban"
    addEventHandler("onClientRender", root, drawnBan, true, "low-5")
    Clear()
    --toggleAllControls(false, false)
    --exports['ax_custom-chat']:showChat(false)
    showChat(false)
    setElementData(localPlayer, "keysDenied", true)
    setElementData(localPlayer, "hudVisible", false)
    accName = getElementData(localPlayer, "ban.accountName") or "Ismeretlen"
    id = getElementData(localPlayer, "ban.id") or "Ismeretlen"
    reason = getElementData(localPlayer, "ban.reason") or "Ismeretlen"
    aName = getElementData(localPlayer, "ban.aName") or "Ismeretlen"
    startDate = getElementData(localPlayer, "ban.startDate") or "Ismeretlen"
    endDate = getElementData(localPlayer, "ban.endDate") or "Ismeretlen"
    alpha = 0
    multipler = 1
    w, h = 400, 380
end

function stopBanPanel()
    if page == "Ban" then
        removeEventHandler("onClientRender", root, drawnBan)
    end
end

function drawnBan()
    if alpha + multipler <= 255 then
        alpha = alpha + multipler
    elseif alpha >= 255 then
        alpha = 255
    end
    
    local font = exports['cr_fonts']:getFont('Poppins-SemiBold', 16)
    local font2 = exports['cr_fonts']:getFont('Poppins-Medium', 12)
    local font3 = exports['cr_fonts']:getFont('Poppins-Medium', 50)
    local font4 = exports['cr_fonts']:getFont('Poppins-SemiBold', 20)

    local x, y = sx/2 - w/2, sy/2 - h/2

    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, alpha * 0.8))
	dxDrawImage(x + 10, y + 5, 25, 25, ":cr_account/files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))

	dxDrawText('Banpanel', x + 10 + 25 + 10,y+5,x+w,y+5+25 + 4,tocolor(242, 242, 242, alpha),1,font,"left","center")

    dxDrawText('Oops!', x,y,x + w,y + 125 + 4,tocolor(242, 242, 242, alpha),1,font3,"center","center")

    dxDrawText('Úgy tűnik, hogy ki vagy tiltva a szerverről.\nLentebb olvashatod a tíltás részleteit.', x,y + 120,x + w,y + 150 + 4,tocolor(242, 242, 242, alpha),1,font2,"center","center")

    dxDrawRectangle(x + 20, y + 167, (w - 40), 115, tocolor(41, 41, 41, alpha * 0.9))

    local red = exports['cr_core']:getServerColor('red', true)
    local yellow = exports['cr_core']:getServerColor('yellow', true)
    local white = exports['cr_core']:getServerColor('white', true)
    local text = red .. 'BanID: ' .. white .. id .. ' (' .. red .. 'Account név: ' .. white .. accName..')\n' .. red .. 'Általa: ' .. yellow .. aName .. white .. '\n' .. red .. 'Indok: '.. white .. reason .. '\n' .. red .. 'Kitiltás kezdete: ' .. white .. startDate .. '\n' .. red .. 'Kitiltás lejárata: ' .. yellow .. endDate
    dxDrawText(text, x + 20 + 10, y + 167 + 5, x + 20 + 5 + 350, y + 167 + 5 + 105 + 4, tocolor(242, 242, 242, alpha), 1, font2, "left", "center", false, false, false, true)

    local tWidth = dxGetTextWidth(text, 1, font2, true) + 60
    if tWidth > w then 
        w = tWidth
    end 

    dxDrawText('Ha bármi ellenvetésed lenne a tíltással kapcsolatban,\nfórumunkon a megfelelő helyre leírhatod a panaszod.', x,y + 295,x + w,y + 325 + 4,tocolor(242, 242, 242, alpha),1,font2,"center","center")

    dxDrawText('forum.csrp.hu', x,y + 340,x + w,y + 360 + 4,tocolor(255, 59, 59, alpha),1,font4,"center","center")
end