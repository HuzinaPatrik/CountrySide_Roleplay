playerOptions = {}

defaultOptions = {
    ["viewdistance"] = 1500,
    ["headsync"] = 1,
    ['ramfree'] = 1,
    ['defaultwalk'] = 1,
    ["shoutanimation"] = 1,
    ["walkstyle"] = 1,
    ["fightstyle"] = 1,
    ['afkWarning'] = 1,
    ['networkWarning'] = 1,
    ['streamerMode'] = 0,
    ["speakanimation"] = 1,
    ["shaders.sky"] = 0,
    ["shaders.blackwhite"] = 0,
    ["shaders.motionblur"] = 0,
    ["shaders.bloom"] = 0,
    ["shaders.hdr"] = 0,
    ["shaders.vignette"] = 0,
    ["shaders.pencil"] = 0,
    ["shaders.carshinereflection"] = 0,
    ["shaders.night"] = 0,
    ["shaders.water"] = 0,
    ["shaders.palette"] = 1,
    ["shaders.detail"] = 0,
    ["nametag.myname"] = 0,
    ["nametag.font"] = 1,
    ["nametag.descriptions"] = 1,
    ["chat.bubbles"] = 1,
    ["chat.mybubbles"] = 0,
    ["customchat.font"] = 1,
    ["customchat.fontsize"] = 6,
    ["customchat.fontbold"] = 0,
    ["customchat.fadeout"] = 1,
    ["customchat.showtime"] = 30,
    ["customchat.fadeoutmultiplier"] = 30,
    ["customchat.backgroundr"] = 0,
    ["customchat.backgroundg"] = 0,
    ["customchat.backgroundb"] = 0,
    ["customchat.backgrounda"] = 0,
    ["customchat.cacheremain"] = 10,
    ["customchat.outline"] = 0,
    ["oocchat.font"] = 1,
    ["oocchat.fontsize"] = 6,
    ["oocchat.fontbold"] = 0,
    ["oocchat.fadeout"] = 1,
    ["oocchat.showtime"] = 30,
    ["oocchat.fadeoutmultiplier"] = 30,
    ["oocchat.backgroundr"] = 0,
    ["oocchat.backgroundg"] = 0,
    ["oocchat.backgroundb"] = 0,
    ["oocchat.backgrounda"] = 0,
    ["oocchat.cacheremain"] = 10,
    ["oocchat.outline"] = 0,
}

local walkStyles = {
    118,
    119,
    120,
    123,
    135,
    121,
    122,
    124,
    129,
    130,
    131,
    132,
    133,
    134,
}

local fightStyles = {
    5,
    4, 
    6, 
    15,
    16,
}

addEvent("email.error", true)
addEventHandler("email.error", localPlayer, 
    function()
        SetText("1>>inputBar", localPlayer:getData("acc >> email") or "Ismeretlen")
    end 
)

