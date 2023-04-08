local cache = {
    --{"CommandName", isCommandHaveSubTag(Ha van a kommand után subTag pld: /walk 2 (Itt 2 a subtag) akkor ez legyen true), subTagID, {animationBlock, animationName}, isCarAnimation},
    {"fall", false, nil, {"ped", "FLOOR_hit", -1, false, false, false}},
    {"fallfront", false, nil, {"ped", "FLOOR_hit_f", -1, false, false, false}},
    {"what", false, nil, {"RIOT", "RIOT_ANGRY", -1, true, false, false}},
    {"dive", false, nil, {"ped", "EV_dive", -1, false, true, false}},
    {"shocked", false, nil, {"ON_LOOKERS", "panic_loop", -1, true, false, false}},
    {"bitchslap", false, nil, {"MISC", "bitchslap", -1, true, false, false}},
    {"shove", false, nil, {"GANGS", "shake_carSH", -1, true, false, false}},
    {"grabbottle", false, nil, {"BAR", "Barserve_bottle", 4000, false, false, false}},
    {"tired", false, nil, {"FAT", "idle_tired", -1, true, false, false}},
    {"carchat", false, nil, {"CAR_CHAT", "car_talkm_loop", -1, true, false, false}},
    {"startrace", false, nil, {"CAR", "flag_drop", -1, true, false, false}},
    {"laugh", false, nil, {"RAPPING", "Laugh_01", -1, true, false, false}},
    {"drag", false, nil, {"SMOKING", "M_smk_drag", -1, true, false, false}},
    {"smokelean", false, nil, {"LOWRIDER", "M_smklean_loop", -1, true, false, false}},
    {"aim", false, nil, {"SHOP", "ROB_Loop_Threat", -1, false, true, false}},
    {"puke", false, nil, {"FOOD", "EAT_Vomit_P", 8000, true, false, false}},
    {"cry", false, nil, {"GRAVEYARD", "mrnF_loop", -1, true, false, false}},
    {"mourn", false, nil, {"GRAVEYARD", "mrnM_loop", -1, true, false, false}},
    {"beg", false, nil, {"SHOP", "SHP_Rob_React", -1, false, false, false}},
    {"drink", false, nil, {"BAR", "dnk_stndM_loop", -1, false, false, false}},
    {"heil", false, nil, {"ON_LOOKERS", "Pointup_in", -1, false, true, false}},
    {"lightup", false, nil, {"SMOKING", "M_smk_in", 4000, true, true, false}},
    {"fu", false, nil, {"RIOT", "RIOT_FUKU", 800, false, true, false}},
    {"scratch", false, nil, {"MISC", "Scratchballs_01", -1, true, true, false}},
    {"hailtaxi", false, nil, {"MISC", "Hiker_Pose", -1, false, true, false}},
    {"handsup", false, nil, {"ped", "handsup", -1, false, false, false}},
    {"fixcar", false, nil, {"CAR", "Fixn_Car_loop", -1, true, false, false}},
    {"slapass", false, nil, {"SWEET", "sweet_ass_slap", -1, true, false, false}},
    {"wank", false, nil, {"PAULNMAC", "wank_loop", -1, true, false, false}},
    {"piss", false, nil, {"PAULNMAC", "Piss_loop", -1, true, false, false}},
    {"idle", false, nil, {"DEALER", "DEALER_IDLE_01", -1, true, false, false}},
    {"lean", false, nil, {"GANGS", "leanIDLE", -1, true, false, false}},
    {"shake", false, nil, {"COP_AMBIENT", "Coplook_shake", -1, true, false, false}},
    {"think", false, nil, {"COP_AMBIENT", "Coplook_think", -1, true, false, false}},
    {"wait", false, nil, {"COP_AMBIENT", "Coplook_loop", -1, true, false, false}},
    {"copstop", false, nil, {"POLICE", "CopTraf_Stop", -1, true, false, false}},
    {"copleft", false, nil, {"POLICE", "CopTraf_Left", -1, true, false, false}},
    {"copcome", false, nil, {"POLICE", "CopTraf_Come", -1, true, false, false}},
    {"copaway", false, nil, {"police", "coptraf_away", -1, true, false, false}},
    {"cpr", false, nil, {"medic", "cpr", -1, false, true, false}},
    {"cover", false, nil, {"ped", "duck_cower", -1, false, false, false}},
    {"daps", true, nil, nil},
    {"walk", true, nil, nil},
    {"win", true, nil, nil},
    {"bat", true, nil, nil},
    {"sit", true, nil, nil, true},
    {"strip", true, nil, nil},
    {"lay", true, nil, nil},
    {"cheer", true, nil, nil},
    {"dance", true, nil, nil},
    {"crack", true, nil, nil},
    {"gsign", true, nil, nil},
    {"rap", true, nil, nil},
    {"smoke", true, nil, nil},
}

