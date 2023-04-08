local global = {
    --[[
    {"Név", {cameraMatrix(6 pos)}, "Leírás", time},
    ]]
    {"Town Hall", {2266.0920410156, -105.12779998779, 37.549800872803, 2266.0900878906, -104.15191650391, 37.331504821777, 0, 70}, "Ebben az épületben lehetséges munkát keresni és annak függvényében elhelyezkedni a legkedveltebb munka területen. Itt szintén lehetőség nyílik hivatalos ügyek el intézésére, mint pl. a személyes iratok kezelése!", 20000},
    {"Montgomery Medical Centre", {1261.9831542969, 351.47406005859, 26.830173492432, 1219.8210449219, 261.32479858398, 17.058973312378, 0, 70}, "A karakter halála után erre a helyre kerülsz, illetve ha megsebesülsz ide visznek a sérüléseid ellátására. Egyaránt gyógyszert is ebben az épületben tudsz igényelni.", 10000},
    {"Los Santos County Sheriff's Department", {649.08435058594, -572.75067138672, 19.830707550049, 549.27325439453, -568.82489013672, 15.106151580811, 0, 70}, "Bűncselekményt szemtanúja lettél? Ezen a helyen tudsz feljelentést tenni. Ide kerülnek azok, akiknek meggyűlik a bajuk a törvénnyel.", 10000},
    {"Autókereskedés", {1368.55078125, 445.94030761719, 25.829441070557, 1415.2696533203, 358.16696166992, 15.190299034119, 0, 70}, "Szeretnél igazi vidékbe illő amerikai stílusú járművel közlekedni a kisvárosok között? Nincs más dolgod, mint eljönni erre a helyre és kiválasztani a legmegfelelőbb járgányt a mindig bővülő széleskörű választékból.", 15000},
    {"Walmart", {635.52294921875, -564.9345703125, 21.829990386963, 735.20544433594, -567.57720947266, 14.318756103516, 0, 70}, "A kis városokban több helyen is megtalálhatóak különböző benzinkutak/boltok, mint pl. a Walmart és a Texaco, ezeken a helyeken tudod megvásárolni a hétköznapokhoz szükséges dolgokat és a járművedet meg tankolni.", 10000},
    {"Palomino Bay", {2168.0051269531, -116.72665405273, 11.830143928528, 2072.3793945312, -91.906967163086, -3.6526374816895, 0, 70}, "Ez a hely a horgászat kedvelőinek szolgál, akik szívesen ütik el az idejüket egy kis halászattal. Itt szintén megtalálható a helyi kikötő ahol az import/export áru érkezik. ", 10000},
    {"Bank", {2283.9965820312, -7.0452189445496, 29.82946395874, 2383.8923339844, -7.4267511367798, 25.279218673706, 0, 70}, "Itt tudsz bankkártyàt igényelni és nagyobb tranzakciókat/utalásokat lebonyolítani. ", 15000},
    {"Binco", {675.38439941406, -621.57983398438, 19.136775970459, 775.16925048828, -623.93255615234, 13.01828289032, 0, 70}, "Nem tetszik a jelenlegi kinézeted? Itt tudod lecserélni a karaktered külsejét és a ruházatát testre szabni a ruhaboltban megtalálható kiegészítőkkel.", 15000},
    {"Fegyverbolt", {219.57739257812, -178.0089263916, 8.8296165466309, 318.83038330078, -178.15925598145, -3.3697364330292, 0, 70}, "A kisvárosokban több különböző fegyverbolt is megtalálható, ahol lehetőséged nyílik különböző fegyver skillek kitanulásához illetve itt tudsz fegyvert is vásárolni a meglévő engedélyekkel.", 10000},
    {"Szerelőtelep", {235.95901489258, -282.130859375, 7.8304023742676, 169.36820983887, -208.06057739258, -1.0721123218536, 0, 70}, "Elromlott a járműved? Vidd el a szerelőtelepre ahol a telep segítőkész dolgozói se perc alatt megjavítják a károkat és ràncfelvarrást végeznek egyéni kérések szerint.", 15000},
}

function startTour()
    _dim = getElementDimension(localPlayer)
    setElementDimension(localPlayer, 0)
    fadeCamera(true)
    tourSound = playSound("https://tsapi.bluemta.com/MTA:SA/Music/tutorial.mp3", true)
    setSoundVolume(tourSound, 0.5)
    now = 1
    name, matrix, text, time = unpack(global[now])
    
    setCameraMatrix(unpack(matrix))
    --exports['ax_custom-chat']:showChat(false)
    showChat(false)
    --toggleAllControls(false, false)
    setElementData(localPlayer, "hudVisible", false)
    setElementData(localPlayer, "keysDenied", true)
    page = "Tour"
    addEventHandler("onClientRender", root, drawnTour, true, "low-5")
    setTimer(change, global[now][4], 1)
end

local i = 5000
function change()
    if global[now + 1] then
        now = now + 1
        name, matrix, text, time = unpack(global[now])
        local x1, y1, z1, x2, y2, z2 = unpack(global[now - 1][2])
        local x3, y3, z3, x4, y4, z4 = unpack(matrix)
        exports['cr_core']:smoothMoveCamera(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, i)
        removeEventHandler("onClientRender", root, drawnTour)
        setTimer(
            function()
                addEventHandler("onClientRender", root, drawnTour, true, "low-5")
                setTimer(
                    function()
                        change()
                    end, global[now][4], 1
                )
            end, i, 1
        )
    else
        -- Vége
        stopTour()
    end
end

function stopTour()
    startLoadingScreen("Char-Reg", 2)
    setElementDimension(localPlayer, _dim or 1)
    destroyElement(tourSound)
    removeEventHandler("onClientRender", root, drawnTour)
end

function drawnTour()
    local font = exports['cr_fonts']:getFont("Poppins-SemiBold", 18)
    local font2 = exports['cr_fonts']:getFont("Poppins-Regular", 14)

    local w, h = 450, 250
    local x, y = 42, 42 
    dxDrawRectangle(x, y, w, h, tocolor(51, 51, 51, 255 * 0.8))
    dxDrawText(name, x + 20, y + 20, x + 20, y + 20, tocolor(229, 229, 229, 255), 1, font, "left", "top")
    dxDrawText(now .. "/" .. #global, x + 20, y + 20, x + w - 20, y + 20, tocolor(229, 229, 229, 255), 1, font, "right", "top")

    dxDrawText(text, x + 20, y + 50, x + w - 75, y + 20, tocolor(229, 229, 229, 255), 1, font2, "left", "top", false, true)

    local logoW, logoH = 52, 60
    dxDrawImage(x + w - logoW - 10, y + h - logoH - 10, logoW, logoH, "files/logo-white.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
end
--startTour()