function loadOptions()
    playerOptions = exports['cr_json']:jsonGET("dashboard/options.json", true, defaultOptions)

    for k,v in pairs(defaultOptions) do 
        if tonumber(v) then 
            if not tonumber(playerOptions[k]) then 
                playerOptions[k] = v
            end 
        else 
            if not playerOptions[k] then 
                playerOptions[k] = v
            end 
        end 
    end 

    options = {
        {
            ["name"] = "Általános",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Email cím",
                    ["type"] = 3,
                    ["optionName"] = "email",
                    ["nowValue"] = playerOptions["email"],
                    ["icon"] = textures["user"],
                    ["getDefaultValue"] = function()
                        return localPlayer:getData("acc >> email") or "Ismeretlen"
                    end, 
                    ["onChange"] = function(oldVal, newVal)
                        if not newVal:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") then
                            SetText("1>>inputBar", localPlayer:getData("acc >> email") or "Ismeretlen")
                            exports["cr_infobox"]:addBox("error", "Használj rendes emailcímet (Pld: xyz@gmail.com)!")
                            return 
                        end 

                        triggerLatentServerEvent("change.accEmail", 5000, false, localPlayer, localPlayer, localPlayer:getData("acc >> username"), newVal)
                        --localPlayer:setData("acc >> email", newVal)
                    end,
                },
                
                {
                    ["name"] = "Látótávolság",
                    ["type"] = 4,
                    ["optionName"] = "viewdistance",
                    ["minValue"] = 50,
                    ["nowValue"] = playerOptions["viewdistance"],
                    ["maxValue"] = 3000,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["viewdistance"] = newVal
                        setFarClipDistance(playerOptions["viewdistance"])
                    end,
                    ["onLoad"] = function()
                        setFarClipDistance(playerOptions["viewdistance"])
                    end 
                },

                {
                    ["name"] = "Séta stílus",
                    ["type"] = 5,
                    ["optionName"] = "walkstyle",
                    ["buttonName"] = "walkstyle",
                    ["nowValue"] = playerOptions["walkstyle"],
                    ["options"] = {
                        "Alap",
                        "Öreg 1",
                        "Öreg 2",
                        "Öreg 3",
                        "Öreg 4",
                        "Banda 1",
                        "Banda 2",
                        "Feszítős",
                        "Női 1",
                        "Női 2",
                        "Női 3",
                        "Női 4",
                        "Női 5",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["walkstyle"] = newVal
                        localPlayer:setData("char >> walkStyle", walkStyles[tonumber(newVal)])
                    end,
                    ["onLoad"] = function()
                        localPlayer:setData("char >> walkStyle", walkStyles[playerOptions["walkstyle"]])
                    end,
                },

                {
                    ["name"] = "Harc stílus",
                    ["type"] = 5,
                    ["optionName"] = "fightstyle",
                    ["buttonName"] = "fightstyle",
                    ["nowValue"] = playerOptions["fightstyle"],
                    ["options"] = {
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["fightstyle"] = newVal
                        localPlayer:setData("char >> fightStyle", fightStyles[tonumber(newVal)])
                    end,
                    ["onLoad"] = function()
                        localPlayer:setData("char >> fightStyle", fightStyles[playerOptions["fightstyle"]])
                    end,
                },

                {
                    ["name"] = "Fejmozgatás szinkronizálása",
                    ["type"] = 1,
                    ["optionName"] = "headsync",
                    ["nowValue"] = playerOptions["headsync"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["headsync"] = newVal
                        if playerOptions["headsync"] == 1 then 
                            exports['cr_head']:toggleHeadMove(playerOptions["headsync"])
                        else 
                            exports['cr_head']:toggleHeadMove(playerOptions["headsync"])
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["headsync"] == 1 then 
                            exports['cr_head']:toggleHeadMove(playerOptions["headsync"])
                        end 
                    end 
                },

                {
                    ["name"] = "Alap járás",
                    ["type"] = 5,
                    ["optionName"] = "defaultwalk",
                    ["buttonName"] = "Alap járás",
                    ["nowValue"] = playerOptions["defaultwalk"],
                    ["options"] = {
                        "Séta",
                        "Kocogás",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["defaultwalk"] = newVal

                        exports['cr_interface']:changeWalkingStatus(playerOptions['defaultwalk'] == 1)
                    end,
                    ["onLoad"] = function()
                        exports['cr_interface']:changeWalkingStatus(playerOptions['defaultwalk'] == 1)
                    end 
                },

                {
                    ["name"] = "Intelligens memória ürítés",
                    ["type"] = 1,
                    ["optionName"] = "ramfree",
                    ["nowValue"] = playerOptions["ramfree"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["ramfree"] = newVal
                        if playerOptions["ramfree"] == 1 then 
                            toggleRamFree(playerOptions["ramfree"])
                        else 
                            toggleRamFree(playerOptions["ramfree"])
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["ramfree"] == 1 then 
                            toggleRamFree(playerOptions["ramfree"])
                        end 
                    end 
                },

                {
                    ["name"] = "AFK figyelmeztetés",
                    ["type"] = 1,
                    ["optionName"] = "afkWarning",
                    ["nowValue"] = playerOptions["afkWarning"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["afkWarning"] = newVal
                    end,
                },

                {
                    ["name"] = "Internet hiba figyelmeztetés",
                    ["type"] = 1,
                    ["optionName"] = "networkWarning",
                    ["nowValue"] = playerOptions["networkWarning"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["networkWarning"] = newVal
                    end,
                },

                {
                    ["name"] = "Streamer mód",
                    ["type"] = 1,
                    ["optionName"] = "streamerMode",
                    ["nowValue"] = playerOptions["streamerMode"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["streamerMode"] = newVal
                        if playerOptions["streamerMode"] == 1 then 
                            exports['cr_radio']:deSyncAllVehicles()
                            exports['cr_hifi']:deSyncAllHifis()
                        else 
                            exports['cr_radio']:syncAllVehicles()
                            exports['cr_hifi']:syncAllHifis()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["streamerMode"] == 1 then 
                            exports['cr_radio']:deSyncAllVehicles()
                            exports['cr_hifi']:deSyncAllHifis()
                        end 
                    end 
                },
            },
        },

        {
            ["name"] = "Grafikai",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Paletta",
                    ["type"] = 5,
                    ["optionName"] = "shaders.palette",
                    ["buttonName"] = "Paletta",
                    ["nowValue"] = playerOptions["shaders.palette"],
                    ["options"] = {
                        "Nincs",
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.palette"] = newVal
                        if playerOptions["shaders.palette"] > 1 then 
                            enablePalette(playerOptions["shaders.palette"] - 1)
                        else 
                            disablePalette()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.palette"] > 1 then 
                            enablePalette(playerOptions["shaders.palette"] - 1)
                        end 
                    end 
                },

                {
                    ["name"] = "Realisztikus égbolt",
                    ["type"] = 1,
                    ["optionName"] = "shaders.sky",
                    ["nowValue"] = playerOptions["shaders.sky"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.sky"] = newVal
                        if playerOptions["shaders.sky"] == 1 then 
                            startDynamicSky()
                        else 
                            stopDynamicSky()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.sky"] == 1 then 
                            startDynamicSky()
                        end 
                    end 
                },

                {
                    ["name"] = "Fekete-fehér",
                    ["type"] = 1,
                    ["optionName"] = "shaders.blackwhite",
                    ["nowValue"] = playerOptions["shaders.blackwhite"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.blackwhite"] = newVal
                        if playerOptions["shaders.blackwhite"] == 1 then 
                            startBlackWhite()
                        else 
                            stopBlackWhite()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.blackwhite"] == 1 then 
                            startBlackWhite()
                        end 
                    end 
                },

                {
                    ["name"] = "Mozgási elmosódás",
                    ["type"] = 1,
                    ["optionName"] = "shaders.motionblur",
                    ["nowValue"] = playerOptions["shaders.motionblur"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.motionblur"] = newVal
                        if playerOptions["shaders.motionblur"] == 1 then 
                            enableRadialBlur()
                        else 
                            disableRadialBlur()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.motionblur"] == 1 then 
                            enableRadialBlur()
                        end 
                    end 
                },

                {
                    ["name"] = "Bloom",
                    ["type"] = 1,
                    ["optionName"] = "shaders.bloom",
                    ["nowValue"] = playerOptions["shaders.bloom"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.bloom"] = newVal
                        if playerOptions["shaders.bloom"] == 1 then 
                            enableBloom()
                        else 
                            disableBloom()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.bloom"] == 1 then 
                            enableBloom()
                        end 
                    end 
                },

                {
                    ["name"] = "Kontraszt",
                    ["type"] = 1,
                    ["optionName"] = "shaders.hdr",
                    ["nowValue"] = playerOptions["shaders.hdr"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.hdr"] = newVal
                        if playerOptions["shaders.hdr"] == 1 then 
                            enableContrast()
                        else 
                            disableContrast()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.hdr"] == 1 then 
                            enableContrast()
                        end 
                    end 
                },

                {
                    ["name"] = "Vignetta",
                    ["type"] = 1,
                    ["optionName"] = "shaders.vignette",
                    ["nowValue"] = playerOptions["shaders.vignette"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.vignette"] = newVal
                        if playerOptions["shaders.vignette"] == 1 then 
                            enableVignette()
                        else 
                            disableVignette()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.vignette"] == 1 then 
                            enableVignette()
                        end 
                    end 
                },

                {
                    ["name"] = "Ceruza effekt",
                    ["type"] = 1,
                    ["optionName"] = "shaders.pencil",
                    ["nowValue"] = playerOptions["shaders.pencil"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.pencil"] = newVal
                        if playerOptions["shaders.pencil"] == 1 then 
                            enablePencilShader()
                        else 
                            disablePencilShader()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.pencil"] == 1 then 
                            enablePencilShader()
                        end 
                    end 
                },

                {
                    ["name"] = "Jármű fényvisszaverődés",
                    ["type"] = 1,
                    ["optionName"] = "shaders.carshinereflection",
                    ["nowValue"] = playerOptions["shaders.carshinereflection"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.carshinereflection"] = newVal
                        if playerOptions["shaders.carshinereflection"] == 1 then 
                            startCarPaintRefLite()
                        else 
                            stopCarPaintRefLite()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.carshinereflection"] == 1 then 
                            startCarPaintRefLite()
                        end 
                    end 
                },

                {
                    ["name"] = "Realisztikus éjszaka",
                    ["type"] = 1,
                    ["optionName"] = "shaders.night",
                    ["nowValue"] = playerOptions["shaders.night"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.night"] = newVal
                        if playerOptions["shaders.night"] == 1 then 
                            startNightShader()
                        else 
                            stopNightShader()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.night"] == 1 then 
                            startNightShader()
                        end 
                    end 
                },

                {
                    ["name"] = "Realisztikus víz",
                    ["type"] = 1,
                    ["optionName"] = "shaders.water",
                    ["nowValue"] = playerOptions["shaders.water"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.water"] = newVal
                        if playerOptions["shaders.water"] == 1 then 
                            startWaterShader()
                        else 
                            stopWaterShader()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.water"] == 1 then 
                            startWaterShader()
                        else 
                            stopWaterShader()
                        end 
                    end 
                },

                {
                    ["name"] = "HD Textúrák",
                    ["type"] = 1,
                    ["optionName"] = "shaders.detail",
                    ["nowValue"] = playerOptions["shaders.detail"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shaders.detail"] = newVal
                        if playerOptions["shaders.detail"] == 1 then 
                            enableDetail()
                        else 
                            disableDetail()
                        end 
                    end,
                    ["onLoad"] = function()
                        if playerOptions["shaders.detail"] == 1 then 
                            enableDetail()
                        end 
                    end 
                },
            },
        },

        {
            ["name"] = "Nametag",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Font",
                    ["type"] = 5,
                    ["optionName"] = "nametag.font",
                    ["buttonName"] = "Font",
                    ["nowValue"] = playerOptions["nametag.font"],
                    ["options"] = {
                        "Roboto",
                        "OpenSans",
                        "RobotoB",
                        "Awesome",
                        "DeansGate",
                        "Gotham",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["nametag.font"] = newVal
                        exports['cr_nametag']:setFont(newVal)
                        
                    end,
                    ["onLoad"] = function()
                        exports['cr_nametag']:setFont(playerOptions["nametag.font"])
                    end 
                },

                {
                    ["name"] = "Saját név mutatása",
                    ["type"] = 1,
                    ["optionName"] = "nametag.myname",
                    ["nowValue"] = playerOptions["nametag.myname"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["nametag.myname"] = newVal
                        exports['cr_nametag']:setMyName(newVal)
                    end,
                    ["onLoad"] = function()
                        exports['cr_nametag']:setMyName(playerOptions["nametag.myname"])
                    end 
                },

                {
                    ["name"] = "Karakter leírások mutatása",
                    ["type"] = 2,
                    ["optionName"] = "nametag.descriptions",
                    ["nowValue"] = playerOptions["nametag.descriptions"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["nametag.descriptions"] = newVal
                        exports['cr_nametag']:setDescriptions(newVal)
                    end,
                    ["onLoad"] = function()
                        exports['cr_nametag']:setDescriptions(playerOptions["nametag.descriptions"])
                    end 
                },
            },
        },

        {
            ["name"] = "Chat",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Beszéd animáció",
                    ["boxShowNowValue"] = true,
                    ["type"] = 5,
                    ["optionName"] = "speakanimation",
                    ["buttonName"] = "speakanimation",
                    ["nowValue"] = playerOptions["speakanimation"],
                    ["options"] = {
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10",
                        "11",
                        "12",
                        "13",
                        "Nincs",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["speakanimation"] = newVal
                        localPlayer:setData("options >> speakanimation", newVal)
                    end,
                    ["onLoad"] = function()
                        localPlayer:setData("options >> speakanimation", playerOptions["speakanimation"])
                    end,
                },

                {
                    ["name"] = "Ordítás animáció",
                    ["type"] = 2,
                    ["optionName"] = "shoutanimation",
                    ["nowValue"] = playerOptions["shoutanimation"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["shoutanimation"] = newVal
                        localPlayer:setData("options >> shoutanimation", playerOptions["shoutanimation"])
                    end,
                    ["onLoad"] = function()
                        localPlayer:setData("options >> shoutanimation", playerOptions["shoutanimation"])
                    end 
                },
                
                {
                    ["name"] = "Szövegbuborékok mutatása",
                    ["type"] = 1,
                    ["optionName"] = "chat.bubbles",
                    ["nowValue"] = playerOptions["chat.bubbles"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["chat.bubbles"] = newVal
                        exports['cr_chat']:setBubbles(newVal)
                    end,
                    ["onLoad"] = function()
                        exports['cr_chat']:setBubbles(playerOptions["chat.bubbles"])
                    end 
                },

                {
                    ["name"] = "Saját szövegbuborékok mutatása",
                    ["type"] = 2,
                    ["optionName"] = "chat.mybubbles",
                    ["nowValue"] = playerOptions["chat.mybubbles"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["chat.mybubbles"] = newVal
                        exports['cr_chat']:setMyBubbles(newVal)
                    end,
                    ["onLoad"] = function()
                        exports['cr_chat']:setMyBubbles(playerOptions["chat.mybubbles"])
                    end 
                },
            },
        },

        {
            ["name"] = "Custom Chat",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Font",
                    ["type"] = 5,
                    ["optionName"] = "customchat.font",
                    ["buttonName"] = "Font",
                    ["nowValue"] = playerOptions["customchat.font"],
                    ["options"] = {
                        "Roboto",
                        "OpenSans",
                        "RobotoB",
                        "Awesome",
                        "DeansGate",
                        "Gotham",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["customchat.font"] = newVal
                        exports['cr_custom-chat']:setICOption("font", playerOptions["customchat.font"])
                        
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("font", playerOptions["customchat.font"])
                    end 
                },

                {
                    ["name"] = "Font méret",
                    ["type"] = 5,
                    ["optionName"] = "customchat.fontsize",
                    ["buttonName"] = "Fontsize",
                    ["nowValue"] = playerOptions["customchat.fontsize"],
                    ["options"] = {
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10",
                        "11",
                        "12",
                        "13",
                        "14",
                        "15",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["customchat.fontsize"] = newVal
                        exports['cr_custom-chat']:setICOption("fontsize", playerOptions["customchat.fontsize"] + 4)
                        
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("fontsize", playerOptions["customchat.fontsize"] + 4)
                    end 
                },

                {
                    ["name"] = "Félkövér",
                    ["type"] = 2,
                    ["optionName"] = "customchat.fontbold",
                    ["nowValue"] = playerOptions["customchat.fontbold"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["customchat.fontbold"] = newVal
                        exports['cr_custom-chat']:setICOption("bold", playerOptions["customchat.fontbold"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("bold", playerOptions["customchat.fontbold"])
                    end 
                },

                {
                    ["name"] = "Szöveg körvonal",
                    ["type"] = 2,
                    ["optionName"] = "customchat.outline",
                    ["nowValue"] = playerOptions["customchat.outline"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["customchat.outline"] = newVal
                        exports['cr_custom-chat']:setICOption("outline", playerOptions["customchat.outline"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("outline", playerOptions["customchat.outline"])
                    end 
                },

                {
                    ["name"] = "Elhalványulás",
                    ["type"] = 1,
                    ["optionName"] = "customchat.fadeout",
                    ["nowValue"] = playerOptions["customchat.fadeout"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["customchat.fadeout"] = newVal
                        exports['cr_custom-chat']:setICOption("fadeout", playerOptions["customchat.fadeout"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("fadeout", playerOptions["customchat.fadeout"])
                    end 
                },

                {
                    ["name"] = "Mutatási idő",
                    ["type"] = 4,
                    ["optionName"] = "customchat.showtime",
                    ["tooltipRound"] = true,
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.showtime"],
                    ["maxValue"] = 60,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.showtime"] = newVal
                        exports['cr_custom-chat']:setICOption("showtime", playerOptions["customchat.showtime"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("showtime", playerOptions["customchat.showtime"])
                    end 
                },

                {
                    ["name"] = "Elhalványulás idő",
                    ["type"] = 4,
                    ["optionName"] = "customchat.fadeoutmultiplier",
                    ["tooltipRound"] = true,
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.fadeoutmultiplier"],
                    ["maxValue"] = 60,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.fadeoutmultiplier"] = newVal
                        exports['cr_custom-chat']:setICOption("fadeoutmultiplier", playerOptions["customchat.fadeoutmultiplier"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("fadeoutmultiplier", playerOptions["customchat.fadeoutmultiplier"])
                    end 
                },

                {
                    ["name"] = "Háttér r",
                    ["type"] = 4,
                    ["optionName"] = "customchat.backgroundr",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.backgroundr"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.backgroundr"] = newVal
                        exports['cr_custom-chat']:setICOption("backgroundr", playerOptions["customchat.backgroundr"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("backgroundr", playerOptions["customchat.backgroundr"])
                    end 
                },

                {
                    ["name"] = "Háttér g",
                    ["type"] = 4,
                    ["optionName"] = "customchat.backgroundg",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.backgroundg"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.backgroundg"] = newVal
                        exports['cr_custom-chat']:setICOption("backgroundg", playerOptions["customchat.backgroundg"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("backgroundg", playerOptions["customchat.backgroundg"])
                    end 
                },

                {
                    ["name"] = "Háttér b",
                    ["type"] = 4,
                    ["optionName"] = "customchat.backgroundb",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.backgroundb"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.backgroundb"] = newVal
                        exports['cr_custom-chat']:setICOption("backgroundb", playerOptions["customchat.backgroundb"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("backgroundb", playerOptions["customchat.backgroundb"])
                    end 
                },

                {
                    ["name"] = "Háttér áttetszőség",
                    ["type"] = 4,
                    ["optionName"] = "customchat.backgrounda",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.backgrounda"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.backgrounda"] = newVal
                        exports['cr_custom-chat']:setICOption("backgrounda", playerOptions["customchat.backgrounda"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("backgrounda", playerOptions["customchat.backgrounda"])
                    end 
                },

                {
                    ["name"] = "Megtartott sorok elhalványulás után",
                    ["type"] = 4,
                    ["optionName"] = "customchat.cacheremain",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["customchat.cacheremain"],
                    ["maxValue"] = 100,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["customchat.cacheremain"] = newVal
                        exports['cr_custom-chat']:setICOption("cacheRemain", playerOptions["customchat.cacheremain"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setICOption("cacheRemain", playerOptions["customchat.cacheremain"])
                    end 
                },
            },
        },

        {
            ["name"] = "OOC Chat",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Font",
                    ["type"] = 5,
                    ["optionName"] = "oocchat.font",
                    ["buttonName"] = "Font",
                    ["nowValue"] = playerOptions["oocchat.font"],
                    ["options"] = {
                        "Roboto",
                        "OpenSans",
                        "RobotoB",
                        "Awesome",
                        "DeansGate",
                        "Gotham",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["oocchat.font"] = newVal
                        exports['cr_custom-chat']:setOOCOption("font", playerOptions["oocchat.font"])
                        
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("font", playerOptions["oocchat.font"])
                    end 
                },

                {
                    ["name"] = "Font méret",
                    ["type"] = 5,
                    ["optionName"] = "oocchat.fontsize",
                    ["buttonName"] = "Fontsize",
                    ["nowValue"] = playerOptions["oocchat.fontsize"],
                    ["options"] = {
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10",
                        "11",
                        "12",
                        "13",
                        "14",
                        "15",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["oocchat.fontsize"] = newVal
                        exports['cr_custom-chat']:setOOCOption("fontsize", playerOptions["oocchat.fontsize"] + 4)
                        
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("fontsize", playerOptions["oocchat.fontsize"] + 4)
                    end 
                },

                {
                    ["name"] = "Félkövér",
                    ["type"] = 2,
                    ["optionName"] = "oocchat.fontbold",
                    ["nowValue"] = playerOptions["oocchat.fontbold"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["oocchat.fontbold"] = newVal
                        exports['cr_custom-chat']:setOOCOption("bold", playerOptions["oocchat.fontbold"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("bold", playerOptions["oocchat.fontbold"])
                    end 
                },

                {
                    ["name"] = "Szöveg körvonal",
                    ["type"] = 2,
                    ["optionName"] = "oocchat.outline",
                    ["nowValue"] = playerOptions["oocchat.outline"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["oocchat.outline"] = newVal
                        exports['cr_custom-chat']:setOOCOption("outline", playerOptions["oocchat.outline"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("outline", playerOptions["oocchat.outline"])
                    end 
                },

                {
                    ["name"] = "Elhalványulás",
                    ["type"] = 1,
                    ["optionName"] = "oocchat.fadeout",
                    ["nowValue"] = playerOptions["oocchat.fadeout"],
                    ["onChange"] = function(oldVal, newVal)
                        playerOptions["oocchat.fadeout"] = newVal
                        exports['cr_custom-chat']:setOOCOption("fadeout", playerOptions["oocchat.fadeout"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("fadeout", playerOptions["oocchat.fadeout"])
                    end 
                },

                {
                    ["name"] = "Mutatási idő",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.showtime",
                    ["tooltipRound"] = true,
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.showtime"],
                    ["maxValue"] = 60,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.showtime"] = newVal
                        exports['cr_custom-chat']:setOOCOption("showtime", playerOptions["oocchat.showtime"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("showtime", playerOptions["oocchat.showtime"])
                    end 
                },

                {
                    ["name"] = "Elhalványulás idő",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.fadeoutmultiplier",
                    ["tooltipRound"] = true,
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.fadeoutmultiplier"],
                    ["maxValue"] = 60,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.fadeoutmultiplier"] = newVal
                        exports['cr_custom-chat']:setOOCOption("fadeoutmultiplier", playerOptions["oocchat.fadeoutmultiplier"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("fadeoutmultiplier", playerOptions["oocchat.fadeoutmultiplier"])
                    end 
                },

                {
                    ["name"] = "Háttér r",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.backgroundr",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.backgroundr"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.backgroundr"] = newVal
                        exports['cr_custom-chat']:setOOCOption("backgroundr", playerOptions["oocchat.backgroundr"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("backgroundr", playerOptions["oocchat.backgroundr"])
                    end 
                },

                {
                    ["name"] = "Háttér g",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.backgroundg",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.backgroundg"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.backgroundg"] = newVal
                        exports['cr_custom-chat']:setOOCOption("backgroundg", playerOptions["oocchat.backgroundg"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("backgroundg", playerOptions["oocchat.backgroundg"])
                    end 
                },

                {
                    ["name"] = "Háttér b",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.backgroundb",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.backgroundb"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.backgroundb"] = newVal
                        exports['cr_custom-chat']:setOOCOption("backgroundb", playerOptions["oocchat.backgroundb"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("backgroundb", playerOptions["oocchat.backgroundb"])
                    end 
                },

                {
                    ["name"] = "Háttér áttetszőség",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.backgrounda",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.backgrounda"],
                    ["maxValue"] = 255,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.backgrounda"] = newVal
                        exports['cr_custom-chat']:setOOCOption("backgrounda", playerOptions["oocchat.backgrounda"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("backgrounda", playerOptions["oocchat.backgrounda"])
                    end 
                },

                {
                    ["name"] = "Megtartott sorok elhalványulás után",
                    ["type"] = 4,
                    ["optionName"] = "oocchat.cacheremain",
                    ["minValue"] = 0,
                    ["nowValue"] = playerOptions["oocchat.cacheremain"],
                    ["maxValue"] = 100,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        playerOptions["oocchat.cacheremain"] = newVal
                        exports['cr_custom-chat']:setOOCOption("cacheRemain", playerOptions["oocchat.cacheremain"])
                    end,
                    ["onLoad"] = function()
                        exports['cr_custom-chat']:setOOCOption("cacheRemain", playerOptions["oocchat.cacheremain"])
                    end 
                },
            },
        },

        --[[
        {
            ["name"] = "Általános",
            ["icon"] = "",
            ["options"] = {
                {
                    ["name"] = "Beállítás1",
                    ["type"] = 1,
                    ["nowValue"] = playerOptions["test1"],
                    ["onChange"] = function(oldVal, newVal)
                        outputChatBox("oldVal: "..oldVal)
                        outputChatBox("newVal: "..newVal)
                        playerOptions["test1"] = newVal
                    end,
                    ["onLoad"] = function()
                        if playerOptions["test1"] == 1 then 
                            outputChatBox("Hivatalosan is elismerted, hogy buzi vagy!")
                        end 
                    end 
                },

                {
                    ["name"] = "Beállítás2",
                    ["type"] = 2,
                    ["nowValue"] = playerOptions["test2"],
                    ["onChange"] = function(oldVal, newVal)
                        outputChatBox("oldVal: "..oldVal)
                        outputChatBox("newVal: "..newVal)
                        playerOptions["test2"] = newVal
                    end,
                },

                {
                    ["name"] = "Beállítás3",
                    ["type"] = 3,
                    ["nowValue"] = playerOptions["test3"],
                    ["icon"] = textures["user"],
                    ["getDefaultValue"] = function()
                        return playerOptions["test3"] or "Ismeretlen"
                    end, 
                    ["onChange"] = function(oldVal, newVal)
                        outputChatBox("oldVal: "..oldVal)
                        outputChatBox("newVal: "..newVal)
                        playerOptions["test3"] = newVal
                    end,
                },

                {
                    ["name"] = "Beállítás4",
                    ["type"] = 4,
                    ["minValue"] = 0,
                    ["nowValue"] = 0,
                    ["maxValue"] = 100,
                    ["onChange"] = function(minVal, newVal, maxVal)
                        outputChatBox("minVal: "..minVal)
                        outputChatBox("newVal: "..newVal)
                        outputChatBox("maxVal: "..maxVal)
                        playerOptions["test4"] = newVal
                    end,
                },

                {
                    ["name"] = "Beállítás5",
                    ["type"] = 5,
                    ["buttonName"] = "Test5",
                    ["nowValue"] = playerOptions["test5"],
                    ["options"] = {
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                    },
                    ["onChange"] = function(oldVal, newVal)
                        outputChatBox("oldVal: "..oldVal)
                        outputChatBox("newVal: "..newVal)
                        playerOptions["test5"] = newVal
                    end,
                },
            },
        },]]
    }

    for k,v in pairs(options) do
        if options[k] and type(options[k]) == "table" then 
            for k2, v2 in pairs(options[k]) do 
                if options[k][k2] and type(options[k][k2]) == "table" then 
                    for k3, v3 in pairs(options[k][k2]) do 
                        if v3["onLoad"] then 
                            v3["onLoad"]()
                        end 
                    end
                end 
            end 
        end
    end 
end 

addEventHandler("onClientResourceStart", resourceRoot, 
    function()
        if localPlayer:getData("loggedIn") then 
            loadOptions()
        end 
    end 
)

addEventHandler("onClientElementDataChange", localPlayer, 
    function(dName, oValue, nValue)
        if dName == "loggedIn" and nValue then 
            loadOptions()
        end 
    end 
)

function getOption(option)
    return playerOptions[option]
end

function saveOptions()
    if localPlayer:getData("loggedIn") then 
        exports['cr_json']:jsonSAVE("dashboard/options.json", playerOptions, true)
    end 
end 
addEventHandler("onClientResourceStop", resourceRoot, saveOptions)
setTimer(saveOptions, 5 * 60 * 1000, 0)

--[[
    Ram Free
]]
local ramTimer
function toggleRamFree(val)
    if isTimer(ramTimer) then 
        killTimer(ramTimer)
    end 

    if val == 1 then 
        ramTimer = setTimer(
            function()
                engineStreamingFreeUpMemory(math.random(1, 10) * (104857600 * (math.random(1, 10) / 10)))

                outputDebugString('Memória űrítve!')
            end, 5 * 60 * 1000, 0
        )
    end 
end 