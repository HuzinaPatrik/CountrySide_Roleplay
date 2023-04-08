local sounds = {}
local soundPath = "assets/sounds/warning.mp3"

addEventHandler("onClientElementDataChange", root, 
    function(dName, oValue, nValue)
        if dName == "veh >> stealWarning" then 
            if isElementStreamedIn(source) then 
                if nValue then 
                    if isElement(sounds[source]) then 
                        sounds[source]:destroy()
                        sounds[source] = nil 
                    end 

                    local sound = playSound3D(soundPath, source.position, true)
                    sound.dimension = source.dimension 
                    sound.interior = source.interior 
                    sound:attach(source)

                    sounds[source] = sound
                else
                    if isElement(sounds[source]) then 
                        sounds[source]:destroy()
                        sounds[source] = nil 
                    end  
                end 
            end 
        end 
    end 
)

addEventHandler("onClientElementStreamIn", root, 
    function()
        if source and isElement(source) and source.type == "vehicle" then 
            if source:getData("veh >> stealWarning") then 
                if isElement(sounds[source]) then 
                    sounds[source]:destroy()
                    sounds[source] = nil 
                end 

                local sound = playSound3D(soundPath, source.position, true)
                sound.dimension = source.dimension 
                sound.interior = source.interior 
                sound:attach(source)

                sounds[source] = sound
            end 
        end 
    end 
)

addEventHandler("onClientElementStreamOut", root, 
    function()
        if source and isElement(source) and source.type == "vehicle" then 
            if isElement(sounds[source]) then 
                sounds[source]:destroy()
                sounds[source] = nil 
            end 
        end 
    end 
)