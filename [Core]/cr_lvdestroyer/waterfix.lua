--[[local waters = {
	--[1] = {2800, -3000, 0, 3000, -3000, 0, 2800, 3000, 0, 3000, 3000, 0},
	--[2] = {-3000, 2900, 0, 2900, 2900, 0, -3000, 3000, 0, 2900, 3000, 0},
	--[3] = {-3000, -3000, 0, -1300, -3000, 0, -3000, 2900, 0, -1300, 2900, 0},
	--[4] = {-1300, 345, 0, 0, 345, 0, -1300, 2030, 0, 0, 2030, 0},
	--[5] = {0, 345, 0, 2800, 345, 0, 0, 700, 0, 2800, 700, 0},
	--[6] = {1353, -1826, 9, 1375, -1826, 9, 1357, -1589, 9, 1373, -1589, 9},--1415.10071 -1250.59937
	--[7] = {1521, -1916, 9, 2629, -1916, 9, 1748, -1725, 9, 2629, -1725, 9},
    --[7] = {1521, -1768, 9, 
	--[8] = {2305, -2306, 9, 2532, -2306, 9, 1970, -1920, 9, 2532, -1920, 9},
	--[9] = {1356, -1589, 9, 1420, -1589, 9, 1382, -1247, 9, 1417, -1247, 9},
	--[10] = {1373, -1746, 9, 1520, -1746, 9, 1374, -1699, 9, 1519, -1699, 9},
	--[11] = {-600, 2030, 40, -550, 2030, 40, -600, 2060, 40, -550, 2060, 40},
	--[12] = {2050, 1870, 9.6, 2107, 1870, 9.6, 2050, 1962, 9.6, 2107, 1962, 9.6},
	--[13] = {1850, 1470, 9, 2032, 1470, 9, 1850, 1570, 9, 2032, 1570, 9},
	--[14] = {1890, 1570, 9, 2032, 1570, 9, 1890, 1700, 9, 2032, 1700, 9},
	--[15] = {2105, 1220, 9, 2200, 1220, 9, 2105, 1333, 9, 2200, 1333, 9},
	--[16] = {2105, 1100, 8.5, 2200, 1100, 8.5, 2105, 1175, 8.5, 2200, 1175, 8.5},
	--[17] = {2120, 1050, 8.5, 2150, 1050, 8.5, 2120, 1100, 8.5, 2150, 1100, 8.5},
	--[18] = {542, 2800, 0, 793, 2800, 0, 542, 2900, 0, 793, 2900, 0},
	--[19] = {1750, 2770, 9, 1800, 2770, 9, 1750, 2850, 9, 1800, 2850, 9},
	--[20] = {2510, 1550, 9.25, 2550, 1550, 9.25, 2510, 1600, 9.25, 2550, 1600, 9.25},
    --[21] = {2637, 1864, 19, 2655, 1864, 19, 2637, 1922, 19, 2655, 1922, 19},
    --2923.54883 605.26324 1.37731
    
    
    -->> LV-S Vízek:
    [1] = {-1301, 605, 0, 2923, 605, 0, -1301, 2889, 0, 2923, 2889, 0},
    [2] = {-767, 671, 0, -740, 671, 0, -767, 700, 0, -740, 700, 0},
    [3] = {1824, 575, 0, 2560, 575, 0, 1824, 604, 0, 2560, 604, 0},
    [4] = {-2832, 2191, 0, -1302, 2191, 0, -2832, 2888, 0, -1302, 2888, 0},
    [5] = {-1923, 1695, 0, -1301, 1695, 0, -1923, 2190, 0, -1301, 2190, 0},
    [6] = {-431, 526, 0, 120, 526, 0, -431, 604, 0, 120, 604, 0},
}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for i,v in pairs(waters) do
			local water = createWater(waters[i][1], waters[i][2], waters[i][3], waters[i][4], waters[i][5], waters[i][6], waters[i][7], waters[i][8], waters[i][9], waters[i][10], waters[i][11], waters[i][12])
		end
        --setWaterColor(255,204,0)
	end
)

local devState = false

addCommandHandler("showWaterXYZ", 
    function(cmd)
        if exports['cr_permission']:hasPermission(localPlayer, cmd) then
            devState = not devState
            if devState then
                addEventHandler("onClientRender", root, drawnPoints, true, "low-5")
            else
                removeEventHandler("onClientRender", root, drawnPoints)
            end
        end    
    end
)

function drawnPoints()
    for k,v in pairs(waters) do
        local x, y, z = v[1], v[2], v[3]
        local sx, sy = getScreenFromWorldPosition(x,y,z)
        if sx and sy then
            dxDrawRectangle(sx - 25/2, sy - 25/2, 25, 25, tocolor(0,0,0, 180))
            dxDrawText("1 -- " .. k, sx, sy, sx, sy, tocolor(255,255,255,255), 1, "clear", "center", "center")
        end
        
        local x, y, z = v[4], v[5], v[6]
        local sx, sy = getScreenFromWorldPosition(x,y,z)
        if sx and sy then
            dxDrawRectangle(sx - 25/2, sy - 25/2, 25, 25, tocolor(0,0,0, 180))
            dxDrawText("2 -- " .. k, sx, sy, sx, sy, tocolor(255,255,255,255), 1, "clear", "center", "center")
        end
        
        local x, y, z = v[7], v[8], v[9]
        local sx, sy = getScreenFromWorldPosition(x,y,z)
        if sx and sy then
            dxDrawRectangle(sx - 25/2, sy - 25/2, 25, 25, tocolor(0,0,0, 180))
            dxDrawText("3 -- " .. k, sx, sy, sx, sy, tocolor(255,255,255,255), 1, "clear", "center", "center")
        end
        
        local x, y, z = v[10], v[11], v[12]
        local sx, sy = getScreenFromWorldPosition(x,y,z)
        if sx and sy then
            dxDrawRectangle(sx - 25/2, sy - 25/2, 25, 25, tocolor(0,0,0, 180))
            dxDrawText("4 -- " .. k, sx, sy, sx, sy, tocolor(255,255,255,255), 1, "clear", "center", "center")
        end
    end
end
--]]