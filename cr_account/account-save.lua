function savePlayer(e)
    -- outputChatBox(tostring(e:getData("player.loggedIn")))
    if e:getData("loggedIn") then
        --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
        --local position = data[3]
        local id = tonumber(e:getData("acc >> id"))
        -- outputChatBox(id)
        local name = tostring(e:getData("acc >> username"))

        local x,y,z = getElementPosition(e)
        local dim, int = getElementDimension(e), getElementInterior(e)
        local a,a,rot = getElementRotation(e)

        if e:getData("clone") then 
            local e = e:getData("clone") or e
            
            x,y,z = getElementPosition(e)
            dim, int = getElementDimension(e), getElementInterior(e)
            a,a,rot = getElementRotation(e)
        end 

        if e:getData('specialDimension') then 
            dim = tonumber(e:getData('specialDimension')) or dim
        end 

        if e:getData('specialInterior') then 
            int = tonumber(e:getData('specialInterior')) or int
        end 
        --local x,y,z, dim,int,rot = unpack(position)

        local Health = tonumber(getElementHealth(e))
        local Armor = tonumber(getPedArmor(e))
        local SkinID = tonumber(e:getData("char >> skin") or 1)
        local Money = tonumber(e:getData("char >> money")) or 0
        local PlayedTime = tonumber(e:getData("char >> playedtime")) or 0
        local Level = tonumber(e:getData("char >> level")) or 1
        local premiumPoints = tonumber(e:getData("char >> premiumPoints")) or 0
        local job = tonumber(e:getData("char >> job")) or 1
        local food = tonumber(e:getData("char >> food")) or 100
        local drink = tonumber(e:getData("char >> drink")) or 100
        --local details = {Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink}
        --local Health, Armor, SkinID, Money, PlayedTime, Level, premiumPoints, job, food, drink = unpack(details)

        local charname = tostring(e:getData("char >> name")) or "Ismeretlen"

        local dead = stringToBoolean(e:getData("char >> death"))
        local reason = tostring(e:getData("deathReason")) or ""
        local aReason = tostring(e:getData("deathReason >> admin")) or ""
        local reason = {reason, aReason}
        local headless = stringToBoolean(e:getData("char >> headless"))

        local alevel = tonumber(e:getData("admin >> level")) or 0
        local nick = tostring(e:getData("admin >> name")) or "Ismeretlen"
        local adutyTime = tonumber(e:getData("admin >> time")) or 0
        
        local vehicleLimit = tonumber(e:getData("char >> vehicleLimit")) or 3
        local interiorLimit = tonumber(e:getData("char >> interiorLimit")) or 3
        local avatar = tonumber(e:getData("char >> avatar")) or 1
        local crosshair = tonumber(e:getData("char >> crosshair")) or 1
        local crosshairColor = e:getData("char >> crosshairColor") or {255, 255, 255}
        local c1 = e:getData("friends", friend) or {}
        local c2 = e:getData("debuts", debut) or {}
        local isKnow = {c2, c1}
        local isHidden = e:getData("weapons >> hidden") or {}
        
        local Bones = e:getData("char >> bone", bone) or {true, true, true, true, true}
        local BloodData = e:getData("bloodData") or {}

        local rtc = e:getData("rtc >> using") or 0
        local fix = e:getData("fix >> using") or 0
        local fuel = e:getData("fuel >> using") or 0
        local ban = e:getData("ban >> using") or 0
        local kick = e:getData("kick >> using") or 0
        local jail = e:getData("jail >> using") or 0
        local pms = e:getData("privateMessages >> using") or 0
        local replies = e:getData("repliedMessages >> using") or 0
        local sethps = e:getData("sethp >> using") or 0
        local setarmors = e:getData("setarmor >> using") or 0
        local sethungers = e:getData("sethunger >> using") or 0
        local setwaters = e:getData("setwater >> using") or 0
        local healthResets = e:getData("healthReset >> using") or 0
        local unflips = e:getData("unflip >> using") or 0
        local getcars = e:getData("getcar >> using") or 0
        local gotocars = e:getData("gotocar >> using") or 0
        local setcarhps = e:getData("setcarhp >> using") or 0
        
        local usedCmds = {
            ['rtc'] = rtc,
            ['fix'] = fix,
            ['fuel'] = fuel,
            ['ban'] = ban,
            ['kick'] = kick,
            ['jail'] = jail,
            ['privateMessages'] = pms,
            ['repliedMessages'] = replies,
            ['sethp'] = sethps,
            ['setarmor'] = setarmors,
            ['sethunger'] = sethungers,
            ['setwater'] = setwaters,
            ['healthReset'] = healthResets,
            ['unflip'] = unflips,
            ['getcar'] = getcars,
            ['gotocar'] = gotocars,
            ['setcarhp'] = setcarhps,
        }
        
        local position = {x,y,z, dim,int,rot}
        local charDetails = e:getData("char >> details")
        charDetails["description"] = e:getData("char >> description") or ""
        local stats = {
            [69] = e:getStat(69),
            [70] = e:getStat(70),
            [71] = e:getStat(71),
            [72] = e:getStat(72),
            [73] = e:getStat(73),
            [74] = e:getStat(74),
            [75] = e:getStat(75),
            [76] = e:getStat(76),
            [77] = e:getStat(77),
            [78] = e:getStat(78),
            [79] = e:getStat(79),
        }
        local dutyDatas = {e:getData("char >> duty"), e:getData("char >> dutyskin")} or {false, nil}
        local bondage = stringToBoolean(e:getData("char >> bondage")) or false 
        local blinded = stringToBoolean(e:getData("char >> blinded")) or false 
        local cuffed = stringToBoolean(e:getData("char >> cuffed")) or false 
        local jailData = e:getData("jail >> data") or false 
        local customInterior = e:getData("customInterior") or 0
        local blackJackCoins = e:getData("char >> blackJackCoins") or {}
        
        local details = {
            ['health'] = Health, 
            ['armor'] = Armor, 
            ['skin'] = SkinID, 
            ['money'] = Money, 
            ['playedTime'] = PlayedTime, 
            ['level'] = Level, 
            ['pp'] = premiumPoints, 
            ['job'] = job, 
            ['food'] = food, 
            ['drink'] = drink, 
            ['vehicleLimit'] = vehicleLimit, 
            ['interiorLimit'] = interiorLimit, 
            ['avatar'] = avatar, 
            ['isKnow'] = isKnow, 
            ['bones'] = Bones, 
            ['isHidden'] = isHidden, 
            ['bloodData'] = BloodData, 
            ['crosshair'] = crosshair, 
            ['crosshairColor'] = crosshairColor, 
            ['stats'] = stats, 
            ['dutyDatas'] = dutyDatas, 
            ['cuffed'] = cuffed, 
            ['bondage'] = bondage, 
            ['blinded'] = blinded, 
            ['jailData'] = jailData,
            ["customInterior"] = customInterior,
            ["blackJackCoins"] = blackJackCoins,
        }

        local bulletsInBody = e:getData("bulletsInBody") or {}
        local deathDetails = {
            ['dead'] = dead, 
            ['reason'] = reason, 
            ['headless'] = headless, 
            ['bulletsInBody'] = bulletsInBody,
        }
        
        local abool = e:getData("char >> ajail") or false
        local areason = e:getData("char >> ajail >> reason") or ""
        local atype = e:getData("char >> ajail >> type") or 0
        local aadmin = e:getData("char >> ajail >> admin") or ""
        local adminlevel = e:getData("char >> ajail >> aLevel") or 0
        local atime = e:getData("char >> ajail >> time") or 0
        local ajail = {abool,areason,atype,aadmin,atime,adminlevel}
        
        local adminDetails = {
            ['alevel'] = alevel, 
            ['nick'] = nick, 
            ['adutyTime'] = adutyTime, 
            ['usedCmds'] = usedCmds, 
            ['ajail'] = ajail,
        }
        local groupID = tonumber(e:getData("char >> groupId") or 0)
        
        --characters = {id, ownerAccountName, charname, position, details, charDetails, deathDetails, adminDetails}
        characters[id][2] = charname
        characters[id][3] = position
        characters[id][4] = details
        characters[id][5] = charDetails
        characters[id][6] = deathDetails
        characters[id][7] = adminDetails
        characters[id][9] = groupID
        
        -- outputChatBox("Position:" .. toJSON(position))
        -- outputChatBox("Details:" .. toJSON(details))
        -- outputChatBox("CharDetails:" .. toJSON(charDetails))
        -- outputChatBox("DeathDetails:" .. toJSON(deathDetails))
        -- outputChatBox("AdminDetails:" .. toJSON(adminDetails))
        -- outputChatBox("ID:" .. id)

        --outputDebugString("Account #"..id.." - saved", 0, 200, 200, 200)
        
        dbExec(connection, "UPDATE `characters` SET `charname`=?, `position`=?, `details`=?, `charDetails`=?, `deathDetails`=?, `adminDetails`=? WHERE `id`=?", charname, toJSON(position), toJSON(details), toJSON(charDetails), toJSON(deathDetails), toJSON(adminDetails), id)
    end
end

addEventHandler("onPlayerQuit", root,
    function()
        savePlayer(source)
        local id = getElementData(source, "acc >> id")
        if id then
            outputDebugString("Account #"..id.." - saved", 0, 200, 200, 200)
        end
    end
)

function saveAllPlayers()
    local count = 0
    outputDebugString("Started saving accounts...", 0, 200, 200, 200)
    for k,v in pairs(getElementsByType("player")) do
        local co = coroutine.create(savePlayer)
        coroutine.resume(co, v)
        count = count + 1
    end
    outputDebugString("Saved #"..count.." accounts!", 0, 200, 200, 200)
end
addEventHandler("onResourceStop", resourceRoot, saveAllPlayers)
setTimer(saveAllPlayers, 15 * 60 * 1000, 0)