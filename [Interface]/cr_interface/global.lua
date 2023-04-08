sx, sy = guiGetScreenSize()

dxDrawMultipler = math.min(1.25, sx / 1280)

function res(val)
    return val * dxDrawMultipler
end

function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

defPositions = {
    ["airride"] = {
		["name"] = "Airride panel",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 211,
		["height"] = 50,
		["x"] = sx-211-20,
		["y"] = sy/2-415/2,
    },
    
    ["radio"] = {
		["name"] = "Rádió panel",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 501,
		["height"] = 10,
		["x"] = sx/2-501/2,
		["y"] = sy/2-122/2,
	},

    ["identity"] = {
		["name"] = "Iratok",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 375,
		["height"] = 175,
		["x"] = sx/2-375/2,
		["y"] = sy/2-175/2,
	},

    ["pizza >> list1"] = {
		["name"] = "Pizzás Lista",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 219,
		["height"] = 310,
		["x"] = sx - 219 - 20,
		["y"] = sy/2-310/2,
	},

    ["pizza >> list2"] = {
		["name"] = "Pizzás Lista",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 200,
		["height"] = 300,
		["x"] = sx - 200 - 20,
		["y"] = sy/2-300/2,
	},

    ["hotdog >> list"] = {
		["name"] = "Hot-Dog Lista",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 200,
		["height"] = 300,
		["x"] = sx - 200 - 20,
		["y"] = sy/2-300/2,
	},
    
    ["phone"] = {
        ["name"] = "Telefon",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 328,
		["height"] = 638,
		["x"] = sx - 328 - 10,
		["y"] = sy / 2 - 638 / 2,
    },

	["tutorial"] = {
		["name"] = "Tutorial panel",
        ["invisible"] = true,
        ["showing"] = true,
		["width"] = 300,
		["height"] = 150,
		["x"] = sx/2-150,
		["y"] = 50,
	},
    
    ["oocchat"] = {
        ["name"] = "OOC Chat",
        ["turnable"] = true,
        ["showing"] = true,
		["sizeable"] = true,
		["width"] = 500,
		["height"] = 140,
        ["minWidth"] = 350,
        ["minHeight"] = 100,
        ["maxWidth"] = 500 * 1.5,
        ["maxHeight"] = 150 * 2,
		["x"] = 20,
		["y"] = 330,
    },
    
    ["chat"] = {
        ["name"] = "IC Chat",
        ["turnable"] = true,
        ["showing"] = false,
		["sizeable"] = true,
		["width"] = 500,
		["height"] = 280,
        ["minWidth"] = 500 * 0.5,
        ["minHeight"] = 290 * 0.5 - 10,
        ["maxWidth"] = 500 * 1.5,
        ["maxHeight"] = 290 * 1.5,
		["x"] = 20,
		["y"] = 16,
    },
    
    ["money"] = {
        ["name"] = "Pénz",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 110,
		["height"] = 18,
		["x"] = sx - 245,
		["y"] = 77 + 4,
        ["sizeable"] = true,
        ["minWidth"] = 65,
        ["minHeight"] = 18,
        ["maxWidth"] = 205,
        ["maxHeight"] = 18,
    },
    
    ["infobox"] = {
        ["name"] = "Infobox",
        ["turnable"] = false,
        ["showing"] = true,
		["width"] = 320,
		["height"] = 45,
		["x"] = 20,
		["y"] = sy - 305 - (47 * 2),
    },
    
    ["kick/ban"] = {
        ["name"] = "Adminbox",
        ["turnable"] = false,
        ["showing"] = true,
		["width"] = 320,
		["height"] = 45,
		["x"] = 20,
		["y"] = sy - 305 - (47 * 4),
    },
    
    ["oxygen"] = {
        ["invisible"] = false,
        ["name"] = "Oxigén",
        ["turnable"] = false,
        ["showing"] = true,
		["width"] = 75,
		["height"] = 70,
		["x"] = 20 + 350 + 5,
		["y"] = sy - 20 - 70,
    },
    
    ["bone"] = {
        ["invisible"] = false,
        ["name"] = "Csont",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 18 * 2 - 5,
		["height"] = 48,
		["x"] = sx - 295,
		["y"] = 25,
    },
    
    ["speedo"] = {
        ["name"] = "Kilóméteróra",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 269,
		["height"] = 190,
		["x"] = sx - 20 - 269,
		["y"] = sy - 20 - 190,
    },

    -- ["fuel"] = {
    --     ["name"] = "Üzemanyag mérő",
    --     ["turnable"] = true,
    --     ["showing"] = true,
	-- 	["width"] = 113,
	-- 	["height"] = 113,
	-- 	["x"] = sx - 246 - 20 - 120,
	-- 	["y"] = sy - 20 - 113,
    -- },

    ["vehname"] = {
        ["name"] = "Járműnév",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 300,
		["height"] = 30,
		["x"] = sx - 20 - 300,
		["y"] = sy - 20 - 220,
    },
    
    ["handbrake"] = {
        ["invisible"] = true,
        ["name"] = "Kézifék",
        ["turnable"] = false,
        ["showing"] = true,
		["width"] = 8,
		["height"] = 115,
		["x"] = sx - 20 - 8,
		["y"] = sy/2 - 115/2,
    },
    
    ["km counter"] = {
        ["invisible"] = true,
        ["name"] = "Kilóméter Számláló",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 150,
		["height"] = 50,
		["x"] = sx - 20 - 220,
		["y"] = sy - 20 - 280 - 30-55,
    },
    
    ["speedo_icon"] = {
        ["invisible"] = true,
        ["name"] = "Sebességmérő Ikon",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 145,
		["height"] = 90,
		["x"] = sx - 20 - 250,
		["y"] = sy - 20 - 275+160,
    },
    
    ["weapon"] = {
        ["name"] = "Fegyver",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 128,
		["height"] = 60,
		["x"] = sx - 128 - 30,
		["y"] = 115,
    },
    
    ["weapon-damage"] = {
        ["name"] = "Fegyver\ninformációk",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 105,
		["height"] = 40,
		["x"] = sx - (105) - 25,
		["y"] = 115 + 30,
    },
    
    ["shopitems"] = {
        ["invisible"] = true,
        ["name"] = "Bolt Item",
        ["turnable"] = false,
        ["showing"] = true,
		["width"] = 80,
		["height"] = 70,
		["x"] = sx/2,
		["y"] = sy/2,
    },
    
    ["groupinfo"] = {
        ["invisible"] = true,
        ["name"] = "Csapat információk",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 250,
		["height"] = 250,
		["x"] = sx * 0.25,
		["y"] = 25,
    },
    
    ["packetloss"] = {
        ["name"] = "Csomagveszteség",
        ["turnable"] = true,
        ["showing"] = false,
		["width"] = 180,
		["height"] = 20,
		["x"] = sx - 120 - 200,
		["y"] = 230,
    },
    
    ["videocard"] = {
        ["name"] = "Videókártya",
        ["turnable"] = true,
        ["showing"] = false,
		["width"] = 300,
		["height"] = 100,
		["x"] = sx - 310,
		["y"] = 250,
    },
    
    ["premiumPoints"] = {
        ["name"] = "PP",
        ["turnable"] = true,
        ["showing"] = false,
        ["width"] = 110,
		["height"] = 18,
		["x"] = sx - 245,
		["y"] = 77 + 4 + 20,
        ["sizeable"] = true,
        ["minWidth"] = 65,
        ["minHeight"] = 18,
        ["maxWidth"] = 205,
        ["maxHeight"] = 18,
    },
    
    ["datum"] = {
        ["name"] = "Dátum",
        ["turnable"] = true,
        ["showing"] = false,
		["width"] = 100,
		["height"] = 20,
		["x"] = sx - 120,
		["y"] = 230,
    },
    
    ["time"] = {
        ["name"] = "Idő",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 84,
		["height"] = 30,
		["x"] = sx - 110,
		["y"] = 77,
    },
    
    ["name"] = {
        ["name"] = "Karakternév",
        ["turnable"] = true,
        ["showing"] = false,
		["width"] = 280,
		["height"] = 30,
		["x"] = sx - 300,
		["y"] = 200,
    },
    
    ["fps"] = {
        ["name"] = "FPS",
        ["turnable"] = true,
        ["showing"] = false,
		["width"] = 60,
		["height"] = 20,
		["x"] = 20 + 350 - 60,
		["y"] = sy - 243,
    },
    
    ["ping"] = {
        ["name"] = "Ping",
        ["turnable"] = true,
        ["showing"] = false,
		["width"] = 70,
		["height"] = 20,
		["x"] = sx - 245,
		["y"] = 150,
    },

    ["hp"] = {
        ["name"] = "Élet",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 40,
		["height"] = 40,
		["x"] = sx - 250,
		["y"] = 25,
    },

    ["armor"] = {
        ["name"] = "Páncél",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 40,
		["height"] = 40,
		["x"] = sx - 205,
		["y"] = 25,
    },

    ["hunger"] = {
        ["name"] = "Éhség",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 40,
		["height"] = 40,
		["x"] = sx - 160,
		["y"] = 25,
    },

    ["thirsty"] = {
        ["name"] = "Szomj",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 40,
		["height"] = 40,
		["x"] = sx - 115,
		["y"] = 25,
    },

    ["stamina"] = {
        ["name"] = "Stamina",
        ["turnable"] = true,
        ["showing"] = true,
		["width"] = 40,
		["height"] = 40,
		["x"] = sx - 70,
		["y"] = 25,
    },	

    -- ["healthbar"] = {
    --     ["name"] = "Életerő",
    --     ["turnable"] = true,
    --     ["showing"] = false,
	-- 	["width"] = 250,
	-- 	["height"] = 12,
	-- 	["x"] = sx - 250 - 15,
	-- 	["y"] = 25,
    -- },

    -- ["armorbar"] = {
    --     ["name"] = "Páncél",
    --     ["turnable"] = true,
    --     ["showing"] = false,
	-- 	["width"] = 250,
	-- 	["height"] = 12,
	-- 	["x"] = sx - 250 - 15,
	-- 	["y"] = 45,
    -- },

    -- ["foodbar"] = {
    --     ["name"] = "Étel",
    --     ["turnable"] = true,
    --     ["showing"] = false,
	-- 	["width"] = 250,
	-- 	["height"] = 12,
	-- 	["x"] = sx - 250 - 15,
	-- 	["y"] = 65,
    -- },

    -- ["drinkbar"] = {
    --     ["name"] = "Ital",
    --     ["turnable"] = true,
    --     ["showing"] = false,
	-- 	["width"] = 250,
	-- 	["height"] = 12,
	-- 	["x"] = sx - 250 - 15,
	-- 	["y"] = 85,
    -- },

    -- ["staminabar"] = {
    --     ["name"] = "Stamina",
    --     ["turnable"] = true,
    --     ["showing"] = false,
	-- 	["width"] = 250,
	-- 	["height"] = 12,
	-- 	["x"] = sx - 250 - 15,
	-- 	["y"] = 105,
    -- },
    
    --["level"] = {
		--["name"] = "Szint",
        --["turnable"] = true,
        --["showing"] = true,
		--["width"] = 252,
		--["height"] = 35,
		--["x"] = sx - 252 - 20,
		--["y"] = 20 + 57,
        --["sizeable"] = true,
        --["minWidth"] = 140,
        --["minHeight"] = 35,
        --["maxWidth"] = 600,
        --["maxHeight"] = 35,
	--},
	-- [4] = { -- Armor
		-- ["name"] = "Armor",
		-- ["showing"] = true,
		-- ["width"] = 200,
		-- ["height"] = 100,
		-- ["x"] = 200,
		-- ["y"] = 300,
	-- },	
    
    --20, sy - 265, 350, 225, {true, true}, true, {{100, 600}, {100, 600}}
	["radar"] = { -- Radar 5
		--["name"] = "Radar",
        ["name"] = "Térkép",
        ["turnable"] = true,
		["showing"] = true,
		["sizeable"] = true,
		["width"] = 350,
		["height"] = 225,
        ["minWidth"] = 100,
        ["minHeight"] = 100,
        ["maxWidth"] = 550,
        ["maxHeight"] = 550,
		["x"] = 20,
		["y"] = sy - 245,
    },
    
    ["gps"] = {
		--["name"] = "Radar",
        ["name"] = "GPS",
        ["turnable"] = true,
		["showing"] = true,
		["sizeable"] = true,
		["width"] = 250,
		["height"] = 60,
        ["minWidth"] = 150,
        ["minHeight"] = 60,
        ["maxWidth"] = 300,
        ["maxHeight"] = 60,
		["x"] = 30,
		["y"] = sy - 235,
	},
    --[[
    ["Chat"] = { -- Radar 5
		--["name"] = "Radar",
		["showing"] = true,
		["sizeable"] = true,
		["width"] = 500,
		["height"] = 300,
        ["minWidth"] = 350,
        ["minHeight"] = 200,
        ["maxWidth"] = 1000,
        ["maxHeight"] = 700,
		["x"] = 20,
		["y"] = 16,
	},]]
    
    --20, sy/2 - (15*5)/2,310, 15*5, {false, true}, true, {{50, 600}, {15*2, 15*20}}
    --[[
    ["ooc"] = { -- Radar 5
		--["name"] = "Radar",
        ["name"] = "OOC Chat",
		["showing"] = true,
        ["turnable"] = true,
		["sizeable"] = true,
		["width"] = 310,
		["height"] = 15*5,
        ["minWidth"] = 310,
        ["minHeight"] = 15*2,
        ["maxWidth"] = 310,
        ["maxHeight"] = 15*20,
		["x"] = 20,
		["y"] = sy/2 - (15*5)/2,
	},]]
    
    ["Inventory"] = {
        ["name"] = "Leltár",
        ["showing"] = true,
        --["turnable"] = true,
        
		["width"] = 465,
		["height"] = 10, --280,
		["x"] = sx - 485,
		["y"] = sy/2 - 280/2,
        ["invisible"] = true,
    },

    ["Taxipanel"] = {
        ["name"] = "Taxipanel",
        ["showing"] = true,
        
		["width"] = 180,
		["height"] = 40,
		["x"] = sx/2 - 180/2,
		["y"] = sy - 20 - 160,
        ["invisible"] = true,
    },
    
    ["Actionbar"] = {
        ["name"] = "Actionbar",
        ["showing"] = true,
        ["turnable"] = true,
		["width"] = (40 * 6 + (6 * 5)) + 5,
		["height"] = 50,
		["x"] = sx/2 - (((40 * 6 + (6 * 5)) + 5)/2),
		["y"] = sy - 50 - 20,
        ["type"] = 1, 
        ["columns"] = 6,
    },

	["Playerbasket"] = {
        ["invisible"] = true,
        ["name"] = "Bevásárlókosár",
        ["showing"] = true,
		["width"] = 240,
		["height"] = 45,
		["x"] = sx/2 - 240/2,
		["y"] = sy - 20 - 200,
    },
	
	["windowPanel"] = {
        ["name"] = "Ablakok kezelése",
        ["showing"] = true,
        
		["width"] = 210,
		["height"] = 40,
		["x"] = 380,
		["y"] = sy - 245,
        ["invisible"] = true,
    },

    ["doorPanel"] = {
        ["name"] = "Ajtók kezelése",
        ["showing"] = true,
        
		["width"] = 210,
		["height"] = 40,
		["x"] = sx/2 - 210/2,
		["y"] = sy/2 - 200/2,
        ["invisible"] = true,
    },

    ["sirenPanel"] = {
        ["name"] = "Sziréna",
        ["showing"] = true,
        --["turnable"] = true,
        
		["width"] = 263,
		["height"] = 40,
		["x"] = sx / 2 - 262 / 2,
		["y"] = sy - 90 - 80,
        ["invisible"] = true,
    },

    ["mdcLoginPanel"] = {
        ["name"] = "MDC Bejelentkezés",
        ["showing"] = true,
        --["turnable"] = true,
        
		["width"] = res(300),
		["height"] = res(188),
		["x"] = sx / 2 - res(300) / 2,
		["y"] = sy / 2 - res(188) / 2,
        ["invisible"] = true,
    },

    ["mdcPanel"] = {
        ["name"] = "MDC Panel",
        ["showing"] = true,
        --["turnable"] = true,
        
		["width"] = res(1036),
		["height"] = res(573),
		["x"] = sx / 2 - res(1036) / 2,
		["y"] = sy / 2 - res(573) / 2,
        ["invisible"] = true,
    },
}

--[[
for k,v in pairs(defPositions) do
    
    if v["width"] <= 42 then
        --outputChatBox(k)
        v["width"] = 42
    end
    
    if v["height"] <= 30 then
        v["height"] = 30
    end
    
    local font = exports['cr_fonts']:getFont("Rubik-Regular", 12)
    if v["width"] <= dxGetTextWidth(k, 1, font) + 10 then
        v["width"] = dxGetTextWidth(k, 1, font) + 10
    end
end]]