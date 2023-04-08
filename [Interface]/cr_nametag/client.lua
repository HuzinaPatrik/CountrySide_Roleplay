local cache = {}
local hitCache = {}
local hitTimerCache = {}
local myname = false
local refreshDatas = {
	["char >> name"] = -1,
	["char >> customName"] = -1,
	["char >> afk"] = "afk",
    ["afk.data"] = "afkData",
    ["respawn.min"] = "respawnData",
    ["respawn"] = "respawn",
    ["char >> chat"] = "chat",
	["char >> console"] = "console",
	["char >> description"] = "description",
	["admin >> name"] = -1,
	["admin >> duty"] = -1,
    ["admin >> level"] = -1,
    ["char >> level"] = -1,
	["char >> id"] = -1,
    ["acc >> id"] = -1,
    ["char >> specText"] = -1,
	["ped.name"] = -1,
    ["ped.type"] = -1,
    ["hunter >> id"] = "hunter >> id",
    ["hunter >> health"] = "hunter >> health",
    ["hunter >> maxHealth"] = "hunter >> maxHealth",
	["deathReason"] = -1,
	["deathReason >> admin"] = -1,
    ["bubbleOn"] = "bubbleOn",
    ["char >> tazed"] = "tazzed",
    ["char >> cuffed"] = "cuffed",
    ["timedout"] = "timedout",
    ["bloodData"] = -1,
    ["inAnim"] = "inAnim",
}

fontsG = {
    --{Name, MaxSize, minSize},
    {"Roboto", 15, 11},
    {"OpenSans", 15, 11},
    {"RobotoB", 15, 11},
    {"FontAwesome", 15, 11},
    {"DeansGateB", 15, 11},
    {"Rubik", 15, 11},
    {"gotham_light", 15, 11},
}

fontID = 1
fontName = fontsG[fontID][1]
fontSizeMax = fontsG[fontID][2]
fontSizeMin = fontsG[fontID][3]

function setFont(id)
    fontID = id
    fontName = fontsG[fontID][1]
    fontSizeMax = fontsG[fontID][2]
    fontSizeMin = fontsG[fontID][3]
end 

function setMyName(val)
    myname = val == 1
    nametag_callDatas(localPlayer)
end 

function setDescriptions(val)
    descriptionsDisabled = val == 0
end 

local logo;
local logos = {
	--["rKzzz"] = dxCreateTexture("logos/rKzzz.png", "dxt5", true, "clamp"),
}

local images = {
	["afk"] = dxCreateTexture("files/afk.png", "dxt5", true, "clamp"),
	["chat"] = dxCreateTexture("files/write.png", "dxt5", true, "clamp"),
	["console"] = dxCreateTexture("files/console.png", "dxt5", true, "clamp"),
    ["dead"] = dxCreateTexture("files/skull.png", "dxt5", true, "clamp"),
    ["taser"] = dxCreateTexture("files/taser.png", "dxt5", true, "clamp"),
    ["respawn"] = dxCreateTexture("files/respawn.png", "dxt5", true, "clamp"),
    ["timedout"] = dxCreateTexture("files/timedout.png", "dxt5", true, "clamp"),
    ["cuffed"] = dxCreateTexture("files/cuffed.png", "dxt5", true, "clamp"),
    ["anim"] = dxCreateTexture("files/anim.png", "dxt5", true, "clamp"),
}

function getLogo(charid)
	return logos[charid] or logo
end

function hex2rgb(hex) 
    if hex then
        hex = hex:gsub("#","") 
        return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) 
    end
end 