local maxSubTags = {
    --["CommandName"] = 6
    ["daps"] = 6,
    ["lay"] = 2,
    ["strip"] = 2,
    ["bat"] = 3,
    ["dance"] = 10,
    ["cheer"] = 3,
    ["rap"] = 3,
    ["smoke"] = 3,
    ["walk"] = 36,
    ["win"] = 2,
    ["crack"] = 4,
    ["sit"] = 5,
    ["gsign"] = 5,
}

local animDescriptions = {
    ["fall"] = "Háton fekvés a földön, széttárt kezekkel és lábakkal",
    ["fallfront"] = "Hason fekvés a földön, széttárt kezekkel és lábakkal",
    ["what"] = "Kezek felemelése ismételve, majd lépegetés egy helyben",
    ["dive"] = "Előre vetődés a földön, majd hason fekve maradás",
    ["shocked"] = "Meglepődés, majd a kéz szájra tétele és úgy maradás",
    ["bitchslap"] = "Örömlányás verés a földre térdelve, kéz csapkodással",
    ["shove"] = "Legugolás majd az ajtónak feszülés oldalasan",
    ["grabbottle"] = "Üveg kivétele a pult alól, láb felemeléssel",
    ["tired"] = "Kezek térde tétele, madj enyhén előre dőlve kifáradás",
    ["carchat"] = "Enyhén előre dőlés, majd kéz kocsira tétele és beszéd",
    ["startrace"] = "Bal kéz felemelése, majd verseny indítása lecsapással",
    ["laugh"] = "Jobb kéz meglendítése, majd hosszas nevetés/röhögés",
    ["drag"] = "Jobb kéz szájra tétele majd cigaretta/egyéb szívás",
    ["smokelean"] = "Falnak dőlés, majd jobb kézzel cigaretta szívás",
    ["aim"] = "Jobb kézzel előre célzás, majd úgy maradás",
    ["puke"] = "Oldalra fordulás, majd rókázás előre dőlve",
    ["cry"] = "Bal kéz arcra tétele, majd hosszas sírás",
    ["mourn"] = "Fej előre lógatása, majd gyászolás",
    ["beg"] = "Viszakozás valamitől, majd kézfeltétel",
    ["drink"] = "Jobb kézzel való ivás majd abbahagyás",
    ["heil"] = "Bal kéz kiemelése a magasba majd úgy maradás",
    ["lightup"] = "Öngyűjtó gyújtás bal és jobb kézzel",
    ["fu"] = "Bemutatás az adott félnek jobb kézzel",
    ["scratch"] = "Nemi szerv vakargatás jobb és bal kézzel",
    ["hailtaxi"] = "Gépjármű stoppolás jobb kézzel, kissé elhajolva",
    ["handsup"] = "Kezek feltétele fej mellé, majd úgy maradás",
    ["fixcar"] = "Gépjármű alá befekés háton, majd szerelése",
    ["slapass"] = "Fenékre csapás bal kézzel kisebb erővel",
    ["wank"] = "Maszturbáció jobb kézzel kissé begörnyedve",
    ["piss"] = "Pisilés jobb kézzel, széttárt lábakkal",
    ["idle"] = "Várakozás, jobb kézzel ismétlődő fejbiccentéssel",
    ["lean"] = "Falnak dőlés csípőre tett bal kézzel",
    ["shake"] = "Várakozás, mind a két kézzel csipőre téve ismételve",
    ["think"] = "Gondolkodás kezeit egymásra téve ismételve",
    ["wait"] = "Egyszerű várakozás, összekulcsolt kezekkel",
    ["copstop"] = "Gépjárműnek való 'megálj'-jelzés előröl, ismételve",
    ["copleft"] = "Gépjárműn átirányítása bal oldalra ismételve",
    ["copcome"] = "Gépjárműnek való haladás engedélyezés ismételve",
    ["copaway"] = "Gépjármű elküldése az adott helyszínről",
    ["cpr"] = "Újraélesztés összekulcsolt kezekkel, letérdeve",
    ["cover"] = "Legugolva, védi a fejét tarkóra tett kézzel",
    ["daps"] = "Kezelés az adott féllel ismételve",
    ["walk"] = "Sétálás megállás nélkül",
    ["win"] = "Győzelem nyilvánítás/kikiáltás",
    ["bat"] = "Baseball ütő megtartása/lengetése",
    ["sit"] = "Leülés a földre/egyéb bútorokra",
    ["strip"] = "Sztriptíz tánc a földön/állva",
    ["lay"] = "Földön fekvés nyugalmi állapotban",
    ["cheer"] = "Éljenezés az adott szituációnak",
    ["dance"] = "Táncolás a földön több módon",
    ["crack"] = "Önkívületi állapot kimutatása",
    ["gsign"] = "Két kézzel való gesztikulálás",
    ["rap"] = "Rappelés az adott szituációban",
    ["smoke"] = "Cigarettázás több módon",
}
local subTagAnims = {
    --["walk".."1"] = {animBlock, animName}
    ["strip1"] = {"STRIP", "strip_D", -1, false, true, false},
    ["strip2"] = {"STRIP", "STR_Loop_C", -1, false, true, false},
    ["lay1"] = {"BEACH", "Lay_Bac_Loop", -1, true, false, false},
    ["lay2"] = {"BEACH", "sitnwait_Loop_W", -1, true, false, false},
    ["cheer1"] = {"STRIP", "PUN_HOLLER", -1, true, false, false},
    ["cheer2"] = {"OTB", "wtchrace_win", -1, true, false, false},
    ["cheer3"] = {"RIOT", "RIOT_shout", -1, true, false, false},
    ["dance1"] = {"DANCING", "DAN_Right_A", -1, true, false, false},
    ["dance2"] = {"DANCING", "DAN_Down_A", -1, true, false, false},
    ["dance3"] = {"DANCING", "dnce_M_d", -1, true, false, false},
    ["dance4"] = {"DANCING", "dance_loop", -1, true, false, false},
    ["dance5"] = {"DANCING", "dnce_m_c", -1, true, false, false},
    ["dance6"] = {"DANCING", "dnce_m_e", -1, true, false, false},
    ["dance7"] = {"DANCING", "dnce_m_a", -1, true, false, false},
    ["dance8"] = {"DANCING", "bd_clap", -1, true, false, false},
    ["dance9"] = {"DANCING", "dan_up_a", -1, true, false, false},
    ["dance10"] = {"DANCING", "dan_left_a", -1, true, false, false},
    ["crack1"] = {"CRACK", "crckidle2", -1, true, false, false},
    ["crack2"] = {"CRACK", "crckidle1", -1, true, false, false},
    ["crack3"] = {"CRACK", "crckidle3", -1, true, false, false},
    ["crack4"] = {"CRACK", "crckidle4", -1, true, false, false},
    ["gsign1"] = {"GHANDS", "gsign1", -1, true, false, false},
    ["gsign2"] = {"GHANDS", "gsign2", -1, true, false, false},
    ["gsign3"] = {"GHANDS", "gsign3", -1, true, false, false},
    ["gsign4"] = {"GHANDS", "gsign4", -1, true, false, false},
    ["gsign5"] = {"GHANDS", "gsign5", -1, true, false, false},
    ["rap1"] = {"LOWRIDER", "RAP_A_Loop", -1, true, false, false},
    ["rap2"] = {"LOWRIDER", "RAP_B_Loop", -1, true, false, false},
    ["rap3"] = {"LOWRIDER", "RAP_C_Loop", -1, true, false, false},
    ["sit1"] = {"ped", "SEAT_idle", -1, true, false, false},
    ["sit2"] = {"FOOD", "FF_Sit_Look", -1, true, false, false},
    ["sit3"] = {"Attractors", "Stepsit_loop", -1, true, false, false},
    ["sit4"] = {"BEACH", "ParkSit_W_loop", 1, true, false, false},
    ["sit5"] = {"BEACH", "ParkSit_M_loop", 1, true, false, false},
    ["win1"] = {"CASINO", "manwind", 2000, false, false, false},
    ["win2"] = {"CASINO", "manwinb", 2000, false, false, false},
    ["bat1"] = {"CRACK", "Bbalbat_Idle_01", -1, true, false, false},
    ["bat2"] = {"CRACK", "Bbalbat_Idle_02", -1, true, false, false},
    ["bat3"] = {"Baseball", "Bat_IDLE", -1, true, false, false},
    ["smoke1"] = {"GANGS", "smkcig_prtl", -1, true, false, false},
    ["smoke2"] = {"SMOKING", "M_smkstnd_loop", -1, true, false, false},
    ["smoke3"] = {"LOWRIDER", "M_smkstnd_loop", -1, true, false, false},
    ["daps1"] = {"GANGS", "hndshkca", -1, true, false, false},
    ["daps2"] = {"GANGS", "hndshkfa", -1, true, false, false},
    ["daps3"] = {"GANGS", "hndshkea", -1, true, false, false},
    ["daps4"] = {"GANGS", "hndshkda", -1, true, false, false},
    ["daps5"] = {"GANGS", "hndshkba", -1, true, false, false},
    ["daps6"] = {"GANGS", "hndshkaa", -1, true, false, false},
    ["walk1"] = {"PED", "WALK_armed", -1, true, true, false},
    ["walk2"] = {"PED", "WALK_civi", -1, true, true, false},
    ["walk3"] = {"PED", "WALK_csaw", -1, true, true, false},
    ["walk4"] = {"PED", "Walk_DoorPartial", -1, true, true, false},
    ["walk5"] = {"PED", "WALK_drunk", -1, true, true, false},
    ["walk6"] = {"PED", "WALK_fat", -1, true, true, false},
    ["walk7"] = {"PED", "WALK_fatold", -1, true, true, false},
    ["walk8"] = {"PED", "WALK_gang1", -1, true, true, false},
    ["walk9"] = {"PED", "WALK_gang2", -1, true, true, false},
    ["walk10"] = {"PED", "WALK_old", -1, true, true, false},
    ["walk11"] = {"PED", "WALK_player", -1, true, true, false},
    ["walk12"] = {"PED", "WALK_rocket", -1, true, true, false},
    ["walk13"] = {"PED", "WALK_shuffle", -1, true, true, false},
    ["walk14"] = {"PED", "Walk_Wuzi", -1, true, true, false},
    ["walk15"] = {"PED", "woman_run", -1, true, true, false},
    ["walk16"] = {"PED", "WOMAN_runbusy", -1, true, true, false},
    ["walk17"] = {"PED", "WOMAN_runfatold", -1, true, true, false},
    ["walk18"] = {"PED", "woman_runpanic", -1, true, true, false},
    ["walk19"] = {"PED", "WOMAN_runsexy", -1, true, true, false},
    ["walk20"] = {"PED", "WOMAN_walkbusy", -1, true, true, false},
    ["walk21"] = {"PED", "WOMAN_walkfatold", -1, true, true, false},
    ["walk22"] = {"PED", "WOMAN_walknorm", -1, true, true, false},
    ["walk23"] = {"PED", "WOMAN_walkold", -1, true, true, false},
    ["walk24"] = {"PED", "WOMAN_walkpro", -1, true, true, false},
    ["walk25"] = {"PED", "WOMAN_walksexy", -1, true, true, false},
    ["walk26"] = {"PED", "WOMAN_walkshop", -1, true, true, false},
    ["walk27"] = {"PED", "run_1armed", -1, true, true, false},
    ["walk28"] = {"PED", "run_armed", -1, true, true, false},
    ["walk29"] = {"PED", "Run_Wuzi", -1, true, true, false},
    ["walk30"] = {"PED", "run_csaw", -1, true, true, false},
    ["walk31"] = {"PED", "run_fat", -1, true, true, false},
    ["walk32"] = {"PED", "run_fatold", -1, true, true, false},
    ["walk33"] = {"PED", "run_gang1", -1, true, true, false},
    ["walk34"] = {"PED", "run_old", -1, true, true, false},
    ["walk35"] = {"PED", "run_player", -1, true, true, false},
    ["walk36"] = {"PED", "run_rocket", -1, true, true, false},
}

