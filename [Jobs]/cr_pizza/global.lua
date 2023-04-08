jobID = 7

markerPositions = {
    --{x,y,z,dim,int},
    {1364.35, 263.8, 18.4, 0, 0},
	{1353.8908691406, 239.74940490723, 18.4, 0, 0},
}

vehiclePositions = {
    --{x,y,z,dim,int,rot}
    {1355.1589355469, 242.86282348633, 19.5625, 0, 0, 70},
	{1356.0552978516, 244.80999755859, 19.5625, 0, 0, 70},
	{1356.8228759766, 246.81791687012, 19.5625, 0, 0, 70},
	{1361.6099853516, 257.36721801758, 19.5625, 0, 0, 70},
	{1356.0552978516, 244.80999755859, 19.5625, 0, 0, 70},
	{1361.94921875, 258.51284790039, 19.5625, 0, 0, 70},
	{1362.5184326172, 259.69757080078, 19.5625, 0, 0, 70},
	
}

pizzaPositions = {
    --{x,y,z,dim,int,rot}
    {1377.9969482422, 246.67236328125, 19.55, 0, 0, 115},
	{1378.4822998047, 248.01194763184, 19.55, 0, 0, 20},
}

pedSkins = {
    {
        107, 
        7, 
        1, 
    }, -- Férfi

    {
        2,
    }, -- Nő
}

pedPositions = {
    --{x,y,z,rot}
    --[Palomino]
	{2203.1118164062, -87.798919677734, 28.153547286987, 268.14416503906},
	{2246.79296875, -1.6663173437119, 28.153551101685, 180.05624389648},
	{2292.3686523438, -124.9567565918, 28.153549194336, 356.58944702148},
	{2385.0615234375, -54.960601806641, 28.153551101685, 0.9046448469162},
	{2414.8474121094, 61.759742736816, 28.44164276123, 177.73530578613},
	{2482.0361328125, 126.99303436279, 27.675647735596, 183.32986450195},
	{2551.2172851562, 58.374069213867, 27.675645828247, 91.224555969238},
	{2511.1049804688, 11.757365226746, 28.441644668579, 182.28833007812},
	{2237.5012207031, 168.33723449707, 28.153549194336, 179.2233581543},
	{1708.2648925781, 99.436233520508, 31.545289993286, 307.78405761719},

	--[Montgomery]
	{1420.3818359375, 389.21124267578, 19.263208389282, 338.73388671875},
	{1322.6882324219, 390.8694152832, 19.5625, 335.60916137695},
	{1462.427734375, 342.86822509766, 18.953125, 206.60195922852},
	{1232.4567871094, 361.21923828125, 19.5546875, 159.3441619873},

	--[Blueberry]
	{312.72964477539, -93.910942077637, 3.5353934764862, 271.89450073242},
	{298.56420898438, -246.58242797852, 5.1875, 3.166885137558},
	{267.10330200195, -246.57466125488, 1.8984375, 3.3754251003265},
	{271.29699707031, -231.50155639648, 5.1875, 187.94358825684},
	{235.83862304688, -309.4326171875, 1.578125, 2.6314532756805},
	{253.24195861816, -290.58499145508, 1.578125, 92.564712524414},
	{207.07911682129, -113.59689331055, 4.8964710235596, 89.648551940918},
	{188.09419250488, -96.976943969727, 4.8964710235596, 179.52201843262},
	{190.85108947754, -120.23275756836, 1.5488394498825, 357.09677124023},
	{158.63444519043, -113.39804840088, 1.5567123889923, 268.8600769043},

	--[Dilimore]
	{715.06463623047, -472.56137084961, 16.343704223633, 268.0563659668},
	{712.06707763672, -497.60977172852, 16.3359375, 276.15115356445},
	{769.43127441406, -503.48196411133, 18.012926101685, 180.56369018555},
	{744.32452392578, -556.77819824219, 18.012926101685, 359.32876586914},

	--[Other]
	{749.39782714844, 257.57940673828, 27.0859375, 19.118436813354},
	{718.88024902344, 301.72299194336, 20.234375, 101.40328216553},
	{786.34503173828, 376.31076049805, 21.198089599609, 337.84188842773},
	{804.50457763672, 358.40341186523, 19.762119293213, 356.88790893555},
}

typeNames = {
    ['sauce'] = 'Szósz: ',
    ['cheese'] = 'Sajt: ',
    ['topping'] = 'Feltét: ',
    ['drink'] = 'Ital: ',
}