function nametag_updateDatas(element)
	if not isElement(element) then return end
    local type = getElementType(element)
    orangehex = '#FF5757' --exports['cr_core']:getServerColor("blue", true)
	if type == "player" then
		if source ~= localPlayer or myname then
			local charID = getElementData(element, "char >> id") or 0
			local charName = getElementData(element, "char >> name") or "Ismeretlen"
			charName = charName:gsub("_", " ")
            
            local customCharName = getElementData(element, "char >> customName")
            if customCharName then
                customCharName = customCharName:gsub("_", " ")
                
                charName = customCharName
            end
            
			local adminDuty = exports['cr_admin']:getAdminDuty(element) --getElementData(element, "admin >> duty")
			local adminColor = exports['cr_admin']:getAdminColor(element, false, true) or "#FFFFFF"
			local adminName = getElementData(element, "admin >> name") or "Ismeretlen"
			local adminTitle = exports['cr_admin']:getAdminTitle(element) or "Ismeretlen"
			adminTitle = adminTitle == "Fejlesztő" and "<Fejlesztő/>" or "(" .. adminTitle .. ")"
            local description = getElementData(element, "char >> description")
            local a = 38
            if description then
                description = addCharToString(description, a, "\n", math.floor(#description / a))
            end
            local charNameColor = "#ffffff"

			local extraText = ""
			local text = orangehex .. "(" .. charID .. ")" .. charNameColor .. " " .. charName
			if adminDuty or ((getElementData(element, "admin >> level") or 0) > 0 and (getElementData(element, "admin >> level") or 0) <= 2) then
				text = orangehex .. "(" .. charID .. ") " .. charNameColor .. (adminTitle:find("Adminsegéd") and charName or adminName) .. " " .. adminColor .. adminTitle
			end
            local dbid = getElementData(element, "acc >> id")
            local afkData = getElementData(element, "afk.data") or {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"}
            local bloodData = getElementData(element, "bloodData") or {}

            local level = tonumber(getElementData(element, "char >> level") or 0)
            if level <= 3 then
                local red = exports['cr_core']:getServerColor("red", true)
                text = text .. red .. " (Kezdő)"
            end 

            local specText = element:getData("char >> specText") 
            if specText and #specText >= 1 and #(specText:gsub(" ", "")) >= 1 then 
                text = text .. "\n" .. specText
            end 

            if isPedDead(element) then
                text = "#262626" .. string.gsub(text, "#%x%x%x%x%x%x", "")
            elseif hitCache[element] then 
                text = "#d23131" .. string.gsub(text, "#%x%x%x%x%x%x", "")
            elseif bloodData and #bloodData >= 1 then
                text = "#d23131" .. string.gsub(text, "#%x%x%x%x%x%x", "")
            end 

            cache[element]["text"] = text
            cache[element]["gText"] = string.gsub(text, "#%x%x%x%x%x%x", "")
            cache[element]["specText"] = specText
            cache[element]["aname"] = adminName
            cache[element]["rgb"] = {hex2rgb(adminColor)}
            cache[element]["aduty"] = adminDuty
            cache[element]["ishelper"] = getElementData(element, "admin >> level") == 1 or getElementData(element, "admin >> level") == 2
            cache[element]["bloodData"] = bloodData
		end
	elseif type == "ped" then
		local pedParent = getElementData(element, "parent")
		if pedParent ~= localPlayer then
			local pedID = getElementData(element, "ped.id")
			local pedName = getElementData(element, "ped.name")
			if pedName then
				pedName = tostring(pedName):gsub("_", " ")
			end
			local pedType = getElementData(element, "ped.type")
			local pedParent = getElementData(element, "parent")
			local blockInsert
			local text
            local charID
            local charName
            local adminDuty
            local adminColor
            local adminName
            local adminTitle
            local inDeath
            local specText
            local dbid
            local bloodData
            if pedParent then
                bloodData = getElementData(pedParent, "bloodData") or {}
                dbid = getElementData(element, "acc >> id")
                charID = getElementData(pedParent, "char >> id") or 0
                charName = getElementData(pedParent, "char >> name") or "Ismeretlen"
                
                local customCharName = getElementData(pedParent, "char >> customName")
                if customCharName then
                    customCharName = customCharName:gsub("_", " ")

                    charName = customCharName
                end
                
                charName = charName:gsub("_", " ")
                adminDuty = exports['cr_admin']:getAdminDuty(pedParent)
                adminColor = exports['cr_admin']:getAdminColor(pedParent, false, true) or "#FFFFFF"
                adminName = getElementData(pedParent, "admin >> name") or "Ismeretlen"
                adminTitle = exports['cr_admin']:getAdminTitle(pedParent) or "Ismeretlen"
                inDeath = getElementData(pedParent, "inDeath")
				extraText = ""
				local hex = "#FFFFFF"
				if inDeath then
					hex = "#262626"
				end
				text = orangehex .. "(" .. charID .. ")" .. hex .. " " .. charName .. "#FFFFFF" .. extraText
				if adminDuty then
					text = adminColor .. adminName .. " " .. "(" .. adminTitle .. ")#FFFFFF\n" .. text
                end
                
                local level = tonumber(getElementData(pedParent, "char >> level") or 0)
                if level <= 3 then 
                    local red = exports['cr_core']:getServerColor("red", true)
                    text = text .. red .. " (Kezdő)"
                end 

                specText = element:getData("char >> specText") 
                if specText and #specText >= 1 and #(specText:gsub(" ", "")) >= 1 then 
                    text = text .. "\n" .. specText
                end 
                
				if inDeath then
					local deathReason
					if anames then
						deathReason = getElementData(pedParent, "deathReason >> admin") or "Ismeretlen"
					else
						deathReason = getElementData(pedParent, "deathReason") or "Ismeretlen"
					end
					text =  text .. "\n#d23131" .. deathReason
				end
			else
				if pedName and pedType then
					local pedNameColor = "#ffffff"
                    text = pedNameColor .. pedName .. " " .. orangehex .. "(" .. pedType .. ")"
                    
                    if isPedDead(element) then
                        text = "#262626" .. string.gsub(text, "#%x%x%x%x%x%x", "")
                    elseif hitCache[element] then 
                        text = "#d23131" .. string.gsub(text, "#%x%x%x%x%x%x", "")
                    end 
				else
					blockInsert = true
				end
			end
			if not blockInsert then
                local pedParent = pedParent or element
                local description = getElementData(pedParent, "char >> description")
                local a = 38
                if description then
                    description = addCharToString(description, a, "\n", math.floor(#description / a))
                end
                local afkData = getElementData(pedParent, "afk.data") or {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"}
                
                cache[element]["text"] = text
                cache[element]["gText"] = string.gsub(text, "#%x%x%x%x%x%x", "")
                cache[element]["aname"] = adminName
                cache[element]["rgb"] = {hex2rgb(adminColor)}
                cache[element]["ishelper"] = getElementData(pedParent, "admin >> level") == 1 or getElementData(pedParent, "admin >> level") == 2
                cache[element]["aduty"] = adminDuty
                cache[element]["bloodData"] = bloodData
                cache[element]["specText"] = specText
                cache[element]["hunter >> id"] = pedParent:getData("hunter >> id")
                cache[element]["hunter >> health"] = pedParent:getData("hunter >> health")
                cache[element]["hunter >> maxHealth"] = pedParent:getData("hunter >> maxHealth")
			end
		end
	end
end

function nametag_callDatas(element)
	if not isElement(element) then return end
    local type = getElementType(element)
    orangehex = '#FF5757' --exports['cr_core']:getServerColor("blue", true)
	if type == "player" then
		if source ~= localPlayer or myname then
			local charID = getElementData(element, "char >> id") or 0
			local charName = getElementData(element, "char >> name") or "Ismeretlen"
			charName = charName:gsub("_", " ")
            
            local customCharName = getElementData(element, "char >> customName")
            if customCharName then
                customCharName = customCharName:gsub("_", " ")
                
                charName = customCharName
            end
            
			local adminDuty = getElementData(element, "admin >> duty")
			local adminColor = exports['cr_admin']:getAdminColor(element, false, true) or "#FFFFFF"
			local adminName = getElementData(element, "admin >> name") or "Ismeretlen"
			local adminTitle = exports['cr_admin']:getAdminTitle(element) or "Ismeretlen"
			adminTitle = adminTitle == "Fejlesztő" and "<Fejlesztő />" or "(" .. adminTitle .. ")"
            local description = getElementData(element, "char >> description")
            local a = 38
            if description then
                description = addCharToString(description, a, "\n", math.floor(#description / a))
            end
            local charNameColor = "#ffffff"
			local extraText = ""
			local text = orangehex .. "(" .. charID .. ")" .. charNameColor .. " " .. charName
			if adminDuty or ((getElementData(element, "admin >> level") or 0) > 0 and (getElementData(element, "admin >> level") or 0) <= 2) then
				text = orangehex .. "(" .. charID .. ") " .. charNameColor .. (adminTitle:find("Adminsegéd") and charName or adminName) .. " " .. adminColor .. adminTitle
            end
            local bloodData = getElementData(element, "bloodData") or {}
            local inAnim = getElementData(element, "inAnim")
            local level = tonumber(getElementData(element, "char >> level") or 0)
            if level <= 3 then 
                local red = exports['cr_core']:getServerColor("red", true)
                text = text .. red .. " (Kezdő)"
            end 

            local specText = element:getData("char >> specText") 
            if specText and #specText >= 1 and #(specText:gsub(" ", "")) >= 1 then 
                text = text .. "\n" .. specText
            end 
            
            if isPedDead(element) then
                text = "#262626" .. string.gsub(text, "#%x%x%x%x%x%x", "")
            elseif hitCache[element] then 
                text = "#d23131" .. string.gsub(text, "#%x%x%x%x%x%x", "")
            elseif bloodData and #bloodData >= 1 then
                text = "#d23131" .. string.gsub(text, "#%x%x%x%x%x%x", "")
            end 

            local dbid = getElementData(element, "acc >> id")
            local afkData = getElementData(element, "afk.data") or {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"}

            local oldData = cache[element] or {}

			cache[element] = {
                ["dbid"] = dbid,
				["text"] = text,
				["gText"] = string.gsub(text, "#%x%x%x%x%x%x", ""),
				["aduty"] = adminDuty,
				["rgb"] = {hex2rgb(adminColor)},
				["aname"] = adminName,
				["ishelper"] = getElementData(element, "admin >> level") == 1 or getElementData(element, "admin >> level") == 2,
				["afk"] = getElementData(element, "char >> afk"),
                ["afkData"] = {afkData.seconds, afkData.minutes, afkData.hours},
                ["respawnData"] = getElementData(element, "respawn.min"),
                ["respawn"] = getElementData(element, "respawn"),
				["chat"] = getElementData(element, "char >> chat"),
				["console"] = getElementData(element, "char >> console"),
                ["tazzed"] = getElementData(element, "char >> tazed"),
                ["cuffed"] = getElementData(element, "char >> cuffed"),
				["description"] = description,
                ["death"] = inDeath,
                ["specText"] = specText,
                ["bubbleOn"] = getElementData(element, "bubbleOn"),
                ["timedout"] = getElementData(element, "timedout"),
                ["bloodData"] = bloodData,
                ["inAnim"] = inAnim,
                ['sightLine'] = oldData['sightLine'],
                ['distance'] = oldData['distance'],
                ['alpha'] = oldData['alpha'],
			}
		end
	elseif type == "ped" then
		local pedParent = getElementData(element, "parent")
		if pedParent ~= localPlayer then
			local pedID = getElementData(element, "ped.id")
			local pedName = getElementData(element, "ped.name")
			if pedName then
				pedName = tostring(pedName):gsub("_", " ")
			end
			local pedType = getElementData(element, "ped.type")
			local pedParent = getElementData(element, "parent")
			local blockInsert
			local text
            local charID
            local charName
            local adminDuty
            local adminColor
            local adminName
            local adminTitle
            local inDeath
            local specText
            local dbid
            local bloodData = getElementData(element, "bloodData") or {}
			if pedParent then
                dbid = getElementData(element, "acc >> id")
                charID = getElementData(pedParent, "char >> id") or 0
                charName = getElementData(pedParent, "char >> name") or "Ismeretlen"
                charName = charName:gsub("_", " ")
                
                local customCharName = getElementData(pedParent, "char >> customName")
                if customCharName then
                    customCharName = customCharName:gsub("_", " ")

                    charName = customCharName
                end
                adminDuty = getElementData(pedParent, "admin >> duty")
                adminColor = exports['cr_admin']:getAdminColor(pedParent, false, true) or "#FFFFFF"
                adminName = getElementData(pedParent, "admin >> name") or "Ismeretlen"
                adminTitle = exports['cr_admin']:getAdminTitle(pedParent) or "Ismeretlen"
                inDeath = getElementData(pedParent, "inDeath")
                inAnim = getElementData(pedParent, "inAnim")
                extraText = ""
				local hex = "#FFFFFF"
				if inDeath then
					hex = "#262626"
				end
				text = orangehex .. "(" .. charID .. ")" .. hex .. " " .. charName .. "#FFFFFF" .. extraText
				if adminDuty then
					text = adminColor .. adminName .. " " .. "(" .. adminTitle .. ")#FFFFFF\n" .. text
                end

                local level = tonumber(getElementData(pedParent, "char >> level") or 0)
                if level <= 3 then 
                    local red = exports['cr_core']:getServerColor("red", true)
                    text = text .. red .. " (Kezdő)"
                end 

                specText = pedParent:getData("char >> specText") 
                if specText and #specText >= 1 and #(specText:gsub(" ", "")) >= 1 then 
                    text = text .. "\n" .. specText
                end 
                
				if inDeath then
					local deathReason
					if anames then
						deathReason = getElementData(pedParent, "deathReason >> admin") or "Ismeretlen"
					else
						deathReason = getElementData(pedParent, "deathReason") or "Ismeretlen"
					end
					text =  text .. "\n#d23131" .. deathReason
				end
			else
				if pedName and pedType then
					local pedNameColor = "#ffffff"
                    text = pedNameColor .. pedName .. " " .. orangehex .. "(" .. pedType .. ")"
                    
                    if isPedDead(element) then
                        text = "#262626" .. string.gsub(text, "#%x%x%x%x%x%x", "")
                    elseif hitCache[element] then 
                        text = "#d23131" .. string.gsub(text, "#%x%x%x%x%x%x", "")
                    end 
				else
					blockInsert = true
				end
			end
			if not blockInsert then
                local pedParent = pedParent or element
                local description = getElementData(pedParent, "char >> description")
                local a = 38
                if description then
                    description = addCharToString(description, a, "\n", math.floor(#description / a))
                end
                local afkData = getElementData(pedParent, "afk.data") or {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"}

                local oldData = cache[element] or {}
                
				cache[element] = {
                    ["dbid"] = dbid,
					["text"] = text,
					["gText"] = string.gsub(text, "#%x%x%x%x%x%x", ""),
                    ["aduty"] = adminDuty,
                    ["rgb"] = {hex2rgb(adminColor)},
                    ["aname"] = adminName,
                    ["afk"] = getElementData(pedParent, "char >> afk"),
                    ["afkData"] = {afkData.seconds, afkData.minutes, afkData.hours},
                    ["respawnData"] = getElementData(pedParent, "respawn.min"),
                    ["respawn"] = getElementData(pedParent, "respawn"),
                    ["chat"] = getElementData(pedParent, "char >> chat"),
                    ["console"] = getElementData(pedParent, "char >> console"),
                    ["tazzed"] = getElementData(pedParent, "char >> tazed"),
                    ["cuffed"] = getElementData(pedParent, "char >> cuffed"),     
                    ["description"] = description,
                    ["dead"] = inDeath,
                    ["specText"] = specText,
                    ["bubbleOn"] = getElementData(pedParent, "bubbleOn"),
                    ["timedout"] = getElementData(pedParent, "timedout"),
                    ["bloodData"] = bloodData,
                    ["inAnim"] = inAnim,
                    ["hunter >> id"] = pedParent:getData("hunter >> id"),
                    ["hunter >> health"] = pedParent:getData("hunter >> health"),
                    ["hunter >> maxHealth"] = pedParent:getData("hunter >> maxHealth"),
                    ['sightLine'] = oldData['sightLine'],
                    ['distance'] = oldData['distance'],
                    ['alpha'] = oldData['alpha'],
				}
			end
		end
	end
end

pAduty = getElementData(localPlayer, "admin >> duty")
anames = getElementData(localPlayer, "admin >> duty")
maskState = localPlayer:getData("maskState")
friends = getElementData(localPlayer, "friends") or {}

local function nametag_hitElement()
	if isTimer(hitTimerCache[source]) then
		killTimer(hitTimerCache[source])
	end
	hitCache[source] = true
	nametag_callDatas(source)
	hitTimerCache[source] = setTimer(
		function(source)
			hitCache[source] = nil
			nametag_callDatas(source)
		end, 3000, 1, source
	)
end
addEventHandler("onClientPedDamage", root, nametag_hitElement)
addEventHandler("onClientPlayerWasted", root, nametag_hitElement)
addEventHandler("onClientPlayerSpawn", root, nametag_hitElement)
addEventHandler("onClientPlayerDamage", root, nametag_hitElement)

setTimer(
    function()
        if not friends then
            friends = getElementData(localPlayer, "friends") or {}
        end
        cameraX, cameraY, cameraZ = getCameraMatrix()
        playerInHeli = nil 
        if localPlayer.vehicle then 
            if localPlayer.vehicle.vehicleType:lower() == ("Helicopter"):lower() or localPlayer.vehicle.vehicleType:lower() == ("Plane"):lower() then 
                playerInHeli = true
            end 
        end 
        pedTarget = localPlayer:getTarget()
        if localPlayer:getWeapon() ~= 34 or not localPlayer:getControlState("aim_weapon") then 
            pedTarget = nil 
        end 

        for k,v in pairs(cache) do
            local boneX, boneY, boneZ = getPedBonePosition(k, 5)
            boneZ = boneZ + 0.2
            if isElementOnScreen(k) then
                if k == localPlayer then
                    cache[k]["sightLine"] = true
                else 
                    cache[k]["sightLine"] = pedTarget == k or isLineOfSightClear(cameraX, cameraY, cameraZ, boneX, boneY, boneZ, true, false, false, true, false, false, false, localPlayer)
                end
                cache[k]["distance"] = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
                if pedTarget == k then 
                    cache[k]["distance"] = 0.1
                end 
                cache[k]["alpha"] = k.alpha >= 255
                cache[k]["isKnow"] = friends[v["dbid"]]
                if localPlayer.vehicle then
                    if not k.vehicle or k.vehicle ~= localPlayer.vehicle then
                        cache[k]["isKnow"] = false
                    end
                elseif k.vehicle then
                    if not localPlayer.vehicle or localPlayer.vehicle ~= k.vehicle then
                        cache[k]["isKnow"] = false
                    end
                end
            end
        end
    end, 150, 0
)

renderCache = {}

setTimer(
    function()
        local cache = cache
        renderCache = {}

        if pedTarget and cache[pedTarget] and not hudVisible then 
            if not pedTargeted then 
                pedTargeted = true 
            end 

            if not checkRender("nametag_handleRender") then 
                createRender("nametag_handleRender", nametag_handleRender)
            end 

            local data = cache[pedTarget]
            cache = {} 
            cache[pedTarget] = data
        else 
            if pedTargeted then 
                pedTargeted = false 

                if checkRender("nametag_handleRender") and not hudVisible then 
                    destroyRender("nametag_handleRender")
                end 

                return
            end 
        end 

        if localPlayer:getData("char >> blinded") then 
            cache = {}
        end 

        for k,v in pairs(cache) do
            if isElement(k) and isElementStreamedIn(k) then
                if v["alpha"] then
                    local sightLine = v["sightLine"]
                    if anames then
                        sightLine = true
                    end
                    if sightLine then
                        if (k ~= localPlayer or myname) then
                            renderCache[k] = v
                        end
                    end
                end
            end
        end
    end, 100, 0
)

fontHeight = 22
_fontHeight = 22
local _maxDist = 42
function nametag_handleRender(timeSlice)
    if not logo then 
        logo = dxCreateTexture(":cr_account/files/logo-white.png", "dxt5", true, "clamp")

        return
    end 

    font = exports['cr_fonts']:getFont(fontName, fontSizeMax)
    font2 = exports['cr_fonts']:getFont(fontName, fontSizeMin)
    fontHeight = dxGetFontHeight(1, font)
    _fontHeight = fontHeight
    orangehex = '#FF5757' --exports['cr_core']:getServerColor("blue", true)
    color = orangehex
    white = "#ffffff"
    now = getTickCount()
    for element, value in pairs(renderCache) do
        if not isElement(element) then 
            cache[element] = nil
            renderCache[element] = nil 

            collectgarbage("collect")

            return
        end 
        local fontHeight = fontHeight
        local boneX, boneY, boneZ = getPedBonePosition(element, 5)
        local maxDistance = _maxDist
        if anames and getElementType(element) == "player" then
            maxDistance = 1000
        elseif playerInHeli and getElementType(element) == "player" then 
            maxDistance = maxDistance * 2
        end

        if maskState then 
            maxDistance = maxDistance / 2
        end 

        local distance = value["distance"]
        if distance <= maxDistance then
            local size = 1 - (distance / maxDistance)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + (0.35 * size))
            if screenX and screenY then
                local text = value["text"]
                local gText = value["gText"]
                local dbid = value["dbid"]
                local afk = value["afk"]
                local respawn = value["respawn"]
                local alpha = 255*size
                local _alpha = alpha
                local bloodData = value["bloodData"] 
                if bloodData and #bloodData >= 1 then
                    alpha = interpolateBetween(50, 0, 0, alpha, 0, 0, now / 1500, "SineCurve")
                end 

                local inAnim = value["inAnim"]
                local hunterID = value["hunter >> id"]

                if afk then
                    local afkData = value["afkData"]
                    local sec, min, hour = afkData[1], afkData[2], afkData[3]
                    local size = 1 - (distance / _maxDist)
                    if size > 0 then
                        fontHeight = fontHeight + _fontHeight
                        text = color .. hour .. white ..":" .. color .. min .. white ..":" .. color .. sec .. white .."\n" .. text
                        gText = hour ..":" .. min ..":" .. sec .."\n" .. gText
                    else
                        afk = false
                    end
                end

                if value["dead"] then
                    fontHeight = fontHeight + _fontHeight
                end

                if value["specText"] then 
                    fontHeight = fontHeight + _fontHeight
                end 

                if respawn then
                    local min = value["respawnData"]
                    if tonumber(min) then
                        local size = 1 - (distance / _maxDist)
                        if size > 0 then
                            fontHeight = fontHeight + _fontHeight
                            text = color .. min .. white .. " perce éledt újra!\n" .. text
                            gText = min .." perce éledt újra!\n" .. gText
                        else
                            respawn = false
                        end
                    else
                        respawn = false
                    end
                end

                local fullAlpha = value["isKnow"] or value["aduty"] or pAduty or getElementType(element) ~= "player" or element == localPlayer
                if fullAlpha then
                    dxDrawText(gText,screenX+1,0+1,screenX+1,screenY+1,tocolor(0,0,0,alpha <= 200 and alpha or 200),size, font, "center", "bottom", false, false, false, true, true)
                    dxDrawText(text, screenX, 0, screenX, screenY, tocolor(255, 255, 255, alpha), size, font, "center", "bottom", false, false, false, true, true)
                else
                    dxDrawText(gText,screenX+1,0+1,screenX+1,screenY+1,tocolor(0,0,0,alpha <= 50 and alpha or 50),size, font, "center", "bottom", false, false, false, true, true)
                    dxDrawText(text, screenX, 0, screenX, screenY, tocolor(255, 255, 255, alpha <= 100 and alpha or 100), size, font, "center", "bottom", false, false, false, true, true)
                end

                if not descriptionsDisabled then
                    local size = 1 - (distance / _maxDist)
                    if size > 0 then
                        if value["description"] then
                            local x2,y2,z2 = element:getBonePosition(3)
                            local x3, y3 = getScreenFromWorldPosition(x2,y2,z2,25,false)
                            if x3 and y3 then
                                if fullAlpha then
                                    dxDrawText(value["description"], x3 + (50 * size)/2,y3, x3 - (50 * size)/2,y3, tocolor(194, 162, 218, _alpha), size, font2,"center","center",false,false,false,true,true)
                                else
                                    dxDrawText(value["description"], x3 + (50 * size)/2,y3, x3 - (50 * size)/2,y3, tocolor(194, 162, 218, _alpha <= 100 and _alpha or 100), size, font2,"center","center",false,false,false,true,true)
                                end
                            end
                        end
                    end
                end

                if anames and element.type == "player" then
                    if size > 0 then
                        local x3, y3 = screenX, screenY + (30 * size) + (30 * size)

                        local multipler = element.health / 100
                        local w, h = 200 * size, 20 * size
                        dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w, h, tocolor(242, 242, 242, _alpha * 0.6))
                        dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w * multipler, h, tocolor(255,59,59, _alpha))

                        local multipler = element.armor / 100
                        local w, h = 200 * size, 20 * size
                        dxDrawRectangle(x3 - w/2, y3 + (10 * size) - h/2, w, h, tocolor(242, 242, 242, _alpha * 0.6))
                        dxDrawRectangle(x3 - w/2, y3 + (10 * size) - h/2, w * multipler, h, tocolor(97,177,90, _alpha))
                    end
                else 
                    if element.type == "player" then 
                        if inAnim then 
                            local x3, y3 = screenX, screenY + (30 * size) + (30 * size)

                            local elapsedTime = inAnim[1] - inAnim[2]
                            local duration = 10 * 60 * 1000
                            local multipler = math.min(1, math.max(0, 1 - (elapsedTime / duration)))
                            local w, h = 200 * size, 20 * size
                            dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w, h, tocolor(242, 242, 242, _alpha * 0.6))
                            dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w * multipler, h, tocolor(255,59,59, _alpha))
                        end 
                    elseif element.type == "ped" then 
                        if tonumber(hunterID) then 
                            local x3, y3 = screenX, screenY + (30 * size) + (30 * size)

                            local health = value["hunter >> health"]
                            local maxHealth = value["hunter >> maxHealth"]
                            local multipler = math.min(1, math.max(0, health / maxHealth))
                            local w, h = 150 * size, 15 * size
                            dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w, h, tocolor(242, 242, 242, _alpha * 0.6))
                            local r,g,b = 255,59,59
                            dxDrawRectangle(x3 - w/2, y3 - (10 * size) - h/2, w * multipler, h, tocolor(r,g,b, _alpha))
                            dxDrawText(math.floor(health / maxHealth * 100) .. "%", x3, y3 - (10 * size), x3, y3 - (10 * size), tocolor(242, 242, 242, _alpha), size, font2, "center", "center", false, false, false, true)
                        end 
                    end 
                end


                if not value["bubbleOn"] then
                    local maxAlpha
                    if fullAlpha then
                        maxAlpha = 255
                    else
                        maxAlpha = _alpha <= 100 and _alpha or 100
                    end
                    
                    if value["chat"] then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["chat"], 0, 0, 0, tocolor(255, 59, 59, alpha))
                    elseif value["console"] then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["console"], 0, 0, 0, tocolor(255, 59, 59, alpha))
                    elseif afk then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["afk"], 0, 0, 0, tocolor(210,49,49, alpha))
                    elseif value["tazzed"] then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["taser"], 0, 0, 0, tocolor(63,63,63, alpha))
                    elseif value["cuffed"] then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["cuffed"], 0, 0, 0, tocolor(63,63,63, alpha))
                    elseif respawn then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["respawn"], 0, 0, 0, tocolor(210,49,49, alpha))
                    elseif value["dead"] then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["dead"], 0, 0, 0, tocolor(20,20,20, alpha))
                    elseif value["timedout"] then
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (30 * size), (50 * size), 50 * size, images["timedout"], 0, 0, 0, tocolor(210,49,49, alpha))    
                    elseif inAnim then 
                        local alpha = interpolateBetween(0, 0, 0, maxAlpha, 0, 0, now / 2500, "SineCurve")
                        dxDrawImage(screenX - (25 * size), screenY - (50 * size) - (fontHeight * size), (50 * size), 50 * size, images["anim"], 0, 0, 0, tocolor(210,49,49, alpha))
                    elseif value["aduty"] or value["ishelper"] then
                        local y, alpha = interpolateBetween(-5, 0, 0, 5, maxAlpha, 0, now / 2500, "CosineCurve")
                        local a,b,c = (55)/2, 55, 64
                        dxDrawImage(screenX - (a * size), screenY - (c * size) - (30 * size) + (y * size), b * size, c * size, getLogo(value["aname"]), 0, 0, 0, logos[value["aname"]] and tocolor(255, 255, 255, alpha) or tocolor(value["rgb"][1], value["rgb"][2], value["rgb"][3], alpha))
                    end
                end
            end
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in ipairs(getElementsByType("player")) do
			if isElementStreamedIn(value) then
				nametag_callDatas(value)
				setPlayerNametagShowing(value, false)
			end
		end
		for key, value in ipairs(getElementsByType("ped")) do
			if isElementStreamedIn(value) then
				nametag_callDatas(value)
			end
		end
		hudVisible = getElementData(localPlayer, "hudVisible")
		if hudVisible then
			--addEventHandler("onClientRender", root, nametag_handleRender, true, "low-5")
            createRender("nametag_handleRender", nametag_handleRender)
		else
			--removeEventHandler("onClientRender", root, nametag_handleRender)
            destroyRender("nametag_handleRender")
		end
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		nametag_callDatas(source)
		setPlayerNametagShowing(source, false)
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		cache[source] = nil
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dName, oValue, nValue)
        if dName == "admin >> duty" and source == localPlayer then
            pAduty = getElementData(localPlayer, "admin >> duty")
            anames = pAduty
            for element in pairs(cache) do 
                nametag_updateDatas(element)
            end 
        elseif dName == "maskState" then 
            maskState = nValue
        elseif dName == "friends" and source == localPlayer then
            friends = getElementData(localPlayer, "friends") or {}
        end
        local source = source
        local _source = source
        if source.type == "player" and source:getData("clone") then 
            source = source:getData("clone") or source 
        end

		if cache[source] and refreshDatas[dName] then
            if dName == "char >> description" then
                local element = source
                
                local n = refreshDatas[dName]
                local val = getElementData(_source, dName)
                local a = 38
                if val then
                    val = addCharToString(val, a, "\n", math.floor(#val / a))
                end
                
                cache[element][n] = val
            elseif dName == "afk.data" then
                local element = source
                local afkData = getElementData(_source, "afk.data") or {["seconds"] = "00", ["minutes"] = "00", ["hours"] = "00"}
                cache[element]["afkData"] = {afkData.seconds, afkData.minutes, afkData.hours}
                return
            elseif dName == "respawn.min" then
                local element = source
                cache[element]["respawnData"] = getElementData(_source, dName)
                return
            elseif type(refreshDatas[dName]) == "string" then
                local element = source
                local n = refreshDatas[dName]
                cache[element][n] = getElementData(_source, dName)
                return
            else
                nametag_updateDatas(source)
            end
        end
        
		if source == localPlayer and dName == "hudVisible" then
			hudVisible = getElementData(localPlayer, "hudVisible")
			if hudVisible then
				--addEventHandler("onClientRender", root, nametag_handleRender, true, "low-5")
                createRender("nametag_handleRender", nametag_handleRender)
			else
				--removeEventHandler("onClientRender", root, nametag_handleRender)
                destroyRender("nametag_handleRender")
			end
        end
        
		if source == localPlayer and dName == "admin >> duty" and not getElementData(source, dName) then
			anames = false
		end
	end
)

addEventHandler("onClientPlayerQuit", root,
	function()
		cache[source] = nil
        renderCache[source] = nil 

        collectgarbage("collect")
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
        cache[source] = nil
        renderCache[source] = nil 

        collectgarbage("collect")
	end
)

setTimer( 
    function()  
        if not localPlayer:getData("loggedIn") then return end
        if isChatBoxInputActive() then
            setElementData(localPlayer, "char >> chat", true)
            return
        else
            setElementData(localPlayer, "char >> chat", false)
        end

        if isConsoleActive() then
            setElementData(localPlayer, "char >> console", true)	
            return
        else
            setElementData(localPlayer, "char >> console", false)
        end
        
        if isMTAWindowActive() then
            if not afk then
                afk = true
                startAfkTimer()
                setElementData(localPlayer, "char >> afk", true)
            end
        end
    end    
, 350, 0)

function toggleANames(cmd)
    if exports['cr_permission']:hasPermission(localPlayer, "anames") then
        anames = not anames
        for element, _ in pairs(cache) do
        	nametag_callDatas(element)
        end
        if anames then
            local syntax = exports['cr_core']:getServerSyntax(false, "success")
            outputChatBox(syntax .. "Sikeresen bekapcsoltad az adminisztrátori nametaget!", 255,255,255,true)
        else
            local syntax = exports['cr_core']:getServerSyntax(false, "error")
            outputChatBox(syntax .. "Sikeresen kikapcsoltad az adminisztrátori nametaget!", 255,255,255,true)
        end
    end
end
addCommandHandler("anames", toggleANames)
addCommandHandler("nevek", toggleANames)

addCommandHandler("refreshnametag",
	function()
		for _, element in ipairs(getElementsByType("player")) do
			if isElementStreamedIn(element) then
				nametag_callDatas(element)
			end
		end
		for _, element in ipairs(getElementsByType("ped")) do
			if isElementStreamedIn(element) then
				nametag_callDatas(element)
			end
		end
		for element, _ in pairs(cache) do
			nametag_callDatas(element)
		end
        local syntax = exports['cr_core']:getServerSyntax(false, "success")
        outputChatBox(syntax .. "Sikeresen frissítetted a nametag adatokat!", 255,255,255,true)
	end
)

function addCharToString(str, pos, chr, howMany, origPos)
    if howMany == 0 then return str end
    if not origPos then origPos = pos end
    local stringVariation = str:sub(1, pos) .. chr .. str:sub(pos + 1)
    howMany = howMany - 1
    return addCharToString(stringVariation, pos + origPos, chr, howMany, origPos)
end