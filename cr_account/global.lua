salt = "/*-+CountrySideDEFENSEdefense2k12-2021#><|\ÄäĐ[í{}]defenseYEes4k2#@&äí€"
page = "Start"
fonts = {}
size = {
    ["login-bg-X"] = 1920,
    ["login-bg-Y"] = 1080,
    ["logo-image-X"] = 144,
    ["logo-image-Y"] = 114,
}

function stringToBoolean(v)
    if v and type(v) == 'string' and v == "true" or v and type(v) == 'boolean' then
        return true
    else
        return false
    end
end

function nationalityNumToString(e)
    e = tonumber(e)
    if e == 1 then
        return "europid"
    elseif e == 2 then
        return "mongoloid"
    elseif e == 3 then
        return "negrid"
    else
        return "ismeretlen"
    end
end

function getNationalityByID(i)
    local btnText
    if i == 1 then
        btnText = 'Europid';
    elseif i == 2 then
        btnText = 'Mongoloid';
    elseif i == 3 then
        btnText = 'Negrid';
    else
        btnText = 'Ismeretlen';
    end	
    
    return btnText
end

function getNemeByID(i)
    if i == 1 then
        return "Férfi"
    elseif i == 2 then
        return "Nő"
    end
end

function getBornTime(age)
    local time = getRealTime()
    local month = time.month + 1
    local monthday = time.monthday
    local year = 1900 + time.year
    if month < 10 then
        month = "0" .. tostring(month)
    end
    if monthday < 10 then
        monthday = "0" .. tostring(monthday)
    end
    local year = year - age
    return year.."."..month.."."..monthday
end

function searchSpace(a)
    local match = {}
    local d = 0
    local s = 0
   
    while true do
        local b, c = utf8.find(a, "%s", s)
        if b then
            s = b + 1
            d = d + 1
            match[d] = b
        else
            break
        end
    end
   
    return match
end
 
function matchConvertToString(text, matchTable)
    local args = {}
    local d = 0
    for i = 1, #matchTable do
        local v = matchTable[i] + 1
        if matchTable[i+1] then
            local v2 = matchTable[i+1] + 1
            local e = utfSub(text, v, v2)
            args[d] = e
        else
            e = eutfSub(text, v, #text)
            args[d] = e
        end
    end
   
    return args
    --Használatkor: executeCommandHandler("asd", source, unpack(table))
end

function dxDrawBorder(x, y, w, h, radius, color)
	dxDrawRectangle(x - radius, y, radius, h, color)
	dxDrawRectangle(x + w, y, radius, h, color)
	dxDrawRectangle(x - radius, y - radius, w + (radius * 2), radius, color)
	dxDrawRectangle(x - radius, y + h, w + (radius * 2), radius, color)
end

informationTexts = {
    --{Text, font, fontSize},
    {"A CountrySide RolePlay egy Grand Theft Auto:", "Poppins-Medium", 14},
    {".. San Andreas szerepjáték szerver amely,", "Poppins-Medium", 14},
    {".. a Multi Theft Auto kliensen keresztül érhető el,", "Poppins-Medium", 14},
    {".. a játék felépítése hozzá járul ahhoz, hogy", "Poppins-Medium", 14},
    {".. szórakoztató szerepjáték élményt biztosítson!", "Poppins-Medium", 14},
    {"A szerver Los Santos vidéki területén játszódik,", "Poppins-Medium", 14},
    {".. egész pontosan Red County területén.", "Poppins-Medium", 14},
    {".. a terület részletesebben: Blueberry, Dillimore,", "Poppins-Medium", 14},
    {".. Hampton Barns Montgomery, Palomino Creek.", "Poppins-Medium", 14},
    {"A CountrySide RolePlay rengeteg tevékenységet", "Poppins-Medium", 14},
    {".. és karriert kínál a karaktered számára.", "Poppins-Medium", 14},
    {"Egyedi modelljeinknek, elképzeléseinknek,", "Poppins-Medium", 14},
    {".. és karakter-testreszabásnak köszönhetően,", "Poppins-Medium", 14},
    {".. teljes személyre szabott élményt tudunk nyújtani.", "Poppins-Medium", 14},
    {"Legyél korrupt rendőr, bűnügyi elme vagy az ország", "Poppins-Medium", 14},
    {".. legjobb taxisofőre. A lehetőségek végtelenek,", "Poppins-Medium", 14},
    {".. az egyetlen korlátozás a saját fantáziád!", "Poppins-Medium", 14},
    {"Mielőtt elkezdenéd a játékot, rendelkezned kell a", "Poppins-Medium", 14},
    {".. Grand Theft Auto: San Andreas játékkal és le kell", "Poppins-Medium", 14},
    {".. töltened az online többjátékos", "Poppins-Medium", 14},
    {".. módosítást (klienst), amelyet Multi Theft Autonak", "Poppins-Medium", 14},
    {".. neveznek, vagy röviden MTA.", "Poppins-Medium", 14},
    {"Az MTA segítségével feltudsz csatlakozni a szerverre,", "Poppins-Medium", 14},
    {".. és alakíthatod a karakteredet, csatlakozz", "Poppins-Medium", 14},
    {".. a feledhetetlen játékélményért!", "Poppins-Medium", 14},
}

rulesTexts = {
    --{Text, font, fontSize},
    {"DM - DeathMatch", "Poppins-SemiBold", 14},
    {"Ok nélküli ölés", "Poppins-Regular", 14},
    {"MG - MetaGaming", "Poppins-SemiBold", 14},
    {"OOC információ felhasználása IC.", "Poppins-Regular", 14},
    {"PG - PowerGaming", "Poppins-SemiBold", 14},
    {"Olyan dolog amit a valóságban nem tudnál", "Poppins-Regular", 14},
    {".. és nem mernél megtenni.", "Poppins-Regular", 14},
    {"RK - RevengeKill", "Poppins-SemiBold", 14},
    {"Halál utáni bosszúállás.", "Poppins-Regular", 14},
    {"DB - DriveBy", "Poppins-SemiBold", 14},
    {"Járművel való szándékos ölés.", "Poppins-Regular", 14},
    {"SK - SpawnKill", "Poppins-SemiBold", 14},
    {"Spawnoláskor ölés.", "Poppins-Regular", 14},
    {"ForceRP", "Poppins-SemiBold", 14},
    {"Saját RP más játékosra történő ráerőltetése.", "Poppins-Regular", 14},
    {"NonRP - Nem reális cselekedet,", "Poppins-SemiBold", 14},
    {".. olyan dolog amit a valóságban sem tudnál,", "Poppins-Regular", 14},
    {".. vagy nem tennél meg.", "Poppins-Regular", 14},
    {"Szereptévesztés", "Poppins-SemiBold", 14},
    {"Olyan cselekedet ami nem illik a karakteredhez.", "Poppins-Regular", 14},
}