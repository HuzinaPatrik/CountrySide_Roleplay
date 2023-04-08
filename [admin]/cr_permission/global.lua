permissionDetails = {
    --["commandNév"] = {type ("cmd"/"permission"), minAdminlevel, specialAdminLevels, requestAdminDuty, minimumNoDutyLevel}
    ["forcepm"] = {"permission", 8, {}, false},
    ["fly"] = {"cmd", 3, {}, true, 7},
    ["anames"] = {"cmd", 3, {}, true, 7},
    ["showWaterXYZ"] = {"cmd", 10, {}, true, 10},
    ["setadminlevel"] = {"cmd", 9, {}, false},
    ["setguardlevel"] = {"cmd", 11, {}, false},
    ["vehBoot"] = {"permission", 9, {}, false},
    ["safeBoot"] = {"permission", 9, {}, false},
    ["forceSafeOpen"] = {"permission", 8, {}, false},
    ["sethelperlevel"] = {"cmd", 5, {}, false},
    ["stats"] = {"cmd", 5, {}, false},

    ["stat"] = {"cmd", 8, {}, false}, -- dev mcd
    ["performancelog"] = {"cmd", 11, {}, false}, -- dev mcd
    ["performance"] = {"cmd", 11, {}, false}, -- dev mcd

    ["stopserver"] = {"cmd", 11, {}, true, 11},

    ["asegit"] = {"cmd", 3, {}, false},
    ["agyogyit"] = {"cmd", 3, {}, false},
    ["aduty"] = {"cmd", 3, {}, false},
    ["asduty"] = {"cmd", 1, {}, false},
    -- ["resetserial"] = {"cmd", 5, {}, false},
    ["forceaduty"] = {"permission", 8, {}, false},
    ["forceasduty"] = {"permission", 8, {}, false},
    ["togalog"] = {"cmd", 3, {}, false},
    ["getpos"] = {"cmd", 8, {}, false},
    ["forceVehicleOpen"] = {"permission", 3, {}, true, 9},
    ["forceVehicleStart"] = {"permission", 4, {}, true, 9},
    ["setvehint"] = {"cmd", 6, {}, false},
    ["setvehdim"] = {"cmd", 6, {}, false},
    ["setvehcolor"] = {"cmd", 8, {}, false},
    ["forcePark"] = {"permission", 8, {}, false},
    ["gotocar"] = {"cmd", 3, {}, false},
    ["getcar"] = {"cmd", 3, {}, false},
    ["nearbyvehicle"] = {"cmd", 3, {}, false},
    ["deljobvehicle"] = {"cmd", 6, {}, false},
    ["fixveh"] = {"cmd", 5, {}, false},
    ["isPlayerKnow"] = {"permission", 3, {}, false},
    ["unflipVehicle"] = {"cmd", 3, {}, false},
    ["unflip"] = {"cmd", 3, {}, false},
    ["setcarhp"] = {"cmd", 5, {}, false},
    ["rtc"] = {"cmd", 3, {}, false},
    ["fuelveh"] = {"cmd", 4, {}, false},

    --[[
        Buszos
    ]]
    ["createbusstop"] = {"cmd", 8, {}, false},
    ["deletebusstop"] = {"cmd", 8, {}, false},
    ["nearbybusstops"] = {"cmd", 8, {}, false},

    ["ah"] = {"cmd", 1, {}, false},

    ["deleteplacedo"] = {"cmd", 3, {}, false},
    ["getnearbyplacedo"] = {"cmd", 3, {}, false},

    ["setfuelveh"] = {"cmd", 4, {}, false},
    ["resetvehoil"] = {"cmd", 5, {}, false},
    ["setvehoil"] = {"cmd", 5, {}, false},
    ["resetfix"] = {"cmd", 9, {}, false},
    ["resetrtc"] = {"cmd", 9, {}, false},
    ["resetfuel"] = {"cmd", 9, {}, false},
    ["resetatime"] = {"cmd", 9, {}, false},
    ["resetban"] = {"cmd", 9, {}, false},
    ["resetkick"] = {"cmd", 9, {}, false},
    ["resetjail"] = {"cmd", 9, {}, false},
    ["setvehicleplatetext"] = {"cmd", 8, {}, false},
    ["resetadminstats"] = {"cmd", 9, {}, false},
    ["achangelock"] = {"cmd", 8, {}, false},
    ["makeveh"] = {"cmd", 8, {}, false},
    ["delthisveh"] = {"cmd", 8, {}, false},
    ["delveh"] = {"cmd", 8, {}, false},
    ["deltempveh"] = {"cmd", 4, {}, false}, -- 2 es admin
    ["setvehfaction"] = {"cmd", 8, {}, false},
    ["protect"] = {"cmd", 8, {}, false},
    ["unprotect"] = {"cmd", 8, {}, false},
    ["blowvehicle"] = {"cmd", 9, {}, false},
    ["startvehengine"] = {"permission", 8, {}, false},
    ["stopvehengine"] = {"permission", 8, {}, false},
    ["getadminstats"] = {"cmd", 8, {}, false},
    ["getvehiclestats"] = {"cmd", 3, {}, false},
    ["setadminnick"] = {"cmd", 8, {}, false},
    ["debug"] = {"cmd", 9, {}, false},
    ["addspeedcam"] = {"cmd", 9, {}, false},
    ["getnearbyspeedcams"] = {"cmd", 9, {}, false},
    ["delspeedcam"] = {"cmd", 9, {}, false},
    ["glue"] = {"cmd", 3, {}, true, 8},
    ["getkilllog"] = {"cmd", 3, {}, true, 8},
    ["getdeathlog"] = {"cmd", 3, {}, true, 8},
    ["loadvehicle"] = {"permission", 8, {}, true, 9},
    ["savevehicle"] = {"cmd", 8, {}, true, 9},
    ["unloadvehicle"] = {"permission", 8, {}, true, 9},

    ["setserverslot"] = {"cmd", 9, {}, false},

    ["auncuff"] = {"cmd", 3, {}, true, 3},

    ["ajail"] = {"cmd", 3, {[-1] = true, [-2] = true}, false},
    ["offjail"] = {"cmd", 4, {[-1] = true, [-2] = true}, false},
    ["forceajail"] = {"permission", 8, {}, false},

    -- Fuel
    -- ["createfuelpump"] = {"cmd", 8, {}, false},
    -- ["deletefuelpump"] = {"cmd", 8, {}, false},
    -- ["nearbyfuelpump"] = {"cmd", 8, {}, false},
    --

    ["showinventory"] = {"cmd", 3, {}, false},
    ["dash"] = {"cmd", 3, {}, false},
    ["itemlist"] = {"cmd", 8, {}, false},
    ["deltrash"] = {"cmd", 8, {}, false},
    ["addtrash"] = {"cmd", 8, {}, false},
    ["nearbytrash"] = {"cmd", 8, {}, false},
    ["nearbysafe"] = {"cmd", 8, {}, false},
    ["addsafe"] = {"cmd", 8, {}, false},
    ["delsafe"] = {"cmd", 8, {}, false},
    ["getsafe"] = {"cmd", 8, {}, false},
    ["convertmap"] = {"cmd", 9, {}, false},

    ["pm"] = {"cmd", 0, {[1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = true, [8] = true, [9] = true, [10] = true}, false},
    ["vá"] = {"cmd", 1, {}, true, 8},
    ["asay"] = {"cmd", 3, {}, false},
    ["togvá"] = {"cmd", 3, {}, false},
    ["asChat"] = {"permission", 1, {}, false},
    ["as"] = {"cmd", 1, {}, false},
    ["adminChat"] = {"cmd", 3, {}, false},
    ["staffChat"] = {"cmd", 8, {}, false},
    ["vhSpawn"] = {"cmd", 3, {}, false},
    ['mdspawn'] = {"cmd", 3, {}, false},
    ['bberryspawn'] = {"cmd", 3, {}, false},
    ['bbspawn'] = {"cmd", 3, {}, false},
    ['pdspawn'] = {"cmd", 3, {}, false},
    ["recon"] = {"cmd", 3, {}, true, 8},
    ["goto"] = {"cmd", 3, {}, false},
    ["gotopos"] = {"cmd", 6, {}, false},
    ["mark"] = {"cmd", 3, {}, false},
    ["gotomark"] = {"cmd", 3, {}, false},
    ["deletemark"] = {"cmd", 3, {}, false},
    ["delmark"] = {"cmd", 3, {}, false},
    ["getmarkedlocations"] = {"cmd", 3, {}, false},
    ["gethere"] = {"cmd", 3, {}, false},
    ["sethp"] = {"cmd", 3, {}, true, 7},
    ["setarmor"] = {"cmd", 7, {}, true, 7},
    ["vanish"] = {"cmd", 3, {}, true, 7},
    ["sethunger"] = {"cmd", 6, {}, false},
    ["setwater"] = {"cmd", 6, {}, false},
    ["kick"] = {"cmd", 3, {[-2] = true}, false},
    ["setskin"] = {"cmd", 3, {}, false},
    ["freeze"] = {"cmd", 3, {}, false},
    ["unfreeze"] = {"cmd", 3, {}, false},

    ["sgoto"] = {"cmd", 3, {}, false}, -- ADMIN 2 --
    ["setname"] = {"cmd", 7, {}, false},
    ["accinfo"] = {"cmd", 9, {}, false},

    ["setmoney"] = {"cmd", 9, {}, true, 10},
    ["setbankmoney"] = {"cmd", 9, {}, true, 10},
    ["checkbankmoney"] = {"cmd", 8, {}, false},
    ["setpp"] = {"cmd", 12, {}, true, 10},

    ["createinterior"] = {"cmd", 8, {}, false},
    ["creategarage"] = {"cmd", 8, {}, false},
    ["deleteinterior"] = {"cmd", 8, {}, false},
    ["nearbyinteriors"] = {"cmd", 8, {}, false},
    ["setinteriorname"] = {"cmd", 8, {}, false},
    ["setinteriorcost"] = {"cmd", 8, {}, false},
    ["setinteriorowner"] = {"cmd", 8, {}, false},
    ["setinteriorid"] = {"cmd", 8, {}, false},
    ["setinteriorenter"] = {"cmd", 8, {}, false},
    ["setinteriorexit"] = {"cmd", 8, {}, false},
    ["setinteriorfaction"] = {"cmd", 8, {}, false},
    ["setfactioninterior"] = {"cmd", 8, {}, false},
    ["gotointerior"] = {"cmd", 8, {}, false},
    ["forceInteriorLock"] = {"permission", 8, {}, false},
    ["gameintlist"] = {"cmd", 8, {}, false},

    ["forceRelease"] = {"permission", 5, {}, false},

    ["createelevator"] = {"cmd", 8, {}, false},
    ["deleteelevator"] = {"cmd", 8, {}, false},
    ["nearbyelevators"] = {"cmd", 8, {}, false},
    ["setelevatorenter"] = {"cmd", 8, {}, false},
    ["setelevatorexit"] = {"cmd", 8, {}, false},
    ["setelevatorname"] = {"cmd", 8, {}, false},
    ["gotoelevator"] = {"cmd", 8, {}, false},
    ["setelevatorinvisible"] = {"cmd", 8, {}, false},
    ["setelevatorprotection"] = {"cmd", 8, {}, false},

    ["creategate"] = {"cmd", 8, {}, false},
    ["deletegate"] = {"cmd", 8, {}, false},
    ["nearbygates"] = {"cmd", 8, {}, false},
    ["forceGate"] = {"permission", 8, {}, false},

    ["createfuel"] = {"cmd", 9, {}, false},
    ["deletefuel"] = {"cmd", 9, {}, false},
    ["nearbyfuels"] = {"cmd", 9, {}, false},
    ["createfuelped"] = {"cmd", 9, {}, false},
    ["deletefuelped"] = {"cmd", 9, {}, false},
    ["nearbyfuelpeds"] = {"cmd", 9, {}, false},
    ["createfuelarea"] = {"cmd", 9, {}, false},
    ["deletefuelarea"] = {"cmd", 9, {}, false},
    ["nearbyfuelareas"] = {"cmd", 9, {}, false},

    ["showshopnpctypes"] = {"cmd", 7, {}, false},
    ["setshopnpcstatic"] = {"cmd", 7, {}, false},
    ["createshopnpc"] = {"cmd", 7, {}, false},
    ["getnearbyshopnpc"] = {"cmd", 7, {}, false},
    ["deleteshopnpc"] = {"cmd", 7, {}, false},
    ["getshopnpc"] = {"cmd", 7, {}, false},
    ["renameshopnpc"] = {"cmd", 7, {}, false},
    ["additemtoshopnpc"] = {"cmd", 7, {}, false},
    ["removeitemshopnpc"] = {"cmd", 7, {}, false},
    ["getshopnpcitems"] = {"cmd", 7, {}, false},
	["createshop"] = {"cmd", 9, {}, false},
	["addshopcashier"] = {"cmd", 9, {}, false},
	["addshopbasket"] = {"cmd", 9, {}, false},
	["shopeditor"] = {"cmd", 9, {}, false},
	["deleteshop"] = {"cmd", 9, {}, false},
	["additemtoshelf"] = {"cmd", 9, {}, false},
	["removeitemfromshelf"] = {"cmd", 9, {}, false},

    ["createlicenseped"] = {"cmd", 9, {}, false},
    ["deletelicenseped"] = {"cmd", 9, {}, false},

    ["createticketped"] = {"cmd", 9, {}, false},
    ["deleteticketped"] = {"cmd", 9, {}, false},
    ["nearbyticketpeds"] = {"cmd", 9, {}, false},

    -- ["af"] = {"cmd", 8, {}, false}, -- FŐ ADMIN --
    ["dev"] = {"cmd", 11, {}, false}, -- FEJLESZTŐ --

    ["giveitem"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["getchardetails"] = {"cmd", 8, {}, false}, -- FŐ ADMIN --
    ["setchardetail"] = {"cmd", 8, {}, false}, -- FŐ ADMIN --

    ["createfaction"] = {"cmd", 9, {}, false}, -- SUPER ADMIN --
    ["deletefaction"] = {"cmd", 9, {}, false}, -- SUPER ADMIN --
    ["setfactionname"] = {"cmd", 9, {}, false}, -- SUPER ADMIN --
    ["showfactions"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["showfactiontypes"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["setplayerfaction"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["setplayerfactionleader"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["removeplayerfaction"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["removeplayerfactionleader"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    ["createdutylocation"] = {"cmd", 8, {}, false},
    ["getnearbydutylocations"] = {"cmd", 8, {}, false},
    ["deletedutylocation"] = {"cmd", 8, {}, false},
    ["createfactionduty"] = {"cmd", 8, {}, false},
    ["getfactiondutys"] = {"cmd", 8, {}, false},
    ["deletefactionduty"] = {"cmd", 8, {}, false},
    ["adddutyitem"] = {"cmd", 8, {}, false},
    ["getdutyitems"] = {"cmd", 8, {}, false},
    ["deletedutyitem"] = {"cmd", 8, {}, false},

    ["addnote"] = {"cmd", 11, {}, false}, -- FEJLESZTŐ --

    ["ban"] = {"cmd", 5, {}, false},
    ["oban"] = {"cmd", 5, {}, false},
    ["unban"] = {"cmd", 6, {}, false},
    ["changeaccname"] = {"cmd", 9, {}, false},
    ["changeaccpw"] = {"cmd", 9, {}, false},
    ["changeaccemail"] = {"cmd", 9, {}, false},
    ["changeaccserial"] = {"cmd", 9, {}, false},

    ["delplacedo"] = {"cmd", 3, {}, false},

	["addrock"] = {"cmd", 11, {}, false},
	["delrock"] = {"cmd", 11, {}, false},
	["nearbyrocks"] = {"cmd", 11, {}, false},

	["addtree"] = {"cmd", 11, {}, false},
	["deltree"] = {"cmd", 11, {}, false},
	["nearbytrees"] = {"cmd", 11, {}, false},

	["addwaste"] = {"cmd", 11, {}, false},
	["delwaste"] = {"cmd", 11, {}, false},
	["nearbywaste"] = {"cmd", 11, {}, false},

    -- ["createtable"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    -- ["edittable"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --
    -- ["stopedittable"] = {"cmd", 8, {}, false}, -- SUPER ADMIN --


    ["addatm"] = {"cmd", 9, {}, false},
	["delatm"] = {"cmd", 9, {}, false},
	["nearbyatm"] = {"cmd", 9, {}, false},

	["nearbyjobvehicle"] = {"cmd", 3, {}, false},

    -- ["createtables"] = {"cmd", 3, {[3] = true}, false}, -- SUPER ADMIN --
    -- ["edittables"] = {"cmd", 3, {[3] = true}, false}, -- SUPER ADMIN --
    -- ["stopedittables"] = {"cmd", 3, {[3] = true}, false}, -- SUPER ADMIN --

	["addjobnpc"] = {"cmd", 11, {}, false},
	["deljobnpc"] = {"cmd", 11, {}, false},
    ["nearbyjobnpcs"] = {"cmd", 11, {}, false},

    ["createjunkpile"] = {"cmd", 9, {}, false},
    ["deletejunkpile"] = {"cmd", 9, {}, false},
    ["nearbyjunkpiles"] = {"cmd", 9, {}, false},

    ["createjunkped"] = {"cmd", 9, {}, false},
    ["deletejunkped"] = {"cmd", 9, {}, false},
    ["nearbyjunkpeds"] = {"cmd", 9, {}, false},

    ["creategrapevine"] = {"cmd", 9, {}, false},
    ["editgrapevine"] = {"cmd", 9, {}, false},
    ["deletegrapevine"] = {"cmd", 9, {}, false},

    ["createappletree"] = {"cmd", 9, {}, false},
    ["editappletree"] = {"cmd", 9, {}, false},
    ["deleteappletree"] = {"cmd", 9, {}, false},

    ["createhiker"] = {"cmd", 8, {}, false},
    ["deletehiker"] = {"cmd", 8, {}, false},
    ["nearbyhikers"] = {"cmd", 8, {}, false},

    ["createterminal"] = {"cmd", 8, {}, false},
    ["deleteterminal"] = {"cmd", 8, {}, false},
    ["delterminal"] = {"cmd", 8, {}, false},
    ["nearbyterminals"] = {"cmd", 8, {}, false},

    ["createcamera"] = {"cmd", 8, {}, false},
    ["deletecamera"] = {"cmd", 8, {}, false},
    ["nearbycameras"] = {"cmd", 8, {}, false},

    ["createcoindealer"] = {"cmd", 9, {}, false},
    ["deletecoindealer"] = {"cmd", 9, {}, false},
    ["delcoindealer"] = {"cmd", 9, {}, false},

    ["createblackjacktable"] = {"cmd", 9, {}, false},
    ["deleteblackjacktable"] = {"cmd", 9, {}, false},
    ["delblackjacktable"] = {"cmd", 9, {}, false},
    ["nearbyblackjacktables"] = {"cmd", 9, {}, false},

    ["startcinema"] = {"cmd", 10, {}, false},
    ["advertisecinema"] = {"cmd", 10, {}, false},
}

local serverside = false
addEventHandler("onResourceStart", resourceRoot,
    function()
        serverSide = true
        --On clientSide event onResourceStart doesnt work.
    end
)

function hasPermission(element, permission)
    local data = permissionDetails[permission]
    if not isElement(element) then return false end
    if not getElementData(element, "loggedIn") then
        return false
    end
    if data then
        local adminlevel = getElementData(element, "admin >> level") or 0
        if adminlevel >= data[2] then
            if data[4] then
                local adminduty = exports['cr_admin']:getAdminDuty(element) --getElementData(element, "admin >> duty")
                if adminlevel >= data[5] then
                    adminduty = true
                end

                if adminduty or exports['cr_core']:getPlayerDeveloper(element) then
                    return true
                end
            else
                return true
            end
        elseif data[3][adminlevel] then
            if data[4] then
                local adminduty = exports['cr_admin']:getAdminDuty(element) --getElementData(element, "admin >> duty")
                if adminduty or exports['cr_core']:getPlayerDeveloper(element) then
                    return true
                end
            else
                return true
            end
        elseif exports['cr_core']:getPlayerDeveloper(element) then
            return true
        end
    end
    return false
end

function isPermissionCommand(permission)
    return permissionDetails[permission][1]
end 

function getRequiredLevel(permission)
    return permissionDetails[permission][2]
end

function addPermission(permission, data)
    if permission and data then 
        if not permissionDetails[permission] then 
            permissionDetails[permission] = data

            return true
        end 
    end 

    return false
end
--Pld: exports['cr_permission']:addPermission("teszt", {"cmd", 8, {}, false})

function removePermission(permission)
    if permission then 
        if permissionDetails[permission] then 
            permissionDetails[permission] = nil 
            collectgarbage("collect")

            return true
        end 
    end 

    return false
end
--Pld: exports['cr_permission']:removePermission("teszt")