function boneBreaked(e)
    --char >> bone felépítése = {Has, Bal kéz, Jobb kéz, Bal láb, Jobb láb}
    local bone = getElementData(e, "char >> bone") or {true, true, true, true, true}
    if not bone[4] or not bone[5] then 
        return true
    end
    return false
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(cache) do
            if getElementData(localPlayer, "freeze") then return end
            local commandName, isCommandHaveSubTag, subTagID, animDetails, isCarAnimation = unpack(v)
            if isCommandHaveSubTag then
                addCommandHandler(commandName,
                    function(cmd, id)
                        local forceAnim = false
                        local forceAnimation = getElementData(localPlayer, "forceAnimation") or {"", ""}
                        if commandName == "walk" then
                            if boneBreaked(localPlayer) then return end
                        end
                        if forceAnimation[1] ~= "" or forceAnimation[2] ~= "" then
                            forceAnim = true
                        end
                        if forceAnim then
                            return
                        end
                        -- if not localPlayer.onGround then 
                        --     return
                        -- end 
                        if getElementData(localPlayer, "char >> tazed") then
                            return
                        end
                        if getElementData(localPlayer, "char >> cuffed") then
                            return
                        end
                        if not getElementData(localPlayer, "loggedIn") then
                            return
                        end
                        if getElementData(localPlayer, "inDeath") then
                            return
                        end
                        if getPedOccupiedVehicle(localPlayer) then
                            if not isCarAnimation then
                                return
                            end
                        end
                        if not id then
                            if not isCarAnimation then
                                local syntax = exports['cr_core']:getServerSyntax(false, "error")
                                local maxSubTag = maxSubTags[cmd] or 1
                                outputChatBox(syntax .. "/"..cmd.." [ID (1-"..maxSubTag..")]", 255,255,255,true)
                                return
                            else
                                id = 1
                            end
                        elseif tonumber(id) == nil then
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            outputChatBox("Az ID-nek egy számnak kell lennie", 255,255,255,true)
                            return
                        end
                        id = tonumber(id)
                        local animDetails = subTagAnims[cmd..tostring(id)]
                        if not animDetails then
                            local syntax = exports['cr_core']:getServerSyntax(false, "error")
                            local maxSubTag = maxSubTags[cmd] or 1
                            outputChatBox(syntax .. "/"..cmd.." [ID (1-"..maxSubTag..")]", 255,255,255,true)
                            return
                            --animDetails = subTagAnims[cmd.."1"]
                        end
                        if isElementInWater(localPlayer) then return end
                        local block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime
                        if animDetails then
                            block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime = unpack(animDetails)
                        end
                        local veh = getPedOccupiedVehicle(localPlayer)
                        if veh then
                            if not isCarAnimation then
                                return
                            else
                                if getVehicleType(veh) == "BMX" or getVehicleType(veh) == "Bike" or getVehicleType(veh) == "Quad" then
                                    return
                                end
                                if commandName == "sit" then
                                    block, anim, time, loop, updatePosition = nil
                                    if id == 1 then
                                        block, anim = "CAR", "Sit_relaxed"
                                    else
                                        block, anim = "CAR", "Tap_hand"
                                    end
                                end
                            end
                        end
                        applyAnimation(localPlayer, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime)
                    end, false, false
                )
            else
                addCommandHandler(commandName,
                    function(cmd)
                        local forceAnim = false
                        local forceAnimation = getElementData(localPlayer, "forceAnimation") or {"", ""}
                        if forceAnimation[1] ~= "" or forceAnimation[2] ~= "" then
                            forceAnim = true
                        end
                        if forceAnim then
                            return
                        end
                        -- if not localPlayer.onGround then 
                        --     return
                        -- end 
                        if getElementData(localPlayer, "char >> tazed") then
                            return
                        end
                        if getElementData(localPlayer, "char >> cuffed") then
                            return
                        end
                        if not getElementData(localPlayer, "loggedIn") then
                            return
                        end
                        if getElementData(localPlayer, "inDeath") then
                            return
                        end
                        if isElementInWater(localPlayer) then return end
                        local block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime = unpack(animDetails)
                        if getPedOccupiedVehicle(localPlayer) then
                            if not isCarAnimation then
                                return
                            end
                        end
                        applyAnimation(localPlayer, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime)
                    end, false, false
                )
            end
        end
    end
)

