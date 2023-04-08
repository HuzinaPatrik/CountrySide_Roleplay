local removableObjects = {
	--{modelID, radius, x,y,z},
	{1676, 1000, 1941.6563, -1767.2891, 14.1406};
	{1676, 1000, 1941.6563, -1771.3438, 14.1406};
	{1676, 1000, 1941.6563, -1774.3125, 14.1406};
	{1676, 1000, 1941.6563, -1778.4531, 14.1406};

	{1412, 1000, 1906.7734, -1797.4219, 13.8125};
	{1412, 1000, 1912.0547, -1797.4219, 13.8125};
	{1412, 1000, 1917.3203, -1797.4219, 13.8125};
	{1412, 1000, 1922.5859, -1797.4219, 13.8125};
	{1412, 1000, 1927.8516, -1797.4219, 13.8125};
	{1412, 1000, 1933.1250, -1797.4219, 13.8125};
	{1412, 1000, 1938.3906, -1797.4219, 13.8125};
	{1412, 1000, 1943.6875, -1797.4219, 13.8125};
	{1412, 1000, 1948.9844, -1797.4219, 13.8125};
	{1412, 1000, 1951.6094, -1800.0625, 13.8125};
	{1412, 1000, 1951.6094, -1805.3281, 13.8125};
	{1412, 1000, 1951.6094, -1810.5938, 13.8125};
	{1412, 1000, 1951.6094, -1815.8594, 13.8125};
	{1412, 1000, 1951.6094, -1821.1250, 13.8125};
	{4003, 1000, 1481.0781, -1747.0313, 33.5234};
	{4172, 1000, 1534.7656, -1756.1797, 15.0000};
	{5779, 1000, 041.3516, -1025.9297, 32.6719};

	{1426, 1000,  116.508, -191.094, 0.648438}, -- HELLSIDETP
	{1426, 1000,  106.109, -195.594, 0.648438}, -- HELLSIDETP
	{12928, 1000,  93.2422, -188.859, 0.484375}, -- HELLSIDETP

	{13485, 10000, 1304.3, 330.156, 23.7031}; -- [COUNTRYSIDE]-ConcessionaryMontgomery + COUNTRYSIDECarParkMontgomery + PizzaHut;

	{13009, 5000, 1331.18, 375.711, 22.976}; -- [COUNTRYSIDE]-HotelMontgomeryBurnedBuild

	{13484, 5000, 738.398, -553.984, 21.9609}; -- [COUNTRYSIDE]-Police

	{13493, 500, 145.79643249512, -33.301879882812, 2.71875}; -- Busz telep

	{13552, 8000, -454.37, -180.25, 19.8825}; -- Mine

	{1684, 1000, 0, 0, 0};

	{1283, 5000, 0, 0, 0},
	{1315, 5000, 0, 0, 0},

    -- Hordók
	{1370, 5000, 0, 0, 0},
	
	--hospital
	{13485, 3000, 1304.3, 330.156, 23.7031},

	-- pride zászlók
	{3853, 5000, 0, 0, 0},
	{3854, 5000, 0, 0, 0},
	{3855, 5000, 0, 0, 0},

	-- Mechanic
	{13437, 3000, 210.938, -245.141, 10.0234},
	{1412, 3000, 215, -224, 2.02344},
	{1412, 3000, 222.805, -238.945, 1.85156},
	{1412, 3000, 222.781, -248.023, 1.85156},
	{1412, 3000, 222.797, -253.297, 1.85156},
	{1412, 3000, 222.797, -258.57, 1.85156},
	{1412, 3000, 222.789, -263.852, 1.85156},
	{1412, 3000, 222.805, -269.125, 1.85156},
	{1412, 3000, 220.125, -271.797, 1.85156},
	{1412, 3000, 214.844, -271.82, 1.85156},
	{1412, 3000, 209.57, -271.836, 1.85156},
	{1412, 3000, 200.742, -271.82, 1.85156},
	{1412, 3000, 195.461, -271.82, 1.85156},
	{1412, 3000, 192.906, -269.125, 1.84375},
	{1412, 3000, 192.812, -263.844, 1.8125},
	{1412, 3000, 192.812, -254.805, 1.82812},
	{1412, 3000, 192.812, -249.531, 1.82812},
	{1412, 3000,192.812, -244.25, 1.82812 },
	{1412, 3000, 192.914, -238.977, 1.82031},
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k,v in pairs(removableObjects) do
            local id, radius, x,y,z = unpack(v)
            removeWorldModel(id, radius, x,y,z)
        end
    end
)