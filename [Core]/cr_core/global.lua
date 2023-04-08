colors = {
    --['colorname'] = {r, g, b, hex},
    ['red'] = {255, 59, 59, "#FF3B3B"},
	['green'] = {97, 177, 90, "#61B15A"},
    ['blue'] = {9, 193, 252, "#09C1FC"},
    ['yellow'] = {255, 235, 59, "#FFEB3B"},
    ['orange'] = {255, 212, 5, "#FFD405"},
    
	--['blue2'] = {36, 109, 208, "#246dd0"},
    ['darkblue'] = {47, 128, 237, "#2F80ED"},
    
    ["orangeOld"] = {255, 212, 5, "#FFD405"},
    ["orangeNew"] = {255, 212, 5, "#FFD405"},

    ['lightyellow'] = {255, 240, 107, "#FFF06B"},
    ['gray'] = {229, 229, 229, "#E5E5E5"},

    ['white'] = {242, 242, 242, "#F2F2F2"},
}

devMode = false -- Ha true akkor a getPlayerDeveloper funkció nem checkeli a loggedIn-t
serverColor = 'red'
serverName = 'CountrySide'
hexCode = colors[serverColor][4]
low = hexCode .. '[' .. serverName .. ']: #FFFFFF'
local serverSide = false
addEventHandler("onResourceStart", resourceRoot,
    function()
        serverSide = true
    end
)

serverData = {
    --['dataname'] = unknow,
    ['sponsor'] = 'Ken',
    ['developer'] = 'Huzina Patrik, Edison', 
	['designer'] = 'Tx', 
    ['owner'] = 'DX',
	['version'] = "V1.0",
    ['name'] = serverName,
    ['color'] = serverColor,
	['mod'] = 'CountrySide',
	['city'] = 'Red County',
	['minScreenSize'] = {1024, 768},
	['defaultBlurLevel'] = 0,
	['syntax'] = low,
}

function getVersion()
    return serverData["version"]
end

function converType(t)
    if t == "error" then
        return 'red'
    elseif t == "info" then
        return 'blue'
    elseif t == "warning" then
        return 'yellow'
    elseif t == "success" then
        return 'green'
    end
    
    return nil
end

function getServerSyntax(extra, t)
    if extra and type(extra) == "table" then
        local extra = extra["text"]
        if extra then
            if t then
                if colors[t] then
                    return colors[t][4] .. '[' .. extra .. ']: #FFFFFF'
                else
                    return colors[converType(t)][4] .. '[' .. extra .. ']: #FFFFFF'
                end
            else
                return hexCode .. '[' .. extra .. ']: #FFFFFF'
            end
        end
    elseif extra and type(extra) == "string" then
        if t then
            if colors[t] then
                return colors[t][4] .. '[' .. serverName .. ' - ' .. extra .. ']: #FFFFFF'
            else
                return colors[converType(t)][4] .. '[' .. serverName .. ' - ' .. extra .. ']: #FFFFFF'
            end
        else
            return hexCode .. '[' .. serverName .. ' - ' .. extra .. ']: #FFFFFF'
        end
    else
        if t then
            if colors[t] then
                return colors[t][4] .. '[' .. serverName .. ']: #FFFFFF'
            else
                return colors[converType(t)][4] .. '[' .. serverName .. ']: #FFFFFF'
            end
        else
            return serverData['syntax']
        end
    end
end

local fSyntax = getServerSyntax(false, "success")

