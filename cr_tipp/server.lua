local blue = "#FFEB3B"
local white = "#ffffff"
local tips = {
    --"Tipp", 
    "A "..blue.."/elrejt"..white.." parancs használatával eltudod rejteni az éppen kezedben lévő kiskaliberű fegyvert!",   
    --"A "..blue.."/togdescriptions"..white.." parancs használatával eltudod tűntetni a játékosok leírásait! (Descriptionst a nametagből)",
    --"A "..blue.."/myname"..white.." parancs használatával betudod kapcsolni a saját nametaged megjelenítését",
    "Ha kijelölsz a "..blue.."HUD"..white.." Szerkesztőben "..blue.."1"..white.." elemet amit mozgatni szeretnél utána kurzor mozgatás helyett lehetőséged van akár a "..blue.."nyilakkal"..white.." is mozgatni",
    "Egyes widgeteket (Pld: "..blue.."Inventory"..white..") anélkül tudsz mozgatni, hogy megnyisd a hud szerkesztést!",
    ""..blue.."Tudtad?"..white.." Ha "..blue.."2"..white.." másodpercig lenyomva tartod a "..blue.."'TAB'"..white.." gombot a scoreboard nem tűnik el csak újbóli lenyomás után!",
    "Az "..blue.."F11"..white.."-s radaron a "..blue.."görgő"..white.." lenyomásával képes vagy blipeket létrehozni. Az újbóli lenyomáskor képes vagy a blip típusát állítani. "..blue.."Jobb"..white.." klikkel hozza létre, újbóli "..blue.."jobb"..white.." klikkel tudod törölni az ugyanolyan típusú blippeket",
    "Ha az actionbarra nyomsz 1 "..blue.."görgőt"..white.." akkor tudsz változtatni, hogy "..blue.."vízszintes"..white.." vagy "..blue.."függőleges"..white.." legyen és a hud szerkesztésben lehetőséged van akár hozzáadni és törölni is slotokat",
    --"A "..blue.."/mybubble"..white.." parancs használatával képes vagy szabályozni, hogy látod a saját "..blue.."szövegbuborékaidat"..white.." vagy sem!",
    --"A "..blue.."/myname"..white.." parancs használatával képes vagy szabályozni, hogy látod a saját "..blue.."neved"..white.." (nametag) vagy sem!",
    --"A "..blue.."/togglebubbles"..white.." parancs használatával képes vagy szabályozni, hogy látod a "..blue.."szövegbuborékokat"..white.." vagy sem!",
	"Elérhetőség "..blue.."Discord:"..white.." discord.gg/mdCYRRn9ta "..blue.."Fórum: "..white.." forum.csrp.hu",
    'A '..blue..'/clothes'..white..' parancs használatával elérheted a saját kiegészítőidet!',
    'A '..blue..'radar forgatást'..white..' ki/be kapcsolhatod a radar beállításokban!',
    'Ha '..blue..'hibás / nem jelenik meg'..white..' a radar használd '..blue..'/resetmap'..white..' parancsot!',
}

local blue = "#ffa800"
local syntax = blue .. "[Tipp] "..white
local oldTipp = 0

addEventHandler("onResourceStart", resourceRoot,
    function()
        createTipp()
    end
)

function createTipp()
    local newTipp = math.random(1, #tips)
    if newTipp == oldTipp then
        return createTipp
    end
    oldTipp = newTipp
    local text = tips[newTipp]
    outputChatBox(syntax .. text, root, 255,255,255,true)
    return true
end

local seconds = 15 * 60
setTimer(createTipp, seconds * 1000, 0)