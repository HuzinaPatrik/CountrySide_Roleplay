function getNearbyElevators(cmd)
    if exports["cr_permission"]:hasPermission(localPlayer, cmd) then 
        local count = 0
        local dimension = localPlayer:getDimension()
        for key, value in pairs(getElementsByType("marker", root, true)) do 
            local data = {}
            
            if value ~= value:getData("parent") then 
                data = value:getData("marker >> data")
            else
                data = value:getData("parent"):getData("marker >> data")
            end

            local distance = getDistanceBetweenPoints3D(localPlayer.position, value.position)
            if distance <= 15 then 
                if value:getDimension() == dimension then 
                    if data and data["elevator"] then 
                        outputChatBox(exports["cr_core"]:getServerSyntax(false, "yellow").."ID: "..exports["cr_core"]:getServerColor("yellow", true)..data["id"].."#ffffff | Név: "..exports["cr_core"]:getServerColor("yellow", true)..data["name"], 255, 0, 0, true)
                        count = count + 1
                    end
                end
            end
        end
        if count == 0 then 
            return outputChatBox(exports["cr_core"]:getServerSyntax(false, "red").."Nincs a közeledben lift.", 255, 0, 0, true)
        end
    end
end
addCommandHandler("nearbyelevators", getNearbyElevators, false, false)