function findPlayer(sourcePlayer, id, skipMessage)
    if id and #id >= 1 then
        if id == "*" or id == "me" or utfSub(id, 1, 1) == "*" then
            return sourcePlayer
        end

        local table = {}
        for k,v in pairs(getElementsByType("player")) do
            local name = string.lower(getElementData(v, "char >> name") or getPlayerName(v))
            local logged = false
            if utfSub(name, 1, #id) == string.lower(id) then
                table[#table + 1] = {v, name}
                logged = true
            end
            local adminname = string.lower(exports['cr_admin']:getAdminName(v))
            if utfSub(adminname, 1, #id) == string.lower(id) and not logged then
                table[#table + 1] = {v, adminname}
                logged = true
            end
            local number = tonumber(getElementData(v, "char >> id"))
            local number2 = tonumber(id)
            if number == number2 and not logged then
                table[#table + 1] = {v, adminname}
                logged = true
            end
        end

        if #table == 0 then
            --[[
            if serverSide then
                outputChatBox(fSyntax .. "Nincs találat ("..id.."-ra/re)", sourcePlayer, 255, 255, 255, true)
            else
                outputChatBox(fSyntax .. "Nincs találat ("..id.."-ra/re)", 255, 255, 255, true)
            end
            --]]
            return false 
        elseif #table == 1 then
            return table[1][1]
        elseif #table > 1 then
        	if not skipMessage then
	            if serverSide then
	                outputChatBox(fSyntax .. "Találatok: ("..id.."-ra/re)", sourcePlayer, 255, 255, 255, true)
	                for k,v in pairs(table) do
	                    local name = v[2]
	                    local id = getElementData(v[1], "char >> id")
	                    outputChatBox(name .. "("..id..")", sourcePlayer, 255, 255, 255, true)
	                end
	            else
	                outputChatBox(fSyntax .. "Találatok: ("..id.."-ra/re)", 255, 255, 255, true)
	                for k,v in pairs(table) do
	                    local name = v[2]
	                    local id = getElementData(v[1], "char >> id")
	                    outputChatBox(name .. "("..id..")", 255, 255, 255, true)
	                end
	            end
	        end
        end
    end
    
    return false
end

function getServerColor(color, hexCode)
    if not hexCode then
	    local r,g,b = colors[serverColor][1], colors[serverColor][2], colors[serverColor][3]
		if color and colors[color] then
		    r,g,b = colors[color][1], colors[color][2], colors[color][3]
		end
		return r,g,b
	else
	    local hex = colors[serverColor][4]
		if color and colors[color] then
		    hex = colors[color][4]
		end
		return hex
	end
end

function getServerData(dataName)
    local data = 'unknown'
    if dataName then
	    local value = serverData[dataName]
	    if value then
		    data = value
		end
	end
	return data
end

function getMinScreenSize() 
    return serverData['minScreenSize']
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

local times = {
    ['month'] = {
	    [0] = "Január",
		[1] = "Febrár", 
		[2] = "Március", 
		[3] = "Április", 
		[4] = "Május",
		[5] = "Június",
		[6] = "Júlis", 
		[7] = "Augusztus",
		[8] = "Szeptember",
		[9] = "Október",
		[10] = "November",
		[11] = "December",
	},
    ['week'] = {
	    [0] = "Vasárnap",
		[1] = "Hétfő", 
		[2] = "Kedd", 
		[3] = "Szerda", 
		[4] = "Csütörtök",
		[5] = "Péntek",
		[6] = "Szombat", 
	},
}

local _getElementType = getElementType
function getElementType(element)
    if _getElementType(element) == "player" then
        return 1, "player"
    elseif _getElementType(element) == "vehicle" then
        return 2, "vehicle"
    elseif _getElementType(element) == "object" then
        return 3, "object"
    else
        return 4, _getElementType(element)
    end
end

local elementData = {
    [1] = "char >> id",
    [2] = "vehicle >> id",
    [3] = "object >> id",
    [4] = "acc >> id",
}

function getElementIDName(element)
    local elementid = elementData[getElementType(element)]
    if elementid then
        return elementid
    end
    return -1
end

function getElementID(element)
    local elementid = elementData[getElementType(element)]
    if elementid then
        return tonumber(getElementData(element, elementid) or -1)
    end
    return -1
end

function getTimeStringByNumber(timevalue, number)
    if times[timevalue] and times[timevalue][number] then
	    return times[timevalue][number]
	end
	return false
end

_getTime = getTime
function getTime(between, between2)
    if not between then 
        between = "-"
    end 

    if not between2 then 
        between2 = ":"
    end 

    local time = getRealTime()
    local hour = time.hour
    local minute = time.minute
    local month = time.month + 1
    local monthday = time.monthday
    local year = 1900 + time.year

    if hour < 10 then
        hour = "0" .. tostring(hour)
    end

    if minute < 10 then
        minute = "0" .. tostring(minute)
    end

    if month < 10 then
        month = "0" .. tostring(month)
    end

    if monthday < 10 then
        monthday = "0" .. tostring(monthday)
    end

    return "["..year..between..month..between..monthday.." "..hour..between2..minute.."]"
end

function getDatum(between)
    if not between then 
        between = "-"
    end 

    local time = getRealTime()
    local hour = time.hour
    local minute = time.minute
    local month = time.month + 1
    local monthday = time.monthday
    local year = 1900 + time.year

    if hour < 10 then
        hour = "0" .. tostring(hour)
    end

    if minute < 10 then
        minute = "0" .. tostring(minute)
    end

    if month < 10 then
        month = "0" .. tostring(month)
    end

    if monthday < 10 then
        monthday = "0" .. tostring(monthday)
    end

    return year..between..month..between..monthday
end

-----------STRING FUNKCIÓK-----------
function stringInsert(value, insert, place)
	local isLen = string.len(value)
	if isLen > place then
		return string.sub(value, 1,place-1) .. tostring(insert) .. string.sub(value, place, string.len(value))
	else
		return value
	end
end

function split(s)
	local newString = s
	newString = stringInsert(newString, "\n", 34)
	newString = stringInsert(newString, "\n", 68)
	newString = stringInsert(newString, "\n", 102)
	newString = stringInsert(newString, "\n", 136)
	newString = stringInsert(newString, "\n", 170)
	newString = stringInsert(newString, "\n", 204)
	newString = stringInsert(newString, "\n", 238)
    return newString
end

function modifyString(str)
	if str then
		return tostring(split(str))
	end
end

function math.round(number, decimals, method) 
    decimals = decimals or 0 
    local factor = 10 ^ decimals 
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor 
    else return tonumber(("%."..decimals.."f"):format(number)) end 
end 

function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function thousandsStepper(amount)
	local formatted = amount
	
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
		if (k==0) then
			break
		end
	end

	return formatted
end

function formatTimeStamp(t, onlyDatum)
    local time = getRealTime(t)
    local year = time.year
    local month = time.month+1
    local day = time.monthday
    local hours = time.hour
    local minutes = time.minute
    local seconds = time.second
    if(month < 10) then
        month = "0"..month
    end
    if(day < 10) then
        day = "0"..day
    end
    if (hours < 10) then
        hours = "0"..hours
    end
    if (minutes < 10) then
        minutes = "0"..minutes
    end
    if (seconds < 10) then
        seconds = "0"..seconds
    end
    return 1900+year .. "." ..  month .. "." .. day .. (onlyDatum and '' or (" - " .. hours .. ":" .. minutes))
end

function table.val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v ) or tostring( v )
	end
end

function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end

function table.tostring(tbl)
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, table.val_to_str( v ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
			table.insert( result,
			table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end

function getTreeCentre(model)
	if model == 7607 then
		return 0, 0, 0
	elseif model == 7608 then
		return -2, 0, 0
	elseif model == 7637 then
		return -1, 0, 0
	elseif model == 7638 then
		return 0, 0, 0
	end
end

function getTreeStart(model)
	if model == 7607 then
		return 1, 0, 0
	elseif model == 7608 then
		return 0, 0, 0
	elseif model == 7637 then
		return 2, 0, 0
	elseif model == 7638 then
		return 4, 0, 0
	end
end

function getTreeEnd(model)
	if model == 7607 then
		return -1, 0, 0
	elseif model == 7608 then
		return -4, 0, 0
	elseif model == 7637 then
		return -4, 0, 0
	elseif model == 7638 then
		return -4, 0, 0
	end
end

function getRealGroundPosition(x, y, z)
	local hit, hitX, hitY, hitZ = processLineOfSight(x, y, z+10, x, y, z-10, true, false, false, true)
	if hit then
		return hitZ
	else
		return nil
	end
end

function toFloor(num)
	return tonumber(string.sub(tostring(num), 0, -2)) or 0
end

local firstName = { "Jacob","Michael","Ethan","Joshua","Daniel","Alexander","Anthony","William","Christopher","Matthew","Jayden","Andrew","Joseph","David","Noah","Aiden","James","Ryan","Logan","John","Nathan","Elijah","Christian","Gabriel","Benjamin","Jonathan","Tyler","Samuel","Nicholas","Gavin","Dylan","Jackson","Brandon","Caleb","Mason","Angel","Isaac","Evan","Jack","Kevin","Jose","Isaiah","Luke","Landon","Justin","Lucas","Zachary","Jordan","Robert","Aaron","Brayden","Thomas","Cameron","Hunter","Austin","Adrian","Connor","Owen","Aidan","Jason","Julian","Wyatt","Charles","Luis","Carter","Juan","Chase","Diego","Jeremiah","Brody","Xavier","Adam","Carlos","Sebastian","Liam","Hayden","Nathaniel","Henry","Jesus","Ian","Tristan","Bryan","Sean","Cole","Alex","Eric","Brian","Jaden","Carson","Blake","Ayden","Cooper","Dominic","Brady","Caden","Josiah","Kyle","Colton","Kaden","Eli","Miguel","Antonio","Parker","Steven","Alejandro","Riley","Richard","Timothy","Devin","Jesse","Victor","Jake","Joel","Colin","Kaleb","Bryce","Levi","Oliver","Oscar","Vincent","Ashton","Cody","Micah","Preston","Marcus","Max","Patrick","Seth","Jeremy","Peyton","Nolan","Ivan","Damian","Maxwell","Alan","Kenneth","Jonah","Jorge","Mark","Giovanni","Eduardo","Grant","Collin","Gage","Omar","Emmanuel","Trevor","Edward","Ricardo","Cristian","Nicolas","Kayden","George","Jaxon","Paul","Braden","Elias","Andres","Derek","Garrett","Tanner","Malachi","Conner","Fernando","Cesar","Javier","Miles","Jaiden","Alexis","Leonardo","Santiago","Francisco","Cayden","Shane","Edwin","Hudson","Travis","Bryson","Erick","Jace","Hector","Josue","Peter","Jaylen","Mario","Manuel","Abraham","Grayson","Damien","Kaiden","Spencer","Stephen","Edgar","Wesley","Shawn","Trenton","Jared","Jeffrey","Landen","Johnathan","Bradley","Braxton","Ryder","Camden","Roman","Asher","Brendan","Maddox","Sergio","Israel","Andy","Lincoln","Erik","Donovan","Raymond","Avery","Rylan","Dalton","Harrison","Andre","Martin","Keegan","Marco","Jude","Sawyer","Dakota","Leo","Calvin","Kai","Drake","Troy","Zion","Clayton","Roberto","Zane","Gregory","Tucker","Rafael","Kingston","Dominick","Ezekiel","Griffin","Devon","Drew","Lukas","Johnny","Ty","Pedro","Tyson","Caiden","Mateo","Braylon","Cash","Aden","Chance","Taylor","Marcos","Maximus","Ruben","Emanuel","Simon","Corbin","Brennan","Dillon","Skyler","Myles","Xander","Jaxson","Dawson","Kameron","Kyler","Axel","Colby","Jonas","Joaquin","Payton","Brock","Frank","Enrique","Quinn","Emilio","Malik","Grady","Angelo","Julio","Derrick","Raul","Fabian","Corey","Gerardo","Dante","Ezra","Armando","Allen","Theodore","Gael","Amir","Zander","Adan","Maximilian","Randy","Easton","Dustin","Luca","Phillip","Julius","Charlie","Ronald","Jakob","Cade","Brett","Trent","Silas","Keith","Emiliano","Trey","Jalen","Darius","Lane","Jerry","Jaime","Scott","Graham","Weston","Braydon","Anderson","Rodrigo","Pablo","Saul","Danny","Donald","Elliot","Brayan","Dallas","Lorenzo","Casey","Mitchell","Alberto","Tristen","Rowan","Jayson","Gustavo","Aaden","Amari","Dean","Braeden","Declan","Chris","Ismael","Dane","Louis","Arturo","Brenden","Felix","Jimmy","Cohen","Tony","Holden","Reid","Abel","Bennett","Zackary","Arthur","Nehemiah","Ricky","Esteban","Cruz","Finn","Mauricio","Dennis","Keaton","Albert","Marvin","Mathew","Larry","Moises","Issac","Philip","Quentin","Curtis","Greyson","Jameson","Everett","Jayce","Darren","Elliott","Uriel","Alfredo","Hugo","Alec","Jamari","Marshall","Walter","Judah","Jay","Lance","Beau","Ali","Landyn","Yahir","Phoenix","Nickolas","Kobe","Bryant","Maurice","Russell","Leland","Colten","Reed","Davis","Joe","Ernesto","Desmond","Kade","Reece","Morgan","Ramon","Rocco","Orlando","Ryker","Brodie","Paxton","Jacoby","Douglas","Kristopher","Gary","Lawrence","Izaiah","Solomon","Nikolas","Mekhi","Justice","Tate","Jaydon","Salvador","Shaun","Alvin","Eddie","Kane","Davion","Zachariah","Dorian","Titus","Kellen","Camron","Isiah","Javon","Nasir","Milo","Johan","Byron","Jasper","Jonathon","Chad","Marc","Kelvin","Chandler","Sam","Cory","Deandre","River","Reese","Roger","Quinton","Talon","Romeo","Franklin","Noel","Alijah","Guillermo","Gunner","Damon","Jadon","Emerson","Micheal","Bruce","Terry","Kolton","Melvin","Beckett","Porter","August","Brycen","Dayton","Jamarion","Leonel","Karson","Zayden","Keagan","Carl","Khalil","Cristopher","Nelson","Braiden","Moses","Isaias","Roy","Triston","Walker","Kale","Jermaine","Leon","Rodney","Kristian","Mohamed","Ronan","Pierce","Trace","Warren","Jeffery","Maverick","Cyrus","Quincy","Nathanael","Skylar","Tommy","Conor","Noe","Ezequiel","Demetrius","Jaylin","Kendrick","Frederick","Terrance","Bobby","Jamison","Jon","Rohan","Jett","Kieran","Tobias","Ari","Colt","Gideon","Felipe","Kenny","Wilson","Orion","Kamari","Gunnar","Jessie","Alonzo","Gianni","Omari","Waylon","Malcolm","Emmett","Abram","Julien","London","Tomas","Allan","Terrell","Matteo","Tristin","Jairo","Reginald","Brent","Ahmad","Yandel","Rene","Willie","Boston","Billy","Marlon","Trevon","Aydan","Jamal","Aldo","Ariel","Cason","Braylen","Javion","Joey","Rogelio","Ahmed","Dominik","Brendon","Toby","Kody","Marquis","Ulises","Armani","Adriel","Alfonso","Branden","Will","Craig","Ibrahim","Osvaldo","Wade","Harley","Steve","Davin","Deshawn","Kason","Damion","Jaylon","Jefferson","Aron","Brooks","Darian","Gerald","Rolando","Terrence","Enzo","Kian","Ryland","Barrett","Jaeden","Ben","Bradyn","Giovani","Blaine","Madden","Jerome","Muhammad","Ronnie","Layne","Kolby","Leonard","Vicente","Cale","Alessandro","Zachery","Gavyn","Aydin","Xzavier","Malakai","Raphael","Cannon","Rudy","Asa","Darrell","Giancarlo","Elisha","Junior","Zackery","Alvaro","Lewis","Valentin","Deacon","Jase","Harry","Kendall","Rashad","Finnegan","Mohammed","Ramiro","Cedric","Brennen","Santino","Stanley","Tyrone","Chace","Francis","Johnathon","Teagan","Zechariah","Alonso","Kaeden","Kamden","Gilberto","Ray","Karter","Luciano","Nico","Kole","Aryan","Draven","Jamie","Misael","Lee","Alexzander","Camren","Giovanny","Amare","Rhett","Rhys","Rodolfo","Nash","Markus","Deven","Mohammad","Moshe","Quintin","Dwayne","Memphis","Atticus","Davian","Eugene","Jax","Antoine","Wayne","Randall","Semaj","Uriah","Clark","Aidyn","Jorden","Maxim","Aditya","Lawson","Messiah","Korbin","Sullivan","Freddy","Demarcus","Neil","Brice","King","Davon","Elvis","Ace","Dexter","Heath","Duncan","Jamar","Sincere","Irvin","Remington","Kadin","Soren","Tyree","Damarion","Talan","Adrien","Gilbert","Keenan","Darnell","Adolfo","Tristian","Derick","Isai","Rylee","Gauge","Harold","Kareem","Deangelo","Agustin","Coleman","Zavier","Lamar","Emery","Jaydin","Devan","Jordyn","Mathias","Prince","Sage","Seamus","Jasiah","Efrain","Darryl","Arjun","Mike","Roland","Conrad","Kamron","Hamza","Santos","Frankie","Dominique","Marley","Vance","Dax","Jamir","Kylan","Todd","Maximo","Jabari","Matthias","Haiden","Luka","Marcelo","Keon","Layton","Tyrell","Kash","Raiden","Cullen","Donte","Jovani","Cordell","Kasen","Rory","Alfred","Darwin","Ernest","Bailey","Gaige","Hassan","Jamarcus","Killian","Augustus","Trevin","Zain","Ellis","Rex","Yusuf","Bruno","Jaidyn","Justus","Ronin","Humberto","Jaquan","Josh","Kasey","Winston","Dashawn","Lucian","Matias","Sidney","Ignacio","Nigel","Van","Elian","Finley","Jaron","Addison","Aedan","Braedon","Jadyn","Konner","Zayne","Franco","Niko","Savion","Cristofer","Deon","Krish","Anton","Brogan","Cael","Coby","Kymani","Marcel","Yair","Dale","Bo","Jordon","Samir","Darien","Zaire","Ross","Vaughn","Devyn","Kenyon","Clay","Dario","Ishaan","Jair","Kael","Adonis","Jovanny","Clinton","Rey","Chaim","German","Harper","Nathen","Rigoberto","Sonny","Glenn","Octavio","Blaze","Keshawn","Ralph","Ean","Nikhil","Rayan","Sterling","Branson","Jadiel","Dillan","Jeramiah","Koen","Konnor","Antwan","Houston","Tyrese","Dereon","Leonidas","Zack","Fisher","Jaydan","Quinten","Nick","Urijah","Darion","Jovan","Salvatore","Beckham","Jarrett","Antony","Eden","Makai","Zaiden","Broderick","Camryn","Malaki","Nikolai","Howard","Immanuel","Demarion","Valentino","Jovanni","Ayaan","Ethen","Leandro","Royce","Yael","Yosef","Jean","Marquise","Alden","Leroy","Gaven","Jovany","Tyshawn","Aarav","Kadyn","Milton","Zaid","Kelton","Tripp","Kamren","Slade","Hezekiah","Jakobe","Nathanial","Rishi","Shamar","Geovanni","Pranav","Roderick","Bentley","Clarence","Lyric","Bernard","Carmelo","Denzel","Maximillian","Reynaldo","Cassius","Gordon","Reuben","Samson","Yadiel","Jayvon","Reilly","Sheldon","Abdullah","Jagger","Thaddeus","Case","Kyson","Lamont","Chaz","Makhi","Jan","Marques","Oswaldo","Donavan","Keyon","Kyan","Simeon","Trystan","Andreas","Dangelo","Landin","Reagan","Turner","Arnav","Brenton","Callum","Jayvion","Bridger","Sammy","Deegan","Jaylan","Lennon","Odin","Abdiel","Jerimiah","Eliezer","Bronson","Cornelius","Pierre","Cortez","Baron","Carlo","Carsen","Fletcher","Izayah","Kolten","Damari","Hugh","Jensen","Yurem" }
local lastName = { "Smith","Johnson","Williams","Brown","Jones","Miller","Davis","Garcia","Rodriguez","Wilson","Martinez","Anderson","Taylor","Thomas","Hernandez","Moore","Martin","Jackson","Thompson","White","Lopez","Lee","Gonzalez","Harris","Clark","Lewis","Robinson","Walker","Perez","Hall","Young","Allen","Sanchez","Wright","King","Scott","Green","Baker","Adams","Nelson","Hill","Ramirez","Campbell","Mitchell","Roberts","Carter","Phillips","Evans","Turner","Torres","Parker","Collins","Edwards","Stewart","Flores","Morris","Nguyen","Murphy","Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett","Gray","James","Reyes","Cruz","Hughes","Price","Myers","Long","Foster","Sanders","Ross","Morales","Powell","Sullivan","Russell","Ortiz","Jenkins","Gutierrez","Perry","Butler","Barnes","Fisher","Henderson","Coleman","Simmons","Patterson","Jordan","Reynolds","Hamilton","Graham","Kim","Gonzales","Alexander","Ramos","Wallace","Griffin","West","Cole","Hayes","Chavez","Gibson","Bryant","Ellis","Stevens","Murray","Ford","Marshall","Owens","Mcdonald","Harrison","Ruiz","Kennedy","Wells","Alvarez","Woods","Mendoza","Castillo","Olson","Webb","Washington","Tucker","Freeman","Burns","Henry","Vasquez","Snyder","Simpson","Crawford","Jimenez","Porter","Mason","Shaw","Gordon","Wagner","Hunter","Romero","Hicks","Dixon","Hunt","Palmer","Robertson","Black","Holmes","Stone","Meyer","Boyd","Mills","Warren","Fox","Rose","Rice","Moreno","Schmidt","Patel","Ferguson","Nichols","Herrera","Medina","Ryan","Fernandez","Weaver","Daniels","Stephens","Gardner","Payne","Kelley","Dunn","Pierce","Arnold","Tran","Spencer","Peters","Hawkins","Grant","Hansen","Castro","Hoffman","Hart","Elliott","Cunningham","Knight","Bradley","Carroll","Hudson","Duncan","Armstrong","Berry","Andrews","Johnston","Ray","Lane","Riley","Carpenter","Perkins","Aguilar","Silva","Richards","Willis","Matthews","Chapman","Lawrence","Garza","Vargas","Watkins","Wheeler","Larson","Carlson","Harper","George","Greene","Burke","Guzman","Morrison","Munoz","Jacobs","Obrien","Lawson","Franklin","Lynch","Bishop","Carr","Salazar","Austin","Mendez","Gilbert","Jensen","Williamson","Montgomery","Harvey","Oliver","Howell","Dean","Hanson","Weber","Garrett","Sims","Burton","Fuller","Soto","Mccoy","Welch","Chen","Schultz","Walters","Reid","Fields","Walsh","Little","Fowler","Bowman","Davidson","May","Day","Schneider","Newman","Brewer","Lucas","Holland","Wong","Banks","Santos","Curtis","Pearson","Delgado","Valdez","Pena","Rios","Douglas","Sandoval","Barrett","Hopkins","Keller","Guerrero","Stanley","Bates","Alvarado","Beck","Ortega","Wade","Estrada","Contreras","Barnett","Caldwell","Santiago","Lambert","Powers","Chambers","Nunez","Craig","Leonard","Lowe","Rhodes","Byrd","Gregory","Shelton","Frazier","Becker","Maldonado","Fleming","Vega","Sutton","Cohen","Jennings","Parks","Mcdaniel","Watts","Barker","Norris","Vaughn","Vazquez","Holt","Schwartz","Steele","Benson","Neal","Dominguez","Horton","Terry","Wolfe","Hale","Lyons","Graves","Haynes","Miles","Park","Warner","Padilla","Bush","Thornton","Mccarthy","Mann","Zimmerman","Erickson","Fletcher","Mckinney","Page","Dawson","Joseph","Marquez","Reeves","Klein","Espinoza","Baldwin","Moran","Love","Robbins","Higgins","Ball","Cortez","Le","Griffith","Bowen","Sharp","Cummings","Ramsey","Hardy","Swanson","Barber","Acosta","Luna","Chandler","Blair","Daniel","Cross","Simon","Dennis","Oconnor","Quinn","Gross","Navarro","Moss","Fitzgerald","Doyle","Mclaughlin","Rojas","Rodgers","Stevenson","Singh","Yang","Figueroa","Harmon","Newton","Paul","Manning","Garner","Mcgee","Reese","Francis","Burgess","Adkins","Goodman","Curry","Brady","Christensen","Potter","Walton","Goodwin","Mullins","Molina","Webster","Fischer","Campos","Avila","Sherman","Todd","Chang","Blake","Malone","Wolf","Hodges","Juarez","Gill","Farmer","Hines","Gallagher","Duran","Hubbard","Cannon","Miranda","Wang","Saunders","Tate","Mack","Hammond","Carrillo","Townsend","Wise","Ingram","Barton","Mejia","Ayala","Schroeder","Hampton","Rowe","Parsons","Frank","Waters","Strickland","Osborne","Maxwell","Chan","Deleon","Norman","Harrington","Casey","Patton","Logan","Bowers","Mueller","Glover","Floyd","Hartman","Buchanan","Cobb","French","Kramer","Mccormick","Clarke","Tyler","Gibbs","Moody","Conner","Sparks","Mcguire","Leon","Bauer","Norton","Pope","Flynn","Hogan","Robles","Salinas","Yates","Lindsey","Lloyd","Marsh","Mcbride","Owen","Solis","Pham","Lang","Pratt","Lara","Brock","Ballard","Trujillo","Shaffer","Drake","Roman","Aguirre","Morton","Stokes","Lamb","Pacheco","Patrick","Cochran","Shepherd","Cain","Burnett","Hess","Li","Cervantes","Olsen","Briggs","Ochoa","Cabrera","Velasquez","Montoya","Roth","Meyers","Cardenas","Fuentes","Weiss","Hoover","Wilkins","Nicholson","Underwood","Short","Carson","Morrow","Colon","Holloway","Summers","Bryan","Petersen","Mckenzie","Serrano","Wilcox","Carey","Clayton","Poole","Calderon","Gallegos","Greer","Rivas","Guerra","Decker","Collier","Wall","Whitaker","Bass","Flowers","Davenport","Conley","Houston","Huff","Copeland","Hood","Monroe","Massey","Roberson","Combs","Franco","Larsen","Pittman","Randall","Skinner","Wilkinson","Kirby","Cameron","Bridges","Anthony","Richard","Kirk","Bruce","Singleton","Mathis","Bradford","Boone","Abbott","Charles","Allison","Sweeney","Atkinson","Horn","Jefferson","Rosales","York","Christian","Phelps","Farrell","Castaneda","Nash","Dickerson","Bond","Wyatt","Foley","Chase","Gates","Vincent","Mathews","Hodge","Garrison","Trevino","Villarreal","Heath","Dalton","Valencia","Callahan","Hensley","Atkins","Huffman","Roy","Boyer","Shields","Lin","Hancock","Grimes","Glenn","Cline","Delacruz","Camacho","Dillon","Parrish","Oneill","Melton","Booth","Kane","Berg","Harrell","Pitts","Savage","Wiggins","Brennan","Salas","Marks","Russo","Sawyer","Baxter","Golden","Hutchinson","Liu","Walter","Mcdowell","Wiley","Rich","Humphrey","Johns","Koch","Suarez","Hobbs","Beard","Gilmore","Ibarra","Keith","Macias","Khan","Andrade","Ware","Stephenson","Henson","Wilkerson","Dyer","Mcclure","Blackwell","Mercado","Tanner","Eaton","Clay","Barron","Beasley","Oneal","Preston","Small","Wu","Zamora","Macdonald","Vance","Snow","Mcclain","Stafford","Orozco","Barry","English","Shannon","Kline","Jacobson","Woodard","Huang","Kemp","Mosley","Prince","Merritt","Hurst","Villanueva","Roach","Nolan","Lam","Yoder","Mccullough","Lester","Santana","Valenzuela","Winters","Barrera","Leach","Orr","Berger","Mckee","Strong","Conway","Stein","Whitehead","Bullock","Escobar","Knox","Meadows","Solomon","Velez","Odonnell","Kerr","Stout","Blankenship","Browning","Kent","Lozano","Bartlett","Pruitt","Buck","Barr","Gaines","Durham","Gentry","Mcintyre","Sloan","Melendez","Rocha","Herman","Sexton","Moon","Hendricks","Rangel","Stark","Lowery","Hardin","Hull","Sellers","Ellison","Calhoun","Gillespie","Mora","Knapp","Mccall","Morse","Dorsey","Weeks","Nielsen","Livingston","Leblanc","Mclean","Bradshaw","Glass","Middleton","Buckley","Schaefer","Frost","Howe","House","Mcintosh","Ho","Pennington","Reilly","Hebert","Mcfarland","Hickman","Noble","Spears","Conrad","Arias","Galvan","Velazquez","Huynh","Frederick","Randolph","Cantu","Fitzpatrick","Mahoney","Peck","Villa","Michael","Donovan","Mcconnell","Walls","Boyle","Mayer","Zuniga","Giles","Pineda","Pace","Hurley","Mays","Mcmillan","Crosby","Ayers","Case","Bentley","Shepard","Everett","Pugh","David","Mcmahon","Dunlap","Bender","Hahn","Harding","Acevedo","Raymond","Blackburn","Duffy","Landry","Dougherty","Bautista","Shah","Potts","Arroyo","Valentine","Meza","Gould","Vaughan","Fry","Rush","Avery","Herring","Dodson","Clements","Sampson","Tapia","Bean","Lynn","Crane","Farley","Cisneros","Benton","Ashley","Mckay","Finley","Best","Blevins","Friedman","Moses","Sosa","Blanchard","Huber","Frye","Krueger","Bernard","Rosario","Rubio","Mullen","Benjamin","Haley","Chung","Moyer","Choi","Horne","Yu","Woodward","Ali","Nixon","Hayden","Rivers","Estes","Mccarty","Richmond","Stuart","Maynard","Brandt","Oconnell","Hanna","Sanford","Sheppard","Church","Burch","Levy","Rasmussen","Coffey","Ponce","Faulkner","Donaldson","Schmitt","Novak","Costa","Montes","Booker","Cordova","Waller","Arellano","Maddox","Mata","Bonilla","Stanton","Compton","Kaufman","Dudley","Mcpherson","Beltran","Dickson","Mccann","Villegas","Proctor","Hester","Cantrell","Daugherty","Cherry","Bray","Davila","Rowland","Levine","Madden","Spence","Good","Irwin","Werner","Krause","Petty","Whitney","Baird","Hooper","Pollard","Zavala","Jarvis","Holden","Haas","Hendrix","Mcgrath","Bird","Lucero","Terrell","Riggs","Joyce","Mercer","Rollins","Galloway","Duke","Odom","Andersen","Downs","Hatfield","Benitez","Archer","Huerta","Travis","Mcneil","Hinton","Zhang","Hays","Mayo","Fritz","Branch","Mooney","Ewing","Ritter","Esparza","Frey","Braun","Gay","Riddle","Haney","Kaiser","Holder","Chaney","Mcknight","Gamble","Vang","Cooley","Carney","Cowan","Forbes","Ferrell","Davies","Barajas","Shea","Osborn","Bright","Cuevas","Bolton","Murillo","Lutz","Duarte","Kidd","Key","Cooke" }

function createRandomMaleName()
	local random1 = math.random(1, #firstName)
	local random2 = math.random(1, #lastName)
	local name = firstName[random1].." "..lastName[random2]
	return name
end

local femaleFirstname = { "Emma","Isabella","Emily","Madison","Ava","Olivia","Sophia","Abigail","Elizabeth","Chloe","Samantha","Addison","Natalie","Mia","Alexis","Alyssa","Hannah","Ashley","Ella","Sarah","Grace","Taylor","Brianna","Lily","Hailey","Anna","Victoria","Kayla","Lillian","Lauren","Kaylee","Allison","Savannah","Nevaeh","Gabriella","Sofia","Makayla","Avery","Riley","Julia","Leah","Aubrey","Jasmine","Audrey","Katherine","Morgan","Brooklyn","Destiny","Sydney","Alexa","Kylie","Brooke","Kaitlyn","Evelyn","Layla","Madeline","Kimberly","Zoe","Jessica","Peyton","Alexandra","Claire","Madelyn","Maria","Mackenzie","Arianna","Jocelyn","Amelia","Angelina","Trinity","Andrea","Maya","Valeria","Sophie","Rachel","Vanessa","Aaliyah","Mariah","Gabrielle","Katelyn","Ariana","Bailey","Camila","Jennifer","Melanie","Gianna","Charlotte","Paige","Autumn","Payton","Faith","Sara","Isabelle","Caroline","Genesis","Isabel","Mary","Zoey","Gracie","Megan","Haley","Mya","Michelle","Molly","Stephanie","Nicole","Jenna","Natalia","Sadie","Jada","Serenity","Lucy","Ruby","Eva","Kennedy","Rylee","Jayla","Naomi","Rebecca","Lydia","Daniela","Bella","Keira","Adriana","Lilly","Hayden","Miley","Katie","Jade","Jordan","Gabriela","Amy","Angela","Melissa","Valerie","Giselle","Diana","Amanda","Kate","Laila","Reagan","Jordyn","Kylee","Danielle","Briana","Marley","Leslie","Kendall","Catherine","Liliana","Mckenzie","Jacqueline","Ashlyn","Reese","Marissa","London","Juliana","Shelby","Cheyenne","Angel","Daisy","Makenzie","Miranda","Erin","Amber","Alana","Ellie","Breanna","Ana","Mikayla","Summer","Piper","Adrianna","Jillian","Sierra","Jayden","Sienna","Alicia","Lila","Margaret","Alivia","Brooklynn","Karen","Violet","Sabrina","Stella","Aniyah","Annabelle","Alexandria","Kathryn","Skylar","Aliyah","Delilah","Julianna","Kelsey","Khloe","Carly","Amaya","Mariana","Christina","Alondra","Tessa","Eliana","Bianca","Jazmin","Clara","Vivian","Josephine","Delaney","Scarlett","Elena","Cadence","Alexia","Maggie","Laura","Nora","Ariel","Elise","Nadia","Mckenna","Chelsea","Lyla","Alaina","Jasmin","Hope","Leila","Caitlyn","Cassidy","Makenna","Allie","Izabella","Eden","Callie","Haylee","Caitlin","Kendra","Karina","Kyra","Kayleigh","Addyson","Kiara","Jazmine","Karla","Camryn","Alina","Lola","Kyla","Kelly","Fatima","Tiffany","Kira","Crystal","Mallory","Esmeralda","Alejandra","Eleanor","Angelica","Jayda","Abby","Kara","Veronica","Carmen","Jamie","Ryleigh","Valentina","Allyson","Dakota","Kamryn","Courtney","Cecilia","Madeleine","Aniya","Alison","Esther","Heaven","Aubree","Lindsey","Leilani","Nina","Melody","Macy","Ashlynn","Joanna","Cassandra","Alayna","Kaydence","Madilyn","Aurora","Heidi","Emerson","Kimora","Madalyn","Erica","Josie","Katelynn","Guadalupe","Harper","Ivy","Lexi","Camille","Savanna","Dulce","Daniella","Lucia","Emely","Joselyn","Kiley","Kailey","Miriam","Cynthia","Rihanna","Georgia","Rylie","Harmony","Kiera","Kyleigh","Monica","Bethany","Kaylie","Cameron","Teagan","Cora","Brynn","Ciara","Genevieve","Alice","Maddison","Eliza","Tatiana","Jaelyn","Erika","Ximena","April","Marely","Julie","Danica","Presley","Brielle","Julissa","Angie","Iris","Brenda","Hazel","Rose","Malia","Shayla","Fiona","Phoebe","Nayeli","Paola","Kaelyn","Selena","Audrina","Rebekah","Carolina","Janiyah","Michaela","Penelope","Janiya","Anastasia","Adeline","Ruth","Sasha","Denise","Holly","Madisyn","Hanna","Tatum","Marlee","Nataly","Helen","Janelle","Lizbeth","Serena","Anya","Jaslene","Kaylin","Jazlyn","Nancy","Lindsay","Desiree","Hayley","Itzel","Imani","Madelynn","Asia","Kadence","Madyson","Talia","Jane","Kayden","Annie","Amari","Bridget","Raegan","Jadyn","Celeste","Jimena","Luna","Yasmin","Emilia","Annika","Estrella","Sarai","Lacey","Ayla","Alessandra","Willow","Nyla","Dayana","Lilah","Lilliana","Natasha","Hadley","Harley","Priscilla","Claudia","Allisson","Baylee","Brenna","Brittany","Skyler","Fernanda","Danna","Melany","Cali","Lia","Macie","Lyric","Logan","Gloria","Lana","Mylee","Cindy","Lilian","Amira","Anahi","Alissa","Anaya","Lena","Ainsley","Sandra","Noelle","Marisol","Meredith","Kailyn","Lesly","Johanna","Diamond","Evangeline","Juliet","Kathleen","Meghan","Paisley","Athena","Hailee","Rosa","Wendy","Emilee","Sage","Alanna","Elaina","Cara","Nia","Paris","Casey","Dana","Emery","Rowan","Aubrie","Kaitlin","Jaden","Kenzie","Kiana","Viviana","Norah","Lauryn","Perla","Amiyah","Alyson","Rachael","Shannon","Aileen","Miracle","Lillie","Danika","Heather","Kassidy","Taryn","Tori","Francesca","Kristen","Amya","Elle","Kristina","Cheyanne","Haylie","Patricia","Anne","Samara","Skye","Kali","America","Lexie","Parker","Halle","Londyn","Abbigail","Linda","Hallie","Saniya","Bryanna","Bailee","Jaylynn","Mckayla","Quinn","Jaelynn","Jaida","Caylee","Jaiden","Melina","Abril","Sidney","Kassandra","Elisabeth","Adalyn","Kaylynn","Mercedes","Yesenia","Elliana","Brylee","Dylan","Isabela","Ryan","Ashlee","Daphne","Kenya","Marina","Christine","Mikaela","Kaitlynn","Justice","Saniyah","Jaliyah","Ingrid","Marie","Natalee","Joy","Juliette","Simone","Adelaide","Krystal","Kennedi","Mila","Tamia","Addisyn","Aylin","Dayanara","Sylvia","Clarissa","Maritza","Virginia","Braelyn","Jolie","Jaidyn","Kinsley","Kirsten","Laney","Marilyn","Whitney","Janessa","Raquel","Anika","Kamila","Aria","Rubi","Adelyn","Amara","Ayanna","Teresa","Zariah","Kaleigh","Amani","Carla","Yareli","Gwendolyn","Paulina","Nathalie","Annabella","Jaylin","Tabitha","Deanna","Madalynn","Journey","Aiyana","Skyla","Yaretzi","Ada","Liana","Karlee","Jenny","Myla","Cristina","Myah","Lisa","Tania","Isis","Jayleen","Jordin","Arely","Azul","Helena","Aryanna","Jaqueline","Lucille","Destinee","Martha","Zoie","Arielle","Liberty","Marlene","Elisa","Isla","Noemi","Raven","Jessie","Aleah","Kailee","Kaliyah","Lilyana","Haven","Tara","Giana","Camilla","Maliyah","Irene","Carley","Maeve","Lea","Macey","Sharon","Alisha","Marisa","Jaylene","Kaya","Scarlet","Siena","Adyson","Maia","Shiloh","Tiana","Jaycee","Gisselle","Yazmin","Eve","Shyanne","Arabella","Sherlyn","Sariah","Amiya","Kiersten","Madilynn","Shania","Aleena","Finley","Kinley","Kaia","Aliya","Taliyah","Pamela","Yoselin","Ellen","Carlie","Monserrat","Jakayla","Reyna","Yaritza","Carolyn","Clare","Lorelei","Paula","Zaria","Gracelyn","Kasey","Regan","Alena","Angelique","Regina","Britney","Emilie","Mariam","Jaylee","Julianne","Greta","Elyse","Lainey","Kallie","Felicity","Zion","Aspen","Carlee","Annalise","Iliana","Larissa","Akira","Sonia","Catalina","Phoenix","Joslyn","Anabelle","Mollie","Susan","Judith","Destiney","Hillary","Janet","Katrina","Mareli","Ansley","Kaylyn","Alexus","Gia","Maci","Elsa","Stacy","Kaylen","Carissa","Haleigh","Lorena","Jazlynn","Milagros","Luz","Leanna","Renee","Shaniya","Charlie","Abbie","Cailyn","Cherish","Elsie","Jazmyn","Elaine","Emmalee","Luciana","Dahlia","Jamya","Belinda","Mariyah","Chaya","Dayami","Rhianna","Yadira","Aryana","Rosemary","Armani","Cecelia","Celia","Barbara","Cristal","Eileen","Rayna","Campbell","Amina","Aisha","Amirah","Ally","Araceli","Averie","Mayra","Sanaa","Patience","Leyla","Selah","Zara","Chanel","Kaiya","Keyla","Miah","Aimee","Giovanna","Amelie","Kelsie","Alisson","Angeline","Dominique","Adrienne","Brisa","Cierra","Paloma","Isabell","Precious","Alma","Charity","Jacquelyn","Janae","Frances","Shyla","Janiah","Kierra","Karlie","Annabel","Jacey","Karissa","Jaylah","Xiomara","Edith","Marianna","Damaris","Deborah","Jaylyn","Evelin","Mara","Olive","Ayana","India","Kendal","Kayley","Tamara","Briley","Charlee","Nylah","Abbey","Moriah","Saige","Savanah","Giada","Hana","Lizeth","Matilda","Ann","Jazlene","Gillian","Beatrice","Ireland","Karly","Mylie","Yasmine","Ashly","Kenna","Maleah","Corinne","Keely","Tanya","Tianna","Adalynn","Ryann","Salma","Areli","Karma","Shyann","Kaley","Theresa","Evie","Gina","Roselyn","Kaila","Jaylen","Natalya","Meadow","Rayne","Aliza","Yuliana","June","Lilianna","Nathaly","Ali","Alisa","Aracely","Belen","Tess","Jocelynn","Litzy","Makena","Abagail","Giuliana","Joyce","Libby","Lillianna","Thalia","Tia","Sarahi","Zaniyah","Kristin","Lorelai","Mattie","Taniya","Jaslyn","Gemma","Valery","Lailah","Mckinley","Micah","Deja","Frida","Brynlee","Jewel","Krista","Mira","Yamilet","Adison","Carina","Karli","Magdalena","Stephany","Charlize","Raelynn","Aliana","Cassie","Mina","Karley","Shirley","Marlie","Alani","Taniyah","Cloe","Sanai","Lina","Nola","Anabella","Dalia","Raina","Mariela","Ariella","Bria","Kamari","Monique","Ashleigh","Reina","Alia","Ashanti","Lara","Lilia","Justine","Leia","Maribel","Abigayle","Tiara","Alannah","Princess","Sydnee","Kamora","Paityn","Payten","Naima","Gretchen","Heidy","Nyasia","Livia","Marin","Shaylee","Maryjane","Laci","Nathalia","Azaria","Anabel","Chasity","Emmy","Izabelle","Denisse","Emelia","Mireya","Shea","Amiah","Dixie","Maren","Averi","Esperanza","Micaela","Selina","Alyvia","Chana","Avah","Donna","Kaylah","Ashtyn","Karsyn","Makaila","Shayna","Essence","Leticia","Miya","Rory","Desirae","Kianna","Laurel","Neveah","Amaris","Hadassah","Dania","Hailie","Jamiya","Kathy","Laylah","Riya","Diya","Carleigh","Iyana","Kenley","Sloane","Elianna" }

function createRandomFemaleName()
	local random1 = math.random(1, #femaleFirstname)
	local random2 = math.random(1, #lastName)
	local name = femaleFirstname[random1].." "..lastName[random2]
	return name
end

function createRandomName(sex)
    if not sex or not tonumber(sex) then 
        sex = math.random(1, 2)
    end 

    local data = sex == 1 and firstName or femaleFirstname

    local random1 = math.random(1, #data)
	local random2 = math.random(1, #lastName)

	local name = data[random1].." "..lastName[random2]


	return name, sex
end 

function getRealTimeForIPB(time)
	local time = getRealTime(time)
	local str = ""
	if (time.hour < 10) then
		str = "0"..time.hour
	else
		str = time.hour
	end
	if (time.minute < 10) then
		str = str..":0"..time.minute
	else
		str = str..":"..time.minute
	end
	if (time.second < 10) then
		str = str..":0"..time.second
	else
		str = str..":"..time.second
	end
	return str
end

local jobs = {
    --[id] = "JobName"
    [0] = "Munkanélküli"
}

function convertJobIDtoName(id)
    return jobs[id]
end

function findRotation(x1, y1, x2, y2) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end