function applyAnimation(element, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime)
    if not getElementData(element, "objectInHand") then
        triggerServerEvent("applyAnimation", localPlayer, element, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime)
    end
end

function removeAnimation(element)
    triggerServerEvent("removeAnimation", localPlayer, element)
end

function stopAnimation()
    local anim = localPlayer:getData("forceAnimation") or {"", ""}
    if anim[1] ~= "" or anim[2] ~= "" then return end
    removeAnimation(localPlayer)
end

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName, oValue)
        if getElementData(localPlayer, "freeze") then return end
        if dName == "realAnimation" then
            local value = getElementData(localPlayer, dName)
            if value then
                if not aState then
                    bindKey("space", "down", stopAnimation)
                    addCommandHandler("stopanim", stopAnimation)
                    addCommandHandler("stopanimation", stopAnimation)
                    addEventHandler("onClientRender", root, rotationOrder, true, "low-5")
                    aState = true
                end
            else
                if aState then
                    unbindKey("space", "down", stopAnimation)
                    removeCommandHandler("stopanim", stopAnimation)
                    removeCommandHandler("stopanimation", stopAnimation)
                    removeEventHandler("onClientRender", root, rotationOrder, true, "low-5")
                    aState = false
                end
            end 
        end
    end
)

function rotationOrder()
    for i = 1, maxSubTags["walk"] do
        local block, style = getPedAnimation(localPlayer)
		if block == "ped" and subTagAnims["walk"..tostring(i)][2] == style then
			local px, py, pz, lx, ly, lz = getCameraMatrix()
			setElementRotation(localPlayer, 0, 0, math.deg(math.atan2(ly - py, lx - px)) - 90, "default", true)
		end
    end