orderTabs = {
    --[[
        Szószok
    ]]
    {
        ['name'] = 'Szószok',

        {
            ['name'] = 'Paradicsom',
            ['imageData'] = {86, 67, 'assets/images/sauce/1/icon.png'},
            ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/sauce/1/overlay.png'},
        },
		
		{
            ['name'] = 'Tejföl',
            ['imageData'] = {86, 67, 'assets/images/sauce/2/icon.png'},
            ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/sauce/2/overlay.png'},
        },
    },

    --[[
        Feltétek
    ]]
    {
        ['altTabs'] = {
            'Zöldségek/Gyümölcsök',
            'Húsok',
        },

        ['name'] = 'Feltétek',

        { -->>'Zöldségek/Gyümölcsök',
            {
                ['name'] = 'Paprika',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/1/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/1/overlay.png'},
            },

            {
                ['name'] = 'Bazsalikom',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/2/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/2/overlay.png'},
            },

            {
                ['name'] = 'Jalapeno paprika',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/3/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/3/overlay.png'},
            },

            {
                ['name'] = 'Olivabogyó',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/4/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/4/overlay.png'},
            },

            {
                ['name'] = 'Paradicsom',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/5/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/5/overlay.png'},
            },

            {
                ['name'] = 'Hagyma',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/6/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/6/overlay.png'},
            },

            {
                ['name'] = 'Gomba',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/7/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/7/overlay.png'},
            },
			
			{
                ['name'] = 'Ananász',
                ['imageData'] = {54, 50, 'assets/images/topping/fruit/8/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/fruit/8/overlay.png'},
            },
        }, --<<'Zöldségek/Gyümölcsök',

        { -->>Húsok
            {
                ['name'] = 'Szalámi',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/1/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/1/overlay.png'},
            },

            {
                ['name'] = 'Bacon',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/2/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/2/overlay.png'},
            },

            {
                ['name'] = 'Csirke',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/3/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/3/overlay.png'},
            },

            {
                ['name'] = 'Kolbász',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/4/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/4/overlay.png'},
            },

            {
                ['name'] = 'Sonka',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/5/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/5/overlay.png'},
            },

            --[[{
                ['name'] = 'Tojás',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/6/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/6/overlay.png'},
            },]]--

            {
                ['name'] = 'Rák',
                ['imageData'] = {54, 50, 'assets/images/topping/meat/7/icon.png'},
                ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/topping/meat/7/overlay.png'},
            },
        }, --<<Húsok
    },

    --[[
        Sajtok
    ]]
    {
        ['name'] = 'Sajtok',

        {
            ['name'] = 'Feta',
            ['imageData'] = {53, 50, 'assets/images/cheese/1/icon.png'},
            ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/cheese/1/overlay.png'},
        },

        {
            ['name'] = 'Mozarella',
            ['imageData'] = {56, 50, 'assets/images/cheese/2/icon.png'},
            ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/cheese/2/overlay.png'},
        },

        {
            ['name'] = 'Parmezan',
            ['imageData'] = {67, 48, 'assets/images/cheese/3/icon.png'},
            ['overlayImageData'] = {0, 0, 200, 200, 'assets/images/cheese/3/overlay.png'},
        },
    },
}

drinks = {
    {
        ['name'] = 'Coca-Cola 330ml',
        ['imageData'] = {34, 57, 'assets/images/drinks/1/icon.png'},
    },

    {
        ['name'] = 'Fanta 330ml',
        ['imageData'] = {34, 57, 'assets/images/drinks/2/icon.png'},
    },
	
	{
        ['name'] = 'Sprite 330ml',
        ['imageData'] = {34, 57, 'assets/images/drinks/3/icon.png'},
    },
	
	{
        ['name'] = 'Coca-Cola 0.5l',
        ['imageData'] = {34, 57, 'assets/images/drinks/4/icon.png'},
    },

    {
        ['name'] = 'Fanta 0.5l',
        ['imageData'] = {34, 57, 'assets/images/drinks/5/icon.png'},
    },

    {
        ['name'] = 'Sprite 0.5l',
        ['imageData'] = {34, 57, 'assets/images/drinks/6/icon.png'},
    },
	
	{
        ['name'] = 'Coca-Cola 1.25l',
        ['imageData'] = {34, 57, 'assets/images/drinks/7/icon.png'},
    },

    {
        ['name'] = 'Fanta 1.25l',
        ['imageData'] = {34, 57, 'assets/images/drinks/8/icon.png'},
    },
	
	{
        ['name'] = 'Sprite 1.25l',
        ['imageData'] = {34, 57, 'assets/images/drinks/9/icon.png'},
    },
}