end

if getElementData(localPlayer, "realAnimation") then
    if getElementData(localPlayer, "freeze") then return end
    bindKey("space", "down", stopAnimation)
    addCommandHandler("stopanim", stopAnimation)
    addCommandHandler("stopanimation", stopAnimation)
    addEventHandler("onClientRender", root, rotationOrder, true, "low-5")
    aState = true
end

function showAnimationPanel()
    if not getElementData(localPlayer, "loggedIn") then
        return
    end
    if getElementData(localPlayer, "freeze") then return end
    
    local data = {
        ["hoverText"] = "Animáció lista",
        ['altText'] = "Elérhető animációk listája:",
        ["minLines"] = 1,
        ["maxLines"] = 14,
        ["type"] = "anims",
    }

    local texts = {}

    local blue = exports['cr_core']:getServerColor("yellow", true)
    local white = "#f2f2f2"

    for k,v in pairs(cache) do
        local commandName, isCommandHaveSubTag, subTagID, animDetails, isCarAnimation = unpack(v)
        local text = white.."/"..blue..commandName..white
        if isCommandHaveSubTag then
            local maxSubTags = maxSubTags[commandName]
            text = text .. " [ID (1-"..maxSubTags..")]"
        end
        local description = white .. animDescriptions[commandName] or "Ismeretlen"
        table.insert(texts, {text, description})
    end

    data["texts"] = texts
    exports['cr_dx']:openInformationsPanel(data)
end
addCommandHandler("anims", showAnimationPanel)
addCommandHandler("animlist", showAnimationPanel)
addCommandHandler("animations", showAnimationPanel)

function getAnimations()
    return cache
end

function isPlayerHaveActiveAnimation(element)
    if not getPedAnimation(element) or getPedAnimation(element):gsub(" ", "") == "" then 
        return false 
    end 

    return true
end 